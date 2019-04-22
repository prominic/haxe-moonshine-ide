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

import flash.errors.Error;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ITokenListUpdateDelegate;

/**
 * @private
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ParentheticListUpdateDelegate implements ITokenListUpdateDelegate {

	//--------------------------------------------------------------------------
	//
	//  Private :: Variable
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var open:String;

	/**
	 * @private
	 */
	private var close:String;

	public function setBoundaries(open:String, close:String):Void {
		this.open = open;
		this.close = close;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(open:String, close:String) {
		this.open = open;
		this.close = close;
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function addedChild(parent:IParserNode,
			child:IParserNode):Void {
		var insert:LinkedListToken = findClose(parent).previous;

		insertAfter(insert, insert.next, child.startToken, child.stopToken);
	}

	/**
	 * @private
	 */
	public function addedChildAt(tree:IParserNode,
			index:Int,
			child:IParserNode):Void {
		var target:LinkedListToken;
		var targetNext:LinkedListToken;

		if (index == 0) {
			var tn:TokenNode = AS3.as(tree, TokenNode);
			if (!tn.absolute) {
				target = findOpen(tree);
				targetNext = target.next;
			} else {
				target = tree.startToken.previous;
				targetNext = target.next;
			}
		} else {
			var prev:IParserNode = tree.getChild(index - 1);
			target = prev.stopToken;
			targetNext = target.next;
		}
		insertAfter(target, targetNext, child.startToken, child.stopToken);
	}

	/**
	 * @private
	 */
	public function appendToken(parent:IParserNode,
			append:LinkedListToken):Void {
		var close:LinkedListToken = findClose(parent).previous;
		insertAfter(close, close.next, append, append);
	}

	/**
	 * @private
	 */
	public function addToken(parent:IParserNode,
			index:Int,
			append:LinkedListToken):Void {
		var target:LinkedListToken;
		var targetNext:LinkedListToken;

		if (index == 0) {
			target = findOpen(parent);
			// added
			if (target == null) {
				target = parent.startToken;
			}
			targetNext = target.next;
		} else {
			var beforeChild:IParserNode = parent.getChild(index);
			// added
			if (beforeChild == null) {
				//targetNext = parent.startToken.next;
				target = parent.startToken.next;
			} else {
				targetNext = beforeChild.startToken;
				target = targetNext.previous;
			}

			//target = targetNext.previous;
		}
		insertAfter(target, targetNext, append, append);
	}

	/**
	 * @private
	 */
	public function deletedChild(parent:IParserNode,
			index:Int,
			child:IParserNode):Void {
		var start:LinkedListToken = child.startToken;
		var stop:LinkedListToken = child.stopToken;
		var startPrev:LinkedListToken = start.previous;
		var stopNext:LinkedListToken = stop.next;
		if (startPrev != null) {
			startPrev.next = stopNext;
		} else if (stopNext != null) {
			stopNext.previous = startPrev;
		}
		// just to save possible confusion, break links out from the
		// removed token list too,
		start.previous = null;
		stop.next = null;
	}

	/**
	 * @private
	 */
	public function replacedChild(tree:IParserNode,
			index:Int,
			child:IParserNode,
			oldChild:IParserNode):Void {
		// link the new child's tokens in place of the old,
		oldChild.startToken.previous.next = child.startToken;
		oldChild.stopToken.next.previous = child.stopToken;
		// just to save possible confusion, break links out from the
		// removed token list too,
		oldChild.startToken.previous = null;
		oldChild.stopToken.next = null;
	}

	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function findOpen(parent:IParserNode):LinkedListToken {
		var tok:LinkedListToken = parent.startToken;
		while (tok != null) {
			if (tok.kind == open) {
				return tok;
			}
			tok = tok.next;
		}
		return null;
	}

	/**
	 * @private
	 */
	private function findClose(parent:IParserNode):LinkedListToken {
		var tok:LinkedListToken = parent.stopToken;
		while (tok != null) {
			if (tok.kind == close) {
				return maybeSkiptoLinePreceeding(tok);
			}
			tok = tok.previous;
		}
		return null;
	}

	/**
	 * @private
	 */
	private function maybeSkiptoLinePreceeding(target:LinkedListToken):LinkedListToken {
		var tok:LinkedListToken = target.previous;
		while (tok != null) {
			switch (tok.kind) {
				case AS3NodeKind.WS:
					tok = tok.previous;
					continue;
				case AS3NodeKind.NL:
					return tok;
				case _:
					return target;
			}
			tok = tok.previous;
		}
		return target;
	}

	/**
	 * @private
	 */
	private static function insertAfter(left:LinkedListToken,
			right:LinkedListToken,
			startToken:LinkedListToken,
			stopToken:LinkedListToken):Void {
		if (left == null && right == null) {
			// IllegalArgumentException
			throw new Error('At least one of target and targetNext must be non-null');
		}
		if (startToken != null) {
			// i.e. we're not adding an imaginary node that currently
			//      has no real children
			if (left != null) {
				left.next = startToken;
			}
			stopToken.next = right;
			if (right != null) {
				right.previous = stopToken;
			}
		}
	}

}