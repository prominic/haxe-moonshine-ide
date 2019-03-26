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

package org.as3commons.asblocks.parser.core;

/**
 * A token entry with text, sourdce id and start line.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TokenEntry {

	public var text(get, set):String;
	public var tokenSrcID(get, set):String;
	public var startLine(get, set):Int;

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 * @private
	 */
	private var _text:String;

	/**
	 * The token String text.
	 */
	private function get_text():String {
		return _text;
	}

	/**
	 * @private
	 */
	private function set_text(value:String):String {
		_text = value;
		return value;
	}

	//----------------------------------
	//  tokenSrcID
	//----------------------------------

	/**
	 * @private
	 */
	private var _tokenSrcID:String;

	/**
	 * The token source it, usually a file name.
	 */
	private function get_tokenSrcID():String {
		return _tokenSrcID;
	}

	/**
	 * @private
	 */
	private function set_tokenSrcID(value:String):String {
		_tokenSrcID = value;
		return value;
	}

	//----------------------------------
	//  startLine
	//----------------------------------

	/**
	 * @private
	 */
	private var _startLine:Int;

	/**
	 * The token start line in the source.
	 */
	private function get_startLine():Int {
		return _startLine;
	}

	/**
	 * @private
	 */
	private function set_startLine(value:Int):Int {
		_startLine = value;
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 *
	 * @param text The token String text.
	 * @param tokenSrcID The token source it, usually a file name.
	 * @param startLine The token start line in the source.
	 */
	public function new(text:String, tokenSrcID:String, startLine:Int) {
		_text = text;
		_tokenSrcID = tokenSrcID;
		_startLine = startLine;
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Returns an End Of Line TokenEntry, '__END__'.
	 *
	 * @return An EOF TokenEntry.
	 */
	public static function getEOF():TokenEntry {
		return new TokenEntry('__END__', null, -1);
	}

}