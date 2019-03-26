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
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.plugins.svn.provider.SVNStatus;
import actionScripts.valueObjects.GenericSelectableObject;
import components.popup.GitCommitSelectionPopup;
class CommitCommand extends SVNCommandBase {

	private var message:String;

	// Files we need to add before commiting
	private var toAdd:Array<Dynamic>;

	private var affectedFiles:ArrayCollection;

	private var isTrustServerCertificateSVN:Bool;

	public var status:Dynamic;

	private var svnCommitWindow:GitCommitSelectionPopup;

	public function new(executable:File, root:File, status:Dynamic) {
		this.status = status;
		super(executable, root);
	}

	public function commit(file:FileLocation, message:String = null, user:String = null, password:String = null, commitInfo:Dynamic = null, isTrustServerCertificateSVN:Bool = false):Void {
		this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
		if (user != null && password != null) {
			doCommit(user, password, commitInfo);
			return;
		}

		if (runningForFile) {
			error('Currently running, try again later.');
			return;
		}

		runningForFile = try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null;
		this.message = message;

		// Update status, in case files were added
		var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
		statusCommand.addEventListener(Event.COMPLETE, handleCommitStatusUpdateComplete);
		statusCommand.addEventListener(Event.CANCEL, handleCommitStatusUpdateCancel);
		statusCommand.update(try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null, this.isTrustServerCertificateSVN);

		print('Updating status before commit');
	}

	private function handleCommitStatusUpdateComplete(event:Event):Void
	// Ok, now we know the status is fresh.
	 {

		var topPath:String = runningForFile.nativePath;
		var topPathLength:Int = topPath.length;
		affectedFiles = new ArrayCollection();
		for (p in Reflect.fields(status)) {
			var st:SVNStatus = Reflect.field(status, p);

			if (st.canBeCommited) {
				var relativePath:String = p.substr(topPathLength + 1);
				affectedFiles.addItem(new GenericSelectableObject(false, {
							path: p,
							status: getFileStatus(st)
						}));
			}
		}

		promptForCommitMessage();

		/*
		* @local
		*/
		function getFileStatus(value:SVNStatus):String {
			if (value.status == 'deleted') {
				return GitProcessManager.GIT_STATUS_FILE_DELETED;
			} else if (value.status == 'unversioned') {
				return GitProcessManager.GIT_STATUS_FILE_NEW;
			}
			return GitProcessManager.GIT_STATUS_FILE_MODIFIED;
		};
	}

	private function handleCommitStatusUpdateCancel(event:Event):Void {
		error('Could update status, commit failed.');
	}

	private function promptForCommitMessage():Void {
		if (svnCommitWindow == null) {
			svnCommitWindow = try cast(PopUpManager.createPopUp(try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, GitCommitSelectionPopup, false), GitCommitSelectionPopup) catch (e:Dynamic) null;
			svnCommitWindow.title = 'Commit';
			svnCommitWindow.commitDiffCollection = affectedFiles;
			svnCommitWindow.windowType = GitCommitSelectionPopup.TYPE_SVN;
			svnCommitWindow.addEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
			PopUpManager.centerPopUp(svnCommitWindow);
		} else {
			PopUpManager.bringToFront(svnCommitWindow);
		}
	}

	private function onSVNCommitWindowClosed(event:CloseEvent):Void {
		if (svnCommitWindow.isSubmit) {
			this.message = svnCommitWindow.commitMessage;
			initiateProcess();
		}

		svnCommitWindow.removeEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
		PopUpManager.removePopUp(svnCommitWindow);
		svnCommitWindow = null;
	}

	private function initiateProcess():Void
	// We'll need to add some files
	 {

		toAdd = [];
		for (wrap /* AS3HX WARNING could not determine type for var: wrap exp: EIdent(affectedFiles) type: ArrayCollection */ in affectedFiles) {
			if (wrap.isSelected && wrap.data.status == GitProcessManager.GIT_STATUS_FILE_NEW) {
				toAdd.push(wrap.data.path);
			}
		}

		addFiles();
	}

	// Start adding files
	private function addFiles(event:Event = null):Void {
		if (toAdd.length == 0) {
			doCommit();
		} else {
			var file:String = toAdd.pop();
			var addCommand:AddCommand = new AddCommand(executable, runningForFile);
			addCommand.addEventListener(Event.COMPLETE, addFiles);
			addCommand.addEventListener(Event.CANCEL, addFilesCancel);
			addCommand.add(file);
		}
	}

	private function addFilesCancel(event:Event):Void {
		error('Couldn\t add file, commit failed.');
		toAdd = null;
	}

	private function doCommit(user:String = null, password:String = null, commitInfo:Dynamic = null):Void
	// TODO: Check for empty commits, since svn commit will recurse-commit everything
	 {

		if (commitInfo != null) {
			affectedFiles = (affectedFiles != null) ? affectedFiles : commitInfo.files;
			this.message ||= commitInfo.message;
			runningForFile ||= commitInfo.runningForFile;
		}

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		args.push('commit');
		var argFiles:Array<String> = new Array<String>();
		for (wrap /* AS3HX WARNING could not determine type for var: wrap exp: EIdent(affectedFiles) type: ArrayCollection */ in affectedFiles) {
			if (wrap.isSelected) {
				argFiles.push(wrap.data.path);
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

		customInfo.workingDirectory = runningForFile;
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

	private function svnOutput(event:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		if (data == '.') {
			return;
		}
		notice('%s', data);
	}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0) { // Success

		}
		// Commit failed
		else {

			var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
			var match:Array<Dynamic> = err.match(new as3hx.Compat.Regex('Authentication failed', ''));
			if (match != null) {
				dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_AUTH_REQUIRED, runningForFile, null, null, null, 'commit', affectedFiles, this.message, runningForFile));
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

}