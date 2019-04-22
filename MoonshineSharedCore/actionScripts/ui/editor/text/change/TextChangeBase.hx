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
package actionScripts.ui.editor.text.change;

import flash.errors.Error;

class TextChangeBase {

	private var _startLine:Int = 0;
	private var _startChar:Int = 0;

	public var startLine(get, never):Int;
	private function get_startLine():Int {
		return _startLine;
	}

	public var startChar(get, never):Int;
	private function get_startChar():Int {
		return _startChar;
	}

	@:allow(actionScripts.ui.editor.text.change)
	private static var UNBLOCK(get, never):TextChangeBlocker;
	@:allow(actionScripts.ui.editor.text.change)
	private static function get_UNBLOCK():TextChangeBlocker {
		return new TextChangeBlocker();
	}

	public function new(block:TextChangeBlocker) {
		if (block == null) {
			throw new Error('TextChangeBase cannot be instantiated directly.');
		}
	}

	public function getReverse():TextChangeBase {
		throw new Error('TextChangeBase.getReverse must be overriden in sub-class.');
	}

}

class TextChangeBlocker {

}