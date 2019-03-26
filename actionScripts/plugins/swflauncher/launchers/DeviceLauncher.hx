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
package actionScripts.plugins.swflauncher.launchers;

import com.adobe.utils.StringUtil;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import mx.controls.Alert;
import mx.events.CloseEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ShowSettingsEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
class DeviceLauncher extends ConsoleOutputter {

	private var customProcess:NativeProcess;

	private var customInfo:NativeProcessStartupInfo;

	private var queue:Array<Dynamic> = new Array<Dynamic>();

	private var connectedDevices:Array<String>;

	private var windowsAutoJavaLocation:File;

	private var model:IDEModel = IDEModel.getInstance();

	private var isAndroid:Bool;

	private var isRunAsDebugger:Bool;

	private var isErrorClose:Bool;

	public function new() {
		super();
	}

	public function runOnDevice(project:AS3ProjectVO, sdk:File, swf:File, descriptorPath:String, runAsDebugger:Bool = false):Void {
		isAndroid = (project.buildOptions.targetPlatform == 'Android');
		isRunAsDebugger = runAsDebugger;

		// checks if the credentials are present
		if (!ensureCredentialsPresent(project)) {
			return;
		}

		// We need the application ID; without pre-guessing any
		// lets read and find it
		var descriptorFile:FileLocation = project.folderLocation.fileBridge.resolvePath(descriptorPath);
		var descriptorXML:FastXML = new FastXML(descriptorFile.fileBridge.read());
		var xmlns:Namespace = new Namespace(descriptorXML.node.namespace.innerData());
		var appID:String = descriptorXML.node.xmlns::id.innerData;

		var descriptorPathModified:Array<Dynamic> = descriptorPath.split(File.separator);
		var adtPath:String = '-jar&&' + sdk.nativePath + '/lib/adt.jar&&';

		// STEP 1
		//var executableFile:File = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
		var executableFile:File;
		if (!ConstantsCoreVO.IS_MACOS && windowsAutoJavaLocation != null) {
			executableFile = windowsAutoJavaLocation;
		} else {
			var tmpExecutableJava:FileLocation = UtilsCore.getExecutableJavaLocation();
			if (tmpExecutableJava != null) {
				executableFile = try cast(tmpExecutableJava.fileBridge.getFile, File) catch (e:Dynamic) null;
			}
			if (!ConstantsCoreVO.IS_MACOS && windowsAutoJavaLocation == null) {
				windowsAutoJavaLocation = executableFile;
			}
		}

		if (executableFile == null || !executableFile.exists) {
			Alert.show('You need Java to complete this process.\nYou can setup Java by going into Settings under File menu.', 'Error!');
			return;
		}

		if (customProcess != null) {
			startShell(false);
		}
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executableFile;
		customInfo.workingDirectory = swf.parent;

		queue = new Array<Dynamic>();

		addToQueue({
					com: adtPath + '-devices&&-platform&&' + ((isAndroid) ? 'android' : 'ios'),
					showInConsole: false
				});

		var debugOptions:String = '';
		if (runAsDebugger) {
			debugOptions = '&&-connect';
		}

		var adtPackagingCom:String;
		if (isAndroid) {
			var androidPackagingMode:String = null;
			if (runAsDebugger) {
				androidPackagingMode = 'apk-debug';
			} else {
				androidPackagingMode = 'apk';
			}
			adtPackagingCom = adtPath + '-package&&-target&&' + androidPackagingMode + debugOptions + '&&-storetype&&pkcs12&&-keystore&&' + project.buildOptions.certAndroid + '&&-storepass&&' + ((isAndroid) ? project.buildOptions.certAndroidPassword : project.buildOptions.certIosPassword) + '&&' + project.name + '.apk' + '&&' + descriptorPathModified[descriptorPathModified.length - 1] + '&&' + swf.name;
		} else {
			var iOSPackagingMode:String = null;
			if (runAsDebugger) {
				if (project.buildOptions.iosPackagingMode == BuildOptions.IOS_PACKAGING_FAST)
				//fast bypasses bytecode translation interprets the SWF
				{

					iOSPackagingMode = 'ipa-debug-interpreter';
				}
				//standard takes longer to package
				else {

					//debug builds aren't meant for the app store, though
					iOSPackagingMode = 'ipa-debug';
				}
			}
			//release
			else {

				{
					if (project.buildOptions.iosPackagingMode == BuildOptions.IOS_PACKAGING_FAST)
					//fast bypasses bytecode translation interprets the SWF
					{

						iOSPackagingMode = 'ipa-test-interpreter';
					}
					//standard takes longer to package
					else {

						//release builds are suitable for the app store
						iOSPackagingMode = 'ipa-app-store';
					}
				}
			}

			adtPackagingCom = adtPath + '-package&&-target&&' + iOSPackagingMode + debugOptions + '&&-storetype&&pkcs12&&-keystore&&' + project.buildOptions.certIos + '&&-storepass&&' + ((isAndroid) ? project.buildOptions.certAndroidPassword : project.buildOptions.certIosPassword) + '&&-provisioning-profile&&' + project.buildOptions.certIosProvisioning + '&&' + project.name + '.ipa' + '&&' + descriptorPathModified[descriptorPathModified.length - 1] + '&&' + swf.name;
		}

		// extensions and resources
		if (project.nativeExtensions && project.nativeExtensions.length > 0) {
			adtPackagingCom += '&&-extdir&&' + project.nativeExtensions[0].fileBridge.nativePath;
		}
		if (project.resourcePaths) {
			for (i /* AS3HX WARNING could not determine type for var: i exp: EField(EIdent(project),resourcePaths) type: null */ in project.resourcePaths) {
				adtPackagingCom += '&&' + i.fileBridge.nativePath;
			}
		}

		addToQueue({
					com: adtPackagingCom,
					showInConsole: true
				});
		addToQueue({
					com: adtPath + '-installApp&&-platform&&' + ((isAndroid) ? 'android' : 'ios') + '{{DEVICE}}-package&&' + project.name + ((isAndroid) ? '.apk' : '.ipa'),
					showInConsole: true
				});
		addToQueue({
					com: adtPath + '-launchApp&&-platform&&' + ((isAndroid) ? 'android' : 'ios') + '&&-appid&&' + appID,
					showInConsole: true
				});

		if (customProcess != null) {
			startShell(false);
		}
		startShell(true);
		flush();
	}

