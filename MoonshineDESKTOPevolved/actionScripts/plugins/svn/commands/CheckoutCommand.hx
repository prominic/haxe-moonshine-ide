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
import flash.utils.IDataInput;
import actionScripts.events.ProjectEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.plugins.versionControl.VersionControlUtils;
import actionScripts.valueObjects.RepositoryItemVO;

class CheckoutCommand extends SVNCommandBase {

	private var cmdFile:File;
	private var isEventReported:Bool = false;
	private var url:String;
	private var targetFolder:String;

	public function new(executable:File, root:File) {
		super(executable, root);
		//cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
	}

	// url, folder, user, password, istrust
	public function checkout(url:String, rootDirectory:File, targetFolder:String, isTrustServerCertificateSVN:Bool, repository:RepositoryItemVO, userName:String = null, userPassword:String = null):Void {
		this.repositoryItem = repository;
		this.root = rootDirectory;
		this.url = url;
		this.targetFolder = targetFolder;
		this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
		notice('Trying to check out %s. May take a while.', url);

		isEventReported = false;
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;
		//customInfo.executable = cmdFile;

		// http://stackoverflow.com/questions/1625406/using-tortoisesvn-via-the-command-line
		var args:Array<String> = new Array<String>();
		var username:String;
		var password:String;
		args.push('checkout');
		if (repositoryItem != null && AS3.as(repositoryItem.userName, Bool) && AS3.as(repositoryItem.userPassword, Bool)) {
			username = Std.string(repositoryItem.userName);
			password = Std.string(repositoryItem.userPassword);
		} else if (userName != null && userPassword != null) {
			username = userName;
			password = userPassword;
		}
		if (username != null && password != null) {
			args.push('--username');
			args.push(username);
			args.push('--password');
			args.push(password);
		}
		args.push(url);
		args.push(targetFolder);
		args.push('--non-interactive');
		if (isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;
		customInfo.workingDirectory = this.root;

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
			if (customProcess == null) {
				return;
			}
			if (AS3.as(customProcess.running, Bool)) {
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

		var match:Array<Dynamic> = as3hx.Compat.match(data.toLowerCase(), new as3hx.Compat.Regex('Error validating server certificate for', ''));
		if (match != null) {
			//serverCertificatePrompt(data);
			//return;
		}

		if (VersionControlUtils.hasAuthenticationFailError(data)) {
			openAuthentication();
		}

		error('%s', data);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
		startShell(false);
	}

	override private function onAuthenticationSuccess(username:String, password:String):Void {
		this.checkout(this.url, this.root, this.targetFolder, this.isTrustServerCertificateSVN, this.repositoryItem, username, password);
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
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, new File(this.root.nativePath + File.separator + targetFolder)));
			/*var p:ProjectVO = new ProjectVO(new FileLocation(runningForFile.nativePath));
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, p)
			);*/
		} else {
			// Checkout failed
		}

		/*runningForFile = null;
		customProcess = null;*/
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		startShell(false);
	}

}