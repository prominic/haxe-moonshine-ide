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
import actionScripts.factory.FileLocation;

class RenameApplicationEvent extends Event {

	public static inline var RENAME_APPLICATION_FOLDER:String = 'RENAME_APPLICATION_FOLDER';

	public var from:FileLocation;
	public var to:FileLocation;

	public function new(type:String, from:FileLocation, to:FileLocation) {
		this.from = from;
		this.to = to;

		super(type, true, false);
	}

}