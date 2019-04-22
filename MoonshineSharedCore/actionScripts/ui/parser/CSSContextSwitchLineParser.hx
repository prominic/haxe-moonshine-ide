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
package actionScripts.ui.parser;

import actionScripts.ui.parser.context.ContextSwitch;
import actionScripts.ui.parser.context.ContextSwitchManager;
import actionScripts.ui.parser.context.ContextSwitchParser;

class CSSContextSwitchLineParser extends ContextSwitchParser implements ILineParser {

	public static inline var CSS_TEXT:Int = 0x0;
	public static inline var CSS_PROPERTY:Int = 0x1;
	public static inline var CSS_VALUE:Int = 0x2;
	public static inline var CSS_STRING1:Int = 0x3;
	public static inline var CSS_STRING2:Int = 0x4;
	public static inline var CSS_STRING3:Int = 0x5;
	public static inline var CSS_STRING4:Int = 0x6;
	public static inline var CSS_COMMENT1:Int = 0x7;
	public static inline var CSS_COMMENT2:Int = 0x8;
	public static inline var CSS_COMMENT3:Int = 0x9;
	public static inline var CSS_MEDIA:Int = 0xA;
	public static inline var CSS_BRACEOPEN:Int = 0xB;
	public static inline var CSS_BRACECLOSE:Int = 0xC;
	public static inline var CSS_COLON1:Int = 0xD;
	public static inline var CSS_COLON2:Int = 0xE;
	public static inline var CSS_COLON3:Int = 0xF;

	public function new() {
		super();

		defaultContext = CSS_TEXT;

		// Context switches, order matters
		switchManager = new ContextSwitchManager(
				[
						// Comments
						new ContextSwitch([CSS_TEXT], CSS_COMMENT1, new as3hx.Compat.Regex('\\/\\*', '')),
						new ContextSwitch([CSS_COMMENT1], CSS_TEXT, new as3hx.Compat.Regex('\\*\\/', ''), true),
						new ContextSwitch([CSS_PROPERTY], CSS_COMMENT2, new as3hx.Compat.Regex('\\/\\*', '')),
						new ContextSwitch([CSS_COMMENT2], CSS_PROPERTY, new as3hx.Compat.Regex('\\*\\/', ''), true),
						new ContextSwitch([CSS_VALUE], CSS_COMMENT3, new as3hx.Compat.Regex('\\/\\*', '')),
						new ContextSwitch([CSS_COMMENT3], CSS_VALUE, new as3hx.Compat.Regex('\\*\\/', ''), true),
						// Media rules
						new ContextSwitch([CSS_TEXT], CSS_MEDIA, new as3hx.Compat.Regex('@media(?=[;{\\s])', ''), true),
						new ContextSwitch([CSS_MEDIA], CSS_TEXT, new as3hx.Compat.Regex('[{\\r\\n]', '')),
						// Semi-colons
						new ContextSwitch([CSS_TEXT, CSS_MEDIA], CSS_COLON1, new as3hx.Compat.Regex(';', '')),
						new ContextSwitch([CSS_COLON1], CSS_TEXT),
						// Selectors
						new ContextSwitch([CSS_TEXT], CSS_BRACEOPEN, new as3hx.Compat.Regex('\\{', '')),
						new ContextSwitch([CSS_BRACEOPEN], CSS_PROPERTY),
						new ContextSwitch([CSS_PROPERTY, CSS_VALUE], CSS_BRACECLOSE, new as3hx.Compat.Regex('\\}', '')),
						new ContextSwitch([CSS_BRACECLOSE], CSS_TEXT, new as3hx.Compat.Regex('(?=.)', '')),
						// Values
						new ContextSwitch([CSS_PROPERTY], CSS_COLON2, new as3hx.Compat.Regex(':', '')),
						new ContextSwitch([CSS_COLON2], CSS_VALUE),
						new ContextSwitch([CSS_VALUE], CSS_PROPERTY, new as3hx.Compat.Regex('[\\r\\n]', '')),
						new ContextSwitch([CSS_VALUE], CSS_COLON3, new as3hx.Compat.Regex(';', '')),
						new ContextSwitch([CSS_COLON3], CSS_PROPERTY),
						// Strings
						new ContextSwitch([CSS_TEXT], CSS_STRING1, new as3hx.Compat.Regex('"', '')),
						new ContextSwitch([CSS_TEXT], CSS_STRING2, new as3hx.Compat.Regex('\'', '')),
						new ContextSwitch([CSS_STRING1], CSS_STRING1, new as3hx.Compat.Regex('\\\\["\\r\\n]', '')),
						new ContextSwitch([CSS_STRING2], CSS_STRING2, new as3hx.Compat.Regex('\\\\[\'\\r\\n]', '')),
						new ContextSwitch([CSS_STRING1], CSS_TEXT, new as3hx.Compat.Regex('"|(?=[\\r\\n])', ''), true),
						new ContextSwitch([CSS_STRING2], CSS_TEXT, new as3hx.Compat.Regex('\'|(?=[\\r\\n])', ''), true),
						new ContextSwitch([CSS_VALUE], CSS_STRING3, new as3hx.Compat.Regex('"', '')),
						new ContextSwitch([CSS_VALUE], CSS_STRING4, new as3hx.Compat.Regex('\'', '')),
						new ContextSwitch([CSS_STRING3], CSS_STRING3, new as3hx.Compat.Regex('\\\\["\\r\\n]', '')),
						new ContextSwitch([CSS_STRING4], CSS_STRING4, new as3hx.Compat.Regex('\\\\[\'\\r\\n]', '')),
						new ContextSwitch([CSS_STRING3], CSS_VALUE, new as3hx.Compat.Regex('"|(?=[\\r\\n])', ''), true),
						new ContextSwitch([CSS_STRING4], CSS_VALUE, new as3hx.Compat.Regex('\'|(?=[\\r\\n])', ''), true)
			]);
	}

}