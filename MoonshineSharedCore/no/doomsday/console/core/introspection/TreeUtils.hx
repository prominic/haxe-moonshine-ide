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
package no.doomsday.console.core.introspection;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

/**
 * ...
 * @author Andreas Rønning
 */
class TreeUtils {

	public function new() {}

	public static function getChildren(o:Dynamic):Array<ChildScopeDesc> {
		var out:Array<ChildScopeDesc> = new Array<ChildScopeDesc>();
		//if we're in a DisplayObjectContainer, add first level children
		var c:ChildScopeDesc;
		if (Std.is(o, DisplayObjectContainer)) {
			var d:DisplayObjectContainer = AS3.as(o, DisplayObjectContainer);
			var cd:DisplayObject;
			var n:Int = d.numChildren;
			n > 0;
			while (n-- != 0) {
				cd = d.getChildAt(n);
				c = new ChildScopeDesc();
				c.name = cd.name;
				c.type = Std.string(cd);
				out.push(c);
			}
		}
		return out;
	}

}