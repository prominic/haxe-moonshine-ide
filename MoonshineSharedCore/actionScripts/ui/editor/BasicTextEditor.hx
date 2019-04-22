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
package actionScripts.ui.editor;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;
import mx.managers.PopUpManager;
import spark.components.Group;
import actionScripts.controllers.DataAgent;
import actionScripts.events.ChangeEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.SaveFileEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.text.DebugHighlightManager;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.vo.SearchResult;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.URLDescriptorVO;
import components.popup.FileSavePopup;
import components.popup.SelectOpenedFlexProject;
import components.views.project.TreeView;

class BasicTextEditor extends Group implements IContentWindow implements IFocusManagerComponent {

	public var defaultLabel:String = 'New';
	public var projectPath:String;
	public var editor:TextEditor;
	public var lastOpenType:String;

	private var file:FileLocation;
	private var created:Bool = false;
	private var loadingFile:Bool = false;
	private var tempScrollTo:Int = -1;
	private var loader:DataAgent;

	private var _readOnly:Bool = false;

	public var readOnly(get, never):Bool;
	private function get_readOnly():Bool {
		return this._readOnly;
	}

	private var pop:FileSavePopup;
	private var model:IDEModel = IDEModel.getInstance();

	private var selectProjectPopup:SelectOpenedFlexProject;

	private var isVisualEditor:Bool = false;

	private var _isChanged:Bool = false;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	public var label(get, never):String;
	private function get_label():String {
		var labelChangeIndicator:String = (_isChanged) ? '*' : '';
		if (file == null) {
			return labelChangeIndicator + defaultLabel;
		}

		return labelChangeIndicator + file.fileBridge.name;
	}

	public var longLabel(get, never):String;
	private function get_longLabel():String {
		if (file == null) {
			return defaultLabel;
		}
		return Std.string(file.fileBridge.nativePath);
	}

	public var currentFile(get, set):FileLocation;
	private function get_currentFile():FileLocation {
		return file;
	}

	private function set_currentFile(value:FileLocation):FileLocation {
		if (file != value) {
			file = value;

			dispatchEvent(new Event('labelChanged'));
		}
		return value;
	}

	public var text(get, set):String;
	private function get_text():String {
		return editor.dataProvider;
	}

	private function set_text(value:String):String {
		editor.dataProvider = value;
		return value;
	}

	// Search may be RegExp or String
	public function search(search:Dynamic, backwards:Bool = false):SearchResult {
		return editor.search(search, backwards);
	}

	// Search all instances and highlight
	// Preferably used in 'search in project' sequence
	public function searchAndShowAll(search:Dynamic):Void {
		editor.searchAndShowAll(search);
	}

	// Search may be RegExp or String
	public function searchReplace(search:Dynamic, replace:String, all:Bool = false):SearchResult {
		return editor.searchReplace(search, replace, all);
	}

	public function isEmpty():Bool {
		if (file == null && text == '') {
			return true;
		}
		return false;
	}

	public function isChanged():Bool {
		return _isChanged;
	}

	public function getEditorComponent():TextEditor {
		return editor;
	}

	public function new(readOnly:Bool = false) {
		super();
		_readOnly = readOnly;

		percentHeight = 100;
		percentWidth = 100;
		addEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
		initializeChildrens();
	}

	private function initializeChildrens():Void {
		editor = new TextEditor(_readOnly);
		editor.percentHeight = 100;
		editor.percentWidth = 100;
		editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
		text = '';
	}

	override public function setFocus():Void {
		if (editor != null) {
			editor.hasFocus = true;
			editor.setFocus();
		}
	}

	override private function createChildren():Void {
		if (!isVisualEditor) {
			this.addElement(editor);
		}

		super.createChildren();

		// @note
		// https://github.com/prominic/Moonshine-IDE/issues/31
		// to ensure if the file has a pending debug/breakpoint call
		// call extended from OpenFileCommand/openFile(..)
		if (currentFile != null && currentFile.fileBridge.nativePath == DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH) {
			editor.isNeedToBeTracedAfterOpening = true;
		}
	}

	private function basicTextEditorCreationCompleteHandler(e:FlexEvent):Void {
		removeEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);

