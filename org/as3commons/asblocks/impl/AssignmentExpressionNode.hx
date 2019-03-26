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

import org.as3commons.asblocks.api.IAssignmentExpression;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IAssignmentExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class AssignmentExpressionNode extends ExpressionNode implements IAssignmentExpression {

	public var leftExpression(get, set):IExpression;
	public var operator(get, set):String;
	public var rightExpression(get, set):IExpression;

	//--------------------------------------------------------------------------
	//
	//  IAssignmentExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  leftExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IAssignmentExpression#leftExpression
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
	//  operator
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IAssignmentExpression#operator
	 */
	private function get_operator():String {
		return node.getChild(1).stringValue;
	}

	/**
	 * @private
	 */
	private function set_operator(value:String):String {
		node.getChild(1).stringValue = value;
		return value;
	}

	//----------------------------------
	//  rightExpression
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IAssignmentExpression#rightExpression
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
		var ast:IParserNode = expression.node;
		//ASTBuilder.assertNoParent("expression", ast);
		// handle operator precedence issues
		node.setChildAt(ast, index);
	}

}