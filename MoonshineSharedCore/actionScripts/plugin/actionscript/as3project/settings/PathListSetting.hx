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
package actionScripts.plugin.actionscript.as3project.settings;

import mx.collections.ArrayCollection;
import mx.core.IVisualElement;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.settings.vo.AbstractSetting;

class PathListSetting extends AbstractSetting {

	private var copiedPaths:ArrayCollection;

	public var allowFiles:Bool = false;
	public var allowFolders:Bool = false;
	public var fileMustExist:Bool = false;
	public var relativeRoot:FileLocation;
	public var customMessage:IVisualElement;
	public var displaySourceFolder:Bool = false;

	private var rdr:PathListSettingRenderer;

	public function new(provider:Dynamic, name:String, label:String,
			relativeRoot:FileLocation = null,
			allowFiles:Bool = true,
			allowFolders:Bool = true,
			fileMustExist:Bool = true,
			displaySourceFolder:Bool = false) {
		super();
		this.provider = provider;
		this.name = name;
		this.label = label;
		this.allowFiles = allowFiles;
		this.allowFolders = allowFolders;
		this.fileMustExist = fileMustExist;
		this.relativeRoot = relativeRoot;
		this.displaySourceFolder = displaySourceFolder;
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
		rdr = new PathListSettingRenderer();
		rdr.setting = this;
		rdr.enabled = _isEditable;
		return rdr;
	}

	public var paths(get, never):ArrayCollection;
	private function get_paths():ArrayCollection {
		if (copiedPaths == null) {
			if (getSetting() == null) {
				return null;
			}

			copiedPaths = new ArrayCollection();
			for (f in as3hx.Compat.each(getSetting())) {
				var tmpPath:PathListItemVO = new PathListItemVO(f, getLabelFor(f));
				if (displaySourceFolder &&
					Reflect.hasField(provider, 'sourceFolder') &&
					Reflect.field(provider, 'sourceFolder') != null &&
					FileLocation(Reflect.field(provider, 'sourceFolder')).fileBridge.nativePath == Reflect.field(Reflect.field(f, 'fileBridge'), 'nativePath')) {
					tmpPath.isMainSourceFolder = true;
				}
				copiedPaths.addItem(tmpPath);
			}
		}
		return copiedPaths;
	}

	override public function valueChanged():Bool {
		if (copiedPaths == null) {
			return false;
		}

		var tmpString:String = '';
		var matches:Bool = true;
		var itemMatch:Bool;
		for (f1 in as3hx.Compat.each(getSetting())) {
			itemMatch = false;
			for (item in copiedPaths) {
				tmpString += Reflect.field(Reflect.field(f1, 'fileBridge'), 'nativePath') + ' : ' + Reflect.field(Reflect.field(Reflect.field(item, 'file'), 'fileBridge'), 'nativePath') + '\n';
				if (Reflect.field(Reflect.field(f1, 'fileBridge'), 'nativePath') == Reflect.field(Reflect.field(Reflect.field(item, 'file'), 'fileBridge'), 'nativePath')) {
					itemMatch = true;
				}
			}

			if (!itemMatch) {
				matches = false;
				break;
			}
		}

		// Length mismatch?
		if (AS3.as(getSetting(), Bool) && copiedPaths != null) {
			if (getSetting().length != copiedPaths.length) {
				matches = false;
			}
		}

		return !matches;
	}

	override public function commitChanges():Void {
		if (!hasProperty() || !valueChanged()) {
			return;
		}

		var pending:Array<FileLocation> = new Array<FileLocation>();
		for (item in copiedPaths) {
			if (Reflect.field(item, 'label') != PathListSettingRenderer.NOT_SET_PATH_MESSAGE) {
				pending.push(Reflect.field(item, 'file'));
			}
		}

		Reflect.setField(provider, name, pending);
		hasPendingChanges = false;
	}

	private var _isEditable:Bool = true;

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

}