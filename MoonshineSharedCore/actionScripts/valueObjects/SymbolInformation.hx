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

/**
 * Implementation of SymbolInformation interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new values to this class that are specific
 * to Moonshine IDE or to a particular language.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
 * @see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
 */
class SymbolInformation {

	public function new() {}

	public var name:String;
	public var containerName:String;
	public var kind:Int = 0;
	public var deprecated:Bool = false;
	public var location:Location;

	public static function parse(original:Dynamic):SymbolInformation {
		var vo:SymbolInformation = new SymbolInformation();
		vo.name = AS3.string(Reflect.field(original, 'name'));
		vo.kind = AS3.int(Reflect.field(original, 'kind'));
		vo.containerName = AS3.string(Reflect.field(original, 'containerName'));
		vo.deprecated = AS3.as(Reflect.field(original, 'deprecated'), Bool);
		vo.location = Location.parse(Reflect.field(original, 'location'));
		return vo;
	}

}