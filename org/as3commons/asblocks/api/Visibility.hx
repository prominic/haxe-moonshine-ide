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
 * Member visibility modifiers.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
@:final class Visibility {

	public var name(get, never):String;

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	public static var DEFAULT:Visibility = new Visibility('default');

	public static var INTERNAL:Visibility = new Visibility('internal');

	public static var PRIVATE:Visibility = new Visibility('private');

	public static var PROTECTED:Visibility = new Visibility('protected');

	public static var PUBLIC:Visibility = new Visibility('public');

	private static var list:Array<Dynamic>;

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
	 * The visibility modifier name.
	 */
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
	public function equals(other:Visibility):Bool {
		return _name == other.name;
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public static function create(name:String):Visibility {
		for (element in list) {
			if (element.name == name) {
				return element;
			}
		}

		var namespace:Visibility = new Visibility(name);
		list.push(namespace);
		return namespace;
	}

	/**
	 * @private
	 */
	public static function hasVisibility(visibility:String):Bool {
		for (element in list) {
			if (element.name == visibility) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @private
	 */
	public static function getVisibility(visibility:String):Visibility {
		for (element in list) {
			if (element.name == visibility) {
				return element;
			}
		}
		return null;
	}

	private static var Visibility_static_initializer = {
		{
			list =
					[
					DEFAULT,
					INTERNAL,
					PRIVATE,
					PROTECTED,
					PUBLIC
			];
		};
		true;
	}

}