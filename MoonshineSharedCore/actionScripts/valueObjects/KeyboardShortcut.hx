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
package actionScripts.valueObjects;

import flash.ui.Keyboard;

class KeyboardShortcut {

	public var altKey:Bool = false;
	public var ctrlKey:Bool = false;
	public var cmdKey:Bool = false;
	public var shiftKey:Bool = false;
	public var keyCode:Int = 0;
	private var _event:String;

	private static var SHIFT_KEYCODE_CHAR_MAP(default, never):Dynamic = {
			'192': ['`', '~'],
			'220': ['\\', '|'],
			'188': [',', '<'],
			'187': ['=', '+'],
			'219': ['[', '{'],
			'189': ['-', '_'],
			'190': ['.', '>'],
			'222': ['\'', '"'],
			'221': [']', '}'],
			'191': ['/', '?'],
			'186': [';', ':']
		};
	private static var STRING_KEYCODE_TEXT_CONVERSION(default, never):Dynamic = {
			'\n': [Keyboard.ENTER, 'Enter'],
			' ': [Keyboard.SPACE, 'Space']
		};

	private static var KEYCODE_STRING_TEXT_CONVERSION:Dynamic = {};

	private static var SHIFT_CHAR_KEYCODE_MAP:Dynamic = {};

	// setup mapping once and only once

	private static function init():Void {
		for (keyCode in Reflect.fields(SHIFT_KEYCODE_CHAR_MAP)) {
			Reflect.setField(SHIFT_CHAR_KEYCODE_MAP, Std.string(Reflect.field(Reflect.field(SHIFT_KEYCODE_CHAR_MAP, keyCode), Std.string(0))), keyCode);// Non Shift
			Reflect.setField(SHIFT_CHAR_KEYCODE_MAP, Std.string(Reflect.field(Reflect.field(SHIFT_KEYCODE_CHAR_MAP, keyCode), Std.string(1))), keyCode);// Shift

		}
		for (str in Reflect.fields(STRING_KEYCODE_TEXT_CONVERSION)) {
			Reflect.setField(KEYCODE_STRING_TEXT_CONVERSION, Std.string(Reflect.field(Reflect.field(STRING_KEYCODE_TEXT_CONVERSION, str), Std.string(0))), [str, Reflect.field(Reflect.field(STRING_KEYCODE_TEXT_CONVERSION, str), Std.string(1))]);
		}

	}

	public function new(event:String, key:String, modifiers:Array<Dynamic> = null) {
		_event = event;
		parse(key, (modifiers != null) ? modifiers : []);
	}

	public function toString():String {
		var keys:Array<Dynamic> = [];
		if (altKey) {
			keys.push('Alt');
		}
		if (ctrlKey) {
			keys.push('Ctrl');
		}
		if (shiftKey) {
			keys.push('Shift');
		}
		if (cmdKey) {
			keys.push('Cmd');
		}

		if (Reflect.field(SHIFT_KEYCODE_CHAR_MAP, Std.string(keyCode)) != null) {
			keys.push((shiftKey) ? Reflect.field(Reflect.field(SHIFT_KEYCODE_CHAR_MAP, Std.string(keyCode)), Std.string(1)) : Reflect.field(Reflect.field(SHIFT_KEYCODE_CHAR_MAP, Std.string(keyCode)), Std.string(0)));
		} else if (keyCode >= 112 && keyCode <= 123) {
			// function keys
			keys.push('F' + Std.string((keyCode % 112) + 1));
		} else if (keyCode > 64 && keyCode < 91) {
			var char:String = String.fromCharCode(AS3.int('0x' + as3hx.Compat.toString(AS3.int(keyCode), 16)));
			keys.push((shiftKey) ? char.toUpperCase() : char.toLowerCase());
		} else if (Reflect.field(KEYCODE_STRING_TEXT_CONVERSION, Std.string(keyCode)) != null) {
			keys.push(Reflect.field(Reflect.field(KEYCODE_STRING_TEXT_CONVERSION, Std.string(keyCode)), Std.string(1)));// String translation
		}

		return keys.join('+');
	}

	private function parse(key:String, modifiers:Array<Dynamic>):Void {
		if (Lambda.indexOf(modifiers, Keyboard.ALTERNATE) != -1) {
			altKey = true;
		}
		if (Lambda.indexOf(modifiers, Keyboard.COMMAND) != -1) {
			cmdKey = true;
		}
		if (Lambda.indexOf(modifiers, Keyboard.CONTROL) != -1) {
			ctrlKey = true;
		}
		if (Lambda.indexOf(modifiers, Keyboard.SHIFT) != -1) {
			shiftKey = true;
		}

		var charCode:Int = key.charCodeAt(0);
		if (charCode > 64 && charCode < 91) {
			// isUpperCase
			shiftKey = true;
		}

		if (Reflect.field(STRING_KEYCODE_TEXT_CONVERSION, key) != null) {
			keyCode = AS3.int(Reflect.field(Reflect.field(STRING_KEYCODE_TEXT_CONVERSION, key), Std.string(0)));
			return;
		}

		key = key.toUpperCase();
		if (Reflect.getProperty(Keyboard, key) != null) {
			keyCode = AS3.int(Reflect.getProperty(Keyboard, key));
		} else if (Reflect.getProperty(Keyboard, 'NUMBER_' + key) != null) {
			keyCode = AS3.int(Reflect.getProperty(Keyboard, 'NUMBER_' + key));
		} else if (!AS3.as(Math.isNaN(as3hx.Compat.parseInt(key)), Bool)) {
			keyCode = as3hx.Compat.parseInt(key);
		} else if (Reflect.field(SHIFT_CHAR_KEYCODE_MAP, key) != null) {
			keyCode = AS3.int(Reflect.field(SHIFT_CHAR_KEYCODE_MAP, key));
		}
	}

	public var event(get, never):String;
	private function get_event():String {
		return _event;
	}

	private static var KeyboardShortcut_static_initializer = {
		init();
		true;
	}

}