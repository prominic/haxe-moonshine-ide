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

import flash.errors.IllegalOperationError;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * @private
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ExpressionBuilder {

	/**
	 * @private
	 */
	public static function build(ast:IParserNode):IExpression {
		var _sw0_ = (ast.kind);
		switch (_sw0_) {
			case AS3NodeKind.NUMBER:
				return new NumberLiteralNode(ast);
			case AS3NodeKind.STRING:
				return new StringLiteralNode(ast);
			case AS3NodeKind.NULL:
				return new NullLiteralNode(ast);
			case AS3NodeKind.UNDEFINED:
				return new UndefinedLiteralNode(ast);
			case AS3NodeKind.TRUE, AS3NodeKind.FALSE:
				return new BooleanLiteralNode(ast);
			case AS3NodeKind.ADDITIVE, AS3NodeKind.EQUALITY, AS3NodeKind.RELATIONAL, AS3NodeKind.SHIFT, AS3NodeKind.MULTIPLICATIVE, AS3NodeKind.AND, AS3NodeKind.OR, AS3NodeKind.B_AND, AS3NodeKind.B_OR, AS3NodeKind.B_XOR:
				return new BinaryExpressionNode(ast);
			case AS3NodeKind.NOT, AS3NodeKind.B_NOT, AS3NodeKind.PRE_INC, AS3NodeKind.PRE_DEC, AS3NodeKind.PLUS, AS3NodeKind.MINUS:
				return new PrefixExpressionNode(ast);
			case AS3NodeKind.POST_INC, AS3NodeKind.POST_DEC:
				return new PostfixExpressionNode(ast);
			case AS3NodeKind.ENCAPSULATED:
				return build(ast.getFirstChild());
			case AS3NodeKind.CONDITIONAL:
				return new ConditionalExpressionNode(ast);
			case AS3NodeKind.CALL:
				return new InvocationExpressionNode(ast);
			case AS3NodeKind.ARRAY:
				return new ArrayLiteralNode(ast);
			case AS3NodeKind.LAMBDA:
				return new FunctionLiteralNode(ast);
			case AS3NodeKind.OBJECT:
				return new ObjectLiteralNode(ast);
			case AS3NodeKind.ASSIGNMENT:
				return new AssignmentExpressionNode(ast);
			case AS3NodeKind.PRIMARY, AS3NodeKind.TYPE, AS3NodeKind.ARRAY_ACCESSOR:
				switch (_sw0_) {case AS3NodeKind.TYPE: // FIXME TEMP
					return new SimpleNameExpressionNode(ast);
				}
				return new ArrayAccessExpressionNode(ast);
			case AS3NodeKind.NEW:
				return new NewExpressionNode(ast);
			case AS3NodeKind.DOT:
				return new FieldAccessExpressionNode(ast);
			case AS3NodeKind.VECTOR:
				return new VectorExpressionNode(ast);
			case _:
				throw new IllegalOperationError('unhandled expression node type: \' +
				ASTUtil.tokenName(ast.kind) + '\');
		}
	}

	public function new() {}

}