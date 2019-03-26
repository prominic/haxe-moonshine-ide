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

import flash.errors.Error;

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.impl.ASQName;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTPrinter;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParser;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.parser.core.Token;
import org.as3commons.asblocks.parser.errors.NullTokenError;
import org.as3commons.asblocks.parser.errors.UnExpectedTokenError;
import org.as3commons.asblocks.parser.impl.AS3Parser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;
import org.as3commons.mxmlblocks.parser.impl.MXMLParser;

/**
 * @private
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ASTUtil {

	private static var adapter:LinkedListTreeAdaptor = new LinkedListTreeAdaptor();

	public static function getLastTagList(ast:IParserNode):IParserNode {
		var i:ASTIterator = new ASTIterator(ast);
		var child:IParserNode;
		while (i.hasNext()) {
			child = i.search(MXMLNodeKind.TAG_LIST);
		}

		return child;
	}

	public static function findTagStart(ast:IParserNode):LinkedListToken {
		if (ast == null) {
			return null;
		}

		// <tag>\n
		// \t<tag2 ti="s">\n
		// \t</tag2>\n
		// </tag>
		var startAST:IParserNode = ast;
		if (ast.hasKind(MXMLNodeKind.TAG_LIST)) {
			startAST = getLastTagList(ast);
		}

		var tok:LinkedListToken = startAST.startToken;
		while (tok.text != '>') {
			if (tok.next == null) {
				break;
			}
			tok = tok.next;
		}

		return tok;
	}

	public static function findTagStop(ast:IParserNode):LinkedListToken {
		if (ast == null) {
			return null;
		}
		// <tag>\n
		// \t<tag2 ti="s">\n
		// \t</tag2>\n
		// </tag>

		var endAST:IParserNode = ast;
		if (ast.hasKind(MXMLNodeKind.TAG_LIST)) {
			endAST = getLastTagList(ast);
		}

		var tok:LinkedListToken = endAST.stopToken;
		while (tok.text != '</') {
			if (tok.previous == null) {
				break;
			}
			tok = tok.previous;
		}

		return tok;
	}

	public static function findXMLIndent(node:IParserNode):String {
		if (node == null) {
			return '';
		}

		var tok:LinkedListToken = node.startToken;
		tok = tok.next;
		if (tok == null) {
			return findIndent(node.parent);
		}

		// the start-token of this AST node is actually whitespace, so
		// scan forward until we hit a non-WS token,
		while (tok.kind == AS3NodeKind.NL || tok.kind == AS3NodeKind.WS) {
			if (tok.next == null) {
				break;
			}
			tok = tok.next;
		}
		// search backwards though the tokens, looking for the start of
		// the line,
		while (tok.previous != null) {
			if (tok.kind == AS3NodeKind.NL) {
				break;
			}
			tok = tok.previous;
		}
		if (tok.kind == AS3NodeKind.WS) {
			return tok.text;
		}
		if (tok.kind != AS3NodeKind.NL) {
			return '';
		}

		var startOfLine:LinkedListToken = tok.next;

		if (startOfLine.kind == AS3NodeKind.WS) {
			return startOfLine.text;
		}
		return '';
	}

	public static function findIndent(node:IParserNode):String {
		var tok:LinkedListToken = node.startToken;
		if (tok == null) {
			return findIndent(node.parent);
		}

		// the start-token of this AST node is actually whitespace, so
		// scan forward until we hit a non-WS token,
		while (tok.kind == AS3NodeKind.NL || tok.kind == AS3NodeKind.WS) {
			if (tok.next == null) {
				break;
			}
			tok = tok.next;
		}
		// search backwards though the tokens, looking for the start of
		// the line,
		while (tok.previous != null) {
			if (tok.kind == AS3NodeKind.NL) {
				break;
			}
			tok = tok.previous;
		}
		if (tok.kind == AS3NodeKind.WS) {
			return tok.text;
		}
		if (tok.kind != AS3NodeKind.NL) {
			return '';
		}

		var startOfLine:LinkedListToken = tok.next;

		if (startOfLine.kind == AS3NodeKind.WS) {
			return startOfLine.text;
		}
		return '';
	}

	public static function newParenAST(kind:String, token:Token):IParserNode {
		var result:IParserNode = ASTUtil.newParentheticAST(
				kind,
				AS3NodeKind.LPAREN, '(',
				AS3NodeKind.RPAREN, ')'
		);
		result.line = token.line;
		result.column = token.column;
		return result;
	}

	public static function newCurlyAST(kind:String, token:Token):IParserNode {
		var result:IParserNode = ASTUtil.newParentheticAST(
				kind,
				AS3NodeKind.LCURLY, '{',
				AS3NodeKind.RCURLY, '}'
		);
		result.line = token.line;
		result.column = token.column;
		return result;
	}

	public static function newBracketAST(kind:String, token:Token):IParserNode {
		var result:IParserNode = ASTUtil.newParentheticAST(
				kind,
				AS3NodeKind.LBRACKET, '[',
				AS3NodeKind.RBRACKET, ']'
		);
		result.line = token.line;
		result.column = token.column;
		return result;
	}

	public static function newParentheticAST(kind:String,
			startKind:String,
			startText:String,
			endKind:String,
			endText:String):IParserNode {
		var ast:IParserNode = ASTBuilder.newAST(kind);
		var start:LinkedListToken = TokenBuilder.newToken(startKind, startText);
		ast.startToken = start;
		var stop:LinkedListToken = TokenBuilder.newToken(endKind, endText);
		ast.stopToken = stop;
		start.next = stop;
		ast.initialInsertionAfter = start;
		return ast;
	}

	public static function increaseIndent(node:IParserNode, indent:String):Void {
		var newStart:LinkedListToken = increaseIndentAt(node.startToken, indent);
		node.startToken = newStart;
		increaseIndentAfterFirstLine(node, indent);
	}

	public static function increaseIndentAfterFirstLine(node:IParserNode, indent:String):Void {
		var tok:LinkedListToken = node.startToken;
		while (tok != node.stopToken) {
			var _sw0_ = (tok.kind);
			switch (_sw0_) {
				case AS3NodeKind.NL:
					tok = increaseIndentAt(tok.next, indent);
				case AS3NodeKind.AS_DOC:
				//					DocCommentUtils.increaseCommentIndent(tok, indent);
				break;
			}
			tok = tok.next;
		}
	}

	private static function increaseIndentAt(tok:LinkedListToken, indentStr:String):LinkedListToken {
		if (tok.kind == AS3NodeKind.WS) {
			tok.text = indentStr + tok.text;
			return tok;
		}

		var indent:LinkedListToken = TokenBuilder.newWhiteSpace(indentStr);
		tok.prepend(indent);

		return indent;
	}

	public static function collapseWhitespace(startToken:LinkedListToken):Void
	// takes 2 tokens like "  " to " "
	 {

		if (startToken.channel == AS3NodeKind.HIDDEN && startToken.next.channel == AS3NodeKind.HIDDEN) {
			startToken.next.remove();
		}
	}

	public static function removeTrailingWhitespaceAndComma(stopToken:LinkedListToken,
			trim:Bool = false):Void {
		var tok:LinkedListToken = stopToken.next;
		while (tok != null) {
			if (tok.channel == AS3NodeKind.HIDDEN) {
				tok.remove();
			} else if (tok.text == ',') {
				tok.remove();
				if (trim && stopToken.next.channel == AS3NodeKind.HIDDEN && stopToken.previous.channel == AS3NodeKind.HIDDEN) {
					stopToken.next.remove();
				}
				break;
			} else {
				throw new ASBlocksSyntaxError('Unexpected token: ' + tok);
			}
			tok = tok.next;
		}
	}

	public static function printNode(ast:IParserNode):String {
		var result:String = '';
		var tok:LinkedListToken = ast.startToken;
		while (tok != null) {
			result += tok.text;
			if (tok == ast.stopToken) {
				break;
			}
			tok = tok.next;
		}
		return result;
	}

	public static function newTokenAST(token:LinkedListToken):IParserNode {
		return adapter.createNode(token);
	}

	/**
	 * Returns the first child of the given AST node which has the given
	 * type, or null, if no such node exists.
	 */
	public static function findChildByType(ast:IParserNode, kind:String):IParserNode {
		return ast.getKind(kind);
	}

	public static function addChildWithIndentation(ast:IParserNode,
			stmt:IParserNode,
			index:Int = -1):Void {
		var last:IParserNode = ast.getLastChild();
		var indent:String;
		if (last == null) {
			indent = '\t' + findIndent(ast);
		} else {
			indent = findIndent(last);
		}

		increaseIndent(stmt, indent);
		stmt.addTokenAt(TokenBuilder.newNewline(), 0);
		if (index == -1) {
			ast.addChild(stmt);
		} else {
			ast.addChildAt(stmt, index);
		}
	}

	public static function removePreceedingWhitespaceAndComma(startToken:LinkedListToken):Void {
		var tok:LinkedListToken = startToken.previous;
		while (tok != null) {
			if (tok.channel == AS3NodeKind.HIDDEN) {
				var del:LinkedListToken = tok;
				tok = tok.next;
				del.remove();
				{tok = tok.previous;
					continue;
				}
			} else if (tok.kind == 'comma') {
				tok.remove();
				break;
			} else {
				throw new ASBlocksSyntaxError('Unexpected token: ' + tok);
			}
			tok = tok.previous;
		}
	}

	public static function removeAllChildren(ast:IParserNode):Void {
		while (ast.numChildren > 0) {
			ast.removeChildAt(0);
		}
	}

	public static function nameText(ast:IParserNode):String {
		if (ast == null) {
			return null;
		}

		// NAME node, I want to change ast some day
		return ast.stringValue;
	}

	public static function typeText(ast:IParserNode):String {
		if (ast == null) {
			return null;
		}

		// TYPE node, I want to change ast some day
		return ast.stringValue;
	}

	public static function initText(ast:IParserNode):String {
		if (ast == null) {
			return null;
		}

		// TYPE node, I want to change ast some day
		return stringifyNode(ast);
	}

	/**
	 * Converts an <code>IParserNode</code> into a flat XML String.
	 *
	 * @param ast The <code>IParserNode</code> to convert.
	 * @return A String XML representation of the <code>IParserNode</code>.
	 */
	public static function convert(ast:IParserNode,
			location:Bool = true):String {
		return visitNodes(ast, '', 0, location);
	}

	public static function decodeStringLiteral(string:String):String {
		var result:String = '';

		if (string.indexOf('"') != 0 && string.indexOf('\') != 0) {
			throw new ASBlocksSyntaxError('Invalid delimiter at position 0: ' + string[0]);
		}

		var chars:Array<Dynamic> = string.split('');

		var delimiter:String = chars[0];
		var end:Int = as3hx.Compat.parseInt(chars.length - 1);
		for (i in 1...end) {
			var c:String = chars[i];
			switch (c) {
				case '\\':

					c = chars[++i];
					switch (c) {
						case 'n':
							result += '\n';
						case 't':
							result += '\t';
						case '\\':
							result += '\\';
						case _:
							result += c;
					}
				case _:
					result += c;
			}
		}

		if (chars[end] != delimiter) {
			throw new ASBlocksSyntaxError('End delimiter doesn\t match ' + delimiter + ' at position ' + end);
		}

		return result;
	}

	/**
	 * Escape the given String and place within double quotes so that it
	 * will be a valid ActionScript string literal.
	 */
	public static function escapeString(string:String):String {
		var result:String = '"';

		var len:Int = string.length;
		for (i in 0...len) {
			var c:String = string.charAt(i);

			switch (c) {
				case '\n':
					result += '\\n';
				case '\t':
					result += '\\t';
				case '\r':
					result += '\\r';
				case '"':
					result += '\\"';
				case '\\':
					result += '\\\\';
				case _:
					result += c;
			}
		}
		result += '"';

		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Private Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static function visitNodes(ast:IParserNode,
			result:String,
			level:Int,
			location:Bool = true):String {
		if (location) {
			result += '<' + ast.kind + ' line="' +
			ast.line + '" column="' + ast.column + '">';
		} else {
			result += '<' + ast.kind + '>';
		}

		var numChildren:Int = ast.numChildren;
		if (numChildren > 0) {
			for (i in 0...numChildren) {
				result = visitNodes(ast.getChild(i), result, level + 1, location);
			}
		} else if (ast.stringValue != null) {
			result += escapeEntities(ast.stringValue);
		}

		result += '</' + ast.kind + '>';

		return result;
	}

	/**
	 * @private
	 */
	private static function escapeEntities(stringToEscape:String):String {
		var buffer:String = '';

		var i:Int = 0;
		while (i < stringToEscape.length) {
			var currentCharacter:String = stringToEscape.charAt(i);

			if (currentCharacter == '<') {
				buffer += '&lt;';
			} else if (currentCharacter == '>') {
				buffer += '&gt;';
			} else {
				buffer += currentCharacter;
			}
			i++;
		}
		return buffer;
	}

	public static function stringifyNode(ast:IParserNode):String {
		var result:String = '';
		var tok:LinkedListToken = ast.startToken;
		while (tok != null && tok.kind != null) {
			if (tok.text != null) {
				result += tok.text;
			}

			if (tok == ast.stopToken) {
				break;
			}
			tok = tok.next;
		}
		return result;
	}

	public static function tokenName(kind:String):String {
		return kind;
	}

	public static function parseAS():AS3Parser {
		var parser:AS3Parser = new AS3Parser();
		return parser;
	}

	public static function parse(code:ISourceCode):AS3Parser {
		var parser:AS3Parser = new AS3Parser();
		var source:String = code.code;
		source = source.split('\r\n').join('\n');
		parser.scanner.setLines(source.split('\n'));
		return parser;
	}

	public static function parseMXML(code:ISourceCode):MXMLParser {
		var parser:MXMLParser = new MXMLParser();
		var source:String = code.code;
		source = source.split('\r\n').join('\n');
		parser.scanner.setLines(source.split('\n'));
		return parser;
	}

	public static function constructSyntaxError(statement:String,
			parser:IParser,
			cause:Error):ASBlocksSyntaxError {
		var message:String = '';
		if (Std.is(cause, UnExpectedTokenError)) {
			message = cause.message;
		} else if (Std.is(cause, NullTokenError)) {
			message = cause.message;
		} else if (statement == null) {
			message = '';
		} else {
			message = 'Problem parsing ' + escapeString(statement);
		}
		return new ASBlocksSyntaxError(message, cause);
	}

	//--------------------------------------------------------------------------
	//
	//  Node :: Methods
	//
	//--------------------------------------------------------------------------
	public static function getNodes(kind:String, node:IParserNode):Array<IParserNode> {
		var result:Array<IParserNode> = new Array<IParserNode>();

		if (node.numChildren == 0) {
			return result;
		}

		var len:Int = node.children.length;
		for (i in 0...len) {
			var element:IParserNode = try cast(node.children[i], IParserNode) catch (e:Dynamic) null;
			if (element.isKind(kind)) {
				result.push(element);
			}
		}

		return result;
	}

	public static function findIndentForXMLComment(ast:IParserNode):String {
		var last:IParserNode = ast.getLastChild();
		var indent:String;
		if (last == null) {
			indent = '\t' + findXMLIndent(ast);
		} else {
			indent = findXMLIndent(last);
		}
		return indent;
	}

	public static function findIndentForComment(ast:IParserNode):String {
		var last:IParserNode = ast.getLastChild();
		var indent:String;
		if (last == null) {
			indent = '\t' + findIndent(ast);
		} else {
			indent = findIndent(last);
		}
		return indent;
	}

	public static function print(node:IParserNode):String {
		var printer:ASTPrinter = new ASTPrinter(new SourceCode());
		printer.print(node);
		return printer.flush();
	}

	public static function removeComment(ast:IParserNode):IToken
	// nl, sl-comment, ws, nl
	 {

		var comment:LinkedListToken = getComment(ast);
		if (comment == null) {
			return null;
		}

		var ws:LinkedListToken = comment.previous;
		var nl:LinkedListToken = ws.previous;

		nl.remove();
		ws.remove();
		comment.remove();

		return comment;
	}

	private static function getComment(ast:IParserNode):LinkedListToken {
		var tok:LinkedListToken = ast.startToken;
		while (tok != null) {
			if (tok.kind == 'sl-comment') {
				return tok;
			}
			tok = tok.previous;
		}
		return null;
	}

	public static function qualifiedNameFor(unit:ICompilationUnit):String {
		var name:String;
		var packageName:String = unit.packageName;
		var typeName:String = unit.typeNode.name;
		if (packageName == null || packageName == '') {
			name = typeName;
		} else {
			name = packageName + '.' + typeName;
		}
		return name;
	}

	public static function packageNameForType(type:IType):String {
		var ast:IParserNode = getPackageAST(type.node);
		return nameText(ast.getKind(AS3NodeKind.NAME));
	}

	public static function qualifiedNameForType(type:IType):String {
		var name:String;
		var ast:IParserNode = getPackageAST(type.node);

		var packageName:String = packageNameForType(type);
		var typeName:String = type.name;
		if (packageName == null || packageName == '') {
			name = typeName;
		} else {
			name = packageName + '.' + typeName;
		}
		return name;
	}

	public static function qualifiedNameForTypeString(node:IParserNode, name:String):String {
		var packageAST:IParserNode = getPackageAST(node);
		var contentAST:IParserNode = packageAST.getKind(AS3NodeKind.CONTENT);
		var packageName:String = nameText(packageAST.getKind(AS3NodeKind.NAME));

		if (TopLevelUtil.isTopLevel(name)) {
			return name;
		}

		var i:ASTIterator = new ASTIterator(contentAST);
		while (i.hasNext()) {
			var imp:IParserNode = i.search(AS3NodeKind.IMPORT);
			if (imp == null) {
				break;
			}

			var type:String = typeText(imp.getKind(AS3NodeKind.TYPE));
			var qimp:ASQName = new ASQName(type);
			if (qimp.localName == name) {
				return qimp.qualifiedName;
			}
		}

		if (packageName == null)
		// toplevel
		{

			return name;
		}

		return packageName + '.' + name;
	}

	public static function getPackageAST(ast:IParserNode):IParserNode {
		while (ast != null) {
			if (ast.isKind(AS3NodeKind.PACKAGE)) {
				return ast;
			}

			ast = ast.parent;
		}
		return null;
	}

	public function new() {}

}