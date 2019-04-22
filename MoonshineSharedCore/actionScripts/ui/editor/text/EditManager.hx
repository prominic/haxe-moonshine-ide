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

import actionScripts.events.ChangeEvent;
import actionScripts.locator.IDEModel;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.ui.editor.text.change.TextChangeRemove;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Settings;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;

class EditManager extends EventDispatcher {

	private var editor:TextEditor;
	private var model:TextEditorModel;
	private var cm:ContextMenu;
	private var toCopy:String = '';
	private var deleteItem:ContextMenuItem;
	private var saveItem:ContextMenuItem;
	private var readOnly:Bool = false;

	public function new(editor:TextEditor, model:TextEditorModel, readOnly:Bool) {
		super();
		this.editor = editor;
		this.model = model;
		this.readOnly = readOnly;

		if (readOnly) {
			editor.addEventListener(KeyboardEvent.KEY_DOWN, readonlyKeyDown);
		} else {
			editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			editor.addEventListener(TextEvent.TEXT_INPUT, handleTextInput);
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange, false, 100);
		}

		//create a Context Menu for Editor
		cm = new ContextMenu();
		this.editor.addEventListener(Event.COPY, contextMenuHandler);
		this.editor.addEventListener(Event.CUT, contextMenuHandler);
		this.editor.addEventListener(Event.PASTE, contextMenuHandler);
		this.editor.addEventListener(Event.CLEAR, contextMenuHandler);
		cm.addEventListener(ContextMenuEvent.MENU_SELECT, menuActivateHandler);
		saveItem = new ContextMenuItem('Save', false, true, true);
		saveItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, customItemHandler);
		cm.customItems.push(saveItem);
		cm.clipboardMenu = true;
		this.editor.contextMenu = cm;
	}

	//Context menu Handler for enable clipboard Items
	private function menuActivateHandler(e:Event):Void {
		if (this.editor.getSelection().length > 0) {
			cm.clipboardItems.copy = true;
			cm.clipboardItems.cut = true;
			cm.clipboardItems.paste = true;
			cm.clipboardItems.clear = true;
		} else if (toCopy.length > 0) {
			cm.clipboardItems.copy = false;
			cm.clipboardItems.cut = false;
			cm.clipboardItems.paste = true;
			cm.clipboardItems.clear = false;
		} else {
			cm.clipboardItems.copy = false;
			cm.clipboardItems.cut = false;
			cm.clipboardItems.paste = false;
			cm.clipboardItems.clear = false;
		}
	}

	//handler for clipboardItem
	private function contextMenuHandler(e:Event):Void {
		if (e.type == 'copy') {
			handleCopy(e);
			e.preventDefault();
		}
		if (e.type == 'paste') {
			handlePaste(e);
			e.preventDefault();
		}
		if (e.type == 'cut') {
			handleCut(e);
			e.preventDefault();
		}
		if (e.type == 'clear') {
			removeAtCursor(true, true);
		}

	}

	//Handler for Custom menu item
	private function customItemHandler(e:Event):Void {
		if (Reflect.field(e.target, 'caption') == 'Save') {
			var IDEmodel:IDEModel = IDEModel.getInstance();
			var editor:IContentWindow = AS3.as(IDEmodel.activeEditor, IContentWindow);

			editor.save();
		}
	}

	private function readonlyKeyDown(event:KeyboardEvent):Void {
		// Only allow copy
		if (event.keyCode == 0x43) {
			// C
			{
				handleCopy(event);
			}
		}
	}

	private function handleKeyDown(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				insert('\n');
			case Keyboard.BACKSPACE:
				removeAtCursor(false, Reflect.getProperty(event, Settings.keyboard.wordModifierKey) != null);
			case Keyboard.DELETE:
				removeAtCursor(true, Reflect.getProperty(event, Settings.keyboard.wordModifierKey) != null);
			case Keyboard.TAB:
				indent(event.shiftKey);
				event.preventDefault();
			case 0x43, 0x56, 0x58:
				switch (event.keyCode) {case 0x43:
						// C
						{
							if (Reflect.getProperty(event, Settings.keyboard.copyModifierKey) != null && !event.altKey) {
								handleCopy(event);
								event.preventDefault();
							}
							break;
						}
				}
				switch (event.keyCode) {case 0x56:
						// V
						{
							if (Reflect.getProperty(event, Settings.keyboard.copyModifierKey) != null && !event.altKey) {
								handlePaste(event);
								event.preventDefault();
							}
							break;
						}
				}
				// X
				{
					if (Reflect.getProperty(event, Settings.keyboard.copyModifierKey) != null && !event.altKey) {
						handleCut(event);
						event.preventDefault();
					}
					break;
				}
		}
		// Prevent COMMAND key combinations from ever triggering text input
		// CHECK COMMAND KEY VALUE FOR MAC
		if (event.keyCode == 25) {
			event.preventDefault();
		}
	}

	public function setCompletionData(start:Int, end:Int, s:String):Void {
		var lineIndex:Int = model.selectedLineIndex;

		var change:TextChangeBase = new TextChangeInsert(
		lineIndex,
		start,
		new as3hx.Compat.Regex('\\r\\n?', 'g').replace(s, '\n').split('\n'));

		if (start < end) {
			change = new TextChangeMulti(
					new TextChangeRemove(lineIndex, start, lineIndex, end),
					change);
		}

		dispatchChange(change);
	}

	private function handleTextInput(event:TextEvent):Void {
		// Insert text only if it contains non-control characters (via http://www.fileformat.info/info/unicode/category/Cc/list.htm)
		if (AS3.as(new as3hx.Compat.Regex('[^\\x00-\\x1F\\x7F\\x80-\\x9F]', '').test(event.text), Bool)) {
			insert(event.text);
		}
	}

	private function insert(s:String):Void {
		var change:TextChangeBase;
		var line:Int = model.selectedLineIndex;
		var char:Int = model.caretIndex;

		if (model.hasSelection) {
			if (model.hasMultilineSelection) {
				if (line > model.selectionStartLineIndex) {
					line = model.selectionStartLineIndex;
					char = model.selectionStartCharIndex;
				}
			} else {
				char = AS3.int(Math.min(char, model.selectionStartCharIndex));
			}
		}

		change = new TextChangeInsert(
				line,
				char,
				new as3hx.Compat.Regex('\\r\\n?', 'g').replace(s, '\n').split('\n'));

		if (model.hasSelection) {
			change = new TextChangeMulti(
					removeSelection(),
					change);
		}

		dispatchChange(change);
	}

	private function removeAtCursor(afterCaret:Bool = false, word:Bool = false):Void {
		var change:TextChangeRemove;

		if (model.hasSelection) {
			change = removeSelection();
		} else {
			var startLine:Int = model.selectedLineIndex;
			var endLine:Int = model.selectedLineIndex;
			var startChar:Int = model.caretIndex;
			var endChar:Int = model.caretIndex;

			// Backspace remove line & append to line above it
			if (startChar == 0 && !afterCaret) {
				// Can't remove first line with backspace
				if (startLine == 0) {
					return;
				}

				startLine--;
				startChar = model.lines[startLine].text.length;
				endChar = 0;
			}// Delete remove linebreak & append to line below it
			else if (startChar == model.lines[startLine].text.length && afterCaret) {
				if (startLine == model.lines.length - 1) {
					return;
				}

				endLine++;
				startChar = model.lines[startLine].text.length;
				endChar = 0;
			} else if (afterCaret) {
				// Delete
				{
					endChar += (word) ? TextUtil.wordBoundaryForward(Std.string(model.lines[startLine].text.substring(startChar))) : 1;
				}
			}// Backspace
			else {
				startChar -= (word) ? TextUtil.wordBoundaryBackward(Std.string(model.lines[startLine].text.substring(0, endChar))) : 1;
			}

			change = new TextChangeRemove(
					startLine,
					startChar,
					endLine,
					endChar);
		}

		dispatchChange(change);
	}

	private function removeSelection():TextChangeRemove {
		var startChar:Int;
		var endChar:Int;
		var startLine:Int;
		var endLine:Int;

		if (model.hasMultilineSelection) {
			if (model.selectionStartLineIndex < model.selectedLineIndex) {
				startLine = model.selectionStartLineIndex;
				endLine = model.selectedLineIndex;
				startChar = model.selectionStartCharIndex;
				endChar = model.caretIndex;
			} else {
				startLine = model.selectedLineIndex;
				endLine = model.selectionStartLineIndex;
				startChar = model.caretIndex;
				endChar = model.selectionStartCharIndex;
			}
		} else {
			startLine = model.selectedLineIndex;
			endLine = startLine;
			startChar = AS3.int(Math.min(model.selectionStartCharIndex, model.caretIndex));
			endChar = AS3.int(Math.max(model.selectionStartCharIndex, model.caretIndex));
		}

		return new TextChangeRemove(
		startLine,
		startChar,
		endLine,
		endChar);
	}

	private function indent(decrease:Bool = false):Void {
		if (model.hasMultilineSelection) {
			var changes:Array<TextChangeBase> = new Array<TextChangeBase>();
			var startLine:Int;
			var endLine:Int;
			var startChar:Int;
			var endChar:Int;

			if (model.selectionStartLineIndex < model.selectedLineIndex) {
				startLine = model.selectionStartLineIndex;
				endLine = model.selectedLineIndex;
				startChar = model.selectionStartCharIndex;
				endChar = model.caretIndex;
			} else {
				startLine = model.selectedLineIndex;
				endLine = model.selectionStartLineIndex;
				startChar = model.caretIndex;
				endChar = model.selectionStartCharIndex;
			}

			if (startChar == model.lines[startLine].text.length) {
				startLine++;
			}
			if (endChar == 0) {
				endLine--;
			}

			for (line in startLine...endLine + 1) {
				if (decrease) {
					if (model.lines[line].text.charAt(0) == '\t') {
						changes.push(new TextChangeRemove(line, 0, line, 1));
					}
				} else {
					changes.push(new TextChangeInsert(line, 0, ['\t']));
				}
			}

			if (changes.length != 0) {
				dispatchChange(new TextChangeMulti(changes));

				model.setSelection(startLine, 0, endLine + 1, 0);
				editor.invalidateSelection();
			}
		} else if (decrease) {
			line = model.selectedLineIndex;
			if (model.lines[line].text.charAt(0) == '\t') {
				dispatchChange(
						new TextChangeRemove(line, 0, line, 1)
			);
			}
		} else if (!decrease) {
			insert('\t');
		}

	}

	private function handlePaste(event:Event):Void {
		if (readOnly) {
			return;
		}
		// Get data from clipboard, and insert
		var clipboardData:Dynamic = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT);

		if (AS3.as(clipboardData, Bool)) {
			insert(Std.string(clipboardData));
		}
	}

	private function handleCopy(event:Event):Void {
		if (!model.hasSelection) {
			return;
		}

		toCopy = editor.getSelection();
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, toCopy, false);
	}

	private function handleCut(event:Event):Void {
		if (readOnly) {
			return;
		}
		if (model.hasSelection) {
			handleCopy(event);
			removeAtCursor();
		}
	}

	private function dispatchChange(change:TextChangeBase):Void {
		editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change));
	}

	private function handleChange(event:ChangeEvent):Void {
		applyChange(event.change);
	}

	private function applyChange(change:TextChangeBase):Void {
		if (change != null) {
			if (Std.is(change, TextChangeInsert)) {
				applyChangeInsert(TextChangeInsert(change));
			}
			if (Std.is(change, TextChangeRemove)) {
				applyChangeRemove(TextChangeRemove(change));
			}
			if (Std.is(change, TextChangeMulti)) {
				applyChangeMulti(TextChangeMulti(change));
			}
		}
	}

	private function applyChangeInsert(change:TextChangeInsert):Void {
		var textLines:Array<String> = change.textLines;

		if (textLines != null && textLines.length > 0) {
			var startLine:TextLineModel = model.lines[change.startLine];
			var startIndent:Int = TextUtil.indentAmount(startLine.text);
			var trailText:String = Std.string(startLine.text.substring(change.startChar));

			// Break line at change position, and append first text line
			startLine.text = startLine.text.substring(0, change.startChar) + textLines[0];

			// Append any additional lines to the model
			if (textLines.length > 1) {
				// Add indentation to last line if it's empty
				if (textLines[textLines.length - 1] == '') {
					// Get indentation of trailing text
					var trailIndent:Int = TextUtil.indentAmount(trailText);
					// Get indentation of last line of the insert if it's a multi-line insert
					if (textLines.length > 2) {
						startIndent = TextUtil.indentAmount(textLines[textLines.length - 2]);
					}
					// Add required amount of indent to get the trailing text aligned with the last line
					textLines[textLines.length - 1] += TextUtil.repeatStr('\t', AS3.int(Math.max(startIndent - trailIndent, 0)));
				}

				// Create line models from strings
				var newLines:Array<Dynamic> = new Array<Dynamic>();

				for (i in 0...textLines.length) {
					newLines[i - 1] = new TextLineModel(textLines[i]);
				}

				model.lines.splice.apply(model.lines, [change.startLine + 1, 0].concat(newLines));
			}

			// Append trailing text to the last changed line
			model.lines[change.startLine + textLines.length - 1].text += trailText;
		}
	}

	private function applyChangeRemove(change:TextChangeRemove):Void {
		var startLine:TextLineModel = model.lines[change.startLine];
		var endLine:TextLineModel = model.lines[change.endLine];
		var textLines:Array<String> = new Array<String>();

		if (change.endLine > change.startLine) {
			// Remove any lines after the first
			var remLines:Array<TextLineModel> = cast model.lines.splice(change.startLine + 1, change.endLine - change.startLine);
			// Store each removed line's text
			textLines[0] = Std.string(startLine.text.substring(change.startChar));
			for (i in 0...remLines.length - 1) {
				textLines[i + 1] = remLines[i].text;
			}
			textLines[remLines.length] = Std.string(remLines[remLines.length - 1].text.substring(0, change.endChar));
		}// Store removed text
		else {
			// Store removed text
			textLines[0] = Std.string(startLine.text.substring(change.startChar, change.endChar));
		}

		// Remove from first line, and append trailing from end line
		startLine.text = Std.string(startLine.text.substring(0, change.startChar) + endLine.text.substring(change.endChar));

		// Store removed lines in change
		change.setTextLines(textLines);
	}

	private function applyChangeMulti(change:TextChangeMulti):Void {
		for (subchange in change.changes) {
			applyChange(subchange);
		}
	}

}