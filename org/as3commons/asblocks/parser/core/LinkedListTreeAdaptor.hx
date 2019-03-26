package org.as3commons.asblocks.parser.core;

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.ASDocNodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
class LinkedListTreeAdaptor {

	private var delegate:TokenListUpdateDelegate;

	private var parenDelegate:ParentheticListUpdateDelegate;

	private var curlyDelegate:ParentheticListUpdateDelegate;

	private var bracketDelegate:ParentheticListUpdateDelegate;

	private var cdataDelegate:ParentheticListUpdateDelegate;

	public function new() {
		delegate = new TokenListUpdateDelegate();
		parenDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LPAREN, AS3NodeKind.RPAREN);
		curlyDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LCURLY, AS3NodeKind.RCURLY);
		bracketDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LBRACKET, AS3NodeKind.RBRACKET);
		cdataDelegate = new ParentheticListUpdateDelegate('lcdata', 'rcdata');
	}

	public function createToken(kind:String,
			text:String = null,
			line:Int = -1,
			column:Int = -1):LinkedListToken {
		var token:LinkedListToken = new LinkedListToken(kind, text);
		if (kind == AS3NodeKind.SPACE || kind == AS3NodeKind.TAB || kind == AS3NodeKind.NL || kind == AS3NodeKind.WS) {
			token.channel = AS3NodeKind.HIDDEN;
		}
		token.line = line;
		token.column = column;
		return token;
	}

	public function empty(kind:String, token:Token):TokenNode {
		var result:LinkedListToken = new LinkedListToken(kind, null);
		result.line = token.line;
		result.column = token.column;
		var node:TokenNode = createNode(result);
		return node;
	}

	public function copy(kind:String, token:Token):TokenNode {
		var result:LinkedListToken = new LinkedListToken(kind, token.text);
		result.line = token.line;
		result.column = token.column;
		var node:TokenNode = createNode(result);
		return node;
	}

	public function create(kind:String,
			text:String = null,
			line:Int = -1,
			column:Int = -1):TokenNode {
		var token:LinkedListToken = new LinkedListToken(kind, text);
		token.line = line;
		token.column = column;
		var node:TokenNode = createNode(token);
		return node;
	}

	public function createNode(payload:LinkedListToken):TokenNode
	//parenDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LPAREN, AS3NodeKind.RPAREN);
	 {

		//		curlyDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LCURLY, AS3NodeKind.RCURLY);
		//bracketDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LBRACKET, AS3NodeKind.RBRACKET);
		//cdataDelegate = new ParentheticListUpdateDelegate("lcdata", "rcdata");

		var result:TokenNode = new TokenNode(
		payload.kind,
		payload.text,
		payload.line,
		payload.column);

		cast((result), TokenNode).token = payload;

		cast((result), TokenNode).tokenListUpdater = delegate;

		if (payload.kind == ASDocNodeKind.DESCRIPTION) {
			cast((result), TokenNode).tokenListUpdater =
					new ParentheticListUpdateDelegate('ml-start', 'ml-end');
		} else if (payload.kind ==AS3NodeKind.ARRAY
			|| payload.kind == AS3NodeKind.META /*|| payload.kind == AS3NodeKind.ARRAY_ACCESSOR*/ ) {
			cast((result), TokenNode).tokenListUpdater = bracketDelegate;
		} else if (payload.kind == AS3NodeKind.OBJECT || payload.kind == AS3NodeKind.BLOCK || payload.kind == AS3NodeKind.CONTENT || payload.kind == AS3NodeKind.CASES) {
			curlyDelegate = new ParentheticListUpdateDelegate(AS3NodeKind.LCURLY, AS3NodeKind.RCURLY);
			cast((result), TokenNode).tokenListUpdater = curlyDelegate;
		} else if (payload.kind == AS3NodeKind.PARAMETER_LIST || payload.kind == AS3NodeKind.ARGUMENTS || payload.kind == AS3NodeKind.CONDITION) {
			cast((result), TokenNode).tokenListUpdater = parenDelegate;
		} else if (payload.kind == 'cdata') {
			cast((result), TokenNode).tokenListUpdater = cdataDelegate;
		}

		if (Std.is(payload, LinkedListToken)) {
			result.startToken = cast((payload), LinkedListToken);
			result.stopToken = cast((payload), LinkedListToken);
		}

		return result;
	}

}