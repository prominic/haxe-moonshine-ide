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
package actionScripts.plugin.console;

import flash.events.EventDispatcher;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.utils.HtmlFormatter;
import no.doomsday.console.ConsoleUtil;

class ConsoleOutputter extends EventDispatcher {

	public static var DEBUG:Bool = true;

	private static var _name:String = '';

	public var name(get, never):String;
	private function get_name():String {
		return _name;
	}

	private function success(str:String, replacements:Array<Dynamic> = null):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'success');
	}

	// Console output functions, use %s for substitution
	private function notice(str:String, replacements:Array<Dynamic> = null):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'notice');
	}

	private function error(str:String, replacements:Array<Dynamic> = null):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'error');
	}

	private function warning(str:String, replacements:Array<Dynamic> = null):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'warning');
	}

	private function print(str:String, replacements:Array<Dynamic> = null):Void {
		ConsoleUtil.print(str);
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
	}

	private function debug(str:String, replacements:Array<Dynamic> = null):Void {
		if (DEBUG) {
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
		}
	}

	public static function formatOutput(str:String, style:String, showWhenDone:Bool = true):Array<TextLineModel> {
		var textLines:Array<String> = str.split('\n');
		var lines:Array<TextLineModel> = [];
		for (i in 0...textLines.length) {
			if (textLines[i] == '') {
				continue;
			}
			var text:String = HtmlFormatter.sprintf('<%x>%x:</%x> %x', style, _name, style, textLines[i]);
			var lineModel:TextLineModel = new ConsoleTextLineModel(text, style);
			lines.push(lineModel);
		}

		if (showWhenDone) {
			outputMsg(lines);
			return null;
		}

		return lines;
	}

	private static function outputMsg(msg:Dynamic):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, msg));
	}

	private function clearOutput():Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_CLEAR, null, true));
	}

	public function new() {
		super();
	}

}