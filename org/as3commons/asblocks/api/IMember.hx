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
 * A type member; field or method.
 *
 * <pre>
 * var field:IField = type.newField("foo", Visibility.PUBLIC, "int");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * ...
 * {
 * 	public var foo:int = 0;
 * }
 * ...
 * </pre>
 *
 * <pre>
 * var method:IMethod = type.newMethod("foo", Visibility.PUBLIC, "int");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * ...
 * {
 * 	public function foo():int {
 * 	}
 * }
 * ...
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IClassType#newField()
 * @see org.as3commons.asblocks.api.IType#newMethod()
 */
interface IMember extends IScriptNode extends IDocCommentAware extends IMetaDataAware {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  visibility
	//----------------------------------

	/**
	 * The <code>Visibility</code> of the member.
	 *
	 * <p>This can be one of the <code>Visibility</code> enumerations or a
	 * custom namespace <code>Visibility</code>.</p>
	 */
	var visibility(get, set):Visibility;

	/**
	 * @private
	 */

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * The name of the member.
	 *
	 * <p><strong>Note:</strong> This name cannot contain a period.</p>
	 */
	var name(get, set):String;

	//----------------------------------
	//  qualifiedName
	//----------------------------------

	/**
	 * The qualified name of the member.
	 */
	var qualifiedName(get, never):String;

	/**
	 * @private
	 */

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * The type of the member.
	 *
	 * <p><strong>Note:</strong> This name can contain a period, if a period
	 * is present, the type will be considered a qualified name not a simple
	 * name.</p>
	 */
	var type(get, set):String;

	//----------------------------------
	//  qualifiedType
	//----------------------------------

	/**
	 * The qualified type of the member.
	 */
	var qualifiedType(get, never):String;

	/**
	 * @private
	 */

	//----------------------------------
	//  isStatic
	//----------------------------------

	/**
	 * Whether the member constains the <code>static</code> keyword.
	 *
	 * <p>Setting this property to <code>true</code> will add the <code>static</code>
	 * keyword, setting the property to <code>false</code> will remove the
	 * <code>static</code> keyword.</p>
	 */
	var isStatic(get, set):Bool;

}