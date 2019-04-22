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
 * A for ( ; ; ) statement; <code>for (initializer; condition; iterator) { }</code>.
 *
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var intializer:IExpression = factory.newExpression("i = 0");
 * var condition:IExpression = factory.newExpression("i < len");
 * var iterator:IExpression = factory.newExpression("i++");
 * var fs:IForStatement = block.newFor(intializer, condition, iterator);
 * fs.addStatement("trace('do work')");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for (i = 0; i < len; i++) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 *
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var intializer:IExpression = factory.newExpression("i = 0");
 * var condition:IExpression = factory.newExpression("i < len");
 * var iterator:IExpression = factory.newExpression("i++");
 * var fs:IForStatement = block.newFor(intializer, condition, iterator);
 * fs.initializer = factory.newDeclaration("j:int = 0");
 * fs.condition = factory.newExpression("j >= len");
 * fs.iterator = factory.newExpression("--j");
 * fs.addStatement("trace('do work')");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for (var j:int = 0; j >= len; --j) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.IStatementContainer#newFor()
 * @see org.as3commons.asblocks.ASFactory#newDeclaration()
 */
interface IForStatement extends IStatement extends IStatementContainer {

	/**
	 * @private
	 */
	var initializer(get, set):IScriptNode;

	/**
	 * @private
	 */
	var condition(get, set):IExpression;

	/**
	 * @private
	 */
	var iterator(get, set):IExpression;

}