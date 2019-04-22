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
import org.as3commons.asblocks.api.ICatchClause;
import org.as3commons.asblocks.api.IFinallyClause;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.api.ITryStatement;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>ITryStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TryStatementNode extends ContainerDelegate implements ITryStatement {

	// try-stmnt
	// try-stmnt/try
	// try-stmnt/catch[i]
	// try-stmnt/finally

	//--------------------------------------------------------------------------
	//
	//  ITryStatement API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  catchClauses
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#catchClauses
	 */
	public var catchClauses(get, never):Array<ICatchClause>;
	private function get_catchClauses():Array<ICatchClause> {
		var result:Array<ICatchClause> = new Array<ICatchClause>();
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext()) {
			var ast:IParserNode = i.search(AS3NodeKind.CATCH);
			if (ast == null) {
				return result;
			}

			result.push(new CatchClauseNode(ast));
		}
		return result;
	}

	//----------------------------------
	//  finallyClause
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#finallyClause
	 */
	public var finallyClause(get, never):IFinallyClause;
	private function get_finallyClause():IFinallyClause {
		var ast:IParserNode = findFinallyClause();
		if (ast == null) {
			return null;
		}
		return new FinallyClauseNode(ast);
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
		return new StatementList(findTryClause().getFirstChild());// try-stmnt/try/block
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
	//  ITryStatement API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#newCatchClause()
	 */
	public function newCatchClause(name:String, type:String):ICatchClause {
		var ast:IParserNode = ASTStatementBuilder.newCatchClause(name, type);

		var space:LinkedListToken = TokenBuilder.newSpace();
		// add a space before the catch keyword
		ast.startToken.prepend(space);
		// set the start of the chain to the space
		ast.startToken = space;

		var f:IParserNode = findFinallyClause();
		var index:Int = ((f != null)) ? node.getChildIndex(f) - 1 : node.numChildren;
		// add the catch node
		node.addChildAt(ast, index);
		// get the current indent of the try statement
		var indent:String = ASTUtil.findIndent(node);
		// push the indent into the catch tokens
		ASTUtil.increaseIndentAfterFirstLine(ast, indent);
		return new CatchClauseNode(ast);
	}

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#removeCatch()
	 */
	public function removeCatch(statement:ICatchClause):ICatchClause {
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext()) {
			var ast:IParserNode = i.search(AS3NodeKind.CATCH);
			if (ast == statement.node) {
				i.remove();
				return statement;
			}
		}
		return null;
	}

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#newFinallyClause()
	 */
	public function newFinallyClause():IFinallyClause {
		var ast:IParserNode = findFinallyClause();
		if (ast != null) {
			throw new ASBlocksSyntaxError('only one finally-clause allowed');
		}
		ast = ASTStatementBuilder.newFinallyClause();
		node.addChild(ast);
		return new FinallyClauseNode(ast);
	}

	/**
	 * @copy org.as3commons.asblocks.api.ITryStatement#removeFinally()
	 */
	public function removeFinally():IFinallyClause {
		var ast:IParserNode = findFinallyClause();
		if (ast == null) {
			return null;
		}

		node.removeChild(ast);

		return new FinallyClauseNode(ast);
	}

	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function findTryClause():IParserNode {
		return node.getKind(AS3NodeKind.TRY);
	}

	/**
	 * @private
	 */
	private function findFinallyClause():IParserNode {
		return node.getKind(AS3NodeKind.FINALLY);
	}

}