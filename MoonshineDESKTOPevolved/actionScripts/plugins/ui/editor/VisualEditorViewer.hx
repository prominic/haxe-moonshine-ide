////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ui.editor;

import actionScripts.events.PreviewPluginEvent;
import actionScripts.factory.FileLocation;
import actionScripts.utils.MavenPomUtil;
import flash.events.Event;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import actionScripts.events.AddTabEvent;
import actionScripts.events.ChangeEvent;
import actionScripts.impls.IVisualEditorLibraryBridgeImp;
import actionScripts.interfaces.IVisualEditorViewer;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugins.help.view.VisualEditorView;
import actionScripts.plugins.help.view.events.VisualEditorEvent;
import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
import actionScripts.plugins.ui.editor.text.UndoManagerVisualEditor;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.ui.tabview.TabEvent;
import view.suportClasses.events.PropertyEditorChangeEvent;

class VisualEditorViewer extends BasicTextEditor implements IVisualEditorViewer {

	private static inline var EVENT_SWITCH_TAB_TO_CODE:String = 'switchTabToCode';

	private var visualEditorView:VisualEditorView;
	private var hasChangedProperties:Bool = false;

	private var visualEditorProject:AS3ProjectVO;
	private var visualEditoryLibraryCore:IVisualEditorLibraryBridgeImp;
	private var undoManager:UndoManagerVisualEditor;

	public var editorView(get, never):VisualEditorView;
	private function get_editorView():VisualEditorView {
		return visualEditorView;
	}

	public function new(visualEditorProject:AS3ProjectVO = null) {
		this.visualEditorProject = visualEditorProject;

		super();
	}

	override private function initializeChildrens():Void {
		isVisualEditor = true;

		// at this moment prifefaces projects only using the bridge
		// this condition can be remove if requires
		if (AS3.as(visualEditorProject.isPrimeFacesVisualEditorProject, Bool)) {
			visualEditoryLibraryCore = new IVisualEditorLibraryBridgeImp();
			visualEditoryLibraryCore.visualEditorProject = visualEditorProject;
		}

		visualEditorView = new VisualEditorView();

		(AS3.as(visualEditorProject.isPrimeFacesVisualEditorProject, Bool)) ?
		visualEditorView.currentState = 'primeFacesVisualEditor' :
		visualEditorView.currentState = 'flexVisualEditor';
		visualEditorView.visualEditorProject = visualEditorProject;

		visualEditorView.percentWidth = 100;
		visualEditorView.percentHeight = 100;
		visualEditorView.addEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
		visualEditorView.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);

		undoManager = new UndoManagerVisualEditor(visualEditorView);

		editor = new TextEditor(true);
		editor.percentHeight = 100;
		editor.percentWidth = 100;
		editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
		editor.dataProvider = '';

		visualEditorView.codeEditor = editor;

