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
package actionScripts.utils;

import actionScripts.events.ChangeEvent;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.ui.editor.text.change.TextChangeRemove;
import actionScripts.valueObjects.Position;
import actionScripts.valueObjects.Range;
import actionScripts.valueObjects.TextEdit;

/**
 * Class for applyTextEditsToTextEditor
 */
@:final class ApplyTextEditsToTextEditor {

	public static function applyTextEditsToTextEditor(textEditor:TextEditor, textEdits:Array<TextEdit>):Void {
		var multi:TextChangeMulti = new TextChangeMulti();
		var textEditsCount:Int = textEdits.length;
		var line:Int = textEditor.model.selectedLineIndex;
		var char:Int = textEditor.model.caretIndex;
		var scrollPosition:Int = textEditor.model.scrollPosition;
		for (i in 0...textEditsCount) {
			var change:TextEdit = textEdits[i];
			var range:Range = change.range;
			var start:Position = range.start;
			var end:Position = range.end;
			var insert:TextChangeInsert = new TextChangeInsert(start.line, start.character, change.newText.split('\n'));
			if (start.line != end.line || start.character != end.character) {
				var remove:TextChangeRemove = new TextChangeRemove(start.line, start.character, end.line, end.character);
				multi.changes.push(remove);
				if (end.line > start.line) {
					line -= AS3.int(end.line - start.line);
				}
			}
			multi.changes.push(insert);
			if (start.line <= line) {
				line += AS3.int(insert.textLines.length - 1);
			}
		}
		textEditor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multi));
		textEditor.model.selectedLineIndex = line;
		textEditor.model.caretIndex = char;
		textEditor.scrollTo(scrollPosition);
	}

}