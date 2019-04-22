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
import actionScripts.plugin.settings.renderers.StaticLabelRenderer;

class StaticLabelSetting extends AbstractSetting {

	@:meta(Bindable())public var fontSize:Int = 0;

	public var fakeSetting:String = '';

	public function new(label:String, fontSize:Int = 24) {
		super();
		this.name = 'fakeSetting';
		this.label = label;
		this.fontSize = fontSize;

	}

	override private function get_renderer():IVisualElement {
		var rdr:StaticLabelRenderer = new StaticLabelRenderer();
		rdr.setting = this;
		return rdr;
	}

	// Do nothing
	override private function getSetting():Dynamic {
		return '';
	}

	override private function hasProperty(names:Array<Dynamic> = null):Bool {
		return false;
	}

	override private function setPendingSetting(v:Dynamic):Void {}

	override public function valueChanged():Bool {
		return false;
	}

	override public function commitChanges():Void {}

}