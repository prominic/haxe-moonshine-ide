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
package actionScripts.factory;

import haxe.Constraints.Function;
import actionScripts.interfaces.INativeMenuItemBridge;

class NativeMenuItemLocation {

	public var item:INativeMenuItemBridge;

	public function new(label:String = '', isSeparator:Bool = false, listener:Function = null, enableTypes:Array<Dynamic> = null) {
		// ** IMPORTANT **
		var obj:Dynamic = BridgeFactory.getNativeMenuItemInstance();
		item = Type.createInstance(obj, []);
		item.createMenu(label, isSeparator, cast listener, enableTypes);
	}

}