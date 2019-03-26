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
 * A while statement; <code>while (condition) {}</code>.
 *
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var condition:IExpression = factory.newExpression("hasNext()");
 * var ws:IWhileStatement = block.newWhile(condition);
 * ws.addStatement("current = foo.next()");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	with (hasNext()) {
 * 		current = foo.next();
 * 	}
 * }
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IStatementContainer#newWhile()
 */
interface IWhileStatement extends IStatement extends IStatementContainer {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  condition
	//----------------------------------

	/**
	 * The while statement's condition expression.
	 */
	var condition(get, set):IExpression;

	//----------------------------------
	//  body
	//----------------------------------

	/**
	 * The while statement's body statement, usually a block.
	 */
	var body(get, never):IStatement;

}