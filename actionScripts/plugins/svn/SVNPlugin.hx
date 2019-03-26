////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.svn;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filesystem.File;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SaveFileEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.event.SetSettingsEvent;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugins.git.GitHubPlugin;
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.plugins.svn.provider.SubversionProvider;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import components.popup.GitAuthenticationPopup;
import components.popup.SourceControlCheckout;
class SVNPlugin extends PluginBase implements ISettingsProvider {

	public var svnBinaryPath(get, set):String;

	public static inline var CHECKOUT_REQUEST:String = 'checkoutRequestEvent';

	public static inline var COMMIT_REQUEST:String = 'svnCommitRequest';

	public static inline var UPDATE_REQUEST:String = 'svnUpdateRequest';

	public static inline var SVN_TEST_COMPLETED:String = 'svnTestCompleted';

	override private function get_name():String {
		return 'Subversion';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return ResourceManager.getInstance().getString('resources', 'plugin.desc.subversion');
	}

	private var _svnBinaryPath:String;

	private function get_svnBinaryPath():String {
		return _svnBinaryPath;
	}

	private function set_svnBinaryPath(value:String):String {
		model.svnPath = _svnBinaryPath = value;
		return value;
	}

	private var checkoutWindow:SourceControlCheckout;

	private var gitAuthWindow:GitAuthenticationPopup;

