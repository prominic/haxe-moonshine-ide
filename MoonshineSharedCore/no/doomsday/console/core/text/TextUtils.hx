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
package no.doomsday.console.core.text;

import no.doomsday.console.core.DConsole;
import flash.text.Font;
import flash.text.TextField;

/**
 * ...
 * @author Andreas Rønning
 */
class TextUtils {

	public function new() {}

	public static function listFonts(c:DConsole):Void {
		var fnts:Array<Dynamic> = Font.enumerateFonts();
		if (fnts.length < 1) {
			c.print('Only system fonts available');
		}
		for (i in 0...fnts.length) {
			c.print('	' + Reflect.field(fnts[i], 'fontName'));
		}
	}

	public static function getNextSpaceAfterCaret(tf:TextField):Int {
		var str:String = tf.text;
		var first:Int = str.lastIndexOf(' ', tf.caretIndex) + 1;
		var last:Int = str.indexOf(' ', first);
		if (last < 0) {
			last = tf.text.length;
		}
		return last;
	}

	public static function selectWordAtCaretIndex(tf:TextField):Void {
		var str:String = tf.text;
		var first:Int = str.lastIndexOf(' ', tf.caretIndex) + 1;
		var last:Int = str.indexOf(' ', first);
		if (last == -1) {
			last = str.length;
		}
		tf.setSelection(first, last);
	}

	public static function getWordAtCaretIndex(tf:TextField):String {
		return getWordAtIndex(tf, tf.caretIndex);
	}

	public static function getWordAtIndex(tf:TextField, index:Int):String {
		var str:String = tf.text;
		var first:Int = str.lastIndexOf(' ', index) + 1;
		var last:Int = str.indexOf(' ', first);
		if (last == -1) {
			last = str.length;
		}
		return Std.string(str.substring(first, last));
	}

	public static function getFirstIndexOfWordAtCaretIndex(tf:TextField):Int {
		var str:String = tf.text;
		return AS3.int(str.lastIndexOf(' ', tf.caretIndex) + 1);
	}

	public static function stripWhitespace(str:String):String {
		while (str.charAt(str.length - 1) == ' ') {
			str = str.substr(0, str.length - 1);
		}
		return str;
	}

	public static function parseForSecondElement(str:String):String {
		var split:Array<String> = str.split(' ');
		if (split.length > 1) {
			return split[1];
		}
		return '';
	}

}