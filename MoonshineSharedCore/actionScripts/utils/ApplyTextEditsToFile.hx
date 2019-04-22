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
package actionScripts.utils;

import actionScripts.events.EditorPluginEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.factory.FileLocation;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.valueObjects.TextEdit;

import flash.events.Event;

import mx.core.FlexGlobals;

/**
 * Class for applyTextEditsToFile
 */
@:final class ApplyTextEditsToFile {

	public static function applyTextEditsToFile(file:FileLocation, textEdits:Array<TextEdit>):Void {
		var textEditor:TextEditor = FindOpenTextEditor.findOpenTextEditor(file);
		if (textEditor != null) {
			ApplyTextEditsToTextEditor.applyTextEditsToTextEditor(textEditor, textEdits);
			return;
		}
		var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		var editorOpenHandler:EditorPluginEvent->Void = function(event:EditorPluginEvent):Void {
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, editorOpenHandler);

			var url:String = Std.string(event.file.fileBridge.url);
			if (url != file.fileBridge.url) {
				return;
			}
			textEditor = event.editor;
			var file2:Dynamic = event.file.fileBridge.getFile;
			//this seems to be the only way to be sure that the editor is
			//displaying the file -JT
			file2.addEventListener(Event.COMPLETE, function(event:Event):Void {
						file2.removeEventListener(event.target, arguments.callee);
						//this is pretty hacky! but otherwise, we get an error -JT
						FlexGlobals.topLevelApplication.callLater(applyTextEditsToTextEditor, [textEditor, textEdits]);
					});
		}
		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, editorOpenHandler);
		var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, cast [file]);
		dispatcher.dispatchEvent(openEvent);
	}

}