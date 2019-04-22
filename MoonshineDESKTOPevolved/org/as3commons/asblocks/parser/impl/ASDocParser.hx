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

package org.as3commons.asblocks.parser.impl;

import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.ASDocNodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.errors.Position;
import org.as3commons.asblocks.parser.errors.UnExpectedTokenError;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The default implementation of an asdoc comment parser.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ASDocParser extends ParserBase {

	//--------------------------------------------------------------------------
	//
	// Public :: Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public static inline var NL:String = '\n';

	/**
	 * @private
	 */
	public static inline var TAB:String = '\t';

	/**
	 * @private
	 */
	public static inline var SPACE:String = ' ';

	/**
	 * @private
	 */
	public static inline var ML_START:String = '/**';

	/**
	 * @private
	 */
	public static inline var ML_END:String = '*/';

	/**
	 * @private
	 */
	public static inline var ASTRIX:String = '*';

	/**
	 * @private
	 */
	public static inline var AT:String = '@';

	/**
	 * @private
	 */
	public static inline var CURLY_AT:String = '{@';

	/**
	 * @private
	 */
	public static inline var RCURLY:String = '}';

	/**
	 * @private
	 */
	public static inline var EOF:String = '__END__';

	//--------------------------------------------------------------------------
	//
	// Private :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _bodyFound:Bool = false;

	//--------------------------------------------------------------------------
	//
	// Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new() {
		super();

		adapter = new LinkedListTreeAdaptor();
	}

	//--------------------------------------------------------------------------
	//
	// Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override public function parseCompilationUnit():IParserNode {
		var result:TokenNode = adapter.create(ASDocNodeKind.COMPILATION_UNIT);
		nextToken();// /**
		result.addChild(parseDescription());
		return result;
	}

	//--------------------------------------------------------------------------
	//
	// Overridden Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override private function createScanner():IScanner {
		return new ASDocScanner();
	}

	/**
	 * @private
	 */
	override private function initialize():Void {}

	//--------------------------------------------------------------------------
	//
	// Internal Parse :: Methods
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	// description
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.parser.impl)
	private function parseDescription():IParserNode {
		var result:TokenNode = AS3.as(ASTUtil.newParentheticAST(
				ASDocNodeKind.DESCRIPTION,
				ASDocNodeKind.ML_START, '/**',
				ASDocNodeKind.ML_END, '*/'
		), TokenNode);

		consumeParenthetic(ML_START);// /**

		while (!tokIs(EOF) && !tokIs(ML_END)) {
			if (tokIs(AT)) {
				result.addChild(parseDocTagList());
			} else {
				result.addChild(parseBody());
			}
		}

		if (currentNL != null) {
			currentNL.startToken.channel = 'hidden';
		}

		consumeParenthetic(ML_END);// */

		return result;
	}

	//----------------------------------
	// body
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.parser.impl)
	private function parseBody():IParserNode {
		foundNL = false;
		currentNL = null;

		var result:TokenNode = adapter.empty(ASDocNodeKind.BODY, token);

		consumeWhitespace(result);

		while (!tokIs(EOF) && !tokIs(ML_END) && !tokIs(AT) && !tokIs(CURLY_AT)) {
			if (tokIsValid()) {
				if (tokIs(NL)) {
					result.addChild(parseNewline());
				} else {
					result.addChild(parseTextBlock());
				}
			} else {
				consumeWhitespace(result);
			}
		}

		return result;
	}

	//----------------------------------
	// text-block
	//----------------------------------

	/**
	 * @private
	 */
	private function parseTextBlock():TokenNode {
		var result:TokenNode = adapter.empty(ASDocNodeKind.TEXT_BLOCK, token);

		while (!tokIs(EOF) && !tokIs(ML_END) && !tokIs(AT) && !tokIs(RCURLY) && !tokIs('</')) {
			if (tokIs(NL)) {
				result.addChild(parseNewline());
			} else if (tokenStartsWith('<') && isBlock(token.text)) {
				result.addChild(parseTag(token.text.substring(1)));
			} else if (tokIs(CURLY_AT)) {
				result.addChild(parseInlineDocTag());
			} else {
				parseTextStream(result);
			}
		}

		return result;
	}

	//----------------------------------
	// text[i]
	//----------------------------------

	/**
	 * @private
	 */
	private function parseTextStream(node:TokenNode):Void {
		var text:String = '';

		while (!tokIs(EOF) && !tokIs(ML_END) && !tokIs(AT) && !tokIs(CURLY_AT) && !tokIs(RCURLY) && !tokIs(NL) && !isBlock(token.text)) {
			if (tokIsValid()) {
				text += token.text;
				nextToken();
			} else {
				if (text != '') {
					node.addChild(adapter.create(ASDocNodeKind.TEXT, text));
					text = '';
				}
				consumeWhitespace(node);
			}
		}
		if (text != '') {
			node.addChild(adapter.create(ASDocNodeKind.TEXT, text));
		}
	}

	/**
	 * @private
	 */
	private function parseTagStream(node:TokenNode):Void {
		var text:String = '';

		while (!tokIs(EOF) && !tokIs(ML_END) && !tokIs(AT) && !tokIs(NL) && !isBlock(token.text) && !tokIs('</')) {
			if (tokIsValid()) {
				text += token.text;
				nextToken();
			} else {
				if (text != '') {
					node.addChild(adapter.create(ASDocNodeKind.TEXT, text));
					text = '';
				}
				consumeWhitespace(node);
			}
		}
		if (text != '') {
			node.addChild(adapter.create(ASDocNodeKind.TEXT, text));
		}
	}

	//----------------------------------
	// doctag-list
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.parser.impl)
	private function parseDocTagList():IParserNode {
		var result:TokenNode = adapter.empty(ASDocNodeKind.DOCTAG_LIST, token);

		while (!tokIs(EOF) && !tokIs(ML_END)) {
			result.addChild(parseDocTag());
		}

		return result;
	}

	//----------------------------------
	// doctag
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.parser.impl)
	private function parseDocTag():TokenNode {
		var result:TokenNode = adapter.empty(ASDocNodeKind.DOCTAG, token);

		consume(AT, result);

		result.addChild(parseDocTagName());
		result.addChild(parseDocTagBody());

		return result;
	}

	//----------------------------------
	// doctag-name
	//----------------------------------

	/**
	 * @private
	 */
	private function parseDocTagName():TokenNode {
		var result:TokenNode = adapter.copy(ASDocNodeKind.NAME, token);
		nextToken();// name
		return result;
	}

	//----------------------------------
	// doctag-body
	//----------------------------------

	/**
	 * @private
	 */
	private function parseDocTagBody():TokenNode {
		var result:TokenNode = adapter.empty(ASDocNodeKind.BODY, token);

		while (!tokIs(ML_END) && !tokIs(AT) && !tokIs(RCURLY)) {
			if (tokIsValid()) {
				result.addChild(parseTextBlock());
			} else {
				consumeWhitespace(result);
			}
		}

		return result;
	}

	//----------------------------------
	// doctag
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.parser.impl)
	private function parseInlineDocTag():TokenNode {
		var result:TokenNode = adapter.empty(ASDocNodeKind.INLINE_DOCTAG, token);

		consume(CURLY_AT, result);

		result.addChild(parseDocTagName());
		result.addChild(parseDocTagBody());

		consume(RCURLY, result);

		return result;
	}

	//----------------------------------
	// *-tag
	//----------------------------------

	/**
	 * @private
	 */
	private function parseTag(name:String):TokenNode {
		var result:TokenNode = adapter.empty(name + '-block', token);

		var skip:Bool = false;

		consumeTag(result, '<' + name);

		// eat attributes
		if (!tokIs('>')) {
			while (!tokIs('>')) {
				consumeTag(result, token.text);
			}
		}

		consumeTag(result, '>');

		while (!tokIs(EOF) && !tokIs(ML_END)) {
			if (tokIs('</')) {
				nextToken();// </"
				if (tokIs(name)) {
					skip = true;
					break;
				}// this needs to be fixed; append the embeded pre end tag
				else {
					// this needs to be fixed; append the embeded pre end tag
					result.addChild(adapter.create(ASDocNodeKind.TEXT, '</'));
				}
			} else if (tokIs(NL)) {
				result.addChild(parseNewline());
			} else if (tokenStartsWith('<') && isBlock(token.text)) {
				result.addChild(parseTag(token.text.substring(1)));
			} else {
				parseTagStream(result);
			}
		}

		if (!skip) {
			consumeTag(result, '</');
		}// the while kicked out at '</', must record
		else {
			// the while kicked out at '</', must record
			result.appendToken(TokenBuilder.newToken('tag', '</'));
		}

		consumeTag(result, name);
		consumeTag(result, '>');

		return result;
	}

	//----------------------------------
	// nl
	//----------------------------------

	private var foundNL:Bool = false;

	private var currentNL:TokenNode;

	/**
	 * @private
	 */
	private function parseNewline():TokenNode {
		currentNL = adapter.create(ASDocNodeKind.NL);
		if (!foundNL) {
			currentNL.startToken.channel = 'hidden';
			foundNL = true;
		}
		currentNL.appendToken(TokenBuilder.newToken(ASDocNodeKind.NL, token.text));
		nextToken();
		return currentNL;
	}

	/**
	 * @private
	 */
	override private function consumeWhitespace(node:TokenNode):Bool {
		if (node == null || token == null) {
			return false;
		}

		var advanced:Bool = false;

		while (token.kind == ASDocNodeKind.WS || token.kind == ASDocNodeKind.ASTRIX) {
			if (token.text == ' ') {
				appendSpace(node);
			} else if (token.text == '\t') {
				appendTab(node);
			} else if (token.text == '*') {
				appendAstrix(node);
			}

			advanced = true;
		}

		return advanced;
	}

	/**
	 * @private
	 */
	private function appendAstrix(node:TokenNode):Void {
		if (node == null || !scanner.allowWhiteSpace) {
			return;
		}

		if (node != null) {
			node.appendToken(
					adapter.createToken('astrix', '*',
							token.line, token.column
				)
			);
		}

		nextToken();
	}

	/**
	 * @private
	 */
	private function tokIsValid():Bool {
		return token.kind != 'ws' && token.kind != 'astrix';
	}

	/**
	 * @private
	 */
	private function isBlock(name:String):Bool {
		if (!tokenStartsWith('<')) {
			return false;
		}

		// TODO (mschmalle) put asdoc block types in Enum
		var blocks:Dynamic =
		{
			'p': true,
			'code': true,
			'pre': true,
			'strong': true,
			'i': true,
			'ul': true,
			'li': true,
			'listing': true
		};

		return Reflect.field(blocks, name.substring(1)) != null;
	}

	/**
	 * @private
	 */
	private function consumeTag(node:TokenNode, text:String):Void {
		if (!tokIs(text)) {
			throw new UnExpectedTokenError(
			text,
			token.text,
			new Position(token.line, token.column, -1),
			fileName);
		}

		nextTokenAppend(node, 'tag', text);
	}

	/**
	 * @private
	 */
	private function appendToken(node:TokenNode,
			kind:String,
			text:String):LinkedListToken {
		var token:LinkedListToken = adapter.createToken(
				kind, text, token.line, token.column
		);

		node.appendToken(token);

		return token;
	}

	/**
	 * @private
	 */
	private function nextTokenAppend(node:TokenNode, kind:String, text:String):Void {
		node.appendToken(TokenBuilder.newToken(kind, text));
		nextToken();
	}

}