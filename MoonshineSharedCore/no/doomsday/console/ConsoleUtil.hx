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
package no.doomsday.console;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import no.doomsday.console.core.AbstractConsole;
import no.doomsday.console.core.commands.FunctionCallCommand;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.DLogger;
import no.doomsday.console.utilities.ContextMenuUtil;
import no.doomsday.console.utilities.measurement.MeasurementTool;
import no.doomsday.console.core.messages.MessageTypes;

// import no.doomsday.console.utilities.ContextMenuUtilAir;
/**
 * ...
 * @author Andreas Rønning
 */
class ConsoleUtil {

	public static inline var MODE_CONSOLE:String = 'console';
	public static inline var MODE_LOGGER:String = 'logger';
	private static var _instance:AbstractConsole;

	public function new() {
		throw new Error('Use static methods');
	}

	/**
	 * Get the singleton console instance
	 */
	public static var instance(get, never):AbstractConsole;
	private static function get_instance():AbstractConsole {
		return getInstance();
	}

	public static function getInstance(type:String = MODE_CONSOLE):AbstractConsole {
		if (_instance == null) {
			switch (type) {
				case MODE_LOGGER:
					_instance = new DLogger();
					trace('Logger mode set');
				case _:
					_instance = new DConsole();
					trace('Console mode set');
			}
		}
		return _instance;
	}

	/**
	 * Add a message
	 * @param       msg
	 */
	public static function print(input:Dynamic):Void {
		instance.print(Std.string(Std.string(input)));
	}

	/**
	 * Add a message with system color coding
	 * @param       msg
	 */
	public static function addSystemMessage(msg:String):Void {
		instance.print(msg, MessageTypes.SYSTEM);
	}

	/**
	 * Add a message with error color coding
	 * @param       msg
	 */
	public static function addErrorMessage(msg:String):Void {
		instance.print(msg, MessageTypes.ERROR);
	}

	/**
	 * Legacy, deprecated. Use "createCommand" instead
	 */
	public static function linkFunction(triggerPhrase:String, func:Function, commandGroup:String = 'Application', helpText:String = ''):Void {
		createCommand(triggerPhrase, cast func, commandGroup, helpText);
	}

	/**
	 * Create a command for calling a specific function
	 * @param       triggerPhrase
	 * The trigger word for the command
	 * @param       func
	 * The function to call
	 * @param       commandGroup
	 * Optional: The group name you want the command sorted under
	 * @param       helpText
	 */
	public static function createCommand(triggerPhrase:String, func:Function, commandGroup:String = 'Application', helpText:String = ''):Void {
		instance.addCommand(new FunctionCallCommand(triggerPhrase, cast func, commandGroup, helpText));
	}

	/**
	 * Use this to print event messages on dispatch (addEventListener(Event.CHANGE, ConsoleUtil.onEvent))
	 */
	public static var onEvent(get, never):Function;
	private static function get_onEvent():Function {
		return instance.onEvent;
	}

	/**
	 * Add a message to the trace buffer
	 */
	public static var trace(get, never):Function;
	private static function get_trace():Function {
		return instance.trace;
	}

	public static function log(args:Array<Dynamic> = null):Void {
		instance.log.apply(instance, args);
	}

	public static var clear(get, never):Function;
	private static function get_clear():Function {
		return instance.clear;
	}

	/**
	 * Show the console
	 */
	public static function show():Void {
		instance.show();
	}

	/**
	 * Hide the console
	 */
	public static function hide():Void {
		instance.hide();
	}

	/**
	 * Sets the console docking position
	 * @param       position
	 * "top" or "bot"/"bottom"
	 */
	public static function dock(position:String):Void {
		instance.dock(position);
	}

	public static var password(never, set):String;
	private static function set_password(s:String):String {
		instance.setPassword(s);
		return s;
	}

	public static function setKeyStroke(keyCodes:Array<Dynamic> = null, charCodes:Array<Dynamic> = null):Void {
		if (charCodes == null) {
			charCodes = [];
		}
		if (keyCodes == null) {
			keyCodes = [];
		}
		instance.setInvokeKeys(keyCodes, charCodes);
	}

}