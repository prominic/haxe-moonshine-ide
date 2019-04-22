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
package actionScripts.ui.tabview;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Matrix;
import mx.containers.Canvas;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import spark.events.IndexChangeEvent;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.HamburgerMenuTabsVO;

/*
    TODO:
        Make it clearer what selectedIndex means
        Use skins instead of drawing in TabViewTab
*/
class TabView extends Canvas {

	private var tabContainer:Canvas;
	private var itemContainer:Canvas;
	private var shadow:UIComponent;

	private var hamburgerMenuTabs:HamburgerMenuTabs;
	private var _model:TabsModel;

	private var tabLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();// child:tab

	private var tabSizeDefault:Int = 200;
	private var tabSizeMin:Int = 100;

	private var needsTabLayout:Bool = false;
	private var needsNewSelectedTab:Bool = false;

	private var _selectedIndex:Int = 0;

	public var selectedIndex(get, set):Int;
	private function get_selectedIndex():Int {
		return _selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (itemContainer.numChildren == 0) {
			return value;
		}
		if (value < 0) {
			value = 0;
		}
		_selectedIndex = value;

		// Explicitly set new, so no automagic needed.
		needsNewSelectedTab = false;

		// Select correct tab
		var i:Int = 0;

		while (i < tabContainer.numChildren) {
			if (i == value) {
				TabViewTab(tabContainer.getChildAt(i)).selected = true;
			} else {
				TabViewTab(tabContainer.getChildAt(i)).selected = false;
			}
			i++;
		}

		var itemToDisplay:DisplayObject = AS3.as(TabViewTab(tabContainer.getChildAt(value)).data, DisplayObject);

		// Display or hide content
		for (i in 0...itemContainer.numChildren) {
			var child:DisplayObject = itemContainer.getChildAt(i);
			if (child == itemToDisplay) {
				child.visible = true;
				UIComponent(child).setFocus();
				dispatchEvent(new TabEvent(TabEvent.EVENT_TAB_SELECT, child));
			} else {
				child.visible = false;
			}
		}

		invalidateLayoutTabs();
		return value;
	}

	public var model(get, never):TabsModel;
	private function get_model():TabsModel {
		return _model;
	}

	public function new() {
		super();

		_model = new TabsModel();
		addEventListener(ResizeEvent.RESIZE, handleResize);
	}

	public function setSelectedTab(editor:DisplayObject):Void {
		var childIndex:Int = getChildIndex(editor);
		if (childIndex != selectedIndex && childIndex > -1) {
			selectedIndex = childIndex;
		} else {
			var hamburgerMenuCount:Int = AS3.int(_model.hamburgerTabs.length);
			for (i in 0...hamburgerMenuCount) {
				var hamburgerMenuTabsVO:HamburgerMenuTabsVO = AS3.as(_model.hamburgerTabs.getItemAt(i), HamburgerMenuTabsVO);
				if (hamburgerMenuTabsVO.tabData == editor) {
					addTabFromHamburgerMenu(hamburgerMenuTabsVO);
					break;
				}
			}
		}
	}

	private function handleResize(event:Event):Void {
		invalidateLayoutTabs();
	}

	override private function createChildren():Void {
		super.createChildren();

		tabContainer = new Canvas();
		tabContainer.styleName = 'tabView';
		tabContainer.horizontalScrollPolicy = 'off';
		tabContainer.height = 25;
		tabContainer.percentWidth = 100;
		super.addChild(tabContainer);

		itemContainer = new Canvas();
		itemContainer.percentWidth = 100;
		itemContainer.percentHeight = 100;
		itemContainer.y = 25;
		super.addChild(itemContainer);

		shadow = new UIComponent();
		shadow.percentWidth = 200;
		shadow.height = 25;
		shadow.mouseEnabled = false;
		super.addChild(shadow);

		hamburgerMenuTabs = new HamburgerMenuTabs();
		hamburgerMenuTabs.right = 0;
		hamburgerMenuTabs.top = 0;
		hamburgerMenuTabs.visible = hamburgerMenuTabs.includeInLayout = false;
		hamburgerMenuTabs.model = _model;
		hamburgerMenuTabs.addEventListener(Event.CHANGE, onHamburgerMenuTabsChange);

		super.addChild(hamburgerMenuTabs);
	}

	private function addTabFor(child:DisplayObject):Void {
		var tab:TabViewTab = new TabViewTab();
		tab.data = child;
		tabLookup.set(child, tab);
		if (AS3.as(AS3.hasOwnProperty(child, 'label'), Bool)) {
			tab.label = Std.string(Reflect.getProperty(child, 'label'));
			child.addEventListener('labelChanged', updateTabLabel);
		}
		tabContainer.addChildAt(tab, 0);

		tab.addEventListener(TabViewTab.EVENT_TAB_CLICK, onTabClick);
		tab.addEventListener(TabViewTab.EVENT_TAB_CLOSE, onTabClose);
		tab.addEventListener(TabViewTab.EVENT_TABP_CLOSE_ALL, onTabCloseAll);

		invalidateLayoutTabs();
	}

