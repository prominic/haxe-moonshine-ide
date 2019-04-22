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
import org.as3commons.asblocks.api.IDocTag;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.DocCommentUtil;

/**
 * The <code>IDocComment</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class DocCommentNode extends ScriptNode implements IDocComment {

	//--------------------------------------------------------------------------
	//
	//  IDocComment API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  asdocNode
	//----------------------------------

	/**
	 * @private
	 */
	private var _asdocNode:IParserNode;

	/**
	 * @copy org.as3commons.asblocks.api.IDocComment#asdocNode
	 */
	public var asdocNode(get, set):IParserNode;
	private function get_asdocNode():IParserNode {
		return _asdocNode;
	}

	/**
	 * @private
	 */
	private function set_asdocNode(value:IParserNode):IParserNode {
		_asdocNode = value;
		return value;
	}

	//----------------------------------
	//  description
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocComment#description
	 */
	public var description(get, set):String;
	private function get_description():String {
		return DocCommentUtil.getDescription(this);
	}

	/**
	 * @private
	 */
	private function set_description(value:String):String {
		DocCommentUtil.setDescription(this, value);
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
		super(node);// node is IDocCommentAware.node

		asdocNode = DocCommentUtil.buildCompilationUnit(node);
	}

	//--------------------------------------------------------------------------
	//
	//  IDocComment API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocComment#newDocTag()
	 */
	public function newDocTag(name:String, body:String = null):IDocTag {
		return DocCommentUtil.newDocTag(this, name, body);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IDocComment#removeDocTag()
	 */
	public function removeDocTag(tag:IDocTag):Bool {
		return DocCommentUtil.removeDocTag(this, tag);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IDocComment#hasDocTag()
	 */
	public function hasDocTag(name:String):Bool {
		//if (!asdocNode)
		//{
		//	asdocNode = DocCommentUtil.buildASDoc(node);
		//}

		return DocCommentUtil.hasDocTag(node, name);
	}

	public function commitModifiedAST():Void {}

}