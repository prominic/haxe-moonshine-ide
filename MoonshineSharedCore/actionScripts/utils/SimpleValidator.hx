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

import mx.controls.Alert;
import mx.events.ValidationResultEvent;
import mx.validators.StringValidator;
import spark.validators.NumberValidator;
import actionScripts.extResources.com.validator.ValidatorType;

class SimpleValidator {

	public static function validate(fields:Array<Dynamic>):Bool {
		var vResultEvent:ValidationResultEvent;
		var tmpValidatorType:ValidatorType;
		for (i in 0...fields.length) {
			tmpValidatorType = fields[i];

			Reflect.setField(tmpValidatorType.validator, 'source', tmpValidatorType.field);
			if (Std.is(tmpValidatorType.validator, StringValidator)) {
				Reflect.setField(tmpValidatorType.validator, 'minLength', ((tmpValidatorType.minLength != -1)) ? tmpValidatorType.minLength : Math.NaN);
				Reflect.setField(tmpValidatorType.validator, 'maxLength', ((tmpValidatorType.maxLength != -1)) ? tmpValidatorType.maxLength : Math.NaN);
			} else if (Std.is(tmpValidatorType.validator, NumberValidator)) {
				Reflect.setField(tmpValidatorType.validator, 'minValue', ((tmpValidatorType.minLength != -1)) ? tmpValidatorType.minLength : Math.NaN);
				Reflect.setField(tmpValidatorType.validator, 'maxValue', ((tmpValidatorType.maxLength != -1)) ? tmpValidatorType.maxLength : Math.NaN);
				Reflect.setField(tmpValidatorType.validator, 'domain', 'int');
			}
			if (tmpValidatorType.tooLongError != null) {
				Reflect.setField(tmpValidatorType.validator, 'tooLongError', tmpValidatorType.tooLongError);
			}
			if (tmpValidatorType.tooShortError != null) {
				Reflect.setField(tmpValidatorType.validator, 'tooShortError', tmpValidatorType.tooShortError);
			}
			vResultEvent = tmpValidatorType.validator.validate();
			if (vResultEvent.type == ValidationResultEvent.INVALID) {
				Alert.show(tmpValidatorType.fieldName + ' is Invalid/Empty.\nPlease correct so we can save your data.', 'Error!');
				return false;
			}
		}

		// else
		return true;
	}

}