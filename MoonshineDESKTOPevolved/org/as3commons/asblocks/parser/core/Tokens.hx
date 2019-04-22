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

package org.as3commons.asblocks.parser.core;

/**
 * A TokenEntry collection vector.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class Tokens {

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  tokens
	//----------------------------------

	/**
	 * @private
	 */
	private var _tokens:Array<TokenEntry>;

	/**
	 * Returns the token entry Vector.
	 */
	public var tokens(get, never):Array<TokenEntry>;
	private function get_tokens():Array<TokenEntry> {
		return cast _tokens;
	}

	//----------------------------------
	//  length
	//----------------------------------

	/**
	 * Returns the length of the token entry Vector.
	 */
	public var length(get, never):Int;
	private function get_length():Int {
		return _tokens.length;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new() {
		_tokens = cast new Array<TokenEntry>();
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Adds a TokenEntry to the tokens Vector.
	 *
	 * @param entry A TokenEntry to add.
	 */
	public function add(entry:TokenEntry):Void {
		tokens.push(entry);
	}

}