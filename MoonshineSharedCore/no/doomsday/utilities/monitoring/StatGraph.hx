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
package no.doomsday.utilities.monitoring;

import flash.errors.Error;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import no.doomsday.console.core.bitmap.Bresenham;
import no.doomsday.console.core.gui.Window;
import no.doomsday.console.core.text.TextFormats;

/**
 * ...
 * @author Andreas Rønning
 */
class StatGraph extends Sprite {

	private var valueHistory(default, never):Array<Float> = new Array<Float>();
	public var maxValues:Int = 60;
	private var values(default, null):GraphValueStack;
	private var dims(default, never):Rectangle = new Rectangle(0, 0, 300, 100);
	private var graphBitmap:BitmapData;
	private var tagBitmap:BitmapData;
	private var renderStart:Point = new Point();
	private var renderEnd:Point = new Point();
	private var max:Float = 0;
	private var min:Float = 0;
	private var median:Float;
	private var graphDisplay:Bitmap;
	private var tagDisplay:Bitmap;
	private var maxTF:TextField;
	private var midTF:TextField;
	private var minTF:TextField;
	private var queryTF:TextField;
	private var prevQuery:GraphValue;
	private var prevQueryIndex:Int = 0;
	private var dirty:Bool = true;
	private var paused:Bool = false;
	private var content:Sprite = Type.createInstance(Sprite, []);
	private var _disposed:Bool = false;
	private var switchMode:Bool = false;
	private var acceptDuplicateValues:Bool = false;
	private var _bg:Int = 0x00000000;
	private var _graphColor:Int = 0xFFAAAAAA;
	private var _barColor:Int = 0x88000000;

	public var disposed(get, never):Bool;
	private function get_disposed():Bool {
		return _disposed;
	}

	public function new(booleanMode:Bool = false, acceptDuplicateValues:Bool = false, storeHistory:Bool = true) {
		super();
		this.values = new GraphValueStack(this.maxValues);
		this.graphBitmap = new BitmapData(AS3.int(this.dims.width), AS3.int(this.dims.height));
		this.tagBitmap = new BitmapData(AS3.int(this.dims.width), AS3.int(this.dims.height));
		this.median = this.dims.height >> 1;
		this.graphDisplay = new Bitmap(this.graphBitmap);
		this.tagDisplay = new Bitmap(this.tagBitmap);
		values.storeHistory = storeHistory;
		content.addChild(tagDisplay);
		content.addChild(graphDisplay);

		this.switchMode = booleanMode;
		this.acceptDuplicateValues = acceptDuplicateValues;

		maxTF = new TextField();
		midTF = new TextField();
		minTF = new TextField();
		queryTF = new TextField();
		content.addChild(maxTF);
		content.addChild(midTF);
		content.addChild(minTF);
		content.addChild(queryTF);
		var tf:TextFormat = new TextFormat('_sans', 9, 0);
		maxTF.defaultTextFormat = midTF.defaultTextFormat = minTF.defaultTextFormat = queryTF.defaultTextFormat = tf;
		maxTF.mouseEnabled = midTF.mouseEnabled = minTF.mouseEnabled = queryTF.mouseEnabled = false;
		maxTF.autoSize = midTF.autoSize = minTF.autoSize = queryTF.autoSize = TextFieldAutoSize.LEFT;
		queryTF.background = true;
		queryTF.border = true;
		queryTF.visible = false;

		maxTF.x = dims.width;
		minTF.x = dims.width;
		minTF.y = dims.height - 13;
		midTF.x = dims.width;
		midTF.y = median - 8;
		content.addEventListener(MouseEvent.MOUSE_DOWN, startSampling);
		content.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		content.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		content.doubleClickEnabled = true;

		var menu:ContextMenu = new ContextMenu();
		var item:ContextMenuItem = new ContextMenuItem('Clear');
		item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onDoubleClick);
		menu.customItems.push(item);

