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

import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IINvocation;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.ArgumentUtil;

/**
 * The <code>IINvocation</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class InvocationNode extends ExpressionNode implements IINvocation {

	public var target(get, set):IExpression;
	public var arguments(get, set):Array<IExpression>;
	private var hasArguments(get, never):Bool;

	//--------------------------------------------------------------------------
	//
	//  IINvocation API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  target
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IINvocation#target
	 */
	private function get_target():IExpression {
		return ExpressionBuilder.build(findCall().getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_target(value:IExpression):IExpression {
		findCall().setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  arguments
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IINvocation#arguments
	 */
	private function get_arguments():Array<IExpression> {
		return ArgumentUtil.getArguments(findArguments());
	}

	/**
	 * @private
	 */
	private function set_arguments(value:Array<IExpression>):Array<IExpression> {
		setArguments(value);
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
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function findCall():IParserNode {
		return node;
	}

	/**
	 * @private
	 */
	private function findTarget():IParserNode {
		return findCall().getFirstChild();
	}

	/**
	 * @private
	 */
	private function findArguments():IParserNode {
		return findCall().getLastChild();
	}

	/**
	 * @private
	 */
	private function get_hasArguments():Bool {
		return findArguments() != null;
	}

	/**
	 * @private
	 */
	private function setArguments(value:Array<IExpression>):Void {
		ArgumentUtil.setArguments(findCall(), value);
	}

}