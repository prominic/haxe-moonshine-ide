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
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import no.doomsday.console.core.text.TextFormats;

/**
 * ...
 * @author Andreas Rønning
 */
class Window extends Sprite {

	private var contents:Sprite = Type.createInstance(Sprite, []);
	private var chrome:Sprite = Type.createInstance(Sprite, []);
	private var outlines:Shape = new Shape();
	private var header:Sprite = Type.createInstance(Sprite, []);
	private var titleField:TextField = new TextField();
	public var BAR_HEIGHT(default, never):Int = 12;
	public var SCALE_HANDLE_SIZE(default, never):Int = 10;
	private var GRADIENT_MATRIX(default, never):Matrix = new Matrix();
	private var resizeHandle:Sprite = Type.createInstance(Sprite, []);
	private var clickOffset:Point = new Point();
	private var resizeRect:Rectangle = new Rectangle();
	private var maxRect:Rectangle;
	private var minRect:Rectangle;
	private var maxScrollV:Float = 0;
	private var maxScrollH:Float = 0;
	private var scrollBarBottom:SimpleScrollbar = new SimpleScrollbar(SimpleScrollbar.HORIZONTAL);
	private var scrollBarRight:SimpleScrollbar = new SimpleScrollbar(SimpleScrollbar.VERTICAL);
	private var viewRect:Rectangle;
	private var closeButton:Sprite = Type.createInstance(Sprite, []);
	private var background:Shape = new Shape();

