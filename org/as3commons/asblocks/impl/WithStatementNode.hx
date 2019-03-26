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
import org.as3commons.asblocks.api.IStatement;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.api.IWithStatement;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IWithStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class WithStatementNode extends ContainerDelegate implements IWithStatement {

	public var scope(get, set):IExpression;
	public var body(get, never):IStatement;

	//--------------------------------------------------------------------------
	//
	//  IWithStatement API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  scope
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IWithStatement#scope
	 */
	private function get_scope():IExpression {
		return ExpressionBuilder.build(findScope().getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_scope(value:IExpression):IExpression {
		findScope().setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  body
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IWithStatement#body
	 */
	private function get_body():IStatement {
		return StatementBuilder.build(findBlock());
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
		return new StatementList(node.getLastChild());
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
	private function findScope():IParserNode {
		return node.getFirstChild();
	}

	/**
	 * @private
	 */
	private function findBlock():IParserNode {
		return node.getLastChild();
	}

}