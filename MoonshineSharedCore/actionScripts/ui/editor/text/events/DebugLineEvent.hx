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
package actionScripts.ui.editor.text.events;

import flash.events.Event;

class DebugLineEvent extends Event {

	public static inline var SET_DEBUG_LINE:String = 'setDebugLineEvent';
	public static inline var SET_DEBUG_FINISH:String = 'setDebugFinishEvent';

	public var breakPointLine:Int = 0;
	public var breakPoint:Bool = false;

	public function new(type:String, breakPointLine:Int, breakPoint:Bool) {
		this.breakPointLine = breakPointLine;
		this.breakPoint = breakPoint;
		super(type, false, false);
	}

}