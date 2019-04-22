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
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.git.GitProcessManager;
import actionScripts.plugins.svn.provider.SVNStatus;
import actionScripts.plugins.versionControl.VersionControlUtils;
import actionScripts.valueObjects.GenericSelectableObject;
import actionScripts.valueObjects.VersionControlTypes;
import components.popup.GitCommitSelectionPopup;

class CommitCommand extends SVNCommandBase {

	private var message:String;
	// Files we need to add before commiting
	private var toAdd:Array<Dynamic>;
	private var affectedFiles:ArrayCollection;

	public var status:Dynamic;

	private var svnCommitWindow:GitCommitSelectionPopup;
	private var commitInfo:Dynamic;

	public function new(executable:File, root:File, status:Dynamic) {
		this.status = status;
		super(executable, root);
	}

	public function commit(file:FileLocation, message:String = null, user:String = null, password:String = null, commitInfo:Dynamic = null, isTrustServerCertificateSVN:Bool = false):Void {
		this.root = AS3.as(file.fileBridge.getFile, File);
		this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
		this.commitInfo = commitInfo;
		this.message = message;

		if (user != null && password != null) {
			doCommit(user, password, commitInfo);
			return;
		}

		// Update status, in case files were added
		var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
		statusCommand.addEventListener(Event.COMPLETE, handleCommitStatusUpdateComplete);
		statusCommand.addEventListener(Event.CANCEL, handleCommitStatusUpdateCancel);
		statusCommand.update(this.root, this.isTrustServerCertificateSVN);

		print('Updating status before commit');
	}

	private function handleCommitStatusUpdateComplete(event:Event):Void {
		function getFileStatus(value:SVNStatus):String {
			if (value.status == 'deleted') {
				return GitProcessManager.GIT_STATUS_FILE_DELETED;
			} else if (value.status == 'unversioned') {
				return GitProcessManager.GIT_STATUS_FILE_NEW;
			}
			return GitProcessManager.GIT_STATUS_FILE_MODIFIED;
		};
		// Ok, now we know the status is fresh.
		var topPath:String = Std.string(this.root.nativePath);
		var topPathLength:Int = topPath.length;
		affectedFiles = new ArrayCollection();
		for (p in Reflect.fields(status)) {
			var st:SVNStatus = Reflect.field(status, p);

			if (st.canBeCommited) {
				var relativePath:String = p.substr(topPathLength + 1);
				affectedFiles.addItem(new GenericSelectableObject(false, {
							'path': p,
							'status': getFileStatus(st)
						}));
				//var w:SVNFileWrapper = new SVNFileWrapper(new File(p), st, relativePath);
				//affectedFiles.push(w);
			}
		} /*
		* @local
		*/

		promptForCommitMessage();
	}

	private function handleCommitStatusUpdateCancel(event:Event):Void {
		error('Could update status, commit failed.');
	}

