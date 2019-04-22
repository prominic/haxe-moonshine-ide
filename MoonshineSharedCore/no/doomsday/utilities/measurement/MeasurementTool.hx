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
package no.doomsday.utilities.measurement;

import flash.errors.Error;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.ContextMenu;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.introspection.ScopeManager;
import no.doomsday.console.core.messages.MessageTypes;

/**
 * ...
 * @author Andreas R�nning
 */
class MeasurementTool extends Sprite {

	private var rect:Rectangle = new Rectangle();
	private var rectSprite:Sprite;
	private var initialized:Bool = false;
	private var topLeftCornerHandle:Sprite;
	private var bottomRightCornerHandle:Sprite;
	private var widthField:TextField;
	private var heightField:TextField;
	private var xyField:TextField;
	private var fmt:TextFormat;
	private var currentlyChecking:Sprite;
	private var _increment:Float = -1;
	public var clickOffset:Point;
	private var console:DConsole;
	private var previousObj:Dynamic;
	private var scopeManager:ScopeManager;
	private var selectMode:Bool = false;

	public function new(console:DConsole, scopeManager:ScopeManager) {
		super();
		this.console = console;
		this.scopeManager = scopeManager;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}

	private function onRemovedFromStage(e:Event):Void {
		//stage.removeEventListener(Event.RESIZE, getValues);
	}

	public function invoke(doSelect:Bool = false):Void {
		if (doSelect) {
			selectMode = doSelect;
			visible = true;
			console.print('	Snap-selection active. Ctrl-drag to bracket AND select underlying objects.', MessageTypes.SYSTEM);
		} else {
			toggle();
		}
	}

	private function roundTo(num:Float, target:Float):Float {
		return Math.round(num / target) * target;
	}

