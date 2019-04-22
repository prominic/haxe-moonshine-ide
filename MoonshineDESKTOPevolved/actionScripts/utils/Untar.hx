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
package actionScripts.utils;

import haxe.Constraints.Function;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import actionScripts.factory.FileLocation;

class Untar {

	private var process:NativeProcess;
	private var ownerCompleteFn:Function;
	private var ownerErrorFn:Function;

	private var unzipTo:FileLocation;

	public function new(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null) {
		this.unzipTo = unzipTo;

		ownerCompleteFn = cast unzipCompleteFunction;
		ownerErrorFn = cast unzipErrorFunction;

		var tar:File;
		var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		var arguments:Array<String> = new Array<String>();

		tar = new File('/usr/bin/tar');
		if (!AS3.as(tar.exists, Bool)) {
			tar = new File('/usr/bin/bsdtar');
		}

		arguments.push('xf');
		arguments.push(fileToUnzip.fileBridge.nativePath);
		arguments.push('-C');
		arguments.push(unzipTo.fileBridge.nativePath);

		startupInfo.executable = tar;
		startupInfo.arguments = arguments;

		process = new NativeProcess();
		process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unTarFileProgress, false, 0, true);
		process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unzipErrorFunction, false, 0, true);
		process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unTarError, false, 0, true);
		process.addEventListener(NativeProcessExitEvent.EXIT, unzipCompleteFunction, false, 0, true);
		process.addEventListener(NativeProcessExitEvent.EXIT, unTarComplete, false, 0, true);
		process.start(startupInfo);
	}

	private function unTarError(event:Event):Void {
		//var output:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
	}

	private function unTarFileProgress(event:Event):Void {
		/*var output:String = _process.standardOutput.readUTFBytes(_process.standardOutput.bytesAvailable);
		log(output);*/
	}

	private function unTarComplete(event:NativeProcessExitEvent):Void {
		removeListeners();
		process.closeInput();
		process.exit(true);
	}

	private function removeListeners():Void {
		process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unTarFileProgress);
		process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, unTarError);
		process.removeEventListener(NativeProcessExitEvent.EXIT, unTarComplete);
		process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, ownerErrorFn);
		process.removeEventListener(NativeProcessExitEvent.EXIT, ownerCompleteFn);

		ownerCompleteFn = null;
		ownerErrorFn = null;
	}

}