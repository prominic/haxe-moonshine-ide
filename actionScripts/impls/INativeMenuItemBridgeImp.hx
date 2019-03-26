////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls;

import haxe.Constraints.Function;

import flash.events.Event;
import actionScripts.interfaces.INativeMenuItemBridge;
import actionScripts.ui.menu.vo.CustomMenuItem;
import actionScripts.valueObjects.KeyboardShortcut;
import actionScripts.vo.NativeMenuItemMoonshine;
class INativeMenuItemBridgeImp extends CustomMenuItem implements INativeMenuItemBridge {

	public var keyEquivalent(get, set):String;
	public var keyEquivalentModifiers(get, set):Array<Dynamic>;
	public var listener(never, set):Function;
	public var getNativeMenuItem(get, never):Dynamic;

	private var nativeMenuItem:NativeMenuItemMoonshine;

	public function createMenu(label:String = '', isSeparator:Bool = false, listener:Function = null, enableTypes:Array<Dynamic> = null):Void {
		nativeMenuItem = new NativeMenuItemMoonshine(label, isSeparator);
		nativeMenuItem.enableTypes = enableTypes;
	}

	private function get_keyEquivalent():String {
		return nativeMenuItem.keyEquivalent;
	}

	private function set_keyEquivalent(value:String):String {
		nativeMenuItem.keyEquivalent = value;
		return value;
	}

	private function get_keyEquivalentModifiers():Array<Dynamic> {
		return nativeMenuItem.keyEquivalentModifiers;
	}

	private function set_keyEquivalentModifiers(value:Array<Dynamic>):Array<Dynamic> {
		nativeMenuItem.keyEquivalentModifiers = value;
		return value;
	}

	override private function get_data():Dynamic {
		return nativeMenuItem.data;
	}

	override private function set_data(value:Dynamic):Dynamic {
		nativeMenuItem.data = value;
		return value;
	}

	private function set_listener(value:Function):Function {
		if (value != null) {
			nativeMenuItem.addEventListener(Event.SELECT, value, false, 0, true);
		}
		return value;
	}

	override private function set_shortcut(value:KeyboardShortcut):KeyboardShortcut {
		return value;
	}

	private function get_getNativeMenuItem():Dynamic {
		return nativeMenuItem;
	}

	public function new() {
		super();
	}

}