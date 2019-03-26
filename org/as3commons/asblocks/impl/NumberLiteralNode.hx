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

package org.as3commons.asblocks.impl;

import org.as3commons.asblocks.api.INumberLiteral;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>INumberLiteral</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class NumberLiteralNode extends LiteralNode implements INumberLiteral {

	public var value(get, set):Float;

	//--------------------------------------------------------------------------
	//
	//  INumberLiteral API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  value
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.INumberLiteral#value
	 */
	private function get_value():Float {
		return as3hx.Compat.parseInt(tokenText);
	}

	/**
	 * @private
	 */
	private function set_value(value:Float):Float {
		tokenText = Std.string(value);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(node:IParserNode) {
		super(node);
	}

}