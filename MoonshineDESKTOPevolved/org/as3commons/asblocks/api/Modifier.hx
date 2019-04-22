////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.api;

/**
 * Type and member modifiers.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
@:final class Modifier {

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------

	public static var DYNAMIC(default, never):Modifier = Modifier.create('dynamic');

	public static var FINAL(default, never):Modifier = Modifier.create('final');

	public static var INTERNAL(default, never):Modifier = Modifier.create('internal');

	public static var OVERRIDE(default, never):Modifier = Modifier.create('override');

	public static var PRIVATE(default, never):Modifier = Modifier.create('private');

	public static var PROTECTED(default, never):Modifier = Modifier.create('protected');

	public static var PUBLIC(default, never):Modifier = Modifier.create('public');

	public static var STATIC(default, never):Modifier = Modifier.create('static');

	private static var list:Array<Dynamic> =
		cast [
		DYNAMIC,
		FINAL,
		INTERNAL,
		OVERRIDE,
		PRIVATE,
		PROTECTED,
		PUBLIC,
		STATIC
	];

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @private
	 */
	private var _name:String;

	/**
	 * The modifier name.
	 */
	public var name(get, never):String;
	private function get_name():String {
		return _name;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function new(name:String) {
		_name = name;
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function toString():String {
		return _name;
	}

	/**
	 * @private
	 */
	public function equals(other:Modifier):Bool {
		return _name == other.name;
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new Modifier.
	 *
	 * @param name A String indicating the name of the modifier.
	 * @return A new Modifer instance.
	 */
	public static function create(name:String):Modifier {
		for (element_ in list) {
			var element:Modifier = cast element_;
			if (Reflect.field(element, 'name') == name) {
				return element;
			}
		}

		return new Modifier(name);
	}

}