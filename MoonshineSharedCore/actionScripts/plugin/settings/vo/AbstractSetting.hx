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
package actionScripts.plugin.settings.vo;

import flash.errors.Error;
import flash.events.EventDispatcher;
import mx.core.IVisualElement;

class AbstractSetting extends EventDispatcher implements ISetting {

	public static inline var PATH_SELECTED:String = 'pathSelected';
	public static inline var MESSAGE_CRITICAL:String = 'MESSAGE_CRITICAL';
	public static inline var MESSAGE_IMPORTANT:String = 'MESSAGE_IMPORTANT';
	public static inline var MESSAGE_NORMAL:String = 'MESSAGE_NORMAL';

	private var hasPendingChanges:Bool = false;
	private var pendingChanges:Dynamic;
	private var message:String;
	private var messageType:String;

	private var _name:String;

	@:meta(Bindable())
	public var name(get, set):String;
	private function get_name():String {
		return _name;
	}

	private function set_name(v:String):String {
		_name = v;

		if (AS3.as(provider, Bool)) {
			validateName();
		}
		return v;
	}

	private var _label:String;

	@:meta(Bindable())
	public var label(get, set):String;
	private function get_label():String {
		return _label;
	}

	private function set_label(v:String):String {
		_label = v;
		return v;
	}

	public var renderer(get, never):IVisualElement;
	private function get_renderer():IVisualElement {
		return null;
	}

	private var _provider:Dynamic;

	public var provider(get, set):Dynamic;
	private function get_provider():Dynamic {
		return _provider;
	}

	private function set_provider(v:Dynamic):Dynamic {
		_provider = v;

		if (name != null) {
			validateName();
		}
		return v;
	}

	private var _defaultValue:String;

	private var defaultValue(get, set):String;
	private function get_defaultValue():String {
		return _defaultValue;
	}

	private function set_defaultValue(v:String):String {
		_defaultValue = v;

		return v;
	}

	// Used to save to disc — if you want to serialize do so here.
	@:meta(Bindable())
	public var stringValue(get, set):String;
	private function get_stringValue():String {
		//if(pendingChanges) return pendingChanges.toString();
		return Std.string(Std.string(getSetting()));
	}

	private function set_stringValue(v:String):String {
		setPendingSetting(v);
		return v;
	}

	// Not-directly used to save to disk — if we want we can use it for additional purpose.
	private var _additionalValue:Dynamic;

	@:meta(Bindable())
	public var additionalValue(get, set):Dynamic;
	private function get_additionalValue():Dynamic {
		return _additionalValue;
	}

	private function set_additionalValue(v:Dynamic):Dynamic {
		_additionalValue = v;
		return v;
	}

	// Fetches default values from the provider
	private function getSetting():Dynamic {
		if (pendingChanges != null) {
			return pendingChanges;
		}
		return (Reflect.field(provider, name) != null) ? Reflect.field(provider, name) : '';
	}

	private function validateName():Void {
		if (!hasProperty()) {
			throw new Error('Property ' + name + ' not found on settings object ' + provider + '.');
		}
	}

	private function hasProperty(names:Array<Dynamic> = null):Bool {
		names = (names != null) ? names : [name];

		if (!AS3.as(provider, Bool)) {
			return false;
		}
		for (n_ in names) {
			var n:String = cast n_;
			if (!Reflect.hasField(provider, Std.string(n))) {
				return false;
			}
		}
		return true;

	}

	// Commits changes back to provider
	private function setPendingSetting(v:Dynamic):Void {
		hasPendingChanges = true;
		pendingChanges = v;
	}

	public function valueChanged():Bool {
		return (hasPendingChanges && defaultValue != pendingChanges);
	}

	public function commitChanges():Void {
		if (!hasProperty() || !hasPendingChanges) {
			return;
		}

		Reflect.setField(provider, name, pendingChanges);
		hasPendingChanges = false;
	}

	public function new() {
		super();
	}

}