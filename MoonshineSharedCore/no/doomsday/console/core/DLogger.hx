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

/** Tool for displaying a trace window in a released/uploaded SWF
  *
  * Created by Ã˜yvind Nordhagen, www.oyvindnordhagen.com.
  * Released for use, change and distribution free of charge as
  * long as this author credit is left as is.
  *
  * For documentation, suggestions and bug reporting, see www.oyvindnordhagen.com/blog/ailogger/
  */

package no.doomsday.console.core;

import flash.errors.Error;
import flash.errors.ReferenceError;
import no.doomsday.console.core.messages.Message;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.xml.XMLNode;
import no.doomsday.console.core.commands.ConsoleCommand;
import no.doomsday.console.core.interfaces.IConsole;
import no.doomsday.console.core.interfaces.IDisplayable;
import no.doomsday.console.core.interfaces.ILogger;
import no.doomsday.console.core.events.DLoggerEvent;
import no.doomsday.console.core.messages.MessageTypes;
import no.doomsday.console.core.text.TextFormats;
import no.doomsday.console.core.text.TextUtils;

@:final class DLogger extends AbstractConsole {

	private static inline var WELCOME_MESSAGE:String = 'Welcome to DLogger by Øyvind Nordhagen - www.oyvindnordhagen.com';
	private static inline var VERSION:String = '1.0';
	private static inline var OPEN_LOGGER_LABEL:String = 'Show DLogger';
	private static inline var CLOSE_LOGGER_LABEL:String = 'Close DLogger';
	private static inline var CODE_HEX:Int = 99;

	public var detailedLogging:Bool = false;
	public var disablePassword:Bool = false;
	public var disableSenderLabels:Bool = false;
	public var alwaysOnTop:Bool = true;
	public var scrollOnNewLine:Bool = true;

	private var _password:String;
	private var _passwordEntered:String = '';
	private var _scrollSpeed:Int = 2;
	private var _enableContextMenu:Bool = true;
	private var _logColoring:Bool = true;
	private var _inverseColor:Bool = false;
	private var _isVisible:Bool = false;
	private var _fmt:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _senderFmt:TextFormat;
	private var _describeFmt:TextFormat;
	private var _passwordField:TextField;
	private var _txt:TextField;
	private var _bg:Shape = new Shape();
	private var _passwordTimer:Timer;
	private var _lastMessage:String;
	private var _lastMessageRepeat:Int = 0;
	private var _maxHeight:Int = 0;
	private var _width:Int = 0;
	private var _height:Int = 0;
	private var _txtBounds:Rectangle;
	private var _fadeTarget:Float = 1;

	/**
	 * Constructor function
	 *
	 * @param	$password		Password for opening trace window. Empty string = no password
	 * @param	$width			Width of the log window, default: fills stage.
	 * @param	$password		Height of the log window, default: fills stage
	 */
	public function new(__DOLLAR__password:String = '', __DOLLAR__width:Int = 0, __DOLLAR__height:Int = 0) {
		super();
		_password = __DOLLAR__password;
		_width = __DOLLAR__width;
		_height = __DOLLAR__height;

		_setColorScheme();

		//_senderFmt = _getFmt(0xFFFFFF);
		_describeFmt = TextFormats.debugTformatSystem;

		_createTraceWindow();

		addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
	}

	override public function setPassword(pass:String):Void {
		_password = pass;
	}

	public var inverseColorScheme(get, set):Bool;
	private function set_inverseColorScheme(__DOLLAR__val:Bool):Bool {
		_inverseColor = __DOLLAR__val;
		_setColorScheme();

		if (_bg != null) {
			_redrawBg();
		}
		return __DOLLAR__val;
	}

	private function _setColorScheme():Void {
		if (_inverseColor) {
			_setInverseColor();
		} else {
			_setRegularColor();
		}
	}

	private function _setInverseColor():Void {
		_fmt.set(MessageTypes.OUTPUT, TextFormats.getInverse(TextFormats.debugTformatNew));
		_fmt.set(MessageTypes.WARNING, TextFormats.getInverse(TextFormats.debugTformatWarning));
		_fmt.set(MessageTypes.ERROR, TextFormats.getInverse(TextFormats.debugTformatError));
		_fmt.set(MessageTypes.SYSTEM, TextFormats.getInverse(TextFormats.debugTformatSystem));
		_fmt.set(MessageTypes.EVENT, TextFormats.getInverse(TextFormats.debugTformatEvent));
		_fmt.set(MessageTypes.TRACE, TextFormats.getInverse(TextFormats.debugTformatTrace));

		//_fmt[MessageTypes.OUTPUT] 	= _getFmt(0xFFFFFF);
		//_fmt[MessageTypes.WARNING] 	= _getFmt(0xFF6600);
		//_fmt[MessageTypes.ERROR] 	= _getFmt(0xFF0000);
		//_fmt[MessageTypes.SYSTEM] 	= _getFmt(0x00FF00);
		//_fmt[MessageTypes.EVENT] 	= _getFmt(0x0099FF);
		//_fmt[MessageTypes.TRACE] 	= _getFmt(0x999999);
	}

	private function _setRegularColor():Void {
		_fmt.set(MessageTypes.OUTPUT, TextFormats.debugTformatNew);
		_fmt.set(MessageTypes.WARNING, TextFormats.debugTformatWarning);
		_fmt.set(MessageTypes.ERROR, TextFormats.debugTformatError);
		_fmt.set(MessageTypes.SYSTEM, TextFormats.debugTformatSystem);
		_fmt.set(MessageTypes.EVENT, TextFormats.debugTformatEvent);
		_fmt.set(MessageTypes.TRACE, TextFormats.debugTformatTrace);

		//_fmt[MessageTypes.OUTPUT] = _getFmt(0x000000);
		//_fmt[MessageTypes.WARNING] = _getFmt(0x996600);
		//_fmt[MessageTypes.ERROR] = _getFmt(0xCC0000);
		//_fmt[MessageTypes.SYSTEM] = _getFmt(0x009900);
		//_fmt[MessageTypes.EVENT] = _getFmt(0x000099);
		//_fmt[MessageTypes.TRACE] = _getFmt(0x666666);
	}

	private function get_inverseColorScheme():Bool {
		return _inverseColor;
	}

	public var coloring(get, set):Bool;
	private function get_coloring():Bool {
		return _logColoring;
	}

	private function set_coloring(__DOLLAR__val:Bool):Bool {
		_logColoring = __DOLLAR__val;

		if (!__DOLLAR__val) {
			_resetLogColoring();
		}
		return __DOLLAR__val;
	}

	public var enableContextMenu(get, set):Bool;
	private function get_enableContextMenu():Bool {
		return _enableContextMenu;
	}

	private function set_enableContextMenu(__DOLLAR__val:Bool):Bool {
		if (parent != null) {
			if (__DOLLAR__val && parent.contextMenu == null) {
				_createContextMenuItems();
			} else if (!__DOLLAR__val && parent.contextMenu != null) {
				_removeContextMenuItems();
			}
		}

		_enableContextMenu = __DOLLAR__val;
		return __DOLLAR__val;
	}

	public function getLogText():String {
		return _txt.text;
	}

	public var isVisible(get, never):Bool;
	private function get_isVisible():Bool {
		return _isVisible;
	}

	public function toggle():Void {
		_toggleVisible();
	}

	public function describe(__DOLLAR__obj:Dynamic, __DOLLAR__objectName:String = ''):Void {
		if (__DOLLAR__objectName == '') {
			if (Std.string(__DOLLAR__obj) != '[object Object]') {
				_log(_getClassName(__DOLLAR__obj) + ':\n', '', true, false);
			} else {
				_log('Describe:\n', '', true, false);
			}
		} else {
			_log(__DOLLAR__objectName + ':\n', '', true, false);
		}

		_applySeverityColor(MessageTypes.OUTPUT);

		var variables:FastXMLList = DescribeType.describeType(__DOLLAR__obj).variable;
		var numVariables:Int = AS3.int(variables.length());

		if (numVariables > 0) {
			for (i in 0...numVariables) {
				var v:FastXML = variables.get(i);
				var value:String = ((Reflect.field(__DOLLAR__obj, Std.string(v.att.name)) == '')) ? '""' : AS3.string(Reflect.field(__DOLLAR__obj, Std.string(v.att.name)));
				_log(v.att.name + ':' + v.att.type + ' = ' + value, '', false, false);
				_applySeverityColor(MessageTypes.TRACE, 0, false, true);
			}
		} else {
			for (prop in Reflect.fields(__DOLLAR__obj)) {
				_log(prop + ': ' + Reflect.field(__DOLLAR__obj, prop), '', false, false);
				_applySeverityColor(MessageTypes.TRACE, 0, false, true);
				numVariables++;
			}
		}

		_log('<' + numVariables + ' properties found>\n', '', false, false);
		_applySeverityColor(MessageTypes.TRACE, 0, false, true);
	}

	public function cr(__DOLLAR__numLines:Int = 1):Void {
		var cr:String = '';
		for (i in 0...__DOLLAR__numLines) {
			cr += '\n';
		}
		_write(cr);
	}

	public function header(__DOLLAR__text:String, __DOLLAR__severity:Null<Int> = null):Void {
		if (__DOLLAR__severity == null) {
			__DOLLAR__severity = MessageTypes.OUTPUT;
		}
		_write('\n\n\t');
		_write(__DOLLAR__text.toUpperCase());
		_applySeverityColor(__DOLLAR__severity);
		_write('\n');
	}

	override public function log(args:Array<Dynamic> = null):Void {
		for (i in 0...args.length) {
			addMessage(args[i]);
		}
	}

	public function addMessage(__DOLLAR__msg:Dynamic, __DOLLAR__severity:Null<Int> = null, __DOLLAR__appendLast:Bool = false):Void {
		if (__DOLLAR__severity == null) {
			__DOLLAR__severity = MessageTypes.OUTPUT;
		}
		if (_fmt.get(__DOLLAR__severity) == null) {
			__DOLLAR__severity = MessageTypes.OUTPUT;
		}

		var str:String;
		var append:Bool = __DOLLAR__appendLast;
		var sender:String = '';
		var customColor:Int = 0;

		if (Std.is(__DOLLAR__msg, DLoggerEvent)) {
			var aie:DLoggerEvent = (AS3.as(__DOLLAR__msg, DLoggerEvent));
			__DOLLAR__msg = aie.message;

			switch (aie.type) {
				case DLoggerEvent.LOG:
					__DOLLAR__severity = aie.severity;
					append = aie.appendLast;
					sender = ((Std.is(aie.origin, String))) ? Std.string(aie.origin) : _getEventTargetName(aie);

				case DLoggerEvent.DESCRIBE:
					describe(__DOLLAR__msg);
					return;
				case _:
					throw new Error('Invalid DLoggerEvent type: ' + aie.type);
			}
		}

		if (__DOLLAR__msg == null) {
			__DOLLAR__msg = 'null';
			__DOLLAR__severity = MessageTypes.ERROR;
		}

		if (Std.is(__DOLLAR__msg, String)) {
			str = Std.string(__DOLLAR__msg);
		} else if (Std.is(__DOLLAR__msg, Float) || Std.is(__DOLLAR__msg, Int)) {
			var hex:String = Std.string(__DOLLAR__msg.toString(16).toUpperCase());
			str = Std.string(__DOLLAR__msg);

			if (hex.length == 6) {
				str += ', HEX: ' + hex;
				__DOLLAR__severity = CODE_HEX;
				customColor = AS3.int(__DOLLAR__msg);
			}
		} else if (Std.is(__DOLLAR__msg, Array)) {
			str = ((detailedLogging)) ? (AS3.asArray(__DOLLAR__msg)).join(',') + '(' + (AS3.asArray(__DOLLAR__msg)).length + ' elements)' : Std.string((AS3.asArray(__DOLLAR__msg)).join(','));
		} else if (Std.is(__DOLLAR__msg, FastXML) || Std.is(__DOLLAR__msg, XMLNode) || Std.is(__DOLLAR__msg, FastXMLList)) {
			str = Std.string(__DOLLAR__msg.toXMLString());
		} else if (Std.is(__DOLLAR__msg, Error)) {
			str = ((detailedLogging)) ? Std.string((AS3.as(__DOLLAR__msg, Error)).getStackTrace()) : Std.string((AS3.as(__DOLLAR__msg, Error)).message);
			__DOLLAR__severity = MessageTypes.ERROR;
		} else if (Std.is(__DOLLAR__msg, ErrorEvent)) {
			sender = _getEventTargetName(AS3.as(__DOLLAR__msg, ErrorEvent));
			str = _getClassName(__DOLLAR__msg) + ': ' + (AS3.as(__DOLLAR__msg, ErrorEvent)).text;
			__DOLLAR__severity = MessageTypes.ERROR;
		} else if (Std.is(__DOLLAR__msg, Event)) {
			var e:Event = AS3.as(__DOLLAR__msg, Event);
			sender = _getEventTargetName(e);
			str = 'EVENT: ' + Std.string(e);
			__DOLLAR__severity = MessageTypes.EVENT;
		} else {
			str = as3hx.Compat.getQualifiedClassName(__DOLLAR__msg);
			if (Reflect.field(__DOLLAR__msg, 'name') != null) {
				str += '.' + Reflect.field(__DOLLAR__msg, 'name');
			}

			if (detailedLogging) {
				str += '\n' + DescribeType.describeType(__DOLLAR__msg).toXMLString();
			}
		}

		if (!append) {
			_log(str, sender);
		} else {
			_appendLast(str);
		}

		_applySeverityColor(__DOLLAR__severity, customColor, append);
	}

	private function _getFmt(__DOLLAR__color:Int):TextFormat {
		return new TextFormat('_sans', 11, __DOLLAR__color);
	}

	private function _resetLogColoring():Void {
		_txt.setTextFormat(_fmt.get(MessageTypes.OUTPUT));
	}

	private function _appendLast(__DOLLAR__str:String):Void {
		_write(' â€º ' + __DOLLAR__str);
	}

	private function _appendRepeat(__DOLLAR__repeatCount:Int):Void {
		if (__DOLLAR__repeatCount > 2) {
			_txt.replaceText(_txt.text.lastIndexOf('(') + 1, _txt.text.lastIndexOf(')'), Std.string(Std.string(__DOLLAR__repeatCount)));
		} else {
			_write(' (' + __DOLLAR__repeatCount + ')');
		}
	}

	private function _write(__DOLLAR__text:String):Void {
		_txt.appendText(__DOLLAR__text);
		if (scrollOnNewLine) {
			_txt.scrollV = _txt.maxScrollV;
		}
		if (alwaysOnTop) {
			_moveToTop();
		}
	}

	private function _applySeverityColor(__DOLLAR__severity:Int, __DOLLAR__customColor:Int = 0, __DOLLAR__append:Bool = false, __DOLLAR__describe:Bool = false):Void {
		var fmt:TextFormat;

		if (_logColoring) {
			if (!__DOLLAR__describe) {
				fmt = ((__DOLLAR__severity != CODE_HEX)) ? _fmt.get(__DOLLAR__severity) : _getFmt(__DOLLAR__customColor);
			} else {
				fmt = _describeFmt;
			}

			var firstChar:Int = ((!__DOLLAR__append)) ? _txt.getFirstCharInParagraph(_txt.text.length - 1) : _txt.text.lastIndexOf('â€º');
			_txt.setTextFormat(fmt, firstChar, _txt.text.length);
		}
	}

	/**
	 * Sets the logger dimensions
	 * @param	rectangle
	 */
	public function setDims(rectangle:Rectangle):Void {
		_width = AS3.int(rectangle.width);
		_height = AS3.int(rectangle.height);
		_createBg();

		_txt.width = _bg.width - 10;
		_txt.height = _bg.height - 10;
		_txtBounds.width = _bg.width - 40;
		_txtBounds.height = _bg.height - 20;
		_txt.scrollRect = _txtBounds;
	}

	/**
	 * Gets the currently set logger dimensions
	 * @return
	 */
	public function getDims():Rectangle {
		return _txtBounds.clone();
	}

	private function _createBg():Void {
		if (stage == null) {
			return;
		}
		_bg.graphics.clear();

		var fillColor:Int = (_inverseColor) ? 0xFFFFFF : 0x000000;
		_bg.graphics.beginFill(fillColor, 0.8);

		var w:Int = ((_width == 0)) ? stage.stageWidth - 10 : _width;
		var h:Int = ((_height == 0)) ? stage.stageHeight - 10 : _height;

		_bg.graphics.drawRect(0, 0, w, h);
		_bg.graphics.endFill();
	}

	private function _createContextMenuItems():Void {
		if (_enableContextMenu && parent != null) {
			var openItem:ContextMenuItem = new ContextMenuItem(OPEN_LOGGER_LABEL);
			openItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _validateOpen);

			parent.contextMenu = new ContextMenu();
			//parent.contextMenu.customItems = [openItem];
		}
	}

	private function _createPasswordField():Void {
		if (parent == null) {
			return;
		}

		_passwordField = new TextField();
		_passwordField.width = 120;
		_passwordField.height = 20;
		_passwordField.background = true;
		_passwordField.border = true;
		_passwordField.selectable = true;
		_passwordField.type = TextFieldType.INPUT;
		_passwordField.defaultTextFormat = new TextFormat('_sans', 11, 0x000000, false, null, null,
				null, null, TextFormatAlign.CENTER);
		_passwordField.borderColor = 0xFFFFFF;
		_passwordField.backgroundColor = 0x000000;
		_passwordField.x = stage.stageWidth * 0.5 - _passwordField.width * 0.5;
		_passwordField.y = stage.stageHeight * 0.5 - _passwordField.height * 0.5;
		_passwordField.text = 'Enter password';

		_passwordField.setSelection(0, _passwordField.text.length);
		_passwordField.addEventListener(Event.CHANGE, _onPasswordKeyDown);

		addChild(_passwordField);
		stage.focus = _passwordField;
		_moveToTop();
	}

	private function _createTraceWindow():Void {
		_createBg();

		_txt = new TextField();
		_txt.width = _bg.width - 10;
		_txt.height = _bg.height - 10;
		_txt.multiline = true;
		_txt.wordWrap = true;
		_txt.x = 5;
		_txt.y = 5;

		_txtBounds = new Rectangle();
		_txtBounds.x = 0;
		_txtBounds.y = 5;

		_txtBounds.width = _bg.width - 40;
		_txtBounds.height = _bg.height - 20;

		_txt.scrollRect = _txtBounds;
		_txt.defaultTextFormat = _fmt.get(MessageTypes.OUTPUT);
		_txt.text = '';

		if (x == 0) {
			x = 5;
		}

		if (y == 0) {
			y = 5;
		}

		_bg.visible = false;
		_txt.visible = false;

		addChild(_bg);
		addChild(_txt);

		log('Welcome to DLogger v' + VERSION + ' |  Booted at ' + Std.string(Date.now()) + '\n');
		log('Player version is ' + Capabilities.version + '\n');
	}

	private function _getClassName(o:Dynamic):String {
		var fullName:String = as3hx.Compat.getQualifiedClassName(o);
		var ret:String;

		try {
			ret = fullName.substr(fullName.lastIndexOf(':') + 1);
		} catch (e:Error) {
			ret = Std.string(Std.string(o));
		}

		return ret;
	}

	private function _getEventTargetName(e:Dynamic):String {
		var tgt:String = '';

		if (Std.is(e, Event) && Reflect.field(e, 'target') != null || Reflect.field(e, 'currentTarget') != null) {
			var tg:Dynamic;

			if (Std.is(e, DLoggerEvent) && (AS3.as(e, DLoggerEvent)).origin != null) {
				tg = (AS3.as(e, DLoggerEvent)).origin;
			} else if (Std.is(e, Event)) {
				tg = ((Reflect.field(e, 'currentTarget') == null)) ? Reflect.field(e, 'target') : Reflect.field(e, 'currentTarget');
			} else {
				tg = e;
			}

			var tgs:String = Std.string(Std.string(tg));
			tgt = tgs.substring(tgs.lastIndexOf(' ') + 1, tgs.length - 1);

			try {
				if (Std.string(Reflect.field(tg, 'name')).substr(0, 8) != 'instance') {
					tgt += ' (' + Reflect.field(Reflect.field(e, 'target'), 'name') + ')';
				}
			} catch (e:ReferenceError) {
				/* Why bother...*/
			}
		}

		return tgt;
	}

	private function _log(__DOLLAR__msg:String, __DOLLAR__sender:String = null, __DOLLAR__useTimeStamp:Bool = true, __DOLLAR__useSenderLabel:Bool = true):Void {
		if (__DOLLAR__msg != _lastMessage) {
			if (__DOLLAR__msg != '\n\n' && __DOLLAR__msg != '\n') {
				var now:String = Date.now().toTimeString().substr(0, 8);
				var lastChar:Int = __DOLLAR__msg.length;
				var returns:Array<Dynamic> = new Array<Dynamic>();

				while (__DOLLAR__msg.charAt(lastChar - 1) == '\n') {
					lastChar--;
					returns.push('\n');
				}

				if (!disableSenderLabels && __DOLLAR__useSenderLabel) {
					if (__DOLLAR__sender != '') {
						__DOLLAR__sender = ' ~ ' + __DOLLAR__sender;
					} else if (parent != null) {
						var tgs:String = Std.string(parent);
						__DOLLAR__sender = ' ~ ' + tgs.substring(tgs.lastIndexOf(' ') + 1, tgs.length - 1);
					} else {
						__DOLLAR__sender = ' ~ [unknown origin]';
					}
				}

				if (__DOLLAR__useTimeStamp) {
					_write('\n' + now + '   ' + __DOLLAR__msg.substr(0, lastChar) + __DOLLAR__sender + returns.join(''));
				} else {
					_write('\n\t' + __DOLLAR__msg.substr(0, lastChar) + __DOLLAR__sender + returns.join(''));
				}

				_lastMessage = __DOLLAR__msg;
				_lastMessageRepeat = 1;
			} else {
				_write(__DOLLAR__msg);
			}
		} else {
			_lastMessageRepeat++;
			_appendRepeat(_lastMessageRepeat);
		}
	}

	private function _moveToTop():Void {
		if (parent != null) {
			parent.setChildIndex(this, parent.numChildren - 1);
		}
	}

	private function _onAddedToStage(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);

		_createContextMenuItems();

		stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
	}

	// Making the trace window accessible by pressing SHIFT + ENTER
	private function _onKeyDown(e:KeyboardEvent):Void {
		if (e.shiftKey && e.keyCode == Keyboard.ENTER) {
			_validateOpen();
		} else if (e.charCode == Keyboard.ENTER && _passwordField != null) {
			_validatePassword();
		} else if (e.charCode == Keyboard.ESCAPE && _passwordField != null) {
			_removePasswordField();
		}
	}

	private function _onPasswordKeyDown(e:Event):Void {
		_passwordEntered = _passwordField.text;

		if (_passwordEntered == _password) {
			_passwordField.textColor = 0x00FF00;
		} else {
			_passwordField.textColor = 0xFF0000;
		}
	}

	private function _redrawBg():Void {
		_createBg();
	}

	private function _removeContextMenuItems():Void {
		if (parent != null && parent.contextMenu != null) {
			//	parent.contextMenu.customItems[1].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _validateOpen);
			//	parent.contextMenu.customItems = null;
			parent.contextMenu = null;
		}
	}

	private function _removePasswordField():Void {
		removeChild(_passwordField);
		_passwordField.removeEventListener(Event.CHANGE, _onPasswordKeyDown);
		_passwordField = null;

		if (stage != null) {
			stage.focus = null;
		}
	}

	private function _scroll(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.DOWN && _txt.scrollV < _txt.maxScrollV) {
			_txt.scrollV += _scrollSpeed;
		} else if (e.keyCode == Keyboard.UP && _txt.scrollV > 0) {
			_txt.scrollV += AS3.int(_scrollSpeed * -1);
		} else if (e.keyCode == Keyboard.HOME) {
			_txt.scrollV = 0;
		} else if (e.keyCode == Keyboard.END) {
			_txt.scrollV = _txt.maxScrollV;
		}
	}

	private function _handleVisibility():Void {
		if (_isVisible) {
			setDims(new Rectangle(x, y, _width, _height));
			_moveToTop();// Asking parent DisplayObjectContainer to move logger to the top of the Display List
			enableScrolling();
			fadeIn();
		} else {
			disableScrolling();
			fadeOut();
		}

		if (_enableContextMenu) {
			/*if (parent != null && parent.contextMenu.customItems.length > 0) {
				//trace(parent.contextMenu.customItems);
				for (var i:int = 0; i < parent.contextMenu.customItems.length; i++)
				{
					if (parent.contextMenu.customItems[i].caption == CLOSE_LOGGER_LABEL || parent.contextMenu.customItems[i].caption == OPEN_LOGGER_LABEL) {
						parent.contextMenu.customItems[i].caption = _isVisible ? CLOSE_LOGGER_LABEL : OPEN_LOGGER_LABEL;
						break;
					}
				}
			}*/
		}
	}

	private function fadeOut():Void {
		alpha = 1;
		_fadeTarget = 0;
		addEventListener(Event.ENTER_FRAME, fade, false, 0, true);
	}

	private function fadeIn():Void {
		_txt.visible = _bg.visible = _isVisible;
		alpha = 0;
		_fadeTarget = 1;
		addEventListener(Event.ENTER_FRAME, fade, false, 0, true);
	}

	private function fade(e:Event):Void {
		alpha += (_fadeTarget - alpha) * .4;
		if (Math.abs(_fadeTarget - alpha) < 0.1) {
			removeEventListener(Event.ENTER_FRAME, fade);
			alpha = _fadeTarget;
			if (!_isVisible) {
				_txt.visible = _bg.visible = false;
			}
		}
	}

	private function _setVisible(visibility:Bool):Bool {
		_isVisible = visibility;
		_handleVisibility();
		return visibility;
	}

	private function _toggleVisible():Void {
		_isVisible = !_isVisible;
		//_bg.visible = !_bg.visible;
		//_txt.visible = !_txt.visible;
		_handleVisibility();
	}

	private function _validateOpen(e:ContextMenuEvent = null):Void {
		if (_passwordEntered != _password && !disablePassword) {
			if (_passwordField == null) {
				_createPasswordField();
			} else {
				_removePasswordField();
			}
		} else {
			_toggleVisible();
		}
	}

	private function _validatePassword():Void {
		if (_passwordEntered == _password) {
			disablePassword = true;
			_removePasswordField();
			_toggleVisible();
		}
	}

	public function disableScrolling():Void {
		if (stage != null) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _scroll);
		}
	}

	public function enableScrolling():Void {
		if (stage != null) {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _scroll);
		}
	}

	/* INTERFACE no.doomsday.console.core.interfaces.ILogger */

	override public function show():Void {
		_setVisible(true);
	}

	override public function hide():Void {
		_setVisible(false);
	}

	override public function trace(args:Array<Dynamic> = null):Void {
		log.apply(this, args);
	}

}