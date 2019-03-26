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

import org.as3commons.asblocks.parser.core.Token;

/**
 * A scanner that is (/~~ ~/) or (<!--- -->) asdoc domain aware.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ASDocScanner extends ScannerBase {

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * An end of file.
	 */
	public static inline var EOF:String = '__END__';

	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	@:allow(org.as3commons.asblocks.parser.impl)
	private var isWhiteSpace:Bool = false;

	/**
	 * @private
	 */
	private var length:Int = -1;

	/**
	 * @private
	 */
	private var map:Dynamic;

	/**
	 * @private
	 */
	private var inPre:Bool = false;

	/**
	 * @private
	 */
	private var inInlineTag:Bool = false;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new() {
		super();

		allowWhiteSpace = true;
	}

	//--------------------------------------------------------------------------
	//
	// Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override public function setLines(lines:Array<String>):Void {
		super.setLines(lines);

		inPre = false;
		inInlineTag = false;
		isWhiteSpace = true;
		length = getLength();

		map = {};

		Reflect.setField(map, '/**', 'ml-start');
		Reflect.setField(map, '*/', 'ml-end');
		Reflect.setField(map, '*', 'astrix');
		Reflect.setField(map, ' ', 'ws');
		Reflect.setField(map, '\t', 'ws');
		Reflect.setField(map, '\n', 'nl');
		Reflect.setField(map, '__END__', 'eof');
	}

	/**
	 * @private
	 */
	override public function nextToken():Token {
		var currentCharacter:String;
		var token:Token;

		if (lines != null && line < lines.length) {
			currentCharacter = nextChar();
		}

		if (currentCharacter == EOF) {
			token = new Token(EOF, line, column);
		}

		if (currentCharacter == '<') {
			token = scanCharacterSequence(currentCharacter,
							['</', '<listing', '<pre', '<code', '<p',
							'<strong', '<i', '<ul', '<li'
				]
				);

			if (token.text == '<pre' || token.text == '<listing') {
				inPre = true;
			}
		}

		if (currentCharacter == ' ' || currentCharacter == '\n' || currentCharacter == '>' || currentCharacter == '@') {
			token = scanSingleCharacterToken(currentCharacter);
		}

		if (currentCharacter == '/') {
			token = scanCharacterSequence(currentCharacter, ['/**', '/>']);

			if (token.text == '/>') {
				inPre = false;
			}
		}

		if (currentCharacter == '*') {
			token = scanCharacterSequence(currentCharacter, ['*/']);
		}

		if (currentCharacter == '{') {
			token = scanCharacterSequence(currentCharacter, ['{@']);

			if (token.text == '{@') {
				inInlineTag = true;
			}
		}

		if (inInlineTag && currentCharacter == '}') {
			token = scanSingleCharacterToken(currentCharacter);
			inInlineTag = false;
		}

		if (token == null) {
			token = scanWord(currentCharacter);
			if (token != null) {
				isWhiteSpace = false;
			}
		}

		if (token.text == '\n') {
			isWhiteSpace = true;
		}

		commitKind(token);

		return token;
	}

	/**
	 * @private
	 */
	private function commitKind(token:Token):Void {
		var result:String = Reflect.field(map, Std.string(token.text));
		if (token.text == '/**' || token.text == '*/' || token.text == '__END__') {
			token.kind = result;
			return;
		}

		if (result == null || !isWhiteSpace) {
			result = 'text';
		}

		if (inPre && token.text == '*') {
			isWhiteSpace = false;
		}

		token.kind = result;
	}

	/**
	 * @private
	 */
	private function getLength():Int {
		var len:Int = 0;
		for (line in lines) {
			len += line.length;
		}
		return len;
	}

}