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

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * ...
 * @author Andreas Rønning
 */
class SimpleScrollbar extends Sprite {

	public static inline var VERTICAL:Int = 0;
	public static inline var HORIZONTAL:Int = 1;
	private var orientation:Int = 0;
	public var trackWidth:Float = 4;
	public var thumbWidth:Float = 4;
	public var minThumbWidth:Float;
	private var length:Float = 0;
	public var outValue:Float = 0;
	private var clickOffset:Float = 0;
	private var thumbPos:Float;

	public function new(orientation:Int) {
		super();
		this.minThumbWidth = this.thumbWidth;
		this.orientation = orientation;
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
	}

	private function startDragging(e:MouseEvent):Void {
		stage.addEventListener(MouseEvent.MOUSE_MOVE, doScroll);
		stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		switch (orientation) {
			case VERTICAL:
				clickOffset = mouseY - thumbPos;
			case HORIZONTAL:
				clickOffset = mouseX - thumbPos;
		}
		doScroll();
	}

	private function stopDragging(e:MouseEvent):Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, doScroll);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
	}

	private function doScroll(e:MouseEvent = null):Void {
		switch (orientation) {
			case VERTICAL:
				outValue = Math.max(0, Math.min(1, (mouseY - clickOffset) / (length - thumbWidth)));
			case HORIZONTAL:
				outValue = Math.max(0, Math.min(1, (mouseX - clickOffset) / (length - thumbWidth)));
		}
		dispatchEvent(new Event(Event.CHANGE));
	}

	public function draw(length:Float, viewRect:Rectangle, currentScroll:Float, maxScroll:Float):Void {
		this.length = length;
		graphics.clear();
		graphics.beginFill(0);

		switch (orientation) {
			case VERTICAL:
				thumbWidth = Math.max(minThumbWidth, (viewRect.height / maxScroll) * length);
				thumbPos = (currentScroll / maxScroll) * (length);
				graphics.drawRect(0, 0, trackWidth, length);
				graphics.beginFill(0xFFFFFF);
				graphics.drawRect(0, thumbPos, trackWidth, thumbWidth);
			case HORIZONTAL:
				thumbWidth = Math.max(minThumbWidth, (viewRect.width / maxScroll) * length);
				thumbPos = (currentScroll / maxScroll) * (length);
				graphics.drawRect(0, 0, length, trackWidth);
				graphics.beginFill(0xFFFFFF);
				graphics.drawRect(thumbPos, 0, thumbWidth, trackWidth);
		}
	}

}