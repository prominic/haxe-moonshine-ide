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
import actionScripts.valueObjects.FileWrapper;

class RenameFileFolderEvent extends Event {

	public static inline var RENAME_FILE_FOLDER:String = 'RENAME_FILE_FOLDER';

	public var fw:FileWrapper;
	public var oldName:String;

	public function new(type:String, fw:FileWrapper, oldName:String) {
		this.fw = fw;
		this.oldName = oldName;

		super(type, true, false);
	}

}