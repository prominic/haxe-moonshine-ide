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

import flash.events.Event;
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import actionScripts.events.ChangeEvent;
import actionScripts.events.LineEvent;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.ui.editor.text.change.TextChangeRemove;
import actionScripts.ui.parser.ILineParser;
import actionScripts.valueObjects.Settings;

class ColorManager {

	private static var charWidthCache:Dynamic = {
			'\t': 7.82666015625 * Settings.font.tabWidth
		};

	public static inline var CHUNK_TIMESPAN:Int = 25;

	private var parser:ILineParser;
	private var ranges:Array<LineRange> = new Array<LineRange>();
	private var listening:Bool = false;

	private var textElement:TextElement = new TextElement('', new ElementFormat(Settings.font.defaultFontDescription,
		Settings.font.defaultFontSize,
		0x0));
	private var textBlock:TextBlock;

	private var editor:TextEditor;
	private var model:TextEditorModel;

	public var styles:Dynamic = {
			'0': new ElementFormat(Settings.font.defaultFontDescription,
			Settings.font.defaultFontSize,
			0x0),
			'lineNumber': new ElementFormat(Settings.font.defaultFontDescription,
			Settings.font.defaultFontSize,
			0x888888),
			'breakPointLineNumber': new ElementFormat(Settings.font.defaultFontDescription,
			Settings.font.defaultFontSize,
			0xffffff),
			'breakPointBackground': 0xdea5dd,
			'tracingLineColor': 0xc6dbae
		};

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.textBlock = new TextBlock(this.textElement);
		this.editor = editor;
		this.model = model;

		editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
	}

	public function setParser(value:ILineParser):Void {
		parser = value;
	}

	public function reset():Void {
		as3hx.Compat.setArrayLength(ranges, 0);
		invalidate(0, model.lines.length - 1);
	}

	private function invalidate(line:Int, addCount:Int = 0, silent:Bool = false):Void {
		var merged:Bool = false;

		var r:Int = ranges.length;

		while (r-- != 0) {
			var range:LineRange = ranges[r];

			if (range.end < line) {
				break;
			} else if (range.start > line) {
				range.start += addCount;
				range.end += addCount;
			} else {
				merged = true;
				range.end += addCount;
				break;
			}
		}

		if (!merged) {
			ranges.insert(r + 1, new LineRange(line, line + addCount));
		}

		if (!listening && !silent) {
			startListening();
			process();
		}
	}

	private function process(event:Event = null):Void {
		//if (!parser) return;
		var count:Int = model.lines.length;
		var timeLimit:Int = Math.round(haxe.Timer.stamp() * 1000) + CHUNK_TIMESPAN;

		while (ranges.length != 0) {
			var range:LineRange = ranges[0];
			var rangeStart:Int = range.start;
			var rangeEnd:Int = range.end;

			if (parser != null) {
				parser.setContext((rangeStart > 0) ? model.lines[rangeStart - 1].endContext : 0);
			}

			var i:Int = rangeStart;

			while (i <= rangeEnd) {
				var line:TextLineModel = model.lines[i];

				// Calculate line width
				var oldWidth:Float = line.width;
				line.width = calculateWidth(line.text);

				if (oldWidth != line.width) {
					editor.dispatchEvent(new LineEvent(LineEvent.WIDTH_CHANGE, i));
				}

				if (parser != null) {
					// Parse file for coloring
					var oldMeta:Array<Int> = line.meta;
					var newMeta:Array<Int> = parser.parse(line.text + '\n');

					line.meta = newMeta;

					// Notify the editor of change, to invalidate lines if needed
					if (oldMeta == null || oldMeta.join(',') != newMeta.join(',')) {
						editor.dispatchEvent(new LineEvent(LineEvent.COLOR_CHANGE, i));
					}

					if (i == rangeEnd && i < count - 1) {
						// Invalidate next line if its start context doesn't match up with this one's end context
						var nextLine:TextLineModel = model.lines[i + 1];
						var endContext:Int = line.endContext;
						var startContext:Int = nextLine.startContext;

						if (endContext != startContext) {
							invalidate(i + 1);
						}
					}

					if (Math.round(haxe.Timer.stamp() * 1000) > timeLimit) {
						if (i == rangeEnd) {
							ranges.splice(0, 1);
						} else {
							range.start = AS3.int(i + 1);
						}

						return;
					}
				}
				i++;
			}

			ranges.splice(0, 1);
		}

		stopListening();
	}

	public function calculateWidth(text:String):Float {
		var chars:String;
		var calculatedChars:String;
		var i:Int;
		var width:Float = 0;
		var textLenght:Int = text.length;

		// Collect uncached characters
		i = textLenght;

		while (i-- != 0) {
			calculatedChars = Std.string(text.charAt(i));

			if (Reflect.field(charWidthCache, calculatedChars) == null) {
				chars += calculatedChars;
				Reflect.setField(charWidthCache, calculatedChars, -1);
			}
		}
		// Measure uncached characters
		if (chars != null) {
			var textLine:TextLine;

			textElement.text = chars;
			textLine = textBlock.createTextLine();
			i = chars.length;
			while (i-- != 0) {
				calculatedChars = Std.string(chars.charAt(i));
				Reflect.setField(charWidthCache, calculatedChars, textLine.getAtomBounds(textLine.getAtomIndexAtCharIndex(i)).width);
			}
		}
		// Calculate line width
		i = textLenght;

		while (i-- != 0) {
			width += Reflect.field(charWidthCache, Std.string(text.charAt(i)));
		}

		return width;
	}

	private function handleChange(event:ChangeEvent):Void {
		applyChange(event.change);
	}

	private function applyChange(change:TextChangeBase, subChange:Bool = false):Void {
		if (Std.is(change, TextChangeInsert)) {
			applyChangeInsert(TextChangeInsert(change));
		}
		if (Std.is(change, TextChangeRemove)) {
			applyChangeRemove(TextChangeRemove(change));
		}
		if (Std.is(change, TextChangeMulti)) {
			applyChangeMulti(TextChangeMulti(change));
		}

		if (!subChange) {
			if (ranges.length == 0) {
				stopListening();
			} else if (!listening) {
				startListening();
				process();
			}
		}
	}

	private function applyChangeInsert(change:TextChangeInsert):Void {
		invalidate(change.startLine, change.textLines.length - 1, true);
	}

	private function applyChangeRemove(change:TextChangeRemove):Void {
		var r:Int = ranges.length;
		while (r-- != 0) {
			var range:LineRange = ranges[r];

			if (change.startLine > range.end) {
				break;
			} else {
				var lines:Int = AS3.int(Math.min(change.endLine, range.end) - change.startLine);

				range.start = AS3.int(Math.min(range.start, change.startLine));
				range.end -= lines;

				if (range.end < range.start) {
					ranges.splice(r, 1);
				}
			}
		}

		if (change.startChar > 0 || change.endChar > 0) {
			invalidate(change.startLine, 0, true);
		}
	}

	private function applyChangeMulti(change:TextChangeMulti):Void {
		for (subchange in change.changes) {
			applyChange(subchange, true);
		}
	}

	private function startListening():Void {
		if (!listening) {
			listening = true;
			editor.addEventListener(Event.ENTER_FRAME, process);
		}
	}

	private function stopListening():Void {
		if (listening) {
			listening = false;
			editor.removeEventListener(Event.ENTER_FRAME, process);
		}
	}

}

class LineRange {

	public var start:Int = 0;
	public var end:Int = 0;

	private function new(start:Int, end:Int) {
		this.start = start;
		this.end = end;
	}

}