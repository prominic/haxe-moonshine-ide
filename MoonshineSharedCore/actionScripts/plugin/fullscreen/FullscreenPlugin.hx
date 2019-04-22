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
package actionScripts.plugin.fullscreen;

import flash.display.StageDisplayState;
import flash.events.Event;
import mx.core.FlexGlobals;
import actionScripts.plugin.PluginBase;
import actionScripts.valueObjects.ConstantsCoreVO;

class FullscreenPlugin extends PluginBase {

	public static inline var EVENT_FULLSCREEN:String = 'fullscreenEvent';

	override private function get_name():String {
		return 'Fullscreen Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Show edit in fullscreen. Esc exits.';
	}

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(EVENT_FULLSCREEN, handleToggleFullscreen);
	}

	private function handleToggleFullscreen(event:Event):Void {
		var stage:Dynamic = FlexGlobals.topLevelApplication.stage;
		if (Reflect.field(stage, 'displayState') == StageDisplayState.NORMAL) {
			Reflect.setField(stage, 'displayState', StageDisplayState.FULL_SCREEN_INTERACTIVE);
		} else {
			Reflect.setField(stage, 'displayState', StageDisplayState.NORMAL);
		}
	}

	public function new() {
		super();
	}

}