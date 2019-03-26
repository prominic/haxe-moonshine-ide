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
package actionScripts.plugins.svn.event;

import flash.events.Event;
import flash.filesystem.File;
import actionScripts.valueObjects.ProjectVO;
class SVNEvent extends Event {

	public static inline var EVENT_CHECKOUT:String = 'checkoutEvent';

	public static inline var OSX_XCODE_PERMISSION_GIVEN:String = 'onXCodePermissionGivenOnOSX';

	public static inline var SVN_AUTH_REQUIRED:String = 'svnAuthRequired';

	public static inline var SVN_ERROR:String = 'svnError';

	public static inline var SVN_RESULT:String = 'svnResult';

	public var file:File;

	public var url:String;

	public var project:ProjectVO;

	public var authObject:Dynamic;
// [username, password]
	public var extras:Array<Dynamic>;

	public function new(type:String, file:File, url:String = null, project:ProjectVO = null, authObject:Dynamic = null, param:Array<Dynamic> = null) {
		this.file = file;
		this.url = url;
		this.authObject = authObject;
		this.project = project;
		this.extras = param;
		super(type, false, true);
	}

}