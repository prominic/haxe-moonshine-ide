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

import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.TextEditor;

import mx.collections.ArrayCollection;

/**
 * Class for findOpenTextEditor
 */
@:final class FindOpenTextEditor {

	public static function findOpenTextEditor(file:FileLocation):TextEditor {
		var editors:ArrayCollection = IDEModel.getInstance().editors;
		var editorCount:Int = AS3.int(editors.length);
		for (i in 0...editorCount) {
			var contentWindow:IContentWindow = IContentWindow(editors.getItemAt(i));
			if (Std.is(contentWindow, BasicTextEditor)) {
				var editor:BasicTextEditor = BasicTextEditor(contentWindow);
				if (editor.currentFile.fileBridge.nativePath == file.fileBridge.nativePath) {
					return editor.editor;
				}
			}
		}
		return null;
	}

}