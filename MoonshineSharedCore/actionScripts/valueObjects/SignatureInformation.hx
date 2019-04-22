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
 * Implementation of SignatureInformation interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_signatureHelp
 */
class SignatureInformation {

	public var label:String = '';
	public var parameters:Array<ParameterInformation>;

	public static function parse(original:Dynamic):SignatureInformation {
		var vo:SignatureInformation = new SignatureInformation();
		vo.label = AS3.string(Reflect.field(original, 'label'));
		var originalParameters:Array<Dynamic> = Reflect.field(original, 'parameters');
		var parameters:Array<ParameterInformation> = [];
		var originalParametersCount:Int = originalParameters.length;
		for (i in 0...originalParametersCount) {
			var resultParameter:Dynamic = originalParameters;
			var parameter:ParameterInformation = new ParameterInformation();
			parameter.label = AS3.string(Reflect.field(resultParameter, Std.string(parameter)));
			parameters[i] = parameter;
		}
		vo.parameters = cast parameters;
		return vo;
	}

	public function new() {}

}