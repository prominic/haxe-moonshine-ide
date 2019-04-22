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
package actionScripts.plugin.core.importer;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import actionScripts.factory.FileLocation;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.valueObjects.ProjectVO;

class FlashBuilderImporterBase extends EventDispatcher {

	private static inline var SEARCH_BACK_COUNT:Int = 5;

	public function new(target:IEventDispatcher = null) {
		super(target);
	}

	private static function parsePaths(paths:FastXMLList, v:Array<FileLocation>, p:ProjectVO, attrName:String = 'path', documentPath:String = null):Void {
		for (pathXML in paths) {
			var path:String = Std.string(pathXML.descendants('attribute')(attrName));
			var f:FileLocation;
			if (documentPath != null && (path.indexOf('${DOCUMENTS}') != -1)) {
				path = StringTools.replace(path, '${DOCUMENTS}', '');
				path = documentPath + path;
				f = p.folderLocation.resolvePath(path);
			} else if (path.indexOf('${DOCUMENTS}') != -1) {
				// since we didn't found {DOCUMENTS} path in
				// FlashBuilderImporter.readActionScriptSettings(), we take
				// {DOCUMENTS} as p.folderWrapper.parent to make the
				// fileLocation valid, else it'll throw error
				var isParentPathAvailable:Bool = true;
				/* AS3HX WARNING namespace modifier CONFIG::OSX */{
					isParentPathAvailable = checkOSXBookmarked(Std.string(p.folderLocation.fileBridge.parent.fileBridge.nativePath));
				}

				if (isParentPathAvailable) {
					path = StringTools.replace(path, '${DOCUMENTS}', '');
					path = p.folderLocation.fileBridge.parent.fileBridge.nativePath + path;
					f = p.folderLocation.resolvePath(path);
				} else {
					f = p.folderLocation.resolvePath(path);
				}
			} else {
				f = p.folderLocation.resolvePath(path);
			}

			if (f != null && AS3.as(f.fileBridge.exists, Bool)) {
				f.fileBridge.canonicalize();
			}
			if (f != null) {
				v.push(f);
			}
		}
	}

	public static function checkOSXBookmarked(pathValue:String):Bool {
		var tmpBList:Array<String> = ((OSXBookmarkerNotifiers.availableBookmarkedPaths != null)) ? OSXBookmarkerNotifiers.availableBookmarkedPaths.split(',') : cast [];
		if (tmpBList.length >= 1) {
			if (tmpBList[0] == '') {
				tmpBList.shift();
			}// [0] will always blank
			if (tmpBList[0] == 'INITIALIZED') {
				tmpBList.shift();
			}// very first time initialization after Moonshine installation
		}

		if (Lambda.indexOf(tmpBList, pathValue) != -1) {
			return true;
		} else {
			for (j in tmpBList) {
				if (pathValue.indexOf(j) != -1) {
					return true;
				}
			}
		}

		return false;
	}

}