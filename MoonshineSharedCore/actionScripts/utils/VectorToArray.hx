/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.

Author: Victor Dramba
2009
*/

package actionScripts.utils;

/**
 * Class for vectorToArray
 */
@:final class VectorToArray {

	public static function vectorToArray(v:Dynamic):Array<Dynamic> {
		var a:Array<Dynamic> = [];
		for (i in 0...v.length) {
			a[i] = Reflect.field(v, Std.string(i));
		}
		return a;
	}

}