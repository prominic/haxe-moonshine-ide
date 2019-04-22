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
package actionScripts.plugin.core.compiler;

import flash.events.Event;

class ActionScriptBuildEvent extends Event {

	public static inline var BUILD_AND_RUN:String = 'compilerBuildAndRun';
	public static inline var BUILD_AND_RUN_JAVASCRIPT:String = 'compilerBuildAndRunJavaScript';
	public static inline var BUILD_AS_JAVASCRIPT:String = 'compilerBuildAsJavaScript';
	public static inline var BUILD_AND_DEBUG:String = 'compilerBuildAndDebug';
	public static inline var RUN_AFTER_DEBUG:String = 'compilerRunAfterDebug';
	public static inline var BUILD:String = 'compilerBuild';
	public static inline var BUILD_RELEASE:String = 'compilerBuildRelease';
	public static inline var PREBUILD:String = 'compilerPrebuild';
	public static inline var POSTBUILD:String = 'compilerPostbuild';
	public static inline var DEBUG_STEPOVER:String = 'debugStepOVer';
	public static inline var TERMINATE_EXECUTION:String = 'terminateExecution';
	public static inline var STOP_DEBUG:String = 'stopDebug';
	public static inline var EXIT_FDB:String = 'EXIT_FDB';
	public static inline var CONTINUE_EXECUTION:String = 'continueExecution';
	public static inline var SAVE_BEFORE_BUILD:String = 'saveBeforeBuild';

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}

}