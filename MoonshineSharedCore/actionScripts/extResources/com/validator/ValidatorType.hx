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
/**
 * ValidatorType Component
 * 		field = Need to pass the field ID of different user controls (i.e. TextArea, ComboBox et)
 * 		isEmail = True/Talse - optional - whether email validation is required
 * 		isNumber = True/False - optional - whether number validation is required (i.e. only number data can be entered)
 * 		minLength = Integer value - for minimum character length validation (i.e. 4 digit of zip code)
 * 		maxLength = Integer value - for maximum character length validation (i.e. zip code can't be more than 7 digit)
 * 		fieldToMatch = String - optional - required to check current input string with 'fieldToMatch' string
 * 						(i.e. confirm password need to be checked with the password textbox.text OR any textbox with any string)
 * 		customExp = String - optional - if any custom expression need to be checked then pass the expression string with _
 *
 */
package actionScripts.extResources.com.validator;

class ValidatorType {

	public var validator:Dynamic;
	public var tooLongError:String;
	public var tooShortError:String;

	private var _field:Dynamic;
	private var _isRequired:Bool = false;
	private var _isEmail:Bool = false;
	private var _isNumber:Bool = false;
	private var _fieldToMatch:String;
	private var _minLength:Int = 0;
	private var _maxLength:Int = 0;
	private var _customExp:String;
	private var _fieldName:String;

	/**
	 * CONSTRUCTOR
	 */
	public function new(val:Dynamic, field:Dynamic, fName:String, isRequired:Bool = true, isEmail:Bool = false, isNumber:Bool = false, minLength:Int = -1, maxLength:Int = -1, tooLE:String = null, tooSE:String = null) {
		validator = val;
		tooLongError = tooLE;
		tooShortError = tooSE;
		_field = field;
		_isRequired = isRequired;
		_isEmail = isEmail;
		_isNumber = isNumber;
		_minLength = minLength;
		_maxLength = maxLength;
		_customExp = customExp;
		_fieldName = fName;
	}

	public var field(get, set):Dynamic;
	private function get_field():Dynamic {
		return _field;
	}

	private function set_field(value:Dynamic):Dynamic {
		_field = value;
		return value;
	}

	public var isRequired(get, set):Bool;
	private function get_isRequired():Bool {
		return _isRequired;
	}

	private function set_isRequired(value:Bool):Bool {
		_isRequired = value;
		return value;
	}

	public var isEmail(get, set):Bool;
	private function get_isEmail():Bool {
		return _isEmail;
	}

	private function set_isEmail(value:Bool):Bool {
		_isEmail = value;
		return value;
	}

	public var isNumber(get, set):Bool;
	private function get_isNumber():Bool {
		return _isNumber;
	}

	private function set_isNumber(value:Bool):Bool {
		_isNumber = value;
		return value;
	}

	public var fieldToMatch(get, set):String;
	private function get_fieldToMatch():String {
		return _fieldToMatch;
	}

	private function set_fieldToMatch(value:String):String {
		_fieldToMatch = value;
		return value;
	}

	public var minLength(get, set):Int;
	private function get_minLength():Int {
		return _minLength;
	}

	private function set_minLength(value:Int):Int {
		_minLength = value;
		return value;
	}

	public var maxLength(get, set):Int;
	private function get_maxLength():Int {
		return _maxLength;
	}

	private function set_maxLength(value:Int):Int {
		_maxLength = value;
		return value;
	}

	public var customExp(get, set):String;
	private function get_customExp():String {
		return _customExp;
	}

	private function set_customExp(value:String):String {
		_customExp = value;
		return value;
	}

	public var fieldName(get, set):String;
	private function get_fieldName():String {
		return _fieldName;
	}

	private function set_fieldName(value:String):String {
		_fieldName = value;
		return value;
	}

}