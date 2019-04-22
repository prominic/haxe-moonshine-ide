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
package actionScripts.plugin;

import flash.errors.Error;
import flash.events.EventDispatcher;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.console.view.ConsoleModeEvent;

class PluginBase extends ConsoleOutputter implements IPlugin {

	override private function get_name():String {
		throw new Error('You need to give a unique name.');
	}

	public var author(get, never):String;
	private function get_author():String {
		return 'N/A';
	}

	public var description(get, never):String;
	private function get_description():String {
		return 'A plugin base that plugins can extend to gain easier access to some functionality.';
	}

	/**
	 * ensures if the plugin will be activated by default when the plugin
	 * is loaded for the first time (without settings xml file written)
	 * */
	public var activatedByDefault(get, never):Bool;
	private function get_activatedByDefault():Bool {
		return true;
	}

	private static var commands:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private static var mode:String = '';

	private var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();
	private var model:IDEModel = IDEModel.getInstance();

	private var _activated:Bool = false;

	public var activated(get, never):Bool;
	private function get_activated():Bool {
		return _activated;
	}

	public function activate():Void {
		_activated = true;
	}

	public function deactivate():Void {
		_activated = false;
	}

	public function resetSettings():Void {}

	public function new() {
		super();
	}

	// Console command functions
	private function registerCommand(commandName:String, commandObj:Dynamic):Void {commands.set(commandName, commandObj);
	}

	private function unregisterCommand(commandName:String):Void {
		This is an intentional compilation error. See the README for handling the delete keyword
		delete console;commands.get(commandName);
	}

	private function enterConsoleMode(newMode:String):Void {mode = newMode;
		dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, newMode));
	}

	private function exitConsoleMode():Void {mode = '';
		dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, ''));
	}

	private static var PluginBase_static_initializer = {
		protected;
		namespace;
		console;
		true;
	}

}