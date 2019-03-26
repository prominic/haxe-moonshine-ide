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

package org.as3commons.asblocks.utils;

import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.impl.ExpressionBuilder;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;

/**
 * @private
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ArgumentUtil {

	public static function getArguments(ast:IParserNode):Array<IExpression> {
		var result:Array<IExpression> = new Array<IExpression>();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			result.push(ExpressionBuilder.build(i.next()));
		}

		return result;
	}

	public static function setArguments(callAST:IParserNode, arguments:Array<IExpression>):Void {
		var ast:IParserNode = ASTUtil.newParentheticAST(
				AS3NodeKind.ARGUMENTS,
				AS3NodeKind.LPAREN, '(',
				AS3NodeKind.RPAREN, ')'
		);

		if (callAST.numChildren == 2) {
			callAST.setChildAt(ast, 1);
		} else {
			callAST.addChild(ast);
		}

		if (arguments == null) {
			return;
		}

		var len:Int = arguments.length;
		for (i in 0...len) {
			var element:IExpression = try cast(arguments[i], IExpression) catch (e:Dynamic) null;
			ast.addChild(element.node);
			if (i < len - 1) {
				ast.appendToken(TokenBuilder.newComma());
				ast.appendToken(TokenBuilder.newSpace());
			}
		}
	}

	public function new() {}

}