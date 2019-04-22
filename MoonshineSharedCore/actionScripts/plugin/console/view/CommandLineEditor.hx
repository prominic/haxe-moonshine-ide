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

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.SandboxMouseEvent;
import actionScripts.events.ChangeEvent;
import actionScripts.plugin.console.ConsoleCommandEvent;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.valueObjects.ConstantsCoreVO;

class CommandLineEditor extends TextEditor {

	private var history:Array<Dynamic> = [];
	private var historyIndex:Int = -1;

	public function new() {
		super(false);

		this.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
		this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 10);
		this.addEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
		//this.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, handleFocusOut);

		this.addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);
	}

	private function handleChange(event:ChangeEvent):Void {
		var change:TextChangeBase = event.change;

		if (Std.is(change, TextChangeInsert)) {
			applyChangeInsert(TextChangeInsert(change));
		} else if (Std.is(change, TextChangeMulti)) {
			applyChangeMulti(TextChangeMulti(change));
		}
	}

	private function handleKeyDown(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.DOWN:
				historyIndex--;
				if (historyIndex < 0) {
					// Cap to -1. Next 'up' action will bring it to 0 & the first history item.
					historyIndex = -1;
					dataProvider = '';
				} else {
					applyHistory();
				}
				event.preventDefault();
			case Keyboard.UP:
				historyIndex++;
				if (historyIndex >= history.length) {
					historyIndex = AS3.int(history.length - 1);
				}

				applyHistory();

				event.preventDefault();
			case Keyboard.ENTER:
				// Don't let TextEditor handle this,
				//  it'll split the line where the cursor is, which isn't console-standard.
				event.stopImmediatePropagation();

				// Get the line & exec it
				var line:String = model.selectedLine.text;
				exec(line);

				// Reset the console
				dataProvider = '';
		}
	}

	private function applyHistory():Void {
		if (history.length == 0) {
			return;
		}
		dataProvider = Std.string(history[historyIndex]);
		model.caretIndex = model.selectedLine.text.length;
	}

	private function applyChangeMulti(change:TextChangeMulti):Void {
		for (subchange in change.changes) {
			if (Std.is(subchange, TextChangeInsert)) {
				applyChangeInsert(TextChangeInsert(subchange));
			}
		}
	}

	// Used for pasting multi-line commands.
	private function applyChangeInsert(change:TextChangeInsert):Void {
		// Loop all lines and exec them in order
		if (model.lines.length > 1) {
			for (i in 0...model.lines.length - 1) {
				var m:TextLineModel = model.lines[i];

				exec(m.text);
			}

			dataProvider = '';
		}
	}

	private function exec(line:String):Void {
		var cmd:String = Std.string(StringTools.trim(line));
		if (cmd == '') {
			return;
		}

		// reset history index
		historyIndex = -1;
		// add to history
		history.unshift(line);

		var split:Array<String> = cmd.split(' ');
		var c:String = split[0];
		var args:Array<Dynamic> = split.splice(1, split.length);

		dispatchEvent(new ConsoleCommandEvent(c, args));
	}

	private function handleFocusOut(event:FocusEvent):Void {
		trace(event.type);
		hasFocus = false;
	}

	private function onMouseClicked(event:MouseEvent):Void {
		hasFocus = true;
	}

}