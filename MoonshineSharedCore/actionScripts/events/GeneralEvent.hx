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

class GeneralEvent extends Event {

	public static inline var DONE:String = 'DONE';
	public static inline var DEVICE_UPDATED:String = 'DEVICE_UPDATED';
	public static inline var RESET_ALL_SETTINGS:String = 'RESET_ALL_SETTINGS';
	public static inline var SCROLL_TO_TOP:String = 'SCROLL_TO_TOP';

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, _bubble:Bool = false, _cancelable:Bool = true) {
		this.value = value;
		super(type, _bubble, _cancelable);
	}

}