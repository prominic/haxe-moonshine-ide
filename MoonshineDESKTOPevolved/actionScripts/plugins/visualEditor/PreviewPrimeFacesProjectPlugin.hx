////////////////////////////////////////////////////////////////////////////////
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.visualEditor;

import actionScripts.events.MavenBuildEvent;
import actionScripts.events.PreviewPluginEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.maven.MavenBuildPlugin;
import actionScripts.plugin.build.MavenBuildStatus;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.utils.MavenPomUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import flash.events.Event;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.net.URLRequest;

class PreviewPrimeFacesProjectPlugin extends MavenBuildPlugin {

	private static var APP_WAS_DEPLOYED(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('app was successfully deployed', '');
	private static var APP_FAILED(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('Failed to start, exiting', '');
	private static var APP_FAILED_TO_START(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('Server failed to start', '');
	private static var CLOSED(default, never):as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[CLOSED\\]', '');

	private var PAYARA_SERVER_BUILD(default, never):String = 'payaraServerBuild';
	private var URL_PREVIEW(default, never):String = 'http://localhost:8180/';
	private var PREVIEW_EXTENSION_FILE(default, never):String = 'xhtml';
	private var LOCAL_HOST(default, never):String = 'localhost';
	private var PAYARA_SHUTDOWN_PORT(default, never):Int = 44444;
	private var PAYARA_SHUTDOWN_COMMAND(default, never):String = 'shutdown';

	private var currentProject:AS3ProjectVO;
	private var newProject:AS3ProjectVO;

	private var filePreview:FileLocation;
	private var newFilePreview:FileLocation;

	private var payaraShutdownSocket:Socket;

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Start Preview of PrimeFaces project';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Preview PrimeFaces project.';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, previewVisualEditorFileHandler);
		dispatcher.addEventListener(PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW, stopVisualEditorPreviewHandler);
		dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, closeProjectHandler);
	}

	override private function set_running(value:Bool):Bool {
		super.running = value;
		if (currentProject != null) {
			currentProject.isPreviewRunning = value;
		}
		return value;
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.addEventListener(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, previewVisualEditorFileHandler);
	}

	override public function complete():Void {
		if (status == AS3.int(MavenBuildStatus.STOPPED)) {
			return;
		}

		status = AS3.int(MavenBuildStatus.COMPLETE);
		startPreview();
	}

