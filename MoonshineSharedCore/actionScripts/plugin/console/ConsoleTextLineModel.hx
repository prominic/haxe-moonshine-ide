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
package actionScripts.plugin.console;

import actionScripts.ui.editor.text.TextLineModel;

class ConsoleTextLineModel extends TextLineModel {

	private var markupText:String;
	private var consoleOutputType:String;

	public function new(text:String, consoleOutputType:String) {
		this.markupText = text;
		this.consoleOutputType = consoleOutputType;

		super(decode(text));
	}

	public function getTextColor():Int {
		var consoleOutType:Int = AS3.int(Reflect.field(ConsoleStyle.name2style, consoleOutputType));
		switch (consoleOutType) {
			case ConsoleStyle.ERROR:
				return 0xff6666;
			case ConsoleStyle.WARNING:
				return 0xFFBF0F;
			case ConsoleStyle.SUCCESS:
				return 0x33cc33;
			case _:
				return 0xFFFFFF;
		}
	}

	private function decode(markup:String):String {
		var t:String = '';
		var m:Array<Int> = [];

		var style2int:Dynamic = ConsoleStyle.name2style;

		FastXML.node.ignoreWhitespace = false;
		var xml:FastXML = new FastXML('<markup>' + markup + '</markup>');

		var kids:FastXMLList = xml.node.children();
		for (node in kids) {
			// Add style position
			m[m.length] = t.length;

			// Add style value
			if (AS3.as(node.descendants('name')(), Bool) && Reflect.hasField(style2int, Std.string(node.descendants('name')()))) {
				m[m.length] = AS3.int(Reflect.field(style2int, Std.string(Std.string(node.descendants('name')()).toLowerCase())));
			} else {
				m[m.length] = 0;// Default style
			}

			// Build string without markup
			t += Std.string(Std.string(node));
		}

		meta = m;
		return t;
	}

}