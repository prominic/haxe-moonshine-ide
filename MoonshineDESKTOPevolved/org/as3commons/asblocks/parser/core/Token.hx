/**
 *    Copyright (c) 2009, Adobe Systems, Incorporated
 *    All rights reserved.
 *
 *    Redistribution  and  use  in  source  and  binary  forms, with or without
 *    modification,  are  permitted  provided  that  the  following  conditions
 *    are met:
 *
 *      * Redistributions  of  source  code  must  retain  the  above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions  in  binary  form  must reproduce the above copyright
 *        notice,  this  list  of  conditions  and  the following disclaimer in
 *        the    documentation   and/or   other  materials  provided  with  the
 *        distribution.
 *      * Neither the name of the Adobe Systems, Incorporated. nor the names of
 *        its  contributors  may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 *
 *    THIS  SOFTWARE  IS  PROVIDED  BY THE  COPYRIGHT  HOLDERS AND CONTRIBUTORS
 *    "AS IS"  AND  ANY  EXPRESS  OR  IMPLIED  WARRANTIES,  INCLUDING,  BUT NOT
 *    LIMITED  TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *    PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 *    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,  INCIDENTAL,  SPECIAL,
 *    EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED TO,
 *    PROCUREMENT  OF  SUBSTITUTE   GOODS  OR   SERVICES;  LOSS  OF  USE,  DATA,
 *    OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *    LIABILITY,  WHETHER  IN  CONTRACT,  STRICT  LIABILITY, OR TORT (INCLUDING
 *    NEGLIGENCE  OR  OTHERWISE)  ARISING  IN  ANY  WAY  OUT OF THE USE OF THIS
 *    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.as3commons.asblocks.parser.core;

import org.as3commons.asblocks.parser.api.IToken;

/**
 * A Token represents a piece of text in a string of data with location
 * properties.
 *
 * <p>Initial API; Adobe Systems, Incorporated</p>
 *
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
class Token implements IToken {

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  column
	//----------------------------------

	/**
	 * @private
	 */
	private var _column:Int = 0;

	/**
	 * @copy org.as3commons.as3parser.api.IToken#column
	 */
	public var column(get, set):Int;
	@:final private function get_column():Int {
		return _column;
	}

	/**
	 * @private
	 */
	@:final private function set_column(value:Int):Int {
		_column = value;
		return value;
	}

	//----------------------------------
	//  line
	//----------------------------------

	/**
	 * @private
	 */
	private var _line:Int = 0;

	/**
	 * @copy org.as3commons.as3parser.api.IToken#line
	 */
	public var line(get, set):Int;
	@:final private function get_line():Int {
		return _line;
	}

	/**
	 * @private
	 */
	@:final private function set_line(value:Int):Int {
		_line = value;
		return value;
	}

	//----------------------------------
	//  kind
	//----------------------------------

	/**
	 * @private
	 */
	private var _kind:String;

	/**
	 * The token's kind.
	 */
	public var kind(get, set):String;
	@:final private function get_kind():String {
		return _kind;
	}

	/**
	 * @private
	 */
	@:final private function set_kind(value:String):String {
		_kind = value;
		return value;
	}

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 * @private
	 */
	private var _text:String;

	/**
	 * @copy org.as3commons.as3parser.api.IToken#text
	 */
	public var text(get, set):String;
	@:final private function get_text():String {
		return _text;
	}

	/**
	 * @private
	 */
	@:final private function set_text(value:String):String {
		_text = value;
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function new(text:String, line:Int = -1, column:Int = -1) {
		_text = text;
		_line = AS3.int(line + 1);
		_column = AS3.int(column + 1);
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new Token.
	 *
	 * @param text The Token text String.
	 * @param line The line number the Token is found on.
	 * @param column The column the Token starts at.
	 * @return A new Token instance.
	 */
	public static function create(text:String,
			line:Int = -1,
			column:Int = -1):Token {
		return new Token(text, line, column);
	}

}