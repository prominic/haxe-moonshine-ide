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
package actionScripts.ui.editor.text;

class HoverManager {

	private static inline var TOOL_TIP_ID:String = 'HoverManagerToolTip';

	private var editor:TextEditor;
	private var model:TextEditorModel;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;
	}

	public function showHover(contents:Array<String>):Void {
		var contentsCount:Int = contents.length;
		if (contentsCount == 0) {
			this.closeHover();
			return;
		}

		contentsCount = contents.length;
		var hoverText:String = '';
		for (i in 0...contentsCount) {
			if (i > 0) {
				hoverText += '\n';
			}
			var content:String = contents[i];
			hoverText += content;
		}
		if (hoverText.length == 0) {
			//nothing to display
			this.closeHover();
			return;
		}
		editor.setTooltip(TOOL_TIP_ID, hoverText);
	}

	public function closeHover():Void {
		editor.setTooltip(TOOL_TIP_ID, null);
	}

}