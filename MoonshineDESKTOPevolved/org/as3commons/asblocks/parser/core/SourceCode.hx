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

import org.as3commons.asblocks.parser.api.ISourceCode;

/**
 * A chunk of source code with file name identifier.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class SourceCode implements ISourceCode {

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  code
	//----------------------------------

	/**
	 * @private
	 */
	private var _code:String;

	/**
	 * @copy org.as3commons.as3parser.api.ISourceCode#code
	 */
	public var code(get, set):String;
	private function get_code():String {
		return _code;
	}

	/**
	 * @private
	 */
	private function set_code(value:String):String {
		_code = cleanCode(value);
		return value;
	}

	//----------------------------------
	//  filePath
	//----------------------------------

	/**
	 * @private
	 */
	private var _filePath:String;

	/**
	 * @copy org.as3commons.as3parser.api.ISourceCode#filePath
	 */
	public var filePath(get, set):String;
	private function get_filePath():String {
		return _filePath;
	}

	/**
	 * @private
	 */
	private function set_filePath(value:String):String {
		_filePath = value;
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
	 * @param code The String data.
	 * @param filePath The String file name identifier.
	 */
	public function new(code:String = null,
			filePath:String = null) {
		this.code = code;

		_filePath = filePath;
	}

	//--------------------------------------------------------------------------
	//
	//  ISourceCode API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.as3nodes.api.ISourceCode#getSlice()
	 */
	public function getSlice(startLine:Int, endLine:Int):String {
		// TODO (mschmalle) impl SourceCode#getSlice()
		if (code == null) {
			return null;
		}

		return null;
	}

	//--------------------------------------------------------------------------
	//
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Cleans the code by default, removes the \r\n and replaces them with \n.
	 *
	 * @param code A String to clean.
	 * @return The cleaned String.
	 */
	private function cleanCode(code:String):String {
		if (code == null) {
			return null;
		}

		return new as3hx.Compat.Regex('\\r\\n', 'g').replace(code, '\n');
	}

}