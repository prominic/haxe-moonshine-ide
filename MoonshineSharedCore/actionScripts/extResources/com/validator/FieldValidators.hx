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
package actionScripts.extResources.com.validator;

import flash.display.DisplayObject;
import mx.controls.Alert;
import mx.validators.EmailValidator;
import mx.validators.NumberValidator;
import mx.validators.RegExpValidator;
import mx.validators.StringValidator;
import mx.validators.Validator;
import spark.components.DropDownList;

class FieldValidators {

	private var validatorArr:Array<Dynamic>;
	private var validatorErrorArr:Array<Dynamic>;

	private var FORM_ERROR_MSG(default, never):String = ' is Invalid/Empty.\nPlease correct so we can save your data.';
	private var REQUIRED_STRING(default, never):String = 'This field is required.';
	private var REQUIRED_COMBOBOX(default, never):String = 'This field is required.';
	private var VALUE_MISSMATCH(default, never):String = 'The value does not match.';
	private var INVALID_EMAIL(default, never):String = 'The given email is invalid.';
	private var NUMBER_ERROR_MSG(default, never):String = 'Only numbers are allowed.';
	private var CUSTOM_EXP_MSG(default, never):String = 'Improper value';

	//Constructor
	public function new() {}

	public function validate(validationSourceArr:Array<Dynamic>):Bool {
		var validatorFlag:Bool = true;
		validatorArr = new Array<Dynamic>();

		if (validationSourceArr == null) {
			return true;
		}
		for (i in 0...validationSourceArr.length) {
			var tmpReqString:String;
			var currentItem:ValidatorType = validationSourceArr[i];
			var tmpArr:Array<Dynamic>;
			var stringValidator:StringValidator = new StringValidator();
			stringValidator.source = currentItem.field;
			tmpReqString = REQUIRED_STRING;
			stringValidator.required = currentItem.isRequired;
			stringValidator.property = 'text';

			if (currentItem.minLength != -1) {
				tmpReqString = Std.string(stringValidator.tooShortError = 'Required ' + currentItem.minLength + ' digits');
				stringValidator.minLength = currentItem.minLength;
			} else {
				//stringValidator.source.errorString = null;
			}
			if (currentItem.maxLength != -1) {
				stringValidator.maxLength = currentItem.maxLength;
				tmpReqString = Std.string(stringValidator.tooLongError = 'Should not exceed ' + currentItem.maxLength + ' digits');
			} else {
				//stringValidator.source.errorString = null;
			}
			validatorArr.push(stringValidator);
			tmpArr = cast [stringValidator];

			//Combobox validation - whether a value of the combobox is been selected
			if (Std.is((currentItem.field), DropDownList)) {
				var numberValidator:NumberValidator = new NumberValidator();
				numberValidator.source = AS3.as(currentItem.field, DisplayObject);
				numberValidator.minValue = 1;
				numberValidator.lowerThanMinError = REQUIRED_COMBOBOX;
				numberValidator.required = currentItem.isRequired;
				numberValidator.property = 'selectedIndex';
				validatorArr.push(numberValidator);
				tmpArr = cast [stringValidator];
			}

			//Matching 2 fields
			if (currentItem.fieldToMatch != null) {
				var regExp:RegExpValidator = new RegExpValidator();
				regExp.expression = '^' + currentItem.fieldToMatch + '$';
				regExp.source = currentItem.field;
				regExp.property = 'text';
				regExp.required = currentItem.isRequired;
				regExp.noMatchError = tmpReqString = VALUE_MISSMATCH;
				validatorArr.push(regExp);
				tmpArr.push(stringValidator);
			}

			//Email validation
			if (currentItem.isEmail != false) {
				var eValidator:EmailValidator = new EmailValidator();
				eValidator.source = currentItem.field;
				eValidator.required = currentItem.isRequired;
				eValidator.property = 'text';
				eValidator.invalidCharError = tmpReqString = INVALID_EMAIL;
				validatorArr.push(eValidator);
				tmpArr = cast [eValidator];

			}

			//Number validation
			if (currentItem.isNumber != false) {
				var numberExp:RegExpValidator = new RegExpValidator();
				numberExp.expression = '[0-9]';
				numberExp.source = currentItem.field;
				numberExp.property = 'text';
				numberExp.required = currentItem.isRequired;
				numberExp.noMatchError = tmpReqString = NUMBER_ERROR_MSG;
				validatorArr.push(numberExp);
				tmpArr.push(stringValidator);
			}

			//Custom expression/validation
			if (currentItem.customExp != null) {
				var customExp:RegExpValidator = new RegExpValidator();
				customExp.expression = currentItem.customExp;
				customExp.source = currentItem.field;
				customExp.property = 'text';
				customExp.required = currentItem.isRequired;
				customExp.noMatchError = tmpReqString = CUSTOM_EXP_MSG;
				validatorArr.push(customExp);
				tmpArr.push(stringValidator);
			}

			validatorErrorArr = Validator.validateAll(tmpArr);

			if (validatorFlag && validatorErrorArr.length != 0) {
				Reflect.setField(currentItem.field, 'errorString', tmpReqString);
				Alert.show(currentItem.fieldName + FORM_ERROR_MSG, 'Error!');
				return false;
			} else {
				Reflect.setField(Reflect.field(tmpArr[0], 'source'), 'errorString', '');
			}

		}

		if (validatorFlag) {
			return true;
		} else {
			return false;
		}

	}

}