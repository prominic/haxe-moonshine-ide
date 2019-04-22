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
 * Implementation of Diagnostic interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#diagnostic
 */
class Diagnostic {

	public static inline var SEVERITY_ERROR:Int = 1;
	public static inline var SEVERITY_WARNING:Int = 2;
	public static inline var SEVERITY_INFORMATION:Int = 3;
	public static inline var SEVERITY_HINT:Int = 4;

	public function new() {}

	public var path:String;
	public var message:String;
	public var range:Range;
	public var severity:Int = 0;
	public var code:String;

	public static function parse(original:Dynamic):Diagnostic {
		var vo:Diagnostic = new Diagnostic();
		vo.message = AS3.string(Reflect.field(original, 'message'));
		vo.code = AS3.string(Reflect.field(original, 'code'));
		vo.range = Range.parse(Reflect.field(original, 'range'));
		vo.severity = AS3.int(Reflect.field(original, 'severity'));
		return vo;
	}

	public static function parseWithPath(path:String, original:Dynamic):Diagnostic {
		var vo:Diagnostic = new Diagnostic();
		vo.path = path;
		vo.message = AS3.string(Reflect.field(original, 'message'));
		vo.code = AS3.string(Reflect.field(original, 'code'));
		vo.range = Range.parse(Reflect.field(original, 'range'));
		vo.severity = AS3.int(Reflect.field(original, 'severity'));
		return vo;
	}

}