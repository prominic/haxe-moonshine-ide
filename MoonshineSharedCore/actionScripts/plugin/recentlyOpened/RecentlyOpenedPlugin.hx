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
package actionScripts.plugin.recentlyOpened;

import flash.events.Event;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import actionScripts.events.FilePluginEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.StartupHelperEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IMenuPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.utils.ObjectTranslator;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SharedObjectConst;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.MobileDeviceVO;
import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.valueObjects.SDKReferenceVO;
import components.views.project.TreeView;

class RecentlyOpenedPlugin extends PluginBase implements IMenuPlugin {

	public static inline var RECENT_PROJECT_LIST_UPDATED:String = 'RECENT_PROJECT_LIST_UPDATED';
	public static inline var RECENT_FILES_LIST_UPDATED:String = 'RECENT_FILES_LIST_UPDATED';

	override private function get_name():String {
		return 'Recently Opened Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Stores the last opened file paths.';
	}

	private var cookie:SharedObject;

	override public function activate():Void {
		super.activate();

		cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);

		if (model.recentlyOpenedFiles.length == 0) {
			restoreFromCookie();
		}

		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
		//dispatcher.addEventListener(ProjectEvent.ADD_PROJECT_AWAY3D, handleAddProject, false, 0, true);
		dispatcher.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
		dispatcher.addEventListener(ProjectEvent.WORKSPACE_UPDATED, onWorkspaceUpdated);
		dispatcher.addEventListener(SDKUtils.EVENT_SDK_PROMPT_DNS, onSDKExtractDNSUpdated);
		dispatcher.addEventListener(StartupHelperEvent.EVENT_DNS_GETTING_STARTED, onGettingStartedDNSUpdated);
		dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, onJavaPathForTypeaheadSave);
		dispatcher.addEventListener(LayoutModifier.SAVE_LAYOUT_CHANGE_EVENT, onSaveLayoutChangeEvent);
		dispatcher.addEventListener(GeneralEvent.DEVICE_UPDATED, onDeviceListUpdated, false, 0, true);
		dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED, updateRecetProjectList);
		dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED, updateRecetFileList);
		// Give other plugins a chance to cancel the event
		dispatcher.addEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile, false, -100);
	}

	public function getMenu():MenuItem {
		return UtilsCore.getRecentFilesMenu();
	}

	private function restoreFromCookie():Void {
		// Uncomment & run to delete cookie
		//delete cookie.data.recentFiles;
		//delete cookie.data.recentProjects;

		// Load & unserialize recent items
		var recentFiles:Array<Dynamic> = Reflect.field(cookie.data, 'recentFiles');
		var recent:Array<Dynamic> = [];
		var f:FileLocation;
		var file:Dynamic;
		var object:Dynamic;
		var projectReferenceVO:ProjectReferenceVO;
		if (Reflect.hasField(cookie.data, 'recentFiles')) {
			if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
				model.recentlyOpenedProjectOpenedOption.source = Reflect.field(cookie.data, 'recentProjectsOpenedOption');
			} else {
				recentFiles = Reflect.field(cookie.data, 'recentFiles');
				for (i in 0...recentFiles.length) {
					file = recentFiles[i];
					projectReferenceVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
					if (projectReferenceVO.path != null && projectReferenceVO.path != '') {
						f = new FileLocation(projectReferenceVO.path);
						if (AS3.as(f.fileBridge.exists, Bool)) {
							recent.push(projectReferenceVO);
						} else {
							Reflect.field(cookie.data, 'recentFiles').splice(i, 1);
						}
					}
				}

				cookie.flush();
				model.recentlyOpenedFiles.source = recent;
			}
		}

		if (Reflect.hasField(cookie.data, 'recentProjects')) {
			recentFiles = Reflect.field(cookie.data, 'recentProjects');
			recent = [];

			for (j in 0...recentFiles.length) {
				file = recentFiles[j];
				projectReferenceVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
				if (projectReferenceVO.path != null && projectReferenceVO.path != '') {
					f = new FileLocation(projectReferenceVO.path);
					if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && AS3.as(f.fileBridge.exists, Bool)) {
						recent.push(projectReferenceVO);
					} else if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
						recent.push(projectReferenceVO);
					} else {
						Reflect.field(cookie.data, 'recentProjects').splice(j, 1);
					}
				}
			}
			cookie.flush();
			model.recentlyOpenedProjects.source = recent;
		}

		if (Reflect.hasField(cookie.data, 'recentProjectsOpenedOption')) {
			if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
				model.recentlyOpenedProjectOpenedOption.source = Reflect.field(cookie.data, 'recentProjectsOpenedOption');
			} else {
				var recentProjectsOpenedOptions:Array<Dynamic> = Reflect.field(cookie.data, 'recentProjectsOpenedOption');
				recent = [];
				for (object in recentProjectsOpenedOptions) {
					f = new FileLocation(AS3.string(Reflect.field(object, 'path')));
					if (AS3.as(f.fileBridge.exists, Bool)) {
						recent.push(object);
					}
				}
				model.recentlyOpenedProjectOpenedOption.source = recent;
			}
		}

		if (Reflect.hasField(cookie.data, 'userSDKs')) {
			for (object in as3hx.Compat.each(Reflect.field(cookie.data, 'userSDKs'))) {
				var tmpSDK:SDKReferenceVO = SDKReferenceVO.getNewReference(object);
				if (AS3.as(new FileLocation(tmpSDK.path).fileBridge.exists, Bool)) {
					model.userSavedSDKs.addItem(tmpSDK);
				}
			}
		}

		if (Reflect.hasField(cookie.data, 'moonshineWorkspace')) {
			OSXBookmarkerNotifiers.workspaceLocation = new FileLocation(AS3.string(Reflect.field(cookie.data, 'moonshineWorkspace')));
		}
		if (Reflect.hasField(cookie.data, 'isWorkspaceAcknowledged')) {
			OSXBookmarkerNotifiers.isWorkspaceAcknowledged = ((Reflect.field(cookie.data, 'isWorkspaceAcknowledged') == 'true')) ? true : false;
		}
		if (Reflect.hasField(cookie.data, 'isBundledSDKpromptDNS')) {
			ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS = ((Reflect.field(cookie.data, 'isBundledSDKpromptDNS') == 'true')) ? true : false;
		}
		if (Reflect.hasField(cookie.data, 'isSDKhelperPromptDNS')) {
			ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS = ((Reflect.field(cookie.data, 'isSDKhelperPromptDNS') == 'true')) ? true : false;
		}
		if (Reflect.hasField(cookie.data, 'isGettingStartedDNS')) {
			ConstantsCoreVO.IS_GETTING_STARTED_DNS = ((Reflect.field(cookie.data, 'isGettingStartedDNS') == 'true')) ? true : false;
		}
		if (Reflect.hasField(cookie.data, 'javaPathForTypeahead')) {
			model.javaPathForTypeAhead = new FileLocation(AS3.string(Reflect.field(cookie.data, 'javaPathForTypeahead')));
		}
		if (Reflect.hasField(cookie.data, 'devicesAndroid')) {
			ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES = new ArrayCollection();
			ConstantsCoreVO.TEMPLATES_IOS_DEVICES = new ArrayCollection();

			for (object in as3hx.Compat.each(Reflect.field(cookie.data, 'devicesAndroid'))) {
				ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES.addItem(ObjectTranslator.objectToInstance(object, MobileDeviceVO));
			}
			for (object in as3hx.Compat.each(Reflect.field(cookie.data, 'devicesIOS'))) {
				ConstantsCoreVO.TEMPLATES_IOS_DEVICES.addItem(ObjectTranslator.objectToInstance(object, MobileDeviceVO));
			}
		} else {
			ConstantsCoreVO.generateDevices();
		}

		LayoutModifier.parseCookie(cookie);
	}

	private function handleAddProject(event:ProjectEvent):Void {
		// Find & remove project if already present
		//var f:File = (event.project.projectFile) ? event.project.projectFile : event.project.folder;
		var f:FileLocation = event.project.folderLocation;
		var toRemove:Int = -1;
		for (file in model.recentlyOpenedProjects) {
			if (Reflect.field(file, 'path') == f.fileBridge.nativePath) {
				toRemove = AS3.int(model.recentlyOpenedProjects.getItemIndex(file));
				break;
			}
		}
		if (toRemove != -1) {
			model.recentlyOpenedProjects.removeItemAt(toRemove);
			model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
		}

		var customSDKPath:String = null;
		if (Std.is(event.project, AS3ProjectVO)) {
			customSDKPath = (AS3.as(event.project, AS3ProjectVO)).buildOptions.customSDKPath;
		}
		var tmpSOReference:ProjectReferenceVO = new ProjectReferenceVO();
		tmpSOReference.name = event.project.name;
		tmpSOReference.sdk = (customSDKPath != null) ? customSDKPath : Std.string((model.defaultSDK != null) ? model.defaultSDK.fileBridge.nativePath : null);
		tmpSOReference.path = Std.string(event.project.folderLocation.fileBridge.nativePath);
		//tmpSOReference.isAway3D = (event.type == ProjectEvent.ADD_PROJECT_AWAY3D);

		model.recentlyOpenedProjects.addItemAt(tmpSOReference, 0);
		model.recentlyOpenedProjectOpenedOption.addItemAt({
					'path': f.fileBridge.nativePath,
					'option': ((event.extras != null) ? event.extras[0] : '')
				}, 0);

		//Moon-166 fix: This will set selected project in the tree view
		/*var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
		tmpTreeView.tree.selectedItem = model.activeProject.projectFolder;*/

		var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					if (model.activeProject != null) {
						tmpTreeView.tree.selectedItem = model.activeProject.projectFolder;
					}
					as3hx.Compat.clearTimeout(timeoutValue);
				}, 200);

		var timeoutRecentProjectListValue:Int = as3hx.Compat.setTimeout(function():Void {
					dispatcher.dispatchEvent(new Event(RECENT_PROJECT_LIST_UPDATED));
					as3hx.Compat.clearTimeout(timeoutRecentProjectListValue);
				}, 300);
	}

	private function handleOpenFile(event:FilePluginEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}

		// File might have been removed
		var f:FileLocation = event.file;
		if (f == null || !AS3.as(f.fileBridge.exists, Bool)) {
			return;
		}

		// Find item & remove it if already present (path-based, since it's two different File objects)
		var toRemove:Int = -1;
		for (file in model.recentlyOpenedFiles) {
			if (Reflect.field(file, 'path') == f.fileBridge.nativePath) {
				toRemove = AS3.int(model.recentlyOpenedFiles.getItemIndex(file));
				break;
			}
		}
		if (toRemove != -1) {
			model.recentlyOpenedFiles.removeItemAt(toRemove);
		}

		var tmpSOReference:ProjectReferenceVO = new ProjectReferenceVO();
		tmpSOReference.name = ((f.fileBridge.name.indexOf('.') == -1)) ? f.fileBridge.name + '.' + f.fileBridge.extension : Std.string(f.fileBridge.name);
		tmpSOReference.path = Std.string(f.fileBridge.nativePath);
		model.recentlyOpenedFiles.addItemAt(tmpSOReference, 0);
		//model.selectedprojectFolders

		as3hx.Compat.setTimeout(function():Void {
					dispatcher.dispatchEvent(new Event(RECENT_FILES_LIST_UPDATED));
				}, 300);
	}

	private function updateRecetProjectList(event:Event):Void {
		save(model.recentlyOpenedProjects.source, 'recentProjects');
		save(model.recentlyOpenedProjectOpenedOption.source, 'recentProjectsOpenedOption');
	}

	private function updateRecetFileList(event:Event):Void {
		save(model.recentlyOpenedFiles.source, 'recentFiles');
	}

	private function onFlexSDKUpdated(event:ProjectEvent):Void {
		// we need some works here, we don't
		// wants any bundled SDKs to be saved in
		// the saved list
		var tmpArr:Array<Dynamic> = [];
		for (i in model.userSavedSDKs) {
			if (Reflect.field(i, 'status') != SDKUtils.BUNDLED) {
				tmpArr.push(i);
			}
		}

		// and then save
		save(tmpArr, 'userSDKs');
	}

	private function onWorkspaceUpdated(event:ProjectEvent):Void {
		if ((OSXBookmarkerNotifiers.workspaceLocation != null) && AS3.as(OSXBookmarkerNotifiers.workspaceLocation.fileBridge.exists, Bool)) {
			Reflect.setField(cookie.data, 'moonshineWorkspace', OSXBookmarkerNotifiers.workspaceLocation.fileBridge.nativePath);
		}
		Reflect.setField(cookie.data, 'isWorkspaceAcknowledged', Std.string(OSXBookmarkerNotifiers.isWorkspaceAcknowledged));
		cookie.flush();
	}

	private function onSDKExtractDNSUpdated(event:Event):Void {
		Reflect.setField(cookie.data, 'isBundledSDKpromptDNS', Std.string(ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS));
		Reflect.setField(cookie.data, 'isSDKhelperPromptDNS', Std.string(ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS));
		cookie.flush();
	}

	private function onGettingStartedDNSUpdated(event:Event):Void {
		Reflect.setField(cookie.data, 'isGettingStartedDNS', Std.string(ConstantsCoreVO.IS_GETTING_STARTED_DNS));
		cookie.flush();
	}

	private function onJavaPathForTypeaheadSave(event:FilePluginEvent):Void {
		if (event.file != null) {
			Reflect.setField(cookie.data, 'javaPathForTypeahead', event.file.fileBridge.nativePath);
			cookie.flush();
		}
	}

	private function onSaveLayoutChangeEvent(event:GeneralEvent):Void {
		Reflect.setField(cookie.data, Std.string(Reflect.field(event.value, 'label')), Reflect.field(event.value, 'value'));
		cookie.flush();
	}

	private function onDeviceListUpdated(event:GeneralEvent):Void {
		Reflect.setField(cookie.data, 'devicesAndroid', ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES.source);
		Reflect.setField(cookie.data, 'devicesIOS', ConstantsCoreVO.TEMPLATES_IOS_DEVICES.source);
		cookie.flush();
	}

	private function save(recent:Array<Dynamic>, key:String):Void {
		// Only save the ten latest files
		/*if (recent.length > 10)
		{
			recent = recent.slice(0, 10);
		}*/
		// Serialize down to paths
		var toSave:Array<Dynamic> = [];
		for (f in recent) {
			if (Std.is(f, FileLocation)) {
				toSave.push(Reflect.field(Reflect.field(f, 'fileBridge'), 'nativePath'));
			} else {
				toSave.push(f);
			}
		}

		// Add to LocalObject
		Reflect.setField(cookie.data, key, toSave);
		cookie.flush();
	}

	public function new() {
		super();
	}

}