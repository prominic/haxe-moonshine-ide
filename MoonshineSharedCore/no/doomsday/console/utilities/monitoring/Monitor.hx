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
package no.doomsday.console.utilities.monitoring;

import flash.geom.Rectangle;
import no.doomsday.console.core.gui.Window;
import no.doomsday.console.core.introspection.ScopeManager;

/**
 * ...
 * @author Andreas Rønning
 */
class Monitor extends Window {

	private var _scope:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	public var properties:Array<Dynamic>;
	public var outObj:Dynamic = {};

	public function new(scope:Dynamic, properties:Array<Dynamic>) {
		super('Monitor', new Rectangle(0, 0, 300, 100));
		_scope.set('scope', scope);
		this.properties = properties;
	}

	public var scope(get, never):Dynamic;
	private function get_scope():Dynamic {
		return _scope.get('scope');
	}

	public function update():Void {
		Reflect.setField(outObj, 'name', (AS3.as(Reflect.field(scope, 'name'), Bool)) ? Reflect.field(scope, 'name') : Std.string(as3hx.Compat.typeof(scope)));
		for (i in 0...properties.length) {
			Reflect.setField(outObj, Std.string(properties[i]), Reflect.field(scope, Std.string(properties[i])));
		}
	}

	override public function toString():String {
		return Std.string(Std.string(outObj));
	}

}