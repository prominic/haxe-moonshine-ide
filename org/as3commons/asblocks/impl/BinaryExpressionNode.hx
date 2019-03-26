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
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.api.BinaryOperator;
import org.as3commons.asblocks.api.IBinaryExpression;
import org.as3commons.asblocks.api.IExpression;

/**
 * The <code>IBinaryExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class BinaryExpressionNode extends ExpressionNode implements IBinaryExpression {

	public var leftExpression(get, set):IExpression;
	public var rightExpression(get, set):IExpression;
	public var operator(get, set):BinaryOperator;

	//--------------------------------------------------------------------------
	//
	//  IBinaryExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  leftExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IBinaryExpression#leftExpression
	 */
	private function get_leftExpression():IExpression {
		return ExpressionBuilder.build(node.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_leftExpression(value:IExpression):IExpression {
		setExpression(value, 0);
		return value;
	}

	//----------------------------------
	//  rightExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IBinaryExpression#rightExpression
	 */
	private function get_rightExpression():IExpression {
		return ExpressionBuilder.build(node.getLastChild());
	}

	/**
	 * @private
	 */
	private function set_rightExpression(value:IExpression):IExpression {
		setExpression(value, 2);
		return value;
	}

	//----------------------------------
	//  operator
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IBinaryExpression#operator
	 */
	private function get_operator():BinaryOperator {
		return BinaryOperator.opFromKind(node.getChild(1).kind);
	}

	/**
	 * @private
	 */
	private function set_operator(value:BinaryOperator):BinaryOperator {
		BinaryOperator.initializeFromOp(value, cast((node.getChild(1)), TokenNode).token);
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

	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function setExpression(expression:IExpression, index:Int):Void {
		node.setChildAt(expression.node, index);
	}

}