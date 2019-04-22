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
package actionScripts.plugin.findreplace.view;

import flash.events.Event;
import flash.events.FocusEvent;
import spark.components.RichText;
import spark.components.TextInput;

/*
	Original skin by Andy Mcintosh
	http://github.com/andymcintosh/SparkComponents/
*/
class PromptTextInput extends TextInput {

	@:meta(SkinPart(required = 'true'))
	public var promptView:RichText;
	public var marginRight:Int = 4;

	private var _prompt:String;

	private var promptChanged:Bool = false;

	@:meta(Bindable())
	override private function get_prompt():String {
		return _prompt;
	}

	override private function set_prompt(v:String):String {
		_prompt = v;
		promptChanged = true;

		invalidateProperties();
		return v;
	}

	@:meta(Bindable())
	override private function set_text(val:String):String {
		super.text = val;

		updatePromptVisiblity();
		return val;
	}

	override private function get_text():String {
		return Std.string(super.text);
	}

	override private function commitProperties():Void {
		super.commitProperties();

		if (promptChanged) {
			if (promptView != null) {
				promptView.text = prompt;
			}

			promptChanged = false;
		}
	}

	override private function partAdded(partName:String, instance:Dynamic):Void {
		super.partAdded(partName, instance);

		if (partName == 'textDisplay') {
			instance.addEventListener(FocusEvent.FOCUS_IN, updatePromptVisiblity);
			instance.addEventListener(FocusEvent.FOCUS_OUT, updatePromptVisiblity);
			instance.addEventListener(Event.CHANGE, updatePromptVisiblity);
			Reflect.setField(instance, 'styleName', 'uiTextWhite');
			Reflect.setField(instance, 'right', marginRight);
		}

		if (instance == promptView) {
			promptView.text = prompt;
		}
	}

	override private function partRemoved(partName:String, instance:Dynamic):Void {
		super.partRemoved(partName, instance);

		if (partName == 'textDisplay') {
			instance.removeEventListener(FocusEvent.FOCUS_IN, updatePromptVisiblity);
			instance.removeEventListener(FocusEvent.FOCUS_OUT, updatePromptVisiblity);
			instance.removeEventListener(Event.CHANGE, updatePromptVisiblity);
		}
	}

	private function updatePromptVisiblity(event:Event = null):Void {
		if (promptView == null) {
			return;
		}

		if (text != '') {
			promptView.visible = false;
		} else {
			promptView.visible = true;
		}
	}

	public function new() {
		super();
	}

}