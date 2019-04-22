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
package no.doomsday.console.core;

import flash.errors.Error;
import no.doomsday.console.core.interfaces.ILogger;
import no.doomsday.console.core.messages.Message;
import no.doomsday.console.core.commands.ConsoleCommand;
import flash.display.Sprite;
import flash.events.Event;
import no.doomsday.console.core.interfaces.IConsole;
import no.doomsday.console.core.messages.MessageTypes;

/**
 * ...
 * @author Andreas Rønning
 */
class AbstractConsole extends Sprite implements IConsole implements ILogger {

	private static inline var VERSION:String = '1.06a';

	public function new() {
		super();
		//throw new Error("Not implemented");
	}

	/* INTERFACE no.doomsday.console.core.interfaces.IConsole */

	public function show():Void {
		throw new Error('Not implemented');
	}

	public function hide():Void {
		throw new Error('Not implemented');
	}

	public function setInvokeKeys(keyCodes:Array<Dynamic> = null):Void {
		throw new Error('Not implemented');
	}

	public function setRepeatFilter(filter:Int):Void {
		throw new Error('Not implemented');
	}

	public function toggleStats(e:Event = null):Void {
		throw new Error('Not implemented');
	}

	public function routeToJS():Void {
		throw new Error('Not implemented');
	}

	public function alertErrors():Void {
		throw new Error('Not implemented');
	}

	public function screenshot(e:Event = null):Void {
		throw new Error('Not implemented');
	}

	public function addCommand(command:ConsoleCommand):Void {
		throw new Error('Not implemented');
	}

	public function print(str:String, type:Int = 2):Message {
		throw new Error('Not implemented');
	}

	public function clear():Void {
		throw new Error('Not implemented');
	}

	public function saveLog(e:Event = null):Void {
		throw new Error('Not implemented');
	}

	public function setPassword(pwd:String):Void {
		throw new Error('Not implemented');
	}

	public function runBatch(batch:String):Bool {
		throw new Error('Not implemented');
	}

	public function runBatchFromUrl(url:String):Void {
		throw new Error('Not implemented');
	}

	public function maximize():Void {
		throw new Error('Not implemented');
	}

	public function minimize():Void {
		throw new Error('Not implemented');
	}

	public function onEvent(e:Event):Void {
		throw new Error('Not implemented');
	}

	public function trace(args:Array<Dynamic> = null):Void {
		throw new Error('Not implemented');
	}

	public function log(args:Array<Dynamic> = null):Void {
		throw new Error('Not implemented');
	}

	public function dock(value:String):Void {
		throw new Error('Not implemented');
	}

	public function setChromeTheme(backgroundColor:Int = 0, backgroundAlpha:Float = 0.8, borderColor:Int = 0x333333, inputBackgroundColor:Int = 0, helpBackgroundColor:Int = 0x222222):Void {
		throw new Error('Not implemented');
	}

	public function setTextTheme(input:Int = 0xFFD900, oldMessage:Int = 0xBBBBBB, newMessage:Int = 0xFFFFFF, system:Int = 0x00DD00, timestamp:Int = 0xAAAAAA, error:Int = 0xEE0000, help:Int = 0xbbbbbb, trace:Int = 0x9CB79B, event:Int = 0x009900, warning:Int = 0xFFD900):Void {
		throw new Error('Not implemented');
	}

}