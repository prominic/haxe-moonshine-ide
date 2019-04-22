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

import flash.errors.Error;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import actionScripts.ui.menu.renderers.MenuItemRenderer;
import actionScripts.ui.menu.renderers.MenuRenderer;

class MenuKeyboardManager {

	private var model:MenuModel;

	private static var UP(default, never):Int = 1 << 0;
	private static var DOWN(default, never):Int = 1 << 1;
	private static var LEFT(default, never):Int = 1 << 2;
	private static var RIGHT(default, never):Int = 1 << 3;

	private var activeTopLevelMenu:MenuRenderer;

	private var activeMenuItemRenderer:MenuItemRenderer;

	private var activeMenu:MenuRenderer;

	private var selectFirstSubMenuItem:Bool = false;

	private var activeMenus:Array<MenuRenderer> = new Array<MenuRenderer>();

	public function new(model:MenuModel) {
		this.model = model;
	}

	private function reset():Void {
		as3hx.Compat.setArrayLength(activeMenus, 0);
		activeMenuItemRenderer = null;
		selectFirstSubMenuItem = false;
	}

	public function manage(stage:DisplayObject):Void {
		stage.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		model.addEventListener(MenuModelEvent.TOP_LEVEL_MENU_CHANGED, topLevelMenuChangedHandler);
		model.addEventListener(MenuModelEvent.MENU_OPENED, menuOpenedHandler);
		model.addEventListener(MenuModelEvent.MENU_CLOSED, menuClosedHandler);
		model.addEventListener(MenuModelEvent.ACTIVE_MENU_ITEM_RENDERER_CHANGED, activeMenuItemChangedHandler);
	}

	private function menuClosedHandler(e:MenuModelEvent):Void {
		var index:Int = AS3.int(Lambda.indexOf(activeMenus, e.menu));
		if (index > -1) {
			activeMenus.splice(index, 1);
		}
	}

	private function menuOpenedHandler(e:MenuModelEvent):Void {
		activeMenu = e.menu;
		if (Lambda.indexOf(activeMenus, activeMenu) == -1) {
			activeMenus.push(activeMenu);
		}
		if (selectFirstSubMenuItem) {
			// if we previous requested to open a submenu via RIGHT
			{

				activeMenuItemRenderer = null;

				navigate(Keyboard.DOWN);
				selectFirstSubMenuItem = false;
			}
		}
	}

	private function topLevelMenuChangedHandler(e:MenuModelEvent):Void {
		activeMenu = activeTopLevelMenu = e.menu;
		reset();
		activeMenus.push(activeTopLevelMenu);

	}

	private function activeMenuItemChangedHandler(e:MenuModelEvent):Void {
		/*deactiveRenderer(activeMenuItemRenderer)*/

		activeMenuItemRenderer = e.renderer;

		activeMenu = e.menu;// current menu assoicated with renderer
		if (Lambda.indexOf(activeMenus, activeMenu) == -1) {
			activeMenus.push(activeMenu);
		}

	}

	private function keyUpHandler(e:KeyboardEvent):Void {
		if (activeMenu == null) {
			return;
		}
		switch (e.keyCode) {
			case Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT:
				navigate(e.keyCode);
		}
	}

	private function getNextOrPreviousIndex(current:Int, direction:Int, max:Int):Int {
		current += direction;
		if (current >= max) {
			current = 0;
		}
		if (current < 0) {
			current = AS3.int(max - 1);
		}
		return current;
	}

	private function findRendererAtIndex(menu:MenuRenderer, direction:Int, currentIndex:Int):MenuItemRenderer {
		var rdr:MenuItemRenderer;
		var numOfRenderers:Int = menu.numOfRenderers;
		trace('findRendererAtIndex', numOfRenderers, currentIndex);
		do {
			currentIndex = getNextOrPreviousIndex(currentIndex, (direction == Keyboard.DOWN) ? 1 : -1, numOfRenderers);
			trace('after findRendererAtIndex', currentIndex);
			try {
				rdr = menu.getRendererAt(currentIndex);
			} catch (e:Error) {
				return null;
			}
		} while ((AS3.as(rdr.separator, Bool)));
		return rdr;
	}

	private function navigate(direction:Int):Void {
		var numOfRenderers:Int = activeMenu.numOfRenderers;
		var currentIndex:Int = -1;

		var relatedObject:InteractiveObject;

		if (activeMenuItemRenderer != null) {
			try {
				currentIndex = activeMenu.getRendererIndex(activeMenuItemRenderer);
			} catch (e:Error) {}
		}

		var rdr:MenuItemRenderer;
		if (direction == Keyboard.DOWN || direction == Keyboard.UP) {
			trace('Moving:', (direction == Keyboard.DOWN) ? 'down' : 'up');
			rdr = findRendererAtIndex(activeMenu, direction, currentIndex);
			//if (!rdr)
			//rdr = activeMenu.getRendererAt(0);
			// we need to mimc the relatedObject depending on the direction we are traveling
			if (currentIndex != -1) {
				relatedObject = findRendererAtIndex(activeMenu, (direction == Keyboard.DOWN) ?
								Keyboard.UP : Keyboard.DOWN, activeMenu.getRendererIndex(rdr));
			}

			if (activeMenuItemRenderer != null) {
				activeMenuItemRenderer.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT,
						true, false, Math.NaN, Math.NaN, relatedObject));
			}

			if (rdr != null) {
				rdr.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
			}
			trace(rdr);

		} else if (direction == Keyboard.LEFT || direction == Keyboard.RIGHT) {
			if (direction == Keyboard.RIGHT) {
				if (activeMenuItemRenderer != null
					&& AS3.as(activeMenuItemRenderer.submenu, Bool)) {
					// we dispatch the down even again, this will in most cases, already have the submenu open,
					// but we do this so we can get the instance of that menu
					// A flag is set which will denote that we need to move to the first entry in the submenu
					// upon MENU_CHANGED
					selectFirstSubMenuItem = true;
					activeMenuItemRenderer.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

					return;
				}
			} else {
				var index:Int = Lambda.indexOf(activeMenus, activeMenu) - 1;
				if (index < 0) {
					return;
				}
				if (activeMenuItemRenderer != null) {
					model.cleanUpAfterMenuItemRenderer(activeMenuItemRenderer);
				}
				model.cleanUpAfterMenu(activeMenu);
				/*if (model.previousMenuItemRenderer)
				   {
				   model.previousMenuItemRenderer.dispatchEvent(new MouseEvent(
				   MouseEvent.ROLL_OUT,false,false,NaN,NaN,activeMenu));
				 }*/
				activeMenu = activeMenus[index];
				navigate(Keyboard.DOWN);

			}

		}

	}

	private function activateRenderer(rdr:MenuItemRenderer):Void {
		if (rdr != null) {
			if (AS3.as(rdr.data, Bool) && AS3.as(rdr.data.hasSubmenu(), Bool)) {
				rdr.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}
	}

	private function deactiveRenderer(rdr:MenuItemRenderer, relatedObject:InteractiveObject = null):Void {
		if (rdr != null) {}
	}

}