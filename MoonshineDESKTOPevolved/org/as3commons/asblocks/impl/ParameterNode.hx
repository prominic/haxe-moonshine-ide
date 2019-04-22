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

import flash.errors.Error;
import org.as3commons.asblocks.api.IParameter;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IParameter</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ParameterNode extends ScriptNode implements IParameter {

	//--------------------------------------------------------------------------
	//
	//  IParameter API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  description
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#description
	 */
	public var description(get, set):String;
	private function get_description():String {
		return null;
	}

	/**
	 * @private
	 */
	private function set_description(value:String):String {
		// TODO (mschmalle) impl ParameterNode#description
		return value;
	}

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#name
	 */
	public var name(get, set):String;
	private function get_name():String {
		if (isRest) {
			return findRest().stringValue;
		}

		var ast:IParserNode = findNameTypeInit();
		var name:IParserNode = ast.getKind(AS3NodeKind.NAME);
		if (name != null) {
			return ASTUtil.nameText(name);
		}

		// IllegalStateException
		throw new Error('No parameter name, and not a \'rest\' parameter');
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		if (isRest) {
			findRest().stringValue = value;
			return value;
		}

		var ast:IParserNode = findNameTypeInit();
		var name:IParserNode = ast.getKind(AS3NodeKind.NAME);
		if (name != null) {
			name.stringValue = value;
		}
		return value;
	}

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#type
	 */
	public var type(get, set):String;
	private function get_type():String {
		if (isRest) {
			return null;
		}

		return NameTypeUtil.getType(findNameTypeInit());
	}

	/**
	 * @private
	 */
	private function set_type(value:String):String {
		if (isRest) {
			return value;
		}

		var ast:IParserNode = findNameTypeInit();
		var typeAST:IParserNode = ast.getKind(AS3NodeKind.TYPE);
		if (typeAST != null) {
			typeAST.stringValue = value;
		}
		return value;
	}

	//----------------------------------
	//  qualifiedType
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#qualifiedType
	 */
	public var qualifiedType(get, never):String;
	private function get_qualifiedType():String {
		if (type == null) {
			return null;
		}

		return ASTUtil.qualifiedNameForTypeString(node, type);
	}

	//----------------------------------
	//  hasType
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#hasType
	 */
	public var hasType(get, never):Bool;
	private function get_hasType():Bool {
		return NameTypeUtil.hasType(findNameTypeInit());
	}

	//----------------------------------
	//  defaultValue
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#defaultValue
	 */
	public var defaultValue(get, set):String;
	private function get_defaultValue():String {
		if (isRest) {
			return null;
		}

		var ast:IParserNode = findNameTypeInit();
		var init:IParserNode = ast.getKind(AS3NodeKind.INIT);
		if (init != null) {
			return ASTUtil.initText(init);
		}

		return null;
	}

	/**
	 * @private
	 */
	private function set_defaultValue(value:String):String {
		if (isRest) {
			return value;
		}

		var ast:IParserNode = findNameTypeInit();
		var initAST:IParserNode = ast.getKind(AS3NodeKind.INIT);
		if (initAST == null) {
			initAST = ASTBuilder.newAST(AS3NodeKind.INIT);
			ast.addChild(initAST);
		}

		initAST.stringValue = value;
		return value;
	}

	//----------------------------------
	//  hasDefaultValue
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#hasDefaultValue
	 */
	public var hasDefaultValue(get, never):Bool;
	private function get_hasDefaultValue():Bool {
		if (isRest) {
			return false;
		}

		return defaultValue != null;
	}

	//----------------------------------
	//  isRest
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParameter#isRest
	 */
	public var isRest(get, never):Bool;
	private function get_isRest():Bool {
		return node.hasKind(AS3NodeKind.REST);
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

	/**
	 * @private
	 */
	private function findNameTypeInit():IParserNode {
		return node.getKind(AS3NodeKind.NAME_TYPE_INIT);
	}

	/**
	 * @private
	 */
	private function findRest():IParserNode {
		return node.getKind(AS3NodeKind.REST);
	}

}