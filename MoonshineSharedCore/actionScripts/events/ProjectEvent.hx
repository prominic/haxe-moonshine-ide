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
import actionScripts.valueObjects.ProjectVO;

class ProjectEvent extends Event {

	public static inline var SHOW_PROJECT_VIEW:String = 'showProjectViewEvent';

	public static inline var ADD_PROJECT:String = 'addProjectEvent';
	public static inline var OPEN_PROJECT_AWAY3D:String = 'openProjectEventAway3D';
	public static inline var REMOVE_PROJECT:String = 'removeProjectEvent';
	public static inline var SHOW_PREVIOUSLY_OPENED_PROJECTS:String = 'showPreviouslyOpenedProjects';
	public static inline var SCROLL_FROM_SOURCE:String = 'scrollFromSource';

	public static inline var TREE_DATA_UPDATES:String = 'TREE_DATA_UPDATES';
	public static inline var PROJECT_FILES_UPDATES:String = 'PROJECT_FILES_UPDATES';

	public static inline var SAVE_PROJECT_SETTINGS:String = 'SAVE_PROJECT_SETTINGS';
	public static inline var EVENT_IMPORT_FLASHBUILDER_PROJECT:String = 'importFBProjectEvent';
	public static inline var EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG:String = 'importProjectDirect';

	public static inline var EVENT_IMPORT_PROJECT_ARCHIVE:String = 'importProjectArchive';

	public static inline var LAST_OPENED_AS_FB_PROJECT:String = 'LAST_OPENED_AS_FB_PROJECT';
	public static inline var LAST_OPENED_AS_FD_PROJECT:String = 'LAST_OPENED_AS_FD_PROJECT';

	public static inline var FLEX_SDK_UDPATED:String = 'FLEX_SDK_UDPATED';
	public static inline var FLEX_SDK_UDPATED_OUTSIDE:String = 'FLEX_SDK_UDPATED_OUTSIDE';
	public static inline var SET_WORKSPACE:String = 'SET_WORKSPACE';
	public static inline var WORKSPACE_UPDATED:String = 'WORKSPACE_UPDATED';
	public static inline var ACCESS_MANAGER:String = 'ACCESS_MANAGER';
	public static inline var ACTIVE_PROJECT_CHANGED:String = 'ACTIVE_PROJECT_CHANGED';

	public static inline var CHECK_GIT_PROJECT:String = 'checkGitRepository';
	public static inline var CHECK_SVN_PROJECT:String = 'checkSVNRepository';
	public static inline var LANGUAGE_SERVER_OPENED:String = 'languageServerOpenedAgainstProject';
	public static inline var LANGUAGE_SERVER_CLOSED:String = 'languageServerClosedAgainstProject';

	public var project:ProjectVO;
	public var anObject:Dynamic;
	public var extras:Array<Dynamic>;

	public function new(type:String, project:Dynamic = null, args:Array<Dynamic> = null) {
		if (Std.is(project, ProjectVO)) {
			this.project = AS3.as(project, ProjectVO);
		} else {
			anObject = project;
		}

		extras = args;
		super(type, false, false);
	}

}