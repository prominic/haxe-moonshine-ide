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
package actionScripts.interfaces;

import haxe.Constraints.Function;
import actionScripts.valueObjects.KeyboardShortcut;

interface INativeMenuItemBridge {

	function createMenu(label:String = '', isSeparator:Bool = false, listener:Function = null, enableTypes:Array<Dynamic> = null):Void;

	var keyEquivalent(get, set):String;
	var keyEquivalentModifiers(get, set):Array<Dynamic>;
	var data(get, set):Dynamic;
	var listener(never, set):Function;
	var shortcut(never, set):KeyboardShortcut;
	var getNativeMenuItem(get, never):Dynamic;

}