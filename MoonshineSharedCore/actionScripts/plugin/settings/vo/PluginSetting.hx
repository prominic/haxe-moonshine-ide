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
import actionScripts.plugin.settings.renderers.PluginRenderer;

class PluginSetting extends AbstractSetting {

	private var _value:String = '';

	@:meta(Bindable())
	public var author:String;

	@:meta(Bindable())
	public var description:String;

	public function new(pluginName:String, author:String, description:String, activated:Bool) {
		super();
		this.name = pluginName;
		this.label = 'activated';
		this.author = author;
		this.description = description;
		stringValue = defaultValue = Std.string(activated);
	}

	override private function getSetting():Dynamic {
		return _value;
	}

	override private function setPendingSetting(v:Dynamic):Void {
		super.setPendingSetting(v);
		_value = Std.string(v);
	}

	override private function get_renderer():IVisualElement {
		var rdr:PluginRenderer = new PluginRenderer();
		rdr.percentWidth = 100;
		rdr.setting = this;
		return rdr;
	}

}