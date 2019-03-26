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

import org.as3commons.asblocks.parser.api.ASDocNodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.api.IDocTag;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IDocTag</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class DocTagNode extends ScriptNode implements IDocTag {

	public var name(get, set):String;
	public var body(get, set):String;

	//--------------------------------------------------------------------------
	//
	//  IDocTag API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocTag#name
	 */
	private function get_name():String {
		return ASTUtil.nameText(node.getKind(ASDocNodeKind.NAME));
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		return value;
	}

	//----------------------------------
	//  body
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocTag#body
	 */
	private function get_body():String {
		return ASTUtil.nameText(node.getKind(ASDocNodeKind.BODY));
	}

	/**
	 * @private
	 */
	private function set_body(value:String):String {
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

}