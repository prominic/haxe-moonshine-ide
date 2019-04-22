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
package no.doomsday.console.core.input;

import flash.errors.Error;
import flash.display.InteractiveObject;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;

/**
 * Maintains a dictionary of key up/down states
 * @author Andreas Rønning
 */
class KeyboardManager extends EventDispatcher {

	private static var INSTANCE:KeyboardManager;

	/**
	 * Gets a singleton instance of the input manager
	 * @return
	 */
	public static var instance(get, never):KeyboardManager;
	private static function get_instance():KeyboardManager {
		if (INSTANCE == null) {
			INSTANCE = new KeyboardManager();
		}
		return INSTANCE;
	}

	private var keyboardSource:Dynamic = null;
	public var keydict:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	/**
	 * Start tracking keyboard events
	 * If already tracking, previous event listeners will be removed
	 * @param	eventSource
	 * The object whose events to respond to (typically stage)
	 */
	public function setup(eventSource:InteractiveObject):Void {
		try {
			shutdown();
		} catch (e:Error) {}
		keydict = new Dictionary(false);
		keyboardSource = eventSource;
		eventSource.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, AS3.int(Math.POSITIVE_INFINITY), true);
		eventSource.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, AS3.int(Math.POSITIVE_INFINITY), true);
	}

	/**
	 * Stop tracking keyboard events
	 */
	public function shutdown():Void {
		keyboardSource.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		keyboardSource.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		keyboardSource = null;
		keydict = new Dictionary(false);
	}

	public var isTracking(get, never):Bool;
	private function get_isTracking():Bool {
		if (AS3.as(keyboardSource, Bool)) {
			return true;
		}
		return false;
	}

	private function onKeyUp(e:KeyboardEvent):Void {
		keydict.set(e.keyCode, false);
	}

	private function onKeyDown(e:KeyboardEvent):Void {
		keydict.set(e.keyCode, true);
	}

	/**
	 * Check wether a given key is currently pressed
	 * @param	keyCode
	 * @return
	 */
	public function keyIsDown(keyCode:Int):Bool {
		return keydict.get(keyCode) != null;
	}

	public function new() {
		super();
	}

}