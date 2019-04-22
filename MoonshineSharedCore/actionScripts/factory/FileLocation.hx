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
package actionScripts.factory;

import flash.events.Event;
import flash.events.EventDispatcher;
import actionScripts.controllers.DataAgent;
import actionScripts.interfaces.IFileBridge;
import actionScripts.valueObjects.URLDescriptorVO;

@:meta(Bindable())class FileLocation extends EventDispatcher {

	public var fileBridge:IFileBridge;

	public function new(path:String = null, isURL:Bool = false) {
		super();
		// ** IMPORTANT **
		var obj:Dynamic = BridgeFactory.getFileInstanceObject();
		fileBridge = Type.createInstance(obj, []);
		if (path == null) {
			return;
		}

		if (isURL) {
			fileBridge.url = path;
		} else {
			fileBridge.nativePath = path;
		}
	}

	public function resolvePath(path:String):FileLocation {
		return fileBridge.resolvePath(path);
	}

	public var name(get, never):String;
	private function get_name():String {
		return Std.string(fileBridge.name);
	}

	//--------------------------------------------------------------------------
	//
	//  WEB METHODS
	//
	//--------------------------------------------------------------------------

	public function deleteFileOrDirectory():Void {
		var tmpLoader:DataAgent = new DataAgent(URLDescriptorVO.FILE_REMOVE, onSuccessDelete, onFault, {
			'path': fileBridge.nativePath
		}, DataAgent.POSTEVENT);
	}

	private function onSuccessDelete(value:Dynamic, message:String = null):Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onFault(message:String = null):Void {
		dispatchEvent(new Event(Event.CLOSE));
	}

}