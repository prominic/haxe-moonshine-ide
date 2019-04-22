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
import actionScripts.ui.menu.renderers.MenuItemRenderer;
import actionScripts.ui.menu.renderers.MenuRenderer;

class MenuModelEvent extends Event {

	public static inline var TOP_LEVEL_MENU_CHANGED:String = 'topLevelMenuChanged';
	public static inline var ACTIVE_MENU_ITEM_RENDERER_CHANGED:String = 'activeMenuItemRendererChanged';
	public static inline var MENU_OPENED:String = 'menuOpened';
	public static inline var MENU_CLOSED:String = 'menuClosed';
	public static inline var ACTIVE_ALL_MENUS:String = 'activeAllMenus';

	private var _renderer:MenuItemRenderer;
	private var _menu:MenuRenderer;

	public function new(type:String,
			bubbles:Bool = false, cancelable:Bool = false,
			menu:MenuRenderer = null,
			renderer:MenuItemRenderer = null) {
		super(type, bubbles, cancelable);
		_renderer = renderer;
		_menu = menu;
	}

	public var menu(get, never):MenuRenderer;
	private function get_menu():MenuRenderer {
		return _menu;
	}

	public var renderer(get, never):MenuItemRenderer;
	private function get_renderer():MenuItemRenderer {
		return _renderer;
	}

}