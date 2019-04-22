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

import haxe.Constraints.Function;
import flash.events.Event;
import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.ProjectVO;

class DeleteFileEvent extends Event {

	public static inline var EVENT_DELETE_FILE:String = 'deleteFileEvent';

	public var file:FileLocation;
	public var wrappers:Array<Dynamic>;
	public var treeViewCompletionHandler:Function;
	public var showAlert:Bool = false;
	public var projectAssociatedWithFile:ProjectVO;

	// If you don't supply a filewrapper with a version control object it won't be registered with vc
	public function new(file:FileLocation, wrappers:Array<Dynamic> = null, treeViewHandler:Function = null,
			showAlert:Bool = true, projectAssociatedWithFile:ProjectVO = null) {
		this.file = file;
		this.wrappers = wrappers;
		this.showAlert = showAlert;
		this.treeViewCompletionHandler = cast treeViewHandler;
		this.projectAssociatedWithFile = projectAssociatedWithFile;

		super(EVENT_DELETE_FILE, false, false);
	}

}