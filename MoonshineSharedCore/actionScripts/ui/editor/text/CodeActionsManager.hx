package actionScripts.ui.editor.text;

import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.Position;
import actionScripts.valueObjects.Range;
import flash.events.MouseEvent;
import flash.geom.Point;
import actionScripts.valueObjects.Command;
import actionScripts.valueObjects.CodeAction;
import flash.events.FocusEvent;

class CodeActionsManager {

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var savedCodeActions:Array<CodeAction>;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;
		editor.addEventListener(FocusEvent.FOCUS_OUT, editor_onFocusOut);
	}

	public function showCodeActions(codeActions:Array<CodeAction>):Void {
		this.savedCodeActions = cast codeActions;

		var lines:Array<TextLineModel> = cast model.lines;
		var linesCount:Int = lines.length;
		for (i in 0...linesCount) {
			var line:TextLineModel = lines[i];
			if (line.codeActions == null) {
				line.codeActions = [];
			} else {
				as3hx.Compat.setArrayLength(line.codeActions, 0);
			}
		}
		if (model.selectedLine != null) {
			model.selectedLine.codeActions = as3hx.Compat.filter(codeActions, function(codeAction:CodeAction, index:Int, original:Array<CodeAction>):Bool {
								if (codeAction.kind == CodeAction.KIND_SOURCE_ORGANIZE_IMPORTS) {
									//we don't display this one in the light bulb
									return false;
								}
								return true;
							});
		}
		editor.invalidateLines();
	}

	private function editor_onFocusOut(event:FocusEvent):Void {
		this.showCodeActions([]);
	}

}