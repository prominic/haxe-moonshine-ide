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
package actionScripts.plugins.svn.commands;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
class AddCommand extends SVNCommandBase {

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function add(file:String):Void {
		if (runningForFile) {
			error('Currently running, try again later.');
			return;
		}

		//runningForFile = file;

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		args.push('add');
		args.push(file);

		customInfo.arguments = args;
		// We give the file as target, so go one directory up
		customInfo.workingDirectory = root;

		startShell(true);
		customProcess.start(customInfo);
	}

	private function startShell(start:Bool):Void {
		if (start) {
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
		} else {
			if (!customProcess) {
				return;
			}
			if (customProcess.running) {
				customProcess.exit();
			}
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, svnExit);
			customProcess = null;
			customInfo = null;
		}
	}

	private function svnError(event:ProgressEvent):Void {
		startShell(false);
	}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0)
		// Update succeded (but no need to tell anyone, useful for debugging maybe)
		{

			//var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);
			//notice(str);

			// Tell caller we're done
			dispatchEvent(new Event(Event.COMPLETE));
		}
		// Add failed
		else {

			var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
			error(err);

			// Tell caller we failed
			dispatchEvent(new Event(Event.CANCEL));
		}

		startShell(false);
	}

}