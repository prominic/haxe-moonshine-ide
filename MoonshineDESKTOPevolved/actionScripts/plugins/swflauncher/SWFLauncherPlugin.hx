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
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
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
		if (event.file.fileBridge.extension == 'swf') {
			// Stop Moonshine from trying to open this file
			event.preventDefault();
			// Fake event
			launchSwf(new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, AS3.as(event.file.fileBridge.getFile, File)));
		}
	}

	private function launchSwf(event:SWFLaunchEvent):Void {
		// Find project if we can (otherwise we can't open AIR swfs)
		if (event.project == null) {
			event.project = findProjectForFile(event.file);
		}

		// Do we have an AIR project on our hands?
		if (Std.is(event.project, AS3ProjectVO) && AS3ProjectVO(event.project).testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			launchAIR(event.file, AS3ProjectVO(event.project), event.sdk);
		}// Open with default app
		else {
			// Open with default app
			launchExternal((event.url != null) ? event.url : Std.string(event.file));
		}

		warning('Application ' + event.project.name + ' started.');
	}

	// when user has already one session ins progress and tries to build/run the application again- close current session and start new one
	private function unLaunchSwf(event:SWFLaunchEvent):Void {
		if (customProcess != null) {
			customProcess.exit(true);//Forcefully close running SWF
			addRemoveShellListeners(false);
			customProcess = null;
		}
	}

	private function findProjectForFile(file:File):ProjectVO {
		for (project in as3hx.Compat.each(model.projects)) {
			// See if we're part of this project
			if (file.nativePath.indexOf(Reflect.field(Reflect.field(Reflect.field(project, 'folderLocation'), 'fileBridge'), 'nativePath')) == 0) {
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
		if (sdk == null && !AS3.as(project.buildOptions.customSDK, Bool)) {
			// Try to fetch default value from MXMLC plugin
			var event:RequestSettingEvent = new RequestSettingEvent(MXMLCPlugin, 'defaultFlexSDK');
			dispatcher.dispatchEvent(event);
			// None found, abort
			if (event.value == '' || event.value == null) {
				return;
			}

			// Default SDK found, let's use that
			sdk = new File(Std.string(event.value));
		}

		var currentSDK:File = ((AS3.as(project.buildOptions.customSDK, Bool))) ? AS3.as(project.buildOptions.customSDK.fileBridge.getFile, File) : sdk;
		var appXML:String = Std.string(FindAndCopyApplicationDescriptor.findAndCopyApplicationDescriptor(file, project, file.parent));

		// In case of mobile project and device-run, lets divert
		if (AS3.as(project.isMobile, Bool) && !AS3.as(project.buildOptions.isMobileRunOnSimulator, Bool)) {
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

		if (AS3.as(project.isMobile, Bool)) {
			var device:MobileDeviceVO;
			if (AS3.as(project.buildOptions.isMobileHasSimulatedDevice.name, Bool) && !AS3.as(project.buildOptions.isMobileHasSimulatedDevice.key, Bool)) {
				var deviceCollection:ArrayCollection = (project.buildOptions.targetPlatform == 'iOS') ? ConstantsCoreVO.TEMPLATES_IOS_DEVICES : ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES;
				for (i in 0...deviceCollection.length) {
					if (project.buildOptions.isMobileHasSimulatedDevice.name == Reflect.getProperty(deviceCollection, Std.string(i)).name) {
						device = Reflect.getProperty(deviceCollection, Std.string(i));
						break;
					}
				}
			} else if (!AS3.as(project.buildOptions.isMobileHasSimulatedDevice.name, Bool)) {
				device = Reflect.getProperty(ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES, Std.string(0));
			} else {
				device = project.buildOptions.isMobileHasSimulatedDevice;
			}

			// @note
			// https://feathersui.com/help/faq/display-density.html

			processArgs.push('-screensize');
			processArgs.push(device.key);// NexusOne
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

		if (AS3.as(project.nativeExtensions, Bool) && project.nativeExtensions.length > 0) {
			var relativeExtensionFolderPath:String = Std.string(project.folderLocation.fileBridge.getRelativePath(Reflect.getProperty(project.nativeExtensions, Std.string(0)), true));
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

			var syntaxMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
			if (syntaxMatch != null) {
				error('%s\n', data);
			}

			var generalMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('[^:]*:?\\s*Error:\\s(.*)', ''));
			if (syntaxMatch == null && generalMatch != null) {
				error('%s', data);
			} else if (AS3.as(as3hx.Compat.match(data, new as3hx.Compat.Regex('[^:]*:?\\s*warning:\\s(.*)', '')), Bool)) {
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

		if (AS3.as(as3hx.Compat.match(data, new as3hx.Compat.Regex('initial content not found', '')), Bool)) {
			warning('SWF source not found in application descriptor.');
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB, false));
		} else if (AS3.as(as3hx.Compat.match(data, new as3hx.Compat.Regex('error while loading initial content', '')), Bool)) {
			error('Error while loading SWF source.\nInvalid application descriptor: Unknown namespace: ' + currentAIRNamespaceVersion);
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB, false));
		} else {
			print('%s', data);
		}
	}

	private function launchExternal(file:Dynamic):Void {
		var request:URLRequest = new URLRequest(((Std.is(file, File))) ? AS3.string(Reflect.field(file, 'url')) : (Std.string(file)));
		try {
			flash.Lib.getURL(request, '_blank');// second argument is target
		} catch (e:Error) {
			error(e.getStackTrace() + ' Error');
		}
	}

	public function new() {
		super();
	}

}