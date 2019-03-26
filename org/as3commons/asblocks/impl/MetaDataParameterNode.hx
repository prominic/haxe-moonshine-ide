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

import org.as3commons.asblocks.api.IMetaDataParameter;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IMetaDataParameter</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class MetaDataParameterNode extends ScriptNode implements IMetaDataParameter {

	public var value(get, never):String;
	public var name(get, never):String;
	public var hasName(get, never):Bool;

	//--------------------------------------------------------------------------
	//
	//  IMetaDataParameter API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  value
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataParameter#value
	 */
	private function get_value():String {
		if (hasName) {
			return ASTUtil.stringifyNode(node.getLastChild());
		}
		return ASTUtil.stringifyNode(node.getFirstChild());
	}

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataParameter#name
	 */
	private function get_name():String {
		var ast:IParserNode = findName();
		if (ast == null) {
			return null;
		}
		return ast.stringValue;
	}

	//----------------------------------
	//  label
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataParameter#hasName
	 */
	private function get_hasName():Bool {
		return findName() != null;
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

	private function findName():IParserNode {
		return node.getKind(AS3NodeKind.NAME);
	}

}