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

import flash.events.EventDispatcher;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Settings;
import flash.events.Event;

/**
 * Dispatched when the selection or caret index changes.
 */
@:meta(Event(name = 'change', type = 'flash.events.Event'))
class TextEditorModel extends EventDispatcher {

	private var _selectedLineIndex:Int = 0;
	private var _selectedTraceLineIndex:Int = 0;
	private var _caretIndex:Int = 0;
	private var _caretTraceIndex:Int = 0;

	public var itemRenderersInUse:Array<TextLineRenderer> = new Array<TextLineRenderer>();
	public var itemRenderersFree:Array<TextLineRenderer> = new Array<TextLineRenderer>();

	public var lines:Array<TextLineModel> = new Array<TextLineModel>();

	// View size
	public var viewWidth:Float = 0;
	public var viewHeight:Float = 0;

	// Vertical scrolling, in lines.
	public var scrollPosition:Int = 0;
	public var renderersNeeded:Int = 0;

	// Horizontal scrolling, in pixels.
	public var horizontalScrollPosition:Int = 0;
	public var textWidth:Float = 0;
	public var _hasTraceLine:Bool = false;

	public var selectedLineIndex(get, set):Int;
	private function set_selectedLineIndex(idx:Int):Int {
		if (_selectedLineIndex == idx) {
			return idx;
		}
		_selectedLineIndex = idx;
		validateSelection();
		if (_selectedLineIndex == idx) {
			//don't dispatch an event unless it is still changed after
			//validation
			dispatchEvent(new Event(Event.CHANGE));
		}
		return idx;
	}

	private function get_selectedLineIndex():Int {
		return _selectedLineIndex;
	}

	public var selectedTraceLineIndex(get, set):Int;
	private function set_selectedTraceLineIndex(idx:Int):Int {
		_selectedTraceLineIndex = idx;
		validateTraceSelection();
		return idx;
	}

	private function get_selectedTraceLineIndex():Int {
		return _selectedTraceLineIndex;
	}

	public var caretIndex(get, set):Int;
	private function set_caretIndex(idx:Int):Int {
		// Get current line indentation
		var indent:Int = (selectedLine != null) ? TextUtil.indentAmount(selectedLine.text) : 0;

		// Store the index with tabs expanded
		var expandedIdx:Int = AS3.int(idx + Math.min(indent, idx) * (Settings.font.tabWidth - 1));

		if (_caretIndex == expandedIdx) {
			return idx;
		}
		_caretIndex = expandedIdx;

		validateSelection();
		if (_caretIndex == expandedIdx) {
			//don't dispatch an event unless it is still changed after
			//validation
			dispatchEvent(new Event(Event.CHANGE));
		}
		return idx;
	}

	private function get_caretIndex():Int {
		if (selectedLine != null) {
			// Get current line indentation
			var indent:Int = TextUtil.indentAmount(selectedLine.text);
			// Get the index with tabs contracted
			var idx:Int = _caretIndex - indent * (Settings.font.tabWidth - 1);
			// If the index falls within the indentation, approximate
			if (idx <= indent) {
				idx = Math.round(_caretIndex / Settings.font.tabWidth);
			}

			// Limit the index by the line length
			return AS3.int(Math.min(idx, selectedLine.text.length));
		}

		return 0;
	}

	public var caretTraceIndex(get, set):Int;
	private function set_caretTraceIndex(idx:Int):Int {
		// Get current line indentation
		var indent:Int = (selectedTraceLine != null) ? TextUtil.indentAmount(selectedTraceLine.text) : 0;

		// Store the index with tabs expanded
		_caretTraceIndex = AS3.int(idx + Math.min(indent, idx) * (Settings.font.tabWidth - 1));

		validateTraceSelection();
		return idx;
	}

	private function get_caretTraceIndex():Int {
		if (selectedTraceLine != null) {
			// Get current line indentation
			var indent:Int = TextUtil.indentAmount(selectedTraceLine.text);
			// Get the index with tabs contracted
			var idx:Int = _caretTraceIndex - indent * (Settings.font.tabWidth - 1);
			// If the index falls within the indentation, approximate
			if (idx <= indent) {
				idx = Math.round(_caretTraceIndex / Settings.font.tabWidth);
			}

			// Limit the index by the line length
			return AS3.int(Math.min(idx, selectedTraceLine.text.length));
		}

		return 0;
	}

