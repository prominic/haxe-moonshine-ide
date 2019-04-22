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
import org.as3commons.asblocks.api.IForStatement;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;

/**
 * The <code>IForStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ForStatementNode extends ContainerDelegate implements IForStatement {

	//--------------------------------------------------------------------------
	//
	//  IForStatement API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  initializer
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IForStatement#initializer
	 */
	public var initializer(get, set):IScriptNode;
	private function get_initializer():IScriptNode {
		var ast:IParserNode = findInit();
		if (ast == null) {
			return null;
		}

		ast = ast.getFirstChild();

		if (ast.isKind(AS3NodeKind.DEC_LIST)) {
			return new DeclarationStatementNode(ast);
		} else {
			return ExpressionBuilder.build(ast);
		}

		return null;
	}

	/**
	 * @private
	 */
	private function set_initializer(value:IScriptNode):IScriptNode {
		var ast:IParserNode = findInit();
		if (value == null && ast != null) {
			node.removeChild(ast);
		} else if (value != null) {
			if (ast == null) {
				ast = ASTBuilder.newAST(AS3NodeKind.INIT);
				node.addChildAt(ast, 0);
			}

			var last:LinkedListToken = value.node.stopToken;
			if (last.text == ';') {
				var prev:LinkedListToken = last.previous;
				last.remove();
				value.node.stopToken = prev;
			}
			ast.setChildAt(value.node, 0);
		}
		return value;
	}

	//----------------------------------
	//  condition
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IForStatement#condition
	 */
	public var condition(get, set):IExpression;
	private function get_condition():IExpression {
		var ast:IParserNode = findCondition();
		if (ast == null) {
			return null;
		}

		return ExpressionBuilder.build(ast.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_condition(value:IExpression):IExpression {
		var ast:IParserNode = findCondition();
		if (value == null && ast != null) {
			node.removeChild(ast);
		} else if (value != null) {
			if (ast == null) {
				ast = ASTBuilder.newAST(AS3NodeKind.COND);
				node.addChildAt(ast, 1);// FIXME (mschmalle) this index is not certain
			}

			ast.setChildAt(value.node, 0);
		}
		return value;
	}

	//----------------------------------
	//  iterator
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IForStatement#iterator
	 */
	public var iterator(get, set):IExpression;
	private function get_iterator():IExpression {
		var ast:IParserNode = findIterator();
		if (ast == null) {
			return null;
		}

		return ExpressionBuilder.build(ast.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_iterator(value:IExpression):IExpression {
		var ast:IParserNode = findIterator();
		if (value == null && ast != null) {
			node.removeChild(ast);
		} else if (value != null) {
			if (ast == null) {
				ast = ASTBuilder.newAST(AS3NodeKind.ITER);
				node.addChildAt(ast, 2);// FIXME (mschmalle) this index is not certain
			}

			ast.setChildAt(value.node, 0);
		}
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
		return new StatementList(node.getLastChild());// block
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
	private function findInit():IParserNode {
		return node.getKind(AS3NodeKind.INIT);
	}

	/**
	 * @private
	 */
	private function findCondition():IParserNode {
		return node.getKind(AS3NodeKind.COND);
	}

	/**
	 * @private
	 */
	private function findIterator():IParserNode {
		return node.getKind(AS3NodeKind.ITER);
	}

}