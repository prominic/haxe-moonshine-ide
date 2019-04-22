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
package actionScripts.plugins.versionControl;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.SettingsEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugins.git.GitHubPlugin;
import actionScripts.plugins.versionControl.event.VersionControlEvent;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;
import components.popup.AddRepositoryPopup;
import components.popup.ManageRepositoriesPopup;

class VersionControlPlugin extends PluginBase {

	override private function get_name():String {
		return 'Version Control';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Version Controls\' Manager Plugin';
	}

	private var addRepositoryWindow:AddRepositoryPopup;
	private var manageRepoWindow:ManageRepositoriesPopup;

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories, false, 0, true);
		dispatcher.addEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository, false, 0, true);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories);
		dispatcher.removeEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository);
	}

	//--------------------------------------------------------------------------
	//
	//  MANAGE REPOSITORIES
	//
	//--------------------------------------------------------------------------

	private function handleOpenManageRepositories(event:Event):Void {
		if (!continueIfSVNSupported()) {
			return;
		}

		openManageRepoWindow();
	}

	private function openManageRepoWindow():Void {
		if (manageRepoWindow == null) {
			manageRepoWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), ManageRepositoriesPopup, false), ManageRepositoriesPopup);
			manageRepoWindow.title = 'Manage Repositories';
			manageRepoWindow.repositories = VersionControlUtils.REPOSITORIES;
			manageRepoWindow.width = FlexGlobals.topLevelApplication.stage.nativeWindow.width * .8;
			manageRepoWindow.height = FlexGlobals.topLevelApplication.stage.nativeWindow.height * .5;
			manageRepoWindow.addEventListener(CloseEvent.CLOSE, onManageRepoWindowClosed);
			PopUpManager.centerPopUp(manageRepoWindow);
		} else {
			PopUpManager.bringToFront(manageRepoWindow);
		}
	}

	private function onManageRepoWindowClosed(event:CloseEvent):Void {
		manageRepoWindow.removeEventListener(CloseEvent.CLOSE, onManageRepoWindowClosed);
		PopUpManager.removePopUp(manageRepoWindow);
		manageRepoWindow = null;
	}

	//--------------------------------------------------------------------------
	//
	//  CHECKOUT/CLONE WINDOW
	//
	//--------------------------------------------------------------------------

	private function handleOpenAddRepository(event:Event):Void {
		openAddEditRepositoryWindow(
				(((Std.is(event, VersionControlEvent)) && AS3.as((AS3.as(event, VersionControlEvent)).value, Bool))) ?
				(AS3.as((AS3.as(event, VersionControlEvent)).value, RepositoryItemVO)) :
				null
		);
	}

	private function openAddEditRepositoryWindow(editItem:RepositoryItemVO = null):Void {
		if (addRepositoryWindow == null) {
			addRepositoryWindow = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), AddRepositoryPopup, true), AddRepositoryPopup);
			addRepositoryWindow.title = 'Add Repository';
			addRepositoryWindow.type = Std.string(VersionControlTypes.SVN);
			addRepositoryWindow.editingRepository = editItem;
			addRepositoryWindow.addEventListener(CloseEvent.CLOSE, onAddRepoWindowClosed);
			addRepositoryWindow.addEventListener(VersionControlEvent.ADD_EDIT_REPOSITORY, onAddEditRepository);

			PopUpManager.centerPopUp(addRepositoryWindow);
		} else {
			PopUpManager.bringToFront(addRepositoryWindow);
		}
	}

	private function onAddEditRepository(event:VersionControlEvent):Void {
		// check if new repository or old
		if (VersionControlUtils.REPOSITORIES.getItemIndex(event.value) == -1) {
			VersionControlUtils.REPOSITORIES.addItem(event.value);
		}
		SharedObjectUtil.saveRepositoriesToSO(VersionControlUtils.REPOSITORIES);
	}

	private function onAddRepoWindowClosed(event:CloseEvent):Void {
		addRepositoryWindow.removeEventListener(CloseEvent.CLOSE, onAddRepoWindowClosed);
		addRepositoryWindow.removeEventListener(VersionControlEvent.ADD_EDIT_REPOSITORY, onAddEditRepository);

		PopUpManager.removePopUp(addRepositoryWindow);
		addRepositoryWindow = null;
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE API
	//
	//--------------------------------------------------------------------------

	private function continueIfSVNSupported():Bool {
		// check if svn path exists
		if (!AS3.as(model.svnPath, Bool) || model.svnPath == '') {
			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
			} else {
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.svn::SVNPlugin'));
			}
			return false;
		}

		return true;
	}

	private function isVersioned(folder:FileLocation):Bool {
		return AS3.as(folder.fileBridge.resolvePath('.svn/wc.db').fileBridge.exists, Bool);
	}

	public function new() {
		super();
	}

}