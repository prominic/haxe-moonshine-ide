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
package actionScripts.plugin.syntax;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import actionScripts.events.EditorPluginEvent;
import actionScripts.plugin.IEditorPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.ui.parser.AS3LineParser;
import actionScripts.ui.parser.CSSContextSwitchLineParser;
import actionScripts.ui.parser.XMLContextSwitchLineParser;
import actionScripts.ui.parser.context.ContextSwitch;
import actionScripts.ui.parser.context.InlineParser;
import actionScripts.ui.parser.context.InlineParserManager;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.Settings;

class MXMLSyntaxPlugin extends PluginBase implements ISettingsProvider implements IEditorPlugin {

	private static inline var SCRIPT_MASK:Int = 0x1000;
	private static inline var BIND1_MASK:Int = 0x2000;
	private static inline var BIND2_MASK:Int = 0x3000;
	private static inline var BIND3_MASK:Int = 0x4000;

	private static inline var STYLE_MASK:Int = 0x5000;
	private static inline var STYLE_OPEN_TAG:Int = 0x11;
	private static inline var STYLE_CLOSE_TAG:Int = 0x12;

	private var formats:Dynamic = {};

	override private function get_name():String {
		return 'MXML Syntax Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides highlighting for MXML.';
	}

	public function getSettingsList():Array<ISetting> {
		return new Array<ISetting>();
	}

	override public function activate():Void {
		super.activate();
		init();
	}

	override public function deactivate():Void {
		super.deactivate();
	}

	public function new() {
		super();
	}

