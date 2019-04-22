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
import actionScripts.valueObjects.ConstantsCoreVO;

class InfoCommand extends SVNCommandBase {

	public var infoLines:Array<Dynamic>;

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	// Modifies status object. obj[nativePath] = SVNStatus
	public function request(file:File, isTrustServerCertificateSVN:Bool):Void {
		if (runningForFile != null) {
			error('Currently running, try again later.');
			return;
		}

		infoLines = null;
		runningForFile = file;

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		/*var target:String = file.getRelativePath(root, false);
		// If we're refreshing the root we give roots name
		if (!target) target = file.name; */
		args.push('info');
		/*args.push(file.name);*/
		args.push('--non-interactive');
		if (isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;
		// We give the file as target, so go one directory up
		customInfo.workingDirectory = file;

		customProcess = new NativeProcess();
		customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
		customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
		customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
		customProcess.start(customInfo);
	}

	private function svnError(event:ProgressEvent):Void {}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) {
			// Refresh succeded
			var str:String = Std.string(customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable));
			infoLines = cast str.split((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '\n' : '\r\n');

			dispatchEvent(new Event(Event.COMPLETE));
		} else {
			// Refresh failed
			var err:String = Std.string(customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable));
			error(err);

			dispatchEvent(new Event(Event.CANCEL));
		}

		runningForFile = null;
		customProcess = null;
	}

}