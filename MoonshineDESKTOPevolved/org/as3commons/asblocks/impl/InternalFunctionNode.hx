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

import org.as3commons.asblocks.api.IDocComment;
import org.as3commons.asblocks.api.IInternalFunction;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.DocCommentUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IInternalFunction</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class InternalFunctionNode extends FunctionNodeBase implements IInternalFunction {

	//--------------------------------------------------------------------------
	//
	//  IInternalFunction API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IInternalFunction#name
	 */
	public var name(get, set):String;
	private function get_name():String {
		return NameTypeUtil.getName(node);
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		NameTypeUtil.setName(node, value);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  IDocCommentAware API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  description
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#description
	 */
	public var description(get, set):String;
	private function get_description():String {
		return null;
	}

	/**
	 * @private
	 */
	private function set_description(value:String):String {
		documentation.description = value;
		return value;
	}

	//----------------------------------
	//  documentation
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#documentation
	 */
	public var documentation(get, never):IDocComment;
	private function get_documentation():IDocComment {
		return DocCommentUtil.createDocComment(node);
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