	private function promptForCommitMessage():Void {
		if (svnCommitWindow == null) {
			svnCommitWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitCommitSelectionPopup, false), GitCommitSelectionPopup);
			svnCommitWindow.title = 'Commit';
			svnCommitWindow.commitDiffCollection = affectedFiles;
			svnCommitWindow.windowType = Std.string(VersionControlTypes.SVN);
			svnCommitWindow.addEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
			PopUpManager.centerPopUp(svnCommitWindow);
			svnCommitWindow.isReadyToUse = true;
		} else {
			PopUpManager.bringToFront(svnCommitWindow);
		}

		/*var editor:CommitMessageEditor = new CommitMessageEditor();
		//editor.files = affectedFiles;
		dispatcher.dispatchEvent(
			new AddTabEvent(editor)
		);*/

		//editor.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleCommitEditorClose);
	}

	private function onSVNCommitWindowClosed(event:CloseEvent):Void {
		if (svnCommitWindow.isSubmit) {
			this.message = svnCommitWindow.commitMessage;

			// get repository infor to check authentication (if requires
			// and if exists) from repositoryItemVo
			this.getRepositoryInfo();
		}

		svnCommitWindow.removeEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
		PopUpManager.removePopUp(svnCommitWindow);
		svnCommitWindow = null;
	}

	override private function handleInfoUpdateComplete(event:Event):Void {
		super.handleInfoUpdateComplete(event);
		if (this.repositoryItem != null) {
			this.isTrustServerCertificateSVN = AS3.as(this.repositoryItem.isTrustCertificate, Bool);
		}
		initiateProcess();
	}

	private function releaseListenersFromInfoCommand(event:Event):Void {
		event.target.removeEventListener(Event.COMPLETE, handleInfoUpdateComplete);
		event.target.removeEventListener(Event.CANCEL, handleInfoUpdateCancel);
	}

	private function initiateProcess():Void {
		// We'll need to add some files
		toAdd = [];
		for (wrap in affectedFiles) {
			if (AS3.as(Reflect.field(wrap, 'isSelected'), Bool) && Reflect.field(Reflect.field(wrap, 'data'), 'status') == GitProcessManager.GIT_STATUS_FILE_NEW) {
				toAdd.push(Reflect.field(Reflect.field(wrap, 'data'), 'path'));
			}
		}

		addFiles();
	}

	// Start adding files
	private function addFiles(event:Event = null):Void {
		if (toAdd.length == 0) {
			if (repositoryItem != null && AS3.as(repositoryItem.userName, Bool) && AS3.as(repositoryItem.userPassword, Bool)) {
				doCommit(Std.string(repositoryItem.userName), Std.string(repositoryItem.userPassword), this.commitInfo);
			} else {
				doCommit(null, null, this.commitInfo);
			}
		} else {
			var file:String = Std.string(toAdd.pop());
			var addCommand:AddCommand = new AddCommand(executable, this.root);
			addCommand.addEventListener(Event.COMPLETE, addFiles);
			addCommand.addEventListener(Event.CANCEL, addFilesCancel);
			addCommand.add(file);
		}
	}

	private function addFilesCancel(event:Event):Void {
		error('Couldn\'t add file, commit failed.');
		toAdd = null;
	}

	private function doCommit(user:String = null, password:String = null, commitInfo:Dynamic = null):Void {
		// TODO: Check for empty commits, since svn commit will recurse-commit everything
		if (AS3.as(commitInfo, Bool)) {
			affectedFiles = (affectedFiles != null) ? affectedFiles : Reflect.field(commitInfo, 'files');
			this.message = (this.message != null) ? this.message : AS3.string(Reflect.field(commitInfo, 'message'));
			this.root = (this.root != null) ? this.root : Reflect.field(commitInfo, 'runningForFile');
		}

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		args.push('commit');
		var argFiles:Array<String> = new Array<String>();
		for (wrap in affectedFiles) {
			if (AS3.as(Reflect.field(wrap, 'isSelected'), Bool)) {
				argFiles.push(Reflect.field(Reflect.field(wrap, 'data'), 'path'));
			}
		}

		if (argFiles.length == 0) {
			error('No files to commit.');
			return;
		}

		args = args.concat(argFiles);
		args.push('--message');
		args.push(this.message);
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

		customInfo.workingDirectory = this.root;
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'SVN Process ', false));

		startShell(true);
		customProcess.start(customInfo);

		print('Starting commit');
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

	private function svnOutput(event:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		if (data == '.') {
			return;
		}
		notice('%s', data);
	}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) {
			// Success
		} else {
			// Commit failed
			var err:String = Std.string(customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable));
			if (VersionControlUtils.hasAuthenticationFailError(err)) {
				openAuthentication();
			} else {
				error(err);
			}
		}

		// Update status (don't care if it fails or not, just try it)
		/*var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, runningForFile, status);
		statusCommand.update(runningForFile);

		// Show changes in project view
		dispatcher.dispatchEvent(
			new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
		);*/

		startShell(false);
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	override private function onAuthenticationSuccess(username:String, password:String):Void {
		this.doCommit(username, password, this.commitInfo);
	}

}