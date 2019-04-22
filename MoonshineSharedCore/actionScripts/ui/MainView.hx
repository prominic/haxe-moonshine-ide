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
package actionScripts.ui;

import flash.display.DisplayObject;
import mx.binding.utils.BindingUtils;
import mx.containers.VBox;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.locator.IDEModel;
import actionScripts.ui.divider.IDEHDividedBox;
import actionScripts.ui.divider.IDEVDividedBox;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.ui.tabview.TabEvent;
import actionScripts.ui.tabview.TabView;
import actionScripts.valueObjects.ConstantsCoreVO;
import components.views.project.TreeView;
import components.views.splashscreen.SplashScreen;

// TODO: Make this an all-in-one flexible layout thing
class MainView extends VBox {

	public var isProjectViewAdded:Bool = false;
	public var bodyPanel:IDEVDividedBox;
	public var mainPanel:IDEHDividedBox;
	public var sidebar:IDEVDividedBox;

	private var _mainContent:TabView;
	private var model:IDEModel;
	private var childIndex:Int = 0;

	public function new() {
		super();

		setStyle('backgroundAlpha', 0);
		model = IDEModel.getInstance();
		model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
		BindingUtils.bindSetter(activeEditorChanged, model, 'activeEditor');
	}

	public var mainContent(get, never):TabView;
	private function get_mainContent():TabView {
		return _mainContent;
	}

	override private function createChildren():Void {
		super.createChildren();

		setStyle('verticalGap', 0);

		bodyPanel = new IDEVDividedBox();
		bodyPanel.percentHeight = 100;
		bodyPanel.percentWidth = 100;
		bodyPanel.setStyle('backgroundColor', 0x424242);
		bodyPanel.setStyle('dividerThickness', 7);
		bodyPanel.setStyle('dividerAffordance', 4);
		bodyPanel.setStyle('verticalGap', 7);
		addChild(bodyPanel);

		mainPanel = new IDEHDividedBox();
		mainPanel.percentWidth = 100;
		mainPanel.percentHeight = 100;
		mainPanel.setStyle('dividerThickness', 2);
		mainPanel.setStyle('dividerAffordance', 2);
		mainPanel.setStyle('horizontalGap', 2);
		bodyPanel.addChild(mainPanel);

		_mainContent = new TabView();
		_mainContent.styleName = 'tabNav';
		_mainContent.percentWidth = 100;
		_mainContent.percentHeight = 100;
		_mainContent.addEventListener(TabEvent.EVENT_TAB_CLOSE, handleTabClose);
		_mainContent.addEventListener(TabEvent.EVENT_TAB_SELECT, focusNewEditor);

		mainPanel.addChild(_mainContent);

		sidebar = new IDEVDividedBox();
		sidebar.verticalScrollPolicy = 'off';
		sidebar.percentHeight = 100;
		sidebar.width = 300;
		sidebar.setStyle('backgroundColor', 0xCFCFCF);
		sidebar.setStyle('dividerThickness', 2);
		sidebar.setStyle('dividerAffordance', 2);
		sidebar.setStyle('verticalGap', 2);
	}

	private function handleEditorChange(event:CollectionEvent):Void {
		switch (event.kind) {
			case CollectionEventKind.REMOVE:
				var editor:DisplayObject = AS3.as(Reflect.getProperty(event.items, Std.string(0)), DisplayObject);
				if (ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(IContentWindow(editor).label) == -1) {
					_mainContent.removeChild(editor);
				}
			case CollectionEventKind.ADD:
				editor = AS3.as(model.editors.getItemAt(event.location), DisplayObject);
				mainContent.addChild(editor);
				mainContent.selectedIndex = _mainContent.getChildIndex(editor);
				model.activeEditor = AS3.as(editor, IContentWindow);
		}
	}

	private function focusNewEditor(event:TabEvent):Void {
		if (Std.is(event.child, IContentWindow)) {
			model.activeEditor = AS3.as(event.child, IContentWindow);
		}

		if (event.type == TabEvent.EVENT_TAB_SELECT) {
			var e:TabEvent = new TabEvent(TabEvent.EVENT_TAB_SELECT, event.child);
			GlobalEventDispatcher.getInstance().dispatchEvent(e);
		}
	}

	private function activeEditorChanged(newActiveEditor:IContentWindow):Void {
		if (mainContent == null) {
			return;
		}

		mainContent.setSelectedTab(AS3.as(model.activeEditor, DisplayObject));
	}

	public function handleTabClose(event:TabEvent):Void {
		// We handle this by ourselves.
		event.preventDefault();

		var e:CloseTabEvent = new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.child);
		GlobalEventDispatcher.getInstance().dispatchEvent(e);
	}

	public function addPanel(panel:IPanelWindow):Void {
		if (panel.document.className == 'TreeView') {
			childIndex = 0;
		} else {
			childIndex = AS3.int(mainPanel.numChildren - 1);
		}

		if (!AS3.as(sidebar.stage, Bool)) {
			mainPanel.addChildAt(sidebar, childIndex);
		}
		sidebar.addChild(AS3.as(panel, DisplayObject));
		isProjectViewAdded = true;
	}

	public function getTreeViewPanel():TreeView {
		if (isProjectViewAdded) {
			for (i in 0...sidebar.numElements) {
				if (Std.is(sidebar.getElementAt(i), TreeView)) {
					return (AS3.as(sidebar.getElementAt(i), TreeView));
				}
			}
		}

		return null;
	}

}