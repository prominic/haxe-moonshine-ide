package actionScripts.ui.editor.text;

import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.Position;
import actionScripts.valueObjects.Range;
import flash.events.MouseEvent;
import flash.geom.Point;

class DiagnosticsManager {

	private static inline var TOOL_TIP_ID:String = 'DiagnosticsManagerToolTip';

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var savedDiagnostics:Array<Diagnostic>;
	private var lastDiagnostic:Diagnostic;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;
	}

	public function showDiagnostics(diagnostics:Array<Diagnostic>):Void {
		this.savedDiagnostics = cast diagnostics;
		this.closeTooltip();
		var lines:Array<TextLineModel> = cast model.lines;
		var linesCount:Int = lines.length;
		for (i in 0...linesCount) {
			var line:TextLineModel = lines[i];
			if (line.diagnostics == null) {
				line.diagnostics = [];
			} else {
				as3hx.Compat.setArrayLength(line.diagnostics, 0);
			}
		}
		var diagnosticsCount:Int = diagnostics.length;
		for (i in 0...diagnosticsCount) {
			var diagnostic:Diagnostic = diagnostics[i];
			var range:Range = diagnostic.range;
			var start:Position = range.start;
			var end:Position = range.end;
			var startLine:Int = start.line;
			var startLineOneBeforeEnd:Int = startLine - 1;
			var endLine:Int = end.line;
			var endLineOneBeforeEnd:Int = endLine - 1;
			var startChar:Int = start.character;
			var endChar:Int = end.character;

			if (startLineOneBeforeEnd == linesCount) {
				startLine = AS3.int(linesCount - 1);
			}

			if (endLineOneBeforeEnd == linesCount) {
				endLine = AS3.int(linesCount - 1);
			}

			if (startLine == endLine && endChar == startChar) {
				//if the start and end are the same, try to extend the
				//underline to the end of the current word

				//default to the end of the line, since we might not
				//find a character that ends the word
				if (startLine == lines.length) {
					startLine = AS3.int(startLine - 1);
				}
				if (startLine > (lines.length - 1)) {
					return;
				}
				line = lines[startLine];
				//update the end character so that it matches what is
				//displayed in the UI
				end.character = TextUtil.endOfWord(line.text, startChar);
			}

			if (startLine < linesCount) {
				line = lines[startLine];
				line.diagnostics.push(diagnostic);
				if (startLine != endLine) {
					if (lines.length == endLine) {
						endLine = AS3.int(lines.length - 1);
					}
					//the diagnostic is on two lines!
					line = lines[endLine];
					line.diagnostics.push(diagnostic);
				}
			}
		}
		editor.invalidateLines();

		if (savedDiagnostics != null && savedDiagnostics.length > 0) {
			editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		} else {
			editor.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}

	public function closeTooltip():Void {
		lastDiagnostic = null;
		editor.setTooltip(TOOL_TIP_ID, null);
	}

	private function onMouseMove(event:MouseEvent):Void {
		var globalXY:Point = new Point(event.stageX, event.stageY);
		var charAndLine:Point = editor.getCharAndLineForXY(globalXY, false);
		if (charAndLine == null) {
			this.closeTooltip();
			return;
		}
		var line:Int = AS3.int(charAndLine.y);
		var char:Int = AS3.int(charAndLine.x);
		var filtered:Array<Diagnostic> = as3hx.Compat.filter(savedDiagnostics, function(item:Diagnostic, index:Int, source:Array<Diagnostic>):Bool {
					var range:Range = item.range;
					var start:Position = range.start;
					var end:Position = range.end;
					var startLine:Int = start.line;
					var endLine:Int = end.line;
					if (line < startLine || line > endLine) {
						return false;
					}
					if (startLine == endLine) {
						return char >= start.character && char <= end.character;
					}
					if (line == startLine) {
						return char > start.character;
					}
					return char < end.character;
				});
		if (filtered.length == 0) {
			this.closeTooltip();
			return;
		}
		var diagnostic:Diagnostic = filtered[0];
		if (lastDiagnostic == diagnostic) {
			//it's the same one so do nothing!
			return;
		}
		lastDiagnostic = diagnostic;

		editor.setTooltip(TOOL_TIP_ID, diagnostic.message);
	}

}