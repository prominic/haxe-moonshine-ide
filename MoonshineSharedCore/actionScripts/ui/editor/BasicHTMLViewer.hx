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
package actionScripts.ui.editor;

import mx.containers.Canvas;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.ui.IContentWindow;
import actionScripts.valueObjects.ConstantsCoreVO;

/*
	Simple chrome-less browser, used for binary file viewing (images etc)
	TODO: Make sure it unloads properly!
*/
class BasicHTMLViewer extends Canvas implements IContentWindow {

	@:meta(Bindable())public var file:FileLocation;

	override private function get_label():String {
		if (file != null) {
			return Std.string(file.fileBridge.name);
		}
		return 'Image';
	}

	public var longLabel(get, never):String;
	private function get_longLabel():String {
		if (file != null) {
			return Std.string(file.fileBridge.nativePath);
		}
		return 'Image';
	}

	public function save():Void {}

	public function isChanged():Bool {
		return false;
	}

	public function isEmpty():Bool {
		return true;
	}

	public function open(file:FileLocation):Void {
		this.file = file;
	}

	override private function createChildren():Void {
		super.createChildren();
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			addChild(IDEModel.getInstance().flexCore.getHTMLView(Std.string(file.fileBridge.url)));
		}
	}

	public function new() {
		super();
	}

}