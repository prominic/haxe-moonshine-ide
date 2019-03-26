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

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.impl.TokenBuilder;

/**
 * @private
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class FormatterUtil {

	public static function breakParentheticNode(element:IScriptNode,
			kind:String,
			breakIt:Bool):Void {
		var paren:LinkedListToken = findFirstToken(element.node, kind);

		// to do this both ways
		// - find the paren
		// - check to see if a nl is before any token other than ws

		if (paren != null && breakIt)
		// add the nl before the curly
		{

			paren.prepend(TokenBuilder.newNewline());

			// add indentation
			var indent:String = ASTUtil.findIndent(element.node);
			paren.prepend(TokenBuilder.newWhiteSpace(indent));
		}
	}

	public static function findFirstToken(ast:IParserNode, kind:String):LinkedListToken {
		var tok:LinkedListToken = ast.startToken;
		while (tok != null) {
			if (tok.kind == kind) {
				return tok;
			}

			if (tok == ast.stopToken) {
				break;
			}
			tok = tok.next;
		}

		return null;
	}

	public static function appendNewlines(ast:IParserNode, token:LinkedListToken, count:Int):Void {
		var indent:String = ASTUtil.findIndent(ast);
		var len:Int = count;
		for (i in 0...len) {
			token.prepend(TokenBuilder.newNewline());
			token.prepend(TokenBuilder.newWhiteSpace(indent));
		}
	}

	public function new() {}

}