	private function removeTabFor(child:DisplayObject):Void {
		var tab:DisplayObject = tabLookup.get(child);

		tabLookup.remove(child);
		tab.parent.removeChild(tab);

		child.removeEventListener('labelChanged', updateTabLabel);
		invalidateLayoutTabs();
	}

	private function onTabClose(event:Event):Void {
		var child:DisplayObject = AS3.as(TabViewTab(event.target).data, DisplayObject);

		var te:TabEvent = new TabEvent(TabEvent.EVENT_TAB_CLOSE, child);
		dispatchEvent(te);
		if (te.isDefaultPrevented()) {
			return;
		}

		removeChild(child);

		invalidateLayoutTabs();
	}

	private function onTabCloseAll(event:Event):Void {
		removeTabsFromCache();
		UtilsCore.closeAllRelativeEditors(null);
	}

	private function updateTabLabel(event:Event):Void {
		var child:DisplayObject = AS3.as(event.target, DisplayObject);
		var tab:TabViewTab = tabLookup.get(child);

		tab.label = Std.string(Reflect.getProperty(child, 'label'));
	}

	private function onTabClick(event:Event):Void {
		if (Reflect.field(event.target, 'parent') == tabContainer) {
			selectedIndex = AS3.int(tabContainer.getChildIndex(AS3.as(event.target, DisplayObject)));
		} else {
			var tab:TabViewTab = AS3.as(event.target, TabViewTab);
			tabContainer.addChild(tab);
			tab.selected = true;
			selectedIndex = AS3.int(tabContainer.numChildren - 1);
		}
	}

	private function onHamburgerMenuTabsChange(event:IndexChangeEvent):Void {
		addTabFromHamburgerMenu(AS3.as(hamburgerMenuTabs.selectedItem, HamburgerMenuTabsVO));
	}

	private function isNonCloseableChild(child:DisplayObject):Bool {
		return AS3.as(AS3.hasOwnProperty(child, 'label'), Bool) && ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(Reflect.getProperty(child, 'label')) != -1;
	}

	override public function getChildIndex(child:DisplayObject):Int {
		var tab:DisplayObject = tabLookup.get(child);
		if (tab != null && tab.parent == tabContainer) {
			return AS3.int(tabContainer.getChildIndex(tab));
		}

		return -1;
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		addTabFor(child);
		var editor:DisplayObject = itemContainer.addChild(child);
		selectedIndex = 0;

		return editor;
	}

	public function addChildTab(child:DisplayObject):DisplayObject {
		addTabFor(child);
		return itemContainer.addChildAt(child, 0);
	}

	override public function removeChildAt(index:Int):DisplayObject {
		invalidateTabSelection();

		removeTabFor(itemContainer.getChildAt(index));
		return itemContainer.removeChildAt(index);
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		invalidateTabSelection();

		var tab:TabViewTab = tabLookup.get(child);

		if (tab != null) {
			removeTabFor(child);
			return itemContainer.removeChild(child);
		}

		return null;
	}

	public function removeTabsFromCache():Void {
		var numTabs:Int = AS3.int(tabContainer.numChildren);
		var i:Int = numTabs - 2;
		while (i > -1) {
			var tab:TabViewTab = AS3.as(tabContainer.getChildAt(i), TabViewTab);
			removeTabFromCache(AS3.as(tab.data, BasicTextEditor));
			i--;
		}

		for (item in model.hamburgerTabs) {
			if (Std.is(Reflect.field(item, 'tabData'), BasicTextEditor)) {
				removeTabFromCache(AS3.as(Reflect.field(item, 'tabData'), BasicTextEditor));
			}
		}
	}

	private function addTabFromHamburgerMenu(hamburgerMenuTabsVO:HamburgerMenuTabsVO):Void {
		_model.hamburgerTabs.removeItem(hamburgerMenuTabsVO);

		// in case of non-closeable tabs, add only its tabViewTab considering
		// its view never removed in previous step (updateTabLayout())
		if (isNonCloseableChild(hamburgerMenuTabsVO.tabData)) {
			addTabFor(hamburgerMenuTabsVO.tabData);
			selectedIndex = 0;
		} else {
			addChild(hamburgerMenuTabsVO.tabData);
		}
	}

	private function focusNewTab():Void {
		if (selectedIndex - 1 < tabContainer.numChildren) {
			selectedIndex = AS3.int(_selectedIndex - 1);
		} else {
			selectedIndex = 0;
		}
	}

