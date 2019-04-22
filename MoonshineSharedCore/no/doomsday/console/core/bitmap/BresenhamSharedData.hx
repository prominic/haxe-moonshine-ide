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
package no.doomsday.console.core.bitmap;

import flash.geom.Point;

/**
 * ...
 * @author Andreas Rønning
 */
@:final class BresenhamSharedData {

	public var x0:Int = 0;public var x1:Int = 0;public var y0:Int = 0;public var y1:Int = 0;public var deltax:Int = 0;public var deltay:Int = 0;public var error:Int = 0;public var ystep:Int = 0;
	public var steep:Bool = false;
	private var t1:Int = 0;private var t2:Int = 0;private var temp:Int = 0;

	public function update(p1:Point, p2:Point):Void {
		t1 = AS3.int(p1.y - p2.y);
		t2 = AS3.int(p1.x - p2.x);
		steep = ((t1 ^ (t1 >> 31)) - (t1 >> 31)) > ((t2 ^ (t2 >> 31)) - (t2 >> 31));
		x0 = AS3.int(p2.x);
		x1 = AS3.int(p1.x);
		y0 = AS3.int(p2.y);
		y1 = AS3.int(p1.y);

		if (steep) {
			x0 = x0 ^ y0;
			y0 = y0 ^ x0;
			x0 = x0 ^ y0;

			x1 = x1 ^ y1;
			y1 = y1 ^ x1;
			x1 = x1 ^ y1;
		}
		if (x0 > x1) {
			x0 = x0 ^ x1;
			x1 = x1 ^ x0;
			x0 = x0 ^ x1;

			y0 = y0 ^ y1;
			y1 = y1 ^ y0;
			y0 = y0 ^ y1;
		}
		deltax = AS3.int(x1 - x0);
		temp = AS3.int(y1 - y0);
		deltay = AS3.int((temp ^ (temp >> 31)) - (temp >> 31));
		error = AS3.int(deltax * .5);
		((y0 < y1)) ? ystep = 1 : ystep = -1;
	}

	public function new() {}

}