	private function init():Void {
		var fontDescription:FontDescription = Settings.font.defaultFontDescription;
		var fontSize:Float = Settings.font.defaultFontSize;

		Reflect.setField(formats, 'lineNumber', new ElementFormat(fontDescription, fontSize, 0x888888));
		Reflect.setField(formats, 'breakPointLineNumber', new ElementFormat(fontDescription, fontSize, 0xffffff));
		Reflect.setField(formats, 'breakPointBackground', 0xdea5dd);
		Reflect.setField(formats, 'tracingLineColor', 0xc6dbae);

		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_TEXT), new ElementFormat(fontDescription, fontSize, 0x101010));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_TAG),
		Reflect.setField(formats, Std.string(STYLE_OPEN_TAG),
		Reflect.setField(formats, Std.string(STYLE_CLOSE_TAG), new ElementFormat(fontDescription, fontSize, 0x003DF5))));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_COMMENT), new ElementFormat(fontDescription, fontSize, 0x39c02f));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_CDATA), new ElementFormat(fontDescription, fontSize, 0x606060));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_NAME), new ElementFormat(fontDescription, fontSize, 0x101010));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_VAL1),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_VAL2), new ElementFormat(fontDescription, fontSize, 0xca2323)));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_OPER),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_BRACKETOPEN),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_BRACKETCLOSE), new ElementFormat(fontDescription, fontSize, 0x144d9b))));

		// Populate AS3 parser formats for all inline masks
		for (mask in [SCRIPT_MASK, BIND1_MASK, BIND2_MASK, BIND3_MASK]) {
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_CODE), new ElementFormat(fontDescription, fontSize, 0x101010));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_STRING1),
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_STRING2), new ElementFormat(fontDescription, fontSize, 0xca2323)));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_COMMENT),
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_MULTILINE_COMMENT), new ElementFormat(fontDescription, fontSize, 0x39c02f)));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_REGULAR_EXPRESSION), new ElementFormat(fontDescription, fontSize, 0x9b0000));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x0082cd));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_VAR_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x6d5a9c));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_FUNCTION_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x3382dd));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_PACKAGE_CLASS_KEYWORDS), new ElementFormat(fontDescription, fontSize, 0xa848da));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_METADATA), new ElementFormat(fontDescription, fontSize, 0x808000));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_FIELD), new ElementFormat(fontDescription, fontSize, 0x660E7A));
			Reflect.setField(formats, Std.string(mask | AS3LineParser.AS_FUNCTIONS), new ElementFormat(fontDescription, fontSize, 0x7A7A43));
		}

		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_TEXT), new ElementFormat(fontDescription, fontSize, 0x011282));
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_PROPERTY), new ElementFormat(fontDescription, fontSize, 0x202020));
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_VALUE),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_MEDIA), new ElementFormat(fontDescription, fontSize, 0x97039C)));
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_BRACEOPEN),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_BRACECLOSE),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COLON1),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COLON2),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COLON3), new ElementFormat(fontDescription, fontSize, 0x000000))))));
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_STRING1),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_STRING2),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_STRING3),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_STRING4), new ElementFormat(fontDescription, fontSize, 0xca2323)))));
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COMMENT1),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COMMENT2),
		Reflect.setField(formats, Std.string(STYLE_MASK | CSSContextSwitchLineParser.CSS_COMMENT3), new ElementFormat(fontDescription, fontSize, 0x39c02f))));

		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
	}

	private function handleEditorOpen(event:EditorPluginEvent):Void {
		if (event.fileExtension == 'mxml') {
			var lineParser:XMLContextSwitchLineParser = new XMLContextSwitchLineParser();

			// Add inline parsers
			lineParser.parserManager = new InlineParserManager(
					[
							new InlineParser(SCRIPT_MASK, new AS3LineParser()),
							new InlineParser(BIND1_MASK, new AS3LineParser()),
							new InlineParser(BIND2_MASK, new AS3LineParser()),
							new InlineParser(BIND3_MASK, new AS3LineParser()),
							new InlineParser(STYLE_MASK, new CSSContextSwitchLineParser())
				]);
			// Add context switches for inline AS3 parsing
			lineParser.switchManager.addSwitch(new ContextSwitch([XMLContextSwitchLineParser.XML_CDATA], SCRIPT_MASK));
			lineParser.switchManager.addSwitch(new ContextSwitch([SCRIPT_MASK], XMLContextSwitchLineParser.XML_CDATA, new as3hx.Compat.Regex('(?=\\]\\]>)', '')));
			// Inline parsing for data binding
			lineParser.switchManager.addSwitch(new ContextSwitch([XMLContextSwitchLineParser.XML_ATTR_VAL1], BIND1_MASK, new as3hx.Compat.Regex('\\{', ''), true));
			lineParser.switchManager.addSwitch(new ContextSwitch([BIND1_MASK], XMLContextSwitchLineParser.XML_ATTR_VAL1, new as3hx.Compat.Regex('(?=\\})', '')));
			lineParser.switchManager.addSwitch(new ContextSwitch([XMLContextSwitchLineParser.XML_ATTR_VAL2], BIND2_MASK, new as3hx.Compat.Regex('\\{', ''), true));
			lineParser.switchManager.addSwitch(new ContextSwitch([BIND2_MASK], XMLContextSwitchLineParser.XML_ATTR_VAL2, new as3hx.Compat.Regex('(?=\\})', '')));
			lineParser.switchManager.addSwitch(new ContextSwitch([XMLContextSwitchLineParser.XML_TEXT], BIND3_MASK, new as3hx.Compat.Regex('\\{', ''), true));
			lineParser.switchManager.addSwitch(new ContextSwitch([BIND3_MASK], XMLContextSwitchLineParser.XML_TEXT, new as3hx.Compat.Regex('(?=\\})', '')));
			// Inline style context switches
			lineParser.switchManager.addSwitch(new ContextSwitch([XMLContextSwitchLineParser.XML_TEXT], STYLE_OPEN_TAG, new as3hx.Compat.Regex('<(?:[^\\x00-\\x39\\x3A-\\x40\\x5B-\\x5E\\x60\\x7B-\\xBF\\xD7\\xF7][^\\x00-\\x2C\\x2F\\x3A-\\x40\\x5B-\\x5E\\x60\\x7B-\\xB6\\xB8-\\xBF\\xD7\\xF7]*:)?style(?:>|\\s>|\\s[^>]*[^>\\/]>)', 'i')), true);
			lineParser.switchManager.addSwitch(new ContextSwitch([STYLE_OPEN_TAG], STYLE_MASK));
			lineParser.switchManager.addSwitch(new ContextSwitch([STYLE_MASK], STYLE_CLOSE_TAG, new as3hx.Compat.Regex('<\\/(?:[^\\x00-\\x39\\x3A-\\x40\\x5B-\\x5E\\x60\\x7B-\\xBF\\xD7\\xF7][^\\x00-\\x2C\\x2F\\x3A-\\x40\\x5B-\\x5E\\x60\\x7B-\\xB6\\xB8-\\xBF\\xD7\\xF7]*:)?style\\s*>', 'i')));
			lineParser.switchManager.addSwitch(new ContextSwitch([STYLE_CLOSE_TAG], XMLContextSwitchLineParser.XML_TEXT));

			event.editor.setParserAndStyles(lineParser, formats);
		}
	}

}