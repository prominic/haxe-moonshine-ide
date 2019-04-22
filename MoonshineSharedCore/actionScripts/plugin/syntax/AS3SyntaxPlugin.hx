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
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.Settings;

class AS3SyntaxPlugin extends PluginBase implements ISettingsProvider implements IEditorPlugin {

	private var formats:Dynamic = {};

	override private function get_name():String {
		return 'AS3 Syntax Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides highlighting for AS3.';
	}

	public function getSettingsList():Array<ISetting> {
		return new Array<ISetting>();
	}

	override public function activate():Void {
		super.activate();
		init();
	}

	private function init():Void {
		var fontDescription:FontDescription = Settings.font.defaultFontDescription;
		var fontSize:Float = Settings.font.defaultFontSize;

		Reflect.setField(formats, Std.string(0),  /* default, parser fault */ new ElementFormat(fontDescription, fontSize, 0xFF0000));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_CODE), new ElementFormat(fontDescription, fontSize, 0x101010));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_STRING1),
		Reflect.setField(formats, Std.string(AS3LineParser.AS_STRING2), new ElementFormat(fontDescription, fontSize, 0xca2323)));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_COMMENT),
		Reflect.setField(formats, Std.string(AS3LineParser.AS_MULTILINE_COMMENT), new ElementFormat(fontDescription, fontSize, 0x39c02f)));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_REGULAR_EXPRESSION), new ElementFormat(fontDescription, fontSize, 0x9b0000));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x0082cd));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_VAR_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x6d5a9c));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_FUNCTION_KEYWORD), new ElementFormat(fontDescription, fontSize, 0x3382dd));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_PACKAGE_CLASS_KEYWORDS), new ElementFormat(fontDescription, fontSize, 0xa848da));
		Reflect.setField(formats, 'lineNumber', new ElementFormat(fontDescription, fontSize, 0x888888));
		Reflect.setField(formats, 'breakPointLineNumber', new ElementFormat(fontDescription, fontSize, 0xffffff));
		Reflect.setField(formats, 'breakPointBackground', 0xdea5dd);
		Reflect.setField(formats, 'tracingLineColor', 0xc6dbae);
		Reflect.setField(formats, Std.string(AS3LineParser.AS_METADATA), new ElementFormat(fontDescription, fontSize, 0x808000));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_FIELD), new ElementFormat(fontDescription, fontSize, 0x660E7A));
		Reflect.setField(formats, Std.string(AS3LineParser.AS_FUNCTIONS), new ElementFormat(fontDescription, fontSize, 0x7A7A43));

		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
	}

	private function handleEditorOpen(event:EditorPluginEvent):Void {
		if (event.fileExtension == 'as') {
			event.editor.setParserAndStyles(new AS3LineParser(), formats);
		}
	}

	public function new() {
		super();
	}

}