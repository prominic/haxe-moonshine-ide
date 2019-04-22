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
package no.doomsday.console.core.references;

import flash.errors.Error;
import haxe.Constraints.Function;
import no.doomsday.console.core.DConsole;
import no.doomsday.console.core.introspection.ScopeManager;
import no.doomsday.console.core.messages.MessageTypes;

/**
 * ...
 * @author Andreas Rønning
 */
class ReferenceManager {

	private var referenceDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var console:DConsole;
	private var scopeManager:ScopeManager;
	private var uidPool:Int = 0;

	private var uid(get, never):Int;
	private function get_uid():Int {
		return uidPool++;
	}

	//TODO: Add autocomplete for reference names
	public function new(console:DConsole, scopeManager:ScopeManager) {
		this.scopeManager = scopeManager;
		this.console = console;
	}

	public function clearReferenceByName(name:String):Void {
		try {
			This is an intentional compilation error. See the README for handling the delete keyword
			delete (referenceDict.get(name));
			console.print('Cleared reference ' + name, MessageTypes.SYSTEM);
			printReferences();
		} catch (e:Error) {
			console.print('No such reference', MessageTypes.ERROR);
		}
	}

	public function getReferenceByName(target:Dynamic, id:String = null):Void {
		var t:Dynamic;
		try {
			t = scopeManager.getScopeByName(Std.string(target));
		} catch (e:Error) {
			t = target;
		}
		if (!AS3.as(t, Bool)) {
			throw new Error('Invalid target');
		}
		if (id == null) {
			id = 'ref' + uid;
		}
		referenceDict.set(id, t);
		printReferences();
	}

	public function getReference(id:String = null):Void {
		if (id == null) {
			id = 'ref' + uid;
		}
		referenceDict.set(id, scopeManager.currentScope.obj);
		printReferences();
	}

	public function createReference(o:Dynamic):Void {
		var id:String = 'ref' + uid;
		referenceDict.set(id, o);
		printReferences();
	}

	public function clearReferences():Void {
		referenceDict = new Dictionary(true);
		console.print('References cleared', MessageTypes.SYSTEM);
	}

	public function printReferences():Void {
		console.print('Stored references: ');
		for (b in referenceDict.keys()) {
			console.print('	' + Std.string(b) + ' : ' + Std.string(referenceDict.get(b)));
		}
	}

	public function setScopeByReferenceKey(key:String):Void {
		if (referenceDict.get(key) != null) {
			scopeManager.setScope(referenceDict.get(key));
		} else {
			throw new Error('No such reference');
		}
	}

	public function parseForReferences(args:Array<Dynamic>):Array<Dynamic> {
		for (i in 0...args.length) {
			if (args[i].indexOf('@') > -1) {
				var s:Array<Dynamic> = args[i].split('@');
				var key:String = Std.string(s[1]);
				if (referenceDict.get(key) != null) {
					if (Std.is(referenceDict.get(key), Function)) {
						args[i] = referenceDict.get(key)();
					} else {
						args[i] = referenceDict.get(key);
					}
				} else {
					try {
						args[i] = scopeManager.getScopeByName(key);
					} catch (e:Error) {
						args[i] = null;
					}
				}
			}
		}
		return args;
	}

}