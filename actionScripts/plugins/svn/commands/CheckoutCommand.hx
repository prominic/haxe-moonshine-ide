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

import flash.desktop.NativeApplication;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import actionScripts.events.ProjectEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.valueObjects.ProjectVO;
import flashx.textLayout.TlfInternal;
class CheckoutCommand extends SVNCommandBase {

	private var cmdFile:File;

	private var isEventReported:Bool;

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function checkout(event:SVNEvent, isTrustServerCertificateSVN:Bool):Void {
		if (runningForFile) {
			error('Currently running, try again later.');
			return;
		}

		notice('Trying to check out %s. May take a while.', event.url);

		isEventReported = false;
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;
		//customInfo.executable = cmdFile;

		// http://stackoverflow.com/questions/1625406/using-tortoisesvn-via-the-command-line
		var args:Array<String> = new Array<String>();
		args.push('checkout');
		if (event.authObject != null) {
			args.push('--username');
			args.push(event.authObject.username);
			args.push('--password');
			args.push(event.authObject.password);
		}
		args.push(event.url);
		args.push('--non-interactive');
		if (isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;
		customInfo.workingDirectory = event.file;

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'SVN Process ', false));

		startShell(true);
		customProcess.start(customInfo);

		var tmpSplit:Array<Dynamic> = event.url.split('/');
		var tmpLastFolderName:String = tmpSplit[tmpSplit.length - 1];
		var newFilePath:String = !(NativeApplication.supportsSystemTrayIcon) ? event.file.nativePath + '/' + tmpLastFolderName : event.file.nativePath + '\\' + tmpLastFolderName;

		runningForFile = new File(newFilePath);
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
			runningForFile = null;
		}
	}

	private function svnError(event:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		var match:Array<Dynamic> = data.toLowerCase().match(new as3hx.Compat.Regex('Error validating server certificate for', ''));
		if (match != null) {
			serverCertificatePrompt(data);
			return;
		}

		error('%s', data);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
		startShell(false);
	}

	private function svnOutput(event:ProgressEvent):Void {
		if (!isEventReported) {
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_RESULT, null));
			isEventReported = true;
		}

		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		notice('%s', data);
	}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) {
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, new File(runningForFile.nativePath)));
		} else { // Checkout failed

		}

		/*runningForFile = null;
		customProcess = null;*/
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		startShell(false);
	}

}