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

package org.as3commons.asblocks.api;

/**
 * A <code>var</code> or <code>const</code> declaration found in an
 * <code>IDeclarationStatement</code>.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IDeclarationStatement
 */
interface IDeclaration {

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * The name of the declaration.
	 */
	var name(get, never):String;

	/**
	 * @private
	 */
	//function set name(value:String):void;

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * The type of the declaration.
	 */
	var type(get, never):String;

	/**
	 * @private
	 */
	//function set type(value:String):void;

	//----------------------------------
	//  initializer
	//----------------------------------

	/**
	 * The <code>IExpression</code> initializer for the declaration.
	 *
	 * <p>This is the expression that follows the <code>=</code> sign.</p>
	 */
	var initializer(get, never):IExpression;

}