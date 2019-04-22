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
package no.doomsday.console.core.text;

import flash.errors.Error;
import actionScripts.extResources.com.adobe.serialization.json.Json;
import no.doomsday.console.core.commands.CommandArgument;

/**
 * ...
 * @author Andreas Rønning
 */
class ParseUtils {

	public function new() {}

	public static function parseForJson(arg:String):Dynamic {
		try {
			var ret:Dynamic = json.decode(arg);
			return ret;
		} catch (e:Error) {
			return arg;
		}
	}

	public static function parseForArrays(commandArgs:Array<CommandArgument>):Array<CommandArgument> {
		for (i in 0...commandArgs.length) {
			try {
				var test:Dynamic = json.decode(commandArgs[i].data);
				commandArgs[i].data = test;
			} catch (e:Error) {}
		}
		return commandArgs;
	}

}