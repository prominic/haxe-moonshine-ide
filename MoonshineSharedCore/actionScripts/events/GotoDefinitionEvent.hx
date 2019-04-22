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

import actionScripts.valueObjects.Location;
import actionScripts.valueObjects.Position;
import flash.events.Event;

class GotoDefinitionEvent extends Event {

	public static inline var EVENT_SHOW_DEFINITION_LINK:String = 'newShowDefinitionLink';

	public var locations:Array<Location>;
	public var position:Position;

	public function new(type:String, locations:Array<Location>, position:Position) {
		super(type, false, true);
		this.locations = cast locations;
		this.position = position;
	}

}