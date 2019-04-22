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

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.MenuEvent;
import actionScripts.locator.IDEModel;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.renderers.MenuItemRenderer;
import actionScripts.ui.menu.renderers.MenuRenderer;

class MenuModel extends EventDispatcher {

	private var AUTO_CLICK_DELAY(default, never):Int = 200;

	private var freeMenuItemRenderers:Array<MenuItemRenderer> = new Array<MenuItemRenderer>();

	private var freeMenuOrSubMenus:Array<MenuRenderer> = new Array<MenuRenderer>();

	private var hysteresisTimer:Timer;

	// Bi-Directional Hash Of open menus
	private var activeMenuRepo:MenuRepo = new MenuRepo();

	private var _menuBar:MenuBar;

	private var stage:DisplayObject;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	// Current MenuItemRenderer in scope, this will be used after the the renderer has been
	// in over state for 300ms
	@:allow(actionScripts.ui.menu)
	private var activeMenuItemRenderer:MenuItemRenderer;

	@:allow(actionScripts.ui.menu)
	private var previousMenuItemRenderer:MenuItemRenderer;

	@:allow(actionScripts.ui.menu)
	private var topLevelMenu:MenuRenderer;

	// helper flag used to suppress the stage MouseEvent.CLICK listener
	// when MenuItemRenderer is clicked
	private var supressMouseClick:Bool = false;

	private function setTopLevelMenu(value:MenuRenderer):Void {
		if (topLevelMenu == value) {
			return;
		}
		topLevelMenu = value;
		dispatchEvent(new MenuModelEvent(MenuModelEvent.TOP_LEVEL_MENU_CHANGED,
				false, false, value));

	}

	public var bar(get, never):MenuBar;
	private function get_bar():MenuBar {
		return _menuBar;
	}

	public function new(menuBar:MenuBar) {
		super();
		_menuBar = menuBar;

		var hook:Function = function(e:Event):Void {
			_menuBar.removeEventListener(Event.ADDED_TO_STAGE, hook);
			stage = _menuBar.stage;
			init();

		}
		_menuBar.addEventListener(Event.ADDED_TO_STAGE, hook);

		hysteresisTimer = new Timer(AUTO_CLICK_DELAY, 0);
		hysteresisTimer.addEventListener(TimerEvent.TIMER, timerHysteresisHandler);
	}

	private function init():Void {
		stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
		var keyboardManager:MenuKeyboardManager = new MenuKeyboardManager(this);
		keyboardManager.manage(stage);
	}

	private function deactivateHandler(e:Event):Void {
		destroy();
	}

	public function isOpen():Bool {
		return topLevelMenu != null;
	}

	public var menuItems(get, never):Array<ICustomMenuItem>;
	private function get_menuItems():Array<ICustomMenuItem> {
		return (topLevelMenu != null) ? cast topLevelMenu.items : null;
	}

	/**
	 * Release unused menuItemRenders
	 * @param	container
	 * @param	startIndex
	 */
	public function freeMenuItemRenderer(container:DisplayObjectContainer, startIndex:Int):Void {
		var toRemove:Array<MenuItemRenderer> = new Array<MenuItemRenderer>();
		var renderer:MenuItemRenderer;
		while (container.numChildren > startIndex) {
			renderer = AS3.as(container.getChildAt(startIndex), MenuItemRenderer);

			if (renderer == null) {
				continue;
			}
			toRemove.push(renderer);
		}

		freeMenuItemRenderers = freeMenuItemRenderers.concat(toRemove);
	}

	/**
	 * Get new MenuItemRenderers
	 * @param	howMany
	 * @return
	 */
	public function getMenuItemRenderers(howMany:Int):Array<MenuItemRenderer> {
		var rtn:Array<MenuItemRenderer> = new Array<MenuItemRenderer>();
		var rdr:MenuItemRenderer;

		for (i in 0...howMany) {
			if (freeMenuItemRenderers.length > 0) {
				rdr = freeMenuItemRenderers.pop();
			} else {
				rdr = new MenuItemRenderer();
				rdr.model = this;
				rdr.addEventListener(MouseEvent.ROLL_OVER, menuItemRenderRollOverHandler);
				rdr.addEventListener(MouseEvent.ROLL_OUT, menuItemRenderRollOutHandler);
				rdr.addEventListener(MouseEvent.MOUSE_DOWN, menuItemRenderClickHandler);
			}

			rtn.push(rdr);
		}
		return rtn;
	}

