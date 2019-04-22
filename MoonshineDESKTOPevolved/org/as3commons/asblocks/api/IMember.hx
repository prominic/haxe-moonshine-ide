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
	var visibility(get, set):Visibility;

	/**
	 * @private
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
	var isStatic(get, set):Bool;

}