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
package no.doomsday.console.core.events;

import flash.events.Event;

class DLoggerEvent extends Event {

	public static inline var LOG:String = 'log';
	public static inline var DESCRIBE:String = 'describe';

	public static inline var CODE_SUCCESS:Int = 0;
	public static inline var CODE_INFO:Int = 2;
	public static inline var CODE_EVENT:Int = 2;
	public static inline var CODE_ERROR:Int = 3;
	public static inline var CODE_WARNING:Int = 4;
	public static inline var CODE_TRACE:Int = 5;

	public var appendLast:Bool = false;
	public var message:Dynamic;
	public var severity:Int = 0;
	public var origin:Dynamic;

	public function new(__DOLLAR__type:String,
			__DOLLAR__message:Dynamic,
			__DOLLAR__appendLast:Bool = false,
			__DOLLAR__severity:Int = 0,
			__DOLLAR__origin:Dynamic = null,
			__DOLLAR__bubbles:Bool = false,
			__DOLLAR__cancelable:Bool = false) {
		super(__DOLLAR__type, __DOLLAR__bubbles, __DOLLAR__cancelable);

		message = __DOLLAR__message;
		appendLast = __DOLLAR__appendLast;
		severity = __DOLLAR__severity;
		origin = __DOLLAR__origin;
	}

	/**
	 * Creates and returns a copy of the current instance.
	 * @return A copy of the current instance.
	 */
	override public function clone():Event {
		return new DLoggerEvent(type, message, appendLast, severity, origin, bubbles, cancelable);
	}

	/**
	 * Returns a String containing all the properties of the current
	 * instance.
	 * @return A string representation of the current instance.
	 */
	override public function toString():String {
		return formatToString('AILoggerEvent', 'type', 'message', 'appendLast', 'severity', 'origin', 'bubbles', 'cancelable', 'eventPhase');
	}

}