	private function ensureCredentialsPresent(project:AS3ProjectVO):Bool {
		if (isAndroid && (project.buildOptions.certAndroid && project.buildOptions.certAndroid != '') && (project.buildOptions.certAndroidPassword && project.buildOptions.certAndroidPassword != '')) {
			return true;
		} else if (!isAndroid && (project.buildOptions.certIos && project.buildOptions.certIos != '') && (project.buildOptions.certIosPassword && project.buildOptions.certIosPassword != '') && (project.buildOptions.certIosProvisioning && project.buildOptions.certIosProvisioning != '')) {
			return true;
		}

		Alert.show('Insufficient information. Process terminates.', 'Error!', Alert.OK, null, onProcessTerminatesDueToCredentials);
		return false;

		/*
		 * @local
		 */
		function onProcessTerminatesDueToCredentials(event:CloseEvent):Void {
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ShowSettingsEvent(project, 'run')
			);
		};
	}

	private function addToQueue(value:Dynamic):Void {
		queue.push(value);
	}

	private function flush():Void {
		if (queue.length == 0) {
			startShell(false);
			return;
		}

		if (queue[0].showInConsole) {
			debug('Sending to adt: %s', queue[0].com);
		}

		var tmpArr:Array<Dynamic> = queue[0].com.split('&&');
		customInfo.arguments = tmpArr;

		queue.shift();
		customProcess.start(customInfo);
	}

	private function startShell(start:Bool):Void {
		if (start) {
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		} else {
			if (customProcess == null) {
				return;
			}
			if (customProcess.running) {
				customProcess.exit();
			}
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			customProcess = null;
			GlobalEventDispatcher.getInstance().dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.STOP_DEBUG, false));
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (customProcess != null) {
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var syntaxMatch:Array<Dynamic>;
			var generalMatch:Array<Dynamic>;
			var initMatch:Array<Dynamic>;

			syntaxMatch = data.match(new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
			if (syntaxMatch != null) {
				var pathStr:String = syntaxMatch[1];
				var lineNum:Int = syntaxMatch[2];
				var colNum:Int = syntaxMatch[3];
				var errorStr:String = syntaxMatch[4];
			}

			generalMatch = data.match(new as3hx.Compat.Regex('(.*?): Error: (.*).*', ''));
			if (syntaxMatch == null && generalMatch != null) {
				pathStr = generalMatch[1];
				errorStr = generalMatch[2];
				pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);
				debug('%s', data);
			} else if (!isRunAsDebugger) {
				debug('%s', data);
			}

			isErrorClose = true;
			startShell(false);
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		if (customProcess != null) {
			if (!isErrorClose) {
				flush();
			}
		}
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
		var match:Array<Dynamic>;

		match = data.match(new as3hx.Compat.Regex('set flex_home', ''));
		if (match != null) {
			return;
		}

		// osx return
		match = data.match(new as3hx.Compat.Regex('list of attached devices', ''));
		if (match != null) {
			onDeviceListFound();
			return;
		}

		// windows return
		match = data.match(new as3hx.Compat.Regex('list of devices attached', ''));
		if (match != null) {
			onDeviceListFound();
			return;
		}

		match = data.match(new as3hx.Compat.Regex('password', ''));
		if (match != null) {
			return;
		}

		match = data.match(new as3hx.Compat.Regex('the application has been packaged with a shared runtime', ''));
		if (match != null) {
			print('NOTE: The application has been packaged with a shared runtime.');
			return;
		}

		isErrorClose = false;

		/*
		 * @local
		 */
		function onDeviceListFound():Void
		/*
				@example
				@ios
				List of attached devices:
				Handle	DeviceClass	DeviceUUID					DeviceName
				1	iPad    	6de82fb31xxxxxxxxxxxxcc8	My iPad

				@android
				list of devices attached
				h7azcyxxxx32	device
				*/
		 {

			var devicesLines:Array<Dynamic> = data.split('\n');
			devicesLines.shift(); // one
			if (!isAndroid) {
				devicesLines.shift();
			} // two
			connectedDevices = new Array<String>();
			for (i in Reflect.fields(devicesLines)) {
				if (StringTools.trim(Reflect.field(devicesLines, i)).length != 0) {
					var newDevice:DeviceVO = new DeviceVO();
					var breakups:Array<Dynamic> = Reflect.field(devicesLines, i).split('\t');

					if (!isAndroid) {
						newDevice.deviceID = as3hx.Compat.parseInt(StringTools.trim(breakups[0]));
						newDevice.deviceUDID = StringTools.trim(breakups[2]);
					} else {
						newDevice.deviceUDID = StringTools.trim(breakups[0]);
					}

					connectedDevices.push(newDevice);
				} else {
					break;
				}
			}

			// probable termination if no device found connected
			if (connectedDevices.length == 0) {
				Alert.show('Please make sure your device is connected.', 'Error!');
				startShell(false);
				return;
			} else {
				var deviceString:String = (isAndroid) ? '&&' : '&&-device&&' + newDevice.deviceID + '&&';
				queue[1].com = queue[1].com.replace('{{DEVICE}}', deviceString);
			}
		};
	}

}