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
package actionScripts.plugin.core.mouse;

import flash.events.Event;
import flash.events.FocusEvent;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.valueObjects.ConstantsCoreVO;

class MouseManagerPlugin extends PluginBase implements IPlugin {

	override private function get_name():String {
		return 'Mouse Manager Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Mouse Manager Plugin. Esc exits.';
	}

	private var lastKnownEditor:TextEditor;
	private var isApplicationDeactivated:Bool = false;

	override public function activate():Void {
		super.activate();

		// we need to watch all the focus change event to
		// track and keep one cursor at a time
		FlexGlobals.topLevelApplication.systemManager.addEventListener(FocusEvent.FOCUS_IN, onCursorUpdated);
		FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);

		// removeElement from FlexGlobals.topLevelApplication do not return focus to TextEditor
		FlexGlobals.topLevelApplication.addEventListener(FlexEvent.UPDATE_COMPLETE, onTopLevelUpdated);
	}

	private function onTopLevelUpdated(event:FlexEvent):Void {
		if (isApplicationDeactivated) {
			return;
		}
		if (lastKnownEditor != null) {
			setFocusToTextEditor(lastKnownEditor, true);
		}
	}

	private function onCursorUpdated(event:FocusEvent):Void {
		// this should handle any non-input type of component focus
		if (!(Std.is(event.target, TextEditor)) && !Reflect.hasField(event.target, 'text') && !Reflect.hasField(event.target, 'selectable')) {
			return;
		}

		if (lastKnownEditor != null && lastKnownEditor != event.target) {
			setFocusToTextEditor(lastKnownEditor, false);
		}

		// we mainly need to manage TextEditor focus
		// since this only differ with general focus cursor
		if (Std.is(event.target, TextEditor)) {
			setFocusToTextEditor(AS3.as(event.target, TextEditor), true);
			lastKnownEditor = AS3.as(event.target, TextEditor);
		} else {
			lastKnownEditor = null;
		}
	}

	private function onApplicationLostFocus(event:Event):Void {
		FlexGlobals.topLevelApplication.stage.removeEventListener(Event.DEACTIVATE, onApplicationLostFocus);
		FlexGlobals.topLevelApplication.stage.addEventListener(Event.ACTIVATE, onApplicationReturnFocus);
		isApplicationDeactivated = true;

		if (lastKnownEditor != null) {
			setFocusToTextEditor(lastKnownEditor, false);
		}
	}

	private function onApplicationReturnFocus(event:Event):Void {
		FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);
		FlexGlobals.topLevelApplication.stage.removeEventListener(Event.ACTIVATE, onApplicationReturnFocus);
		isApplicationDeactivated = false;

		if (lastKnownEditor != null) {
			setFocusToTextEditor(lastKnownEditor, true);
		}
	}

	private function setFocusToTextEditor(editor:TextEditor, value:Bool):Void {
		if (value) {
			editor.setFocus();
		}

		editor.hasFocus = value;
		editor.updateSelection();
	}

	public function new() {
		super();
	}

}