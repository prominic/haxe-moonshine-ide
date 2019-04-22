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
package actionScripts.ui.menu;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import mx.containers.Canvas;
import spark.components.HGroup;
import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.renderers.MenuBarItemRenderer;

class MenuBar extends Canvas {

	private var _menu:ICustomMenu;
	private var needsRedrawing:Bool = false;

	private var menuLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var bar:HGroup;
	private var lastActiveMenuBarItem:MenuBarItemRenderer;

	private var model:MenuModel;

	public function new() {
		super();

		createMenuModelInContext();
	}

	private function createMenuModelInContext():Void {
		model = new MenuModel(this);
		model.addEventListener('topMenuClosed', modelTopMenuClosedHandler);
		model.addEventListener(MenuModelEvent.ACTIVE_ALL_MENUS, activeAllMenusHandler);
	}

	private function activeAllMenusHandler(e:MenuModelEvent):Void {}

	private function modelTopMenuClosedHandler(e:Event):Void {
		if (lastActiveMenuBarItem == null) {
			return;
		}
		lastActiveMenuBarItem.active = false;
		// Check to see if mouse is still over last bar item and if so reselect it
		if (AS3.as(lastActiveMenuBarItem.hitTestPoint(mouseX, mouseY), Bool)) {
			lastActiveMenuBarItem.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		}
		lastActiveMenuBarItem = null;
	}

	override private function createChildren():Void {
		super.createChildren();
		percentWidth = 100;
		height = 21;

		bar = new HGroup();
		bar.setStyle('left', 0);

		bar.percentWidth = 100;
		bar.mouseChildren = true;

		bar.gap = 0;

		addChild(bar);
	}

	public var menu(get, set):ICustomMenu;
	private function set_menu(value:ICustomMenu):ICustomMenu {
		_menu = value;
		needsRedrawing = true;
		invalidateDisplayList();
		return value;
	}

	private function get_menu():ICustomMenu {
		return _menu;
	}

	private function drawMenuState():Void {
		var barItem:MenuBarItemRenderer;
		var items:Array<ICustomMenuItem> = cast _menu.items;
		for (item in items) {
			barItem = new MenuBarItemRenderer();
			menuLookup.set(item.label, item);
			barItem.text = item.label;
			barItem.addEventListener(MouseEvent.MOUSE_DOWN, barItemOpenMenu, false, as3hx.Compat.FLOAT_MAX, true);
			barItem.addEventListener(MouseEvent.ROLL_OVER, barItemOpenMenu, false, as3hx.Compat.FLOAT_MAX, true);

			//barItem.menu = item;
			bar.addElement(barItem);
		}

		needsRedrawing = false;
	}

	public var numOfRenderers(get, never):Int;
	private function get_numOfRenderers():Int {
		return _menu.items.length;
	}

	public function getRendererAt(index:Int):MenuBarItemRenderer {
		return MenuBarItemRenderer(bar.getElementAt(index));
	}

	public function displayMenuAt(index:Int):Void {
		var barItem:MenuBarItemRenderer = getRendererAt(index);
		var item:ICustomMenuItem = AS3.as(menuLookup.get(barItem.text), ICustomMenuItem);
		if (item == null || !AS3.as(item.data, Bool)) {
			return;
		}

		var menuItems:Array<ICustomMenuItem> = ((AS3.as(item.data, ICustomMenu))) ? cast (AS3.as(item.data, ICustomMenu)).items : null;

		if (menuItems == null || menuItems.length == 0) {
			return;
		}

		if (lastActiveMenuBarItem != null) {
			lastActiveMenuBarItem.active = false;
		}
		barItem.active = true;
		lastActiveMenuBarItem = barItem;
		model.displayMenu(barItem, (AS3.as(item.data, ICustomMenu)).items);
	}

	private function barItemOpenMenu(e:Event):Void {
		if (e.type == MouseEvent.ROLL_OVER && !model.isOpen()) {
			return;
		}

		var barItem:MenuBarItemRenderer = AS3.as(e.target, MenuBarItemRenderer);
		// Menu is open but we must also check to see if the current menu items are the same,
		// if so we will skip opening the window otherwise we will close it due to the toggle statement
		// in _model.displayMenu

		if (e.type == MouseEvent.ROLL_OVER && lastActiveMenuBarItem == barItem) {
			return;
		}

		displayMenuAt(AS3.int(bar.getElementIndex(barItem)));
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var mtr:Matrix = new Matrix();
		mtr.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);

		graphics.clear();
		graphics.beginGradientFill('linear', [0xebeff7, 0xCACBCD], [1, 1], [64, 255], mtr);
		graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
		graphics.endFill();

		graphics.lineStyle(1);
		graphics.moveTo(0, unscaledHeight - 1);
		graphics.lineTo(unscaledWidth, unscaledHeight - 1);

		if (needsRedrawing) {
			drawMenuState();
		}
	}

}