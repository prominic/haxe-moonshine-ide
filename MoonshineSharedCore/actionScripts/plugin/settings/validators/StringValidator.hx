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
package actionScripts.plugin.settings.validators;

class StringValidator implements IValidator {

	public function new(minLength:Float = -1, maxLength:Float = -1, noSpaces:Bool = false,
			restrictChars:Dynamic = null, badChars:Dynamic = null) {}

	/**
	 *
	 * @param content
	 * @param rules
	 * Rules can be one be any of the following
	 * minValue - minimun string length
	 * maxValue
	 * noSpaces
	 * restrictChars
	 * badChars
	 * @return
	 *
	 */
	public function validate(content:Dynamic, rules:Dynamic = null):Bool {
		return false;
	}

}