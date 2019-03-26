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
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.svn.event.SVNEvent;
class UpdateCommand extends SVNCommandBase {

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function update(file:FileLocation, user:String = null, password:String = null, isTrustServerCertificateSVN:Bool = false):Void {
		if (customProcess && customProcess.running) {
			return;
		}

		runningForFile = try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null;

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		args.push('update');
		if (user != null && password != null) {
			args.push('--username');
			args.push(user);
			args.push('--password');
			args.push(password);
		}
		args.push('--non-interactive');
		if (isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;
		// We give the file as target, so go one directory up
		customInfo.workingDirectory = runningForFile;

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'SVN Process ', false));

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
		var str:String = customProcess.standardError.readUTFBytes(customProcess.standardOutput.bytesAvailable);
		error(str);

		//startShell(false);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0)
		// Update succeded
		{

			var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);

			notice(str);

			// Show changes in project view
			dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);
		}
		// Refresh failed
		else {

			var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
			var match:Array<Dynamic> = err.match(new as3hx.Compat.Regex('Authentication failed', ''));
			if (match != null) {
				dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_AUTH_REQUIRED, runningForFile, null, null, null, 'update'));
			} else {
				error(err);
			}
		}

		startShell(false);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

}