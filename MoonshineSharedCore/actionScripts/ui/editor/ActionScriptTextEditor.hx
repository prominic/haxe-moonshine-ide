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
package actionScripts.ui.editor;

import actionScripts.events.ChangeEvent;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.ui.Keyboard;

class ActionScriptTextEditor extends LanguageServerTextEditor {

	public static inline var LANGUAGE_ID_ACTIONSCRIPT:String = 'nextgenas';

	private var dispatchCompletionPending:Bool = false;
	private var dispatchSignatureHelpPending:Bool = false;

	public function new(readOnly:Bool = false) {
		super(LANGUAGE_ID_ACTIONSCRIPT, readOnly);
		editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		editor.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
	}

	private function onTextInput(event:TextEvent):Void {
		if (dispatchCompletionPending) {
			dispatchCompletionPending = false;
			dispatchCompletionEvent();
		}
		if (dispatchSignatureHelpPending) {
			dispatchSignatureHelpPending = false;
			dispatchSignatureHelpEvent();
		}
	}

	private function onKeyDown(event:KeyboardEvent):Void {
		var fromCharCode:String = String.fromCharCode(event.charCode);
		var ctrlSpace:Bool = event.keyCode == Keyboard.SPACE && event.ctrlKey;
		var memberAccess:Bool = fromCharCode == '.';
		var typeAnnotation:Bool = fromCharCode == ':';
		var openTag:Bool = fromCharCode == '<';
		var enterKey:Bool = event.keyCode == 13;

		if (ctrlSpace || memberAccess || typeAnnotation || openTag) {
			if (!ctrlSpace) {
				//wait for the character to be input
				dispatchCompletionPending = true;
				return;
			}
			//don't type the space when user presses Ctrl+Space
			event.preventDefault();
			dispatchCompletionPending = false;
			dispatchCompletionEvent();
		}

		var parenOpen:Bool = fromCharCode == '(';
		var comma:Bool = fromCharCode == ',';
		var activeAndBackspace:Bool = editor.signatureHelpActive && event.keyCode == Keyboard.BACKSPACE;
		if (parenOpen || comma) {
			dispatchSignatureHelpPending = true;
		} else if (activeAndBackspace) {
			dispatchSignatureHelpPending = false;
			dispatchSignatureHelpEvent();
		}

		var minusOneSelectedLineIndex:Int = editor.model.selectedLineIndex - 1;
		var plusOneSelectedLineIndex:Int = editor.model.selectedLineIndex + 1;

		/*if (openingBracket)
		{
			event.preventDefault();
			change = new TextChangeInsert(
				editor.model.selectedLineIndex,
				editor.model.caretIndex,
				Vector.<String>([")"])
			);
			editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, "(", change);
		}
		else if (openingSingleQuote)
		{
			event.preventDefault();
			change = new TextChangeInsert(
					editor.model.selectedLineIndex,
					editor.model.caretIndex,
					Vector.<String>(["'"])
				);
			editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, "'", change);
		}
		else if (openingDoubleQuote)
		{
			event.preventDefault();
			change = new TextChangeInsert(
				editor.model.selectedLineIndex,
				editor.model.caretIndex,
				Vector.<String>(['"'])
			);
			editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '"', change);
		}
		else */
		if (enterKey) {
			var isCurlybracesOpened:Bool;
			var isQuotesOpened:Bool;
			var lineText:String = Std.string(StringTools.trim(editor.model.lines[minusOneSelectedLineIndex].text));
			if (lineText.charAt(lineText.length - 1) == '{' && !editor.model.lines[minusOneSelectedLineIndex].isQuoteTextOpen) {
				isCurlybracesOpened = true;
			} else if (editor.model.lines[minusOneSelectedLineIndex].isQuoteTextOpen) {
				isQuotesOpened = true;
			}

			// for curly braces
			if (isCurlybracesOpened) {
				// continue to next phase if only found an opened and non-closed
				// curly braces
				var openCount:Int = AS3.int(as3hx.Compat.match(text, new as3hx.Compat.Regex('{', 'g')).length);
				var closeCount:Int = AS3.int(as3hx.Compat.match(text, new as3hx.Compat.Regex('}', 'g')).length);
				if (openCount > closeCount) {
					//try to use the same indent as whatever follows
					var newCaretPos:Int;
					var editorHasNextLine:Bool;
					var indent:String = '';
					if (editor.model.selectedLineIndex < (editor.model.lines.length - 1)) {
						var regExp:as3hx.Compat.Regex = new as3hx.Compat.Regex('^([ \\t]*)\\w', 'gm');
						editorHasNextLine = true;
						var matches:Array<Dynamic> = regExp.exec(editor.model.lines[plusOneSelectedLineIndex].text);
						if (matches == null) {
							regExp.exec(editor.model.lines[minusOneSelectedLineIndex].text);
						}
						if (matches != null) {
							indent = Std.string(matches[1]);
						}
					}

					if (matches == null) {
						newCaretPos = editor.model.caretIndex;
					}

					editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '\n');
					editor.model.selectedLineIndex--;
					var curlyBraceChange:TextChangeMulti = new TextChangeMulti(
					new TextChangeInsert(
					(editorHasNextLine) ? plusOneSelectedLineIndex : editor.model.selectedLineIndex,
					newCaretPos,
					[indent + '}']),
					new TextChangeInsert(
					editor.model.selectedLineIndex,
					editor.model.caretIndex,
					['\t']));
					editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, curlyBraceChange));
				}
			}

			// for quotes
			if (isQuotesOpened) {
				var quotesChange:TextChangeMulti = new TextChangeMulti(
				new TextChangeInsert(
				minusOneSelectedLineIndex,
				editor.model.lines[minusOneSelectedLineIndex].text.length,
				[editor.model.lines[minusOneSelectedLineIndex].lastQuoteText]),
				new TextChangeInsert(
				editor.model.selectedLineIndex,
				editor.model.caretIndex,
				['+ ' + editor.model.lines[minusOneSelectedLineIndex].lastQuoteText]));
				editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, quotesChange));
			}
		}
	}

}