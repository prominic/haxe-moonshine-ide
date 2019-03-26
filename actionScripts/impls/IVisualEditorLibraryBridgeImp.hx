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
package actionScripts.impls;

import haxe.Constraints.Function;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugins.ui.editor.VisualEditorViewer;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.ResourceVO;
import view.VisualEditor;
import view.interfaces.IVisualEditorLibraryBridge;
class IVisualEditorLibraryBridgeImp implements IVisualEditorLibraryBridge {

	public var visualEditorProject:AS3ProjectVO;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var model:IDEModel = IDEModel.getInstance();

	private var updateHandler:Function;

	public function getXhtmlFileUpdates(updateHandler:Function = null):Void {
		this.updateHandler = updateHandler;
		if (!visualEditorProject.filesList) {
			visualEditorProject.filesList = new ArrayCollection();
			UtilsCore.parseFilesList(visualEditorProject.filesList, try cast(visualEditorProject, ProjectVO) catch (e:Dynamic) null, ['xhtml'], true); // to be use in includes files list in primefaces
			dispatcher.addEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onNewFileAdded, false, 0, true);
			dispatcher.addEventListener(TreeMenuItemEvent.FILE_DELETED, onFileRemoved, false, 0, true);
			dispatcher.addEventListener(TreeMenuItemEvent.FILE_RENAMED, onFileRenamed, false, 0, true);

			// remove footprint when project is removed
			model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange, false, 0, true);
		}

		sendXHtmlUpdates();
	}

	public function openXhtmlFile(path:String):Void {
		var tmpOpenFile:FileLocation = new FileLocation(visualEditorProject.sourceFolder.fileBridge.nativePath + visualEditorProject.projectFile.fileBridge.separator + path);
		if (tmpOpenFile == null) {
			return;
		}

		dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpOpenFile]));
	}

	public function getVisualEditorComponent():VisualEditor {
		var editor:VisualEditorViewer = try cast(model.activeEditor, VisualEditorViewer) catch (e:Dynamic) null;
		if (editor != null) {
			return editor.editorView.visualEditor;
		}

		return null;
	}

	public function getCustomTooltipFunction():Function {
		return UtilsCore.createCustomToolTip;
	}

	public function getPositionTooltipFunction():Function {
		return UtilsCore.positionTip;
	}

	public function getRelativeFilePath():String {
		var editor:VisualEditorViewer = try cast(model.activeEditor, VisualEditorViewer) catch (e:Dynamic) null;
		if (editor == null) {
			return '';
		}

		return editor.currentFile.fileBridge.getRelativePath(visualEditorProject.sourceFolder, true);
	}

	private function onNewFileAdded(event:TreeMenuItemEvent):Void
	// add resource only relative to the project
	 {

		if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
		// make sure we use existing object only and not create new
		{

			var newFileWrapper:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(event.data, try cast(event.extra, FileLocation) catch (e:Dynamic) null);
			if (newFileWrapper != null) {
				visualEditorProject.filesList.addItem(new ResourceVO((try cast(event.extra, FileLocation) catch (e:Dynamic) null).name, newFileWrapper));
				sendXHtmlUpdates();
			}
		}
	}

	private function onFileRemoved(event:TreeMenuItemEvent):Void
	// remove resource only relative to the project
	 {

		if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath) {
			var pathSeparator:String = event.data.file.fileBridge.separator;
			var i:Int = 0;
			while (i < visualEditorProject.filesList.length)
			// direct == path check or
			{

				// path check if the xhtml file is children of deleted file/folder
				if (event.data.file.fileBridge.nativePath == visualEditorProject.filesList[i].sourceWrapper.file.fileBridge.nativePath) {
					visualEditorProject.filesList.removeItemAt(i);
					break;
				} else if (visualEditorProject.filesList[i].sourceWrapper.file.fileBridge.nativePath.indexOf(event.data.file.fileBridge.nativePath + pathSeparator) != -1) {
					visualEditorProject.filesList.removeItemAt(i);
					i--;
				}
				i++;
			}

			sendXHtmlUpdates();
		}
	}

	private function onFileRenamed(event:TreeMenuItemEvent):Void
	// remove resource only relative to the project
	 {

		if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath) {
			for (i /* AS3HX WARNING could not determine type for var: i exp: EField(EIdent(visualEditorProject),filesList) type: null */ in visualEditorProject.filesList) {
				if (event.data.file.fileBridge.nativePath == i.sourceWrapper.file.fileBridge.nativePath) {
					i.name = event.data.name;
					i.resourcePath = event.data.nativePath;
					break;
				}
			}
			sendXHtmlUpdates();
		}
	}

	private function sendXHtmlUpdates():Void {
		this.updateHandler(visualEditorProject.filesList);
	}

	private function handleEditorChange(event:CollectionEvent):Void {
		if (event.kind == CollectionEventKind.REMOVE && (cast((event.items[0]), AS3ProjectVO).folderPath == visualEditorProject.folderPath)) {
			model.projects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
			dispatcher.removeEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onNewFileAdded);
			dispatcher.removeEventListener(TreeMenuItemEvent.FILE_DELETED, onFileRemoved);
			dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, onFileRenamed);

			this.updateHandler = null;
		}
	}

	public function new() {}

}