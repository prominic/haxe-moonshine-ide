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
package no.doomsday.utilities.controller;

import flash.events.Event;

/**
 * ...
 * @author Andreas Rønning
 */
class ControllerEvent extends Event {

	public static inline var VALUE_CHANGE:String = 'valuechange';

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);

	}

	override public function clone():Event {
		return new ControllerEvent(type, bubbles, cancelable);
	}

	override public function toString():String {
		return formatToString('ControllerEvent', 'type', 'bubbles', 'cancelable', 'eventPhase');
	}

}