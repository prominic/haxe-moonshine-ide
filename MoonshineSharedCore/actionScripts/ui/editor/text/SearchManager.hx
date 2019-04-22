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

import flash.geom.Point;
import actionScripts.events.ChangeEvent;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.ui.editor.text.change.TextChangeRemove;
import actionScripts.ui.editor.text.vo.SearchResult;
import actionScripts.utils.TextUtil;

class SearchManager {

	private var model:TextEditorModel;
	private var editor:TextEditor;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;
	}

	// Search all instances and highlight
	// Preferably used in 'search in project' sequence
	public function searchAndShowAll(search:Dynamic):Void {
		// this probably overkill if search highlights already
		// rendered once
		if (model.allInstancesOfASearchStringDict != null) {
			return;
		}

		var results:Array<Dynamic>;
		var searchRegExp:as3hx.Compat.Regex = AS3.as(search, RegExp);
		var str:String = editor.dataProvider;
		var res:SearchResult;
		var tmpDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

		results = searchRegExp.exec(str);
		while (results != null) {
			var lc:Point = TextUtil.charIdx2LineCharIdx(str, AS3.int(results.index), editor.lineDelim);

			res = new SearchResult();
			res.startLineIndex = AS3.int(lc.x);
			res.endLineIndex = AS3.int(lc.x);
			res.startCharIndex = AS3.int(lc.y);
			res.endCharIndex = AS3.int(lc.y + results[0].length);
			if (tmpDict.get(res.startLineIndex) == null) {
				tmpDict.set(res.startLineIndex, [res]);
			} else {
				tmpDict.get(res.startLineIndex).push(res);
			}

			results = searchRegExp.exec(str);
		}

		model.allInstancesOfASearchStringDict = tmpDict;

		// TODO: Have a bit more margin, maybe center the selected textline?
		editor.scrollViewIfNeeded();
		editor.invalidateLines();
	}

	public function search(search:Dynamic, replace:String, all:Bool = false, backwards:Bool = false):SearchResult {
		// Get string once (it's built dynamically)
		var str:String = editor.dataProvider;

		// Starting point for search
		var startLine:Int = model.selectedLineIndex;
		var startChar:Int = model.caretIndex;

		// When going backwards, start at the left edge of the selection
		if (backwards && model.hasSelection) {
			startLine = model.getSelectionLineStart();
			startChar = model.getSelectionCharStart();
		}

		// Map to '1-d space'
		var startCharIndex:Int = TextUtil.lineCharIdx2charIdx(
				str,
				startLine,
				startChar,
				editor.lineDelim
		);

		var result:Int = -1;
		var results:Array<Dynamic> = [];
		var wrapped:Bool;
		var match:Dynamic;
		var selectedIndex:Int;

		// Search with regexp
		if (Std.is(search, RegExp)) {
			// Find first occurance
			match = search.exec(str);

			// Find other occurances
			while (match != null) {
				if (AS3.as(Std.string(match), Bool)) {
					// match return infinite string for somekind of regexp like /L*/ /?*/
					{
						results.push(match);
						match = search.exec(str);
					}
				} else {
					match = null;
					break;
				}
			}

			// Figure out which one we want to select
			var resultsLength:Int = results.length;
			if (backwards) {
				var i:Int = resultsLength - 1;
				while (i >= 0) {
					if (Reflect.field(results[i], 'index') < startCharIndex) {
						result = AS3.int(Reflect.field(results[i], 'index'));
						match = results[i];
						selectedIndex = i;
						break;
					}
					i--;
				}
			} else {
				for (i in 0...resultsLength) {
					if (Reflect.field(results[i], 'index') > startCharIndex) {
						result = AS3.int(Reflect.field(results[i], 'index'));
						match = results[i];
						selectedIndex = i;
						break;
					}
				}
			}

			// No match, wrap search
			if (result == -1 && results.length != 0) {
				if (backwards) {
					selectedIndex = AS3.int(results.length - 1);
					match = results[selectedIndex];
					result = AS3.int(Reflect.field(match, 'index'));
				} else {
					selectedIndex = 0;
					match = results[selectedIndex];
					result = AS3.int(Reflect.field(match, 'index'));
				}
				wrapped = true;
			}
		}// Search is string
		else {
			// Find first occurance
			var current:Int = str.indexOf(Std.string(search));

			// Find other occurances
			while (current != -1) {
				results.push(current);
				current = str.indexOf(Std.string(search), current + 1);
			}

			// Figure out which one we want to select
			resultsLength = results.length;
			if (backwards) {
				i = AS3.int(resultsLength - 1);
				while (i >= 0) {
					if (results[i] < startCharIndex) {
						result = AS3.int(results[i]);
						selectedIndex = i;
						break;
					}
					i--;
				}
			} else {
				for (i in 0...resultsLength) {
					if (results[i] >= startCharIndex) {
						result = AS3.int(results[i]);
						selectedIndex = i;
						break;
					}
				}
			}

			resultsLength = results.length;
			// No match, wrap search
			if (result == -1 && resultsLength != 0) {
				if (backwards) {
					selectedIndex = AS3.int(resultsLength - 1);
					result = AS3.int(results[selectedIndex]);
				} else {
					selectedIndex = 0;
					result = AS3.int(results[selectedIndex]);
				}
				wrapped = true;
			}
		}

		var res:SearchResult = new SearchResult();

		if (result != -1 && replace != null) {
			res = this.replace(str, search, replace, results, all);
			applySearch(res);
			return res;
		}

		// Did we find anything?
		if (result != -1) {
			var lc:Point = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);
			res.startLineIndex = AS3.int(lc.x);
			res.endLineIndex = AS3.int(lc.x);

			res.startCharIndex = AS3.int(lc.y);
			if (Std.is(search, RegExp)) {
				res.endCharIndex = AS3.int(lc.y + Reflect.field(match, Std.string(0)).length);
			} else {
				res.endCharIndex = AS3.int(lc.y + search.length);
			}

			res.didWrap = wrapped;
			res.totalMatches = results.length;

			res.selectedIndex = selectedIndex;

			// Display
			applySearch(res);
		}

		return res;
	}

	public function highlightTagSelection(tagSelectionLineBeginIndex:Int, tagSelectionLineEndIndex:Int):Void {
		var res:SearchResult;
		var tmpDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

		// for multiple lines
		if (tagSelectionLineEndIndex > tagSelectionLineBeginIndex) {
			var tmpHighlightResult:SearchResult = new SearchResult();
			var linesCount:Int = tagSelectionLineEndIndex - tagSelectionLineBeginIndex + 1;
			var i:Int;
			while (i < linesCount) {
				res = new SearchResult();
				if (i == 0) {
					res.startLineIndex = tagSelectionLineBeginIndex;
					res.endLineIndex = tagSelectionLineBeginIndex;
					res.startCharIndex = model.lines[tagSelectionLineBeginIndex].text.indexOf('<');
					res.endCharIndex = model.lines[tagSelectionLineBeginIndex].text.length;

					tmpHighlightResult.startLineIndex = res.startLineIndex;
					tmpHighlightResult.startCharIndex = res.startCharIndex;
				} else {
					res.startLineIndex = ++tagSelectionLineBeginIndex;
					res.endLineIndex = tagSelectionLineBeginIndex;
					res.startCharIndex = 0;
					res.endCharIndex = model.lines[tagSelectionLineBeginIndex].text.length;
				}

				tmpDict.set(tagSelectionLineBeginIndex, [res]);
				i++;
			}

			tmpHighlightResult.endLineIndex = res.endLineIndex;
			tmpHighlightResult.endCharIndex = res.endCharIndex;

			applySearch(tmpHighlightResult);
		} else {
			// for single line
			res = new SearchResult();
			res.startLineIndex = tagSelectionLineBeginIndex;
			res.endLineIndex = tagSelectionLineEndIndex;
			res.startCharIndex = model.lines[tagSelectionLineBeginIndex].text.indexOf('<');
			res.endCharIndex = model.lines[tagSelectionLineEndIndex].text.length;
			tmpDict.set(tagSelectionLineBeginIndex, [res]);

			applySearch(res);
		}

		model.allInstancesOfASearchStringDict = tmpDict;
	}

	public function unHighlightTagSelection():Void {
		model.allInstancesOfASearchStringDict = new Dictionary();
		//editor.scrollViewIfNeeded();
		editor.invalidateLines();
		editor.callLater(function():Void {
					model.allInstancesOfASearchStringDict = null;
				});
	}

	private function replace(str:String, search:Dynamic, replace:String, results:Array<Dynamic>, all:Bool):SearchResult {
		var regexp:Bool = Std.is(search, RegExp);

		// Get leftmost selection edge, so we can replace something that's selected
		var startLine:Int = model.getSelectionLineStart();
		var startChar:Int = model.getSelectionCharStart();

		var startCharIndex:Int = TextUtil.lineCharIdx2charIdx(
				str,
				startLine,
				startChar,
				editor.lineDelim
		);

		// Build search results
		var res:SearchResult = new SearchResult();
		res.totalMatches = results.length;
		res.selectedIndex = AS3.int(res.totalMatches - 1);

		var result:Int;
		var removeText:TextChangeRemove;
		var addText:TextChangeInsert;
		var changes:Array<TextChangeBase> = [];
		var match:Dynamic;

		// Replace all
		if (all) {
			var lastLineIndex:Int = -1;
			var replaceLengthDiff:Int;
			// Loop over all results and replace
			for (i in 0...results.length) {
				if (regexp) {
					match = results[i];
					result = AS3.int(Reflect.field(match, 'index'));
				} else {
					result = AS3.int(results[i]);
				}

				var lc:Point = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);

				var lineIndex:Int = AS3.int(lc.x);
				startCharIndex = AS3.int(lc.y);
				var endCharIndex:Int;

				if (Std.is(search, RegExp)) {
					endCharIndex = AS3.int(lc.y + Reflect.field(match, Std.string(0)).length);
				} else {
					endCharIndex = AS3.int(lc.y + search.length);
				}

				// For new lines we have no length diff
				if (lastLineIndex != lineIndex) {
					replaceLengthDiff = 0;
				}

				// Create text change events so we can undo/redo
				removeText = new TextChangeRemove(lineIndex,
						startCharIndex - replaceLengthDiff,
						lineIndex,
						endCharIndex - replaceLengthDiff);

				addText = new TextChangeInsert(lineIndex,
						startCharIndex - replaceLengthDiff,
						[replace]);

				changes.push(removeText);
				changes.push(addText);

				lastLineIndex = lineIndex;

				// For multiple replaces on the same line
				//  we need to track changes in search/replace length to offset
				replaceLengthDiff += AS3.int((endCharIndex - startCharIndex) - replace.length);
			}

			// Remove last adjustment, it's only for trailing adjustments
			//  which we have none in this context
			replaceLengthDiff -= AS3.int((endCharIndex - startCharIndex) - replace.length);
			// Apply diff (if any) so the new selection is the replace string
			startCharIndex -= replaceLengthDiff;

			// Since we replaced everything we shouldn't have any new matches
			res.totalReplaces = res.totalMatches;
			res.totalMatches = 0;

			// Dispatch change event
			var multiEvent:TextChangeMulti = new TextChangeMulti(changes);
			editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multiEvent));
		} else {
			// Find item to replace
			for (i in 0...results.length) {
				if (regexp) {
					if (Reflect.field(results[i], 'index') >= startCharIndex) {
						match = results[i];
						result = AS3.int(Reflect.field(match, 'index'));
						res.selectedIndex = i;
						break;
					}
				} else if (results[i] >= startCharIndex) {
					result = AS3.int(results[i]);
					res.selectedIndex = i;
					break;
				}
			}

			// Map to 2D
			lc = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);
			lineIndex = AS3.int(lc.x);
			startCharIndex = AS3.int(lc.y);

			if (Std.is(search, RegExp)) {
				endCharIndex = AS3.int(lc.y + Reflect.field(match, Std.string(0)).length);
			} else {
				endCharIndex = AS3.int(lc.y + search.length);
			}

			// Create text change events
			removeText = new TextChangeRemove(lineIndex, startCharIndex, lineIndex, endCharIndex);
			addText = new TextChangeInsert(lineIndex, startCharIndex, [replace]);

			// Wrap in one undo step
			multiEvent = new TextChangeMulti(removeText, addText);

			// Apply
			editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multiEvent));

			// We replaced one
			res.totalMatches -= 1;
			res.totalReplaces = 1;
		}

		res.startLineIndex = res.endLineIndex = lineIndex;
		res.startCharIndex = startCharIndex;
		res.endCharIndex = AS3.int(startCharIndex + replace.length);

		return res;
	}

	// Map to TextEditor internal representation
	private function applySearch(s:SearchResult):Void {
		model.setSelection(s.startLineIndex, s.startCharIndex, s.endLineIndex, s.endCharIndex);

		// TODO: Have a bit more margin, maybe center the selected textline?
		editor.scrollViewIfNeeded();
		editor.invalidateLines();
	}

}