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
package actionScripts.ui.menu.vo;

import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.interfaces.IMenuEntity;

/**
 * ...
 * @author Conceptual Ideas
 */
class CustomMenu implements ICustomMenu implements IMenuEntity {

	public var dynamicItem:Bool = false;

	private var _items:Array<ICustomMenuItem> = new Array<ICustomMenuItem>();

	public var items(get, never):Array<ICustomMenuItem>;
	private function get_items():Array<ICustomMenuItem> {
		return cast _items;
	}

	public var numItems(get, never):Int;
	private function get_numItems():Int {
		return items.length;
	}

	private var _label:String;

	public var label(get, set):String;
	private function get_label():String {
		return _label;
	}

	private function set_label(value:String):String {
		if (label == value) {
			return value;
		}
		_label = value;
		return value;
	}

	public function new(label:String = '', items:Array<IMenuEntity> = null) {
		this.label = label;
	}

	public function addItem(item:ICustomMenuItem):ICustomMenuItem {
		// TODO : Check if item is bound to another ICustomMenu
		items.push(item);
		return item;
	}

	public function addItemAt(item:ICustomMenuItem, index:Int):ICustomMenuItem {
		var pos:Int = index;
		if (index > items.length) {
			pos = items.length;
		}

		var removeIndex:Int = getItemIndex(item);
		if (removeIndex == -1) {
			items.splice(removeIndex, 1);
		}

		items.insert(pos, item);

		return item;
	}

	public function addSubmenu(submenu:ICustomMenu, label:String = null):ICustomMenuItem {
		return addItem(new CustomMenuItem(Std.string((label != null) ? label : submenu.label), false, {
					'data': submenu
				}));
	}

	public function addSubMenuAt(submenu:ICustomMenu, index:Int, label:String = null):ICustomMenuItem {
		return addItemAt(new CustomMenuItem(Std.string((label != null) ? label : submenu.label), false, {
					'data': submenu
				}), index);

	}

	public function containsItem(item:ICustomMenuItem):Bool {
		return false;
	}

	public function getItemAt(index:Int):ICustomMenuItem {
		if (index > items.length || index < 0) {
			return null;
		}

		return items[index];
	}

	public function getItemByName(name:String):ICustomMenuItem {
		for (entity in items) {
			if (entity == null) {
				continue;
			}
			if (entity.label == name) {
				return entity;
			}
		}
		return null;
	}

	public function getItemIndex(item:ICustomMenuItem):Int {
		return AS3.int(Lambda.indexOf(_items, item));

	}

	public function removeItemAt(index:Int):ICustomMenuItem {
		if (index > items.length || index < 0) {
			return null;
		}

		var removedItem:ICustomMenuItem = this.getItemAt(index);
		items.splice(index, 1);

		return removedItem;
	}

	public var menu(get, set):ICustomMenu;
	private function get_menu():ICustomMenu {
		return null;
	}

	private function set_menu(value:ICustomMenu):ICustomMenu {
		return value;
	}

}