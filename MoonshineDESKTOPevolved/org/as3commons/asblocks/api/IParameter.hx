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
 * A function parameter; <code>(arg0:int = 0)</code>.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IFunction#addParameter()
 * @see org.as3commons.asblocks.api.IFunction#addRestParameter()
 * @see org.as3commons.asblocks.api.IFunction#removeParameter()
 * @see org.as3commons.asblocks.api.IFunction#getParameter()
 */
interface IParameter extends IScriptNode {

	/**
	 * @private
	 */
	var description(get, set):String;

	/**
	 * @private
	 */
	var name(get, set):String;

	/**
	 * @private
	 */
	var type(get, set):String;

	//----------------------------------
	//  qualifiedType
	//----------------------------------

	/**
	 * The qualified (resolved from imports or package) type.
	 */
	var qualifiedType(get, never):String;

	//----------------------------------
	//  hasType
	//----------------------------------

	/**
	 * Returns whether the parameter contains a type.
	 */
	var hasType(get, never):Bool;

	/**
	 * @private
	 */
	var defaultValue(get, set):String;

	//----------------------------------
	//  hasDefaultValue
	//----------------------------------

	/**
	 * Returns <code>true</code> if a default value exist.
	 */
	var hasDefaultValue(get, never):Bool;

	//----------------------------------
	//  isRest
	//----------------------------------

	/**
	 * Whether this parameter is a rest that appears at the end of the parameter
	 * list.
	 */
	var isRest(get, never):Bool;

}