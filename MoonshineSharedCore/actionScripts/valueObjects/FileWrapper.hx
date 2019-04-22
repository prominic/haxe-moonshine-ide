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
package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.core.sourcecontrol.ISourceControlProvider;

@:meta(Bindable())
class FileWrapper {

	public var projectReference:ProjectReferenceVO;

	private var _file:FileLocation;
	private var _children:Array<Dynamic>;

	private var _isRoot:Bool = false;
	private var _isSourceFolder:Bool = false;
	private var _defaultName:String;
	private var _isWorking:Bool = false;
	private var _isDeleting:Bool = false;
	private var _sourceController:ISourceControlProvider;
	private var _shallUpdateChildren:Bool = false;
	private var _isHidden:Bool = false;

	public function new(file:FileLocation, isRoot:Bool = false,
			projectRef:ProjectReferenceVO = null, shallUpdateChildren:Bool = true) {
		_file = file;
		_isRoot = isRoot;
		_shallUpdateChildren = shallUpdateChildren;
		projectReference = projectRef;

		if (isRoot && projectRef != null && projectRef.name != null) {
			name = projectRef.name;
		} else if (file != null) {
			name = Std.string(file.fileBridge.name);
		}

		// store filelocation reference for later
		// search through Find Resource menu option
		if (_file != null && _shallUpdateChildren) {
			updateChildren();
		}
	}

	public var shallUpdateChildren(get, set):Bool;
	private function get_shallUpdateChildren():Bool {
		return _shallUpdateChildren;
	}

	private function set_shallUpdateChildren(value:Bool):Bool {
		_shallUpdateChildren = value;
		return value;
	}

	public var file(get, set):FileLocation;
	private function get_file():FileLocation {
		return _file;
	}

	private function set_file(value:FileLocation):FileLocation {
		_file = value;
		return value;
	}

	public var isHidden(get, never):Bool;
	private function get_isHidden():Bool {
		return _isHidden;
	}

	public var isRoot(get, set):Bool;
	private function get_isRoot():Bool {
		return _isRoot;
	}

	private function set_isRoot(value:Bool):Bool {
		_isRoot = value;
		return value;
	}

	public var isSourceFolder(get, set):Bool;
	private function get_isSourceFolder():Bool {
		return _isSourceFolder;
	}

	private function set_isSourceFolder(value:Bool):Bool {
		_isSourceFolder = value;
		return value;
	}

	public var name(get, set):String;
	private function get_name():String {
		if (isRoot && _defaultName != null) {
			return _defaultName;
		} else if (file != null && _shallUpdateChildren) {
			return Std.string(file.fileBridge.name);
		} else if (_defaultName == null && projectReference != null) {
			return projectReference.name;
		} else {
			return _defaultName;
		}
	}

	private function set_name(value:String):String {
		_defaultName = value;
		return value;
	}

	public var defaultName(get, set):String;
	private function get_defaultName():String {
		return _defaultName;
	}

	private function set_defaultName(value:String):String {
		_defaultName = value;
		return value;
	}

	public var children(get, set):Array<Dynamic>;
	private function get_children():Array<Dynamic> {
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && _children == null && _shallUpdateChildren) {
			updateChildren();
		}
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && !AS3.as(file.fileBridge.isDirectory, Bool)) {
			_children = null;
		}

		return _children;
	}

	private function set_children(value:Array<Dynamic>):Array<Dynamic> {
		_children = value;
		return value;
	}

	public var nativePath(get, never):String;
	private function get_nativePath():String {
		if (file == null) {
			return null;
		}
		return Std.string(file.fileBridge.nativePath);
	}

	public var isWorking(get, set):Bool;
	private function set_isWorking(value:Bool):Bool {
		_isWorking = value;
		return value;
	}

	private function get_isWorking():Bool {
		return _isWorking;
	}

	public var isDeleting(get, set):Bool;
	private function set_isDeleting(value:Bool):Bool {
		_isDeleting = value;
		return value;
	}

	private function get_isDeleting():Bool {
		return _isDeleting;
	}

	public var sourceController(get, set):ISourceControlProvider;
	private function get_sourceController():ISourceControlProvider {
		return _sourceController;
	}

	private function set_sourceController(value:ISourceControlProvider):ISourceControlProvider {
		if (_sourceController == value) {
			return value;
		}
		_sourceController = value;

		if (children == null) {
			return value;
		}
		for (i in 0...children.length) {
			Reflect.setField(children[i], 'sourceController', value);
		}
		return value;
	}

	public function sortChildren():Void {
		_children.sortOn('name', Array.CASEINSENSITIVE);
	}

	public function updateChildren():Void {
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			return;
		}

		if (projectReference != null) {
			if (projectReference.showHiddenPaths) {
				_isHidden = AS3.as(projectReference.hiddenPaths.some(function(item:FileLocation, index:Int, arr:Array<FileLocation>):Bool {
											return nativePath == Std.string(item.fileBridge.nativePath);
										}), Bool);
			} else {
				_isHidden = false;
			}
		}

		if (!AS3.as(file.fileBridge.isDirectory, Bool)) {
			return;
		}

		var directoryListing:Array<Dynamic> = file.fileBridge.getDirectoryListing();
		if (directoryListing.length == 0 && !AS3.as(file.fileBridge.isDirectory, Bool)) {
			_children = null;
			return;
		} else {
			_children = [];
		}

		var fw:FileWrapper;
		var directoryListingCount:Int = directoryListing.length;

		for (i in 0...directoryListingCount) {
			var currentDirectory:Dynamic = directoryListing[i];

			if (AS3.as(Reflect.field(currentDirectory, 'isHidden'), Bool)) {
				continue;
			}

			if (projectReference.showHiddenPaths) {
				fw = new FileWrapper(new FileLocation(AS3.string(Reflect.field(currentDirectory, 'nativePath'))), false, projectReference, _shallUpdateChildren);
				fw.sourceController = _sourceController;
				_children.push(fw);
			} else {
				var currentIsHidden:Bool = projectReference != null && AS3.as(projectReference.hiddenPaths.some(function(item:FileLocation, index:Int, arr:Array<FileLocation>):Bool {
									return Reflect.field(currentDirectory, 'nativePath') == item.fileBridge.nativePath;
								}), Bool);

				if (!currentIsHidden) {
					fw = new FileWrapper(new FileLocation(AS3.string(Reflect.field(currentDirectory, 'nativePath'))), false, projectReference, _shallUpdateChildren);
					fw.sourceController = _sourceController;
					_children.push(fw);
				}
			}
		}
	}

	public function containsFile(file:FileLocation):Bool {
		if (file.fileBridge.nativePath.indexOf(nativePath) == 0) {
			return true;
		}
		return false;
	}

}