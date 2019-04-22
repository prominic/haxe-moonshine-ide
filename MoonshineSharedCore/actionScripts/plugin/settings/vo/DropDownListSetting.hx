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

import mx.collections.IList;
import mx.core.IVisualElement;
import actionScripts.plugin.settings.renderers.DropDownListSettingRenderer;

class DropDownListSetting extends AbstractSetting {

	@:meta(Bindable())public var dataProvider:IList;
	public var labelField:String;

	private var rdr:DropDownListSettingRenderer;

	private var _isEditable:Bool = true;

	public function new(provider:Dynamic, name:String, label:String, dataProvider:IList, labelField:String = null) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		this.labelField = labelField;
		this.dataProvider = dataProvider;
		defaultValue = '';
	}

	override private function get_renderer():IVisualElement {
		rdr = new DropDownListSettingRenderer();
		rdr.setting = this;
		rdr.enabled = _isEditable;
		return rdr;
	}

	public var isEditable(get, set):Bool;
	private function set_isEditable(value:Bool):Bool {
		_isEditable = value;
		if (rdr != null) {
			rdr.mouseChildren = _isEditable;
			rdr.enabled = _isEditable;
		}
		return value;
	}

	private function get_isEditable():Bool {
		return _isEditable;
	}

}