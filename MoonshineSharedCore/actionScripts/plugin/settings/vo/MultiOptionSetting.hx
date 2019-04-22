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
import actionScripts.plugin.settings.renderers.MultiOptionRenderer;

class MultiOptionSetting extends StringSetting {

	public var isCommitOnChange:Bool = false;

	private var _options:Array<NameValuePair>;

	private var _isEditable:Bool = false;

	private var rdr:MultiOptionRenderer;

	public function new(provider:Dynamic, name:String, label:String, options:Array<NameValuePair>) {
		super(provider, name, label);
		_options = cast options;
		value = defaultValue = stringValue;
	}

	public var value(get, set):Dynamic;
	private function get_value():Dynamic {
		return getSetting();
	}

	private function set_value(v:Dynamic):Dynamic {
		setPendingSetting(v);
		return v;
	}

	override private function get_renderer():IVisualElement {
		rdr = new MultiOptionRenderer();
		rdr.options = _options;
		rdr.setting = this;
		return rdr;
	}

	override private function set_isEditable(value:Bool):Bool {
		_isEditable = value;
		if (rdr != null) {
			rdr.mouseChildren = _isEditable;
			//rdr.filters = _isEditable ? [] : [myBlurFilter];
		}
		return value;
	}

	override private function get_isEditable():Bool {
		return _isEditable;
	}

}