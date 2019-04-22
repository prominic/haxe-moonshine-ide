////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects;

import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

class ResourceVO {

	public var name:String;
	public var sourceWrapper:FileWrapper;

	private var _resourcePath:String;
	private var _resourceExtension:String;
	private var _projectName:String;

	private var sourcePath:String;

	public function new(_name:String, _sourceWrapper:FileWrapper) {
		name = _name;
		resourcePath = Std.string(_sourceWrapper.file.fileBridge.nativePath);
		_resourceExtension = Std.string(_sourceWrapper.file.fileBridge.extension);
		sourceWrapper = _sourceWrapper;
	}

	public var resourcePath(get, set):String;
	private function set_resourcePath(value:String):String {
		for (project in IDEModel.getInstance().projects) {
			var folderPath:String = AS3.string(Reflect.field(project, 'folderPath'));
			if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
				folderPath = folderPath.substr(Reflect.field(project, 'folderPath').indexOf('?path=') + 7, folderPath.length);
			}
			if (value.indexOf(folderPath) != -1) {
				value = StringTools.replace(value, folderPath, AS3.string(Reflect.field(project, 'name')));
				_resourcePath = value;
				_projectName = AS3.string(Reflect.field(project, 'name'));
				var as3Project:AS3ProjectVO = AS3.as(project, AS3ProjectVO);
				if (as3Project != null) {
					sourcePath = Std.string(as3Project.sourceFolder.fileBridge.nativePath.replace(folderPath, ''));
				}

				break;
			}
		}
		return value;
	}

	private function get_resourcePath():String {
		return _resourcePath;
	}

	public var resourceExtension(get, never):String;
	private function get_resourceExtension():String {
		return _resourceExtension;
	}

	public var resourcePathWithoutRoot(get, never):String;
	private function get_resourcePathWithoutRoot():String {
		if (sourcePath != null && _projectName != null) {
			var resourcePathWithoutRoot:String = StringTools.replace(_resourcePath, _projectName, '');
			return StringTools.replace(resourcePathWithoutRoot, sourcePath + sourceWrapper.file.fileBridge.separator, '');
		}

		return _resourcePath;
	}

}