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

import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

/**
 * Class for getProjectSDKPath
 */
@:final class GetProjectSDKPath {

	public static function getProjectSDKPath(project:ProjectVO, model:IDEModel):String {
		var sdkPath:String = null;
		if (Std.is(project, AS3ProjectVO)) {
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			if (AS3.as(as3Project.buildOptions.customSDK, Bool)) {
				return Std.string(as3Project.buildOptions.customSDK.fileBridge.nativePath);
			} else if (AS3.as(model.defaultSDK, Bool)) {
				return Std.string(model.defaultSDK.fileBridge.nativePath);
			}
		} else if (Std.is(project, JavaProjectVO)) {
			var javaProject:JavaProjectVO = JavaProjectVO(project);
			if (AS3.as(model.javaPathForTypeAhead, Bool)) {
				return Std.string(model.javaPathForTypeAhead.fileBridge.nativePath);
			}
		}
		return null;
	}

}