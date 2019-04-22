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
import org.as3commons.asblocks.api.IConditionalExpression;
import org.as3commons.asblocks.api.IExpression;

/**
 * The <code>IConditionalExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ConditionalExpressionNode extends ExpressionNode implements IConditionalExpression {

	//--------------------------------------------------------------------------
	//
	//  IConditionalExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  condition
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IConditionalExpression#condition
	 */
	public var condition(get, set):IExpression;
	private function get_condition():IExpression {
		return ExpressionBuilder.build(node.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_condition(value:IExpression):IExpression {
		node.setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  thenExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IConditionalExpression#thenExpression
	 */
	public var thenExpression(get, set):IExpression;
	private function get_thenExpression():IExpression {
		return ExpressionBuilder.build(node.getChild(1));
	}

	/**
	 * @private
	 */
	private function set_thenExpression(value:IExpression):IExpression {
		node.setChildAt(value.node, 1);
		return value;
	}

	//----------------------------------
	//  elseExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IConditionalExpression#elseExpression
	 */
	public var elseExpression(get, set):IExpression;
	private function get_elseExpression():IExpression {
		return ExpressionBuilder.build(node.getLastChild());
	}

	/**
	 * @private
	 */
	private function set_elseExpression(value:IExpression):IExpression {
		node.setChildAt(value.node, 2);
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