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

import flash.text.TextFormat;

/**
 * ...
 * @author Andreas Rønning
 */
@:final class TextFormats {

	public static var debugTformatInput(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatOld(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xBBBBBB, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatNew(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xFFFFFF, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatSystem(default, never):TextFormat = new TextFormat('_typewriter', 11, 0x00DD00, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatTimeStamp(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xAAAAAA, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatError(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xEE0000, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatHelp(default, never):TextFormat = new TextFormat('_typewriter', 10, 0xbbbbbb, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatTrace(default, never):TextFormat = new TextFormat('_typewriter', 11, 0x9CB79B, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatEvent(default, never):TextFormat = new TextFormat('_typewriter', 11, 0x009900, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var debugTformatWarning(default, never):TextFormat = new TextFormat('_typewriter', 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0, 0);

	public static var windowTitleFormat(default, never):TextFormat = new TextFormat('_sans', 10, 0xeeeeee, null, null, null, null, null, null, 0, 0, 0, 0);
	public static var windowDefaultFormat(default, never):TextFormat = new TextFormat('_sans', 10, 0x111111, null, null, null, null, null, null, 0, 0, 0, 0);

	public function new() {}

	public static function setTheme(input:Int, oldMessage:Int, newMessage:Int, system:Int, timestamp:Int, error:Int, help:Int, trace:Int, event:Int, warning:Int):Void {
		debugTformatInput.color = input;
		debugTformatOld.color = oldMessage;
		debugTformatNew.color = newMessage;
		debugTformatSystem.color = system;
		debugTformatTimeStamp.color = timestamp;
		debugTformatError.color = error;
		debugTformatHelp.color = help;
		debugTformatTrace.color = trace;

		debugTformatEvent.color = event;
		debugTformatWarning.color = warning;
	}

	/**
	 * Returns a textformat copy with inverted color
	 * @param	tformat
	 * @return
	 */
	public static function getInverse(tformat:TextFormat):TextFormat {
		var newFormat:TextFormat = new TextFormat(tformat.font, tformat.size, tformat.color, tformat.bold, tformat.italic, tformat.underline, tformat.url, tformat.target, tformat.align, tformat.leftMargin, tformat.rightMargin, tformat.indent, tformat.leading);
		newFormat.color = 0xFFFFFF - AS3.int(tformat.color);
		return newFormat;
	}

}