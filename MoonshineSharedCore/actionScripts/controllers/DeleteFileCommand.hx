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
package actionScripts.controllers;

import haxe.Constraints.Function;
import actionScripts.events.RefreshTreeEvent;
import flash.display.DisplayObject;
import flash.events.Event;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.DeleteFileEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.valueObjects.ProjectVO;
import components.popup.ProjectDeletionPopup;

class DeleteFileCommand implements ICommand {

	private var file:FileLocation;
	private var wrapper:FileWrapper;
	private var treeViewHandler:Function;
	private var projectDeletePopup:ProjectDeletionPopup;
	private var thisEvent:DeleteFileEvent;
	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var pendingDeletionProjectsDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var model:IDEModel = IDEModel.getInstance();

	public function execute(event:Event):Void {
		thisEvent = DeleteFileEvent(event);

		var tab:IContentWindow;
		var ed:BasicTextEditor;

		// project deletion
		if (AS3.as(Reflect.field(thisEvent.wrappers[0], 'isRoot'), Bool) && thisEvent.showAlert) {
			if (projectDeletePopup == null) {
				projectDeletePopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), ProjectDeletionPopup, true), ProjectDeletionPopup);
				projectDeletePopup.wrapperBelongToProject = thisEvent.wrappers[0];
				projectDeletePopup.addEventListener(DeleteFileEvent.EVENT_DELETE_FILE, onProjectDeletionConfirmed);
				projectDeletePopup.addEventListener(CloseEvent.CLOSE, onProjectDeletePopupClosed);
				PopUpManager.centerPopUp(projectDeletePopup);
			}
			return;
		} else if (AS3.as(Reflect.field(thisEvent.wrappers[0], 'isRoot'), Bool)) {
			// this generally when deleting a template project
			// ideally, deleting a normal project without above prompting
			// not going to happen
			onProjectDeletionConfirmed(thisEvent);
			return;
		}

		// file/folder deletion for desktop
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			for (fw_ in thisEvent.wrappers) {
				var fw:FileWrapper = cast fw_;
				onFileDeletionConfirmed(fw);
			}

			thisEvent.treeViewCompletionHandler(thisEvent.wrappers);
		}// for web
		else {
			file = thisEvent.file;
			treeViewHandler = cast thisEvent.treeViewCompletionHandler;
			wrapper = thisEvent.wrappers[0];
			wrapper.isWorking = true;
			wrapper.isDeleting = true;

			file.addEventListener(Event.COMPLETE, onFileDeleted);
			file.addEventListener(Event.CLOSE, onDeleteFault);
			file.deleteFileOrDirectory();
		}
	}

	private function onFileDeletionConfirmed(fw:FileWrapper):Void {
		var veSourceFile:FileLocation = null;
		var tab:IContentWindow;
		var ed:BasicTextEditor;

		if (AS3.as(fw.file.fileBridge.isDirectory, Bool)) {
			if (AS3.as(fw.file.fileBridge.exists, Bool)) {
				fw.file.fileBridge.deleteDirectory(true);
			}

			veSourceFile = getVisualEditorSourceFile(fw);
			if (veSourceFile != null && AS3.as(veSourceFile.fileBridge.exists, Bool)) {
				veSourceFile.fileBridge.deleteDirectory(true);
			}
		} else {
			if (AS3.as(fw.file.fileBridge.exists, Bool)) {
				fw.file.fileBridge.deleteFile();
			}

			veSourceFile = getVisualEditorSourceFile(fw);
			if (veSourceFile != null && AS3.as(veSourceFile.fileBridge.exists, Bool)) {
				veSourceFile.fileBridge.deleteFile();
				if (model.showHiddenPaths) {
					var fileForRefresh:FileLocation = veSourceFile;
					if (!AS3.as(veSourceFile.fileBridge.isDirectory, Bool)) {
						fileForRefresh = veSourceFile.fileBridge.parent;
					}
					dispatcher.dispatchEvent(new RefreshTreeEvent(fileForRefresh));
				}
			}
		}

		if (fw.sourceController != null) {
			fw.sourceController.remove(fw.file);
		}

		for (tab in model.editors) {
			ed = AS3.as(tab, BasicTextEditor);
			if (ed != null
				&& ed.currentFile != null
				&& (ed.currentFile.fileBridge.nativePath == fw.file.fileBridge.nativePath ||
				(ed.currentFile.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1))) {
				dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
			);
			}
		}

		// removing the wrapper in tree view
		fw.isDeleting = true;
	}

	private function onProjectDeletionConfirmed(event:DeleteFileEvent):Void {
		var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(event.wrappers[0]);
		// sends delete call to factory classes

		var projectRef:ProjectReferenceVO = Reflect.field(event.wrappers[0], 'projectReference');
		SharedObjectUtil.removeCookieByName('projectFiles' + projectRef.name);
		SharedObjectUtil.removeProjectTreeItemFromOpenedItems(
				{
					'name': projectRef.name,
					'path': projectRef.path
				}, 'name', 'path'
		);

		// removal from the recently opened project in splash screen
		var toRemove:Int = -1;
		for (file in model.recentlyOpenedProjects) {
			if (Reflect.field(file, 'path') == Reflect.field(Reflect.field(Reflect.field(event.wrappers[0], 'file'), 'fileBridge'), 'nativePath')) {
				toRemove = AS3.int(model.recentlyOpenedProjects.getItemIndex(file));
				break;
			}
		}
		if (toRemove != -1) {
			model.recentlyOpenedProjects.removeItemAt(toRemove);
			model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
			dispatcher.dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED));
		}

		// removal from the recently opened files in splash screen
		// Find item & remove it if already present (path-based, since it's two different File objects)
		toRemove = -1;
		var i:Int = 0;
		while (i < model.recentlyOpenedFiles.length) {
			if (Reflect.getProperty(model.recentlyOpenedFiles, Std.string(i)).path.indexOf(Reflect.field(Reflect.field(Reflect.field(event.wrappers[0], 'file'), 'fileBridge'), 'nativePath') + Reflect.field(Reflect.field(Reflect.field(event.wrappers[0], 'file'), 'fileBridge'), 'separator')) != -1) {
				model.recentlyOpenedFiles.removeItemAt(i);
				toRemove = 0;
				i--;
			}
			i++;
		}

		if (toRemove != -1) {
			dispatcher.dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
		}

		// preparing to close the language-server against the project
		// and listen for its complete shutdown event
		// @note
		// visual editor project do not use language server
		if (model.languageServerCore.hasLanguageServerForProject(project) && (!(Std.is(project, AS3ProjectVO)) || !(AS3.as(project, AS3ProjectVO)).isVisualEditorProject)) {
			// keep the files collection in a dictionary so we can select between multiple
			// project deletion calls - as language server shutdown event returns after some delay
			pendingDeletionProjectsDict.set(Reflect.field(event.wrappers[0], 'projectReference'), event.wrappers[0]);

			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed, false, 0, true);
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
		} else {
			// when no language server present or not setup
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
			model.flexCore.deleteProject(event.wrappers[0], cast thisEvent.treeViewCompletionHandler, false);
		}
	}

	private function onProjectLanguageServerClosed(event:ProjectEvent):Void {
		if (pendingDeletionProjectsDict.get(event.project.projectFolder.projectReference) != null) {
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed);
			model.flexCore.deleteProject(pendingDeletionProjectsDict.get(event.project.projectFolder.projectReference), cast thisEvent.treeViewCompletionHandler, false);
			pendingDeletionProjectsDict.remove(event.project.projectFolder.projectReference);
		}
	}

	private function onProjectDeletePopupClosed(event:CloseEvent):Void {
		projectDeletePopup.removeEventListener(DeleteFileEvent.EVENT_DELETE_FILE, onProjectDeletionConfirmed);
		projectDeletePopup.removeEventListener(CloseEvent.CLOSE, onProjectDeletePopupClosed);
		projectDeletePopup = null;
	}

	private function onFileDeleted(event:Event):Void {
		for (tab in model.editors) {
			var ed:BasicTextEditor = AS3.as(tab, BasicTextEditor);
			if (ed != null
				&& ed.currentFile != null
				&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath) {
				dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
			);
			}
		}

		// remove footprints
		wrapper.isDeleting = false;
		wrapper.isWorking = false;
		treeViewHandler(wrapper);
		dispose();
	}

	private function onDeleteFault(event:Event):Void {
		wrapper.isDeleting = false;
		wrapper.isWorking = false;
		treeViewHandler(null);
		dispose();
	}

	private function dispose():Void {
		file.removeEventListener(Event.COMPLETE, onFileDeleted);
		file.removeEventListener(Event.CLOSE, onDeleteFault);
		file = null;
		treeViewHandler = null;
		wrapper = null;
	}

	private function getVisualEditorSourceFile(fw:FileWrapper):FileLocation {
		var as3ProjectVO:AS3ProjectVO = AS3.as(UtilsCore.getProjectFromProjectFolder(fw), AS3ProjectVO);
		if (as3ProjectVO != null && as3ProjectVO.isVisualEditorProject) {
			var veSourcePathFile:String = Std.string(fw.file.fileBridge.nativePath.replace(as3ProjectVO.sourceFolder.fileBridge.nativePath,
									as3ProjectVO.visualEditorSourceFolder.fileBridge.nativePath
					).replace(new as3hx.Compat.Regex('.mxml$|.xhtml$', ''), '.xml'));
			return new FileLocation(veSourcePathFile);
		}

		return null;
	}

	public function new() {}

}