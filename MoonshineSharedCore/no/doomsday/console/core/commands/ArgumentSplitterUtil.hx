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
package no.doomsday.console.core.commands;

import flash.errors.ArgumentError;

/**
 * ...
 * @author Andreas Rønning
 */
class ArgumentSplitterUtil {

	private static var stringOpener1(default, never):Int = '\''.charCodeAt(0);
	private static var stringOpener2(default, never):Int = '"'.charCodeAt(0);
	private static var objectOpener(default, never):Int = '{'.charCodeAt(0);
	private static var objectCloser(default, never):Int = '}'.charCodeAt(0);
	private static var arrayOpener(default, never):Int = '['.charCodeAt(0);
	private static var arrayCloser(default, never):Int = ']'.charCodeAt(0);
	private static var subCommandOpener(default, never):Int = '('.charCodeAt(0);
	private static var subCommandCloser(default, never):Int = ')'.charCodeAt(0);
	private static var space(default, never):Int = ' '.charCodeAt(0);

	public static function slice(a:String):Array<Dynamic> {
		var position:Int = 0;

		while (position < a.length) {
			position++;
			var char:Int = a.charCodeAt(position);
			switch (char) {
				case subCommandOpener:
					position = findSubCommand(a, position);
				case space:
					var sa:String = a.substring(0, position);
					var sb:String = a.substring(position + 1);
					var ar:Array<String> = [sa, sb];
					a = ar.join('|');
				case stringOpener1, stringOpener2:
					position = findString(a, position);
				case objectOpener:
					position = findObject(a, position);
				case arrayOpener:
					position = findArray(a, position);
			}
		}
		var out:Array<String> = a.split('|');
		var str:String = '';
		for (i in 0...out.length) {
			str = out[i];
			if (str.charCodeAt(0) == stringOpener1 || str.charCodeAt(0) == stringOpener2) {
				out[i] = str.substring(1, str.length - 1);
			}
		}
		return cast out;
	}

	private static function findSubCommand(input:String, start:Int):Int {
		var score:Int = 0;
		var l:Int = input.length;
		var char:Int;
		var end:Int;
		for (i in start...l) {
			char = input.charCodeAt(i);
			if (char == subCommandOpener) {
				score++;
			} else if (char == subCommandCloser) {
				score--;
				if (score <= 0) {
					end = i;
					break;
				}
			}
		}
		if (score > 0) {
			throw (new ArgumentError('Subcommand argument not properly terminated'));
		}
		return end;
	}

	private static function findObject(input:String, start:Int):Int {
		var score:Int = 0;
		var l:Int = input.length;
		var char:Int;
		var end:Int;
		for (i in start...l) {
			char = input.charCodeAt(i);
			if (char == objectOpener) {
				score++;
			} else if (char == objectCloser) {
				score--;
				if (score <= 0) {
					end = i;
					break;
				}
			}
		}
		if (score > 0) {
			throw (new ArgumentError('Object argument not properly terminated'));
		}
		return end;
	}

	private static function findArray(input:String, start:Int):Int {
		var score:Int = 0;
		var l:Int = input.length;
		var char:Int;
		var end:Int;
		for (i in start...l) {
			char = input.charCodeAt(i);
			if (char == arrayOpener) {
				score++;
			} else if (char == arrayCloser) {
				score--;
				if (score <= 0) {
					end = i;
					break;
				}
			}
		}
		if (score > 0) {
			throw (new ArgumentError('Array argument not properly terminated'));
		}
		return end;
	}

	private static function findString(input:String, start:Int):Int {
		var out:Int = input.indexOf(Std.string(input.charAt(start)), start + 1);
		if (out < start) {
			throw (new ArgumentError('String argument not properly terminated'));
		}
		return out;
	}

	private static function findCommand(input:String):Int {
		return AS3.int(input.split(' ').shift().length);
	}

}