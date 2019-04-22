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
package no.doomsday.console.core.commands;

import flash.errors.Error;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.introspection.InspectionUtils;
import no.doomsday.console.core.messages.MessageTypes;
import no.doomsday.console.core.persistence.PersistenceManager;
import no.doomsday.console.core.references.ReferenceManager;
import no.doomsday.console.core.text.ParseUtils;
import no.doomsday.console.core.text.TextUtils;

/**
 * ...
 * @author Andreas Rønning
 */
class CommandManager {

	private var console:DConsole;
	private var persistence:PersistenceManager;
	private var commands:Array<ConsoleCommand>;
	private var password:String = '';
	private var authenticated:Bool = true;
	private var authCommand:FunctionCallCommand;
	private var deAuthCommand:FunctionCallCommand;
	private var authenticationSetup:Bool = false;
	private var referenceManager:ReferenceManager;

	public function new(console:DConsole, persistence:PersistenceManager, referenceManager:ReferenceManager) {
		this.authCommand = new FunctionCallCommand('authorize', this.authenticate, 'System', 'Input password to gain console access');
		this.deAuthCommand = new FunctionCallCommand('deauthorize', this.lock, 'System', 'Lock the console from unauthorized user access');
		this.persistence = persistence;
		this.console = console;
		this.referenceManager = referenceManager;
		commands = cast new Array<ConsoleCommand>();
	}

	public function addCommand(c:ConsoleCommand):Void {
		commands.push(c);
		commands.sort(sortCommands);
	}

	private function sortCommands(a:ConsoleCommand, b:ConsoleCommand):Int {
		if (a.grouping == b.grouping) {
			return -1;
		}
		return 1;
	}

	public function tryCommand(input:String, sub:Bool = false):Dynamic {
		var cmdStr:String = TextUtils.stripWhitespace(input);
		var args:Array<Dynamic>;
		try {
			args = ArgumentSplitterUtil.slice(cmdStr);
		} catch (e:Error) {
			console.print(e.getStackTrace(), MessageTypes.ERROR);
			throw e;
		}
		var str:String = Std.string(args.shift().toLowerCase());
		if (!authenticated && str != authCommand.trigger) {
			if (!sub) {
				console.print('Not authenticated', MessageTypes.ERROR);
			}
			throw new Error('Not authenticated');
		}
		if (str != authCommand.trigger && !sub) {
			persistence.addtoHistory(input);
		}

		var commandArgs:Array<CommandArgument> = new Array<CommandArgument>();
		for (i in 0...args.length) {
			commandArgs.push(new CommandArgument(Std.string(args[i]), this, referenceManager));
		}

		for (i in 0...commands.length) {
			if (commands[i].trigger.toLowerCase() == str) {
				try {
					var val:Dynamic = doCommand(commands[i], cast commandArgs, sub);
				} catch (e:Error) {
					throw (e);
				}
				if (!sub && val != null && val != null) {
					console.print(val);
				}
				return val;
			}
		}
		throw new Error('No such command');
	}

	public function doCommand(command:ConsoleCommand, commandArgs:Array<CommandArgument> = null, sub:Bool = false):Dynamic {
		if (commandArgs == null) {
			commandArgs = new Array<CommandArgument>();
		}
		var args:Array<Dynamic> = [];
		for (i in 0...commandArgs.length) {
			args.push(commandArgs[i].data);
		}
		var val:Dynamic;
		if (Std.is(command, FunctionCallCommand)) {
			var func:FunctionCallCommand = (AS3.as(command, FunctionCallCommand));
			try {
				val = Reflect.callMethod(null, func.callback, args);
				return val;
			} catch (e:Error) {
				//try again with all args as string
				try {
					var joint:String = args.join(' ');
					if (joint.length > 0) {
						val = Reflect.callMethod(null, func.callback, [joint]);
					} else {
						val = Reflect.callMethod(null, func.callback, []);
					}
					return val;
				} catch (e:Error) {
					console.print(e.getStackTrace(), MessageTypes.ERROR);
					return null;
				}
				throw new Error(e.message);
			} catch (e:Error) {
				console.print(e.getStackTrace(), MessageTypes.ERROR);
				return null;
			}
		} else {
			console.print('Abstract command, no action', MessageTypes.ERROR);
			return null;
		}
	}

	/**
	 * List available command phrases
	 */
	public function listCommands(searchStr:String = null):Void {
		var str:String = 'Available commands: ';
		if (searchStr != null) {
			str += ' (search for \'' + searchStr + '\')';
		}
		console.print(str, MessageTypes.SYSTEM);
		for (i in 0...commands.length) {
			if (searchStr != null) {
				var joint:String = commands[i].grouping + commands[i].trigger + commands[i].helpText + commands[i].returnType;
				if (joint.toLowerCase().indexOf(searchStr) == -1) {
					continue;
				}
			}
			console.print('	--> ' + commands[i].grouping + ' : ' + commands[i].trigger, MessageTypes.SYSTEM);
		}
	}

	public function parseForCommand(str:String):ConsoleCommand {
		var i:Int = commands.length;
		while (i-- != 0) {
			if (commands[i].trigger.toLowerCase() == str.split(' ')[0].toLowerCase()) {
				return commands[i];
			}
		}
		throw new Error('No command found');
	}

	public function parseForSubCommand(arg:String):Dynamic {
		return arg;
	}

	//authentication
	public function setupAuthentication(password:String):Void {
		this.password = password;
		authenticated = false;
		if (authenticationSetup) {
			return;
		}
		authenticationSetup = true;
		console.addCommand(authCommand);
		console.addCommand(deAuthCommand);
	}

	private function lock():Void {
		authenticated = false;
		console.print('Deauthorized', MessageTypes.SYSTEM);
	}

	public function authenticate(password:String):Void {
		if (password == this.password) {
			authenticated = true;
			console.print('Authorized', MessageTypes.SYSTEM);
		} else {
			console.print('Not authorized', MessageTypes.ERROR);
		}
	}

	public function doSearch(search:String):Array<String> {
		var result:Array<String> = new Array<String>();
		var s:String = search.toLowerCase();
		for (i in 0...commands.length) {
			var c:ConsoleCommand = commands[i];
			if (c.trigger.toLowerCase().indexOf(s, 0) > -1) {
				result.push(c.trigger);
			}
		}
		return result;
	}

}