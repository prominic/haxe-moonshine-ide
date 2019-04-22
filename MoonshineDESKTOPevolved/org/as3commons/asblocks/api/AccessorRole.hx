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
 * Function accessor <strong>NORMAL</strong>, <strong>GETTER</strong> and
 * <strong>SETTER</strong> roles.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
@:final class AccessorRole {

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * A function using the normal <code>function</code> keyword.
	 */
	public static var NORMAL(default, never):AccessorRole = AccessorRole.create('normal');

	/**
	 * A function using the normal <code>function [get]</code> keyword.
	 */
	public static var GETTER(default, never):AccessorRole = AccessorRole.create('getter');

	/**
	 * A function using the normal <code>function [set]</code> keyword.
	 */
	public static var SETTER(default, never):AccessorRole = AccessorRole.create('setter');

	/**
	 * @private
	 */
	private static var list:Array<Dynamic> =
		cast [
		NORMAL,
		GETTER,
		SETTER
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
	 * The role name; either <strong>normal</strong>, <strong>getter</strong> or
	 * <strong>setter</strong>.
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
	public function equals(other:AccessorRole):Bool {
		return _name == other.name;
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new <code>AccessorRole</code>.
	 *
	 * @param name A <code>String</code> indicating the name of the role.
	 * @return A new <code>AccessorRole</code> instance.
	 */
	public static function create(name:String):AccessorRole {
		for (element_ in list) {
			var element:AccessorRole = cast element_;
			if (Reflect.field(element, 'name') == name) {
				return element;
			}
		}

		return new AccessorRole(name);
	}

}