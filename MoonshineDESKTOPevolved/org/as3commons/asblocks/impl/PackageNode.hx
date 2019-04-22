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

import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IPackage</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class PackageNode extends ScriptNode implements IPackage {

	//--------------------------------------------------------------------------
	//
	//  IPackage API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IPackage#name
	 */
	public var name(get, set):String;
	private function get_name():String {
		var n:IParserNode = node.getKind(AS3NodeKind.NAME);
		if (n != null) {
			return n.stringValue;
		}

		return null;
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		var i:ASTIterator = new ASTIterator(node);
		var first:IParserNode = i.next();

		// a package can have an asdoc, which would be first
		if (first.isKind(AS3NodeKind.AS_DOC)) {
			first = i.next();
		}

		// if name null, remove NAME node
		if (value == null && first.isKind(AS3NodeKind.NAME)) {
			i.remove();
			return value;
		}

		// replace with new NAME parsed node or add it new
		var ast:IParserNode = AS3FragmentParser.parseName(value);
		if (first.isKind(AS3NodeKind.NAME)) {
			i.replace(ast);
		} else {
			i.insertBeforeCurrent(ast);
		}

		ast.appendToken(TokenBuilder.newSpace());
		return value;
	}

	//----------------------------------
	//  typeNode
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IPackage#typeNode
	 */
	public var typeNode(get, never):IType;
	private function get_typeNode():IType {
		var ast:IParserNode = findContent();
		if (ast.hasKind(AS3NodeKind.CLASS)) {
			return new ClassTypeNode(ast.getKind(AS3NodeKind.CLASS));
		} else if (ast.hasKind(AS3NodeKind.INTERFACE)) {
			return new InterfaceTypeNode(ast.getKind(AS3NodeKind.INTERFACE));
		} else if (ast.hasKind(AS3NodeKind.FUNCTION)) {
			return new FunctionTypeNode(ast.getKind(AS3NodeKind.FUNCTION));
		}
		return null;
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
	//  IPackage API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IPackage#addImports()
	 */
	public function addImports(name:String):Void {
		var ast:IParserNode = AS3FragmentParser.parseImport(name);
		var pos:Int = nextInsertion();
		ASTUtil.addChildWithIndentation(findContent(), ast, pos);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IPackage#removeImport()
	 */
	public function removeImport(name:String):Bool {
		var i:ASTIterator = getContentIterator();
		var ast:IParserNode;
		while (ast != null = i.search(AS3NodeKind.IMPORT) != null) {
			if (importText(ast) == name) {
				i.remove();
				return true;
			}
		}
		return false;
	}

	/**
	 * @copy org.as3commons.asblocks.api.IPackage#findImports()
	 */
	public function findImports():Array<String> {
		var i:ASTIterator = getContentIterator();
		var ast:IParserNode;
		var result:Array<String> = new Array<String>();
		while (ast != null = i.search(AS3NodeKind.IMPORT) != null) {
			result.push(importText(ast));
		}

		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function getContentIterator():ASTIterator {
		return new ASTIterator(findContent());
	}

	/**
	 * @private
	 */
	private function findContent():IParserNode {
		return node.getLastChild();
	}

	/**
	 * @private
	 */
	private function importText(ast:IParserNode):String {
		return ast.getFirstChild().stringValue;
	}

	/**
	 * @private
	 */
	private function nextInsertion():Int {
		var i:ASTIterator = getContentIterator();
		var index:Int = 0;
		while (i.search(AS3NodeKind.IMPORT) != null) {
			index = AS3.int(i.currentIndex + 1);
		}
		return index;
	}

}