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
package actionScripts.plugin.console.view;

import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.TextLineModel;

class ConsoleHistoryTextArea extends TextEditor {

	public function new() {
		super(true);
	}

	public var numLines(get, never):Int;
	private function get_numLines():Int {
		return model.lines.length;
	}

	public var numVisibleLines(get, never):Int;
	private function get_numVisibleLines():Int {
		return model.renderersNeeded;
	}

	override public function setFocus():Void {
		super.setFocus();
		// Never allow focus, which means no blinky cursor
		hasFocus = false;
	}

	public function appendText(text:Dynamic):Int {
		invalidateLines();

		// Remove initial empty line (first time anything is outputted)
		if (model.lines.length == 1) {
			if (model.selectedLine.text == '') {
				model.lines = cast new Array<TextLineModel>();
			}
		}

		if (Std.is(text, String)) {
			var lines:Array<Dynamic> = text.split('\n');
			for (i in 0...lines.length) {
				model.lines.push(new TextLineModel(Std.string(lines[i])));
			}

			model.scrollPosition = AS3.int(Math.max(0, model.lines.length - model.renderersNeeded + 1));
			invalidateLines();

			return lines.length;
		} else if (Std.is(text, Array/*Vector.<T> call?*/)) {
			for (i in 0...text.length) {
				model.lines.push(Reflect.field(text, Std.string(i)));
			}

			model.scrollPosition = AS3.int(Math.max(0, model.lines.length - model.renderersNeeded + 1));
			invalidateLines();

			return AS3.int(text.length);
		}

		return 0;
	}

}