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

import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * A parser node that holds start and stop tokens.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TokenNode extends Node {

	public var token(get, set):LinkedListToken;

	public var absolute:Bool = false;

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  token
	//----------------------------------

	/**
	 * @private
	 */
	private var _token:LinkedListToken;

	/**
	 * doc
	 */
	private function get_token():LinkedListToken {
		return _token;
	}

	/**
	 * @private
	 */
	private function set_token(value:LinkedListToken):LinkedListToken {
		_token = value;
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override private function set_kind(value:String):String {
		super.kind = value;

		if (token != null) {
			token.kind = value;
		}
		return value;
	}

	/**
	 * @private
	 */
	override private function set_stringValue(value:String):String {
		super.stringValue = value;

		if (token != null) {
			token.text = value;
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
	public function new(kind:String,
			stringValue:String,
			line:Int,
			column:Int) {
		super(kind, line, column, stringValue);
	}

	/**
	 * called when one of this node's children updates it's start-token,
	 * so that this node can potentially take action; maybe by setting
	 * the same start-token IF the child was the very-first in this node's
	 * list of children.
	 */
	@:allow(org.as3commons.asblocks.parser.core)
	private function notifyChildStartTokenChange(child:IParserNode,
			newStart:LinkedListToken):Void {
		if (isFirst(child) && isSameStartToken(child)) {
			startToken = newStart;
		}
	}

	/**
	 * called when one of this node's children updates it's stop-token,
	 * so that this node can potentially take action; maybe by setting
	 * the same stop-token IF the child was the very-last in this node's
	 * list of children.
	 */
	@:allow(org.as3commons.asblocks.parser.core)
	private function notifyChildStopTokenChange(child:IParserNode,
			newStop:LinkedListToken):Void {
		if (isLast(child) && (isSameStopToken(child) || isNoStopToken(child))) {
			stopToken = newStop;
		}
	}

	/**
	 * @private
	 */
	private function isSameStartToken(child:IParserNode):Bool {
		return child.startToken == startToken;
	}

	/**
	 * @private
	 */
	private function isFirst(child:IParserNode):Bool {
		return child == getFirstChild();
	}

	/**
	 * @private
	 */
	private function isNoStopToken(child:IParserNode):Bool {
		return child.stopToken == null;
	}

	/**
	 * @private
	 */
	private function isSameStopToken(child:IParserNode):Bool {
		return child.stopToken == stopToken;
	}

	/**
	 * @private
	 */
	private function isLast(child:IParserNode):Bool {
		return child == getLastChild();
	}

}