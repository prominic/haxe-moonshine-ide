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
import actionScripts.plugin.settings.renderers.IntRenderer;

class IntSetting extends AbstractSetting {

	public function new(provider:Dynamic, name:String, label:String) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		defaultValue = stringValue;
	}

	public var value(get, set):Int;
	private function get_value():Int {
		return as3hx.Compat.parseInt(getSetting());
	}

	private function set_value(v:Int):Int {
		setPendingSetting(v);
		return v;
	}

	override private function get_renderer():IVisualElement {
		var rdr:IntRenderer = new IntRenderer();
		rdr.setting = this;

		return rdr;
	}

}