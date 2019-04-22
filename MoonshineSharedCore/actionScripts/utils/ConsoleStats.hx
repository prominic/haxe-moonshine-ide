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
/**
 * Hi-ReS! Stats
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 *
 *	addChild( new Stats() );
 *
 *	or
 *
 *	addChild( new Stats( { bg: 0xffffff } );
 *
 * version log:
 *
 *	09.03.28		2.1		Mr.doob			+ Theme support.
 *	09.02.21		2.0		Mr.doob			+ Removed Player version, until I know if it's really needed.
 *											+ Added MAX value (shows Max memory used, useful to spot memory leaks)
 *											+ Reworked text system / no memory leak (original reason unknown)
 *											+ Simplified
 *	09.02.07		1.5		Mr.doob			+ onRemovedFromStage() (thx huihuicn.xu)
 *	08.12.14		1.4		Mr.doob			+ Code optimisations and version info on MOUSE_OVER
 *	08.07.12		1.3		Mr.doob			+ Some speed and code optimisations
 *	08.02.15		1.2		Mr.doob			+ Class renamed to Stats (previously FPS)
 *	08.01.05		1.2		Mr.doob			+ Click changes the fps of flash (half up increases, half down decreases)
 *	08.01.04		1.1		Mr.doob			+ Shameless ripoff of Alternativa's FPS look :P
 *							Theo			+ Log shape for MEM
 *											+ More room for MS
 * 	07.12.13		1.0		Mr.doob			+ First version
 **/

//Some alterations made to link more effectively into no.doomsday.console.DConsole

package actionScripts.utils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.messages.MessageTypes;

/**
 * <b>Hi-ReS! Stats</b> FPS, MS and MEM, all in one.
 */
class ConsoleStats extends Sprite {

	private var _xml:FastXML;

	private var _text:TextField;
	private var _style:StyleSheet;

	private var _timer:Int = 0;
	private var _fps:Int = 0;
	private var _ms:Int = 0;
	private var _ms_prev:Int = 0;
	private var _mem:Float;
	private var _mem_max:Float;

	private var _graph:BitmapData;
	private var _rectangle:Rectangle;

	private var _fps_graph:Int = 0;
	private var _mem_graph:Int = 0;
	private var _mem_max_graph:Int = 0;

	private var console:DConsole;

	private var _theme:Dynamic = {
			'bg': 0x111111,
			'fps': 0xffff00,
			'ms': 0x00ff00,
			'mem': 0x00ffff,
			'memmax': 0xff0070
		};

	/**
	 * <b>Hi-ReS! Stats</b> FPS, MS and MEM, all in one.
	 *
	 * @param theme         Example: { bg: 0x202020, fps: 0xC0C0C0, ms: 0x505050, mem: 0x707070, memmax: 0xA0A0A0 }
	 */
	public function new(console:DConsole) {
		super();
		this.console = console;
		buttonMode = true;

		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	}

	private function shutdown(e:Event):Void {
		removeEventListener(Event.REMOVED_FROM_STAGE, shutdown);
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(Event.ENTER_FRAME, update);
	}

	private function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		addEventListener(Event.REMOVED_FROM_STAGE, shutdown, false, 0, true);

		graphics.beginFill(AS3.int(Reflect.field(_theme, 'bg')));
		graphics.drawRect(0, 0, 70, 50);
		graphics.endFill();

		_mem_max = 0;

		_xml = FastXML.parse('<xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>');

		_style = new StyleSheet();
		_style.setStyle('xml', {
					'fontSize': '9px',
					'fontFamily': '_sans',
					'leading': '-2px'
				});
		_style.setStyle('fps', {
					'color': hex2css(AS3.int(Reflect.field(_theme, 'fps')))
				});
		_style.setStyle('ms', {
					'color': hex2css(AS3.int(Reflect.field(_theme, 'ms')))
				});
		_style.setStyle('mem', {
					'color': hex2css(AS3.int(Reflect.field(_theme, 'mem')))
				});
		_style.setStyle('memMax', {
					'color': hex2css(AS3.int(Reflect.field(_theme, 'memmax')))
				});

		_text = new TextField();
		_text.width = 70;
		_text.height = 50;
		_text.styleSheet = _style;
		_text.condenseWhite = true;
		_text.selectable = false;
		_text.mouseEnabled = false;
		addChild(_text);

		var bitmap:Bitmap = new Bitmap(_graph = new BitmapData(70, 50, false, AS3.int(Reflect.field(_theme, 'bg'))));
		bitmap.y = 50;
		addChild(bitmap);

		_rectangle = new Rectangle(0, 0, 1, _graph.height);

		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(Event.ENTER_FRAME, update);
	}

	private function update(e:Event):Void {
		_timer = Math.round(haxe.Timer.stamp() * 1000);

		if (_timer - 1000 > _ms_prev) {
			_ms_prev = _timer;
			_mem = as3hx.Compat.parseFloat(as3hx.Compat.toFixed(System.totalMemory * 0.000000954, 3));
			_mem_max = (_mem_max > _mem) ? _mem_max : _mem;

			_fps_graph = AS3.int(Math.min(50, (_fps / stage.frameRate) * 50));
			_mem_graph = AS3.int(Math.min(50, Math.sqrt(Math.sqrt(_mem * 5000))) - 2);
			_mem_max_graph = AS3.int(Math.min(50, Math.sqrt(Math.sqrt(_mem_max * 5000))) - 2);

			_graph.scroll(1, 0);

			_graph.fillRect(_rectangle, AS3.int(Reflect.field(_theme, 'bg')));
			_graph.setPixel(0, _graph.height - _fps_graph, AS3.int(Reflect.field(_theme, 'fps')));
			_graph.setPixel(0, _graph.height - ((_timer - _ms) >> 1), AS3.int(Reflect.field(_theme, 'ms')));
			_graph.setPixel(0, _graph.height - _mem_graph, AS3.int(Reflect.field(_theme, 'mem')));
			_graph.setPixel(0, _graph.height - _mem_max_graph, AS3.int(Reflect.field(_theme, 'memmax')));

			_xml.node.fps = 'FPS: ' + _fps + ' / ' + stage.frameRate;
			_xml.node.mem = 'MEM: ' + _mem;
			_xml.node.memMax = 'MAX: ' + _mem_max;

			_fps = 0;
		}

		_fps++;

		_xml.node.ms = 'MS: ' + (_timer - _ms);
		_ms = _timer;

		_text.htmlText = Std.string(_xml);
	}

	private function onClick(e:MouseEvent):Void {
		(mouseY / height > .5) ? stage.frameRate-- : stage.frameRate++;
		_xml.node.fps = 'FPS: ' + _fps + ' / ' + stage.frameRate;

		_text.htmlText = Std.string(_xml);
		console.print('Framerate set to ' + stage.frameRate, MessageTypes.SYSTEM);
	}

	// .. Utils

	private function hex2css(color:Int):String {
		return '#' + as3hx.Compat.toString(color, 16);
	}

}