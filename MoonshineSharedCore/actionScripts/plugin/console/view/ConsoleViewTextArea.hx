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
package actionScripts.plugin.console.view;

import spark.components.RichEditableText;
import spark.components.TextArea;
import spark.components.VScrollBar;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleTextLineModel;
import actionScripts.ui.editor.text.TextEditorModel;
import actionScripts.ui.editor.text.TextLineModel;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.FlowElementMouseEvent;
import no.doomsday.console.core.events.ConsoleEvent;

class ConsoleViewTextArea extends TextArea {

	private var model:TextEditorModel;

	public function new() {
		super();
		this.setStyle('contentBackgroundColor', 0x373737);
		this.setStyle('contentBackgroundAlpha', 0.9);
		this.setStyle('borderVisible', false);

		this.percentHeight = 100;
		this.percentWidth = 100;
	}

	override private function partAdded(partName:String, instance:Dynamic):Void {
		super.partAdded(partName, instance);
		if (instance == textDisplay) {
			(AS3.as(textDisplay, RichEditableText)).textFlow.addEventListener(ConsoleEvent.REPORT_A_BUG, onReportBugFromConsole, false, 0, true);
		}
	}

	public var numLines(get, never):Int;
	private function get_numLines():Int {
		return AS3.int(this.heightInLines);
	}

	public var numVisibleLines(get, never):Int;
	private function get_numVisibleLines():Int {
		return 0;
	}

	public function appendtext(text:Dynamic):Int {
		var linesCount:Int;
		if (Std.is(text, String)) {
			var lines:Array<Dynamic> = text.split('\n');
			linesCount = lines.length;
			var p:ParagraphElement;
			var tf:TextFlow;
			var pe:ParagraphElement;
			var fe:FlowElement;
			for (i in 0...linesCount) {
				p = new ParagraphElement();
				tf = TextConverter.importToFlow(Std.string(lines[i]) + '\n', TextConverter.TEXT_FIELD_HTML_FORMAT);
				pe = Reflect.getProperty(tf.mxmlChildren, Std.string(0));
				for (fe in as3hx.Compat.each(pe.mxmlChildren)) {
					p.addChild(fe);
				}

				this.textFlow.addChild(p);
				//model.lines.push( new TextLineModel(lines[i]) );
				//this.appendText(lines[i] + "\n");
			}

			/*model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
			invalidateLines();*/
			callLater(setScroll);
			return this.numLines;
		} else if (Std.is(text, Array/*Vector.<T> call?*/)) {
			linesCount = AS3.int(text.length);
			for (i in 0...linesCount) {
				p = new ParagraphElement();
				if (Std.is(Reflect.field(text, Std.string(i)), ConsoleTextLineModel)) {
					p.color = (AS3.as(Reflect.field(text, Std.string(i)), ConsoleTextLineModel)).getTextColor();
				}

				tf = TextConverter.importToFlow(Std.string(Reflect.field(text, Std.string(i))) + '\n', TextConverter.PLAIN_TEXT_FORMAT);
				//tf = TextFlowUtil.importFromString(String("<p>"+text[i])+"</p>");
				pe = Reflect.getProperty(tf.mxmlChildren, Std.string(0));
				for (fe in as3hx.Compat.each(pe.mxmlChildren)) {
					p.addChild(fe);
				}
				this.textFlow.addChild(p);
				//model.lines.push( text[i] );
				//this.appendText( String(text[i]) +"\n");
			}

			/*model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
			invalidateLines();*/
			callLater(setScroll);
			return this.numLines;
		} else if (Std.is(text, ParagraphElement)) {
			this.textFlow.addChild(text);
			callLater(setScroll);
		}

		// Remove initial empty line (first time anything is outputted)
		return 0;
	}

	private function onReportBugFromConsole(event:FlowElementMouseEvent):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleEvent(ConsoleEvent.REPORT_A_BUG));
	}

	private function setScroll():Void {
		var scrollBar:VScrollBar = this.scroller.verticalScrollBar;
		scrollBar.value = scrollBar.maximum;
		this.validateNow();
		if (scrollBar.value != scrollBar.maximum) {
			scrollBar.value = scrollBar.maximum;
			this.validateNow();
		}
	}

}