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
package actionScripts.ui.parser.context;

class ContextSwitchManager {

	private var switches:Dynamic = {};

	private function new(switches:Array<ContextSwitch>) {
		for (swtch in switches) {
			addSwitch(swtch);
		}
	}

	public function addSwitch(swtch:ContextSwitch, highPriority:Bool = false):Void {
		for (from in swtch.from) {
			if (Reflect.field(switches, Std.string(from)) == null) {
				Reflect.setField(switches, Std.string(from), new Array<ContextSwitch>());
			}

			if (highPriority) {
				Reflect.field(switches, Std.string(from)).unshift(swtch);
			} else {
				Reflect.field(switches, Std.string(from)).push(swtch);
			}
		}
	}

	public function getSwitches(from:Int):Array<ContextSwitch> {
		return Reflect.field(switches, Std.string(from));
	}

}