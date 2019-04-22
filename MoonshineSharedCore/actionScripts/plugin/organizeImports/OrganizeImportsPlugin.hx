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
package actionScripts.plugin.organizeImports;

import flash.events.Event;
import actionScripts.events.ExecuteLanguageServerCommandEvent;
import actionScripts.events.LanguageServerMenuEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.ui.editor.ActionScriptTextEditor;
import actionScripts.valueObjects.ConstantsCoreVO;

class OrganizeImportsPlugin extends PluginBase {

	private static inline var COMMAND_ORGANIZE_IMPORTS_IN_URI:String = 'as3mxml.organizeImportsInUri';

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Organize Imports Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Organize imports in a file.';
	}

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS, handleOrganizeImports);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS, handleOrganizeImports);
	}

	private function handleOrganizeImports(event:Event):Void {
		var editor:ActionScriptTextEditor = AS3.as(model.activeEditor, ActionScriptTextEditor);
		if (editor == null) {
			return;
		}
		trace(uri, COMMAND_ORGANIZE_IMPORTS_IN_URI);
		var uri:String = Std.string(editor.currentFile.fileBridge.url);
		dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
				ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
				COMMAND_ORGANIZE_IMPORTS_IN_URI, cast [{
					'external': uri
				}]));
	}

}