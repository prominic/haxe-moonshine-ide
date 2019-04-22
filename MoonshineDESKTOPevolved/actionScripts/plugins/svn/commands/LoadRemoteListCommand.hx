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

import haxe.Constraints.Function;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import actionScripts.events.StatusBarEvent;
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.plugins.versionControl.VersionControlUtils;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.RepositoryItemVO;

class LoadRemoteListCommand extends SVNCommandBase {

	private var cmdFile:File;
	private var isEventReported:Bool = false;
	private var remoteOutput:String;
	private var onCompletion:Function;

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	public function loadList(repository:RepositoryItemVO, completion:Function, userName:String = null, userPassword:String = null):Void {
		onCompletion = null;
		remoteOutput = null;

		onCompletion = cast completion;
		this.repositoryItem = repository;
		this.isTrustServerCertificateSVN = AS3.as(this.repositoryItem.isTrustCertificate, Bool);
		notice('Remote data requested. This may take a while.', this.repositoryItem.url);

		isEventReported = false;
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();
		var username:String;
		var password:String;
		args.push('ls');
		args.push('--depth');
		args.push('immediates');
		if (this.repositoryItem != null && AS3.as(this.repositoryItem.userName, Bool) && AS3.as(this.repositoryItem.userPassword, Bool)) {
			username = Std.string(this.repositoryItem.userName);
			password = Std.string(this.repositoryItem.userPassword);
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
		args.push(this.repositoryItem.url);
		args.push('--non-interactive');
		if (this.isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;

		startShell(true);
		customProcess.start(customInfo);
	}

	override private function onCancelAuthentication():Void {
		// notify to the caller
		if (onCompletion != null) {
			onCompletion(this.repositoryItem, false);
			onCompletion = null;
		}
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
		var output:IDataInput = customProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		var isAuthError:Bool;

		/*var match:Array = data.toLowerCase().match(/error validating server certificate for/);
		if (!match) match = data.toLowerCase().match(/issuer is not trusted/);
		if (match)
		{
			//serverCertificatePrompt(data);
		}*/

		error('%s', data);
		startShell(false);

		if (VersionControlUtils.hasAuthenticationFailError(data)) {
			askOrReconnectWithAuthentication();
			isAuthError = true;
		}

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
		if (!isAuthError) {
			onCancelAuthentication();
		}
	}

	private function svnOutput(event:ProgressEvent):Void {
		if (!isEventReported) {
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_RESULT, null));
			isEventReported = true;
		}

		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		if (remoteOutput == null) {
			remoteOutput = data;
		} else {
			remoteOutput += data;
		}
	}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) {
			parseRemoteOutput();
		}

		startShell(false);
	}

	private function parseRemoteOutput():Void {
		if (remoteOutput != null) {
			var lines:Array<String> = remoteOutput.split((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '\n' : '\r\n');
			var tmpRepoItem:RepositoryItemVO;
			for (line in lines) {
				if (line != '') {
					tmpRepoItem = new RepositoryItemVO();
					if (line.charAt(line.length - 1) == '/') {
						// consider a folder
						tmpRepoItem.children = [];
						line = StringTools.replace(line, '/', '');
						tmpRepoItem.url = this.repositoryItem.url + '/' + line;
					}

					tmpRepoItem.label = line;

					// we also want to keep few information from
					// top level for later retreival
					tmpRepoItem.isRequireAuthentication = this.repositoryItem.isRequireAuthentication;
					tmpRepoItem.isTrustCertificate = this.repositoryItem.isTrustCertificate;
					tmpRepoItem.udid = this.repositoryItem.udid;

					this.repositoryItem.children.push(tmpRepoItem);
				}
			}
		}

		// notify to the caller
		if (onCompletion != null) {
			onCompletion(this.repositoryItem, true);
			onCompletion = null;
		}
	}

	private function askOrReconnectWithAuthentication():Void {
		var tmpTopLevel:RepositoryItemVO = VersionControlUtils.getRepositoryItemByUdid(Std.string(this.repositoryItem.udid));
		if (tmpTopLevel != null && AS3.as(tmpTopLevel.userName, Bool) && AS3.as(tmpTopLevel.userPassword, Bool)) {
			// in case user choose to save auth for the Moonshine session
			onAuthenticationSuccess(Std.string(tmpTopLevel.userName), Std.string(tmpTopLevel.userPassword));
		}// in case we requires to prompt to auth
		else {
			// in case we requires to prompt to auth
			openAuthentication();
		}
	}

	override private function onAuthenticationSuccess(username:String, password:String):Void {
		this.loadList(this.repositoryItem, cast onCompletion, username, password);
		notice('Trying to authenticate with temporary saved information');
	}

}