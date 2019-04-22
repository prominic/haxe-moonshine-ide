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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filesystem.File;
import flash.utils.IDataOutput;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.plugins.core.ExternalCommandBase;
import actionScripts.plugins.svn.view.ServerCertificateDialog;
import actionScripts.plugins.versionControl.VersionControlUtils;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;
import components.popup.GitAuthenticationPopup;

class SVNCommandBase extends ExternalCommandBase {

	override private function get_name():String {
		return 'Subversion Plugin';
	}

	private var repositoryItem:RepositoryItemVO;
	private var isTrustServerCertificateSVN:Bool = false;

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	// Only allow one operation at a time
	private var runningForFile:File;

	/*
		Handle SVN asking about Server Certificate approval/rejection
	*/
	private function serverCertificatePrompt(data:String):Void {
		// Strip stuff we don't want
		data = StringTools.replace(data, '(R)eject, accept (t)emporarily or accept (p)ermanently?', '');

		var d:ServerCertificateDialog = new ServerCertificateDialog();
		d.prompt = data;
		d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
		d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
		d.addEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);

		PopUpManager.addPopUp(d, AS3.as(FlexGlobals.topLevelApplication, DisplayObject));
		PopUpManager.centerPopUp(d);
	}

	// (R)eject, accept (t)emporarily or accept (p)ermanently?
	private function acceptPerm(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('p\n');
		removeCertDialog(event);
	}

	private function acceptTemp(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('t\n');
		removeCertDialog(event);
	}

	private function dontAccept(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('r\n');
		removeCertDialog(event);
	}

	private function removeCertDialog(event:Event):Void {
		var d:ServerCertificateDialog = ServerCertificateDialog(event.target);
		PopUpManager.removePopUp(d);

		d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
		d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
		d.removeEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);
	}

	private function openAuthentication():Void {
		var authWindow:GitAuthenticationPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitAuthenticationPopup, true), GitAuthenticationPopup);
		authWindow.title = 'Needs Authentication';
		authWindow.type = Std.string(VersionControlTypes.SVN);

		if (repositoryItem != null) {
			var tmpTopLevel:RepositoryItemVO = VersionControlUtils.getRepositoryItemByUdid(Std.string(repositoryItem.udid));
			if (tmpTopLevel != null && AS3.as(tmpTopLevel.userName, Bool)) {
				authWindow.userName = Std.string(tmpTopLevel.userName);
			}
		}

		authWindow.addEventListener(CloseEvent.CLOSE, onAuthWindowClosed);
		authWindow.addEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
		PopUpManager.centerPopUp(authWindow);
	}

	private function onAuthWindowClosed(event:CloseEvent):Void {
		var target:GitAuthenticationPopup = AS3.as(event.target, GitAuthenticationPopup);
		if (!AS3.as(target.userObject, Bool)) {
			onCancelAuthentication();
		}

		target.removeEventListener(CloseEvent.CLOSE, onAuthWindowClosed);
		target.removeEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
		PopUpManager.removePopUp(AS3.as(target, IFlexDisplayObject));
	}

	private function onAuthSubmitted(event:Event):Void {
		var target:GitAuthenticationPopup = AS3.as(event.target, GitAuthenticationPopup);
		if (AS3.as(target.userObject, Bool)) {
			if (AS3.as(Reflect.field(target.userObject, 'save'), Bool) && repositoryItem != null) {
				var tmpTopLevel:RepositoryItemVO = VersionControlUtils.getRepositoryItemByUdid(Std.string(repositoryItem.udid));
				tmpTopLevel.userName = Reflect.field(target.userObject, 'userName');
				tmpTopLevel.userPassword = Reflect.field(target.userObject, 'password');
				SharedObjectUtil.saveRepositoriesToSO(VersionControlUtils.REPOSITORIES);
			}

			onAuthenticationSuccess(AS3.string(Reflect.field(target.userObject, 'userName')), AS3.string(Reflect.field(target.userObject, 'password')));
		}
	}

	private function onAuthenticationSuccess(username:String, password:String):Void {}

	private function onCancelAuthentication():Void {}

	private function getRepositoryInfo():Void {
		var infoCommand:InfoCommand = new InfoCommand(executable, root);
		infoCommand.addEventListener(Event.COMPLETE, handleInfoUpdateComplete);
		infoCommand.addEventListener(Event.CANCEL, handleInfoUpdateCancel);
		infoCommand.request(this.root, this.isTrustServerCertificateSVN);
	}

	private function handleInfoUpdateComplete(event:Event):Void {
		releaseListenersFromInfoCommand(event);

		var infoLines:Array<Dynamic> = (AS3.as(event.target, InfoCommand)).infoLines;
		var searchCriteria:String = 'Repository Root: ';
		for (line_ in infoLines) {
			var line:String = cast line_;
			if (line.indexOf(searchCriteria) != -1) {
				searchCriteria = Std.string(line.substr(searchCriteria.length, line.length));
				// find out relevant repository item associate to the url
				for (repo in VersionControlUtils.REPOSITORIES) {
					if (Reflect.field(repo, 'url') == searchCriteria) {
						this.repositoryItem = repo;
						break;
					}
				}
				break;
			}
		}
	}

	private function handleInfoUpdateCancel(event:Event):Void {
		releaseListenersFromInfoCommand(event);
	}

	private function releaseListenersFromInfoCommand(event:Event):Void {
		event.target.removeEventListener(Event.COMPLETE, handleInfoUpdateComplete);
		event.target.removeEventListener(Event.CANCEL, handleInfoUpdateCancel);
	}

}