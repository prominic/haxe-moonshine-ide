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
package actionScripts.ui.editor.text;

import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.CodeAction;

class TextLineModel {

	private var _text:String;
	private var _meta:Array<Int>;
	private var _breakPoint:Bool = false;
	private var _width:Float = -1;
	private var _traceLine:Bool = false;
	private var _diagnostics:Array<Diagnostic> = [];
	private var _codeActions:Array<CodeAction> = [];
	private var _isQuoteTextOpen:Bool = false;
	private var _lastQuoteText:String;
	private var _debuggerLineSelection:Bool = false;

	public var text(get, set):String;
	private function set_text(value:String):String {
		_text = value;
		return value;
	}

	private function get_text():String {
		return _text;
	}

	public var meta(get, set):Array<Int>;
	private function set_meta(value:Array<Int>):Array<Int> {
		_meta = value;
		return value;
	}

	private function get_meta():Array<Int> {
		return _meta;
	}

	public var breakPoint(get, set):Bool;
	private function set_breakPoint(value:Bool):Bool {
		_breakPoint = value;
		return value;
	}

	private function get_breakPoint():Bool {
		return _breakPoint;
	}

	public var traceLine(get, set):Bool;
	private function set_traceLine(value:Bool):Bool {
		_traceLine = value;
		return value;
	}

	private function get_traceLine():Bool {
		return _traceLine;
	}

	public var debuggerLineSelection(get, set):Bool;
	private function set_debuggerLineSelection(value:Bool):Bool {
		_debuggerLineSelection = value;
		return value;
	}

	private function get_debuggerLineSelection():Bool {
		return _debuggerLineSelection;
	}

	public var diagnostics(get, set):Array<Diagnostic>;
	private function set_diagnostics(value:Array<Diagnostic>):Array<Diagnostic> {
		_diagnostics = cast value;
		return value;
	}

	private function get_diagnostics():Array<Diagnostic> {
		return cast _diagnostics;
	}

	public var codeActions(get, set):Array<CodeAction>;
	private function set_codeActions(value:Array<CodeAction>):Array<CodeAction> {
		_codeActions = cast value;
		return value;
	}

	private function get_codeActions():Array<CodeAction> {
		return cast _codeActions;
	}

	public var width(get, set):Float;
	private function set_width(value:Float):Float {
		_width = value;
		return value;
	}

	private function get_width():Float {
		return _width;
	}

	public var startContext(get, never):Int;
	private function get_startContext():Int {
		return (_meta != null && _meta.length > 1) ? _meta[1] : 0;
	}

	public var endContext(get, never):Int;
	private function get_endContext():Int {
		return (_meta != null && _meta.length > 1) ? _meta[_meta.length - 1] : 0;
	}

	public function new(text:String) {
		this.text = text;
	}

	public function toString():String {
		return text;
	}

	public var isQuoteTextOpen(get, set):Bool;
	private function set_isQuoteTextOpen(value:Bool):Bool {
		_isQuoteTextOpen = value;
		return value;
	}

	private function get_isQuoteTextOpen():Bool {
		return _isQuoteTextOpen;
	}

	public var lastQuoteText(get, set):String;
	private function set_lastQuoteText(value:String):String {
		_lastQuoteText = value;
		return value;
	}

	private function get_lastQuoteText():String {
		return _lastQuoteText;
	}

}