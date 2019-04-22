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
package no.doomsday.console.utilities.controller;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

/**
 * ...
 * @author Andreas Rønning
 */
class ControllerManager extends Sprite {

	private var controllers:Array<Controller> = new Array<Controller>();

	public function new() {
		super();
	}

	public function createController(object:Dynamic, properties:Array<Dynamic>, x:Float = 0, y:Float = 0):Void {
		var c:Controller = new Controller(object, properties, this);
		c.x = x;
		c.y = y;
		controllers.push(AS3.as(addChild(c), Controller));
	}

	public function removeController(c:Controller):Void {
		for (i in 0...controllers.length) {
			if (controllers[i] == c) {
				controllers.splice(i, 1);
				removeChild(c);
				break;
			}
		}
	}

	public function start():Void {
		addEventListener(Event.ENTER_FRAME, update);
	}

	public function stop():Void {
		removeEventListener(Event.ENTER_FRAME, update);
	}

	private function update(e:Event):Void {
		for (i in 0...controllers.length) {
			controllers[i].update();
		}
	}

}