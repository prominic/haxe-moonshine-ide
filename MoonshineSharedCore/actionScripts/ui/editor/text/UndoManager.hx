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
package actionScripts.ui.editor.text;

import flash.events.KeyboardEvent;
import actionScripts.events.ChangeEvent;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;

class UndoManager {

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var history:Array<TextChangeBase> = new Array<TextChangeBase>();
	private var future:Array<TextChangeBase> = new Array<TextChangeBase>();

	private var savedAt:Int = 0;

	public var hasChanged(get, never):Bool;
	private function get_hasChanged():Bool {
		// Uses history.length to figure out if file is changed
		return (savedAt != history.length);
	}

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;

		editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
	}

	public function save():Void {
		savedAt = history.length;
	}

	public function undo():Void {
		if (history.length > 0) {
			var change:TextChangeBase = history.pop();
			future.push(change);

			// Get reverse change, and dispatch to editor
			change = change.getReverse();
			if (change != null) {
				editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change, ChangeEvent.ORIGIN_UNDO));
			}
		}
	}

	public function redo():Void {
		if (future.length > 0) {
			var change:TextChangeBase = future.pop();
			history.push(change);

			// Redispatch change to editor
			editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change, ChangeEvent.ORIGIN_UNDO));
		}
	}

	public function clear():Void {
		as3hx.Compat.setArrayLength(history, 0);
		as3hx.Compat.setArrayLength(future, 0);
		savedAt = 0;
	}

	private function handleKeyDown(event:KeyboardEvent):Void {
		if (event.ctrlKey && !event.altKey) {
			switch (event.keyCode) {
				case 0x59:
					// Y
					redo();
				case 0x5A:
					// Z
					undo();
			}
		}
	}

	private function handleChange(event:ChangeEvent):Void {
		if (event.change != null && event.origin == ChangeEvent.ORIGIN_LOCAL) {
			collectChange(event.change);
		}
	}

	private function collectChange(change:TextChangeBase):Void {
		// Clear any future changes
		as3hx.Compat.setArrayLength(future, 0);
		// Check if change can be merged into last change
		if (Std.is(change, TextChangeInsert) && history.length > 0 && Std.is(history[history.length - 1], TextChangeInsert)) {
			var thisChange:TextChangeInsert = TextChangeInsert(change);
			var lastChange:TextChangeInsert = TextChangeInsert(history[history.length - 1]);

			// Merge if the last change was on the same line, and ended where this change starts
			if (
				thisChange.startLine == lastChange.startLine &&
				lastChange.textLines.length == 1 &&
				thisChange.startChar == lastChange.startChar + lastChange.textLines[0].length) {
				var textLines:Array<String> = thisChange.textLines.copy();
				textLines[0] = lastChange.textLines[0] + textLines[0];

				change = new TextChangeInsert(lastChange.startLine, lastChange.startChar, textLines);

				// Remove last change from history
				history.pop();
			}
		}
		// Add change to history
		history.push(change);
	}

}