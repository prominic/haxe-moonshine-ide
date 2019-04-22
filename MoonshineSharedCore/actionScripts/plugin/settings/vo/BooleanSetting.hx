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

import mx.core.IVisualElement;
import actionScripts.plugin.settings.renderers.BooleanRenderer;

class BooleanSetting extends AbstractSetting {

	public static inline var VALUE_UPDATED:String = 'valueUpdated';

	private var immediateSave:Bool = false;

	public function new(provider:Dynamic, name:String, label:String, immediateSave:Bool = false) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		this.immediateSave = immediateSave;
		defaultValue = stringValue;
	}

	override private function setPendingSetting(v:Dynamic):Void {
		super.setPendingSetting((Std.is(v, String)) ? (v == 'true') ? true : false : v);
	}

	@:meta(Bindable())
	public var value(get, set):Bool;
	private function get_value():Bool {
		var val:String = Std.string(getSetting());
		return (val == 'true') ? true : false;
	}

	private function set_value(v:Bool):Bool {
		setPendingSetting(v);
		if (immediateSave) {
			commitChanges();
		}
		return v;
	}

	override private function get_renderer():IVisualElement {
		var rdr:BooleanRenderer = new BooleanRenderer();
		rdr.setting = this;

		return rdr;
	}

}