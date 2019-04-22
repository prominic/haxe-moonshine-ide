package actionScripts.ui.editor.text;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flashx.textLayout.conversion.TextConverter;
import mx.containers.VBox;
import mx.managers.PopUpManager;
import spark.components.RichText;
import spark.components.Group;
import spark.layouts.VerticalLayout;

class EditorToolTipManager {

	private static inline var DELAY_MS:Int = 350;

	private var tooltip:VBox;
	private var tooltipGroup:Group;
	private var idToRichText:Dynamic = {};
	private var idToValue:Dynamic = {};
	private var tooltipTimeoutHandle:Int = -1;

	private var editor:TextEditor;
	private var model:TextEditorModel;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;

		tooltip = new VBox();
		tooltip.styleName = 'toolTip';
		tooltip.focusEnabled = false;
		tooltip.mouseEnabled = false;
		tooltip.mouseChildren = false;
		tooltip.maxWidth = 450;

		//RichText won't wrap correctly if added to the VBox above, for some
		//reason, so we're going to add it to this internal Group instead
		tooltipGroup = new Group();
		tooltipGroup.percentWidth = 100;
		tooltipGroup.maxWidth = 450;
		tooltipGroup.layout = new VerticalLayout();
		tooltip.addElement(tooltipGroup);
	}

	public function setTooltip(id:String, value:String):Void {
		if (value == null) {
			if (!(Reflect.hasField(idToValue, id))) {
				//there's nothing to clear
				return;
			}
			var richText:RichText = Reflect.field(idToRichText, id);
			tooltipGroup.removeElement(richText);
			Reflect.deleteField(idToRichText, id);
			Reflect.deleteField(idToValue, id);
			var stillHasData:Bool = false;
			for (key in Reflect.fields(idToValue)) {
				stillHasData = true;
				break;
			}
			if (!stillHasData) {
				closeTooltip();
				return;
			}
		} else {
			var oldValue:String = AS3.string(Reflect.field(idToValue, id));
			if (oldValue == value) {
				//the value has not changed, so ignore it
				return;
			}
			Reflect.setField(idToValue, id, value);
			if (Reflect.hasField(idToRichText, id)) {
				richText = Reflect.field(idToRichText, id);
			} else {
				richText = new RichText();
				richText.percentWidth = 100;
				tooltipGroup.addElement(richText);
				Reflect.setField(idToRichText, id, richText);
			}
			richText.textFlow = TextConverter.importToFlow(value, TextConverter.PLAIN_TEXT_FORMAT);
		}
		if (AS3.as(tooltip.isPopUp, Bool)) {
			//we're already showing the tooltip, so simply reposition it,
			//if needed
			this.showTooltipAfterDelay();
			return;
		}
		//if we're still waiting to show the last one, clear it
		if (tooltipTimeoutHandle != -1) {
			as3hx.Compat.clearTimeout(tooltipTimeoutHandle);
		}
		tooltipTimeoutHandle = as3hx.Compat.setTimeout(showTooltipAfterDelay, DELAY_MS);

		//previously, we listened for these events after the timeout, but
		//it's actually better to listen immediately so that we can clear
		//the timeout because it's possible for the mouse to move away or
		//a key to be pressed before the timeout and that could show the
		//tooltip unexpectedly
		editor.addEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
		editor.addEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
	}

	public function showTooltipAfterDelay():Void {
		tooltipTimeoutHandle = -1;
		if (!AS3.as(tooltip.isPopUp, Bool)) {
			PopUpManager.addPopUp(tooltip, editor, false);
		}

		//to get an accurate height, we need to validate first
		tooltip.validateNow();

		var tooltipX:Float = tooltip.stage.mouseX;
		var tooltipY:Float = tooltip.stage.mouseY - (tooltip.height + 15);
		var maxTooltipX:Float = tooltip.stage.stageWidth - tooltip.width;
		if (tooltipX > maxTooltipX) {
			tooltipX = maxTooltipX;
		}
		if (tooltipY < 0) {
			tooltipY = 0;
		}
		tooltip.move(tooltipX, tooltipY);
	}

	public function closeTooltip():Void {
		if (tooltipTimeoutHandle != -1) {
			as3hx.Compat.clearTimeout(tooltipTimeoutHandle);
			tooltipTimeoutHandle = -1;
		}
		for (id in Reflect.fields(idToValue)) {
			Reflect.deleteField(idToValue, id);

			var text:RichText = Reflect.field(idToRichText, id);
			tooltipGroup.removeElement(text);
			Reflect.deleteField(idToRichText, id);
		}
		//previously, these listeners were only removed if the tooltip was a
		//popup, but now they are added before the tooltip is displayed, so
		//they always need to be removed
		editor.removeEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
		editor.removeEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
		if (!AS3.as(tooltip.isPopUp, Bool)) {
			return;
		}
		PopUpManager.removePopUp(tooltip);
	}

	private function editor_onRollOut(event:MouseEvent):Void {
		closeTooltip();
	}

	private function editor_onKeyDown(event:KeyboardEvent):Void {
		closeTooltip();
	}

}