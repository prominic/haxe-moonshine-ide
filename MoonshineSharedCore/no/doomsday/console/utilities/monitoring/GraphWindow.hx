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
package no.doomsday.console.utilities.monitoring;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import no.doomsday.console.core.events.DropDownEvent;
import no.doomsday.console.core.gui.DropDown;
import no.doomsday.console.core.gui.DropDownOption;
import no.doomsday.console.core.gui.Window;

/**
 * ...
 * @author Andreas Rønning
 */
class GraphWindow extends Window {

	private static var colors(default, never):Array<Int> = new Array<Int>();
	private var graphs:Array<StatGraph> = new Array<StatGraph>();
	private var dims(default, never):Rectangle = new Rectangle(0, 0, 300, 100);
	private var content:Sprite = Type.createInstance(Sprite, []);
	private var graphChoiceDropdown:DropDown;

	public function new(windowName:String = 'Graph') {
		var windowDims:Rectangle = dims.clone();
		windowDims.width += 50;
		var minDims:Rectangle = windowDims.clone();
		minDims.width = 100;
		minDims.height = 50;
		super(windowName, windowDims, content, null, minDims, true, false, true);
		graphChoiceDropdown = new DropDown('Views');
		graphChoiceDropdown.y = dims.height - 2;
		graphChoiceDropdown.x = 1;
		graphChoiceDropdown.visible = false;
		graphChoiceDropdown.addEventListener(DropDownEvent.SELECTION, onSelection);
		addChild(graphChoiceDropdown);

		colors.push(0xFFF2B31E);
		colors.push(0xFF5CB900);
		colors.push(0xFF800000);
		colors.push(0xFFFF0080);
		colors.push(0xFF8000FF);
		colors.push(0xFF000080);

		addEventListener(Event.ENTER_FRAME, test);

		//TODO: Render all graphs to same bitmapdata

	}

	private function test(e:Event):Void {
		for (i in 0...graphs.length) {
			graphs[i].add(Math.random());
		}
	}

	private function onSelection(e:DropDownEvent):Void {
		for (i in 0...graphs.length) {
			graphs[i].current = (e.selectedOption.index == i);
		}
		graphChoiceDropdown.setTitle(e.selectedOption.title);
	}

	override private function onClose(e:MouseEvent):Void {
		for (i in 0...graphs.length) {
			graphs[i].kill();
		}
		graphs = cast new Array<StatGraph>();
		parent.removeChild(this);
		super.onClose(e);
	}

	override private function onResize():Void {
		for (i in 0...graphs.length) {
			graphs[i].resize(viewRect);
		}
		graphChoiceDropdown.y = viewRect.height - 2;
	}

	public function addGraph(g:StatGraph):Void {
		for (i in 0...graphs.length) {
			graphs[i].current = false;
		}
		content.addChild(g);
		graphs.push(g);
		g.resize(viewRect);
		g.current = true;
		g.graphColor = colors[graphs.length - 1];
		redraw(viewRect);
		graphChoiceDropdown.addOption(new DropDownOption('Graph ' + (graphs.length - 1)));
		graphChoiceDropdown.setTitle('Graph ' + (graphs.length - 1));
		if (graphs.length > 1) {
			graphChoiceDropdown.visible = true;
		}
	}

}