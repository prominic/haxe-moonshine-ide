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
import actionScripts.plugins.versionControl.event.VersionControlEvent;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.PathSetupHelperUtil;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;
import components.popup.SourceControlCheckout;

class SVNPlugin extends PluginBase implements ISettingsProvider {

	public static inline var CHECKOUT_REQUEST:String = 'checkoutRequestEvent';
	public static inline var COMMIT_REQUEST:String = 'svnCommitRequest';
	public static inline var UPDATE_REQUEST:String = 'svnUpdateRequest';
	public static inline var SVN_TEST_COMPLETED:String = 'svnTestCompleted';

	override private function get_name():String {
		return 'Subversion';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return Std.string(ResourceManager.getInstance().getString('resources', 'plugin.desc.subversion'));
	}

	private var _svnBinaryPath:String;

	public var svnBinaryPath(get, set):String;
	private function get_svnBinaryPath():String {
		return _svnBinaryPath;
	}

	private function set_svnBinaryPath(value:String):String {
		if (_svnBinaryPath != value) {
			model.svnPath = _svnBinaryPath = value;
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL)));
			if (value != '') {
				checkOpenedProjectsIfVersioned();
			} else {
				removeIfAlreadyVersioned();
				PathSetupHelperUtil.updateSVNPath(null);
			}
		}
		return value;
	}

	private var checkoutWindow:SourceControlCheckout;
	private var failedMethodObjectBeforeAuth:Array<Dynamic>;

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		dispatcher.addEventListener(COMMIT_REQUEST, handleCommitRequest);
		dispatcher.addEventListener(UPDATE_REQUEST, handleUpdateRequest);
		dispatcher.addEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
		dispatcher.addEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
		dispatcher.addEventListener(VersionControlEvent.LOAD_REMOTE_SVN_LIST, onLoadRemoteSVNList);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		dispatcher.removeEventListener(COMMIT_REQUEST, handleCommitRequest);
		dispatcher.removeEventListener(UPDATE_REQUEST, handleUpdateRequest);
		dispatcher.removeEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
		dispatcher.removeEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
		dispatcher.removeEventListener(VersionControlEvent.LOAD_REMOTE_SVN_LIST, onLoadRemoteSVNList);
	}

	override public function resetSettings():Void {
		svnBinaryPath = null;
		ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = false;
		dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL)));

		removeIfAlreadyVersioned();
	}

	public function getSettingsList():Array<ISetting> {
		var binaryPath:PathSetting = new PathSetting(this, 'svnBinaryPath', 'SVN Binary', false);
		var svnMessage:String = 'SVN binary needs to be command-line compliant';
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			svnMessage += '\nFor most users, it will be easier to set this with "Subversion > Grant Permission"';
		}

		binaryPath.setMessage(svnMessage, AbstractSetting.MESSAGE_IMPORTANT);

		return [
				binaryPath
		];
	}

	private function checkOpenedProjectsIfVersioned():Void {
		for (project in as3hx.Compat.each(model.projects)) {
			handleCheckSVNRepository(new ProjectEvent(ProjectEvent.CHECK_SVN_PROJECT, project));
		}
	}

	private function removeIfAlreadyVersioned():Void {
		for (i in as3hx.Compat.each(model.projects)) {
			Reflect.setField(i, 'menuType', Reflect.field(i, 'menuType').replace(',' + ProjectMenuTypes.SVN_PROJECT, ''));
		}

		// following will enable/disable Moonshine top menus based on project
		if (AS3.as(model.activeProject, Bool)) {
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
		}
	}

	private function onOSXodePermission(event:SVNEvent):Void {
		svnBinaryPath = event.url;

		// save the settings
		var thisSettings:Array<ISetting> = cast getSettingsList();
		var pathSettingToDefaultSDK:PathSetting = AS3.as(thisSettings[0], PathSetting);
		dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, 'actionScripts.plugins.svn::SVNPlugin', thisSettings));

		// if an opened project lets test it if Git repository
		if (AS3.as(model.activeProject, Bool)) {
			handleProjectOpen(new ProjectEvent(ProjectEvent.ADD_PROJECT, model.activeProject));
		}
	}

	private function handleProjectOpen(event:ProjectEvent):Void {
		handleCheckSVNRepository(event);
	}

	private function handleCheckSVNRepository(event:ProjectEvent):Void {
		// Check if we have a SVN binary
		if (svnBinaryPath == null || svnBinaryPath == '') {
			return;
		}

		// don't go for a check if already decided as svn project
		if (event.project.menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) == -1) {
			if (isVersioned(event.project.folderLocation)) {
				event.project.menuType += ',' + ProjectMenuTypes.SVN_PROJECT;
				(AS3.as(event.project, AS3ProjectVO)).hasVersionControlType = VersionControlTypes.SVN;
				// following will enable/disable Moonshine top menus based on project
				dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
			}
		}
	}

	private function onLoadRemoteSVNList(event:VersionControlEvent):Void {
		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.loadRemoteList(Reflect.field(event.value, 'repository'), Reflect.field(event.value, 'onCompletion'));
	}

	private function handleCheckoutRequest(event:Event):Void {
		// Check if we have a SVN binary
		// for Windows only
		// @note SK
		// Need to check OSX svn existence someway
		if (svnBinaryPath == null || svnBinaryPath == '') {
			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
			} else {
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.svn::SVNPlugin'));
			}
			return;
		}

		if (checkoutWindow == null) {
			checkoutWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SourceControlCheckout, true), SourceControlCheckout);
			checkoutWindow.title = 'Checkout Repository';
			checkoutWindow.type = Std.string(VersionControlTypes.SVN);
			if (Std.is(event, VersionControlEvent)) {
				checkoutWindow.editingRepository = AS3.as((AS3.as(event, VersionControlEvent)).value, RepositoryItemVO);
			}
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
		if (AS3.as(submitObject, Bool)) {
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.checkout(
					AS3.string(Reflect.field(submitObject, 'url')),
					new File(Reflect.field(submitObject, 'target')),
					AS3.string(Reflect.field(submitObject, 'targetFolder')),
					AS3.as((AS3.as(Reflect.field(submitObject, 'repository'), RepositoryItemVO)).isTrustCertificate, Bool),
					Reflect.field(submitObject, 'repository'),
					(AS3.as(Reflect.field(submitObject, 'user'), Bool)) ? AS3.string(Reflect.field(submitObject, 'user')) : null,
					(AS3.as(Reflect.field(submitObject, 'user'), Bool)) ? AS3.string(Reflect.field(submitObject, 'password')) : null
			);
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
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.commit(model.activeProject.folderLocation, null, user, password, commitInfo, AS3.as((AS3.as(model.activeProject, AS3ProjectVO)).isTrustServerCertificateSVN, Bool));
	}

	private function handleUpdateRequest(event:Event, user:String = null, password:String = null):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var provider:SubversionProvider = new SubversionProvider();
		provider.executable = new File(svnBinaryPath);
		provider.update(AS3.as(model.activeProject.folderLocation.fileBridge.getFile, File), user, password, AS3.as((AS3.as(model.activeProject, AS3ProjectVO)).isTrustServerCertificateSVN, Bool));
	}

	private function isVersioned(folder:FileLocation):Bool {
		return AS3.as(folder.fileBridge.resolvePath('.svn/wc.db').fileBridge.exists, Bool);
	}

	public function new() {
		super();
	}

}