	override public function stop(forceStop:Bool = false):Void {
		if (!running && status != MavenBuildStatus.COMPLETE) {
			warning('Preview is not running.');
			return;
		}

		if (status == AS3.int(MavenBuildStatus.COMPLETE)) {
			payaraShutdownSocket = new Socket(LOCAL_HOST, PAYARA_SHUTDOWN_PORT);
			payaraShutdownSocket.addEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
			payaraShutdownSocket.addEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);
		} else {
			super.stop(forceStop);

			dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, filePreview, currentProject));
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
		}
	}

	override private function startConsoleBuildHandler(event:Event):Void {}

	override private function stopConsoleBuildHandler(event:Event):Void {}

	override private function onNativeProcessStandardErrorData(event:ProgressEvent):Void {
		var data:String = getDataFromBytes(nativeProcess.standardError);
		processOutput(data);

		if (status == AS3.int(MavenBuildStatus.COMPLETE)) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}
	}

	override private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		removeNativeProcessEventListeners();

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
		}
	}

	override private function processOutput(data:String):Void {
		if (projectClosed(data)) {
			currentProject = this.newProject;
			filePreview = this.newFilePreview;
			prepareProjectForPreviewing();

			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
			return;
		} else {
			super.processOutput(data);
		}
	}

	override private function buildFailed(data:String):Bool {
		var failed:Bool = super.buildFailed(data);
		if (!failed) {
			if (AS3.as(as3hx.Compat.match(data, APP_FAILED), Bool) || AS3.as(as3hx.Compat.match(data, APP_FAILED_TO_START), Bool)) {
				stop();
				dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));

				failed = true;
			}
		}

		return failed;
	}

	override private function buildSuccess(data:String):Void {
		super.buildSuccess(data);

		if (AS3.as(as3hx.Compat.match(data, APP_WAS_DEPLOYED), Bool)) {
			complete();
			warning('Preview server has been successfully started for project %s', currentProject.name);
		}
	}

	private function onPayaraShutdownSocketIOError(event:IOErrorEvent):Void {
		payaraShutdownSocket.removeEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
		payaraShutdownSocket.removeEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);

		error('Shutdown socket connection error %s', event.text);

		if (payaraShutdownSocket.connected) {
			payaraShutdownSocket.close();
			payaraShutdownSocket = null;
		}

		dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, filePreview, currentProject));
		dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
	}

	private function onPayaraShutdownSocketConnect(event:Event):Void {
		payaraShutdownSocket.removeEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
		payaraShutdownSocket.removeEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);

		payaraShutdownSocket.writeUTFBytes(PAYARA_SHUTDOWN_COMMAND);
		payaraShutdownSocket.flush();

		payaraShutdownSocket.close();
		payaraShutdownSocket = null;

		dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, filePreview, currentProject));
	}

	private function previewVisualEditorFileHandler(event:Event):Void {
		var newProject:AS3ProjectVO = null;
		var fileWrapper:Dynamic = null;
		var previewPluginEvent:PreviewPluginEvent = AS3.as(event, PreviewPluginEvent);

		if (previewPluginEvent != null) {
			if (Std.is(previewPluginEvent.fileWrapper, FileWrapper)) {
				newProject = AS3.as(UtilsCore.getProjectFromProjectFolder(AS3.as(previewPluginEvent.fileWrapper, FileWrapper)), AS3ProjectVO);
			} else if (AS3.as(previewPluginEvent.project, Bool)) {
				newProject = previewPluginEvent.project;
				fileWrapper = previewPluginEvent.fileWrapper;
			}
		} else if (AS3.as(model.activeProject, Bool)) {
			newProject = AS3.as(model.activeProject, AS3ProjectVO);
			if (!AS3.as(newProject.isPrimeFacesVisualEditorProject, Bool)) {
				newProject = null;
			} else {
				fileWrapper = newProject.folderLocation;
			}
		}

		if (newProject == null) {
			return;
		}

		if (currentProject != null && currentProject != newProject) {
			this.newProject = newProject;
			this.newFilePreview = AS3.as(fileWrapper, FileLocation);

			stop(true);
			return;
		}

		var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
		if (executableJavaLocation == null) {
			running = false;
			error('In order to run preview server you have to specify Java Development Kit path.');
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.as3project.mxmlc::MXMLCPlugin'));
			return;
		}

		if (!AS3.as(model.payaraServerLocation, Bool)) {
			warning('Server for PrimeFaces preview has not been setup');
			return;
		}

		this.newProject = null;
		this.newFilePreview = null;

		if (previewPluginEvent != null && Std.is(previewPluginEvent.fileWrapper, FileWrapper)) {
			filePreview = previewPluginEvent.fileWrapper.file;
		} else {
			filePreview = AS3.as(fileWrapper, FileLocation);
		}

		currentProject = newProject;

		if (status == AS3.int(MavenBuildStatus.COMPLETE) && status != MavenBuildStatus.STOPPED) {
			dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STARTING, filePreview, currentProject));
			startPreview();
		} else {
			dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STARTING, filePreview, currentProject));
			prepareProjectForPreviewing();
		}
	}

	private function stopVisualEditorPreviewHandler(event:Event):Void {
		if (currentProject == null) {
			return;
		}

		stop(true);
	}

	private function closeProjectHandler(event:ProjectEvent):Void {
		if (event.project == currentProject) {
			dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.STOP_MAVEN_BUILD, null, MavenBuildStatus.STOPPED));

			stopWithoutMessage = true;
			stop();
		}
	}

	private function onMavenBuildComplete(event:MavenBuildEvent):Void {
		dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
		dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

		preparePreviewServer();
	}

	private function onMavenBuildFailed(event:MavenBuildEvent):Void {
		error('Starting Preview has been stopped');

		dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
		dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

		running = false;

		dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_START_FAILED, filePreview, currentProject));
		dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
	}

	private function prepareProjectForPreviewing():Void {
		if (currentProject == null && filePreview == null) {
			return;
		}

		this.newProject = null;
		this.newFilePreview = null;

		dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
		dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

		dispatcher.dispatchEvent(new Event(Std.string(MavenBuildEvent.START_MAVEN_BUILD)));
	}

	private function preparePreviewServer():Void {
		if (currentProject == null) {
			return;
		}

		var preCommands:Array<Dynamic> = this.getPreRunPreviewServerCommands();
		var commands:Array<String> = ['compile', 'exec:exec'];

		buildId = PAYARA_SERVER_BUILD;
		prepareStart(buildId, preCommands, cast commands, model.payaraServerLocation);
	}

	private function startPreview():Void {
		if (currentProject == null || filePreview == null) {
			return;
		}

		var fileName:String = Std.string(filePreview.fileBridge.nativePath.replace(currentProject.sourceFolder.fileBridge.nativePath, ''));
		if (AS3.as(filePreview.fileBridge.isDirectory, Bool)) {
			fileName = Std.string(currentProject.name.concat('.', PREVIEW_EXTENSION_FILE));
			var mainFile:FileLocation = Reflect.getProperty(currentProject.targets, Std.string(0));
			if (!AS3.as(mainFile.fileBridge.exists, Bool)) {
				warning('Project does not contains main file. Choose specific file for preview.');
				return;
			}
		}

		var urlReq:URLRequest = new URLRequest(Std.string(URL_PREVIEW.concat(fileName)));
		flash.Lib.getURL(urlReq);

		dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_START_COMPLETE, filePreview, currentProject));
		dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
	}

	private function getPreRunPreviewServerCommands():Array<Dynamic> {
		var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
		var prefixSet:String = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'export' : 'set';

		return [prefixSet.concat(' JAVA_EXEC=', executableJavaLocation.fileBridge.nativePath),
		prefixSet.concat(' TARGET_PATH=', getMavenBuildProjectPath())
	];
	}

	private function getMavenBuildProjectPath():String {
		if (currentProject == null) {
			return null;
		}

		var projectPomFile:FileLocation = new FileLocation(currentProject.mavenBuildOptions.mavenBuildPath).resolvePath('pom.xml');

		var artifactId:String = Std.string(MavenPomUtil.getProjectId(projectPomFile));
		var version:String = Std.string(MavenPomUtil.getProjectVersion(projectPomFile));

		var separator:String = Std.string(projectPomFile.fileBridge.separator);

		return Std.string(currentProject.folderLocation.fileBridge.nativePath.concat(separator, 'target', separator, artifactId, '-', version));
	}

	private function projectClosed(data:String):Bool {
		if (AS3.as(as3hx.Compat.match(data, CLOSED), Bool)) {
			stopWithoutMessage = true;
			super.stop(true);

			warning('Preview server for project %s has been shutdown.', currentProject.name);

			filePreview = null;
			currentProject = null;

			return true;
		}

		return false;
	}

}