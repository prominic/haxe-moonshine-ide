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
package actionScripts.locator;

import flash.events.Event;
import actionScripts.controllers.AddTabCommand;
import actionScripts.controllers.CloseTabCommand;
import actionScripts.controllers.DeleteFileCommand;
import actionScripts.controllers.ICommand;
import actionScripts.controllers.OpenFileCommand;
import actionScripts.controllers.QuitCommand;
import actionScripts.controllers.RenameFileFolderCommand;
import actionScripts.controllers.SaveAsCommand;
import actionScripts.controllers.SaveFileCommand;
import actionScripts.events.AddTabEvent;
import actionScripts.events.DeleteFileEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.RenameFileFolderEvent;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.events.OpenLocationEvent;
import actionScripts.controllers.OpenLocationCommand;

class IDEController {

	private var commands:Dynamic = {};

	public function new() {
		init();
	}

	public function init():Void {
		setupBindings();
		setupListener();
	}

	public function setupBindings():Void {
		Reflect.setField(commands, CloseTabEvent.EVENT_CLOSE_TAB, CloseTabCommand);
		Reflect.setField(commands, CloseTabEvent.EVENT_CLOSE_ALL_TABS, CloseTabCommand);
		Reflect.setField(commands, OpenFileEvent.OPEN_FILE, OpenFileCommand);
		Reflect.setField(commands, OpenFileEvent.TRACE_LINE, OpenFileCommand);
		Reflect.setField(commands, OpenFileEvent.JUMP_TO_SEARCH_LINE, OpenFileCommand);
		Reflect.setField(commands, AddTabEvent.EVENT_ADD_TAB, AddTabCommand);
		Reflect.setField(commands, OpenLocationEvent.OPEN_LOCATION, OpenLocationCommand);

		Reflect.setField(commands, MenuPlugin.MENU_SAVE_AS_EVENT, SaveAsCommand);
		Reflect.setField(commands, MenuPlugin.MENU_SAVE_EVENT, SaveFileCommand);
		Reflect.setField(commands, MenuPlugin.MENU_QUIT_EVENT, QuitCommand);
		Reflect.setField(commands, DeleteFileEvent.EVENT_DELETE_FILE, DeleteFileCommand);
		Reflect.setField(commands, RenameFileFolderEvent.RENAME_FILE_FOLDER, RenameFileFolderCommand);

		/*commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN] = 	ChangeLineEndingCommand;
		commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX] =	ChangeLineEndingCommand;
		commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9] =		ChangeLineEndingCommand;*/
	}

	public function setupListener():Void {
		var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		for (eventName in Reflect.fields(commands)) {
			ged.addEventListener(eventName, execCommand);
		}
	}

	public function execCommand(event:Event):Void {
		var cmd:ICommand = new Reflect.field(commands, event.type)();
		cmd.execute(event);
	}

}