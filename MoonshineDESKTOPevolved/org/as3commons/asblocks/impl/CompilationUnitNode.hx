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
import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IFunctionType;
import org.as3commons.asblocks.api.IInternalClass;
import org.as3commons.asblocks.api.IInternalFunction;
import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>ICompilationUnit</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class CompilationUnitNode extends ScriptNode implements ICompilationUnit {

	//--------------------------------------------------------------------------
	//
	//  ICompilationUnit API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  project
	//----------------------------------

	/**
	 * @private
	 */
	@:allow(org.as3commons.asblocks.impl)
	private var _project:IASProject;

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#project
	 */
	public var project(get, never):IASProject;
	private function get_project():IASProject {
		return _project;
	}

	//----------------------------------
	//  sourceCode
	//----------------------------------

	/**
	 * @private
	 */
	private var _sourceCode:ISourceCode;

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#sourceCode
	 */
	public var sourceCode(get, set):ISourceCode;
	private function get_sourceCode():ISourceCode {
		if (_sourceCode == null) {
			_sourceCode = new SourceCode();
		}
		return _sourceCode;
	}

	/**
	 * @private
	 */
	private function set_sourceCode(value:ISourceCode):ISourceCode {
		_sourceCode = value;
		return value;
	}

	//----------------------------------
	//  packageName
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#packageName
	 */
	public var packageName(get, set):String;
	private function get_packageName():String {
		return packageNode.name;
	}

	/**
	 * @private
	 */
	private function set_packageName(value:String):String {
		packageNode.name = value;
		return value;
	}

	//----------------------------------
	//  qualifiedName
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#packageName
	 */
	public var qname(get, never):ASQName;
	private function get_qname():ASQName {
		var qname:ASQName = new ASQName();
		qname.define(typeNode.name, packageNode.name);
		return qname;
	}

	//----------------------------------
	//  packageNode
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#packageNode
	 */
	public var packageNode(get, never):IPackage;
	private function get_packageNode():IPackage {
		var ast:IParserNode = node.getKind(AS3NodeKind.PACKAGE);
		if (ast == null) {
			return null;
		}

		return new PackageNode(ast);
	}

	//----------------------------------
	//  typeNode
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#typeNode
	 */
	public var typeNode(get, never):IType;
	private function get_typeNode():IType {
		var ast:IPackage = packageNode;
		if (ast == null) {
			return null;
		}

		return ast.typeNode;
	}

	//----------------------------------
	//  typeName
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#typeName
	 */
	public var typeName(get, set):String;
	private function get_typeName():String {
		return typeNode.name;
	}

	/**
	 * @private
	 */
	private function set_typeName(value:String):String {
		typeNode.name = value;
		return value;
	}

	//----------------------------------
	//  internalClasses
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#internalClasses
	 */
	public var internalClasses(get, never):Array<IClassType>;
	private function get_internalClasses():Array<IClassType> {
		var result:Array<IClassType> = new Array<IClassType>();
		var ast:IParserNode = findContent();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			var current:IParserNode = i.next();
			if (current.isKind(AS3NodeKind.CLASS)) {
				result.push(new ClassTypeNode(current));
			}
		}
		return result;
	}

	//----------------------------------
	//  internalFunctions
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#internalFunctions
	 */
	public var internalFunctions(get, never):Array<IFunctionType>;
	private function get_internalFunctions():Array<IFunctionType> {
		var result:Array<IFunctionType> = new Array<IFunctionType>();
		var ast:IParserNode = findContent();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			var current:IParserNode = i.next();
			if (current.isKind(AS3NodeKind.FUNCTION)) {
				result.push(new FunctionTypeNode(current));
			}
		}
		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(node:IParserNode) {
		super(node);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#newInternalClass()
	 */
	public function newInternalClass(name:String):IInternalClass {
		var ast:IParserNode = ASTTypeBuilder.newClassAST(name, false);
		addInternal(ast);
		return new InternalClassNode(ast);
	}

	/**
	 * @copy org.as3commons.asblocks.api.ICompilationUnit#newInternalFunction()
	 */
	public function newInternalFunction(name:String, returnType:String):IInternalFunction {
		var ast:IParserNode = ASTFunctionBuilder.newFunctionAST(name, returnType, false);
		addInternal(ast);
		return new InternalFunctionNode(ast);
	}

	private function findContent():IParserNode {
		return node.getKind(AS3NodeKind.CONTENT);
	}

	private function addInternal(ast:IParserNode):Void {
		var content:IParserNode = findContent();
		if (content == null) {
			content = ASTBuilder.newAST(AS3NodeKind.INTERNAL_CONTENT);
			node.addChild(content);
		}
		content.appendToken(TokenBuilder.newNewline());
		content.addChild(ast);
	}

}