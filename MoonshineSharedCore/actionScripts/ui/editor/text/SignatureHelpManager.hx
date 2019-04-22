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
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import mx.containers.HBox;
import mx.managers.PopUpManager;
import spark.components.RichText;
import actionScripts.valueObjects.ParameterInformation;
import actionScripts.valueObjects.SignatureHelp;
import actionScripts.valueObjects.SignatureInformation;
import flashx.textLayout.conversion.TextConverter;

class SignatureHelpManager {

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var tooltip:HBox;
	private var tooltipText:RichText;
	private var tooltipCaret:Int = 0;

	public var isActive(get, never):Bool;
	private function get_isActive():Bool {
		return AS3.as(tooltip.isPopUp, Bool);
	}

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;

		tooltip = new HBox();
		tooltip.styleName = 'toolTip';
		tooltipText = new RichText();
		tooltip.focusEnabled = false;
		tooltip.mouseEnabled = false;
		tooltip.mouseChildren = false;
		tooltip.addElement(tooltipText);
	}

	public function showSignatureHelp(data:SignatureHelp):Void {
		var signatures:Array<SignatureInformation> = cast data.signatures;
		var activeSignature:Int = data.activeSignature;
		var activeParameter:Int = data.activeParameter;
		if (activeSignature >= 0) {
			var signature:SignatureInformation = signatures[activeSignature];
			var parameters:Array<ParameterInformation> = cast signature.parameters;
			var signatureParts:Array<String> = signature.label.split(Std.string(new as3hx.Compat.Regex('[\\(\\)]', '')));
			var signatureHelpText:String = signatureParts[0] + '(';
			var parametersText:String = signatureParts[1];
			var parameterParts:Array<String> = parametersText.split(',');
			var parameterCount:Int = parameters.length;
			var i:Int = 0;
			while (i < parameterCount) {
				if (i > 0) {
					signatureHelpText += ',';
				}
				var partText:String = parameterParts[i];
				if (i == activeParameter) {
					signatureHelpText += '<b>';
				}
				signatureHelpText += partText;
				if (i == activeParameter) {
					signatureHelpText += '</b>';
				}
				i++;
			}
			signatureHelpText += ')';
			if (signatureParts.length > 2) {
				signatureHelpText += signatureParts[2];
			}
			tooltipText.textFlow = TextConverter.importToFlow(signatureHelpText, TextConverter.TEXT_FIELD_HTML_FORMAT);
			if (!AS3.as(tooltip.isPopUp, Bool)) {
				PopUpManager.addPopUp(tooltip, editor, false);
				var lineText:String = model.lines[model.selectedLineIndex].text;
				tooltipCaret = lineText.lastIndexOf('(', model.caretIndex);
				tooltip.validateNow();
				var position:Point = editor.getPointForIndex(model.caretIndex);
				var tooltipX:Float = position.x + editor.horizontalScrollBar.scrollPosition;
				var tooltipY:Float = position.y - (tooltip.height + 15);
				var maxTooltipX:Float = tooltip.stage.stageWidth - tooltip.width;
				if (tooltipX > maxTooltipX) {
					tooltipX = maxTooltipX;
				}
				if (tooltipY < 0) {
					tooltipY = 0;
				}
				tooltip.move(tooltipX, tooltipY);
				editor.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}
	}

	public function closeSignatureHelp():Void {
		if (!this.isActive) {
			return;
		}
		editor.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		editor.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		PopUpManager.removePopUp(tooltip);
	}

	private function onMouseDown(event:MouseEvent):Void {
		this.closeSignatureHelp();
	}

	private function onKeyDown(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN ||
			String.fromCharCode(e.charCode) == ')' || model.caretIndex <= tooltipCaret) {
			this.closeSignatureHelp();
		}
	}

}