		dispatcher.addEventListener(AddTabEvent.EVENT_ADD_TAB, addTabHandler);
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
		dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		dispatcher.addEventListener(VisualEditorEvent.DUPLICATE_ELEMENT, duplicateSelectedElementHandler);
		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_COMPLETE, previewStartCompleteHandler);
		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STOPPED, previewStoppedHandler);
		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_FAILED, previewStartFailedHandler);
		dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STARTING, previewStartingHandler);

		model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
	}

	private function handleEditorCollectionChange(event:CollectionEvent):Void {
		if (event.kind == CollectionEventKind.REMOVE && Reflect.getProperty(event.items, Std.string(0)) == this) {
			visualEditorView.removeEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
			visualEditorView.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);

			if (visualEditorView.visualEditor != null) {
				visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
				visualEditorView.visualEditor.editingSurface.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_ADDING, onEditingSurfaceItemAdded);
				visualEditorView.visualEditor.componentsOrganizer.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_MOVED, onPropertyEditorChanged);
				visualEditorView.visualEditor.propertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
				visualEditorView.visualEditor.propertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_DELETING, onPropertyEditorChanged);
				visualEditorView.visualEditor.removeEventListener('saveCode', onVisualEditorSaveCode);
			}

			dispatcher.removeEventListener(AddTabEvent.EVENT_ADD_TAB, addTabHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.removeEventListener(VisualEditorEvent.DUPLICATE_ELEMENT, duplicateSelectedElementHandler);
			dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_START_COMPLETE, previewStartCompleteHandler);
			dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_STOPPED, previewStoppedHandler);
			dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_START_FAILED, previewStartFailedHandler);
			dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_STARTING, previewStartingHandler);
			dispatcher.removeEventListener(EVENT_SWITCH_TAB_TO_CODE, switchTabToCodeHandler);

			model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
			undoManager.dispose();
		}
	}

	private function onVisualEditorCreationComplete(event:FlexEvent):Void {
		visualEditorView.removeEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);

		visualEditorView.visualEditor.editingSurface.addEventListener(Event.CHANGE, onEditingSurfaceChange);
		visualEditorView.visualEditor.editingSurface.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_ADDING, onEditingSurfaceItemAdded);
		visualEditorView.visualEditor.componentsOrganizer.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_MOVED, onPropertyEditorChanged);
		visualEditorView.visualEditor.propertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
		visualEditorView.visualEditor.propertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_DELETING, onPropertyEditorChanged);
		visualEditorView.visualEditor.addEventListener('saveCode', onVisualEditorSaveCode);
		visualEditorView.addEventListener('startPreview', onStartPreview);

		visualEditorView.visualEditor.moonshineBridge = visualEditoryLibraryCore;
		visualEditorView.visualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;

		dispatcher.addEventListener(EVENT_SWITCH_TAB_TO_CODE, switchTabToCodeHandler);
	}

	private function previewStartCompleteHandler(event:PreviewPluginEvent):Void {
		visualEditorView.currentState = 'primeFacesVisualEditor';
	}

	private function previewStartingHandler(event:PreviewPluginEvent):Void {
		visualEditorView.currentState = 'primeFacesPreviewStarting';
	}

	private function previewStoppedHandler(event:PreviewPluginEvent):Void {
		visualEditorView.currentState = 'primeFacesVisualEditor';
	}

	private function previewStartFailedHandler(event:PreviewPluginEvent):Void {
		visualEditorView.currentState = 'primeFacesVisualEditor';
	}

	private function onVisualEditorSaveCode(event:Event):Void {
		_isChanged = true;
		this.save();
	}

	private function switchTabToCodeHandler(event:Event):Void {
		visualEditorView.viewStack.selectedIndex = 1;
	}

	private function duplicateSelectedElementHandler(event:Event):Void {
		visualEditorView.visualEditor.duplicateSelectedElement();
	}

	override private function createChildren():Void {
		addElement(visualEditorView);

		super.createChildren();
	}

	override public function save():Void {
		visualEditorView.visualEditor.saveEditedFile();
		editor.dataProvider = getMxmlCode();
		hasChangedProperties = false;

		super.save();

		refreshFileForPreview();
	}

	private function refreshFileForPreview():Void {
		if (AS3.as(visualEditorProject.isPrimeFacesVisualEditorProject, Bool)) {
			var separator:String = Std.string(file.fileBridge.separator);
			var mavenBuildPath:String = Std.string(visualEditorProject.mavenBuildOptions.mavenBuildPath);
			var mavenPomPath:String = Std.string(mavenBuildPath.concat(separator, 'pom.xml'));
			var targetPath:String = Std.string(mavenBuildPath.concat(separator, 'target'));

			var pomLocation:FileLocation = new FileLocation(mavenPomPath);
			var targetLocation:FileLocation = new FileLocation(targetPath);

			if (AS3.as(pomLocation.fileBridge.exists, Bool) && AS3.as(targetLocation.fileBridge.exists, Bool)) {
				var projectName:String = Std.string(MavenPomUtil.getProjectId(pomLocation));
				var projectVersion:String = Std.string(MavenPomUtil.getProjectVersion(pomLocation));
				var destinationFolderLocation:FileLocation = new FileLocation(targetPath.concat(separator, projectName, '-', projectVersion));
				if (AS3.as(destinationFolderLocation.fileBridge.exists, Bool)) {
					var srcFolderLocation:FileLocation = visualEditorProject.sourceFolder;
					var relativePath:String = Std.string(currentFile.fileBridge.nativePath.replace(srcFolderLocation.fileBridge.nativePath, ''));
					var destinationFilePath:String = Std.string(destinationFolderLocation.fileBridge.nativePath.concat(relativePath));
					var destinationFile:FileLocation = destinationFolderLocation.resolvePath(destinationFilePath);

					currentFile.fileBridge.copyTo(destinationFile, true);
				}
			}
		}
	}

	override private function openHandler(event:Event):Void {
		super.openHandler(event);

		createVisualEditorFile();
	}

	override private function updateChangeStatus():Void {
		if (hasChangedProperties) {
			_isChanged = true;
		} else {
			_isChanged = editor.hasChanged;
			if (_isChanged == null) {
				_isChanged = visualEditorView.visualEditor.editingSurface.hasChanged;
			}
		}

		dispatchEvent(new Event('labelChanged'));
	}

	private function onEditingSurfaceChange(event:Event):Void {
		updateChangeStatus();
	}

	private function onPropertyEditorChanged(event:PropertyEditorChangeEvent):Void {
		undoManager.handleChange(event);

		hasChangedProperties = _isChanged != null = true;
		dispatchEvent(new Event('labelChanged'));
	}

	private function onEditingSurfaceItemAdded(event:PropertyEditorChangeEvent):Void {
		undoManager.handleChange(event);
	}

	private function onVisualEditorViewCodeChange(event:VisualEditorViewChangeEvent):Void {
		editor.dataProvider = getMxmlCode();

		updateChangeStatus();
	}

	private function addTabHandler(event:Event):Void {
		if (visualEditorView.visualEditor == null) {
			return;
		}

		visualEditorView.visualEditor.editingSurface.selectedItem = null;
	}

	private function closeTabHandler(event:Event):Void {
		if (visualEditorView.visualEditor == null) {
			return;
		}

		if (Std.is(event, CloseTabEvent)) {
			var tmpEvent:CloseTabEvent = AS3.as(event, CloseTabEvent);
			if (AS3.as(AS3.hasOwnProperty(tmpEvent.tab, 'editor'), Bool) && Reflect.getProperty(tmpEvent.tab, 'editor') == this.editor) {
				visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
				visualEditorView.visualEditor.propertyEditor.removeEventListener('propertyEditorChanged', onPropertyEditorChanged);
				visualEditorView.visualEditor.editingSurface.selectedItem = null;
			}
		}
	}

	private function tabSelectHandler(event:TabEvent):Void {
		if (visualEditorView.visualEditor == null) {
			return;
		}

		if (!AS3.as(AS3.hasOwnProperty(event.child, 'editor'), Bool) || Reflect.getProperty(event.child, 'editor') != this.editor) {
			visualEditorView.visualEditor.editingSurface.selectedItem = null;
		} else {
			visualEditorView.setFocus();
			visualEditorView.visualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
			visualEditorView.visualEditor.moonshineBridge = visualEditoryLibraryCore;
		}
	}

	private function onStartPreview(event:Event):Void {
		if (visualEditorView.currentState == 'primeFacesVisualEditor') {
			dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, file, visualEditorProject));
		}
	}

	private function getMxmlCode():String {
		var mxmlCode:FastXML = visualEditorView.visualEditor.editingSurface.toCode();
		var markAsXml:String = '<?xml version="1.0" encoding="utf-8"?>\n';

		return markAsXml + mxmlCode.node.toXMLString();
	}

	private function createVisualEditorFile():Void {
		var veFilePath:String = getVisualEditorFilePath();
		if (veFilePath != null) {
			visualEditorView.visualEditor.loadFile(veFilePath);
		}
	}

	private function getVisualEditorFilePath():String {
		if (AS3.as(visualEditorProject.visualEditorSourceFolder, Bool)) {
			var filePath:String = Std.string(file.fileBridge.nativePath.replace(visualEditorProject.sourceFolder.fileBridge.nativePath,
									visualEditorProject.visualEditorSourceFolder.fileBridge.nativePath
					).replace(new as3hx.Compat.Regex('.mxml$|.xhtml$', ''), '.xml'));

			return filePath;
		}

		return null;
	}

}