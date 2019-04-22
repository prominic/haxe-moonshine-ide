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

import actionScripts.plugin.settings.renderers.ProjectDirectoryPathRenderer;
import mx.core.IVisualElement;

@:meta(Event(name = 'pathSelected', type = 'flash.events.Event'))
class ProjectDirectoryPathSetting extends AbstractSetting {

	private var rdr:ProjectDirectoryPathRenderer;

	private var _path:String;
	private var _projectDirectoryPath:String;

	public function new(provider:Dynamic, projectDirectoryPath:String, name:String, label:String, path:String = null) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;

		_projectDirectoryPath = projectDirectoryPath;
		_path = path;

		defaultValue = stringValue = ((path != null)) ? path : (stringValue != null) ? stringValue : '';
	}

	public var projectDirectoryPath(get, never):String;
	private function get_projectDirectoryPath():String {
		return _projectDirectoryPath;
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
		rdr = new ProjectDirectoryPathRenderer();
		rdr.setting = this;
		rdr.setMessage(message, messageType);

		return rdr;
	}

}