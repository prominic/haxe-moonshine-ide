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

import flash.events.EventDispatcher;
import actionScripts.plugin.settings.IHasSettings;

class SettingsWrapper extends EventDispatcher implements IHasSettings {

	private var _name:String;
	private var _settings:Array<ISetting>;

	public function new(name:String, settings:Array<ISetting>) {
		super();
		_name = name;
		_settings = cast settings;
	}

	@:meta(Bindable(event = 'weDontReallyCare'))
	public var name(get, never):String;
	private function get_name():String {
		return _name;
	}

	public function getSettingsList():Array<ISetting> {
		return cast _settings;
	}

	public function hasChanged():Bool {
		for (setting in _settings) {
			if (setting.valueChanged()) {
				return true;
			}
		}
		return false;
	}

	public function commitChanges():Void {
		for (setting in _settings) {
			if (setting.valueChanged()) {
				setting.commitChanges();
			}
		}
	}

}