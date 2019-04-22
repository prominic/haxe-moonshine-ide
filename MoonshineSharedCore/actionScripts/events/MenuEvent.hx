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

class MenuEvent extends Event {

	private var _data:Dynamic;

	public static inline var ITEM_SELECTED:String = 'itemSelected';

	public function new(type:String,
			bubbles:Bool = false, cancelable:Bool = false,
			data:Dynamic = null) {
		super(type, bubbles, cancelable);
		_data = data;
	}

	public var data(get, never):Dynamic;
	private function get_data():Dynamic {
		return _data;
	}

	override public function clone():Event {
		return new MenuEvent(type, bubbles, cancelable, data);
	}

}