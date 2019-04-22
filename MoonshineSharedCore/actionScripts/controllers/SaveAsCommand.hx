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
package actionScripts.controllers;

import flash.events.Event;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;

class SaveAsCommand implements ICommand {

	public function execute(event:Event):Void {
		var editor:BasicTextEditor = AS3.as(IDEModel.getInstance().activeEditor, BasicTextEditor);
		if (editor != null) {
			editor.saveAs();
		}
	}

	public function new() {}

}