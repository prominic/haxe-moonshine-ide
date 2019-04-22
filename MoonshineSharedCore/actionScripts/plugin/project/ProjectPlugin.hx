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
package actionScripts.plugin.project;

import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.settings.SettingsInfoView;
import actionScripts.ui.menu.MenuPlugin;
import flash.events.Event;
import flash.net.SharedObject;
import actionScripts.events.AddTabEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.ShowSettingsEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.valueObjects.ProjectVO;
import components.views.project.OpenResourceView;
import components.views.project.TreeView;

class ProjectPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public static inline var EVENT_PROJECT_SETTINGS:String = 'projectSettingsEvent';
	public static inline var EVENT_SHOW_OPEN_RESOURCE:String = 'showOpenResource';

	override private function get_name():String {
		return 'Project Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides project settings.';
	}

	private var treeView:TreeView;
	private var openResourceView:OpenResourceView;
	private var lastActiveProjectMenuType:String;

	public function new() {
		super();
		treeView = new TreeView();
		treeView.projects = model.projects;
	}

	override public function activate():Void {
		super.activate();
		_activated = true;

		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
		dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);

		dispatcher.addEventListener(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS, handleShowPreviouslyOpenedProjects);
		dispatcher.addEventListener(ProjectEvent.SCROLL_FROM_SOURCE, handleScrollFromSource);
		dispatcher.addEventListener(ProjectEvent.SHOW_PROJECT_VIEW, handleShowProjectView);

		dispatcher.addEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);

		dispatcher.addEventListener(ShowSettingsEvent.EVENT_SHOW_SETTINGS, handleShowSettings);
		dispatcher.addEventListener(EVENT_PROJECT_SETTINGS, handleMenuShowSettings);

		dispatcher.addEventListener(RefreshTreeEvent.EVENT_REFRESH, handleTreeRefresh);
	}

	private function handleScrollFromSource(event:ProjectEvent):Void {
		var basicTextEditor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
		if (basicTextEditor != null) {
			var activeEditorFile:FileLocation = basicTextEditor.currentFile;
			var activeFilePath:String = Std.string(activeEditorFile.fileBridge.nativePath);
			var childrenForOpen:Array<String> = activeFilePath.split(Std.string(activeEditorFile.fileBridge.separator));
			treeView.tree.expandChildrenByName('name', cast childrenForOpen);
		}
	}

	override public function deactivate():Void {
		super.deactivate();
		_activated = false;

		dispatcher.removeEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);
	}

	public function getSettingsList():Array<ISetting> {
		return new Array<ISetting>();
	}

	private function showProjectPanel():Void {
		if (!AS3.as(treeView.stage, Bool)) {
			LayoutModifier.attachSidebarSections(treeView);
		}
	}

	private function handleShowSettings(event:ShowSettingsEvent):Void {
		showSettings(event.project, event.jumpToSection);
	}

	private function handleMenuShowSettings(event:Event):Void {
		var project:ProjectVO = model.activeProject;
		if (project != null) {
			showSettings(model.activeProject);
		}
	}

	private function showSettings(project:ProjectVO, jumpToSection:String = null):Void {
		// Don't spawn two identical settings views.
		for (i in 0...model.editors.length) {
			var view:SettingsView = AS3.as(model.editors, SettingsView);
			if (view != null && view.associatedData == project) {
				model.activeEditor = view;
				return;
			}
		}

		var settingsLabel:String = project.folderLocation.fileBridge.name + ' settings';

		if (Std.is(project, JavaProjectVO)) {
			var gradleProject:JavaProjectVO = AS3.as(project, JavaProjectVO);
			if (gradleProject.hasGradleBuild()) {
				var noSettingsInfo:SettingsInfoView = new SettingsInfoView();
				noSettingsInfo.addEventListener(SettingsInfoView.EVENT_CLOSE, settingsInfoClose);

				dispatcher.dispatchEvent(new AddTabEvent(noSettingsInfo));
				return;
			}
		}

		// Create settings view & fetch project settings
		var settingsView:SettingsView = new SettingsView();
		settingsView.Width = 230;
		settingsView.addCategory(settingsLabel);

		var categories:Array<SettingsWrapper> = cast project.getSettings();
		for (category in categories) {
			settingsView.addSetting(category, settingsLabel);
			if (jumpToSection != null && jumpToSection.toLowerCase() == category.name.toLowerCase()) {
				settingsView.currentRequestedSelectedItem = category;
			}
		}

		settingsView.label = settingsLabel;
		settingsView.associatedData = project;

		// Listen for save/cancel
		settingsView.addEventListener(SettingsView.EVENT_SAVE, settingsSave);
		settingsView.addEventListener(SettingsView.EVENT_CLOSE, settingsClose);

		dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
		);
	}

	private function settingsClose(event:Event):Void {
		var settings:SettingsView = AS3.as(event.target, SettingsView);

		// Close the tab
		dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, settings)
		);

		settings.removeEventListener(SettingsView.EVENT_CLOSE, settingsClose);
		settings.removeEventListener(SettingsView.EVENT_SAVE, settingsSave);
	}

	private function settingsSave(event:Event):Void {
		var view:SettingsView = AS3.as(event.target, SettingsView);

		if (view != null && Std.is(view.associatedData, ProjectVO)) {
			var pvo:ProjectVO = AS3.as(view.associatedData, ProjectVO);

			if (model.projects.getItemIndex(pvo) == -1) {
				// Newly created project, add it to project explorer & show it
				model.projects.addItem(pvo);
				model.activeProject = pvo;

				if (lastActiveProjectMenuType != pvo.menuType) {
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, model.activeProject));
					lastActiveProjectMenuType = pvo.menuType;
				}

				showProjectPanel();

				dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, view)
			);
			}// Save
			else {
				// Save
				pvo.saveSettings();
			}
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SAVE_PROJECT_SETTINGS, pvo));
		}
	}

	private function settingsInfoClose(event:Event):Void {
		var settings:SettingsInfoView = AS3.as(event.target, SettingsInfoView);

		// Close the tab
		dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, settings));

		settings.removeEventListener(SettingsView.EVENT_CLOSE, settingsInfoClose);
	}

	private function handleAddProject(event:ProjectEvent):Void {
		showProjectPanel();
		// Is file in an already opened project?
		for (p in model.projects) {
			if (event.project.folderLocation.fileBridge.nativePath == Reflect.field(Reflect.field(Reflect.field(p, 'folderLocation'), 'fileBridge'), 'nativePath')) {
				return;
			}
		}

		if (model.projects.getItemIndex(event.project) == -1) {
			model.projects.addItemAt(event.project, 0);

			if (Std.is(event.project, AS3ProjectVO) && lastActiveProjectMenuType != event.project.menuType) {
				dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
				lastActiveProjectMenuType = event.project.menuType;
			}
		}

		openRecentlyUsedFiles(event.project);
		SharedObjectUtil.saveProjectForOpen(Std.string(event.project.folderLocation.fileBridge.nativePath), event.project.projectName);
	}

	private function handleRemoveProject(event:ProjectEvent):Void {
		var idx:Int = AS3.int(model.projects.getItemIndex(event.project));
		if (idx > -1) {
			model.projects.removeItemAt(idx);
		}

		if (model.activeProject == event.project) {
			if (model.projects.length == 0) {
				model.activeProject = null;
			}

			if (model.activeProject == null || (Std.is(model.activeProject, AS3ProjectVO) && lastActiveProjectMenuType != AS3ProjectVO(model.activeProject).menuType)) {
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, model.activeProject));
				if (Std.is(model.activeProject, AS3ProjectVO)) {
					lastActiveProjectMenuType = (model.activeProject != null) ? model.activeProject.menuType : null;
				} else {
					lastActiveProjectMenuType = null;
				}
			}
		}

		SharedObjectUtil.removeProjectFromOpen(Std.string(event.project.folderLocation.fileBridge.nativePath), event.project.projectName);
	}

	private function handleShowOpenResource(event:Event):Void {
		if (openResourceView == null) {
			openResourceView = new OpenResourceView();
		}

		// If it's not showing, spin it into view
		if (!AS3.as(openResourceView.stage, Bool)) {
			openResourceView.setFileList(treeView.projectFolders);
			openResourceView.setFocus();
		}
	}

	private function handleShowProjectView(event:Event):Void {
		showProjectPanel();
	}

	private function handleTreeRefresh(event:RefreshTreeEvent):Void {
		treeView.refresh(event.dir, event.shallMarkedForDelete);
	}

	private function handleShowPreviouslyOpenedProjects(event:ProjectEvent):Void {
		openPreviouslyOpenedProject();
	}

	private function openRecentlyUsedFiles(project:ProjectVO):Void {
		var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO('projectFiles');
		if (cookie == null) {
			return;
		}

		var projectFilesForOpen:Array<Dynamic> = Reflect.field(cookie.data, 'projectFiles' + project.name);
		if (projectFilesForOpen != null) {
			for (i in 0...projectFilesForOpen.length) {
				var itemForOpen:Dynamic = projectFilesForOpen[i];
				for (item in Reflect.fields(itemForOpen)) {
					var fileLocation:FileLocation = new FileLocation(AS3.string(Reflect.field(itemForOpen, item)));
					if (AS3.as(fileLocation.fileBridge.exists, Bool)) {
						var as3Project:AS3ProjectVO = (AS3.as(project, AS3ProjectVO));
						var customSDKPath:String = (as3Project != null) ? as3Project.buildOptions.customSDKPath : '';
						var projectReferenceVO:ProjectReferenceVO = new ProjectReferenceVO();
						projectReferenceVO.name = project.name;
						projectReferenceVO.sdk = (customSDKPath != null) ? customSDKPath :
								Std.string((model.defaultSDK != null) ? model.defaultSDK.fileBridge.nativePath : null);

						projectReferenceVO.path = Std.string(project.folderLocation.fileBridge.nativePath);

						var fileWrapper:FileWrapper = new FileWrapper(fileLocation, false, projectReferenceVO);
						dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, cast [fileLocation], -1, cast [fileWrapper]));
					} else {
						SharedObjectUtil.removeLocationOfClosingProjectFile(
								fileLocation.name,
								Std.string(fileLocation.fileBridge.nativePath),
								project.projectFolder.nativePath
				);
					}
				}
			}
		}
	}

	private function openPreviouslyOpenedProject():Void {
		dispatcher.removeEventListener(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS, handleShowPreviouslyOpenedProjects);

		var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO('projects');
		if (cookie == null) {
			return;
		}

		var projectsForOpen:Array<Dynamic> = Reflect.field(cookie.data, 'projects');
		if (projectsForOpen != null && projectsForOpen.length > 0) {
			var projectLocationInfo:Dynamic = {};
			ConstantsCoreVO.STARTUP_PROJECT_OPEN_QUEUE_LEFT = projectsForOpen.length;
			for (i in 0...projectsForOpen.length) {
				var project:ProjectVO;
				for (item in Reflect.fields(projectsForOpen[i])) {
					Reflect.setField(projectLocationInfo, 'path', item);
					Reflect.setField(projectLocationInfo, 'name', Reflect.field(projectsForOpen[i], item));
				}

				var projectLocation:FileLocation = new FileLocation(AS3.string(Reflect.field(projectLocationInfo, 'path')));
				var projectFile:Dynamic = projectLocation.fileBridge.getFile;
				var projectFileLocation:FileLocation = model.flexCore.testFlashDevelop(projectFile);

				if (projectFileLocation != null) {
					project = model.flexCore.parseFlashDevelop(null, projectFileLocation, AS3.string(Reflect.field(projectLocationInfo, 'name')));
				}

				if (project == null) {
					projectFileLocation = model.flexCore.testFlashBuilder(projectFile);
					if (projectFileLocation != null) {
						project = model.flexCore.parseFlashBuilder(projectLocation);
					}
				}

				if (project == null) {
					projectFileLocation = model.javaCore.testJava(projectFile);
					if (projectFileLocation != null) {
						project = model.javaCore.parseJava(projectLocation);
					}
				}

				if (project != null) {
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project));
					project = null;
				} else {
					var pr:Dynamic = projectsForOpen[i];
					SharedObjectUtil.removeProjectFromOpen(AS3.string(Reflect.field(projectLocationInfo, 'path')), AS3.string(Reflect.field(projectLocationInfo, 'name')));
					SharedObjectUtil.removeProjectTreeItemFromOpenedItems(projectLocationInfo, 'name', 'path');
				}

				Reflect.setField(projectLocationInfo, 'projectPath', null);
				Reflect.setField(projectLocationInfo, 'projectName', null);
			}
		}
	}

}