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
package no.doomsday.console.core.introspection;

/**
 * ...
 * @author Andreas Rønning
 */
class ParamDesc {

	//<parameter index="1" type="flash.display::DisplayObject" optional="false"/>
	public var index:Int = 0;
	public var type:Int = 0;
	public var optional:Int = 0;

	public function new(xml:FastXML) {
		index = AS3.int(xml.att.index);
		type = AS3.int(xml.att.type);
		optional = AS3.int(xml.att.optional);
	}

}