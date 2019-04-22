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

package org.as3commons.asblocks.visitor;

import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.IASVisitor;
import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IFunctionType;
import org.as3commons.asblocks.api.IInterfaceType;
import org.as3commons.asblocks.api.IMember;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IType;

/**
 * A default null visitor implementation that can be subclassed.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class NullASVisitor implements IASVisitor {

	/**
	 * @private
	 */
	public function visitProject(element:IASProject):Void {}

	/**
	 * @private
	 */
	public function visitCompilationUnit(element:ICompilationUnit):Void {}

	/**
	 * @private
	 */
	public function visitPackage(element:IPackage):Void {}

	/**
	 * @private
	 */
	public function visitType(element:IType):Void {}

	/**
	 * @private
	 */
	public function visitClass(element:IClassType):Void {}

	/**
	 * @private
	 */
	public function visitInterface(element:IInterfaceType):Void {}

	/**
	 * @private
	 */
	public function visitFunction(element:IFunctionType):Void {}

	/**
	 * @private
	 */
	public function visitMember(element:IMember):Void {}

	/**
	 * @private
	 */
	public function visitMethod(element:IMethod):Void {}

	/**
	 * @private
	 */
	public function visitField(element:IField):Void {}

	public function new() {}

}