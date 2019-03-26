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
 * A binary expression; <code>a == b;</code>, <code>a != b;</code>
 * or <code>a + b;</code>.
 *
 * <pre>
 * var left:IExpression = factory.newExpression("a");
 * var right:IExpression = factory.newExpression("b");
 * var expression:IBinaryExpression = factory.newAndExpression(left, right);
 * </pre>
 *
 * <p>Will produce <code>a && b</code>.</p>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.api.BinaryOperator
 *
 * @see org.as3commons.asblocks.ASFactory#newAddExpression()
 * @see org.as3commons.asblocks.ASFactory#newAndExpression()
 * @see org.as3commons.asblocks.ASFactory#newBitAndExpression()
 * @see org.as3commons.asblocks.ASFactory#newBitOrExpression()
 * @see org.as3commons.asblocks.ASFactory#newBitXorExpression()
 * @see org.as3commons.asblocks.ASFactory#newDivisionExpression()
 * @see org.as3commons.asblocks.ASFactory#newEqualsExpression()
 * @see org.as3commons.asblocks.ASFactory#newGreaterEqualsExpression()
 * @see org.as3commons.asblocks.ASFactory#newGreaterThanExpression()
 * @see org.as3commons.asblocks.ASFactory#newLessEqualsExpression()
 * @see org.as3commons.asblocks.ASFactory#newLessThanExpression()
 * @see org.as3commons.asblocks.ASFactory#newModuloExpression()
 * @see org.as3commons.asblocks.ASFactory#newMultiplyExpression()
 * @see org.as3commons.asblocks.ASFactory#newNotEqualsExpression()
 * @see org.as3commons.asblocks.ASFactory#newOrExpression()
 * @see org.as3commons.asblocks.ASFactory#newShiftLeftExpression()
 * @see org.as3commons.asblocks.ASFactory#newShiftRightExpression()
 * @see org.as3commons.asblocks.ASFactory#newShiftRightUnsignedExpression()
 * @see org.as3commons.asblocks.ASFactory#newSubtractExpression()
 */
interface IBinaryExpression extends IExpression {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  leftExpression
	//----------------------------------

	/**
	 * The <code>IExpression</code> contained on the left side of the binary relation.
	 */
	var leftExpression(get, set):IExpression;

	/**
	 * @private
	 */

	//----------------------------------
	//  operator
	//----------------------------------

	/**
	 * The relation's binrary operator eg; <code>+</code>, <code>==</code>,
	 * <code>!=</code>, ect.
	 */
	var operator(get, set):BinaryOperator;

	/**
	 * @private
	 */

	//----------------------------------
	//  rightExpression
	//----------------------------------

	/**
	 * The <code>IExpression</code> contained on the right side of the binary relation.
	 */
	var rightExpression(get, set):IExpression;

}