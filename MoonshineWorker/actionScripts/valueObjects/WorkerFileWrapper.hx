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

import flash.filesystem.File;

@:meta(Bindable())class WorkerFileWrapper {

	public var projectReference:Dynamic;
	public var searchCount:Int = 0;
	public var lineNumbersWithRange:Array<Dynamic>;
	public var fileReference:String;

	private var _file:File;
	private var _children:Array<Dynamic> = [];

	private var _isRoot:Bool = false;
	private var _defaultName:String;
	private var _isWorking:Bool = false;
	private var _isDeleting:Bool = false;
	private var _shallUpdateChildren:Bool = false;
	private var _isShowAsLineNumber:Bool = false;
	private var _lineText:String;

	public var shallUpdateChildren(get, set):Bool;
	private function set_shallUpdateChildren(value:Bool):Bool {
		_shallUpdateChildren = value;
		return value;
	}

	private function get_shallUpdateChildren():Bool {
		return _shallUpdateChildren;
	}

	public function new(file:File, isRoot:Bool = false, projectRef:Dynamic = null, shallUpdateChildren:Bool = true) {
		_file = file;
		_isRoot = isRoot;
		_shallUpdateChildren = shallUpdateChildren;
		projectReference = projectRef;

		if (isRoot && AS3.as(projectRef, Bool) && AS3.as(Reflect.field(projectRef, 'name'), Bool)) {
			name = AS3.string(Reflect.field(projectRef, 'name'));
		} else if (file != null) {
			name = Std.string(file.name);
		}

		MoonshineWorker.FILES_COUNT++;

		// store filelocation reference for later
		// search through Find Resource menu option
		if (_file != null && _shallUpdateChildren) {
			updateChildren();
		}
	}

	public function updateChildren():Void {
		if (!AS3.as(file.isDirectory, Bool)) {
			return;
		}

		var directoryListing:Array<Dynamic> = file.getDirectoryListing();
		if (directoryListing.length == 0 && !AS3.as(file.isDirectory, Bool)) {
			_children = null;
			return;
		} else {
			_children = [];
		}
		var fw:WorkerFileWrapper;
		var directoryListingCount:Int = directoryListing.length;

		for (i in 0...directoryListingCount) {
			var currentDirectory:Dynamic = directoryListing[i];
			/*var hasHiddenPath:Boolean = projectReference.hiddenPaths.some(function(item:Object, index:int, arr:Vector.<Object>):Boolean
			{
				return currentDirectory.nativePath == item.fileBridge.nativePath;
			});*/

			if (!AS3.as(Reflect.field(currentDirectory, 'isHidden'), Bool)) {
				fw = new WorkerFileWrapper(new File(Reflect.field(currentDirectory, 'nativePath')), false, projectReference, _shallUpdateChildren);
				_children.push(fw);
			}
		}
	}

	public function containsFile(file:File):Bool {
		if (file.nativePath.indexOf(nativePath) == 0) {
			return true;
		}
		return false;
	}

	public var file(get, set):File;
	private function get_file():File {
		return _file;
	}

	private function set_file(v:File):File {
		_file = v;
		return v;
	}

	public var isRoot(get, set):Bool;
	private function get_isRoot():Bool {
		return _isRoot;
	}

	private function set_isRoot(value:Bool):Bool {
		_isRoot = value;
		return value;
	}

	public var name(get, set):String;
	private function get_name():String {
		if (isRoot && _defaultName != null) {
			return _defaultName;
		} else if (file != null && _shallUpdateChildren) {
			return Std.string(file.name);
		} else if (_defaultName == null && AS3.as(projectReference, Bool)) {
			return AS3.string(Reflect.field(projectReference, 'name'));
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

	private function set_defaultName(v:String):String {
		_defaultName = v;
		return v;
	}

	public var children(get, set):Array<Dynamic>;
	private function get_children():Array<Dynamic> {
		if (_children == null && _shallUpdateChildren && !isShowAsLineNumber) {
			updateChildren();
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
		return Std.string(file.nativePath);
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

	public var isShowAsLineNumber(get, set):Bool;
	private function get_isShowAsLineNumber():Bool {
		return _isShowAsLineNumber;
	}

	private function set_isShowAsLineNumber(value:Bool):Bool {
		_isShowAsLineNumber = value;
		if (_isShowAsLineNumber) {
			children = null;
		}
		return value;
	}

	public var lineText(get, set):String;
	private function set_lineText(value:String):String {
		_lineText = value;
		return value;
	}

	private function get_lineText():String {
		return _lineText;
	}

}