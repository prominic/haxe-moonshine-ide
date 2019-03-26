package org.as3commons.asblocks.impl;

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.SourceCode;
class ASTPrinter {

	private var sourceCode:ISourceCode;

	public function new(sourceCode:ISourceCode) {
		this.sourceCode = sourceCode;
	}

	public function print(ast:IParserNode):Void {
		var tok:LinkedListToken = findStart(ast);
		while (tok != null) {
			printLn(tok);
			tok = tok.next;
		}
	}

	private function findStart(ast:IParserNode):LinkedListToken {
		var result:LinkedListToken = null;

		var tok:LinkedListToken = ast.startToken;
		while (viable(tok)) {
			result = tok;
			tok = tok.previous;
		}
		return result;
	}

	private function printLn(token:LinkedListToken):Void {
		if (!sourceCode.code) {
			sourceCode.code = '';
		}

		if (token.text != null) {
			sourceCode.code += token.text;
		}
	}

	private function viable(token:LinkedListToken):Bool {
		return token != null && token.kind != '__END__';
	}

	public function flush():String {
		var result:String = toString();
		sourceCode.code = null;
		return result;
	}

	public function toString():String {
		return sourceCode.code;
	}

}