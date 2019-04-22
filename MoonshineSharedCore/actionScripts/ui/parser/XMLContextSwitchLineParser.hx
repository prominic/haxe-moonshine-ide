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

class XMLContextSwitchLineParser extends ContextSwitchParser implements ILineParser {

	public static inline var XML_TEXT:Int = 0x0;
	public static inline var XML_TAG:Int = 0x1;
	public static inline var XML_COMMENT:Int = 0x2;
	public static inline var XML_CDATA:Int = 0x3;
	public static inline var XML_ATTR_NAME:Int = 0x4;
	public static inline var XML_ATTR_VAL1:Int = 0x5;
	public static inline var XML_ATTR_VAL2:Int = 0x6;
	public static inline var XML_ATTR_OPER:Int = 0x7;
	public static inline var XML_BRACKETOPEN:Int = 0x8;
	public static inline var XML_BRACKETCLOSE:Int = 0x9;

	public function new() {
		super();

		defaultContext = XML_TEXT;

		// Context switches, order matters
		switchManager = new ContextSwitchManager(
				[
						// Comments
						new ContextSwitch([XML_TEXT], XML_COMMENT, new as3hx.Compat.Regex('<!--', '')),
						new ContextSwitch([XML_COMMENT], XML_TEXT, new as3hx.Compat.Regex('-->', ''), true),
						// CDATA Sections
						new ContextSwitch([XML_TEXT], XML_CDATA, new as3hx.Compat.Regex('<!\\[CDATA\\[', '')),
						new ContextSwitch([XML_CDATA], XML_TEXT, new as3hx.Compat.Regex('\\]\\]>', ''), true),
						// Tags
						new ContextSwitch([XML_TEXT], XML_BRACKETOPEN, new as3hx.Compat.Regex('<', '')),
						new ContextSwitch([XML_BRACKETOPEN], XML_TAG, new as3hx.Compat.Regex('[^\\x00-\\x39\\x3B-\\x40\\x5B-\\x5E\\x60\\x7B-\\xBF\\xD7\\xF7][^\\x00-\\x2C\\x2F\\x3B-\\x40\\x5B-\\x5E\\x60\\x7B-\\xB6\\xB8-\\xBF\\xD7\\xF7]*', '')),
						new ContextSwitch([XML_TAG], XML_BRACKETCLOSE, new as3hx.Compat.Regex('>', '')),
						new ContextSwitch([XML_BRACKETCLOSE], XML_TEXT),
						// Attributes
						new ContextSwitch([XML_TAG], XML_ATTR_NAME, new as3hx.Compat.Regex('[^\\x00-\\x39\\x3B-\\x40\\x5B-\\x5E\\x60\\x7B-\\xBF\\xD7\\xF7]+', '')),
						new ContextSwitch([XML_TAG, XML_ATTR_NAME], XML_ATTR_OPER, new as3hx.Compat.Regex('[\\x00-\\x21\\x23-\\x26\\x28-\\x2C\\x2F\\x3B-\\x3D\\x3F\\x40\\x5B-\\x5E\\x60\\x7B-\\xB6\\xB8-\\xBF\\xD7\\xF7]+', '')),
						new ContextSwitch([XML_ATTR_NAME, XML_ATTR_OPER], XML_TAG),
						new ContextSwitch([XML_TAG], XML_ATTR_VAL1, new as3hx.Compat.Regex('"', '')),
						new ContextSwitch([XML_TAG], XML_ATTR_VAL2, new as3hx.Compat.Regex('\'', '')),
						new ContextSwitch([XML_ATTR_VAL1], XML_TAG, new as3hx.Compat.Regex('"', ''), true),
						new ContextSwitch([XML_ATTR_VAL2], XML_TAG, new as3hx.Compat.Regex('\'', ''), true)
			]);
	}

}