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

import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.core.Token;

/**
 * The default base implementation of the IScanner interface.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ScannerBase implements IScanner {

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * An end line.
	 */
	public static inline var END:String = '__END__';

	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * The line Vector to scan.
	 */
	private var lines:Array<String>;

	/**
	 * The current line scanned.
	 */
	private var line:Int = 0;

	/**
	 * The current column scanned.
	 */
	private var column:Int = 0;

	/**
	 * The last non whitespace charater scanned.
	 */
	private var lastNonWhiteSpaceCharacter:String;

	//--------------------------------------------------------------------------
	//
	//  IScanner API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  allowWhiteSpace
	//----------------------------------

	/**
	 * @private
	 */
	private var _allowWhiteSpace:Bool = false;

	/**
	 * @copy org.as3commons.as3parser.api.IScanner#allowWhiteSpace
	 */
	public var allowWhiteSpace(get, set):Bool;
	private function get_allowWhiteSpace():Bool {
		return _allowWhiteSpace;
	}

	/**
	 * @private
	 */
	private function set_allowWhiteSpace(value:Bool):Bool {
		_allowWhiteSpace = value;
		return value;
	}

	//----------------------------------
	//  offset
	//----------------------------------

	/**
	 * @private
	 */
	private var _offset:Int = 0;

	/**
	 * @copy org.as3commons.as3parser.api.IScanner#offset
	 */
	public var offset(get, set):Int;
	private function get_offset():Int {
		return _offset;
	}

	/**
	 * @private
	 */
	private function set_offset(value:Int):Int {
		_offset = value;
		return value;
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

	}

	//--------------------------------------------------------------------------
	//
	//  IScanner API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.as3parser.api.IScanner#setLines()
	 */
	public function setLines(lines:Array<String>):Void {
		this.lines = lines;
		line = 0;
		column = -1;
		lastNonWhiteSpaceCharacter = null;

		_offset = -1;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IScanner#nextToken()
	 */
	public function nextToken():Token {
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//  Protected Final :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Advances the offest/column and finds the next character of
	 * the current line.
	 */
	@:final private function nextChar():String {
		var currentLine:String = lines[line];
		var lastColumn:Int = column;

		_offset++;
		column++;

		if (currentLine.length <= column) {
			column = -1;
			line++;
			if (line == lines.length) {
				return END;
			}

			return '\n';
		}

		var oldCharacter:String = Std.string(currentLine.charAt(lastColumn));
		if (oldCharacter != ' ' && oldCharacter != '\t') {
			lastNonWhiteSpaceCharacter = oldCharacter;
		}

		var character:String = Std.string(currentLine.charAt(column));

		// move past the BOM (if any)
		while (character == '\uFEFF') {
			column++;
			character = Std.string(currentLine.charAt(column));
		}

		return character;
	}

	/**
	 * A look ahead specified by the offset. If the offset calculates passed
	 * the line length, a \n is returned.
	 */
	@:final private function peekChar(offset:Int):String {
		var currentLine:String = lines[line];
		var index:Int = column + offset;

		if (index >= currentLine.length) {
			return '\n';
		}

		return Std.string(currentLine.charAt(index));
	}

	/**
	 * Skips a character by calling nextChar();
	 */
	@:final private function skipChar():Void {
		nextChar();
	}

	/**
	 * Skips a predetermined amount of charatcters.
	 */
	@:final private function skipChars(count:Int):Void {
		var decrementCount:Int = count;

		while (decrementCount-- > 0) {
			nextChar();
		}
	}

	/**
	 * Returns whether the character is an identifier.
	 */
	private function isIdentifierCharacter(currentCharacter:String):Bool {
		var code:Int = currentCharacter.charCodeAt(0);
		var isNum:Bool = (code > 47 && code < 58);
		var isLower:Bool = (code > 96 && code < 123);
		var isUpper:Bool = (code > 64 && code < 91);

		return isUpper || isLower || isNum || currentCharacter == '_' || currentCharacter == '$';
	}

	/**
	 * Scans until delimiter is found.
	 */
	@:final private function scanUntilDelimiter(start:String,
			delimiter:String = null):Token {
		if (delimiter == null) {
			delimiter = start;
		}

		var buffer:String = '';

		var peekPos:Int = 1;
		var numberOfBackslashes:Int = 0;

		buffer += start;

		while (true) {
			var currentCharacter:String = peekChar(peekPos++);

			if (currentCharacter == '\n') {
				return null;
			}

			buffer += currentCharacter;

			if (currentCharacter == delimiter && numberOfBackslashes == 0) {
				var result:Token = Token.create(Std.string(buffer), line, column);
				skipChars(buffer.length - 1);
				return result;
			}
			numberOfBackslashes = (currentCharacter == '\\') ? (numberOfBackslashes + 1) % 2 : 0;
		}

		return null;
	}

	/**
	 * Scans a single character.
	 */
	@:final private function scanSingleCharacterToken(character:String):Token {
		return new Token(character, line, column);
	}

	/**
	 * Find the longest matching sequence.
	 */
	@:final private function scanCharacterSequence(currentCharacter:String,
			possibleMatches:Array<Dynamic>):Token {
		var peekPos:Int = 1;
		var buffer:String = '';
		var maxLength:Int = computePossibleMatchesMaxLength(possibleMatches);

		buffer += currentCharacter;

		var found:String = Std.string(buffer);
		while (peekPos < maxLength) {
			buffer += peekChar(peekPos);

			peekPos++;
			var len:Int = possibleMatches.length;
			for (i in 0...len) {
				if (Std.string(buffer) == Std.string(possibleMatches[i])) {
					found = Std.string(buffer);
				}
			}
		}

		if (found == '') {
			return null;
		}

		var result:Token = new Token(found, line, column);
		skipChars(found.length - 1);
		return result;
	}

	/**
	 * @private
	 */
	@:final private function computePossibleMatchesMaxLength(possibleMatches:Array<Dynamic>):Int {
		var max:Int = 0;

		var len:Int = possibleMatches.length;
		for (i in 0...len) {
			max = AS3.int(Math.max(max, possibleMatches[i].length));
		}
		return max;
	}

	//----------------------------------
	//  Strings
	//----------------------------------

	/**
	 * Something started with a quote or double quote consume characters until
	 * the quote/double quote shows up again and is not escaped
	 */
	@:final private function scanString(startingCharacter:String):Token {
		return scanUntilDelimiter(startingCharacter);
	}

	/**
	 * Scans a word at a start, only allowing identifier characters.
	 */
	@:final private function scanWord(startingCharacter:String):Token {
		var currentChar:String = startingCharacter;

		var buffer:String = '';
		buffer += currentChar;

		var peekPos:Int = 1;
		while (true) {
			currentChar = peekChar(peekPos++);
			if (!isIdentifierCharacter(currentChar)) {
				break;
			}

			buffer += currentChar;
		}
		var result:Token = new Token(Std.string(buffer), line, column);
		skipChars(Std.string(buffer).length - 1);
		return result;
	}

	/**
	 * Returns the next character that is not a \s or \t. Newlines should
	 * not be here since we are using a line Vector.
	 */
	private function nextNonWhitespaceCharacter():String {
		var result:String;

		do {
			result = nextChar();
		} while ((result == ' ' || result == '\t'));

		return result;
	}

	/**
	 * Returns the remaining line.
	 */
	@:final private function getRemainingLine():String {
		return lines[line].substring(column);
	}

	// UTIL -----------------------------------------------------------------

	/**
	 * @private
	 */
	public static function isHexChar(currentCharacter:String):Bool {
		var code:Float = currentCharacter.charCodeAt(0);
		var isNum:Bool = (code > 47 && code < 58);
		var isLower:Bool = (code > 96 && code < 123);
		var isUpper:Bool = (code > 64 && code < 91);

		return isNum || isLower || isUpper;
	}

	/**
	 * @private
	 */
	public static function isDecimalChar(currentCharacter:String):Bool {
		var code:Int = currentCharacter.charCodeAt(0);
		return (code > 47 && code < 58);
	}

}