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

package org.as3commons.asblocks.api;

/**
 * A for ( in ) statement; <code>for (declaration in target) { }</code>.
 *
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var declaration:IExpression = factory.newExpression("foo");
 * var target:IExpression = factory.newExpression("bar");
 * var fs:IForInStatement = block.newForIn(declaration, target);
 * fs.addStatement("trace('do work')");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for (foo in bar) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 *
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var declaration:IExpression = factory.newDeclaration("foo:String");
 * var target:IExpression = factory.newExpression("getObject(baz)");
 * var fs:IForInStatement = block.newForIn(declaration, target);
 * fs.addStatement("trace('do work')");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for (var foo:String in getObject(baz)) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IStatementContainer#newForIn()
 * @see org.as3commons.asblocks.ASFactory#newDeclaration()
 */
interface IForInStatement extends IStatement extends IStatementContainer {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  initializer
	//----------------------------------

	/**
	 * The loop initializer, this can be an <code>IExpression</code> or
	 * <code>IDeclarationStatement</code>.
	 */
	var initializer(get, set):IScriptNode;

	/**
	 * @private
	 */

	//----------------------------------
	//  iterated
	//----------------------------------

	/**
	 * The iterated loop expression.
	 */
	var iterated(get, set):IExpression;

}