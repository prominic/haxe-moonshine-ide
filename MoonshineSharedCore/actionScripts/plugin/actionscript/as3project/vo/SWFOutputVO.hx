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
package actionScripts.plugin.actionscript.as3project.vo;

import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SerializeUtil;
import actionScripts.utils.TextUtil;
import actionScripts.utils.UtilsCore;

class SWFOutputVO {

	public static inline var PLATFORM_AIR:String = 'AIR';
	public static inline var PLATFORM_MOBILE:String = 'AIR Mobile';
	public static inline var PLATFORM_DEFAULT:String = 'Flash Player';

	public var disabled:Bool = false;
	public var path:FileLocation;
	public var frameRate:Float = 24;
	public var swfVersion:Int = 10;
	public var swfMinorVersion:Int = 0;
	public var width:Int = 100;
	public var height:Int = 100;
	public var platform:String;

	// TODO What is this? It's present as <movie input="" /> in FD .as3proj
	/** Not sure what this is */
	public var input:String = '';

	/** Background color */
	public var background:Int = 0;

	public function toString():String {
		return '[SWFOutput path=\'' + path.fileBridge.nativePath + '\' frameRate=\'' + frameRate + '\' swfVersion=\'' + swfVersion + '\' width=\'' + width + '\' height=\'' + height + '\' background=\'#' + backgroundColorHex + '\']';
	}

	public var backgroundColorHex(get, never):String;
	private function get_backgroundColorHex():String {
		return TextUtil.padLeft(Std.string(as3hx.Compat.toString(background, 16).toUpperCase()), 6);
	}

	public function parse(output:FastXMLList, project:AS3ProjectVO):Void {
		var params:FastXMLList = output.descendants('movie');
		disabled = SerializeUtil.deserializeBoolean(params.att.disabled);
		path = project.folderLocation.resolvePath(UtilsCore.fixSlashes(Std.string(params.att.path)));
		frameRate = as3hx.Compat.parseFloat(params.att.fps);
		width = AS3.int(params.att.width);
		height = AS3.int(params.att.height);
		background = AS3.int('0x' + Std.string(params.att.background).substr(1));
		input = Std.string(params.att.input);
		platform = Std.string(params.att.platform);

		// we need to do a little more than just setting SWF version value
		// from config.xml.
		// To make thing properly works without much headache, we'll
		// check if the project does uses any specific SDK, if exists then we'll
		// continue using the config.xml value.
		// If no specific SDK is in use, we'll check if any gloabla SDK is set in Moonshine,
		// if exists then we'll update SWF version by it's version value.
		// If no global SDK exists, then just copy the config.xml value
		if (project.buildOptions.customSDK == null && IDEModel.getInstance().defaultSDK != null) {
			swfVersion = SDKUtils.getSdkSwfMajorVersion(null);
		} else {
			swfVersion = AS3.int(params.att.version);
		}
	}

	/*
		Returns XML representation of this class.
		If root is set you will get relative paths
	*/
	public function toXML(folder:FileLocation):FastXML {
		var output:FastXML = FastXML.parse('<output/>');

		var pathStr:String = Std.string(path.fileBridge.nativePath);
		if (folder != null) {
			pathStr = Std.string(folder.fileBridge.getRelativePath(path));
		}

		// in case parsing relative path returns null
		// particularly in scenario when "path" is outside folder
		// of "folder"
		if (pathStr == null) {
			pathStr = Std.string(path.fileBridge.nativePath);
		}

		var outputPairs:Dynamic = {
			'disabled': SerializeUtil.serializeBoolean(disabled),
			'fps': frameRate,
			'path': pathStr,
			'width': width,
			'height': height,
			'version': swfVersion,
			'background': '#' + backgroundColorHex,
			'input': input,
			'platform': platform
		};

		output.node.appendChild(SerializeUtil.serializePairs(outputPairs, FastXML.parse('<movie/>')));

		return output;
	}

	public function new() {}

}