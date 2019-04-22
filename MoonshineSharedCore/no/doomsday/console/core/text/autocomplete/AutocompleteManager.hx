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
package no.doomsday.console.core.text.autocomplete;

import flash.errors.Error;
import no.doomsday.console.core.text.TextUtils;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.ui.Keyboard;

/**
 * ...
 * @author Andreas Rønning
 * Heavily based on Ali Mills' work at http://www.asserttrue.com/articles/2006/04/09/actionscript-projects-in-flex-builder-2-0
 */
class AutocompleteManager {

	private var txt:String;
	public var dict:AutocompleteDictionary;
	public var scopeDict:AutocompleteDictionary;
	private var paused:Bool = false;
	private var _targetTextField:TextField;
	public var suggestionActive:Bool = false;
	public var ready:Bool = false;

	public function new(targetTextField:TextField) {
		this.targetTextField = targetTextField;
	}

	public function setDictionary(newDict:AutocompleteDictionary):Void {
		dict = newDict;
		ready = true;
	}

	private function changeListener(e:Event):Void {
		suggestionActive = false;
		if (!paused) {
			complete();
		}
	}

	private function keyDownListener(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.BACKSPACE || e.keyCode == Keyboard.DELETE) {
			paused = true;
		} else {
			paused = false;
		}
	}

	public function complete():Void {
		//we only complete single words, so start caret is the beginning of the word the caret is currently in
		var firstIndex:Int = TextUtils.getFirstIndexOfWordAtCaretIndex(_targetTextField);
		var str:String = _targetTextField.text.substr(firstIndex, _targetTextField.caretIndex);

		var strParts:Array<String> = str.split('');
		var suggestion:String;
		if (scopeDict == null || firstIndex < 1) {
			suggestion = dict.getSuggestion(cast strParts);
		} else {
			suggestion = scopeDict.getSuggestion(cast strParts);
		}
		suggestionActive = false;
		if (suggestion.length > 0) {
			//_targetTextField.text = str;
			_targetTextField.appendText(suggestion);
			//TODO: Make autocomplete only work within the word currently at the caret
			_targetTextField.setSelection(_targetTextField.caretIndex, _targetTextField.text.length);
			suggestionActive = true;
		}
	}

	public function isKnown(str:String, includeScope:Bool = false, includeCommands:Bool = true):Bool {
		if (scopeDict != null && includeScope) {
			if (scopeDict.contains(str)) {
				return true;
			}
		}
		if (includeCommands) {
			return dict.contains(str);
		}
		return false;
	}

	public var targetTextField(get, set):TextField;
	private function get_targetTextField():TextField {
		return _targetTextField;
	}

	private function set_targetTextField(value:TextField):TextField {
		try {
			_targetTextField.removeEventListener(Event.CHANGE, changeListener);
			_targetTextField.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		} catch (e:Error) {}{
			_targetTextField = value;
			_targetTextField.addEventListener(Event.CHANGE, changeListener);
			_targetTextField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		}
		return value;
	}

	public function correctCase(str:String):String {
		try {
			return dict.correctCase(str);
		} catch (e:Error) {
			if (scopeDict != null) {
				return scopeDict.correctCase(str);
			}
		}
		throw new Error('No correct case found');
	}

}