	private var failedMethodObjectBeforeAuth:Array<Dynamic>;

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		dispatcher.addEventListener(COMMIT_REQUEST, handleCommitRequest);
		dispatcher.addEventListener(UPDATE_REQUEST, handleUpdateRequest);
		dispatcher.addEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
		dispatcher.addEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
		dispatcher.addEventListener(SVNEvent.SVN_AUTH_REQUIRED, onSVNAuthRequires);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
		dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		dispatcher.removeEventListener(COMMIT_REQUEST, handleCommitRequest);
		dispatcher.removeEventListener(UPDATE_REQUEST, handleUpdateRequest);
		dispatcher.removeEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
		dispatcher.removeEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
		dispatcher.removeEventListener(SVNEvent.SVN_AUTH_REQUIRED, onSVNAuthRequires);
	}

	override public function resetSettings():Void {
		svnBinaryPath = null;
		ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = false;
		dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));

		for (i /* AS3HX WARNING could not determine type for var: i exp: EField(EIdent(model),projects) type: null */ in model.projects) {
			(try cast(i, AS3ProjectVO) catch (e:Dynamic) null).menuType = (try cast(i, AS3ProjectVO) catch (e:Dynamic) null).menuType.replace(',' + ProjectMenuTypes.SVN_PROJECT, '');
		}

		// following will enable/disable Moonshine top menus based on project
		if (model.activeProject) {
			dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
		}
	}

	public function getSettingsList():Array<ISetting> {
		var binaryPath:PathSetting = new PathSetting(this, 'svnBinaryPath', 'SVN Binary', false);
		binaryPath.setMessage('SVN binary needs to be command-line compliant', AbstractSetting.MESSAGE_IMPORTANT);

		return [
				binaryPath
		];
	}

	/*public function getMenu():MenuItem
	{
	var EditMenu:MenuItem = new MenuItem('Subversion');
	EditMenu.parents = ["Subversion"];
	EditMenu.items = new Vector.<MenuItem>();
	EditMenu.items.push(new MenuItem("Checkout", null, [], CHECKOUT_REQUEST));
	return EditMenu;

	}*/
	private function handleFileSave(event:SaveFileEvent):Void {}

	private function onOSXodePermission(event:SVNEvent):Void {
		svnBinaryPath = event.url;

		// save the settings
		var thisSettings:Array<ISetting> = getSettingsList();
		var pathSettingToDefaultSDK:PathSetting = try cast(thisSettings[0], PathSetting) catch (e:Dynamic) null;
		dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, 'actionScripts.plugins.svn::SVNPlugin', thisSettings));

		// if an opened project lets test it if Git repository
		if (model.activeProject) {
			handleProjectOpen(new ProjectEvent(ProjectEvent.ADD_PROJECT, model.activeProject));
		}
	}

	private function handleProjectOpen(event:ProjectEvent):Void
	// Check if project is versioned with SVN
	 {

		if (isVersioned(event.project.folderLocation) == false) {
			return;
		}

		// Check if we have a SVN binary
		if (svnBinaryPath == null || svnBinaryPath == '') {
			return;
		}

		// Create new provider
		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.root = try cast(event.project.folderLocation.fileBridge.getFile, File) catch (e:Dynamic) null;
	}

	private function handleCheckSVNRepository(event:ProjectEvent):Void
	// Check if we have a SVN binary
	 {

		if (svnBinaryPath == null || svnBinaryPath == '') {
			return;
		}

		// don't go for a check if already decided as svn project
		if ((try cast(event.project, AS3ProjectVO) catch (e:Dynamic) null).menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) == -1) {
			if (event.project.folderLocation.fileBridge.resolvePath('.svn/wc.db').fileBridge.exists) {
				(try cast(event.project, AS3ProjectVO) catch (e:Dynamic) null).menuType += ',' + ProjectMenuTypes.SVN_PROJECT;
			}
		}
	}

	private function handleCheckoutRequest(event:Event):Void
	// Check if we have a SVN binary
	 {

		// for Windows only
		// @note SK
		// Need to check OSX svn existence someway
		if (svnBinaryPath == null || svnBinaryPath == '') {
			if (ConstantsCoreVO.IS_MACOS) {
				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
			} else {
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.svn::SVNPlugin'));
			}
			return;
		}

		if (checkoutWindow == null) {
			checkoutWindow = try cast(PopUpManager.createPopUp(try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, SourceControlCheckout, false), SourceControlCheckout) catch (e:Dynamic) null;
			checkoutWindow.title = 'Checkout Repository';
			checkoutWindow.type = SourceControlCheckout.TYPE_SVN;
			checkoutWindow.addEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			checkoutWindow.addEventListener(SVNEvent.EVENT_CHECKOUT, onCheckoutWindowSubmitted);

			dispatcher.addEventListener(SVNEvent.SVN_ERROR, onCheckoutOutputEvent);
			dispatcher.addEventListener(SVNEvent.SVN_RESULT, onCheckoutOutputEvent);

			PopUpManager.centerPopUp(checkoutWindow);
		} else {
			PopUpManager.bringToFront(checkoutWindow);
		}
	}

	private function onCheckoutWindowSubmitted(event:SVNEvent):Void {
		var submitObject:Dynamic = checkoutWindow.submitObject;
		if (submitObject != null)
		//git: submitObject.url, submitObject.target
		{

			//svn: submitObject.url, submitObject.target, submitObject.user, submitObject.password
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.checkout(new SVNEvent(SVNEvent.EVENT_CHECKOUT, new File(submitObject.target), submitObject.url, null, (submitObject.user) ? {
						username: submitObject.user,
						password: submitObject.password
					} : null), submitObject.trustCertificate);
		}
	}

	private function onCheckoutWindowClosed(event:CloseEvent):Void {
		checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
		checkoutWindow.removeEventListener(SVNEvent.EVENT_CHECKOUT, onCheckoutWindowSubmitted);
		dispatcher.removeEventListener(SVNEvent.SVN_ERROR, onCheckoutOutputEvent);
		dispatcher.removeEventListener(SVNEvent.SVN_RESULT, onCheckoutOutputEvent);

		PopUpManager.removePopUp(checkoutWindow);
		checkoutWindow = null;
	}

	private function onCheckoutOutputEvent(event:SVNEvent):Void {
		if (event.type == SVNEvent.SVN_ERROR) {
			checkoutWindow.notifySVNCheckoutError();
		} else {
			checkoutWindow.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
	}

	private function handleCommitRequest(event:Event, user:String = null, password:String = null, commitInfo:Dynamic = null):Void {
		if (!model.activeProject) {
			return;
		}

		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.commit(model.activeProject.folderLocation, null, user, password, commitInfo, (try cast(model.activeProject, AS3ProjectVO) catch (e:Dynamic) null).isTrustServerCertificateSVN);
	}

	private function handleUpdateRequest(event:Event, user:String = null, password:String = null):Void {
		if (!model.activeProject) {
			return;
		}

		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.update(model.activeProject.folderLocation, user, password, (try cast(model.activeProject, AS3ProjectVO) catch (e:Dynamic) null).isTrustServerCertificateSVN);
	}

	private function isVersioned(folder:FileLocation):Bool {
		if (!folder.fileBridge.exists) {
			folder.fileBridge.createDirectory();
		}

		var listing:Array<Dynamic> = folder.fileBridge.getDirectoryListing();
		for (file in listing) {
			if (file.name == '.svn') {
				return true;
			}
		}
		return false;
	}

	private function onSVNAuthRequires(event:SVNEvent):Void {
		failedMethodObjectBeforeAuth = event.extras;
		openAuthentication();
	}

	private function openAuthentication():Void {
		if (gitAuthWindow == null) {
			gitAuthWindow = try cast(PopUpManager.createPopUp(try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, GitAuthenticationPopup, true), GitAuthenticationPopup) catch (e:Dynamic) null;
			gitAuthWindow.title = 'SVN Needs Authentication';
			gitAuthWindow.type = GitAuthenticationPopup.TYPE_SVN;
			gitAuthWindow.addEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			gitAuthWindow.addEventListener(GitAuthenticationPopup.GIT_AUTH_COMPLETED, onAuthSuccessToSVN);
			PopUpManager.centerPopUp(gitAuthWindow);
		}

		/*
		* @local
		*/
		function onGitAuthWindowClosed(event:CloseEvent):Void {
			gitAuthWindow.removeEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			gitAuthWindow.removeEventListener(GitAuthenticationPopup.GIT_AUTH_COMPLETED, onAuthSuccessToSVN);
			PopUpManager.removePopUp(gitAuthWindow);
			gitAuthWindow = null;
		};
	}

	private function onAuthSuccessToSVN(event:Event):Void {
		if (gitAuthWindow.userObject && failedMethodObjectBeforeAuth != null) {
			var _sw0_ = (failedMethodObjectBeforeAuth[0]);
			switch (_sw0_) {
				case 'update':
					handleUpdateRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password);
				case 'commit':
					handleCommitRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password, {
								files: failedMethodObjectBeforeAuth[1],
								message: failedMethodObjectBeforeAuth[2],
								runningForFile: failedMethodObjectBeforeAuth[3]
							});
			}
		}
	}

	public function new() {
		super();
	}

}