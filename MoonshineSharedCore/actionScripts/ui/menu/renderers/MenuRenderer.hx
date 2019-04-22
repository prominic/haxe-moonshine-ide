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
package actionScripts.ui.menu.renderers;

import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import mx.containers.Canvas;
import mx.containers.VBox;
import mx.core.FlexGlobals;
import mx.core.ScrollPolicy;
import actionScripts.ui.menu.CustomMenuBox;
import actionScripts.ui.menu.MenuModel;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.utils.Moonshine_internal;
import actionScripts.valueObjects.ConstantsCoreVO;

class MenuRenderer extends Canvas {

	private var needsRedrawing:Bool = false;
	private var itemContainer:CustomMenuBox;
	private var needsRendererLayout:Bool = false;

	public function new() {
		super();
	}

	override private function createChildren():Void {
		super.createChildren();

		itemContainer = new CustomMenuBox();
		itemContainer.maxHeight = FlexGlobals.topLevelApplication.height - 200;

		addChild(itemContainer);
	}

	private var _model:MenuModel;

	public var model(never, set):MenuModel;
	private function set_model(v:MenuModel):MenuModel {
		_model = v;
		return v;
	}

	private var _items:Array<ICustomMenuItem>;

	public var items(get, set):Array<ICustomMenuItem>;
	private function set_items(v:Array<ICustomMenuItem>):Array<ICustomMenuItem> {
		if (v == null) {
			v = new Array<ICustomMenuItem>();
		}
		_items = cast v;

		needsRedrawing = true;
		invalidateProperties();
		return v;
	}

	private function get_items():Array<ICustomMenuItem> {
		return cast _items;
	}

	public function clear():Void {
		_model.freeMenuItemRenderer(itemContainer, 0);
	}

	public var numOfRenderers(get, never):Int;
	private function get_numOfRenderers():Int {
		return _items.length;
	}

	public function getRendererAt(index:Int):MenuItemRenderer {
		return AS3.as(itemContainer.getChildAt(index), MenuItemRenderer);
	}

	public function getRendererIndex(rdr:MenuItemRenderer):Int {
		return AS3.int(itemContainer.getChildIndex(rdr));
	}

	private function setTooTip(label:String):String {
		for (c in as3hx.Compat.each(ConstantsCoreVO.MENU_TOOLTIP)) {
			if (label == AS3.string(Reflect.field(c, 'label'))) {
				return AS3.string(Reflect.field(c, 'tooltip'));
			}
		}
		return null;
	}

	private function drawMenuState():Void {
		var renderer:MenuItemRenderer;
		var numOfItems:Int = _items.length;

		var tmpRenderers:Array<MenuItemRenderer> = cast _model.getMenuItemRenderers(numOfItems);
		var currMenuItem:ICustomMenuItem;

		for (i in 0...numOfItems) {
			renderer = tmpRenderers[i];

			currMenuItem = _items[i];

			renderer.shortcut = ((currMenuItem.shortcut != null)) ? Std.string(currMenuItem.shortcut) : null;
			renderer.data = currMenuItem;
			renderer.separator = currMenuItem.isSeparator;
			renderer.submenu = (currMenuItem.submenu != null) ? true : false;
			renderer.label = currMenuItem.label;
			renderer.checked = currMenuItem.checked;
			renderer.tooltip = setTooTip(currMenuItem.label);
			itemContainer.addChildAt(renderer, i);
		}

		if (itemContainer.numChildren > numOfItems) {
			_model.freeMenuItemRenderer(itemContainer, numOfItems);
		}

		needsRendererLayout = true;
	}

	override private function commitProperties():Void {
		super.commitProperties();

		if (needsRedrawing) {
			drawMenuState();
			needsRedrawing = false;

		}
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		// add an hit area to add a hit buffer of 5px in any direction
		if (hitArea == null) {
			hitArea = new Sprite();
			hitArea.mouseEnabled = false;
			rawChildren.addChild(hitArea);
		}
		hitArea.graphics.clear();
		hitArea.graphics.beginFill(0xFF0000, 0);
		hitArea.graphics.drawRect(-5, -5, unscaledWidth + 5, unscaledHeight + 5);
		hitArea.graphics.endFill();
		if (itemContainer != null && needsRendererLayout) {
			needsRendererLayout = false;
			var rdr:MenuItemRenderer;
			var containerNumOfChildren:Int = AS3.int(itemContainer.numChildren);

			var maxRendererLabelWidth:Float = 0;
			var maxRendererShortcutLabelWidth:Float = 0;
			var currentWidth:Float;

			var hasShortcut:Bool = false;
			var defaultShortcutWidth:Float = 50;

			use;
			var layoutTime:Float = Math.round(haxe.Timer.stamp() * 1000);

			for (i in 0...containerNumOfChildren) {
				if (Std.is(itemContainer.getChildAt(i), MenuItemRenderer)) {
					rdr = AS3.as(itemContainer.getChildAt(i), MenuItemRenderer);

					if (AS3.as(rdr.shortcut, Bool)) {
						hasShortcut = true;
					}

					currentWidth = rdr.getLabelWidth();
					if (currentWidth > maxRendererLabelWidth) {
						maxRendererLabelWidth = currentWidth;
					}

					currentWidth = rdr.getShortcutLabelWidth();

					if (currentWidth > maxRendererShortcutLabelWidth) {
						maxRendererShortcutLabelWidth = currentWidth;
					}
				}

			}
			if (!hasShortcut) {
				maxRendererShortcutLabelWidth = 5;
			} else if (maxRendererShortcutLabelWidth < defaultShortcutWidth && hasShortcut) {
				maxRendererShortcutLabelWidth = defaultShortcutWidth;
			}

			for (i in 0...containerNumOfChildren) {
				if (Std.is(itemContainer.getChildAt(i), MenuItemRenderer)) {
					rdr = AS3.as(itemContainer.getChildAt(i), MenuItemRenderer);
					rdr.resizeLabels(maxRendererLabelWidth, maxRendererShortcutLabelWidth);
				}

			}

		}

	}

}