		if (storeHistory) {
			item = new ContextMenuItem('Save xml');
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveXML, false, 0, true);
			menu.customItems.push(item);
		}
		content.contextMenu = menu;
		addChild(content);

	}

	public var current(get, set):Bool;
	private function set_current(b:Bool):Bool {
		visible = b;
		paused = !b;
		//maxTF.visible = minTF.visible = midTF.visible = b;
		if (b) {
			parent.setChildIndex(this, parent.numChildren - 1);
		}
		return b;
	}

	private function get_current():Bool {
		return visible;
	}

	private function initialize():Void {
		graphBitmap.dispose();
		tagBitmap.dispose();
		median = dims.height >> 1;
		graphBitmap = new BitmapData(AS3.int(dims.width - 50), AS3.int(dims.height));
		tagBitmap = new BitmapData(AS3.int(dims.width - 50), AS3.int(dims.height));
		tagDisplay.bitmapData = tagBitmap;
		graphDisplay.bitmapData = graphBitmap;

		maxTF.x = dims.width - 50;
		minTF.x = dims.width - 50;
		midTF.x = dims.width - 50;
		minTF.y = dims.height - 13;
		midTF.y = median - 8;

		//content.removeChild(tagDisplay);
		//content.removeChild(graphDisplay);
		//graphDisplay = new Bitmap(graphBitmap);
		//tagDisplay = new Bitmap(tagBitmap);
		//content.addChild(tagDisplay);
		//content.addChild(graphDisplay);
		render();
	}

	public function resize(dims:Rectangle):Void {
		this.dims.height = dims.height;
		this.dims.width = dims.width;
		initialize();
	}

	public var graphColor(never, set):Int;
	private function set_graphColor(color:Int):Int {
		_graphColor = color;
		return color;
	}

	public var barColor(never, set):Int;
	private function set_barColor(color:Int):Int {
		_barColor = color;
		return color;
	}

	private function saveXML(e:ContextMenuEvent):Void {
		var xml:FastXML = getXML();
		new FileReference().save(xml, 'Graph.xml');
	}

	public function getXML():FastXML {
		var out:FastXML = FastXML.parse('<graph/>');
		var i:Int = 0;
		while (i < values.allValues.length) {
			var node:FastXML = FastXML.parse('<event>{values.allValues[i]}</event>');
			node.setAttribute("time", values.allValues[i + 1]);
			out.node.appendChild(node);
			i += 2;
		}
		return out;
	}

	public function kill(e:Event = null):Void {
		_disposed = true;
		content.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		content.removeEventListener(MouseEvent.MOUSE_DOWN, startSampling);
		content.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		content.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stopSampling);
		graphBitmap.dispose();
		tagBitmap.dispose();
		parent.removeChild(this);
	}

	private function onDoubleClick(e:Event):Void {
		values.clear();
		min = max = 0;
	}

	private function onMouseWheel(e:MouseEvent):Void {
		maxValues += e.delta;
		maxValues = AS3.int(Math.max(4, maxValues));
		values.maxValues = maxValues;
		min = max = 0;
		values.forEach(checkMinMax);
	}

	private function checkMinMax(value:Float, index:Int):Void {
		if (value < min) {
			min = value;
		}
		if (value > max) {
			max = value;
		}
	}

	private function startSampling(e:Event):Void {
		onMouseMove();
		paused = true;
		queryTF.visible = true;
		content.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, stopSampling);
	}

	private function stopSampling(e:Event):Void {
		paused = false;
		queryTF.visible = false;
		content.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stopSampling);
	}

	private function onMouseMove(e:MouseEvent = null):Void {
		try {
			getValueAt(AS3.int(mouseX));
		} catch (e:Error) {}
	}

	public function add(newValue:Float):Float {
		if (paused || _disposed) {
			return newValue;
		}
		if (switchMode) {
			newValue = toSwitch(newValue);
		}
		if (newValue == values.lastValue && !acceptDuplicateValues) {
			return newValue;
		}

		if (newValue < min) {
			min = newValue;
		}
		if (newValue > max) {
			max = newValue;
		}
		dirty = true;
		values.add(newValue);
		if (visible) {
			render();
		}
		return newValue;
	}

	private function toSwitch(value:Float):Int {
		return ((value > 0)) ? 1 : 0;
	}

	private function render():Void {
		if (!dirty) {
			return;
		}
		if (switchMode) {
			maxTF.text = '1';
			minTF.text = '0';
			midTF.text = 'AVG:' + Std.string(Math.round(values.average));
		} else {
			maxTF.text = Std.string(as3hx.Compat.toPrecision(max, 2));
			minTF.text = Std.string(as3hx.Compat.toPrecision(min, 2));
			midTF.text = 'AVG:' + Std.string(as3hx.Compat.toPrecision(values.average, 2));
		}

		graphBitmap.lock();
		tagBitmap.lock();

		graphBitmap.fillRect(dims, _bg);
		tagBitmap.fillRect(dims, _bg);

		renderStart.x = renderStart.y = 0;
		values.forEach(drawLines);

		graphBitmap.unlock();
		tagBitmap.unlock();
	}

	private function drawLines(value:Float, index:Int):Void {
		var x:Int = AS3.int(index / (values.totalValues - 1) * (dims.width - 50));
		var mul:Float = (value - min) / (max - min);
		var y:Int = AS3.int((1 - mul) * (dims.height - 1));
		if (index == 0) {
			renderStart.x = 0;
			renderStart.y = y;
		} else {
			renderEnd.x = x;
			renderEnd.y = y;
			Bresenham.line_pixel32(renderStart, renderEnd, graphBitmap, _graphColor);
			renderStart.y = median;
			renderStart.x = x;
			//Bresenham.line_pixel32(renderStart, renderEnd, tagBitmap, _barColor);
			renderStart.y = y;
		}
	}

	public function getValueAt(x:Int):Float {
		x = AS3.int(Math.min(x, dims.width - 50));
		var idx:Int = AS3.int(x / (dims.width - 50) * (values.totalValues - 1));
		prevQueryIndex = idx;
		prevQuery = values.getValueAt(idx);
		var mul:Float = (prevQuery.value - min) / (max - min);
		var y:Int = AS3.int((1 - mul) * (dims.height - 25));
		//queryTF.y = median;
		queryTF.y = y;
		queryTF.x = idx / (values.totalValues - 1) * (dims.width - 50);
		queryTF.text = (prevQuery.creationTime / 1000) + '\n' + Std.string(prevQuery.value);
		return prevQuery.value;
	}

}