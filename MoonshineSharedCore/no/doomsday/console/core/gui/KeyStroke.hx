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
package no.doomsday.console.core.gui;

import no.doomsday.console.core.input.KeyboardManager;

/**
 * ...
 * @author Andreas Rønning
 */
class KeyStroke {

	public var keyCodes:Array<Dynamic> = [];
	private var manager:KeyboardManager;

	public function new(manager:KeyboardManager, keyCodes:Array<Dynamic> = null) {
		this.manager = manager;
		this.keyCodes = keyCodes;
	}

	public var valid(get, never):Bool;
	private function get_valid():Bool {
		var i:Int = keyCodes.length;
		while (i-- != 0) {
			if (manager.keydict.get(keyCodes[i]) == null) {
				return false;
			}
		}
		return true;
	}

}