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

package org.as3commons.mxmlblocks.impl;

import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.mxmlblocks.api.IScriptBlock;
import org.as3commons.mxmlblocks.api.IScriptTag;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

/**
 * The <code>IScriptTag</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ScriptTagNode extends ScriptNode implements IScriptTag {

	//--------------------------------------------------------------------------
	//
	//  IAttribute API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  block
	//----------------------------------

	/**
	 * doc
	 */
	public var block(get, never):IScriptBlock;
	private function get_block():IScriptBlock {
		return new ScriptBlockNode(findBody());
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

	private function findBody():IParserNode {
		return node.getKind(MXMLNodeKind.BODY);
	}

}