		created = true;
		if (file != null) {
			callLater(open, [file]);
		}
	}

	public function scrollTo(line:Int, eventType:String = null):Void {
		if (loadingFile) {
			tempScrollTo = line;
		} else {
			editor.scrollTo(line, eventType);
			editor.selectLine(line);
		}
	}

	public function selectRangeAtLine(search:Dynamic, range:Dynamic = null):Void {
		editor.selectRangeAtLine(search, range);
	}

	public function setContent(content:String):Void {
		editor.dataProvider = content;
		updateChangeStatus();
	}

	public function open(newFile:FileLocation, fileData:Dynamic = null):Void {
		loadingFile = true;
		file = newFile;
		if (AS3.as(fileData, Bool)) {
			openFileAsStringHandler(Std.string(fileData));
			return;
		} else if (!created || !AS3.as(file.fileBridge.exists, Bool)) {
			return;
		}

		file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);

		// Load later so we have time to draw before everything happens
		callLater(file.fileBridge.load);
	}

	public function reload():Void {
		loadingFile = true;
		file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);
		callLater(file.fileBridge.load);
	}

	private function openFileAsStringHandler(data:String):Void {
		loadingFile = false;
		// Get data from file
		text = data;
		scrollToTempValue();
	}

	private function openHandler(event:Event):Void {
		loadingFile = false;
		// Get data from file
		text = Std.string(Std.string(file.fileBridge.data));

		scrollToTempValue();

		file.fileBridge.getFile.removeEventListener(Event.COMPLETE, openHandler);
	}

	public function save():Void {
		if (file == null) {
			saveAs();
			return;
		}

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && !AS3.as(file.fileBridge.exists, Bool)) {
			file.fileBridge.createFile();
			file.fileBridge.save(text);
			editor.save();
			updateChangeStatus();

			// Tell the world we've changed
			dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
			);
		} else if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			file.fileBridge.save(text);
			editor.save();
			updateChangeStatus();

			// Tell the world we've changed
			dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
			);
		} else if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name + ': Saving in process...'));
			loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault,
					{
						'path': file.fileBridge.nativePath,
						'text': text
					});
		}
	}

	private function onSaveFault(message:String):Void {
		//Alert.show("Save Fault"+message);
		dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name + ': Save error!'));
		loader = null;
	}

	private function onSaveSuccess(value:Dynamic, message:String = null):Void {
		//Alert.show("Save Fault"+message);
		loader = null;
		editor.save();
		updateChangeStatus();
		dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name + ': Saving successful.')
		);
		dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
	}

	public function saveAs(file:FileLocation = null):Void {
		if (file != null) {
			this.file = file;
			save();
			// Update labels
			dispatchEvent(new Event('labelChanged'));
			dispatcher.dispatchEvent(new RefreshTreeEvent(file));
			return;
		}

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			if (this.file != null) {
				saveAsPath(Std.string(this.file.fileBridge.parent.fileBridge.nativePath));
			} else if (model.projects.length > 1) {
				if (model.mainView.isProjectViewAdded) {
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference != null) {
						saveAsPath(projectReference.folderPath);
						return;
					}
				}
				selectProjectPopup = new SelectOpenedFlexProject();
				PopUpManager.addPopUp(selectProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			} else if (model.projects.length != 0) {
				saveAsPath((AS3.as(Reflect.getProperty(model.projects, Std.string(0)), ProjectVO)).folderPath);
			} else {
				saveAsPath(null);
			}
		} else {
			pop = new FileSavePopup();
			PopUpManager.addPopUp(pop, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
			PopUpManager.centerPopUp(pop);
		}
		var saveAsPath:String->Void = function(path:String):Void {
			model.fileCore.browseForSave(handleSaveAsSelect, null, 'Save As', path);
		}
		var onProjectSelected:Event->Void = function(event:Event):Void {
			saveAsPath((AS3.as(selectProjectPopup.selectedProject, AS3ProjectVO)).folderPath);
			onProjectSelectionCancelled(null);
		}
		var onProjectSelectionCancelled:Event->Void = function(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		}
	}

	public function onFileSaveSuccess(file:FileLocation = null):Void {
		//saveAs(file);
		this.file = file;
		dispatchEvent(new Event('labelChanged'));
		editor.save();
		updateChangeStatus();
		dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
	}

	private function handleTextChange(event:ChangeEvent):Void {
		if (editor.hasChanged != _isChanged) {
			updateChangeStatus();
		}
	}

	private function updateChangeStatus():Void {
		_isChanged = editor.hasChanged;
		dispatchEvent(new Event('labelChanged'));
	}

	private function handleSaveAsSelect(fileObj:Dynamic):Void {
		saveAs(new FileLocation(AS3.string(Reflect.field(fileObj, 'nativePath'))));
	}

	private function scrollToTempValue():Void {
		if (tempScrollTo > 0) {
			scrollTo(tempScrollTo, lastOpenType);
			tempScrollTo = -1;
		}
	}

}