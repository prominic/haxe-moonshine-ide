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
package actionScripts.plugins.references;

import actionScripts.events.ReferencesEvent;
import actionScripts.events.LanguageServerEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugins.references.view.ReferencesView;
import actionScripts.valueObjects.Location;
import flash.display.DisplayObject;
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import actionScripts.ui.editor.LanguageServerTextEditor;
class ReferencesPlugin extends PluginBase {

	public static inline var EVENT_OPEN_FIND_REFERENCES_VIEW:String = 'openFindReferencesView';

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'References Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Displays all references for a symbol in the entire workspace.';
	}

	private var referencesView:ReferencesView = new ReferencesView();

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(EVENT_OPEN_FIND_REFERENCES_VIEW, handleOpenFindReferencesView);
		dispatcher.addEventListener(ReferencesEvent.EVENT_SHOW_REFERENCES, handleShowReferences);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(EVENT_OPEN_FIND_REFERENCES_VIEW, handleOpenFindReferencesView);
		dispatcher.removeEventListener(ReferencesEvent.EVENT_SHOW_REFERENCES, handleShowReferences);
	}

	private function handleOpenFindReferencesView(event:Event):Void {
		var editor:LanguageServerTextEditor = try cast(model.activeEditor, LanguageServerTextEditor) catch (e:Dynamic) null;
		if (editor == null) {
			return;
		}
		PopUpManager.addPopUp(referencesView, cast((editor.parentApplication), DisplayObject), true);
		PopUpManager.centerPopUp(referencesView);

		var startLine:Int = editor.editor.model.selectedLineIndex;
		var startChar:Int = editor.editor.startPos;
		var endLine:Int = editor.editor.model.selectedLineIndex;
		var endChar:Int = editor.editor.model.caretIndex;
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_FIND_REFERENCES,
				startChar, startLine, endChar, endLine));
	}

	private function handleShowReferences(event:ReferencesEvent):Void {
		var collection:ArrayCollection = referencesView.references;
		collection.removeAll();
		var references:Array<Location> = event.references;
		var itemCount:Int = references.length;
		for (i in 0...itemCount) {
			var symbol:Location = references[i];
			collection.addItem(symbol);
		}
		collection.filterFunction = null;
		collection.refresh();
	}

}