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

import flash.system.Capabilities;

class Settings {

	private static var _os:String;

	public static var os(get, never):String;
	private static function get_os():String {
		return _os;
	}

	private static var _keyboard:KeyboardSettings;

	public static var keyboard(get, never):KeyboardSettings;
	private static function get_keyboard():KeyboardSettings {
		return _keyboard;
	}

	private static var _font:FontSettings;

	public static var font(get, never):FontSettings;
	private static function get_font():FontSettings {
		return _font;
	}
// Static initialization

	public function new() {}

	private static var Settings_static_initializer = {
		{
			_os = ((AS3.as(ConstantsCoreVO.IS_AIR, Bool))) ? Capabilities.os.substr(0, 3).toLowerCase() : Capabilities.version.substr(0, 3).toLowerCase();
			_keyboard = new KeyboardSettings();
			_font = new FontSettings();
		};
		true;
	}

}