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
package actionScripts.impls;

import actionScripts.interfaces.IHelperMoonshineBridge;
import actionScripts.utils.MSDKIdownloadUtil;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.SDKTypes;

class IHelperMoonshineBridgeImp implements IHelperMoonshineBridge {

	public function isDefaultSDKPresent():Bool {
		return AS3.as(UtilsCore.isDefaultSDKAvailable(), Bool);
	}

	public function isFlexSDKAvailable():Dynamic {
		return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEX);
	}

	public function isFlexJSSDKAvailable():Dynamic {
		return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEXJS);
	}

	public function isRoyaleSDKAvailable():Dynamic {
		return SDKUtils.checkSDKTypeInSDKList(SDKTypes.ROYALE);
	}

	public function isFeathersSDKAvailable():Dynamic {
		return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FEATHERS);
	}

	public function isJavaPresent():Bool {
		return AS3.as(UtilsCore.isJavaForTypeaheadAvailable(), Bool);
	}

	public function isAntPresent():Bool {
		return AS3.as(UtilsCore.isAntAvailable(), Bool);
	}

	public function isMavenPresent():Bool {
		return AS3.as(UtilsCore.isMavenAvailable(), Bool);
	}

	public function isSVNPresent():Bool {
		return AS3.as(UtilsCore.isSVNPresent(), Bool);
	}

	public function isGitPresent():Bool {
		return AS3.as(UtilsCore.isGitPresent(), Bool);
	}

	public function runOrDownloadSDKInstaller():Void {
		MSDKIdownloadUtil.getInstance().runOrDownloadSDKInstaller();
	}

	private var _playerglobalExists:Bool = false;

	public var playerglobalExists(get, set):Bool;
	private function get_playerglobalExists():Bool {
		return _playerglobalExists;
	}

	private function set_playerglobalExists(value:Bool):Bool {
		_playerglobalExists = value;
		return value;
	}

	public function new() {}

}