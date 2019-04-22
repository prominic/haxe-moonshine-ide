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
package actionScripts.events;

import flash.events.Event;
import actionScripts.ui.renderers.FTETreeItemRenderer;
import actionScripts.valueObjects.FileWrapper;

class TreeMenuItemEvent extends Event {

	public static inline var RIGHT_CLICK_ITEM_SELECTED:String = 'menuItemSelectedEvent';
	public static inline var EDIT_CANCEL:String = 'editCancel';
	public static inline var EDIT_END:String = 'editEnd';
	public static inline var NEW_FILE_CREATED:String = 'NEW_FILE_CREATED';
	public static inline var FILE_DELETED:String = 'FILE_DELETED';
	public static inline var FILE_RENAMED:String = 'FILE_RENAMED';
	public static inline var NEW_FILES_FOLDERS_COPIED:String = 'NEW_FILE_FOLDER_COPIED';

	public var menuLabel:String;
	public var data:FileWrapper;
	public var renderer:FTETreeItemRenderer;
	public var extra:Dynamic;
	public var showAlert:Bool = false;

	public function new(type:String, menuLabel:String, data:FileWrapper, showAlert:Bool = true) {
		this.menuLabel = menuLabel;
		this.data = data;
		this.showAlert = showAlert;

		super(type, true, false);
	}

}