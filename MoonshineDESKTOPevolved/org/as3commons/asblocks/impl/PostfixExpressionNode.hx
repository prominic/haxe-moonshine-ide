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

import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IPostfixExpression;
import org.as3commons.asblocks.api.PostfixOperator;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.TokenNode;

/**
 * The <code>IPostfixExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class PostfixExpressionNode extends ExpressionNode implements IPostfixExpression {

	//--------------------------------------------------------------------------
	//
	//  IPostfixExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  expression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IPostfixExpression#expression
	 */
	public var expression(get, set):IExpression;
	private function get_expression():IExpression {
		return ExpressionBuilder.build(node.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_expression(value:IExpression):IExpression {
		node.setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  operator
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IPostfixExpression#operator
	 */
	public var operator(get, set):PostfixOperator;
	private function get_operator():PostfixOperator {
		return PostfixOperator.opFromKind(node.kind);
	}

	/**
	 * @private
	 */
	private function set_operator(value:PostfixOperator):PostfixOperator {
		PostfixOperator.initializeFromOp(value, node);
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