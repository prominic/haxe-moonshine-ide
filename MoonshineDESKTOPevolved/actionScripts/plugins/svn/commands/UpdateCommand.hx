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
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.versionControl.VersionControlUtils;

class UpdateCommand extends SVNCommandBase {

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function update(file:File, user:String = null, password:String = null, isTrustServerCertificateSVN:Bool = false):Void {
		if (customProcess != null && AS3.as(customProcess.running, Bool)) {
			return;
		}

		this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
		root = file;

		// check repository info first
		this.getRepositoryInfo();
	}

	override private function handleInfoUpdateComplete(event:Event):Void {
		super.handleInfoUpdateComplete(event);
		if (this.repositoryItem != null) {
			this.isTrustServerCertificateSVN = AS3.as(this.repositoryItem.isTrustCertificate, Bool);
		}
		if (this.repositoryItem != null && AS3.as(this.repositoryItem.userName, Bool) && AS3.as(this.repositoryItem.userPassword, Bool)) {
			doUpdate(Std.string(this.repositoryItem.userName), Std.string(this.repositoryItem.userPassword));
		} else {
			doUpdate();
		}
	}

	private function doUpdate(user:String = null, password:String = null):Void {
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
		customInfo.workingDirectory = root;

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
		}
	}

	private function svnError(event:ProgressEvent):Void {
		var str:String = Std.string(customProcess.standardError.readUTFBytes(customProcess.standardOutput.bytesAvailable));
		error(str);

		//startShell(false);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) {
			// Update succeded
			var str:String = Std.string(customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable));

			notice(str);

			// Show changes in project view
			dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(root.nativePath))
			);
		} else {
			// Refresh failed
			var err:String = Std.string(customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable));
			if (VersionControlUtils.hasAuthenticationFailError(err)) {
				openAuthentication();
			} else {
				error(err);
			}
		}

		startShell(false);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	override private function onAuthenticationSuccess(username:String, password:String):Void {
		this.doUpdate(username, password);
	}

}