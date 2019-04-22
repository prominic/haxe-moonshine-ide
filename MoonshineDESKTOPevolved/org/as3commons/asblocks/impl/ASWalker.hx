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

package org.as3commons.asblocks.impl;

import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.IASVisitor;
import org.as3commons.asblocks.IASWalker;
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
 * Default implementation of the <code>IASWalker</code> API.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ASWalker implements IASWalker {

	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var visitor:IASVisitor;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(visitor:IASVisitor) {
		this.visitor = visitor;
	}

	//--------------------------------------------------------------------------
	//
	//  IASWalker API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkProject()
	 */
	public function walkProject(element:IASProject):Void {
		visitor.visitProject(element);

		var len:Int = element.compilationUnits.length;
		for (i in 0...len) {
			var unit:ICompilationUnit = element.compilationUnits[i];
			walkCompilationUnit(unit);
		}
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkCompilationUnit()
	 */
	public function walkCompilationUnit(element:ICompilationUnit):Void {
		visitor.visitCompilationUnit(element);
		walkPackage(element.packageNode);
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkPackage()
	 */
	public function walkPackage(element:IPackage):Void {
		visitor.visitPackage(element);
		walkType(element.typeNode);
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkType()
	 */
	public function walkType(element:IType):Void {
		visitor.visitType(element);
		if (Std.is(element, IClassType)) {
			walkClass(IClassType(element));
		} else if (Std.is(element, IInterfaceType)) {
			walkInterface(IInterfaceType(element));
		} else if (Std.is(element, IFunctionType)) {
			walkFunction(IFunctionType(element));
		}
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkClass()
	 */
	public function walkClass(element:IClassType):Void {
		visitor.visitClass(element);
		var len:Int;
		var i:Int;

		var fields:Array<IField> = cast element.fields;
		len = fields.length;
		for (i in 0...len) {
			var field:IField = fields[i];
			walkMember(field);
			walkField(field);
		}

		var methods:Array<IMethod> = cast element.methods;
		len = methods.length;
		for (i in 0...len) {
			var method:IMethod = methods[i];
			walkMember(method);
			walkMethod(method);
		}
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkInterface()
	 */
	public function walkInterface(element:IInterfaceType):Void {
		visitor.visitInterface(element);
		var len:Int;
		var i:Int;

		var methods:Array<IMethod> = cast element.methods;
		len = methods.length;
		for (i in 0...len) {
			var method:IMethod = methods[i];
			walkMember(method);
			walkMethod(method);
		}
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkFunction()
	 */
	public function walkFunction(element:IFunctionType):Void {
		visitor.visitFunction(element);
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#visitMember()
	 */
	public function walkMember(element:IMember):Void {
		visitor.visitMember(element);
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#visitMethod()
	 */
	public function walkMethod(element:IMethod):Void {
		visitor.visitMethod(element);
	}

	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkField()
	 */
	public function walkField(element:IField):Void {
		visitor.visitField(element);
	}

}