	public function new(title:String, rect:Rectangle, contents:DisplayObject = null, maxRect:Rectangle = null, minRect:Rectangle = null, enableClose:Bool = true, enableScroll:Bool = true, enableScale:Bool = true) {
		super();
		tabEnabled = tabChildren = false;
		scrollBarBottom.addEventListener(Event.CHANGE, onScroll);
		scrollBarRight.addEventListener(Event.CHANGE, onScroll);

		closeButton.graphics.beginFill(0xFFFFFF);
		closeButton.graphics.lineStyle(0, 0);
		closeButton.graphics.drawRect(0, 0, BAR_HEIGHT - 3, BAR_HEIGHT - 3);
		closeButton.buttonMode = true;

		addChild(background);
		this.contents.y = background.y = BAR_HEIGHT;
		addChild(this.contents);

		this.maxRect = maxRect;
		this.minRect = minRect;

		//rect.height += BAR_HEIGHT;
		titleField.height = BAR_HEIGHT + 3;
		titleField.selectable = false;
		titleField.defaultTextFormat = TextFormats.windowTitleFormat;
		titleField.text = title;
		titleField.y -= 2;
		titleField.mouseEnabled = false;

		resizeHandle.graphics.clear();
		resizeHandle.graphics.beginFill(0xFF0000, 0);
		resizeHandle.graphics.drawRect(0, 0, SCALE_HANDLE_SIZE, SCALE_HANDLE_SIZE);
		resizeHandle.graphics.endFill();
		resizeHandle.graphics.lineStyle(0, 0x333333);
		resizeHandle.graphics.moveTo(SCALE_HANDLE_SIZE, 0);
		resizeHandle.graphics.lineTo(0, SCALE_HANDLE_SIZE);
		resizeHandle.graphics.moveTo(SCALE_HANDLE_SIZE, 5);
		resizeHandle.graphics.lineTo(0, SCALE_HANDLE_SIZE + 5);
		resizeHandle.scrollRect = new Rectangle(0, 0, SCALE_HANDLE_SIZE, SCALE_HANDLE_SIZE);

		closeButton.addEventListener(MouseEvent.CLICK, onClose);
		closeButton.addEventListener(MouseEvent.ROLL_OVER, onCloseRollover);
		closeButton.addEventListener(MouseEvent.ROLL_OUT, onCloseRollout);

		addChild(chrome);
		header.addChild(titleField);
		chrome.addChild(header);
		if (enableScroll) {
			chrome.addChild(scrollBarBottom);
			chrome.addChild(scrollBarRight);
		}
		if (enableScale) {
			chrome.addChild(resizeHandle);
		}
		if (enableClose) {
			chrome.addChild(closeButton);
		}
		chrome.addChild(outlines);

		resizeHandle.buttonMode = header.buttonMode = true;

		x = rect.x;
		y = rect.y;

		var dsf:DropShadowFilter = new DropShadowFilter(4, 45, 0, .1, 8, 8);
		filters = cast [dsf];

		redraw(rect);

		header.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
		resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, startResizing);
		addEventListener(MouseEvent.MOUSE_DOWN, setDepth);
		if (contents != null) {
			setContents(contents);
		}
	}

	private function onCloseRollout(e:MouseEvent):Void {
		DisplayObject(e.target).blendMode = BlendMode.NORMAL;
	}

	private function onCloseRollover(e:MouseEvent):Void {
		DisplayObject(e.target).blendMode = BlendMode.INVERT;
	}

	private function setTitle(str:String):Void {
		titleField.text = str;
	}

	private function onClose(e:MouseEvent):Void {
		header.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging);
		resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, startResizing);
		removeEventListener(MouseEvent.MOUSE_DOWN, setDepth);
	}

	private function onScroll(e:Event):Void {
		var r:Rectangle = getContentsRect();
		var newRect:Rectangle = contents.scrollRect.clone();
		switch (e.target) {
			case scrollBarBottom:
				newRect.x = scrollBarBottom.outValue * (maxScrollH - newRect.width);
			case scrollBarRight:
				newRect.y = scrollBarRight.outValue * (maxScrollV - newRect.height);
		}
		contents.scrollRect = newRect;
		redraw(viewRect);
	}

	private function startResizing(e:MouseEvent):Void {
		clickOffset.x = SCALE_HANDLE_SIZE - resizeHandle.mouseX;
		clickOffset.y = SCALE_HANDLE_SIZE - resizeHandle.mouseY;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onResizeDrag);
		stage.addEventListener(MouseEvent.MOUSE_UP, onResizeStop);
	}

	private function onResizeStop(e:MouseEvent):Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResizeDrag);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onResizeStop);
	}

	private function onResizeDrag(e:MouseEvent):Void {
		e.updateAfterEvent();
		var newMaxX:Float = Math.max(SCALE_HANDLE_SIZE + BAR_HEIGHT, mouseX + clickOffset.x);
		var newMaxY:Float = Math.max(SCALE_HANDLE_SIZE + BAR_HEIGHT, mouseY + clickOffset.y);
		resizeRect.width = newMaxX;
		resizeRect.height = newMaxY - BAR_HEIGHT;
		if (minRect != null) {
			resizeRect.width = Math.max(minRect.width, resizeRect.width);
			resizeRect.height = Math.max(minRect.height, resizeRect.height);
		}
		onResize();
		redraw(resizeRect);
	}

	private function onResize():Void {}

	private function scroll(x:Int = 0, y:Int = 0):Void {
		if (contents.scrollRect.x + x >= 0) {
			if (contents.scrollRect.width + x <= maxScrollH) {
				contents.scrollRect.x += x;
			}
		}
		if (contents.scrollRect.y + y >= 0) {
			if (contents.scrollRect.height + y <= maxScrollV) {
				contents.scrollRect.y += y;
			}
		}
	}

	private function resetScroll():Void {
		contents.scrollRect.x = 0;
		contents.scrollRect.y = 0;
		scrollBarBottom.outValue = 0;
		scrollBarRight.outValue = 0;
	}

	private function redraw(rect:Rectangle):Void {
		GRADIENT_MATRIX.createGradientBox(rect.width * 3, rect.height * 3);

		background.graphics.clear();
		background.graphics.beginGradientFill(GradientType.RADIAL, cast [0xBBBBBB, 0xEEEEEE], cast [1, 1], cast [0, 255], GRADIENT_MATRIX);
		background.graphics.drawRect(0, 0, rect.width, rect.height);

		header.graphics.clear();
		header.graphics.beginFill(0x111111);
		header.graphics.drawRect(0, 0, rect.width, BAR_HEIGHT);
		header.graphics.endFill();

		outlines.graphics.clear();
		outlines.graphics.lineStyle(0, 0);
		outlines.graphics.drawRect(0, 0, rect.width, rect.height + BAR_HEIGHT);

		titleField.width = rect.width;
		closeButton.x = rect.width - (BAR_HEIGHT - 2);
		closeButton.y = 1;

		resizeHandle.x = rect.width - SCALE_HANDLE_SIZE;
		resizeHandle.y = rect.height + BAR_HEIGHT - SCALE_HANDLE_SIZE;

		var cRect:Rectangle = getContentsRect();

		if (rect.width < cRect.width) {
			maxScrollH = cRect.width;
		} else {
			maxScrollH = 0;
		}
		if (rect.height < cRect.height) {
			maxScrollV = cRect.height;
		} else {
			maxScrollV = 0;
		}
		contents.scrollRect = new Rectangle(Math.max(0, scrollBarBottom.outValue * (maxScrollH - rect.width)), Math.max(0, scrollBarRight.outValue * (maxScrollV - rect.height)), rect.width + 1, rect.height + 1);
		updateScrollBars(maxScrollH, maxScrollV, rect);
		viewRect = rect;
	}

	private function updateScrollBars(maxH:Float, maxV:Float, rect:Rectangle):Void {
		if (maxH > 0) {
			scrollBarBottom.visible = true;
			scrollBarBottom.y = rect.height + BAR_HEIGHT - scrollBarBottom.trackWidth;
			scrollBarBottom.draw(rect.width - SCALE_HANDLE_SIZE, contents.scrollRect, contents.scrollRect.x, maxH);
		} else {
			scrollBarBottom.visible = false;
		}

		if (maxV > 0) {
			scrollBarRight.visible = true;
			scrollBarRight.x = rect.width - scrollBarRight.trackWidth;
			scrollBarRight.y = BAR_HEIGHT;
			scrollBarRight.draw(rect.height - SCALE_HANDLE_SIZE, contents.scrollRect, contents.scrollRect.y, maxV);
		} else {
			scrollBarRight.visible = false;
		}
	}

	private function getContentsRect():Rectangle {
		if (contents.numChildren < 1) {
			return new Rectangle();
		}
		return contents.getChildAt(0).getRect(contents);
	}

	private function setDepth(e:MouseEvent):Void {
		parent.setChildIndex(this, parent.numChildren - 1);
	}

	private function startDragging(e:MouseEvent):Void {
		clickOffset.x = chrome.mouseX;
		clickOffset.y = chrome.mouseY;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onWindowDrag);
		stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
	}

	private function stopDragging(e:MouseEvent):Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onWindowDrag);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
	}

	private function onWindowDrag(e:MouseEvent):Void {
		x = stage.mouseX - clickOffset.x;
		y = stage.mouseY - clickOffset.y;
		e.updateAfterEvent();
		dispatchEvent(new Event(Event.CHANGE));
	}

	private function setContents(d:DisplayObject):Void {
		while (contents.numChildren > 0) {
			contents.removeChildAt(0);
		}
		contents.addChild(d);
	}

}