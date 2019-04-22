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
package actionScripts.plugin.rename;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.DuplicateEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.LanguageServerEvent;
import actionScripts.events.NewFileEvent;
import actionScripts.events.RenameEvent;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.plugin.rename.view.RenameView;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.utils.CustomTree;
import actionScripts.utils.TextUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;
import components.popup.RenamePopup;
import components.popup.newFile.NewFilePopup;

class RenamePlugin extends PluginBase {

	private var renameView:RenameView = new RenameView();
	private var newFilePopup:NewFilePopup;
	private var renameFileView:RenamePopup;

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Rename Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Rename a symbol in a project.';
	}

	private var _line:Int = 0;
	private var _startChar:Int = 0;
	private var _endChar:Int = 0;
	private var _existingFilePath:String;

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
		dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
		dispatcher.addEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
		dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
		dispatcher.removeEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
	}

	private function handleOpenRenameView(event:Event):Void {
		var editor:LanguageServerTextEditor = AS3.as(model.activeEditor, LanguageServerTextEditor);
		if (editor == null) {
			return;
		}
		var lineText:String = editor.editor.model.selectedLine.text;
		var caretIndex:Int = editor.editor.model.caretIndex;
		this._startChar = TextUtil.startOfWord(lineText, caretIndex);
		this._endChar = TextUtil.endOfWord(lineText, caretIndex);
		this._line = editor.editor.model.selectedLineIndex;
		renameView.oldName = editor.editor.model.selectedLine.text.substr(this._startChar, this._endChar - this._startChar);
		renameView.addEventListener(CloseEvent.CLOSE, renameView_closeHandler);
		PopUpManager.addPopUp(renameView, DisplayObject(editor.parentApplication), true);
		PopUpManager.centerPopUp(renameView);
	}

	private function renameView_closeHandler(event:CloseEvent):Void {
		renameView.removeEventListener(CloseEvent.CLOSE, renameView_closeHandler);
		if (event.detail != Alert.OK) {
			return;
		}

		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_RENAME,
				this._startChar, this._line, this._endChar, this._line, renameView.newName));
	}

	private function handleOpenRenameFileView(event:RenameEvent):Void {
		if (!AS3.as((AS3.as(event.changes, FileWrapper)).file.fileBridge.checkFileExistenceAndReport(), Bool)) {
			return;
		}

		if (renameFileView == null) {
			renameFileView = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), RenamePopup, true), RenamePopup);
			renameFileView.addEventListener(CloseEvent.CLOSE, handleRenamePopupClose);
			renameFileView.addEventListener(NewFileEvent.EVENT_FILE_RENAMED, onFileRenamedRequest);
			renameFileView.wrapperOfFolderLocation = AS3.as(event.changes, FileWrapper);

			PopUpManager.centerPopUp(renameFileView);
		}
	}

	private function handleRenamePopupClose(event:CloseEvent):Void {
		renameFileView.removeEventListener(CloseEvent.CLOSE, handleRenamePopupClose);
		renameFileView.removeEventListener(NewFileEvent.EVENT_FILE_RENAMED, onFileRenamedRequest);
		renameFileView = null;
	}

	private function onFileRenamedRequest(event:NewFileEvent):Void {
		var newFile:FileLocation = event.insideLocation.file.fileBridge.parent.resolvePath(event.fileName);
		_existingFilePath = event.insideLocation.nativePath;

		event.insideLocation.file.fileBridge.moveTo(newFile, false);
		event.insideLocation.file = newFile;

		// we need to update file location of the (if any) opened instance
		// of the file template
		if (AS3.as(newFile.fileBridge.isDirectory, Bool)) {
			updateChildrenPath(event.insideLocation, _existingFilePath + newFile.fileBridge.separator, Std.string(newFile.fileBridge.nativePath + newFile.fileBridge.separator));
		} else {
			checkAndUpdateOpenedTabs(_existingFilePath, newFile);
		}

		// updating the tree view
		var tree:CustomTree = model.mainView.getTreeViewPanel().tree;
		var tmpParent:FileWrapper = tree.getParentItem(event.insideLocation);

		var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
					var tmpFileW:FileWrapper = UtilsCore.findFileWrapperAgainstProject(event.insideLocation, null, tmpParent);
					tree.selectedItem = tmpFileW;

					var indexToItemRenderer:Int = AS3.int(tree.getItemIndex(tmpFileW));
					tree.callLater(tree.scrollToIndex, [indexToItemRenderer]);

					dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.FILE_RENAMED, null, event.insideLocation));
					as3hx.Compat.clearTimeout(timeoutValue);
				}, 300);
	}

	private function handleOpenDuplicateFileView(event:DuplicateEvent):Void {
		if (!AS3.as(event.fileWrapper.file.fileBridge.checkFileExistenceAndReport(), Bool)) {
			return;
		}

		if (newFilePopup == null) {
			newFilePopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), NewFilePopup, true), NewFilePopup);
			newFilePopup.addEventListener(CloseEvent.CLOSE, handleFilePopupClose);
			newFilePopup.addEventListener(DuplicateEvent.EVENT_APPLY_DUPLICATE, onFileDuplicateRequest);
			newFilePopup.openType = NewFilePopup.AS_DUPLICATE_FILE;
			newFilePopup.folderFileLocation = event.fileWrapper.file;

			var creatingItemIn:FileWrapper = FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(event.fileWrapper));
			newFilePopup.wrapperOfFolderLocation = creatingItemIn;
			newFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);

			PopUpManager.centerPopUp(newFilePopup);
		}
	}

	private function handleFilePopupClose(event:CloseEvent):Void {
		newFilePopup.removeEventListener(CloseEvent.CLOSE, handleFilePopupClose);
		newFilePopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onFileDuplicateRequest);
		newFilePopup = null;
	}

	private function onFileDuplicateRequest(event:DuplicateEvent):Void {
		var fileToSave:FileLocation = event.fileWrapper.file.fileBridge.resolvePath(event.fileName + '.' + event.fileLocation.fileBridge.extension);

		// based on request, we also updates class name and package path
		// to the duplicated file, in case of actionScript class
		if (event.fileLocation.fileBridge.extension == 'as') {
			var updatedContent:String = getUpdatedFileContent(event.fileWrapper, event.fileLocation, event.fileName);
			fileToSave.fileBridge.save(updatedContent);
		} else {
			event.fileLocation.fileBridge.copyTo(fileToSave, true);
		}

		// opens the file after writing done
		/*dispatcher.dispatchEvent(
			new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave, -1, event.insideLocation)
		);*/

		// notify the tree view if it needs to refresh
		// the containing folder to make newly created file show
		if (event.fileWrapper != null) {
			dispatcher.dispatchEvent(
					new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, Std.string(fileToSave.fileBridge.nativePath), event.fileWrapper)
			);
		}
	}

	private function getUpdatedFileContent(projectRef:FileWrapper, source:FileLocation, newFileName:String):String {
		var sourceContentLines:Array<String> = Std.string(source.fileBridge.read()).split('\n');
		var classNameStartIndex:Int;

		var nameOnly:Array<Dynamic> = source.fileBridge.name.split('.');
		nameOnly.pop();
		var sourceFileName:String = nameOnly.join('.');

		var isPackageFound:Bool;
		var isClassDecFound:Bool;
		var isConstructorFound:Bool;

		sourceContentLines = sourceContentLines.map(function(line:String, index:Int, arr:Array<Dynamic>):String {
							if (!isPackageFound && line.indexOf('package') != -1) {
								isPackageFound = true;

								var project:AS3ProjectVO = AS3.as(UtilsCore.getProjectFromProjectFolder(projectRef), AS3ProjectVO);
								var isInsideSourceDirectory:Bool = source.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + source.fileBridge.separator) != -1;

								// do not update package path if not inside source directory
								if (isInsideSourceDirectory) {
									var tmpPackagePath:String = UtilsCore.getPackageReferenceByProjectPath([project.sourceFolder], projectRef.nativePath, null, null, false);
									if (tmpPackagePath.charAt(0) == '.') {
										tmpPackagePath = tmpPackagePath.substr(1, tmpPackagePath.length);
									}

									return 'package ' + tmpPackagePath;
								}
							}

							classNameStartIndex = line.indexOf(' class ' + sourceFileName);
							if (!isClassDecFound && classNameStartIndex != -1) {
								isClassDecFound = true;
								return line.substr(0, classNameStartIndex + 7) + newFileName + line.substr(classNameStartIndex + 7 + sourceFileName.length, line.length);
							}

							classNameStartIndex = line.indexOf(' function ' + sourceFileName + '(');
							if (!isConstructorFound && classNameStartIndex != -1) {
								isConstructorFound = true;
								return line.substr(0, classNameStartIndex + 10) + newFileName + line.substr(classNameStartIndex + 10 + sourceFileName.length, line.length);
							}

							return line;
						});

		return sourceContentLines.join('\n');
	}

	private function updateChildrenPath(fw:FileWrapper, oldPath:String, newPath:String):Void {
		for (i_ in fw.children) {
			var i:FileWrapper = cast i_;
			_existingFilePath = AS3.string(Reflect.field(Reflect.field(Reflect.field(i, 'file'), 'fileBridge'), 'nativePath'));
			Reflect.setField(i, 'file', new FileLocation(Std.string(Reflect.field(Reflect.field(Reflect.field(i, 'file'), 'fileBridge'), 'nativePath').replace(oldPath, newPath))));
			if (!AS3.as(Reflect.field(i, 'children'), Bool)) {
				checkAndUpdateOpenedTabs(_existingFilePath, Reflect.field(i, 'file'));
			} else {
				updateChildrenPath(i, oldPath, newPath);
			}
		}
	}

	private function checkAndUpdateOpenedTabs(oldPath:String, newFile:FileLocation):Void {
		// updates to tab
		for (tab in model.editors) {
			var ed:BasicTextEditor = AS3.as(tab, BasicTextEditor);
			if (ed != null
				&& ed.currentFile != null
				&& ed.currentFile.fileBridge.nativePath == oldPath) {
				ed.currentFile = newFile;
				break;
			}
		}

		// updates entry in recent files list
		for (i in model.recentlyOpenedFiles) {
			if (Reflect.field(i, 'path') == oldPath) {
				Reflect.setField(i, 'path', newFile.fileBridge.nativePath);
				Reflect.setField(i, 'name', newFile.name);
				GlobalEventDispatcher.getInstance().dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
				break;
			}
		}
	}

}