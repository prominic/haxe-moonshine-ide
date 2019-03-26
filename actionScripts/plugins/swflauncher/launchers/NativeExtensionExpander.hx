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

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import mx.controls.Alert;
import actionScripts.factory.FileLocation;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
class NativeExtensionExpander {

	public function new(extensions:Array<Dynamic>) {
		for (i in extensions) {
			if (i.extension.toLowerCase() == 'ane') {
				var onlyFileName:String = i.name.substr(0, i.name.length - 4);
				var extensionNamedFolder:File = i.parent.resolvePath(onlyFileName + 'ANE.ane');

				// if no named folder exists
				if (!extensionNamedFolder.exists) {
					extensionNamedFolder.createDirectory();
					startUnzipProcess(extensionNamedFolder, i);
				}
				// in case of named folder already exists
				else if (extensionNamedFolder.isDirectory)
				// predict if all files are available
				{

					if (extensionNamedFolder.getDirectoryListing().length < 4) {
						startUnzipProcess(extensionNamedFolder, i);
					}
				}
			}
		}
	}

	private function startUnzipProcess(toFolder:File, byANE:File):Void {
		var processArgs:Array<String> = new Array<String>();
		if (ConstantsCoreVO.IS_MACOS) {
			processArgs.push('-c');
			processArgs.push('unzip ../' + byANE.name);
		} else {
			processArgs.push('xf');
			processArgs.push('..\\' + byANE.name);
		}

		var tmpExecutableJava:FileLocation = UtilsCore.getExecutableJavaLocation();
		if (!ConstantsCoreVO.IS_MACOS && (tmpExecutableJava == null || !tmpExecutableJava.fileBridge.exists)) {
			Alert.show('You need Java to complete this process.\nYou can setup Java by going into Settings under File menu.', 'Error!');
			return;
		} else if (!ConstantsCoreVO.IS_MACOS) {
			tmpExecutableJava = tmpExecutableJava.fileBridge.parent.resolvePath('jar.exe');
		}

		var shellInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		shellInfo.arguments = processArgs;
		shellInfo.executable = (ConstantsCoreVO.IS_MACOS) ? new File('/bin/bash') : try cast(tmpExecutableJava.fileBridge.getFile, File) catch (e:Dynamic) null;
		shellInfo.workingDirectory = toFolder;

		var fcsh:NativeProcess = new NativeProcess();
		startShell(fcsh, shellInfo);
	}

	private function startShell(fcsh:NativeProcess, shellInfo:NativeProcessStartupInfo = null, start:Bool = true):Void {
		if (start) {
			fcsh = new NativeProcess();
			fcsh.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			fcsh.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			fcsh.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			fcsh.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			fcsh.start(shellInfo);
		} else {
			if (fcsh == null) {
				return;
			}
			if (fcsh.running) {
				fcsh.exit();
			}
			fcsh.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			fcsh.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			fcsh.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			fcsh.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			fcsh = null;
		}
	}

	private function shellError(event:ProgressEvent):Void {
		var output:IDataInput = event.target.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		trace('Error in Native Extension unzip process: ' + data);

		startShell(try cast(event.target, NativeProcess) catch (e:Dynamic) null, null, false);
	}

	private function shellExit(event:NativeProcessExitEvent):Void {
		startShell(try cast(event.target, NativeProcess) catch (e:Dynamic) null, null, false);
	}

}