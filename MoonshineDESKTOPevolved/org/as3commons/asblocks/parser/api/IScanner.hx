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

package org.as3commons.asblocks.parser.api;

import org.as3commons.asblocks.parser.core.Token;

/**
 * The <strong>IScanner</strong> interface marks a class as having the ability
 * to scan and create Tokens for a specific domain type.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
interface IScanner {

	/**
	 * @private
	 */
	var allowWhiteSpace(get, set):Bool;

	//----------------------------------
	//  offset
	//----------------------------------

	/**
	 * The current scanner offset into the code.
	 */
	var offset(get, never):Int;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * Set the lines to be scanned.
	 *
	 * @param lines A String Vector of source lines.
	 */
	function setLines(lines:Array<String>):Void;

	/**
	 * Returns the next Token
	 *
	 * @return The next Token scanned by the scanner.
	 */
	function nextToken():Token;

}