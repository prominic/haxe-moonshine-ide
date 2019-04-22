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
package actionScripts.valueObjects;

class AS3ClassAttributes {

	public var modifierA:String;
	public var modifierB:String;
	public var modifierC:String;
	public var extendsClassInterface:String;
	public var implementsInterface:String;
	public var imports:Array<Dynamic> = [];

	public function new() {}

	public function getModifiersB():String {
		var tempModifArr:Array<Dynamic> = [];
		if (modifierB != null) {
			tempModifArr.push(modifierB);
		}
		if (modifierC != null) {
			tempModifArr.push(modifierC);
		}

		return tempModifArr.join(' ');
	}

	public function getImports(importKeyword:String = 'import'):String {
		var allImports:String = '';

		var countImports:Int = imports.length;
		var i:Int = 0;
		while (i < countImports) {
			var imp:String = Std.string(imports[i]);
			if (i == 0) {
				allImports += importKeyword + ' ' + imp + ';\n';
			} else {
				allImports += '    ' + importKeyword + ' ' + imp + ';\n';
			}
			i++;
		}

		return allImports;
	}

}