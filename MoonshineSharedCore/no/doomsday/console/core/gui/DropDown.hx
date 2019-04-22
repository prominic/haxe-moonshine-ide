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
package no.doomsday.console.core.gui;

import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import no.doomsday.console.core.events.DropDownEvent;
import no.doomsday.console.core.text.TextFormats;

/**
 * ...
 * @author Andreas Rønning
 */
class DropDown extends Sprite {

	private var titleField:TextField;
	private var headerBar:Sprite = Type.createInstance(Sprite, []);
	private var barHeight:Int = 14;
	private var barWidth:Int = 0;
	private var optionsList:Sprite = Type.createInstance(Sprite, []);
	private var options:Array<DropDownOption> = new Array<DropDownOption>();
	private var optionHeight:Float;
	private var inverter:Shape = new Shape();
	private var selection:DropDownOption;

	public function setTitle(newTitle:String):Void {
		titleField.text = newTitle;
		barWidth = AS3.int(titleField.textWidth + 4);
		draw();
	}

	public function new(title:String = 'Dropdown') {
		super();

		addChild(optionsList);
		addChild(headerBar);
		buttonMode = true;
		titleField = new TextField();
		titleField.autoSize = TextFieldAutoSize.LEFT;
		titleField.defaultTextFormat = TextFormats.windowTitleFormat;
		titleField.text = title;
		titleField.mouseEnabled = false;
		titleField.y = -2;

		headerBar.addChild(titleField);

		headerBar.graphics.beginFill(0);
		headerBar.graphics.drawRect(0, 0, barWidth, barHeight);
		headerBar.graphics.endFill();
		optionsList.visible = false;
		inverter.blendMode = BlendMode.INVERT;
		optionsList.addChild(inverter);
		optionsList.y = barHeight;
		filters = cast [new DropShadowFilter(4, 45, 0, 0.1, 8, 8)];
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	private function onMouseDown(e:MouseEvent):Void {
		optionsList.setChildIndex(inverter, optionsList.numChildren - 1);
		optionsList.visible = true;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	private function onMouseMove(e:MouseEvent):Void {
		var idx:Int = Math.floor(optionsList.mouseY / optionHeight);
		inverter.visible = (idx >= 0 && idx < options.length);
		inverter.y = idx * optionHeight;
		if (inverter.visible) {
			selection = options[idx];
		} else {
			selection = null;
		}
	}

	private function onMouseUp(e:MouseEvent):Void {
		if (selection != null) {
			dispatchEvent(new DropDownEvent(DropDownEvent.SELECTION, selection));
		}
		optionsList.visible = false;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	public function addOption(o:DropDownOption):Void {
		options.push(o);
		o.index = AS3.int(options.length - 1);
		optionsList.addChild(o);
		draw();
	}

	private function draw():Void {
		var h:Float = 0;
		var w:Float = titleField.textWidth + 6;
		for (i in 0...options.length) {
			options[i].y = h;
			optionHeight = options[i].height;
			h += options[i].height;
			if (options[i].width > w) {
				w = options[i].width;
			}
		}
		barWidth = AS3.int(w);
		optionsList.graphics.clear();
		optionsList.graphics.lineStyle(0);
		optionsList.graphics.beginFill(0x222222);
		optionsList.graphics.drawRect(0, 0, w, h);
		inverter.graphics.clear();
		inverter.graphics.beginFill(0xFFFFFF);
		inverter.graphics.drawRect(1, 1, barWidth - 1, optionHeight - 1);
		inverter.graphics.endFill();
		redrawBar();
	}

	private function redrawBar():Void {
		headerBar.graphics.clear();
		headerBar.graphics.beginFill(0);
		headerBar.graphics.lineStyle(0);
		headerBar.graphics.drawRect(0, 0, barWidth, barHeight);
		headerBar.graphics.endFill();
	}

}