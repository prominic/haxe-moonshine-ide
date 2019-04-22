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
package actionScripts.utils;

import flash.geom.Point;
import flash.xml.XMLNode;

class TextUtil {

	private static var NON_WORD_CHARACTERS(default, never):Array<String> = [' ', '\t', '.', ':', ';', ',', '?', '+', '-', '*', '/', '%', '=', '!', '&', '|', '(', ')', '[', ']', '{', '}', '<', '>'];

	public static function startOfWord(line:String, charIndex:Int):Int {
		var startChar:Int = 0;
		var i:Int = charIndex - 1;
		while (i >= 0) {
			var char:String = Std.string(line.charAt(i));
			if (Lambda.indexOf(NON_WORD_CHARACTERS, char) != -1) {
				//include the next character, but not this
				//one, because it's not part of the word
				startChar = AS3.int(i + 1);
				break;
			}
			i--;
		}
		return startChar;
	}

	public static function endOfWord(line:String, charIndex:Int):Int {
		var endChar:Int = line.length;
		for (i in charIndex + 1...endChar) {
			var char:String = Std.string(line.charAt(i));
			if (Lambda.indexOf(NON_WORD_CHARACTERS, char) != -1) {
				endChar = i;
				break;
			}
		}
		return endChar;

	}

	// Find word boundary from the beginning of the line
	public static function wordBoundaryForward(line:String):Int {
		return AS3.int(line.length - new as3hx.Compat.Regex('^(?:\\s+|[^\\s,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+\\s*|[,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+\\s*)', '').replace(line, '').length);
	}

	// Find word boundary from the end of the line
	public static function wordBoundaryBackward(line:String):Int {
		return AS3.int(line.length - new as3hx.Compat.Regex('(?:\\s+|[^\\s,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+\\s*|[,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+\\s*)$', '').replace(line, '').length);
	}

	// Get amount of indentation on line
	public static function indentAmount(line:String):Int {
		var indent:Int = line.length - new as3hx.Compat.Regex('^\\t+', '').replace(line, '').length;
		if (indent > 0) {
			return indent;
		}

		return 0;
	}

	// Count digits in decimal number
	public static function digitCount(num:Int):Int {
		return AS3.int(Math.floor(Math.log(num) / Math.log(10)) + 1);
	}

	// Escape a string so it can be fed into a new RegExp
	public static function escapeRegex(str:String):String {
		return new as3hx.Compat.Regex('[\\$\\(\\)\\*\\+\\.\\[\\]\\?\\\\\\^\\{\\}\\|]', 'g').replace(str, '\\$&');
	}

	// Repeats a string N times
	public static function repeatStr(str:String, count:Int):String {
		return new Array<Dynamic>().join(str);
	}

	// Pad a string to 'len' length with 'char' characters
	public static function padLeft(str:String, len:Int, char:String = '0'):String {
		return repeatStr(char, len - str.length) + str;
	}

	// Return lineIdx/charIdx from charIdx
	public static function charIdx2LineCharIdx(str:String, charIdx:Int, lineDelim:String):Point {
		var line:Int = str.substr(0, charIdx).split(lineDelim).length - 1;
		var chr:Int = (line > 0) ? charIdx - str.lastIndexOf(lineDelim, charIdx - 1) - lineDelim.length : charIdx;
		return new Point(line, chr);
	}

	// Return charIdx from lineIdx/charIdx
	public static function lineCharIdx2charIdx(str:String, lineIdx:Int, charIdx:Int, lineDelim:String):Int {
		return AS3.int(
				str.split(lineDelim).slice(0, lineIdx).join('').length
				+ lineIdx *lineDelim.length
				+charIdx// Current line's length // Preceding delimiters' lengths // Predecing lines' lengths
		);
	}

	public static function htmlUnescape(str:String):String {
		return Std.string(new FastXML(str).nodes.firstChild.descendants('nodeValue'));
	}

	public static function htmlEscape(str:String):String {
		return Std.string(new XMLNode(3, str));
	}

}