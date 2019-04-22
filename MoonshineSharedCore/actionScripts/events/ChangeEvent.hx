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
package actionScripts.events;

import flash.events.Event;
import actionScripts.ui.editor.text.change.TextChangeBase;

class ChangeEvent extends Event {

	public static inline var TEXT_CHANGE:String = 'textChange';

	public static inline var ORIGIN_LOCAL:String = 'local';
	public static inline var ORIGIN_UNDO:String = 'undo';
	public static inline var ORIGIN_REMOTE:String = 'remote';

	private var _change:TextChangeBase;
	private var _origin:String;

	public var change(get, never):TextChangeBase;
	private function get_change():TextChangeBase {
		return _change;
	}

	public var origin(get, never):String;
	private function get_origin():String {
		return _origin;
	}

	public function new(type:String, change:TextChangeBase, origin:String = ORIGIN_LOCAL) {
		super(type, false, false);

		_change = change;
		_origin = origin;
	}

	override public function clone():Event {
		return new ChangeEvent(type, change, origin);
	}

}