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
package actionScripts.plugin.settings.vo;

class NameValuePair {

	public function new(name:String, value:Dynamic) {
		_name = name;
		_value = value;
	}

	private var _name:String;
	private var _value:Dynamic;

	public var name(get, never):String;
	private function get_name():String {
		return _name;
	}

	public var value(get, never):Dynamic;
	private function get_value():Dynamic {
		return _value;
	}

}