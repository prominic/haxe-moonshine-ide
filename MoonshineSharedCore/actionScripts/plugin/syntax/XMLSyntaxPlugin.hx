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
import actionScripts.ui.parser.XMLContextSwitchLineParser;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.Settings;

class XMLSyntaxPlugin extends PluginBase implements ISettingsProvider implements IEditorPlugin {

	private var formats:Dynamic = {};

	override private function get_name():String {
		return 'XML Syntax Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides highlighting for XML.';
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

		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_TEXT), new ElementFormat(fontDescription, fontSize, 0x3322dd));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_TAG), new ElementFormat(fontDescription, fontSize, 0x202020));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_COMMENT), new ElementFormat(fontDescription, fontSize, 0x39c02f));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_CDATA), new ElementFormat(fontDescription, fontSize, 0x9b0000));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_NAME), new ElementFormat(fontDescription, fontSize, 0x404040));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_VAL1),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_VAL2), new ElementFormat(fontDescription, fontSize, 0xca2323)));
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_ATTR_OPER),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_BRACKETOPEN),
		Reflect.setField(formats, Std.string(XMLContextSwitchLineParser.XML_BRACKETCLOSE), new ElementFormat(fontDescription, fontSize, 0x4e022f))));
		Reflect.setField(formats, 'lineNumber', new ElementFormat(fontDescription, fontSize, 0x888888));
		Reflect.setField(formats, 'breakPointLineNumber', new ElementFormat(fontDescription, fontSize, 0xffffff));
		Reflect.setField(formats, 'breakPointBackground', 0xdea5dd);
		Reflect.setField(formats, 'tracingLineColor', 0xc6dbae);

		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
	}

	private function handleEditorOpen(event:EditorPluginEvent):Void {
		if (isExpectedType(event.fileExtension)) {
			event.editor.setParserAndStyles(new XMLContextSwitchLineParser(), formats);
		}
	}

	private function isExpectedType(type:String):Bool {
		return (type == 'xml' || type == 'as3proj' ||
		type == 'veditorproj' || type == 'javaproj');
	}

}