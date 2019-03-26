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

	private static var APP_WAS_DEPLOYED:as3hx.Compat.Regex = new as3hx.Compat.Regex('app was successfully deployed', '');

	private static var APP_FAILED:as3hx.Compat.Regex = new as3hx.Compat.Regex('Failed to start, exiting', '');

	private static var CLOSED:as3hx.Compat.Regex = new as3hx.Compat.Regex('\\[CLOSED\\]', '');

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
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Preview PrimeFaces project.';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_VISUALEDITOR_FILE, previewVisualEditorFileHandler);
		dispatcher.addEventListener(PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW, stopVisualEditorPreviewHandler);
		dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, closeProjectHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_VISUALEDITOR_FILE, previewVisualEditorFileHandler);
	}

	override public function complete():Void {
		if (status == MavenBuildStatus.STOPPED) {
			return;
		}

		status = MavenBuildStatus.COMPLETE;
		startPreview();
	}

	override public function stop(forceStop:Bool = false):Void {
		if (!running && status != MavenBuildStatus.COMPLETE) {
			warning('Preview is not running.');
			return;
		}

		if (status == MavenBuildStatus.COMPLETE) {
			payaraShutdownSocket = new Socket(LOCAL_HOST, PAYARA_SHUTDOWN_PORT);
			payaraShutdownSocket.addEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
			payaraShutdownSocket.addEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);
		} else {
			super.stop(forceStop);
		}
	}

	override private function startConsoleBuildHandler(event:Event):Void {}

	override private function stopConsoleBuildHandler(event:Event):Void {}

	override private function onNativeProcessStandardErrorData(event:ProgressEvent):Void {
		var data:String = getDataFromBytes(nativeProcess.standardError);
		processOutput(data);

		if (status == MavenBuildStatus.COMPLETE) {
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			running = false;
		}
	}

	override private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		removeNativeProcessEventListeners();

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
		}
	}

	override private function processOutput(data:String):Void {
		if (projectClosed(data)) {
			currentProject = this.newProject;
			filePreview = this.newFilePreview;
			prepareProjectForPreviewing();
			return;
		} else {
			super.processOutput(data);
		}
	}

	override private function buildFailed(data:String):Bool {
		var failed:Bool = super.buildFailed(data);
		if (!failed) {
			if (data.match(APP_FAILED)) {
				stop();
				dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));

				failed = true;
			}
		}

		return failed;
	}

	override private function buildSuccess(data:String):Void {
		super.buildSuccess(data);

		if (data.match(APP_WAS_DEPLOYED)) {
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
	}

	private function onPayaraShutdownSocketConnect(event:Event):Void {
		payaraShutdownSocket.removeEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
		payaraShutdownSocket.removeEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);

		payaraShutdownSocket.writeUTFBytes(PAYARA_SHUTDOWN_COMMAND);
		payaraShutdownSocket.flush();

		payaraShutdownSocket.close();
		payaraShutdownSocket = null;
	}

	private function previewVisualEditorFileHandler(event:PreviewPluginEvent):Void {
		var newProject:AS3ProjectVO = try cast(UtilsCore.getProjectFromProjectFolder(try cast(event.fileWrapper, FileWrapper) catch (e:Dynamic) null), AS3ProjectVO) catch (e:Dynamic) null;
		if (newProject == null) {
			return;
		}

		if (currentProject != null && currentProject != newProject) {
			this.newProject = newProject;
			this.newFilePreview = event.fileWrapper.file;

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

		if (!model.payaraServerLocation) {
			warning('Server for PrimeFaces preview has not been setup');
			return;
		}

		this.newProject = null;
		this.newFilePreview = null;

		filePreview = event.fileWrapper.file;
		currentProject = newProject;

		if (status == MavenBuildStatus.COMPLETE && status != MavenBuildStatus.STOPPED) {
			startPreview();
		} else {
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
	}

	private function prepareProjectForPreviewing():Void {
		if (currentProject == null && filePreview == null) {
			return;
		}

		this.newProject = null;
		this.newFilePreview = null;

		dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
		dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

		dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
	}

	private function preparePreviewServer():Void {
		if (currentProject == null) {
			return;
		}

		var preCommands:Array<Dynamic> = this.getPreRunPreviewServerCommands();
		var commands:Array<Dynamic> = ['compile', 'exec:exec'];

		buildId = PAYARA_SERVER_BUILD;
		prepareStart(buildId, preCommands, commands, model.payaraServerLocation);
	}

	private function startPreview():Void {
		if (currentProject == null || filePreview == null) {
			return;
		}

		var fileName:String = filePreview.fileBridge.nativePath.replace(currentProject.sourceFolder.fileBridge.nativePath, '');
		if (filePreview.fileBridge.isDirectory) {
			fileName = currentProject.name.concat('.', PREVIEW_EXTENSION_FILE);
			var mainFile:FileLocation = currentProject.targets[0];
			if (!mainFile.fileBridge.exists) {
				warning('Project does not contains main file. Choose specific file for preview.');
				return;
			}
		}

		var urlReq:URLRequest = new URLRequest(URL_PREVIEW.concat(fileName));
		flash.Lib.getURL(urlReq);
	}

	private function getPreRunPreviewServerCommands():Array<Dynamic> {
		var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
		var prefixSet:String = (ConstantsCoreVO.IS_MACOS) ? 'export' : 'set';

		return [prefixSet.concat(' JAVA_EXEC=', executableJavaLocation.fileBridge.nativePath),
		prefixSet.concat(' TARGET_PATH=', getMavenBuildProjectPath())
	];
	}

	private function getMavenBuildProjectPath():String {
		if (currentProject == null) {
			return null;
		}

		var projectPomFile:FileLocation = new FileLocation(currentProject.mavenBuildOptions.mavenBuildPath).resolvePath('pom.xml');

		var artifactId:String = MavenPomUtil.getProjectId(projectPomFile);
		var version:String = MavenPomUtil.getProjectVersion(projectPomFile);

		var separator:String = projectPomFile.fileBridge.separator;

		return currentProject.folderLocation.fileBridge.nativePath.concat(separator, 'target', separator, artifactId, '-', version);
	}

	private function projectClosed(data:String):Bool {
		if (data.match(CLOSED)) {
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