	public var selectionStartLineIndex:Int = -1;
	public var selectionStartCharIndex:Int = -1;

	public var selectionStartTraceLineIndex:Int = -1;
	public var selectionStartTraceCharIndex:Int = -1;

	public var allInstancesOfASearchStringDict:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	public var hasMultilineSelection(get, never):Bool;
	private function get_hasMultilineSelection():Bool {
		return selectionStartLineIndex > -1 && selectedLineIndex != selectionStartLineIndex;
	}

	public var hasTraceSelection(get, set):Bool;
	private function get_hasTraceSelection():Bool {
		return _hasTraceLine;
	}

	private function set_hasTraceSelection(v:Bool):Bool {
		_hasTraceLine = v;
		return v;
	}

	public var hasSelection(get, never):Bool;
	private function get_hasSelection():Bool {
		return selectionStartCharIndex != -1;
	}

	public function removeSelection():Void {
		selectionStartLineIndex = -1;
		selectionStartCharIndex = -1;
	}

	public function removeTraceSelection():Void {
		selectionStartTraceLineIndex = -1;
		selectionStartTraceCharIndex = -1;
	}

	public function getSelectionLineStart():Int {
		if (hasMultilineSelection) {
			return ((selectedLineIndex < selectionStartLineIndex)) ? selectedLineIndex : selectionStartLineIndex;
		} else {
			return selectedLineIndex;
		}
	}

	public function getSelectionTraceLineStart():Int {
		return selectedTraceLineIndex;

	}

	public function getSelectionCharStart():Int {
		if (hasMultilineSelection) {
			return ((selectedLineIndex < selectionStartLineIndex)) ? caretIndex : selectionStartCharIndex;
		} else {
			return ((caretIndex < selectionStartCharIndex)) ? caretIndex : selectionStartCharIndex;
		}
	}

	public function getSelectionTraceCharStart():Int {
		return ((caretTraceIndex < selectionStartTraceCharIndex)) ? caretTraceIndex : selectionStartTraceCharIndex;

	}

	public function getSelectionLineEnd():Int {
		if (hasMultilineSelection) {
			return ((selectedLineIndex > selectionStartLineIndex)) ? selectedLineIndex : selectionStartLineIndex;
		} else {
			return selectedLineIndex;
		}
	}

	public function getSelectionTraceLineEnd():Int {
		return selectedTraceLineIndex;

	}

	public function getSelectionCharEnd():Int {
		if (hasMultilineSelection) {
			return ((selectedLineIndex > selectionStartLineIndex)) ? caretIndex : selectionStartCharIndex;
		} else {
			return ((caretIndex > selectionStartCharIndex)) ? caretIndex : selectionStartCharIndex;
		}
	}

	public function getSelectionTraceCharEnd():Int {
		return ((caretTraceIndex > selectionStartTraceCharIndex)) ? caretTraceIndex : selectionStartTraceCharIndex;

	}

	public function setSelection(startLine:Int, startChar:Int, endLine:Int, endChar:Int):Void {
		selectionStartLineIndex = startLine;
		selectionStartCharIndex = startChar;
		_selectedLineIndex = endLine;
		caretIndex = endChar;// This triggers validation
	}

	public function setTraceSelection(startLine:Int, startChar:Int, endLine:Int, endChar:Int):Void {
		selectionStartTraceLineIndex = startLine;
		selectionStartTraceCharIndex = startChar;
		_selectedTraceLineIndex = endLine;
		caretTraceIndex = endChar;// This triggers validation
	}

	public var selectedLine(get, never):TextLineModel;
	private function get_selectedLine():TextLineModel {
		return (selectedLineIndex >= 0 && selectedLineIndex < lines.length) ? lines[selectedLineIndex] : null;
	}

	public var selectedTraceLine(get, never):TextLineModel;
	private function get_selectedTraceLine():TextLineModel {
		return (selectedLineIndex >= 0 && selectedTraceLineIndex < lines.length) ? lines[selectedTraceLineIndex] : null;
	}

	private function validateSelection():Void {
		if (selectionStartCharIndex == caretIndex && selectionStartLineIndex == selectedLineIndex) {
			removeSelection();
		}
	}

	private function validateTraceSelection():Void {
		if (selectionStartTraceCharIndex == caretTraceIndex && selectionStartTraceLineIndex == selectedTraceLineIndex) {
			removeTraceSelection();
		}
	}

	public function new() {
		super();
	}

}