	private function onAddedToStage(e:Event):Void {
		if (!initialized) {
			fmt = new TextFormat('_sans', 10, 0);
			widthField = new TextField();
			heightField = new TextField();
			xyField = new TextField();
			widthField.defaultTextFormat = heightField.defaultTextFormat = xyField.defaultTextFormat = fmt;
			var center:Point = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			rect = new Rectangle(center.x - 20, center.y - 20, 40, 40);

			rectSprite = Type.createInstance(Sprite, []);
			topLeftCornerHandle = Type.createInstance(Sprite, []);
			bottomRightCornerHandle = Type.createInstance(Sprite, []);

			topLeftCornerHandle.graphics.beginFill(0);
			topLeftCornerHandle.graphics.lineStyle(0, 0xFF0000);
			bottomRightCornerHandle.graphics.beginFill(0);
			bottomRightCornerHandle.graphics.lineStyle(0, 0xFF0000);
			topLeftCornerHandle.graphics.drawCircle(0, 0, 4);
			bottomRightCornerHandle.graphics.drawCircle(0, 0, 4);

			topLeftCornerHandle.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);
			bottomRightCornerHandle.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);
			rectSprite.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);

			rectSprite.buttonMode = topLeftCornerHandle.buttonMode = bottomRightCornerHandle.buttonMode = true;

			addChild(rectSprite);
			addChild(topLeftCornerHandle);
			addChild(bottomRightCornerHandle);

			xyField.mouseEnabled = widthField.mouseEnabled = heightField.mouseEnabled = false;

			xyField.autoSize = widthField.autoSize = heightField.autoSize = TextFieldAutoSize.LEFT;

			addChild(xyField);
			addChild(widthField);
			addChild(heightField);

			initialized = true;
			tabEnabled = tabChildren = false;
		}

		blendMode = BlendMode.INVERT;
		render();
		//stage.addEventListener(Event.RESIZE, getValues, false, 0, true);
	}

	private function startGettingValues(e:MouseEvent):Void {
		currentlyChecking = AS3.as(e.target, Sprite);
		if (currentlyChecking == rectSprite) {
			clickOffset = new Point(mouseX - rect.x, mouseY - rect.y);
		}
		stage.addEventListener(MouseEvent.MOUSE_MOVE, getValues, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, stopGettingValues, false, 0, true);
	}

	private function stopGettingValues(e:MouseEvent):Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, getValues);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stopGettingValues);
	}

	private function setTopLeft(x:Float, y:Float):Void {
		var prevX:Float = rect.x;
		var prevY:Float = rect.y;
		rect.x = x;
		rect.y = y;
		checkSnap();
		var diffX:Float = prevX - rect.x;
		var diffY:Float = prevY - rect.y;
		rect.width += diffX;
		rect.height += diffY;
		rect.width = Math.max(0, rect.width);
		rect.height = Math.max(0, rect.height);
		keepOnStage();
		render();
	}

	private function setBotRight(x:Float, y:Float):Void {
		if (x < rect.x) {
			rect.x = x;
		}
		if (y < rect.y) {
			rect.y = y;
		}
		rect.width = x - rect.x;
		rect.height = y - rect.y;
		checkSnap();
		keepOnStage();
		render();
	}

	private function setCenter(x:Float, y:Float):Void {
		rect.x = x - clickOffset.x;
		rect.y = y - clickOffset.y;
		checkSnap();
		keepOnStage();
		render();
	}

	private function keepOnStage():Void {
		rect.x = Math.max(0, Math.min(rect.x, stage.stageWidth - rect.width));
		rect.y = Math.max(0, Math.min(rect.y, stage.stageHeight - rect.height));
	}

	private function checkSnap():Void {
		if (increment > 0) {
			rect.x = roundTo(rect.x, increment);
			rect.y = roundTo(rect.y, increment);
			rect.width = roundTo(rect.width, increment);
			rect.height = roundTo(rect.height, increment);
		}
	}

	private function getValues(e:Event = null):Void {
		var mx:Float = Math.max(0, Math.min(stage.mouseX, stage.stageWidth));
		var my:Float = Math.max(0, Math.min(stage.mouseY, stage.stageHeight));
		increment = 1;
		var snap:Bool = false;
		if (Std.is(e, MouseEvent)) {
			var me:MouseEvent = AS3.as(e, MouseEvent);
			if (me.shiftKey) {
				increment = 10;
			} else {
				increment = 1;
			}
			snap = me.ctrlKey;
			try {
				me.updateAfterEvent();
			} catch (err:Error) {}
		}

		if (snap) {
			var snapTarget:Rectangle = null;
			var objects:Array<Dynamic> = stage.getObjectsUnderPoint(new Point(mx, my));
			var dispObj:DisplayObject;
			var i:Int = objects.length;
			while (i-- != 0) {
				dispObj = objects[i];
				if (!contains(dispObj)) {
					snapTarget = dispObj.getRect(stage);
					if (dispObj != previousObj) {
						if (selectMode) {
							scopeManager.setScope(dispObj);
						} else {
							console.print('Measure tool bracketing: ' + dispObj.name + ':' + dispObj);
						}
						previousObj = dispObj;
					}
					break;
				}
			}
			if (snapTarget != null) {
				switch (currentlyChecking) {
					case topLeftCornerHandle:
						setTopLeft(snapTarget.x, snapTarget.y);
					case bottomRightCornerHandle:
						setBotRight(snapTarget.x + snapTarget.width, snapTarget.y + snapTarget.height);
					case rectSprite:
						setTopLeft(snapTarget.x, snapTarget.y);
						setBotRight(snapTarget.x + snapTarget.width, snapTarget.y + snapTarget.height);
				}
			} else {
				switch (currentlyChecking) {
					case topLeftCornerHandle:
						setTopLeft(mx, my);
					case bottomRightCornerHandle:
						setBotRight(mx, my);
					case rectSprite:
						setCenter(mx, my);
				}
			}
		} else {
			previousObj = null;
			switch (currentlyChecking) {
				case topLeftCornerHandle:
					setTopLeft(mx, my);
				case bottomRightCornerHandle:
					setBotRight(mx, my);
				case rectSprite:
					setCenter(mx, my);
			}
		}

		render();
	}

	/**
	 * sets x/y and width to the specified display object
	 * @param	displayObject
	 */
	public function bracket(displayObject:DisplayObject):Void {
		console.print('Measure tool bracketing: ' + displayObject.name + ':' + as3hx.Compat.typeof((displayObject)));
		visible = true;
		rect = displayObject.getRect(this);
		render();
		console.print('Measure tool bracketing: ' + displayObject.name + ':' + as3hx.Compat.typeof((displayObject)));
	}

	public function getMeasurements():String {
		return Std.string(rect);
	}

	private function render():Void {
		rectSprite.graphics.clear();
		rectSprite.graphics.beginFill(0, 0.2);
		rectSprite.graphics.lineStyle(0, 0xFF0000);
		rectSprite.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);

		bottomRightCornerHandle.x = rect.x + rect.width;
		bottomRightCornerHandle.y = rect.y + rect.height;
		topLeftCornerHandle.x = rect.x;
		topLeftCornerHandle.y = rect.y;

		xyField.text = 'x:' + rect.x + ' y:' + rect.y;
		xyField.x = rect.x + 5;
		xyField.y = rect.y - 14;
		heightField.text = Std.string(rect.height);
		heightField.x = rect.x + rect.width;
		heightField.y = rect.y + rect.height / 2 - heightField.textHeight / 2;

		widthField.text = Std.string(rect.width);
		widthField.x = rect.x + rect.width / 2 - widthField.textWidth / 2;
		widthField.y = rect.y + rect.height;

	}

	public var increment(get, set):Float;
	private function get_increment():Float {
		return _increment;
	}

	private function set_increment(value:Float):Float {
		_increment = value;
		checkSnap();
		return value;
	}

	public function toggle():Void {
		visible = !visible;
	}

	override private function get_visible():Bool {
		return super.visible;
	}

	override private function set_visible(value:Bool):Bool {
		super.visible = value;

		if (visible) {
			console.print('Measuring bracket active: ' + visible, MessageTypes.SYSTEM);
			console.print('	Hold shift to round to values of 10', MessageTypes.SYSTEM);
			console.print('	Hold ctrl to snap to mouse target', MessageTypes.SYSTEM);
		} else {
			previousObj = null;
		}
		return value;
	}

}