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

import flash.errors.ArgumentError;
import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.utils.ByteArray;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.messages.MessageTypes;
import no.doomsday.console.core.text.autocomplete.AutocompleteManager;

/**
 * ...
 * @author Andreas Rønning
 */
class ScopeManager {

	public static inline var SEARCH_METHODS:Int = 0;
	public static inline var SEARCH_ACCESSORS:Int = 1;
	public static inline var SEARCH_CHILDREN:Int = 2;

	private var _currentScope:IntrospectionScope;
	private var _previousScope:IntrospectionScope;
	private var console:DConsole;
	private var autoCompleteManager:AutocompleteManager;

	public function new(console:DConsole, autoCompleteManager:AutocompleteManager) {
		this._currentScope = this.createScope({});
		this.console = console;
		this.autoCompleteManager = autoCompleteManager;
	}

	public function createScope(o:Dynamic):IntrospectionScope {
		if (!AS3.as(o, Bool)) {
			throw new ArgumentError('Invalid scope');
		}
		var c:IntrospectionScope = new IntrospectionScope();
		c.autoCompleteDict = InspectionUtils.getAutoCompleteDictionary(o);
		c.children = TreeUtils.getChildren(o);
		c.accessors = InspectionUtils.getAccessors(o);
		c.methods = InspectionUtils.getMethods(o);
		c.variables = InspectionUtils.getVariables(o);
		c.obj = o;
		_currentScope = c;
		return _currentScope;
	}

	public function setScope(o:Dynamic, force:Bool = false):Void {
		if (!force && currentScope.obj == o) {
			printScope();
			return;
		}
		try {
			createScope(o);
			autoCompleteManager.scopeDict = currentScope.autoCompleteDict;
		} catch (e:Error) {
			throw e;
		}
		printScope();
		printDownPath();
	}

	public function getScopeByName(str:String):Dynamic {
		try {
			if (Reflect.field(currentScope.obj, str) != null) {
				return Reflect.field(currentScope.obj, str);
			} else {
				throw new Error();
			}
		} catch (e:Error) {
			try {
				return (currentScope.obj.getChildByName(str));
			} catch (e:Error) {}
		}
		throw new Error('No such scope');
	}

	public var currentScope(get, never):IntrospectionScope;
	private function get_currentScope():IntrospectionScope {
		return _currentScope;
	}

	public function up():Void {
		if (_currentScope == null) {
			return;
		}
		if (Std.is(_currentScope.obj, DisplayObject)) {
			setScope(Reflect.field(_currentScope.obj, 'parent'));
		}
	}

	public function setScopeByName(str:String):Void {
		try {
			setScope(getScopeByName(str));
		} catch (e:Error) {
			throw e;
		}
	}

	public function printMethods():Void {
		var m:Array<MethodDesc> = cast currentScope.methods;
		console.print('	methods:');
		var i:Int;
		for (i in 0...m.length) {
			var md:MethodDesc = m[i];
			console.print('		' + md.name + ' : ' + md.returnType);
		}
	}

	public function printVariables():Void {
		var a:Array<VariableDesc> = cast currentScope.variables;
		var cv:Dynamic;
		console.print('	variables: ' + a.length);
		var i:Int;
		for (i in 0...a.length) {
			var vd:VariableDesc = a[i];
			console.print('		' + vd.name + ': ' + vd.type);
			try {
				cv = Reflect.field(currentScope.obj, vd.name);
				console.print('			value: ' + Std.string(cv));
			} catch (e:Error) {}
		}
		var b:Array<AccessorDesc> = cast currentScope.accessors;
		console.print('	accessors: ' + b.length);
		for (i in 0...b.length) {
			var ad:AccessorDesc = b[i];
			console.print('		' + ad.name + ': ' + ad.type);
			try {
				cv = Reflect.field(currentScope.obj, ad.name);
				console.print('			value: ' + Std.string(cv));
			} catch (e:Error) {}
		}
	}

	public function printChildren():Void {
		var c:Array<ChildScopeDesc> = cast currentScope.children;
		if (c.length < 1) {
			return;
		}
		console.print('	children: ' + c.length);
		for (i in 0...c.length) {
			var cc:ChildScopeDesc = c[i];
			console.print('		' + cc.name + ' : ' + cc.type);
		}
	}

	public function printDownPath():Void {
		printChildren();
		printComplexObjects();
	}

	public function printComplexObjects():Void {
		var a:Array<VariableDesc> = cast currentScope.variables;
		var cv:Dynamic;
		if (a.length < 1) {
			return;
		}
		var i:Int;
		var out:Array<Dynamic> = [];
		for (i in 0...a.length) {
			var vd:VariableDesc = a[i];
			switch (vd.type) {
				case 'Number', 'Boolean', 'String', 'int', 'uint', 'Array':
					continue;
			}
			out.push('		' + vd.name + ': ' + vd.type);
		}
		console.print('	complex types: ' + out.length);
		if (out.length > 0) {
			for (i in 0...out.length) {
				console.print(out[i]);
			}
		}
	}

	public function printScope():Void {
		if (Std.is(currentScope.obj, ByteArray)) {
			console.print('scope : [ByteArray]');
		} else {
			console.print('scope : ' + Std.string(currentScope.obj));
		}
	}

	public function setAccessorOnObject(accessorName:String, arg:Dynamic):Dynamic {
		if (arg == 'true') {
			arg = true;
		} else if (arg == 'false') {
			arg = false;
		}
		Reflect.setField(currentScope.obj, accessorName, arg);
		return Reflect.field(currentScope.obj, accessorName);
	}

	public function getAccessorOnObject(accessorName:String):String {
		return Std.string(Std.string(Reflect.field(currentScope.obj, accessorName)));
	}

	public function selectBaseScope():Void {
		setScope(console.parent);
	}

	public function callMethodOnScope(args:Array<Dynamic> = null):Dynamic {
		var cmd:String = Std.string(args.shift());
		var func:Function = Reflect.field(currentScope.obj, cmd);
		return Reflect.callMethod(currentScope.obj, func, args);
	}

	public function updateScope():Void {
		setScope(currentScope.obj, true);
	}

	public function doSearch(search:String, searchMode:Int = SEARCH_METHODS):Array<String> {
		var result:Array<String> = new Array<String>();
		var s:String = search.toLowerCase();
		var i:Int;
		switch (searchMode) {
			case SEARCH_ACCESSORS:
				i = currentScope.accessors.length;
				while (i-- != 0) {
					var a:AccessorDesc = currentScope.accessors[i];
					if (a.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(a.name);
					}
				}
				i = currentScope.variables.length;
				while (i-- != 0) {
					var v:VariableDesc = currentScope.variables[i];
					if (v.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(v.name);
					}
				}
			case SEARCH_METHODS:
				i = currentScope.methods.length;
				while (i-- != 0) {
					var m:MethodDesc = currentScope.methods[i];
					if (m.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(m.name);
					}
				}
			case SEARCH_CHILDREN:
				i = currentScope.children.length;
				while (i-- != 0) {
					var c:ChildScopeDesc = currentScope.children[i];
					if (c.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(c.name);
					}
				}
		}
		return result;
	}

}