	private function updateTabLayout():Void {
		// Each item draws vertical separators on both sides, overlap by 1 px to not have duplicate lines.
		var availableWidth:Int = width - hamburgerMenuTabs.width;

		var tab:TabViewTab = null;
		var i:Int;
		var numTabs:Int = AS3.int(tabContainer.numChildren);
		hamburgerMenuTabs.visible = hamburgerMenuTabs.includeInLayout = isHamburgerMenuWithTabsVisible();

		if (!canAllTabsFitIntoAvailableSpace()) {
			i = AS3.int(numTabs - 2);
			while (i > -1) {
				tab = AS3.as(tabContainer.getChildAt(i), TabViewTab);
				var tabData:DisplayObject = AS3.as(tab.data, DisplayObject);
				if (!tab.selected && tabData != null) {
					_model.hamburgerTabs.addItem(new HamburgerMenuTabsVO(Std.string(Reflect.getProperty(tab, 'label')), tabData));

					// do not remove display object in case of non-closeable tabs
					// but let remove its tabViewTab only
					if (isNonCloseableChild(tabData) && tabLookup.get(tabData) != null) {
						removeTabFor(tabData);
					} else {
						removeChild(tabData);
					}

					needsNewSelectedTab = false;
					validateDisplayList();
					break;
				}
				i--;
			}
		} else {
			shiftHamburgerMenuTabsIfSpaceAvailable();
		}

		numTabs = AS3.int(tabContainer.numChildren);
		var tabWidth:Int = AS3.int(availableWidth / numTabs);

		tabWidth = AS3.int(Math.max(tabWidth, tabSizeMin));
		tabWidth = AS3.int(Math.min(tabWidth, tabSizeDefault));
		tabWidth += 2;

		var pos:Int = -2;
		i = AS3.int(tabContainer.numChildren - 1);
		while (i > -1) {
			tab = AS3.as(tabContainer.getChildAt(i), TabViewTab);
			tab.x = pos;
			tab.y = 0;
			pos += AS3.int(tabWidth - 1);
			i--;
		}
	}

	private function shiftHamburgerMenuTabsIfSpaceAvailable():Void {
		if (!canTabFitIntoAvailableSpace()) {
			_model.hamburgerTabs.refresh();
			return;
		}

		if (_model.hamburgerTabs.length > 0) {
			var hamburgerMenuVO:HamburgerMenuTabsVO = _model.hamburgerTabs.source.shift();
			addChildTab(hamburgerMenuVO.tabData);

			shiftHamburgerMenuTabsIfSpaceAvailable();
		}
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var mtr:Matrix = new Matrix();
		mtr.createGradientBox(unscaledWidth, 8, Math.PI / 2, 0, 18);

		shadow.graphics.clear();
		shadow.graphics.beginGradientFill('linear', [0x000000, 0x000000], [0, 0.1], [0, 255], mtr);
		shadow.graphics.drawRect(0, 17, unscaledWidth, 8);
		shadow.graphics.endFill();

		shadow.graphics.lineStyle(1, 0x0, 0.4);
		shadow.graphics.moveTo(0, 24);
		shadow.graphics.lineTo(unscaledWidth, 24);

		if (needsNewSelectedTab) {
			focusNewTab();
			needsNewSelectedTab = false;
		}

		if (needsTabLayout) {
			updateTabLayout();
			needsTabLayout = false;
		}
	}

	private function isHamburgerMenuWithTabsVisible():Bool {
		var availableWidth:Int = width - hamburgerMenuTabs.width;
		var numTabs:Int = AS3.int(tabContainer.numChildren);
		var allTabsWidth:Float = (numTabs + _model.hamburgerTabs.length) * tabSizeDefault;

		return allTabsWidth > availableWidth;
	}

	private function canAllTabsFitIntoAvailableSpace():Bool {
		var availableWidth:Int = width - hamburgerMenuTabs.width;
		var numTabs:Int = AS3.int(tabContainer.numChildren);
		var allTabsWidth:Float = (numTabs + _model.hamburgerTabs.length) * tabSizeDefault;
		var currentTabsWidth:Float = numTabs * tabSizeDefault;

		return !(allTabsWidth > availableWidth && currentTabsWidth > availableWidth);
	}

	private function canTabFitIntoAvailableSpace():Bool {
		var availableWidth:Int = width - hamburgerMenuTabs.width;
		var numTabs:Int = AS3.int(tabContainer.numChildren);
		var currentTabsWidth:Float = numTabs * tabSizeDefault;

		if (currentTabsWidth < availableWidth) {
			var widthOfEmptySpace:Float = availableWidth - currentTabsWidth;
			if (widthOfEmptySpace > 0 && widthOfEmptySpace > tabSizeDefault) {
				return true;
			}
		}

		return false;
	}

	private function invalidateTabSelection():Void {
		needsNewSelectedTab = true;
		invalidateDisplayList();
	}

	private function invalidateLayoutTabs():Void {
		needsTabLayout = true;
		invalidateDisplayList();
	}

	private function removeTabFromCache(editor:BasicTextEditor):Void {
		if (editor != null) {
			SharedObjectUtil.removeLocationOfClosingProjectFile(
					editor.currentFile.name,
					Std.string(editor.currentFile.fileBridge.nativePath),
					editor.projectPath
			);
		}
	}

}