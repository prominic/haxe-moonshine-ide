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
package actionScripts.utils;

import flash.events.Event;
import flash.events.EventDispatcher;
import mx.controls.Alert;
import mx.events.CloseEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.help.HelpPlugin;

@:meta(Event(name = 'SDK_SAVED', type = 'flash.events.Event'))
@:meta(Event(name = 'SDK_SAVE_CANCELLED', type = 'flash.events.Event'))
class NoSDKNotifier extends EventDispatcher {

	public static inline var SDK_SAVED:String = 'SDK_SAVED';
	public static inline var SDK_SAVE_CANCELLED:String = 'SDK_SAVE_CANCELLED';

	private static var instance:NoSDKNotifier;
	private static var isShowing:Bool = false;

	private var isJavaCheckingRequires:Bool = false;

	public static function getInstance():NoSDKNotifier {
		if (instance == null) {
			instance = new NoSDKNotifier();
		}
		return instance;
	}

	public function notifyNoFlexSDK(isJavaCheckingRequires:Bool = true):Void {
		if (isShowing) {
			return;
		}

		var model:IDEModel = IDEModel.getInstance();
		if ((model.userSavedSDKs.length != 0) && (Reflect.getProperty(model.userSavedSDKs, Std.string(0)).status == SDKUtils.BUNDLED)) {
			SDKUtils.setDefaultSDKByBundledSDK();
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, Reflect.getProperty(model.userSavedSDKs, Std.string(0))));
			return;
		}

		Alert.noLabel = 'Do it later';
		Alert.yesLabel = 'Fix this now';
		Alert.buttonWidth = 110;

		Alert.show('Moonshine detected no default SDK set!', 'No SDK Found', Alert.YES | Alert.NO, null, alertClosed);
		this.isJavaCheckingRequires = isJavaCheckingRequires;
	}

	private function alertClosed(event:CloseEvent):Void {
		Alert.buttonWidth = 65;
		Alert.noLabel = 'No';
		Alert.yesLabel = 'Yes';

		if (event.detail == Alert.YES) {
			GlobalEventDispatcher.getInstance().dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.as3project.mxmlc::MXMLCPlugin'));
		}

		if (isJavaCheckingRequires) {
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(HelpPlugin.EVENT_ENSURE_JAVA_PATH));
		}
		isShowing = false;
	}

	public function new() {
		super();
	}

}