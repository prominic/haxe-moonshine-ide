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

import flash.errors.Error;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParser;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.core.Token;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.errors.NullTokenError;
import org.as3commons.asblocks.parser.errors.Position;
import org.as3commons.asblocks.parser.errors.UnExpectedTokenError;
import org.as3commons.asblocks.utils.FileUtil;

/**
 * The default base implementation of the IParser interface.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ParserBase implements IParser {

	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * The current <code>Token</code> scanned by the <code>scanner</code>.
	 */
	private var token:Token;

	/**
	 * The adapter.
	 */
	private var adapter:LinkedListTreeAdaptor;

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  scanner
	//----------------------------------

	/**
	 * @private
	 */
	private var _scanner:IScanner;

	/**
	 * The scanner the parser uses internally.
	 */
	public var scanner(get, never):IScanner;
	private function get_scanner():IScanner {
		return _scanner;
	}

	//----------------------------------
	//  fileName
	//----------------------------------

	/**
	 * @private
	 */
	public static var _fileName:String;

	/**
	 * The fileName being parsed (if any).
	 */
	public var fileName(get, never):String;
	private function get_fileName():String {
		return _fileName;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new() {
		_scanner = createScanner();
	}

	//--------------------------------------------------------------------------
	//
	//  IParser API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.as3parser.api.IParser#buildFileAst()
	 */
	public function buildFileAst(fileName:String):IParserNode {
		var lines:Array<String>;

		try {
			lines = FileUtil.readLines(fileName);
		} catch (e:Error) {
			throw e;
		}

		return parseLines(lines, fileName);
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParser#buildAst()
	 */
	public function buildAst(lines:Array<String>,
			fileName:String):IParserNode {
		return parseLines(lines, fileName);
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Parses and returns the root <code>IParserNode</code>.
	 *
	 * <p><em>Override in subclasses.</em></p>
	 *
	 * @return The root <code>IParserNode</code>.
	 */
	public function parseCompilationUnit():IParserNode {
		return null;
	}

	/**
	 * Retrieves the next Token from the scanner.
	 */
	public function nextToken():Void {
		//moveToNextToken();
		token = scanner.nextToken();

		if (token == null) {
			return;
		}
		if (token.text == null) {
			return;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Parses and returns the <code>IParserNode</code> base compilation element.
	 *
	 * @param lines A Vector of String lines to be parsed into an AST.
	 * @param filePath A String indicating the location of the source.
	 */
	private function parseLines(lines:Array<String>,
			fileName:String):IParserNode {
		_scanner = createScanner();
		_scanner.setLines(lines);

		_fileName = fileName;
		token = null;

		initialize();

		return parseCompilationUnit();
	}

	/**
	 * Creates the <code>IScanner</code> for the parser.
	 *
	 * <p><em>Override in subclasses.</em></p>
	 *
	 * @return An <code>IScanner</code> instance.
	 */
	private function createScanner():IScanner {
		throw new Error('Must create IScanner by overridding ParserBase.createScanner()');
		return null;
	}

	/**
	 * Initializes the parser session.
	 *
	 * <p><em>Override in subclasses.</em></p>
	 */
	private function initialize():Void {}

	/**
	 * Moves the parser's <code>token</code> to the next scanner Token.
	 *
	 * <p>This method can be overridden in a subclass to enhance
	 * functionality. The default behavior is to call
	 * <code>scanner.nextToken()</code></p>
	 *
	 * @throws NullTokenError
	 */
	private function _moveToNextToken():Void {
		token = scanner.nextToken();

		if (token == null) {
			throw new NullTokenError(fileName);
		}
		if (token.text == null) {
			throw new NullTokenError(fileName);
		}
	}

	/**
	 * Moves the parser's <code>token</code> to the next scanner Token that
	 * is not considered whitespace or a comment.
	 *
	 * <p>If the node is not null, the parser will append those whitespace
	 * tokens to the node.</p>
	 *
	 * @param node A TokenNode to add whitespace tokens to.
	 * @see #tokIsWhitespace()
	 */
	private function nextTokenConsume(node:TokenNode):Void {
		if (consumeWhitespace(node)) {
			return;
		}

		nextToken();

		consumeWhitespace(node);
	}

	/**
	 * Allows whitespace tokens to be retireved from the scanner.
	 *
	 * @see #moveToNextToken()
	 */
	private function nextTokenAllowWhiteSpace():Void {
		scanner.allowWhiteSpace = true;
		//moveToNextToken();
		nextToken();
		scanner.allowWhiteSpace = false;
	}

	/**
	 * Skips the token if the <code>token.text</code> equals <code>text</code>.
	 *
	 * @param text The String to skip.
	 */
	private function skip(text:String, node:TokenNode = null):Void {
		consumeWhitespace(node);

		if (tokIs(text)) {
			if (node != null && node.stringValue != text) {
				append(node);
			}

			nextToken();
		}

		consumeWhitespace(node);
	}

	/**
	 * Returns whether the current parser token is whitespace.
	 *
	 * @return A Boolean indicating if the current token is whitespace.
	 */
	private function tokIsWhitespace():Bool {
		return token.text == ' ' || token.text == '\t' || token.text == '\n' || tokenStartsWith('/*') || tokenStartsWith('//');
	}

	/**
	 * Consumes the current text.
	 *
	 * <p>If the current token's text does not equal text, an UnExpectedTokenError
	 * is thrown.</p>
	 *
	 * <p>If the token is consumed, the parser advances to the next token.</p>
	 *
	 * @param text The text String to consume.
	 * @param node A TokenNode to append tokens to.
	 * @throws UnExpectedTokenError
	 */
	private function consume(text:String,
			node:TokenNode = null,
			trim:Bool = true):LinkedListToken {
		var consumed:LinkedListToken;

		if (node != null && trim) {
			consumeWhitespace(node);
		}

		if (!tokIs(text)) {
			throw new UnExpectedTokenError(
			text,
			token.text,
			new Position(token.line, token.column, -1),
			fileName);
		}

		if (node != null && node.stringValue != text) {
			consumed = append(node);
		}

		nextToken();

		if (node != null && trim) {
			consumeWhitespace(node);
		}

		return consumed;
	}

	/**
	 * Checks for token equality and only appends whitespace tokens.
	 *
	 * @param node A TokenNode to append whitespace tokens to.
	 */
	private function consumeWS(text:String,
			node:TokenNode = null,
			trim:Bool = true):Void {
		if (trim) {
			consumeWhitespace(node);
		}

		if (!tokIs(text)) {
			throw new UnExpectedTokenError(
			text,
			token.text,
			new Position(token.line, token.column, -1),
			fileName);
		}

		nextToken();

		if (trim) {
			consumeWhitespace(node);
		}
	}

	private function consumeParenthetic(text:String,
			node:TokenNode = null,
			trim:Bool = true):Void {
		if (!tokIs(text)) {
			throw new UnExpectedTokenError(
			text,
			token.text,
			new Position(token.line, token.column, -1),
			fileName);
		}

		nextToken();
	}

	/**
	 * Consumes all whitespace up to a non whitespace token.
	 *
	 * @param node A TokenNode to add whitespace tokens to.
	 * @return A Boolean indicating if whitespace was consumed.
	 */
	private function consumeWhitespace(node:TokenNode):Bool {
		if (node == null || token == null) {
			return false;
		}

		var advanced:Bool = false;

		while (token.text == ' ' || token.text == '\t' || token.text == '\n' || token.text.indexOf('//') == 0 || (token.text.indexOf('/*') == 0 && token.text.indexOf('/**') != 0 == 0)) {
			if (token.text == ' ') {
				appendSpace(node);
			} else if (token.text == '\t') {
				appendTab(node);
			} else if (token.text == '\n') {
				appendNewline(node);
			} else if (token.text.indexOf('//') == 0 || (token.text.indexOf('/*') == 0 && token.text.indexOf('/**') != 0 == 0)) {
				appendComment(node);
			}

			advanced = true;
		}

		return advanced;
	}

	//--------------------------------------------------------------------------
	//
	//  Protected Final :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Compare the current <code>token.text</code> to <code>text</code>.
	 *
	 * @param text A String to compare.
	 * @return A Boolean true, if token's text property equals the parameter.
	 */
	@:final private function tokIs(text:String):Bool {
		if (token != null) {
			return token.text == text;
		} else {
			return false;
		}
	}

	/**
	 * Returns whether the token starts with the String value.
	 *
	 * @param value A String to test.
	 * @return A Boolean indicating whether the token's text starts with the
	 * value.
	 */
	@:final private function tokenStartsWith(value:String):Bool {
		if (token != null) {
			return token.text.indexOf(value) == 0;
		} else {
			return false;
		}
	}

	/**
	 * Trims quotes off a String.
	 *
	 * @param value A String quoted.
	 * @return A new String with start and end trimmed.
	 */
	@:final private function trimQuotes(value:String):String {
		return Std.string(value.substring(1, value.length - 1));
	}

	/**
	 * @private
	 */
	private function append(node:TokenNode):LinkedListToken {
		if (node == null) {
			return null;
		}

		var token:LinkedListToken = adapter.createToken(
				token.text, token.text,
				token.line, token.column
		);

		node.appendToken(token);

		return token;
	}

	/**
	 * @private
	 */
	private function appendSpace(node:TokenNode):Void {
		if (node == null || !scanner.allowWhiteSpace) {
			return;
		}

		if (node != null) {
			node.appendToken(
					adapter.createToken(AS3NodeKind.WS, ' ',
							token.line, token.column
				)
			);
		}

		nextToken();
	}

	/**
	 * @private
	 */
	private function appendTab(node:TokenNode):Void {
		if (node == null || !scanner.allowWhiteSpace) {
			return;
		}

		if (node != null) {
			node.appendToken(
					adapter.createToken(AS3NodeKind.WS, '\t',
							token.line, token.column
				)
			);
		}

		nextToken();
	}

	/**
	 * @private
	 */
	private function appendNewline(node:TokenNode):Void {
		if (node == null || !scanner.allowWhiteSpace) {
			return;
		}

		var tok:LinkedListToken;

		if (node != null) {
			tok = adapter.createToken(AS3NodeKind.WS, '\n',
							token.line, token.column
				);
		}

		nextToken();

		if (tok != null && !tokIs(KeyWords.EOF)) {
			node.appendToken(tok);
		}
	}

	/**
	 * @private
	 */
	private function appendComment(node:TokenNode):Void {
		if (node == null) {
			return;
		}

		if (node != null) {
			node.appendToken(
					adapter.createToken(AS3NodeKind.COMMENT, token.text,
							token.line, token.column
				)
			);
		}

		nextToken();
	}

}