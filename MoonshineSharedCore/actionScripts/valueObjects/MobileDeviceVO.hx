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
package actionScripts.valueObjects;

class MobileDeviceVO {

	public static inline var AND:String = 'AND';
	public static inline var IOS:String = 'IOS';

	public var type:String = AND;
	public var isDefault:Bool = false;

	public function new(name:String = null, key:String = null, type:String = null, dpi:String = '', isDefault:Bool = false) {
		this.name = name;
		this.key = key;
		this.type = type;
		this.dpi = dpi;
		this.isDefault = isDefault;
	}

	private var _name:String;

	public var name(get, set):String;
	private function get_name():String {
		return _name;
	}

	private function set_name(value:String):String {
		_name = value;
		return value;
	}

	private var _key:String;

	public var key(get, set):String;
	private function get_key():String {
		return _key;
	}

	private function set_key(value:String):String {
		_key = value;
		return value;
	}

	private var _dpi:String = '';

	public var dpi(get, set):String;
	private function get_dpi():String {
		return _dpi;
	}

	private function set_dpi(value:String):String {
		_dpi = value;
		return value;
	}

}