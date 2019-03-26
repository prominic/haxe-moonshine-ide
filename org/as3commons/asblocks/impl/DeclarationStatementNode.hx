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

import org.as3commons.asblocks.api.IDeclaration;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IDeclarationStatement</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class DeclarationStatementNode extends ScriptNode implements IDeclarationStatement {

	public var name(get, never):String;
	public var type(get, never):String;
	public var initializer(get, never):IExpression;
	public var declarations(get, never):Array<IDeclaration>;
	public var isConstant(get, set):Bool;

	//--------------------------------------------------------------------------
	//
	//  IDeclarationStatement API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#name
	 */
	private function get_name():String {
		return getFirstDeclaration().name;
	}

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#type
	 */
	private function get_type():String {
		return getFirstDeclaration().type;
	}

	//----------------------------------
	//  initializer
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#initializer
	 */
	private function get_initializer():IExpression {
		return getFirstDeclaration().initializer;
	}

	//----------------------------------
	//  declarations
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#declarations
	 */
	private function get_declarations():Array<IDeclaration> {
		var result:Array<IDeclaration> = new Array<IDeclaration>();
		var i:ASTIterator = new ASTIterator(node);
		i.next(); // dec-role
		while (i.hasNext()) {
			result.push(build(i.next()));
		}
		return result;
	}

	//----------------------------------
	//  isConstant
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#isConstant
	 */
	private function get_isConstant():Bool
	// dec-list/dec-role
	 {

		return findDecRole().getFirstChild().isKind(AS3NodeKind.CONST);
	}

	/**
	 * @private
	 */
	private function set_isConstant(value:Bool):Bool {
		var roleList:IParserNode = findDecRole();
		if (value && roleList.getFirstChild().isKind(AS3NodeKind.CONST)) {
			return value;
		}

		var kind:String = ((value)) ? AS3NodeKind.CONST : AS3NodeKind.VAR;
		var role:IParserNode = ASTBuilder.newAST(AS3NodeKind.DEC_ROLE);
		var ast:IParserNode = ASTBuilder.newAST(kind);
		role.addChild(ast);
		role.appendToken(TokenBuilder.newToken(kind, kind));
		node.setChildAt(role, 0);
		role.appendToken(TokenBuilder.newSpace());
		return value;
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
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function findDecRole():IParserNode {
		return node.getFirstChild();
	}

	/**
	 * @private
	 */
	private function getFirstDeclaration():IDeclaration {
		return build(node.getChild(1));
	}

	/**
	 * @private
	 */
	private function build(ast:IParserNode):IDeclaration {
		return new Declaration(ast);
	}

}