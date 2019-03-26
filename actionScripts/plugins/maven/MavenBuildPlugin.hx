package actionScripts.plugins.maven;

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
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
class MavenBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider {

	public var mavenPath(get, set):String;

	private var status:Int;

	private var stopWithoutMessage:Bool;

	private var buildId:String;

	private static var BUILD_SUCCESS:as3hx.Compat.Regex = new as3hx.Compat.Regex('BUILD SUCCESS', '');

	private static var WARNING:as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[WARNING\\]', '');

	private static var BUILD_FAILED:as3hx.Compat.Regex = new as3hx.Compat.Regex('BUILD FAILED', '');

	private static var ERROR:as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[ERROR\\]', '');

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Maven Build Setup';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Apache Maven® Build Plugin. Esc exits.';
	}

	private function get_mavenPath():String {
		return (model) ? model.mavenPath : null;
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

	override public function start(args:Array<String>, buildDirectory:Dynamic):Void {
		if (nativeProcess.running && running) {
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
		status = MavenBuildStatus.STARTED;

		print('Maven path: %s', mavenPath);
		print('Maven build directory: %s', buildDirectory.fileBridge.nativePath);
		print('Command: %s', args.join(' '));

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, 'Building '));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
		}
	}

	override public function stop(forceStop:Bool = false):Void {
		super.stop(forceStop);

		status = MavenBuildStatus.STOPPED;
	}

	override public function complete():Void {
		nativeProcess.exit();
		running = false;

		status = MavenBuildStatus.COMPLETE;
	}

	private function prepareStart(buildId:String, preArguments:Array<Dynamic>, arguments:Array<Dynamic>, buildDirectory:FileLocation):Void {
		if (buildDirectory == null || !buildDirectory.fileBridge.exists) {
			warning('Maven build directory has not been specified or is invalid.');
			dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, 'Maven Build'));
			return;
		}

		if (arguments.length == 0) {
			warning('Specify Maven commands (Ex. clean install)');
			dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, 'Maven Build'));
			return;
		}

		var args:Array<String> = this.getConstantArguments();
		if (arguments.length > 0) {
			var preArgs:String = (preArguments.length > 0) ?
			preArguments.join(' && ').concat(' && ') : '';
			var commandLine:String = arguments.join(' ');
			var fullCommandLine:String = preArgs.concat(UtilsCore.getMavenBinPath(), ' ', commandLine);

			args.push(fullCommandLine);
		}

		start(args, buildDirectory);
	}

	override private function startConsoleBuildHandler(event:Event):Void {
		super.startConsoleBuildHandler(event);

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

		if (status == MavenBuildStatus.COMPLETE) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
			this.status = 0;
			running = false;
		}
	}

	override private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		super.onNativeProcessExit(event);

		if (!stopWithoutMessage) {
			var info:String = (Math.isNaN(event.exitCode)) ?
			'Maven build has been terminated.' :
			'Maven build has been terminated with exit code: ' + event.exitCode;

			warning(info);
		}

		stopWithoutMessage = false;
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

		if (status == MavenBuildStatus.COMPLETE) {
			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
			this.status = 0;
		}
	}

	private function onProjectBuildTerminate(event:StatusBarEvent):Void {
		stop();
		dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_TERMINATED, this.buildId, MavenBuildStatus.STOPPED));
	}

	private function processOutput(data:String):Void {
		if (buildFailed(data) || data.match(ERROR)) {
			error('%s', data);
		} else if (data.match(WARNING)) {
			warning('%s', data);
		} else {
			print('%s', data);
			buildSuccess(data);
		}
	}

	private function buildFailed(data:String):Bool {
		if (data.match(BUILD_FAILED)) {
			stop();
			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));

			return true;
		}

		return false;
	}

	private function buildSuccess(data:String):Void {
		if (data.match(BUILD_SUCCESS)) {
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
		var mavenBuildEvent:MavenBuildEvent = try cast(event, MavenBuildEvent) catch (e:Dynamic) null;
		if (mavenBuildEvent != null) {
			return mavenBuildEvent.buildId;
		}

		return null;
	}

	private function getPreCommandLine(event:Event):Array<Dynamic> {
		var mavenBuildEvent:MavenBuildEvent = try cast(event, MavenBuildEvent) catch (e:Dynamic) null;
		if (mavenBuildEvent != null) {
			return mavenBuildEvent.preCommands;
		}

		return [];
	}

	private function getCommandLine(event:Event):Array<Dynamic> {
		var mavenBuildEvent:MavenBuildEvent = try cast(event, MavenBuildEvent) catch (e:Dynamic) null;
		if (mavenBuildEvent != null) {
			return mavenBuildEvent.commands;
		}

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			return Reflect.field(project, 'mavenBuildOptions').getCommandLine();
		}

		return [];
	}

	private function getBuildDirectory(event:Event):FileLocation {
		var mavenBuildEvent:MavenBuildEvent = try cast(event, MavenBuildEvent) catch (e:Dynamic) null;
		if (mavenBuildEvent != null) {
			return new FileLocation(mavenBuildEvent.buildDirectory);
		}

		var project:ProjectVO = model.activeProject;
		if (project != null) {
			if (Reflect.field(project, 'mavenBuildOptions').mavenBuildPath) {
				return new FileLocation(Reflect.field(project, 'mavenBuildOptions').mavenBuildPath);
			}
		}

		return null;
	}

}