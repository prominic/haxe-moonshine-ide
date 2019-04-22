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
package actionScripts.plugin.run;

import mx.collections.ArrayCollection;
import mx.core.IVisualElement;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.run.view.RunMobileSettingRenderer;
import actionScripts.plugin.settings.vo.AbstractSetting;

class RunMobileSetting extends AbstractSetting {

	private var copiedPaths:ArrayCollection;

	public var relativeRoot:FileLocation;

	private var rdr:RunMobileSettingRenderer;

	private var _project:AS3ProjectVO;
	private var _visible:Bool = true;

	public function new(provider:Dynamic, label:String,
			relativeRoot:FileLocation = null) {
		super();
		this.provider = provider;
		this.label = label;
		this.relativeRoot = relativeRoot;
		defaultValue = '';
	}

	override private function set_stringValue(v:String):String {
		if (v != '') {
			var toRet:Array<FileLocation> = new Array<FileLocation>();
			var values:Array<String> = v.split(',');
			for (v in values) {
				toRet.push(new FileLocation(v));
			}
		}
		setPendingSetting(toRet);
		return v;
	}

	override private function get_renderer():IVisualElement {
		rdr = new RunMobileSettingRenderer();
		rdr.setting = this;
		rdr.enabled = _visible;
		return rdr;
	}

	override public function commitChanges():Void {
		if (rdr != null) {
			rdr.commitChanges();
		}
	}

	public var visible(get, set):Bool;
	private function set_visible(value:Bool):Bool {
		_visible = value;
		if (rdr != null) {
			rdr.enabled = _visible;
		}
		return value;
	}

	private function get_visible():Bool {
		return _visible;
	}

	public var project(get, set):AS3ProjectVO;
	private function set_project(value:AS3ProjectVO):AS3ProjectVO {
		_project = value;
		return value;
	}

	private function get_project():AS3ProjectVO {
		return _project;
	}

	// Helper function
	public function getLabelFor(file:Dynamic):String {
		var tmpFL:FileLocation = ((Std.is(file, FileLocation))) ? AS3.as(file, FileLocation) : new FileLocation(AS3.string(Reflect.field(file, 'nativePath')));
		var lbl:String = Std.string(FileLocation(Reflect.field(provider, 'folderLocation')).fileBridge.getRelativePath(tmpFL, true));
		if (lbl == null) {
			if (relativeRoot != null) {
				lbl = Std.string(relativeRoot.fileBridge.getRelativePath(tmpFL));
			}
			if (relativeRoot != null && relativeRoot.fileBridge.nativePath == tmpFL.fileBridge.nativePath) {
				lbl = '/';
			}
			if (lbl == null) {
				lbl = Std.string(tmpFL.fileBridge.nativePath);
			}

			if (AS3.as(tmpFL.fileBridge.isDirectory, Bool)
				&& lbl.charAt(lbl.length - 1) != '/') {
				lbl += '/';
			}
		}

		return lbl;
	}

	public function updateDevices(forPlatform:String):Void {
		if (rdr != null) {
			rdr.updateDevices(forPlatform);
		}
	}

}