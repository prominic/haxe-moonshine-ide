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

class TextChangeInsert extends TextChangeBase {

	private var _textLines:Array<String>;

	public var textLines(get, never):Array<String>;
	private function get_textLines():Array<String> {
		return _textLines;
	}

	public function new(startLine:Int, startChar:Int, textLines:Array<String>) {
		super(TextChangeBase.UNBLOCK);

		_startLine = startLine;
		_startChar = startChar;
		_textLines = textLines;
	}

	override public function getReverse():TextChangeBase {
		var endLine:Int = startLine + textLines.length - 1;
		var endChar:Int = ((textLines.length == 1) ? startChar : 0) + textLines[textLines.length - 1].length;

		return new TextChangeRemove(startLine, startChar, endLine, endChar);
	}

}