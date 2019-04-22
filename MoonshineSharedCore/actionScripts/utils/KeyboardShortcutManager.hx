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
package actionScripts.utils;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.MenuEvent;
import actionScripts.events.ShortcutEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.KeyboardShortcut;
import actionScripts.valueObjects.ProjectVO;

class KeyboardShortcutManager {

	private static var _instance:KeyboardShortcutManager;

	private var stage:DisplayObject;
	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var model:IDEModel = IDEModel.getInstance();
	private var pendingEvent:String;
	private var lookup:Dynamic = {};
	private var lookupMenuType:Dynamic = {};

	public function new(block:KeyboardShortcutManagerBlocker) {
		stage = IDEModel.getInstance().mainView.stage;
		if (stage != null) {
			init();
		} else {
			IDEModel.getInstance().mainView.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
	}

	private function addedToStageHandler(e:Event):Void {
		e.target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		stage = Reflect.field(e.target, 'stage');
		init();
	}

	private function init():Void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
	}

	public function stopEvent(event:String, data:Dynamic = null):Void {
		if (pendingEvent != null && pendingEvent == event) {
			clearPendingEvent();
		}
		dispatch(event, data);
	}

	private function markEventAsPending(event:String):Void {
		// Since Air Default windows may or maynot disptach Event.SELECT for
		// shortcuts we will use this pendingEvent system to delay the event
		// one frame
		pendingEvent = event;
		stage.addEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
	}

	private function dispatchPendingEvent(e:Event):Void {
		var event:String = pendingEvent;
		clearPendingEvent();
		dispatch(event);
	}

	private function dispatch(event:String, data:Dynamic = null):Void {
		if (event != null &&
			dispatcher.dispatchEvent(new ShortcutEvent(
					ShortcutEvent.SHORTCUT_PRE_FIRED, false, true, event))) {
			dispatcher.dispatchEvent((AS3.as(data, Bool)) ? new MenuEvent(event, false, false, data) : new Event(event));
		}
	}

	private function clearPendingEvent():Void {
		stage.removeEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
		pendingEvent = null;
	}

	private function keyDownHandler(e:KeyboardEvent):Void {
		if (e.keyCode == 0) {
			return;
		}// omit all modifier only requests

		var event:String = AS3.string(Reflect.field(lookup, getKeyConfigFromEvent(e)));
		if (event != null && isValidToDispatchAgainstActiveProject(event)) {
			e.stopImmediatePropagation();
			e.preventDefault();
			markEventAsPending(event);
		}
	}

	public static function getInstance():KeyboardShortcutManager {
		if (_instance == null) {
			_instance = new KeyboardShortcutManager(new KeyboardShortcutManagerBlocker());
		}
		return _instance;
	}

	public function has(shortcut:KeyboardShortcut):Bool {
		return (Reflect.field(lookup, getKeyConfigFromShortcut(shortcut)) != null) ? true : false;
	}

	private function getKeyConfigFromShortcut(shortcut:KeyboardShortcut):String {
		var config:Array<Dynamic> = [];

		if (shortcut.cmdKey || shortcut.ctrlKey) {
			config.push('C');
		}
		if (shortcut.altKey) {
			config.push('A');
		}
		if (shortcut.shiftKey) {
			config.push('S');
		}
		config.push(shortcut.keyCode);

		return config.join(' ');
	}

	private function getKeyConfigFromEvent(e:KeyboardEvent):String {
		var config:Array<Dynamic> = [];
		if (e.ctrlKey || e.keyCode == 22) {
			// keycode == 22 - CHECK COMMAND KEY VALUE FOR MACOS
			config.push('C');
		}
		if (e.altKey) {
			config.push('A');
		}
		if (e.shiftKey) {
			config.push('S');
		}
		config.push(e.keyCode);
		return config.join(' ');
	}

	private function isValidToDispatchAgainstActiveProject(event:String):Bool {
		if (model.activeProject == null) {
			return true;
		}
		if (Reflect.field(lookupMenuType, event) == null) {
			return true;
		}

		var project:ProjectVO = model.activeProject;
		if (Std.is(project, AS3ProjectVO)) {
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			var tmpProjectsType:Array<String> = as3Project.menuType.split(',');
			for (i in ...tmpProjectsType.length) {
				if (tmpProjectsType[i] == '') {
					continue;
				}
				if (Lambda.indexOf(AS3.asArray(Reflect.field(lookupMenuType, event)), tmpProjectsType[i]) != -1) {
					return true;
				}
			}
		}

		return false;
	}

	public function activate(shortcut:KeyboardShortcut, enableTypes:Array<Dynamic> = null):Bool {
		if (!has(shortcut)) {
			Reflect.setField(lookup, getKeyConfigFromShortcut(shortcut), shortcut.event);
			Reflect.setField(lookupMenuType, shortcut.event, enableTypes);
			return true;
		}
		return false;
	}

	public function deactivate(shortcut:KeyboardShortcut):Bool {
		Reflect.deleteField(lookup, getKeyConfigFromShortcut(shortcut));
		return true;
	}

}

class KeyboardShortcutManagerBlocker {

}