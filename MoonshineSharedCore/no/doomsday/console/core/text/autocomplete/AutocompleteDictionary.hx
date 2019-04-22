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

/**
 * ...
 * @author Andreas Rønning
 */
class AutocompleteDictionary {

	public var basepage:Dynamic = {};
	private var stringContents:Array<String> = new Array<String>();
	private var stringContentsLowercase:Array<String> = new Array<String>();

	public function new() {}

	public function correctCase(str:String):String {
		var idx:Int = AS3.int(Lambda.indexOf(stringContentsLowercase, str.toLowerCase()));
		if (idx == -1) {
			throw new Error('No result');
		}
		return stringContents[idx];
	}

	public function addToDictionary(str:String):Void {
		stringContents.push(str);
		stringContentsLowercase.push(str.toLowerCase());//TODO: This is a terrible way to solve the search problem. Must fix.
		var strParts:Array<String> = str.split('');
		strParts.push(new String());
		insert(cast strParts, basepage);
	}

	public function contains(str:String):Bool {
		return Lambda.indexOf(stringContentsLowercase, str.toLowerCase(), 0) > -1;
	}

	private function insert(parts:Array<Dynamic>, page:Dynamic):Void {
		if (parts[0] == null) {
			return;
		}
		var letter:String = Std.string(parts[0]);
		if (Reflect.field(page, letter) == null) {
			Reflect.setField(page, letter, {});
		}
		insert(parts.slice(1, parts.length), Reflect.field(page, letter));
	}

	public function getSuggestion(arr:Array<Dynamic>):String {
		var suggestion:String = '';
		var len:Int = arr.length;
		var tmpDict:Dynamic = basepage;

		if (len < 1) {
			return suggestion;
		}

		var letter:String;
		for (i in ...len) {
			letter = Std.string(arr[i]);
			if (Reflect.field(tmpDict, letter.toUpperCase()) != null && Reflect.field(tmpDict, letter.toLowerCase()) != null) {
				var upperTmpDict:Dynamic = Reflect.field(tmpDict, letter.toUpperCase());
				var lowerTmpDict:Dynamic = Reflect.field(tmpDict, letter.toLowerCase());
				tmpDict = mergeDictionaries(lowerTmpDict, upperTmpDict);
			} else if (Reflect.field(tmpDict, letter.toUpperCase()) != null) {
				tmpDict = Reflect.field(tmpDict, letter.toUpperCase());
			} else if (Reflect.field(tmpDict, letter.toLowerCase()) != null) {
				tmpDict = Reflect.field(tmpDict, letter.toLowerCase());
			} else {
				return suggestion;
			}
		}

		var loop:Bool = true;
		while (loop) {
			loop = false;
			for (l in Reflect.fields(tmpDict)) {
				if (shouldContinue(tmpDict)) {
					suggestion += l;
					tmpDict = Reflect.field(tmpDict, l);
					loop = true;
					break;
				}
			}
		}

		return suggestion;
	}

	private function mergeDictionaries(lowerCaseDict:Dynamic, upperCaseDict:Dynamic):Dynamic {
		var tmpDict:Dynamic = {};

		for (j in Reflect.fields(lowerCaseDict)) {
			Reflect.setField(tmpDict, j, Reflect.field(lowerCaseDict, j));
		}

		for (k in Reflect.fields(upperCaseDict)) {
			if (Reflect.field(tmpDict, k) != null && Reflect.field(upperCaseDict, k) != null) {
				Reflect.setField(tmpDict, k, mergeDictionaries(Reflect.field(tmpDict, k), Reflect.field(upperCaseDict, k)));
			} else {
				Reflect.setField(tmpDict, k, Reflect.field(upperCaseDict, k));
			}
		}
		return tmpDict;
	}

	private function shouldContinue(tmpDict:Dynamic):Bool {
		var count:Float = 0;
		for (k in Reflect.fields(tmpDict)) {
			if (count > 0) {
				return false;
			}
			count++;
		}
		return true;
	}

}