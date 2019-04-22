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
 * Implementation of DocumentSymbol interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
 */
class DocumentSymbol {

	public function new() {}

	public var name:String;
	public var detail:String;
	public var kind:Int = 0;
	public var deprecated:Bool = false;
	public var range:Range;
	public var selectionRange:Range;
	public var children:Array<DocumentSymbol>;

	public static function parse(original:Dynamic):DocumentSymbol {
		var vo:DocumentSymbol = new DocumentSymbol();
		vo.name = AS3.string(Reflect.field(original, 'name'));
		vo.detail = AS3.string(Reflect.field(original, 'detail'));
		vo.kind = AS3.int(Reflect.field(original, 'kind'));
		vo.deprecated = AS3.as(Reflect.field(original, 'deprecated'), Bool);
		vo.range = Range.parse(Reflect.field(original, 'range'));
		vo.selectionRange = Range.parse(Reflect.field(original, 'selectionRange'));
		if (AS3.as(Reflect.field(original, 'children'), Bool) && Std.is(Reflect.field(original, 'children'), Array)) {
			var children:Array<DocumentSymbol> = [];
			var originalChildren:Array<Dynamic> = cast AS3.asArray(Reflect.field(original, 'children'));
			var childCount:Int = originalChildren.length;
			for (i in 0...childCount) {
				var originalChild:Dynamic = originalChildren[i];
				var child:DocumentSymbol = DocumentSymbol.parse(originalChild);
				children[i] = child;
			}
			vo.children = cast children;
		}
		return vo;
	}

}