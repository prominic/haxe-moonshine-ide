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
class DeleteCommand extends SVNCommandBase {

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function remove(file:File):Void {
		if (runningForFile) {
			error('Currently running, try again later.');
			return;
		}

		runningForFile = file;

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		var target:String = file.getRelativePath(root, false);
		// If we're refreshing the root we give roots name
		if (target == null) {
			target = file.name;
		}

		args.push('delete');
		args.push(target);

		customInfo.arguments = args;
		// We give the file as target, so go one directory up
		customInfo.workingDirectory = file.parent;

		customProcess = new NativeProcess();
		customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
		customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
		customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
		customProcess.start(customInfo);
	}

	private function svnError(event:ProgressEvent):Void {}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0)
		// Tell caller we're done
		{

			dispatchEvent(new Event(Event.COMPLETE));
		}
		// Delete failed
		else {

			var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
			error(err);

			// Tell caller we failed
			dispatchEvent(new Event(Event.CANCEL));
		}

		runningForFile = null;
		customProcess = null;
	}

}