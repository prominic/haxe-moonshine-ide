package actionScripts.plugins.run;

import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import actionScripts.events.RunJavaProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.build.ConsoleBuildPluginBase;
import actionScripts.utils.MavenPomUtil;
import actionScripts.valueObjects.ConstantsCoreVO;

class RunJavaProject extends ConsoleBuildPluginBase {

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Run Java Project';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Java build plugin. Esc exits.';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
	}

	override private function startConsoleBuildHandler(event:Event):Void {
		var javaProjectEvent:RunJavaProjectEvent = AS3.as(event, RunJavaProjectEvent);
		if (javaProjectEvent != null && AS3.as(javaProjectEvent.project, Bool)) {
			warning('Starting application: ' + javaProjectEvent.project.projectName);

			var pomPathLocation:FileLocation = new FileLocation(javaProjectEvent.project.mavenBuildOptions.mavenBuildPath).resolvePath('pom.xml');

			var projectVersion:String = Std.string(MavenPomUtil.getProjectVersion(pomPathLocation));
			var jarName:String = Std.string(javaProjectEvent.project.projectName.concat('-', projectVersion, '.jar'));
			var jarLocation:FileLocation = javaProjectEvent.project.folderLocation.resolvePath('target' + model.fileCore.separator + jarName);

			if (AS3.as(jarLocation.fileBridge.exists, Bool)) {
				var javaCommand:Array<String> = ['java -classpath ' + jarLocation.fileBridge.nativePath +
						' ' + javaProjectEvent.project.mainClassName];
				this.start(javaCommand, javaProjectEvent.project.projectFolder.file);
			} else {
				error('Project .jar file does not exist: ' + jarLocation.fileBridge.nativePath);
			}
		}
	}

	override private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		super.onNativeProcessExit(event);

		if (!AS3.as(Math.isNaN(event.exitCode), Bool)) {
			var info:String = 'Application exited with code: ' + event.exitCode;
			warning(info);
		}
	}

}