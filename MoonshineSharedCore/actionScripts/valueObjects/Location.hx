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
 * Implementation of Location interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#location
 */
class Location {

	public var uri:String;
	public var range:Range;

	public function new(uri:String = null, range:Range = null) {
		this.uri = uri;
		this.range = range;
	}

	public static function parse(original:Dynamic):Location {
		var vo:Location = new Location();
		vo.uri = AS3.string(Reflect.field(original, 'uri'));
		vo.range = Range.parse(Reflect.field(original, 'range'));
		return vo;
	}

}