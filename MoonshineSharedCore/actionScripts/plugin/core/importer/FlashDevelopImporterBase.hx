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
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;

class FlashDevelopImporterBase extends EventDispatcher {

	public function new(target:IEventDispatcher = null) {
		super(target);
	}

	private static function parsePaths(paths:FastXMLList, v:Array<FileLocation>, p:ProjectVO, attrName:String = 'path'):Void {
		for (pathXML in paths) {
			var path:String = Std.string(pathXML.descendants('attribute')(attrName));

			if (path != null) {
				// file separator fix
				path = UtilsCore.fixSlashes(path);
				var f:FileLocation = p.folderLocation.resolvePath(path);

				if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
					f.fileBridge.canonicalize();
				}
				v.push(f);
			}
		}
	}

	private static function parsePathString(paths:FastXMLList, v:Array<String>, p:ProjectVO, attrName:String = 'path'):Void {
		for (pathXML in paths) {
			var path:String = Std.string(pathXML.descendants('attribute')(attrName));
			if (path != null) {
				v.push(path);
			}
		}
	}

}