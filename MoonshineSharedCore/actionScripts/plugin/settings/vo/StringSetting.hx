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
import actionScripts.plugin.settings.renderers.StringRenderer;

class StringSetting extends AbstractSetting {

	public static inline var VALUE_UPDATED:String = 'valueUpdated';

	private var restrict:String;
	private var rdr:StringRenderer;

	private var _isEditable:Bool = true;

	public function new(provider:Dynamic, name:String, label:String, restrict:String = null) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		this.restrict = restrict;
		defaultValue = stringValue;
	}

	override private function get_renderer():IVisualElement {
		rdr = new StringRenderer();
		if (restrict != null) {
			rdr.text.restrict = restrict;
		}

		rdr.setting = this;
		rdr.enabled = isEditable;
		rdr.setMessage(message, messageType);
		return rdr;
	}

	public function setMessage(value:String, type:String = MESSAGE_NORMAL):Void {
		if (rdr != null) {
			rdr.setMessage(value, type);
		} else {
			message = value;
			messageType = type;
		}
	}

	public var isEditable(get, set):Bool;
	private function set_isEditable(value:Bool):Bool {
		_isEditable = value;
		if (rdr != null) {
			rdr.enabled = _isEditable;
		}
		return value;
	}

	private function get_isEditable():Bool {
		return _isEditable;
	}

}