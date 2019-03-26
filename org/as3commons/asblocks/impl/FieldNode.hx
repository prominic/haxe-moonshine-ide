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

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IField</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class FieldNode extends MemberNode implements IField {

	private var nameTypeInit(get, never):IParserNode;
	public var isConstant(get, set):Bool;
	public var initializer(get, set):IExpression;

	private function get_nameTypeInit():IParserNode {
		return node.getKind(AS3NodeKind.NAME_TYPE_INIT);
	}

	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMemberNode#name
	 */
	override private function get_name():String {
		var i:ASTIterator = new ASTIterator(nameTypeInit);
		return ASTUtil.nameText(i.find(AS3NodeKind.NAME));
	}

	/**
	 * @private
	 */
	override private function set_name(value:String):String {
		if (value.indexOf('.') != -1) {
			throw new ASBlocksSyntaxError('field name must not contain \.\');
		}
		var i:ASTIterator = new ASTIterator(nameTypeInit);
		i.find(AS3NodeKind.NAME);
		i.replace(ASTBuilder.newAST(AS3NodeKind.NAME, value));
		return value;
	}

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMemberNode#type
	 */
	override private function get_type():String {
		var i:ASTIterator = new ASTIterator(nameTypeInit);
		var result:IParserNode = i.search(AS3NodeKind.TYPE);
		if (result == null) {
			return null;
		}
		return result.stringValue;
	}

	/**
	 * @private
	 */
	override private function set_type(value:String):String {
		var i:ASTIterator = new ASTIterator(nameTypeInit);
		i.find(AS3NodeKind.TYPE);
		i.replace(ASTBuilder.newAST(AS3NodeKind.TYPE, value));
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  IField API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  isConstant
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFieldNode#isConstant
	 */
	private function get_isConstant():Bool {
		return node.getKind(AS3NodeKind.FIELD_ROLE).getFirstChild().isKind(AS3NodeKind.CONST);
	}

	/**
	 * @private
	 */
	private function set_isConstant(value:Bool):Bool {
		var role:IParserNode = node.getKind(AS3NodeKind.FIELD_ROLE);
		if (role.getFirstChild().isKind(AS3NodeKind.CONST) == value) {
			return value;
		}

		var node:LinkedListToken;
		if (value) {
			node = TokenBuilder.newConst();
		} else {
			node = TokenBuilder.newVar();
		}

		role.setChildAt(ASTUtil.newTokenAST(node), 0);
		return value;
	}

	//----------------------------------
	//  initializer
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFieldNode#initializer
	 */
	private function get_initializer():IExpression {
		var init:IParserNode = nameTypeInit.getKind(AS3NodeKind.INIT);
		if (init == null) {
			return null;
		}
		return ExpressionBuilder.build(init.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_initializer(value:IExpression):IExpression {
		if (value == null) {
			removeInitializer();
		} else {
			setInitAST(value.node);
		}
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
	private function setInitAST(expression:IParserNode):Void {
		var nti:IParserNode = nameTypeInit;
		var init:IParserNode = nti.getKind(AS3NodeKind.INIT);
		if (init == null) {
			init = ASTBuilder.newAST(AS3NodeKind.INIT, '=');
			init.addTokenAt(TokenBuilder.newSpace(), 0);
			init.appendToken(TokenBuilder.newSpace());
			nti.addChild(init);
		} else {
			init.removeChildAt(0);
		}

		init.addChild(expression);
	}

	/**
	 * @private
	 */
	private function removeInitializer():Void {
		var nti:IParserNode = nameTypeInit;
		var i:ASTIterator = new ASTIterator(nti);
		if (i.search(AS3NodeKind.INIT) != null) {
			i.remove();
		}
	}

}