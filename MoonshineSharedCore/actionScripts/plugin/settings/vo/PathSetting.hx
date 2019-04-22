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

import mx.collections.ArrayCollection;
import mx.core.IVisualElement;
import actionScripts.plugin.settings.renderers.PathRenderer;

@:meta(Event(name = 'pathSelected', type = 'flash.events.Event'))
class PathSetting extends AbstractSetting {

	@:meta(Bindable())public var dropdownListItems:ArrayCollection;
	@:meta(Bindable())public var directory:Bool = false;
	public var fileFilters:Array<Dynamic>;

	private var isSDKPath:Bool = false;
	private var isDropDown:Bool = false;
	private var rdr:PathRenderer;

	private var _isEditable:Bool = true;
	private var _path:String;

	public function new(provider:Dynamic, name:String, label:String, directory:Bool,
			path:String = null, isSDKPath:Bool = false, isDropDown:Bool = false) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		this.directory = directory;
		this.isSDKPath = isSDKPath;
		this.isDropDown = isDropDown;
		this._path = path;
		defaultValue = stringValue = ((path != null)) ? path : (stringValue != null) ? stringValue : '';
	}

	public var path(get, never):String;
	private function get_path():String {
		return _path;
	}

	public function setMessage(value:String, type:String = MESSAGE_NORMAL):Void {
		if (rdr != null) {
			rdr.setMessage(value, type);
		} else {
			message = value;
			messageType = type;
		}
	}

	override private function get_renderer():IVisualElement {
		rdr = new PathRenderer();
		rdr.setting = this;
		rdr.isSDKPath = isSDKPath;
		rdr.isDropDown = isDropDown;
		rdr.enabled = _isEditable;
		rdr.setMessage(message, messageType);

		return rdr;
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