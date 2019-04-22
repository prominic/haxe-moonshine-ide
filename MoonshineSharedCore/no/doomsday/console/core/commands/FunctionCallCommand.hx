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

import haxe.Constraints.Function;

/**
 * ...
 * @author Andreas Rønning
 */
class FunctionCallCommand extends ConsoleCommand {

	private var callbackDict:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	/**
	 * Creates a callback command, which calls a function when triggered
	 * @param	trigger
	 * The trigger phrase
	 * @param	callback
	 * The function to call
	 */
	public function new(trigger:String, callback:Function, grouping:String = 'Application', helpText:String = '') {
		callbackDict = new Dictionary(true);
		callbackDict.set('callback', callback);
		super(trigger);
		this.grouping = grouping;
		this.helpText = helpText;
	}

	public var callback(get, never):Function;
	private function get_callback():Function {
		return cast cast callbackDict.get('callback');
	}

}