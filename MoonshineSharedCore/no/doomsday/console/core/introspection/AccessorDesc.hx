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
class AccessorDesc {

	//<accessor name="stage" access="readonly" type="flash.display::Stage" declaredBy="flash.display::DisplayObject"/>
	public var name:String;
	public var access:String;
	public var type:String;
	public var declaredBy:String;

	public function new(xml:FastXML) {
		name = Std.string(xml.att.name);
		access = Std.string(xml.att.access);
		type = Std.string(xml.att.type);
		declaredBy = Std.string(xml.att.declaredBy);
	}

}