	public function displayMenu(base:DisplayObjectContainer, menuItems:Array<ICustomMenuItem>):MenuRenderer {
		if (topLevelMenu != null) {
			// menuItems will never be null so we can do a direct lookup to see if request is from same topmenu
			var isSameTopLevelMenu:Bool = (topLevelMenu.items == cast menuItems);

			// If its the same menu we will notify the close so we can deactive the "highlight" in MenuBarView
			destroy(isSameTopLevelMenu);

			// if open request is from same menu which is already open we will skip opening a new request , thus toggling window to close
			if (isSameTopLevelMenu) {
				return null;
			}

		}
		var localPoint:Point = bar.localToGlobal(new Point(bar.x, bar.y));
		var menu:MenuRenderer = positionMenu(cast menuItems, base, new Point(base.x + localPoint.x, base.y + base.height + localPoint.y));
		setTopLevelMenu(menu);
		return menu;
	}

	public function displaySubmenu(menu:MenuRenderer, base:DisplayObjectContainer, menuItems:Array<ICustomMenuItem>):MenuRenderer {
		hysteresisTimer.reset();
		var submenu:MenuRenderer;
		if (activeMenuRepo.hasObjectAsBase(menu)) {
			submenu = activeMenuRepo.getMenu(menu);

		} else {
			submenu = positionMenu(cast menuItems, menu, new Point(base.width - 5, base.y));
			menu.addChild(submenu);
		}
		// Since we are using the Flex framework we need to delay this event on frame till all models are added,
		// Maybe we should move this to the MenuRenderer ??
		submenu.callLater(delayMenuOpenEvent, [submenu]);
		return submenu;

	}

	private function delayMenuOpenEvent(menu:MenuRenderer):Void {
		dispatchEvent(new MenuModelEvent(MenuModelEvent.MENU_OPENED,
				false, false, menu));
	}

	private function dispatchMenuEvent(menuItem:ICustomMenuItem):Void {
		if (AS3.as(menuItem.data, Bool) && Reflect.hasField(menuItem.data, 'event') && AS3.as(Reflect.field(menuItem.data, 'event'), Bool)) {
			var data:Dynamic = menuItem.data;

			dispatcher.dispatchEvent(new MenuEvent(AS3.string(Reflect.field(data, 'event')), false, false, Reflect.field(data, 'eventData')));

		} else if (menuItem.shortcut != null && menuItem.shortcut.event != null) {
			dispatcher.dispatchEvent(new Event(menuItem.shortcut.event));
		}
	}

	private function positionMenu(menuItems:Array<ICustomMenuItem>, base:DisplayObjectContainer, position:Point):MenuRenderer {
		var menu:MenuRenderer = getMenuOrSubMenu();
		menu.items = cast menuItems;
		menu.x = position.x;
		menu.y = position.y;

		if (topLevelMenu == null) {
			// request is to open up top menu
			PopUpManager.addPopUp(menu, this.bar.parent);
			registerForMouseClicks(true);
		}

		activeMenuRepo.add(base, menu);
		return menu;
	}

