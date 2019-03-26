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
package actionScripts.plugins.vscodeDebug.events;

import actionScripts.plugins.vscodeDebug.vo.StackFrame;
import flash.events.Event;
class StackFrameEvent extends Event {

	public static inline var GOTO_STACK_FRAME:String = 'gotoStackFrame';

	public function new(type:String, stackFrame:StackFrame) {
		super(type, false, false);
		this.stackFrame = stackFrame;
	}

	public var stackFrame:StackFrame;

}