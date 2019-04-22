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
package no.doomsday.utilities.math;

/**
 * ...
 * @author Andreas Rønning
 */
class MathUtils {

	public static function random(from:Float = 0, to:Float = 1, round:Bool = false):Float {
		var v:Float = from + Math.random() * (to - from);
		return (round) ? Math.round(v) : v;
	}

	public static function add(a:Float, b:Float):Float {
		return a + b;
	}

	public static function subtract(a:Float, b:Float):Float {
		return a - b;
	}

	public static function divide(a:Float, b:Float):Float {
		return a / b;
	}

	public static function multiply(a:Float, b:Float):Float {
		return a * b;
	}

	public static function ceil(x:Float):Int {
		if (x > 0) {
			return AS3.int(x + 1);
		} else {
			return AS3.int(x);
		}
	}

}