	// Will allow use to listen to outside menu clicks to close the active menu
	private function registerForMouseClicks(setup:Bool):Void {
		// Mimic callLater,
		//if someone can figure out the right combo of useCapture for stage/MenuBarView events you win a prize
		// TODO : Fix case were onEnterFrame is called twice when closing the currently active topLevelMenu
		var onEnterFrame:Function = function(e:Event):Void {
			stage.removeEventListener(Event.ENTER_FRAME, cast onEnterFrame);
			if (setup) {
				// CLICK instead of MOUSE_DOWN to allow setting of suppressMouseClick flag when item is clicked otherwise
				// stageMouseClickHandler will ALWAYS destory topLevelMenu
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseClickHandler);
			} else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseClickHandler);
			}

		}

		stage.addEventListener(Event.ENTER_FRAME, cast onEnterFrame);

	}

	private function stageMouseClickHandler(e:MouseEvent):Void {
		if (topLevelMenu == null) {
			return;
		}
		e.stopImmediatePropagation();
		e.preventDefault();

		if (!supressMouseClick) {
			var notifyEvent:Bool = !AS3.as(topLevelMenu.hitTestPoint(e.localX, e.localX), Bool);
			destroy(notifyEvent);
		}
		supressMouseClick = false;
	}

	private function destroy(notify:Bool = true):Void {
		registerForMouseClicks(false);
		cleanUpAfterMenu(topLevelMenu);
		setTopLevelMenu(null);
		cancelHysteresisTimer();
		previousMenuItemRenderer = null;
		supressMouseClick = false;
		if (notify) {
			dispatchEvent(new Event('topMenuClosed'));
		}
	}

	@:allow(actionScripts.ui.menu)
	private function cleanUpAfterMenu(menu:MenuRenderer):Void {
		if (menu == null || !activeMenuRepo.hasObjectAsMenu(menu)) {
			return;
		}

		// TODO : use a MenuChain to speed up checking for open windows
		if (activeMenuRepo.hasObjectAsBase(menu)) {
			// clean up open windows
			{
				cleanUpAfterMenu(activeMenuRepo.getMenu(menu));

			}
		}
		if (menu == topLevelMenu) {
			PopUpManager.removePopUp(menu);
		}

		if (AS3.as(menu.parent, Bool)) {
			// completely remove it from its parnet, fixes dropshadow bug o_0
			menu.parent.removeChild(menu);
		}
		freeMenuOrSubMenu(menu);
		activeMenuRepo.clear(menu);// clear instance in repo
		dispatchEvent(new MenuModelEvent(MenuModelEvent.MENU_CLOSED,
				false, false, menu));
		menu = null;

	}

	private function getMenuOrSubMenu():MenuRenderer {
		var menu:MenuRenderer;
		if (freeMenuItemRenderers.length > 0) {
			menu = freeMenuOrSubMenus.pop();
		} else {
			menu = new MenuRenderer();
			menu.model = this;

		}
		return menu;
	}

	private function rescursiveFindMenu(base:Dynamic):MenuRenderer {
		while (!(Std.is(base, MenuRenderer)) && AS3.as(base, Bool) && AS3.as(Reflect.field(base, 'parent'), Bool)) {
			base = Reflect.field(base, 'parent');
		}
		return AS3.as(base, MenuRenderer);

	}

	private function freeMenuOrSubMenu(menu:MenuRenderer):Void {
		menu.x = -2000;
		menu.y = -2000;
		menu.items = null;
		freeMenuOrSubMenus.push(menu);
	}

	private var lastActiveRendererForSubMenu:MenuItemRenderer;

	private function displaySubMenuForRenderer(rdr:MenuItemRenderer):Void {
		var rendererMenu:MenuRenderer = rescursiveFindMenu(rdr);
		if (rendererMenu == null) {
			return;
		}
		if (lastActiveRendererForSubMenu != null) {
			lastActiveRendererForSubMenu.explictActive = false;
		}

		lastActiveRendererForSubMenu = rdr;
		lastActiveRendererForSubMenu.explictActive = true;
		displaySubmenu(rendererMenu, rdr, rdr.data.submenu.items);

	}

	private function menuItemRenderRollOverHandler(e:MouseEvent):Void {
		var rdr:MenuItemRenderer = AS3.as(e.target, MenuItemRenderer);
		// Keyboard navigation will have localX and localY set to NaN

		registerActiveMenuItemRenderer(rdr, !AS3.as(Math.isNaN(e.localX), Bool));
	}

	private function menuItemRenderClickHandler(e:MouseEvent):Void {
		var rdr:MenuItemRenderer = AS3.as(e.target, MenuItemRenderer);

		if (rdr == null || !AS3.as(rdr.enabled, Bool)) {
			return;
		}
		cancelHysteresisTimer();// go ahead and stop the autotimer passing null to clean up previous

		var currMenuItem:ICustomMenuItem = AS3.as(rdr.data, ICustomMenuItem);
		if (currMenuItem == null) {
			return;
		}

		var canDispatch:Bool = currMenuItem.hasShortcut() || currMenuItem.hasSubmenu() || (AS3.as(currMenuItem.data, Bool) && AS3.as(currMenuItem.data, Bool));

		if (canDispatch) {
			// set suppress flag to stop stage listenering from destorying topLevelMenu
			supressMouseClick = true;
		}
		if (currMenuItem.hasSubmenu()) {
			displaySubMenuForRenderer(rdr);

		} else if (canDispatch && currMenuItem.enabled) {
			destroy();
			dispatchMenuEvent(currMenuItem);

		}
	}

	private function menuItemRenderRollOutHandler(e:MouseEvent):Void {
		var rdr:MenuItemRenderer = AS3.as(e.target, MenuItemRenderer);

		/*if (!rdr || !rdr.data || !rdr.data.hasSubmenu()) // if not a submenu then dont worry about it
		 return;*/
		var relatedObject:DisplayObject = AS3.as(e.relatedObject, DisplayObject);

		trace(relatedObject);
		if (relatedObject == null) {
			return;
		}
		// if we are moving down/up to a new menuItemRenderer in the same menu,
		// If we are moving to the newly created submenu then this object will be of another type
		if (!(Std.is(relatedObject, MenuItemRenderer))) {
			if (previousMenuItemRenderer == null &&
				(Std.is(relatedObject, MenuRenderer) || Std.is(relatedObject.parent, MenuRenderer))) {
				setPreviousRenderer(rdr);
			}
		} else if (hasSubMenu(rdr)) {
			cleanUpAfterMenuItemRenderer(rdr);
		} else {
			setPreviousRenderer(rdr);
		}
	}

	private function hasSubMenu(rdr:MenuItemRenderer):Bool {
		return rdr != null && AS3.as(rdr.data, Bool) && AS3.as(rdr.data.hasSubmenu(), Bool);
	}

	private function registerActiveMenuItemRenderer(rdr:MenuItemRenderer, timer:Bool = true):Void {
		cancelHysteresisTimer();
		/*if (hasSubMenu(activeMenuItemRenderer))
		 activeMenuItemRenderer.explictActive = false;*/

		activeMenuItemRenderer = rdr;
		if (activeMenuItemRenderer == previousMenuItemRenderer) {
			previousMenuItemRenderer = null;
		}

		dispatchEvent(new MenuModelEvent(MenuModelEvent.ACTIVE_MENU_ITEM_RENDERER_CHANGED,
				false, false, rescursiveFindMenu(rdr), rdr));

		if (hasSubMenu(rdr) && timer) {
			// only need to auto open on submenu
			hysteresisTimer.start();
		}

	}

	private function cancelHysteresisTimer():Void {
		activeMenuItemRenderer = null;
		hysteresisTimer.reset();

	}

	private function setPreviousRenderer(rdr:MenuItemRenderer):Void {
		trace('setPreviousRenderer', rdr == previousMenuItemRenderer, rdr == activeMenuItemRenderer);
		if (rdr == previousMenuItemRenderer || rdr == activeMenuItemRenderer) {
			return;
		}
		//if (hasSubMenu(rdr))
		//	cleanUpAfterMenuItemRenderer(rdr);
		if (previousMenuItemRenderer != null) {
			cleanUpAfterMenuItemRenderer(previousMenuItemRenderer);
		}
		previousMenuItemRenderer = rdr;

	}

	@:allow(actionScripts.ui.menu)
	private function cleanUpAfterMenuItemRenderer(rdr:MenuItemRenderer):Void {
		var rendererMenu:MenuRenderer = rescursiveFindMenu(rdr);

		// TODO : Enhance this to use a MenuChain
		// check to see if submenu is open ,checking against the base
		if (rendererMenu != null) {
			if (previousMenuItemRenderer == rdr) {
				previousMenuItemRenderer = null;
			}
			if (lastActiveRendererForSubMenu == rdr) {
				lastActiveRendererForSubMenu = null;
			}
			rdr.explictActive = false;
			var openSubMenu:MenuRenderer = activeMenuRepo.getMenu(rendererMenu);
			if (openSubMenu != null) {
				cleanUpAfterMenu(openSubMenu);
			}

		}

	}

	private function timerHysteresisHandler(e:TimerEvent):Void {
		//	trace("timerHysteresisHandler:check")

		if (activeMenuItemRenderer == null ||
			!AS3.as(activeMenuItemRenderer.hitTestPoint(stage.mouseX, stage.mouseY), Bool)
			||// if not over current activeMenuItemRendere exit
			previousMenuItemRenderer && activeMenuItemRenderer == previousMenuItemRenderer) {
			// to not allow same renders
			{

				trace('timerHysteresisHandler', activeMenuItemRenderer == previousMenuItemRenderer);

				//trace(activeMenuItemRenderer, previousMenuItemRenderer, activeMenuItemRenderer == previousMenuItemRenderer);
				//trace("No ActiveMenuItemRenderer or fails HitTest");
				return;
			}
		}

		// We need to check to see if we have a previous renderer and if so if it one of a submenu
		// If all checks are TRUE we then check to see if activeMenuItemRender
		// is part of the previousMenuItemRender, if so we will return out of check and let the timer
		// run again . This is to prevent flickering of the submenu, this may need to be refactor
		// after next release
		if (previousMenuItemRenderer != null &&
			AS3.as(previousMenuItemRenderer.data, Bool) &&
			AS3.as(previousMenuItemRenderer.data.hasSubmenu(), Bool)) {
			var activeMenuName:String = Std.string(activeMenuItemRenderer.label);
			var subMenuItems:Array<ICustomMenuItem> = previousMenuItemRenderer.data.submenu.items;
			var subMenuItem:ICustomMenuItem;
			for (subMenuItem in subMenuItems) {
				if (subMenuItem.label == activeMenuName) {
					//trace("IS Child OF ActiveMenu!!!")
					return;
				}

			}
		}

		var rdr:MenuItemRenderer = activeMenuItemRenderer;

		cancelHysteresisTimer();

		displaySubMenuForRenderer(rdr);
	}

}

