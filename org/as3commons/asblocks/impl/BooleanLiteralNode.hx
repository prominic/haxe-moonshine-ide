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

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.api.IBooleanLiteral;

/**
 * The <code>IBooleanLiteral</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class BooleanLiteralNode extends LiteralNode implements IBooleanLiteral {

	public var value(get, set):Bool;

	//--------------------------------------------------------------------------
	//
	//  IBooleanLiteral API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  value
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IBooleanLiteral#value
	 */
	private function get_value():Bool {
		return (tokenText == 'true') ? true : false;
	}

	/**
	 * @private
	 */
	private function set_value(value:Bool):Bool {
		var token:LinkedListToken = cast((node), TokenNode).token;
		if (value) {
			node.kind = AS3NodeKind.TRUE;
			node.stringValue = KeyWords.TRUE;
		} else {
			node.kind = AS3NodeKind.FALSE;
			node.stringValue = KeyWords.FALSE;
		}
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