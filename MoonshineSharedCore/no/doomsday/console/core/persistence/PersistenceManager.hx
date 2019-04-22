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
package no.doomsday.console.core.persistence;

import actionScripts.utils.SharedObjectConst;
import flash.net.SharedObject;
import no.doomsday.console.core.commands.ConsoleCommand;
import no.doomsday.console.core.DConsole;

/**
 * ...
 * @author Andreas Rønning
 */
class PersistenceManager {

	private var console:DConsole;
	private var _numLines:Int = 10;
	private var _previousCommands:Array<Dynamic>;
	private var _commandIndex:Int = 0;
	private var historySO:SharedObject;
	public var maxHistory:Int = 10;
	private var _dockState:Int = 0;

	public function new(console:DConsole) {
		this.console = console;
		historySO = SharedObject.getLocal(SharedObjectConst.CONSOLE_HISTORY);
		if (!AS3.as(Reflect.field(historySO.data, 'history'), Bool)) {
			Reflect.setField(historySO.data, 'history', []);
		}
		if (!AS3.as(Reflect.field(historySO.data, 'numLines'), Bool)) {
			Reflect.setField(historySO.data, 'numLines', numLines);
		}
		if (!AS3.as(Reflect.field(historySO.data, 'dockState'), Bool)) {
			Reflect.setField(historySO.data, 'dockState', _dockState);
		}
		numLines = AS3.int(Reflect.field(historySO.data, 'numLines'));
		previousCommands = Reflect.field(historySO.data, 'history');
		_dockState = AS3.int(Reflect.field(historySO.data, 'dockState'));
		commandIndex = previousCommands.length;
	}

	public function clearHistory():Void {
		Reflect.setField(historySO.data, 'history', []);
	}

	public var dockState(get, set):Int;
	private function get_dockState():Int {
		return _dockState;
	}

	private function set_dockState(value:Int):Int {
		_dockState = value;
		Reflect.setField(historySO.data, 'dockState', _dockState);
		return value;
	}

	public var commandIndex(get, set):Int;
	private function get_commandIndex():Int {
		return _commandIndex;
	}

	private function set_commandIndex(value:Int):Int {
		_commandIndex = value;
		return value;
	}

	public var previousCommands(get, set):Array<Dynamic>;
	private function get_previousCommands():Array<Dynamic> {
		return _previousCommands;
	}

	private function set_previousCommands(value:Array<Dynamic>):Array<Dynamic> {
		_previousCommands = value;
		Reflect.setField(historySO.data, 'history', _previousCommands);
		return value;
	}

	public var numLines(get, set):Int;
	private function get_numLines():Int {
		return _numLines;
	}

	private function set_numLines(value:Int):Int {
		_numLines = value;
		Reflect.setField(historySO.data, 'numLines', _numLines);
		return value;
	}

	public function historyUp():String {
		if (previousCommands.length > 0) {
			commandIndex = AS3.int(Math.max(commandIndex -= 1, 0));
			return Std.string(previousCommands[commandIndex]);
		}
		return '';
	}

	public function historyDown():String {
		if (commandIndex < previousCommands.length - 1) {
			commandIndex = AS3.int(Math.min(commandIndex += 1, previousCommands.length - 1));
			return Std.string(previousCommands[commandIndex]);
		}
		return '';
	}

	public function addtoHistory(cmdStr:String):Bool {
		if (previousCommands[previousCommands.length - 1] != cmdStr) {
			previousCommands.push(cmdStr);
			if (previousCommands.length > maxHistory) {
				previousCommands.shift();
			}
		}
		commandIndex = previousCommands.length;
		return true;
	}

}