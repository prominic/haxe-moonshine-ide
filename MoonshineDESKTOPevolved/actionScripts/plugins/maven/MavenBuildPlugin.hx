package actionScripts.plugins.maven;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import actionScripts.events.MavenBuildEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.events.ShowSettingsEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.build.MavenBuildStatus;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugins.build.ConsoleBuildPluginBase;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;

class MavenBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider {

	private var status:Int = 0;
	private var stopWithoutMessage:Bool = false;

	private var buildId:String;
	private var isProjectHasInvalidPaths:Bool = false;

	private static var BUILD_SUCCESS(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('BUILD SUCCESS', '');
	private static var WARNING(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[WARNING\\]', '');
	private static var BUILD_FAILED(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('BUILD FAILED', '');
	private static var BUILD_FAILURE(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('BUILD FAILURE', '');
	private static var ERROR(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[ERROR\\]', '');

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Maven Build Setup';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Apache Maven® Build Plugin. Esc exits.';
	}

	public var mavenPath(get, set):String;
	private function get_mavenPath():String {
		return (model != null) ? Std.string(model.mavenPath) : null;
	}

	private function set_mavenPath(value:String):String {
		if (model.mavenPath != value) {
			model.mavenPath = value;
		}
		return value;
	}

	public function getSettingsList():Array<ISetting> {
		return [
				new PathSetting(this, 'mavenPath', 'Maven Home', true, mavenPath)
		];
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(MavenBuildEvent.START_MAVEN_BUILD, startConsoleBuildHandler);
		dispatcher.addEventListener(MavenBuildEvent.STOP_MAVEN_BUILD, stopConsoleBuildHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(MavenBuildEvent.START_MAVEN_BUILD, startConsoleBuildHandler);
		dispatcher.removeEventListener(MavenBuildEvent.STOP_MAVEN_BUILD, stopConsoleBuildHandler);
	}

	override private function onProjectPathsValidated(paths:Array<Dynamic>):Void {
		if (paths != null) {
			isProjectHasInvalidPaths = true;
			error('Following path(s) are invalid or does not exists:\n' + paths.join('\n'));
		}
	}

	override public function start(args:Array<String>, buildDirectory:Dynamic):Void {
		if (AS3.as(nativeProcess.running, Bool) && running) {
			warning('Build is running. Wait for finish...');
			return;
		}

		if (mavenPath == null) {
			error('Specify path to Maven folder.');
			stop(true);
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.maven::MavenBuildPlugin'));
			return;
		}

		warning('Starting Maven build...');

		super.start(args, buildDirectory);
		status = AS3.int(MavenBuildStatus.STARTED);

		print('Maven path: %s', mavenPath);
		print('Maven build directory: %s', Reflect.field(Reflect.field(buildDirectory, 'fileBridge'), 'nativePath'));
		print('Command: %s', args.join(' '));

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, 'Building '));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
		}
	}

	override public function stop(forceStop:Bool = false):Void {
		super.stop(forceStop);

		status = AS3.int(MavenBuildStatus.STOPPED);
	}

	override public function complete():Void {
		nativeProcess.exit();
		running = false;

		status = AS3.int(MavenBuildStatus.COMPLETE);
	}

	private function prepareStart(buildId:String, preArguments:Array<Dynamic>, arguments:Array<Dynamic>, buildDirectory:FileLocation):Void {
		if (buildDirectory == null || !AS3.as(buildDirectory.fileBridge.exists, Bool)) {
			warning('Maven build directory has not been specified or is invalid.');
			dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, 'Maven Build'));
			return;
		}

		if (arguments.length == 0) {
			warning('Specify Maven commands (Ex. clean install)');
			dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, 'Maven Build'));
			return;
		}

		checkProjectForInvalidPaths(model.activeProject);
		if (isProjectHasInvalidPaths) {
			return;
		}

		var args:Array<String> = this.getConstantArguments();
		if (arguments.length > 0) {
			var preArgs:String = (preArguments.length > 0) ?
			Std.string(preArguments.join(' && ').concat(' && ')) : '';
			var commandLine:String = arguments.join(' ');
			var fullCommandLine:String = Std.string(preArgs.concat(UtilsCore.getMavenBinPath(), ' ', commandLine));

			args.push(fullCommandLine);
		}

		start(args, buildDirectory);
	}

	override private function startConsoleBuildHandler(event:Event):Void {
		super.startConsoleBuildHandler(event);

		this.isProjectHasInvalidPaths = false;
		this.status = 0;
		this.buildId = this.getBuildId(event);
		var preArguments:Array<Dynamic> = this.getPreCommandLine(event);
		var arguments:Array<Dynamic> = this.getCommandLine(event);
		var buildDirectory:FileLocation = this.getBuildDirectory(event);

		prepareStart(this.buildId, preArguments, arguments, buildDirectory);
	}

	override private function stopConsoleBuildHandler(event:Event):Void {
		super.stopConsoleBuildHandler(event);

		stop(true);
	}

	override private function onNativeProcessStandardOutputData(event:ProgressEvent):Void {
		var data:String = getDataFromBytes(nativeProcess.standardOutput);
		processOutput(data);
	}

	override private function onNativeProcessIOError(event:IOErrorEvent):Void {
		super.onNativeProcessIOError(event);

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	override private function onNativeProcessStandardErrorData(event:ProgressEvent):Void {
		var data:String = getDataFromBytes(nativeProcess.standardError);
		processOutput(data);

		if (status == AS3.int(MavenBuildStatus.COMPLETE)) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
			this.status = 0;
			running = false;
		}
	}

	override private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		super.onNativeProcessExit(event);

		if (!stopWithoutMessage) {
			var info:String = (AS3.as(Math.isNaN(event.exitCode), Bool)) ?
			'Maven build has been terminated.' :
			'Maven build has been terminated with exit code: ' + event.exitCode;

			warning(info);
		}

		stopWithoutMessage = false;
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

		if (status == AS3.int(MavenBuildStatus.COMPLETE)) {
			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
			this.status = 0;
		}
	}

	private function onProjectBuildTerminate(event:StatusBarEvent):Void {
		stop();
		dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_TERMINATED, this.buildId, MavenBuildStatus.STOPPED));
	}

	private function processOutput(data:String):Void {
		if (buildFailed(data) || AS3.as(as3hx.Compat.match(data, ERROR), Bool)) {
			error('%s', data);
		} else if (AS3.as(as3hx.Compat.match(data, WARNING), Bool)) {
			warning('%s', data);
		} else {
			print('%s', data);
			buildSuccess(data);
		}
	}

	private function buildFailed(data:String):Bool {
		var hasBuildFailed:Bool = false;

		if (AS3.as(as3hx.Compat.match(data, BUILD_FAILURE), Bool)) {
			deferredStop();
			hasBuildFailed = true;
		} else if (AS3.as(as3hx.Compat.match(data, BUILD_FAILED), Bool)) {
			stop();
			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
			hasBuildFailed = true;
		}

		return hasBuildFailed;
	}

	private function buildSuccess(data:String):Void {
		if (AS3.as(as3hx.Compat.match(data, BUILD_SUCCESS), Bool)) {
			stopWithoutMessage = true;
			complete();
		}
	}

	private function getConstantArguments():Array<String> {
		var args:Array<String> = new Array<String>();
		if (Settings.os == 'win') {
			args.push('/C');
		} else {
			args.push('-c');
		}

		return args;
	}

	private function getBuildId(event:Event):String {
		var mavenBuildEvent:MavenBuildEvent = AS3.as(event, MavenBuildEvent);
		if (mavenBuildEvent != null) {
			return Std.string(mavenBuildEvent.buildId);
		}

		return null;
	}

	private function getPreCommandLine(event:Event):Array<Dynamic> {
		var mavenBuildEvent:MavenBuildEvent = AS3.as(event, MavenBuildEvent);
		if (mavenBuildEvent != null) {
			return mavenBuildEvent.preCommands;
		}

		return [];
	}

	private function getCommandLine(event:Event):Array<Dynamic> {
		var mavenBuildEvent:MavenBuildEvent = AS3.as(event, MavenBuildEvent);
		if (mavenBuildEvent != null) {
			return mavenBuildEvent.commands;
		}

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			return Reflect.getProperty(project, 'mavenBuildOptions').getCommandLine();
		}

		return [];
	}

	private function getBuildDirectory(event:Event):FileLocation {
		var mavenBuildEvent:MavenBuildEvent = AS3.as(event, MavenBuildEvent);
		if (mavenBuildEvent != null) {
			return new FileLocation(mavenBuildEvent.buildDirectory);
		}

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			if (AS3.as(Reflect.getProperty(project, 'mavenBuildOptions').mavenBuildPath, Bool)) {
				return new FileLocation(Reflect.getProperty(project, 'mavenBuildOptions').mavenBuildPath);
			}
		}

		return null;
	}

	private function deferredStop():Void {
		var stopDelay:Int = as3hx.Compat.setTimeout(function():Void {
					stop();
					dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
					as3hx.Compat.clearTimeout(stopDelay);
				}, 800);
	}

}