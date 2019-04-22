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
package actionScripts.ui.editor.text.change;

class TextChangeRemove extends TextChangeBase {

	private var _endLine:Int = 0;
	private var _endChar:Int = 0;
	private var _textLines:Array<String>;

	public var endLine(get, never):Int;
	private function get_endLine():Int {
		return _endLine;
	}

	public var endChar(get, never):Int;
	private function get_endChar():Int {
		return _endChar;
	}

	public var textLines(get, never):Array<String>;
	private function get_textLines():Array<String> {
		return _textLines;
	}

	public function new(startLine:Int, startChar:Int, endLine:Int, endChar:Int) {
		super(TextChangeBase.UNBLOCK);

		_startLine = startLine;
		_startChar = startChar;
		_endLine = endLine;
		_endChar = endChar;
	}

	override public function getReverse():TextChangeBase {
		if (textLines != null) {
			return new TextChangeInsert(startLine, startChar, textLines);
		}

		return null;
	}

	public function setTextLines(textLines:Array<String>):Void {
		_textLines = textLines;
	}

}