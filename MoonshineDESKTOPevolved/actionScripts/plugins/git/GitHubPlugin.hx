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
package actionScripts.plugins.git;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.managers.PopUpManager;
import actionScripts.events.GeneralEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.event.SetSettingsEvent;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugins.git.model.GitProjectVO;
import actionScripts.plugins.git.model.MethodDescriptor;
import actionScripts.plugins.svn.event.SVNEvent;
import actionScripts.plugins.versionControl.event.VersionControlEvent;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.GenericSelectableObject;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;
import components.popup.GitAuthenticationPopup;
import components.popup.GitBranchSelectionPopup;
import components.popup.GitCommitSelectionPopup;
import components.popup.GitNewBranchPopup;
import components.popup.GitRepositoryPermissionPopup;
import components.popup.GitXCodePermissionPopup;
import components.popup.SourceControlCheckout;

class GitHubPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public static inline var CLONE_REQUEST:String = 'gutCloneRequest';
	public static inline var CHECKOUT_REQUEST:String = 'gitCheckoutRequestEvent';
	public static inline var COMMIT_REQUEST:String = 'gitCommitRequest';
	public static inline var PULL_REQUEST:String = 'gitPullRequest';
	public static inline var PUSH_REQUEST:String = 'gitPushRequest';
	public static inline var REVERT_REQUEST:String = 'gitFilesRevertRequest';
	public static inline var NEW_BRANCH_REQUEST:String = 'gitNewBranchRequest';
	public static inline var CHANGE_BRANCH_REQUEST:String = 'gitChangeBranchRequest';
	public static inline var RELAY_SVN_XCODE_REQUEST:String = 'svnXCodePermissionRequest';

	override private function get_name():String {
		return 'Git';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Git Plugin. Esc exits.';
	}

	private var _gitBinaryPathOSX:String;

	public var gitBinaryPathOSX(get, set):String;
	private function get_gitBinaryPathOSX():String {
		return _gitBinaryPathOSX;
	}

	private function set_gitBinaryPathOSX(value:String):String {
		if (_gitBinaryPathOSX != value) {
			model.gitPath = _gitBinaryPathOSX = value;
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL)));
		}
		return value;
	}

	public var modelAgainstProject:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	public var projectsNotAcceptedByUserToPermitAsGitOnMacOS:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var isGitAvailable:Bool = false;
	private var checkoutWindow:SourceControlCheckout;
	private var xCodePermissionWindow:GitXCodePermissionPopup;
	private var gitRepositoryPermissionWindow:GitRepositoryPermissionPopup;
	private var gitCommitWindow:GitCommitSelectionPopup;
	private var gitAuthWindow:GitAuthenticationPopup;
	private var gitBranchSelectionWindow:GitBranchSelectionPopup;
	private var gitNewBranchWindow:GitNewBranchPopup;
	private var isStartupTest:Bool = false;

	private var _processManager:GitProcessManager;

	private var processManager(get, never):GitProcessManager;
	private function get_processManager():GitProcessManager {
		if (_processManager == null) {
			_processManager = new GitProcessManager();
			_processManager.plugin = this;
			_processManager.setGitAvailable = setGitAvailable;
		}

		if (gitBinaryPathOSX != null) {
			_processManager.gitBinaryPathOSX = gitBinaryPathOSX;
		}
		return _processManager;
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(CLONE_REQUEST, onCloneRequest, false, 0, true);
		dispatcher.addEventListener(CHECKOUT_REQUEST, onCheckoutRequest, false, 0, true);
		dispatcher.addEventListener(COMMIT_REQUEST, onCommitRequest, false, 0, true);
		dispatcher.addEventListener(PULL_REQUEST, onPullRequest, false, 0, true);
		dispatcher.addEventListener(PUSH_REQUEST, onPushRequest, false, 0, true);
		dispatcher.addEventListener(REVERT_REQUEST, onRevertRequest, false, 0, true);
		dispatcher.addEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest, false, 0, true);
		dispatcher.addEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest, false, 0, true);
		dispatcher.addEventListener(ProjectEvent.CHECK_GIT_PROJECT, onMenuTypeUpdateAgainstGit, false, 0, true);
		dispatcher.addEventListener(RELAY_SVN_XCODE_REQUEST, onXCodeAccessRequestBySVN, false, 0, true);

		model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged, false, 0, true);

		isStartupTest = true;
		if (checkOSXGitAccess()) {
			processManager.checkGitAvailability();
		}
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(CLONE_REQUEST, onCloneRequest);
		dispatcher.removeEventListener(CHECKOUT_REQUEST, onCheckoutRequest);
		dispatcher.removeEventListener(COMMIT_REQUEST, onCommitRequest);
		dispatcher.removeEventListener(PULL_REQUEST, onPullRequest);
		dispatcher.removeEventListener(PUSH_REQUEST, onPushRequest);
		dispatcher.removeEventListener(REVERT_REQUEST, onRevertRequest);
		dispatcher.removeEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest);
		dispatcher.removeEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest);
		dispatcher.removeEventListener(ProjectEvent.CHECK_GIT_PROJECT, onMenuTypeUpdateAgainstGit);
		dispatcher.removeEventListener(RELAY_SVN_XCODE_REQUEST, onXCodeAccessRequestBySVN);

		model.projects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged);
	}

	override public function resetSettings():Void {
		gitBinaryPathOSX = null;
		ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = false;
		setGitAvailable(false);
		dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL)));

		for (i in as3hx.Compat.each(model.projects)) {
			Reflect.setField(i, 'menuType', Reflect.field(i, 'menuType').replace(',' + ProjectMenuTypes.GIT_PROJECT, ''));
		}

		// following will enable/disable Moonshine top menus based on project
		if (AS3.as(model.activeProject, Bool)) {
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
		}
	}

	public function getSettingsList():Array<ISetting> {
		var tmpPathSetting:PathSetting = new PathSetting(this, 'gitBinaryPathOSX', 'Git Binary', false, gitBinaryPathOSX, false);
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			tmpPathSetting.setMessage('For most users, it will be easier to set this with "Git > Grant Permission"', AbstractSetting.MESSAGE_IMPORTANT);
		}

		return [
				tmpPathSetting
		];
	}

	public function requestToAuthenticate():Void {
		if (!AS3.as(modelAgainstProject.get(model.activeProject).sessionUser, Bool)) {
			openAuthentication();
		}
	}

	private function setGitAvailable(value:Bool):Void {
		isGitAvailable = value;
		if (checkoutWindow != null) {
			checkoutWindow.isGitAvailable = isGitAvailable;
		}
		if (gitAuthWindow != null) {
			gitAuthWindow.isGitAvailable = isGitAvailable;
		}
		if (gitBranchSelectionWindow != null) {
			gitBranchSelectionWindow.isGitAvailable = isGitAvailable;
		}
		if (gitNewBranchWindow != null) {
			gitNewBranchWindow.isGitAvailable = isGitAvailable;
		}
	}

	private function onProjectsCollectionChanged(event:CollectionEvent):Void {
		if (event.kind == CollectionEventKind.REMOVE && modelAgainstProject.get(Reflect.getProperty(event.items, Std.string(0))) != null) {
			var deletedProjectPath:String = Std.string((AS3.as(Reflect.getProperty(event.items, Std.string(0)), ProjectVO)).folderLocation.fileBridge.nativePath);
			if (projectsNotAcceptedByUserToPermitAsGitOnMacOS.get(deletedProjectPath) != null) {
				projectsNotAcceptedByUserToPermitAsGitOnMacOS.remove(deletedProjectPath);
			}
			modelAgainstProject.remove(Reflect.getProperty(event.items, Std.string(0)));
		}
	}

	private function onXCodeAccessRequestBySVN(event:Event):Void {
		checkOSXGitAccess(Std.string(ProjectMenuTypes.SVN_PROJECT));
	}

	private function checkOSXGitAccess(against:Null<String> = null):Bool {
		if (against == null) {
			against = Std.string(ProjectMenuTypes.GIT_PROJECT);
		}
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool) && gitBinaryPathOSX == null) {
			processManager.getOSXCodePath(onXCodePathDetection, against);
			return false;
		} else if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool) && (against == Std.string(ProjectMenuTypes.SVN_PROJECT)) && !AS3.as(UtilsCore.isSVNPresent(), Bool)) {
			processManager.getOSXCodePath(onXCodePathDetection, against);
			return false;
		} else if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool) && gitBinaryPathOSX != null && !AS3.as(ConstantsCoreVO.IS_GIT_OSX_AVAILABLE, Bool)) {
			ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = true;
		}

		isStartupTest = false;
		return true;
	}

	private function onXCodePathDetection(path:String, isXCodePath:Bool, against:String):Void {
		// if calls during startup
		// do not open the prompt
		if (!isStartupTest && path != null && xCodePermissionWindow == null) {
			xCodePermissionWindow = new GitXCodePermissionPopup();
			xCodePermissionWindow.isXCodePath = isXCodePath;
			xCodePermissionWindow.xCodePath = path;
			xCodePermissionWindow.xCodePathAgainst = against;
			xCodePermissionWindow.horizontalCenter = xCodePermissionWindow.verticalCenter = 0;
			xCodePermissionWindow.addEventListener(Event.CLOSE, onXCodePermissionClosed, false, 0, true);
			FlexGlobals.topLevelApplication.addElement(xCodePermissionWindow);
		}

		isStartupTest = false;
	}

	private function onXCodePermissionClosed(event:Event):Void {
		var isDiscarded:Bool = xCodePermissionWindow.isDiscarded;
		var isGranted:Bool;
		if (!isDiscarded) {
			isGranted = true;

			var svnBinaryPathOSX:String = xCodePermissionWindow.xCodePath + '/usr/bin/svn';

			gitBinaryPathOSX = xCodePermissionWindow.xCodePath + '/usr/bin/git';
			Alert.show('Permission accepted. You can now use Moonshine Git and SVN functionalities.', 'Success!');

			var thisSettings:Array<ISetting> = cast getSettingsList();
			var pathSettingToDefaultSDK:PathSetting = AS3.as(thisSettings[0], PathSetting);
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, 'actionScripts.plugins.git::GitHubPlugin', thisSettings));
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, null, svnBinaryPathOSX));

			// re-test
			processManager.checkGitAvailability();
			// if an opened project lets test it if Git repository
			if (AS3.as(model.activeProject, Bool)) {
				processManager.pendingProcess.push(new MethodDescriptor(processManager, 'checkIfGitRepository', AS3.as(model.activeProject, AS3ProjectVO)));
			}
		} else {
			isGranted = false;
		}

		if (ConstantsCoreVO.IS_GIT_OSX_AVAILABLE != isGranted) {
			ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = isGranted;
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL)));
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL)));
		}

		xCodePermissionWindow.removeEventListener(Event.CLOSE, onXCodePermissionClosed);
		FlexGlobals.topLevelApplication.removeElement(xCodePermissionWindow);
		xCodePermissionWindow = null;
	}

	private function onCloneRequest(event:Event):Void {
		if (checkoutWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			checkoutWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SourceControlCheckout, false), SourceControlCheckout);
			checkoutWindow.title = 'Clone Repository';
			checkoutWindow.type = Std.string(VersionControlTypes.GIT);
			checkoutWindow.isGitAvailable = isGitAvailable;
			if (Std.is(event, VersionControlEvent)) {
				checkoutWindow.editingRepository = AS3.as((AS3.as(event, VersionControlEvent)).value, RepositoryItemVO);
			}
			checkoutWindow.addEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			PopUpManager.centerPopUp(checkoutWindow);
		} else {
			PopUpManager.bringToFront(checkoutWindow);
		}
	}

	private function onCheckoutWindowClosed(event:CloseEvent):Void {
		var submitObject:Dynamic = checkoutWindow.submitObject;

		checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
		PopUpManager.removePopUp(checkoutWindow);
		checkoutWindow = null;

		if (AS3.as(submitObject, Bool)) {
			processManager.clone(AS3.string(Reflect.field(submitObject, 'url')), AS3.string(Reflect.field(submitObject, 'target')), AS3.string(Reflect.field(submitObject, 'targetFolder')), Reflect.field(submitObject, 'repository'));
		}
	}

	private function onCheckoutRequest(event:Event):Void {
		processManager.checkout();
	}

	private function onCommitRequest(event:Event):Void {
		if (gitCommitWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			gitCommitWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitCommitSelectionPopup, false), GitCommitSelectionPopup);
			gitCommitWindow.title = 'Commit';
			gitCommitWindow.isGitAvailable = isGitAvailable;
			gitCommitWindow.addEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
			PopUpManager.centerPopUp(gitCommitWindow);

			// we let the popup opened completely
			// then run the following process else
			// there could be a hold before appearing
			// the window until folling process is finished
			gitCommitWindow.callLater(function():Void {
						if (!AS3.as(processManager.hasEventListener(GitProcessManager.GIT_DIFF_CHECKED), Bool)) {
							processManager.addEventListener(GitProcessManager.GIT_DIFF_CHECKED, onGitDiffChecked, false, 0, true);
						}
						processManager.checkDiff();
					});
		} else {
			PopUpManager.bringToFront(gitCommitWindow);
		}
	}

	private function onGitAuthorDetection(value:GitProjectVO):Void {
		if (gitCommitWindow != null && value != null) {
			gitCommitWindow.onGitAuthorDetection(value);
		}
	}

	private function onGitCommitWindowClosed(event:CloseEvent):Void {
		if (gitCommitWindow.isSubmit) {
			processManager.commit(gitCommitWindow.commitDiffCollection, gitCommitWindow.commitMessage);
		}

		gitCommitWindow.removeEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
		PopUpManager.removePopUp(gitCommitWindow);
		gitCommitWindow = null;
	}

	private function onGitDiffChecked(event:GeneralEvent):Void {
		processManager.removeEventListener(GitProcessManager.GIT_DIFF_CHECKED, onGitDiffChecked);
		if (gitCommitWindow != null) {
			gitCommitWindow.isReadyToUse = true;
			gitCommitWindow.commitDiffCollection = AS3.as(event.value, ArrayCollection);
		}

		processManager.getGitAuthor(onGitAuthorDetection);
	}

	private function onPullRequest(event:Event):Void {
		processManager.pull();
	}

	private function onPushRequest(event:Event):Void {
		processManager.push();
	}

	private function onAuthSuccessToPush(event:Event):Void {
		if (AS3.as(gitAuthWindow.userObject, Bool)) {
			if (AS3.as(Reflect.field(gitAuthWindow.userObject, 'save'), Bool)) {
				modelAgainstProject.set(model.activeProject, Reflect.field(gitAuthWindow.userObject, 'userName')).sessionUser;
				modelAgainstProject.set(model.activeProject, Reflect.field(gitAuthWindow.userObject, 'password')).sessionPassword;
				processManager.push(null);
			} else {
				processManager.push(gitAuthWindow.userObject);
			}
		}
	}

	private function onRevertRequest(event:Event):Void {
		if (gitCommitWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			gitCommitWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitCommitSelectionPopup, false), GitCommitSelectionPopup);
			gitCommitWindow.title = 'Modified File(s)';
			gitCommitWindow.type = GitCommitSelectionPopup.TYPE_REVERT;
			gitCommitWindow.isGitAvailable = isGitAvailable;
			gitCommitWindow.addEventListener(CloseEvent.CLOSE, onGitRevertWindowClosed);
			PopUpManager.centerPopUp(gitCommitWindow);

			// we let the popup opened completely
			// then run the following process else
			// there could be a hold before appearing
			// the window until folling process is finished
			gitCommitWindow.callLater(function():Void {
						processManager.checkDiff();
						if (!AS3.as(processManager.hasEventListener(GitProcessManager.GIT_DIFF_CHECKED), Bool)) {
							processManager.addEventListener(GitProcessManager.GIT_DIFF_CHECKED, onGitDiffChecked, false, 0, true);
						}
					});
		} else {
			PopUpManager.bringToFront(gitCommitWindow);
		}
	}

	private function onGitRevertWindowClosed(event:CloseEvent):Void {
		if (gitCommitWindow.isSubmit) {
			processManager.revert(gitCommitWindow.commitDiffCollection);
		}

		gitCommitWindow.removeEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
		PopUpManager.removePopUp(gitCommitWindow);
		gitCommitWindow = null;
	}

	private function onNewBranchRequest(event:Event):Void {
		if (gitBranchSelectionWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			gitNewBranchWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitNewBranchPopup, false), GitNewBranchPopup);
			gitNewBranchWindow.title = 'New Branch';
			gitNewBranchWindow.isGitAvailable = isGitAvailable;
			gitNewBranchWindow.addEventListener(CloseEvent.CLOSE, onGitNewBranchWindowClosed);
			gitNewBranchWindow.addEventListener(GitNewBranchPopup.VALIDATE_NAME, onNameValidationRequest);
			PopUpManager.centerPopUp(gitNewBranchWindow);
		} else {
			PopUpManager.bringToFront(gitNewBranchWindow);
		}
	}

	private function onGitNewBranchWindowClosed(event:CloseEvent):Void {
		var newBranchDetails:Dynamic = gitNewBranchWindow.submitObject;

		gitNewBranchWindow.removeEventListener(CloseEvent.CLOSE, onGitNewBranchWindowClosed);
		gitNewBranchWindow.removeEventListener(GitNewBranchPopup.VALIDATE_NAME, onNameValidationRequest);
		PopUpManager.removePopUp(gitNewBranchWindow);
		gitNewBranchWindow = null;

		if (AS3.as(newBranchDetails, Bool)) {
			processManager.createAndCheckoutNewBranch(AS3.string(Reflect.field(newBranchDetails, 'name')), AS3.as(Reflect.field(newBranchDetails, 'pushToRemote'), Bool));
		}
	}

	private function onNameValidationRequest(event:GeneralEvent):Void {
		processManager.checkBranchNameValidity(Std.string(event.value), onNameValidatedByGit);
	}

	private function onNameValidatedByGit(value:String):Void {
		gitNewBranchWindow.onNameValidatedByGit(value);
	}

	private function onChangeBranchRequest(event:Event):Void {
		processManager.switchBranch();
		if (!AS3.as(processManager.hasEventListener(GitProcessManager.GIT_REMOTE_BRANCH_LIST), Bool)) {
			processManager.addEventListener(GitProcessManager.GIT_REMOTE_BRANCH_LIST, onGitRemoteBranchListReceived, false, 0, true);
		}
	}

	private function onGitRemoteBranchListReceived(event:GeneralEvent):Void {
		processManager.removeEventListener(GitProcessManager.GIT_REMOTE_BRANCH_LIST, onGitRemoteBranchListReceived);

		if (gitBranchSelectionWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			gitBranchSelectionWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitBranchSelectionPopup, false), GitBranchSelectionPopup);
			gitBranchSelectionWindow.title = 'Select Branch';
			gitBranchSelectionWindow.isGitAvailable = isGitAvailable;
			gitBranchSelectionWindow.branchCollection = AS3.as(event.value, ArrayCollection);
			gitBranchSelectionWindow.addEventListener(CloseEvent.CLOSE, onGitBranchSelectionWindowClosed);
			PopUpManager.centerPopUp(gitBranchSelectionWindow);
		} else {
			PopUpManager.bringToFront(gitBranchSelectionWindow);
		}
	}

	private function onGitBranchSelectionWindowClosed(event:CloseEvent):Void {
		gitBranchSelectionWindow.removeEventListener(CloseEvent.CLOSE, onGitBranchSelectionWindowClosed);

		var selectedBranch:GenericSelectableObject = (gitBranchSelectionWindow.isSubmit) ? AS3.as(gitBranchSelectionWindow.lstBranches.selectedItem, GenericSelectableObject) : null;

		PopUpManager.removePopUp(gitBranchSelectionWindow);
		gitBranchSelectionWindow = null;

		if (selectedBranch != null) {
			processManager.changeBranchTo(selectedBranch);
		}
	}

	private function onMenuTypeUpdateAgainstGit(event:ProjectEvent):Void {
		// don't go for a check if already decided as a git project
		// or a project is not permitted to access as a git repository on sandbox macos
		if (event.project.menuType.indexOf(ProjectMenuTypes.GIT_PROJECT) != -1 ||
			projectsNotAcceptedByUserToPermitAsGitOnMacOS.get(event.project.folderLocation.fileBridge.nativePath) != null ||
			!isGitAvailable) {
			// following will enable/disable Moonshine top menus based on project
			dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
			return;
		}

		if (!AS3.as(processManager.hasEventListener(GitProcessManager.GIT_REPOSITORY_TEST), Bool)) {
			processManager.addEventListener(GitProcessManager.GIT_REPOSITORY_TEST, onGitRepositoryTested, false, 0, true);
		}
		processManager.checkIfGitRepository(AS3.as(event.project, AS3ProjectVO));
	}

	private function onGitRepositoryTested(event:GeneralEvent):Void {
		processManager.removeEventListener(GitProcessManager.GIT_REPOSITORY_TEST, onGitRepositoryTested);
		if (AS3.as(event.value, Bool) && gitRepositoryPermissionWindow == null) {
			gitRepositoryPermissionWindow = new GitRepositoryPermissionPopup();
			gitRepositoryPermissionWindow.project = event.value.project;
			gitRepositoryPermissionWindow.gitRootLocation = event.value.gitRootLocation;
			gitRepositoryPermissionWindow.horizontalCenter = gitRepositoryPermissionWindow.verticalCenter = 0;
			gitRepositoryPermissionWindow.addEventListener(Event.CLOSE, onGitRepositoryPermissionClosed, false, 0, true);
			FlexGlobals.topLevelApplication.addElement(gitRepositoryPermissionWindow);
		}
	}

	private function onGitRepositoryPermissionClosed(event:Event):Void {
		gitRepositoryPermissionWindow.removeEventListener(Event.CLOSE, onGitRepositoryPermissionClosed);

		var isAccepted:Bool = gitRepositoryPermissionWindow.isAccepted;
		var tmpProject:AS3ProjectVO = gitRepositoryPermissionWindow.project;

		FlexGlobals.topLevelApplication.removeElement(gitRepositoryPermissionWindow);
		gitRepositoryPermissionWindow = null;

		if (isAccepted) {
			tmpProject.menuType += ',' + ProjectMenuTypes.GIT_PROJECT;

			checkOSXGitAccess();
			processManager.checkIfGitRepository(tmpProject);
		} else {
			projectsNotAcceptedByUserToPermitAsGitOnMacOS.set(tmpProject.folderLocation.fileBridge.nativePath, true);
		}
	}

	private function openAuthentication():Void {
		function onGitAuthWindowClosed(event:CloseEvent):Void {
			gitAuthWindow.removeEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			gitAuthWindow.removeEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSuccessToPush);
			PopUpManager.removePopUp(gitAuthWindow);
			gitAuthWindow = null;
		}; /*
		 * @local
		 */
		if (gitAuthWindow == null) {
			if (!checkOSXGitAccess()) {
				return;
			}

			processManager.checkGitAvailability();

			gitAuthWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GitAuthenticationPopup, true), GitAuthenticationPopup);
			gitAuthWindow.title = 'Git Needs Authentication';
			gitAuthWindow.isGitAvailable = isGitAvailable;
			gitAuthWindow.type = Std.string(VersionControlTypes.GIT);
			gitAuthWindow.addEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			gitAuthWindow.addEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSuccessToPush);
			PopUpManager.centerPopUp(gitAuthWindow);
		}
	}

	public function new() {
		super();
	}

}