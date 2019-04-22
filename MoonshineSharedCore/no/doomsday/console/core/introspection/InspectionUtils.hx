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

import flash.errors.Error;
import no.doomsday.console.core.text.autocomplete.AutocompleteDictionary;
import flash.display.DisplayObjectContainer;

/**
 * ...
 * @author Andreas Rønning
 */
class InspectionUtils {

	private static var desc:FastXML;

	public function new() {}

	public static function getAutoCompleteDictionary(o:Dynamic):AutocompleteDictionary {
		desc = DescribeType.describeType(o);
		var dict:AutocompleteDictionary = new AutocompleteDictionary();
		//get all methods
		var node:FastXML;
		var list:FastXMLList = desc.descendants('method');
		for (node in list) {
			dict.addToDictionary(Std.string(node.att.name));
		}
		list = desc.descendants('variable');
		for (node in list) {
			dict.addToDictionary(Std.string(node.att.name));
		}
		list = desc.descendants('method');
		for (node in list) {
			dict.addToDictionary(Std.string(node.att.name));
		}
		list = desc.descendants('accessor');
		for (node in list) {
			dict.addToDictionary(Std.string(node.att.name));
		}
		if (Std.is(o, DisplayObjectContainer)) {
			var i:Int = AS3.int(Reflect.field(o, 'numChildren'));
			i > 0;
			while (i-- != 0) {
				dict.addToDictionary(Std.string(o.getChildAt(i).name));
			}
		}

		return dict;
	}

	public static function getAccessors(o:Dynamic):Array<AccessorDesc> {
		desc = DescribeType.describeType(o);
		var vec:Array<AccessorDesc> = new Array<AccessorDesc>();
		var node:FastXML;
		var list:FastXMLList = desc.descendants('accessor');
		for (node in list) {
			vec.push(new AccessorDesc(node));
		}
		return vec;
	}

	public static function getMethods(o:Dynamic):Array<MethodDesc> {
		desc = DescribeType.describeType(o);
		var vec:Array<MethodDesc> = new Array<MethodDesc>();
		var node:FastXML;
		var list:FastXMLList = desc.descendants('method');
		for (node in list) {
			vec.push(new MethodDesc(node));
		}
		return vec;
	}

	public static function getVariables(o:Dynamic):Array<VariableDesc> {
		desc = DescribeType.describeType(o);
		var vec:Array<VariableDesc> = new Array<VariableDesc>();
		var node:FastXML;
		var list:FastXMLList = desc.descendants('variable');
		for (node in list) {
			vec.push(new VariableDesc(node));
		}
		return vec;
	}

	//thanks Paulo Fierro :)
	public static function getMethodTooltip(scope:Dynamic, methodName:String):String {
		var tip:String = methodName + '( ';
		var desc:FastXMLList = FastXML.filterNodes( //Unexpected ECall(EIdent(describeType),[EIdent(scope)]) ;
		if (desc.length() == 0) {
			throw new Error('No description for method ' + methodName);
		}
		//<parameter index="1" type="String" optional="false"/>
		var first:Bool = true;
		for (attrib in as3hx.Compat.each(desc.descendants('parameter'))) {
			if (!first) {
				tip += ', ';
			}
			tip += Std.string(Std.string(attrib.att.type).toLowerCase());
			if (attrib.att.optional == 'true') {
				tip += '[optional]';
			}
			first = false;
		}
		tip += ' ):' + desc.att.returnType;
		return tip;
	}

	public static function getAccessorTooltip(scope:Dynamic, accessorName:String):String {
		var tip:String = accessorName;
		var desc:FastXMLList = FastXML.filterNodes( //Unexpected ECall(EIdent(describeType),[EIdent(scope)]) ;
		if (desc.length() == 0) {
			desc = FastXML.filterNodes( //Unexpected ECall(EIdent(describeType),[EIdent(scope)]) ;
			if (desc.length() == 0) {
				throw new Error('No description');
			}
		}
		tip += ':' + desc.att.type;
		if (desc.att.access == 'readonly') {
			tip += ' (read only)';
		}
		return tip;
	}

	public static function getMethodArgs(func:Dynamic):Array<Dynamic> {
		var desc:FastXML = DescribeType.describeType(func);
		var out:Array<Dynamic> = [];
		for (attrib in as3hx.Compat.each(desc.descendants('parameter'))) {
			out.push(attrib);
		}
		return out;
	}

}