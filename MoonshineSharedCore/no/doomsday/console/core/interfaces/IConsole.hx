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
package no.doomsday.console.core.interfaces;

import flash.events.Event;
import no.doomsday.console.core.commands.ConsoleCommand;
import no.doomsday.console.core.messages.Message;

/**
 * ...
 * @author Andreas Rønning
 */
interface IConsole {

	function show():Void;

	function hide():Void;

	function setInvokeKeys(keyCodes:Array<Dynamic> = null):Void;

	function setRepeatFilter(filter:Int):Void;

	function toggleStats(e:Event = null):Void;

	function routeToJS():Void;

	function alertErrors():Void;

	function screenshot(e:Event = null):Void;

	function addCommand(command:ConsoleCommand):Void;

function print(str:String, type:Int = 2):Message;

	function clear():Void;

	function saveLog(e:Event = null):Void;

	function setPassword(pwd:String):Void;

	function runBatch(batch:String):Bool;

	function runBatchFromUrl(url:String):Void;

	function maximize():Void;

	function minimize():Void;

	function onEvent(e:Event):Void;

	function trace(args:Array<Dynamic> = null):Void;

	function log(args:Array<Dynamic> = null):Void;

	function dock(value:String):Void;

	function setChromeTheme(backgroundColor:Int = 0, backgroundAlpha:Float = 0.8, borderColor:Int = 0x333333, inputBackgroundColor:Int = 0, helpBackgroundColor:Int = 0x222222):Void;

	function setTextTheme(input:Int = 0xFFD900, oldMessage:Int = 0xBBBBBB, newMessage:Int = 0xFFFFFF, system:Int = 0x00DD00, timestamp:Int = 0xAAAAAA, error:Int = 0xEE0000, help:Int = 0xbbbbbb, trace:Int = 0x9CB79B, event:Int = 0x009900, warning:Int = 0xFFD900):Void;

}