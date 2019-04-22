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
import org.as3commons.asblocks.api.IDoWhileStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IStatementContainer;

/**
 * The <code>IDoWhileStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class DoWhileStatementNode extends ContainerDelegate implements IDoWhileStatement {

	//--------------------------------------------------------------------------
	//
	//  IDoWhileStatementNode API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  condition
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDoWhileStatement#condition
	 */
	public var condition(get, set):IExpression;
	private function get_condition():IExpression {
		return ExpressionBuilder.build(findCondition().getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_condition(value:IExpression):IExpression {
		findCondition().setChildAt(value.node, 0);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override private function get_statementContainer():IStatementContainer {
		return new StatementList(node.getFirstChild());
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
	private function findCondition():IParserNode {
		return node.getLastChild();
	}

}