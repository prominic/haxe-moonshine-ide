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

import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.impl.ASQName;
import org.as3commons.asblocks.parser.api.ISourceCode;

/**
 * The <code>ICompilationUnit</code> is the toplevel AST wrapper class that
 * contains a public <code>IPackage</code> and the package contains a
 * public <code>IType</code>.
 *
 * <p>Although the <code>typeNode</code> is not actually a child of the
 * compilation unit, the <code>typeNode</code> property is available
 * for a shortcut instead of going through the <code>packageNode</code>.</p>
 *
 * <p>The <code>packageName</code> also references the <code>packageNode.name</code>
 * and is not found on this AST.</p>
 *
 * <pre>
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = new ASFactory(factory);
 * var unit:ICompilationUnit = project.newClass("my.domain.ClassType");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * package my.domain {
 * 	public class ClassType {
 * 	}
 * }
 * </pre>
 *
 * <pre>
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = new ASFactory(factory);
 * var unit:ICompilationUnit = project.newInterface("my.domain.IInterfaceType");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * package my.domain {
 * 	public interface IInterfaceType {
 * 	}
 * }
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
interface ICompilationUnit extends IScriptNode {

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  project
	//----------------------------------

	/**
	 * The owner project (if any).
	 */
	var project(get, never):IASProject;

	//----------------------------------
	//  sourceCode
	//----------------------------------

	/**
	 * The container that holds the source code and file path location for the
	 * compilation unit.
	 */
	var sourceCode(get, never):ISourceCode;

	//----------------------------------
	//  packageNode
	//----------------------------------

	/**
	 * The public <code>package</code> node of the compilation unit.
	 *
	 * <p>This node holds the public <code>IType</code> node.</p>
	 */
	var packageNode(get, never):IPackage;

	/**
	 * @private
	 */
	var packageName(get, set):String;

	//----------------------------------
	//  typeNode
	//----------------------------------

	/**
	 * A reference to the public <code>IType</code> found within the
	 * <code>IPackage</code>.
	 *
	 * <p>This type can either be a <code>IClassType</code> or
	 * <code>IInterfaceType</code>.
	 *
	 * @see org.as3commons.asblocks.api.IClassType
	 * @see org.as3commons.asblocks.api.IInterfaceType
	 */
	var typeNode(get, never):IType;

	/**
	 * @private
	 */
	var typeName(get, set):String;

	//----------------------------------
	//  qualifiedName
	//----------------------------------

	/**
	 * The qualified name of the unit, packageName plus typeName.
	 */
	var qname(get, never):ASQName;

	//----------------------------------
	//  internalClasses
	//----------------------------------

	/**
	 * The internal <code>class</code> types found.
	 */
	var internalClasses(get, never):Array<IClassType>;

	//----------------------------------
	//  internalFunctions
	//----------------------------------

	/**
	 * The internal <code>function</code> types found.
	 */
	var internalFunctions(get, never):Array<IFunctionType>;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new internal class within the compilation unit.
	 *
	 * @param name The String class name.
	 * @return A new <code>IInternalClass</code> instance.
	 */
	function newInternalClass(name:String):IInternalClass;

	/**
	 * Creates a new internal function within the compilation unit.
	 *
	 * @param name The String function name.
	 * @param returnType The String return type.
	 * @return A new <code>IInternalFunction</code> instance.
	 */
	function newInternalFunction(name:String, returnType:String):IInternalFunction;

}