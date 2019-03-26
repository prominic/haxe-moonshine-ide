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

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IFieldAccessExpression;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IFieldAccessExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class FieldAccessExpressionNode extends ExpressionNode implements IFieldAccessExpression {

	public var name(get, set):String;
	public var target(get, set):IExpression;
	public var call(get, set):IExpression;

	// dot/[target]
	// dot/name

	//--------------------------------------------------------------------------
	//
	//  IFieldAccessExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFieldAccessExpression#name
	 */
	private function get_name():String {
		return ASTUtil.stringifyNode(node.getLastChild());
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		if (value == '') {
			throw new ASBlocksSyntaxError('Cannot set name to an empty string');
		} else if (value == null) {
			throw new ASBlocksSyntaxError('Cannot set name to null');
		}
		var ast:IParserNode = AS3FragmentParser.parseName(value);
		node.setChildAt(ast, 1);
		return value;
	}

	//----------------------------------
	//  target
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFieldAccessExpression#target
	 */
	private function get_target():IExpression {
		return ExpressionBuilder.build(node.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_target(value:IExpression):IExpression {
		node.setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  call
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFieldAccessExpression#call
	 */
	private function get_call():IExpression {
		return ExpressionBuilder.build(node.getLastChild());
	}

	/**
	 * @private
	 */
	private function set_call(value:IExpression):IExpression { //node.setChildAt(value.node, 0);

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