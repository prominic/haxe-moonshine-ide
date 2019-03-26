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

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IBlock;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IIfStatement;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IIfStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class IfStatementNode extends ContainerDelegate implements IIfStatement {

	public var condition(get, set):IExpression;
	public var thenBlock(get, set):IBlock;
	public var elseBlock(get, set):IBlock;

	//--------------------------------------------------------------------------
	//
	//  IIfStatement API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  condition
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IIfStatement#condition
	 */
	private function get_condition():IExpression {
		return ExpressionBuilder.build(findCondition().getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_condition(value:IExpression):IExpression {
		if (value == null || value.node == null) {
			throw new ASBlocksSyntaxError('if condition connot be null');
		}
		findCondition().setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  thenBlock
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IIfStatement#thenBlock
	 */
	private function get_thenBlock():IBlock {
		return try cast(StatementBuilder.build(findThenClause()), IBlock) catch (e:Dynamic) null;
	}

	/**
	 * @private
	 */
	private function set_thenBlock(value:IBlock):IBlock {
		if (value == null || value.node == null) {
			throw new ASBlocksSyntaxError('if then block connot be null');
		}

		var ast:IParserNode = value.node;
		node.setChildAt(ast, 1);
		var indent:String = ASTUtil.findIndent(node);
		ASTUtil.increaseIndentAfterFirstLine(ast, indent);
		return value;
	}

	//----------------------------------
	//  elseBlock
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IIfStatement#elseBlock
	 */
	private function get_elseBlock():IBlock {
		var ast:IParserNode = findElseClause();
		if (ast == null) {
			setElseClause(ASTStatementBuilder.newBlock());
			ast = findElseClause();
		}

		var statement:IBlock = try cast(StatementBuilder.build(ast.getFirstChild()), IBlock) catch (e:Dynamic) null;
		if (statement == null) {
			throw new ASBlocksSyntaxError('Expecting an IBlock');
		}

		return statement;
	}

	/**
	 * @private
	 */
	private function set_elseBlock(value:IBlock):IBlock {
		var ast:IParserNode = findElseClause();
		if (ast != null) {
			node.removeChild(ast);
			if (value == null) {
				return value;
			}
		}
		setElseClause(value.node);
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
		var ast:IParserNode = findThenClause();
		if (!ast.isKind(AS3NodeKind.BLOCK)) {
			throw new ASBlocksSyntaxError('statement is not a block');
		}
		return new StatementList(ast);
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
		return node.getFirstChild();
	}

	/**
	 * @private
	 */
	private function findThenClause():IParserNode {
		return node.getChild(1);
	}

	/**
	 * @private
	 */
	private function findElseClause():IParserNode {
		return node.getChild(2);
	}

	/**
	 * @private
	 */
	private function setElseClause(ast:IParserNode):Void {
		var indent:String = ASTUtil.findIndent(node);
		var east:IParserNode = ASTBuilder.newAST(AS3NodeKind.ELSE);
		east.appendToken(TokenBuilder.newSpace());
		east.appendToken(TokenBuilder.newElse());
		node.addChild(east);
		east.appendToken(TokenBuilder.newSpace());
		east.addChild(ast);
		ASTUtil.increaseIndentAfterFirstLine(ast, indent);
	}

}