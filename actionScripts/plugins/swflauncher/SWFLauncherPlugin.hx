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
package actionScripts.plugins.swflauncher;

import flash.errors.Error;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.utils.IDataInput;
import mx.collections.ArrayCollection;
import actionScripts.events.FilePluginEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.settings.event.RequestSettingEvent;
import actionScripts.plugins.as3project.mxmlc.MXMLCPlugin;
import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
import actionScripts.plugins.swflauncher.launchers.DeviceLauncher;
import actionScripts.utils.FindAndCopyApplicationDescriptor;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.MobileDeviceVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;
class SWFLauncherPlugin extends PluginBase {

	public static var RUN_AS_DEBUGGER:Bool = false;

	override private function get_name():String {
		return 'SWF Launcher Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Opens .swf files externally. Handles AIR launching via ADL.';
	}

	private var customProcess:NativeProcess;

	private var currentAIRNamespaceVersion:String;

	private var deviceLauncher:DeviceLauncher = new DeviceLauncher();

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(SWFLaunchEvent.EVENT_LAUNCH_SWF, launchSwf);
		dispatcher.addEventListener(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, unLaunchSwf);
		dispatcher.addEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(SWFLaunchEvent.EVENT_LAUNCH_SWF, launchSwf);
		dispatcher.removeEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile);
		dispatcher.removeEventListener(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, unLaunchSwf);
	}

	private function handleOpenFile(event:FilePluginEvent):Void {
		if (event.file.fileBridge.extension == 'swf')
		// Stop Moonshine from trying to open this file
		{

			event.preventDefault();
			// Fake event
			launchSwf(new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, try cast(event.file.fileBridge.getFile, File) catch (e:Dynamic) null));
		}
	}

	private function launchSwf(event:SWFLaunchEvent):Void
	// Find project if we can (otherwise we can't open AIR swfs)
	 {

		if (!event.project) {
			event.project = findProjectForFile(event.file);
		}

		// Do we have an AIR project on our hands?
		if (Std.is(event.project, AS3ProjectVO) && cast((event.project), AS3ProjectVO).testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			launchAIR(event.file, cast((event.project), AS3ProjectVO), event.sdk);
		}
		// Open with default app
		else {

			launchExternal(event.url || event.file);
		}

		warning('Application ' + event.project.name + ' started.');
	}

	// when user has already one session ins progress and tries to build/run the application again- close current session and start new one
	private function unLaunchSwf(event:SWFLaunchEvent):Void {
		if (customProcess != null) {
			customProcess.exit(true); //Forcefully close running SWF
			addRemoveShellListeners(false);
			customProcess = null;
		}
	}

	private function findProjectForFile(file:File):ProjectVO {
		for (project /* AS3HX WARNING could not determine type for var: project exp: EField(EIdent(model),projects) type: null */ in model.projects)
		// See if we're part of this project
		{

			if (file.nativePath.indexOf(project.folderLocation.fileBridge.nativePath) == 0) {
				return project;
			}
		}
		return null;
	}

	private function launchAIR(file:File, project:AS3ProjectVO, sdk:File):Void {
		if (customProcess != null) {
			customProcess.exit(true);
			addRemoveShellListeners(false);
			customProcess = null;
		}

		// Need project opened to run
		if (project == null) {
			return;
		}

		// Can't open files without an SDK set
		if (sdk == null && !project.buildOptions.customSDK)
		// Try to fetch default value from MXMLC plugin
		{

			var event:RequestSettingEvent = new RequestSettingEvent(MXMLCPlugin, 'defaultFlexSDK');
			dispatcher.dispatchEvent(event);
			// None found, abort
			if (event.value == '' || event.value == null) {
				return;
			}

			// Default SDK found, let's use that
			sdk = new File(Std.string(event.value));
		}

		var currentSDK:File = ((project.buildOptions.customSDK)) ? try cast(project.buildOptions.customSDK.fileBridge.getFile, File) catch (e:Dynamic) null : sdk;
		var appXML:String = findAndCopyApplicationDescriptor(file, project, file.parent);

		// In case of mobile project and device-run, lets divert
		if (project.isMobile && !project.buildOptions.isMobileRunOnSimulator) {
			deviceLauncher.runOnDevice(project, sdk, file, appXML, RUN_AS_DEBUGGER);
			return;
		}

		var customInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

		var executableFile:File;
		if (Settings.os == 'win') {
			executableFile = currentSDK.resolvePath('bin/adl.exe');
		} else {
			executableFile = currentSDK.resolvePath('bin/adl');
		}

		//var executableFile: File = new File("C:\\Program Files\\Adobe\\Adobe Flash Builder 4.6\\sdks\\4.14\\bin\\adl.exe");
		customInfo.executable = executableFile;
		var processArgs:Array<String> = new Array<String>();

		if (project.isMobile) {
			var device:MobileDeviceVO;
			if (project.buildOptions.isMobileHasSimulatedDevice.name && !project.buildOptions.isMobileHasSimulatedDevice.key) {
				var deviceCollection:ArrayCollection = (project.buildOptions.targetPlatform == 'iOS') ? ConstantsCoreVO.TEMPLATES_IOS_DEVICES : ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES;
				var i:Int = 0;
				while (i < deviceCollection.length) {
					if (project.buildOptions.isMobileHasSimulatedDevice.name == deviceCollection[i].name) {
						device = deviceCollection[i];
						break;
					}
					i++;
				}
			} else if (!project.buildOptions.isMobileHasSimulatedDevice.name) {
				device = ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES[0];
			} else {
				device = project.buildOptions.isMobileHasSimulatedDevice;
			}

			// @note
			// https://feathersui.com/help/faq/display-density.html

			processArgs.push('-screensize');
			processArgs.push(device.key); // NexusOne
			if (device.dpi != '') {
				processArgs.push('-XscreenDPI');
				processArgs.push(device.dpi);
			}
			processArgs.push('-XversionPlatform');
			processArgs.push(device.type);
			processArgs.push('-profile');
			processArgs.push('mobileDevice');
		} else {
			processArgs.push('-profile');
			processArgs.push('extendedDesktop');
		}

		if (project.nativeExtensions && project.nativeExtensions.length > 0) {
			var relativeExtensionFolderPath:String = project.folderLocation.fileBridge.getRelativePath(project.nativeExtensions[0], true);
			processArgs.push('-extdir');
			processArgs.push(relativeExtensionFolderPath + '/');
		}
		processArgs.push(appXML);
		//processArgs.push(rootPath);

		customInfo.arguments = processArgs;

		customInfo.workingDirectory = new File(project.folderLocation.fileBridge.nativePath);
		customProcess = new NativeProcess();
		addRemoveShellListeners(true);
		customProcess.start(customInfo);
	}

	private function addRemoveShellListeners(add:Bool):Void {
		if (add) {
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		} else {
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (customProcess != null) {
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var syntaxMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
			if (syntaxMatch != null) {
				error('%s\n', data);
			}

			var generalMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('[^:]*:?\\s*Error:\\s(.*)', ''));
			if (syntaxMatch == null && generalMatch != null) {
				error('%s', data);
			} else if (data.match(new as3hx.Compat.Regex('[^:]*:?\\s*warning:\\s(.*)', ''))) {
				warning('%s', data);
			} else if (!RUN_AS_DEBUGGER) {
				debug('%s', data);
			}
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		if (customProcess != null) {
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.STOP_DEBUG, false));
		}
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		if (data.match(new as3hx.Compat.Regex('initial content not found', ''))) {
			warning('SWF source not found in application descriptor.');
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB, false));
		} else if (data.match(new as3hx.Compat.Regex('error while loading initial content', ''))) {
			error('Error while loading SWF source.\nInvalid application descriptor: Unknown namespace: ' + currentAIRNamespaceVersion);
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB, false));
		} else {
			print('%s', data);
		}
	}

	private function launchExternal(file:Dynamic):Void {
		var request:URLRequest = new URLRequest(((Std.is(file, File))) ? file.url : (Std.string(file)));
		try {
			flash.Lib.getURL(request, '_blank');
		} catch (e:Error) {
			error(e.getStackTrace() + ' Error');
		}
	}

	public function new() {
		super();
	}

}