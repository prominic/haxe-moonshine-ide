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
package no.doomsday.utilities.monitoring;

import flash.errors.Error;
import haxe.Constraints.Function;

/**
 * ...
 * @author Andreas Rønning
 */
@:final class GraphValueStack {

	public var storeHistory:Bool = false;
	public var allValues:Array<Float> = new Array<Float>();
	private var values:GraphValue = new GraphValue();
	private var head:GraphValue;
	private var count:Int = 0;
	private var _maxValues:Int = 0;
	private var _lastValue:Float;
	private var startTime:Int = 0;

	public var totalValues(get, never):Int;
	private function get_totalValues():Int {
		return count;
	}

	public function new(maxValues:Int) {
		this.head = this.values;
		_maxValues = maxValues;
	}

	public function add(n:Float):Void {
		if (startTime == 0) {
			startTime = Math.round(haxe.Timer.stamp() * 1000);
		}
		var v:GraphValue = new GraphValue();
		_lastValue = n;
		v.value = n;
		v.creationTime = AS3.int(Math.round(haxe.Timer.stamp() * 1000) - startTime);
		if (storeHistory) {
			allValues.push(v.creationTime);
			allValues.push(n);

		}
		head.next = v;
		head = v;
		count++;
		if (count > _maxValues) {
			values = values.next;
			count--;
		}
	}

	public function clear():Void {
		allValues = new Array<Float>();
		values.next = null;
		head = values;
		count = 0;
	}

	public function extend():Void {
		add(_lastValue);
	}

	public var average(get, never):Float;
	private function get_average():Float {
		if (count > 0) {
			return sum / count;
		}
		return 0;
	}

	public var sum(get, never):Float;
	private function get_sum():Float {
		var v:GraphValue = values;
		var total:Float = 0;
		while (v.next != null) {
			v = v.next;
			total += v.value;
		}
		return total;
	}

	public function getValueAt(index:Int):GraphValue {
		var v:GraphValue = values;
		var idx:Int = 0;
		while (v.next != null) {
			v = v.next;
			if (idx == index) {
				return v;
			}
			idx++;
		}
		throw new Error('The index ' + index + ' is out of range');
	}

	public var maxValues(get, set):Int;
	private function get_maxValues():Int {
		return _maxValues;
	}

	private function set_maxValues(value:Int):Int {
		_maxValues = value;
		while (count > _maxValues) {
			values = values.next;
			count--;
		}
		return value;
	}

	public function forEach(func:Function):Void {
		var v:GraphValue = values;
		var idx:Int = 0;
		while (v.next != null) {
			v = v.next;
			func(v.value, idx);
			idx++;
		}
	}

	public function toString():String {
		var out:String;
		var v:GraphValue = values;
		var total:Float = 0;
		while (v.next != null) {
			v = v.next;
			if (out == null) {
				out = Std.string(v.value) + '\n';
			} else {
				out += v.value + '\n';
			}
		}
		if (out == null) {
			out = '';
		}
		return out;
	}

	public var lastValue(get, never):Float;
	private function get_lastValue():Float {
		return _lastValue;
	}

}