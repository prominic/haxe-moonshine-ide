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
import actionScripts.valueObjects.KeyboardShortcut;

class CustomMenuItem implements ICustomMenuItem implements IMenuEntity {

	public function hasShortcut():Bool {
		return shortcut != null && shortcut.event != null;
	}

	public function hasSubmenu():Bool {
		return Std.is(_data, ICustomMenu) && (AS3.as(_data, ICustomMenu)).items.length != 0;
	}

	public function new(label:String = '', isSeparator:Bool = false, options:Dynamic = null) {

		this.label = label;
		_isSeparator = isSeparator;
		init(options);
	}

	private function init(options:Dynamic):Void {
		if (AS3.as(options, Bool)) {
			if (AS3.as(Reflect.field(options, 'shortcut'), Bool) && AS3.as(Reflect.field(Reflect.field(options, 'shortcut'), 'event'), Bool) && AS3.as(Reflect.field(Reflect.field(options, 'shortcut'), 'key'), Bool)) {
				shortcut = new KeyboardShortcut(AS3.string(Reflect.field(Reflect.field(options, 'shortcut'), 'event')), AS3.string(Reflect.field(Reflect.field(options, 'shortcut'), 'key')), Reflect.field(Reflect.field(options, 'shortcut'), 'mod'));
			}
			if (AS3.as(Reflect.field(options, 'data'), Bool)) {
				data = Reflect.field(options, 'data');
			}
			if (AS3.as(Reflect.field(options, 'enableTypes'), Bool)) {
				enableTypes = Reflect.field(options, 'enableTypes');
			}
		}
	}

	/* INTERFACE com.moonshineproject.plugin.menu.interfaces.ICustomMenuItem */
	private var _checked:Bool = false;

	public var checked(get, set):Bool;
	private function get_checked():Bool {
		return _checked;
	}

	private function set_checked(value:Bool):Bool {
		_checked = value;
		return value;
	}

	private var _data:Dynamic;

	public var data(get, set):Dynamic;
	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		_data = value;
		return value;
	}

	private var _isSeparator:Bool = false;

	public var isSeparator(get, never):Bool;
	private function get_isSeparator():Bool {
		return _isSeparator;
	}

	private var _shortcut:KeyboardShortcut;

	public var shortcut(get, set):KeyboardShortcut;
	private function get_shortcut():KeyboardShortcut {
		return _shortcut;
	}

	private function set_shortcut(value:KeyboardShortcut):KeyboardShortcut {
		if (_shortcut == value) {
			return value;
		}
		_shortcut = value;
		return value;
	}

	public var submenu(get, set):ICustomMenu;
	private function get_submenu():ICustomMenu {
		if (!AS3.as(data, Bool)) {
			return null;
		}
		return AS3.as(data, ICustomMenu);
	}

	private function set_submenu(value:ICustomMenu):ICustomMenu {
		if (data == value) {
			return value;
		}

		data = value;

		return value;
	}

	private var _label:String;

	public var label(get, set):String;
	private function get_label():String {
		return _label;
	}

	private function set_label(value:String):String {
		_label = value;

		return value;
	}

	private var _enabled:Bool = true;

	@:meta(Bindable())
	public var enabled(get, set):Bool;
	private function set_enabled(value:Bool):Bool {
		_enabled = value;
		return value;
	}

	private function get_enabled():Bool {
		return _enabled;
	}

	public var enableTypes:Array<Dynamic>;

	private var _dynamicItem:Bool = false;

	public var dynamicItem(get, set):Bool;
	private function get_dynamicItem():Bool {
		return _dynamicItem;
	}

	private function set_dynamicItem(value:Bool):Bool {
		_dynamicItem = value;
		return value;
	}

}