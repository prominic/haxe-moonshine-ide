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

/**
 * The <strong>IToken</strong> is a String with location information.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
interface IToken {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  column
	//----------------------------------

	/**
	 * The token's column.
	 */
	var column(get, set):Int;

	/**
	 * @private
	 */

	//----------------------------------
	//  line
	//----------------------------------

	/**
	 * The token's line.
	 */
	var line(get, set):Int;

	/**
	 * @private
	 */

	//----------------------------------
	//  kind
	//----------------------------------

	/**
	 * The String kind the token carries.
	 */
	var kind(get, set):String;

	/**
	 * @private
	 */

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 * The String text the token carries.
	 */
	var text(get, set):String;

}