class MenuRepo {

	private var menuToBaseRepo:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var baseToMenuRepo:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	public function add(base:DisplayObjectContainer, menu:MenuRenderer):Void {
		menuToBaseRepo.set(menu, base);
		baseToMenuRepo.set(base, menu);
	}

	public function getOpenMenusForTopMenu(menu:MenuRenderer):Array<MenuRenderer> {
		var opened:Array<MenuRenderer> = new Array<MenuRenderer>();

		while (hasObjectAsMenu(menu)) {
			menu = getMenu(menu);
			opened.push(menu);
		}
		return opened;
	}

	public function hasObjectAsBase(obj:Dynamic):Bool {
		return (baseToMenuRepo.get(obj) != null) ? true : false;
	}

	public function hasObjectAsMenu(obj:Dynamic):Bool {
		return (menuToBaseRepo.get(obj) != null) ? true : false;
	}

	public function has(baseOrMenu:Dynamic):Bool {
		if (Std.is(baseOrMenu, MenuRenderer)) {
			return (menuToBaseRepo.get(baseOrMenu) != null) ? true : false;
		}
		return (baseToMenuRepo.get(baseOrMenu) != null) ? true : false;
	}

	public function getMenu(base:DisplayObjectContainer):MenuRenderer {
		return AS3.as(baseToMenuRepo.get(base), MenuRenderer);
	}

	public function clear(menuOrBase:Dynamic = null):Void {
		var obj:Dynamic;
		if (AS3.as(menuOrBase, Bool)) {
			if (Std.is(menuOrBase, MenuRenderer)) {
				obj = menuToBaseRepo.get(menuOrBase);
				menuToBaseRepo.set(menuOrBase, null);
				baseToMenuRepo.set(obj, null);
				obj = null;
			} else {
				obj = baseToMenuRepo.get(menuOrBase);
				baseToMenuRepo.set(menuOrBase, null);
				menuToBaseRepo.set(obj, null);
				obj = null;
			}
		} else {
			for (obj in menuToBaseRepo) {
				menuToBaseRepo.set(obj, null);
			}

			for (obj in baseToMenuRepo) {
				baseToMenuRepo.set(obj, null);
			}
		}

	}

	@:allow(actionScripts.ui.menu)
	private function new() {}

}