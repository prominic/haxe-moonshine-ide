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

package org.as3commons.asblocks.parser.api;

import org.as3commons.asblocks.parser.core.LinkedListToken;

/**
 * The <strong>IParserNode</strong> interface marks a class as having the
 * ability to be placed in an AST parse tree with tokens.
 *
 * <p>Initial API; Adobe Systems, Incorporated</p>
 *
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
interface IParserNode {

	/**
	 * @private
	 */

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  parent
	//----------------------------------

	/**
	 * The parent node.
	 */
	var parent(get, set):IParserNode;

	/**
	 * @private
	 */

	//----------------------------------
	//  kind
	//----------------------------------

	/**
	 * The String kind (type) of parser node.
	 */
	var kind(get, set):String;

	/**
	 * @private
	 */

	//----------------------------------
	//  stringValue
	//----------------------------------

	/**
	 * The parser node's String value (if any).
	 */
	var stringValue(get, set):String;

	/**
	 * @private
	 */

	//----------------------------------
	//  line
	//----------------------------------

	/**
	 * The line the parser node starts at.
	 */
	var line(get, set):Int;

	/**
	 * @private
	 */

	//----------------------------------
	//  column
	//----------------------------------

	/**
	 * The column the parser node starts at.
	 */
	var column(get, set):Int;

	//----------------------------------
	//  start
	//----------------------------------

	/**
	 * The parser node's start offest.
	 */
	var start(get, never):Int;

	//----------------------------------
	//  end
	//----------------------------------

	/**
	 * The parser node's end offest.
	 */
	var end(get, never):Int;

	//----------------------------------
	//  children
	//----------------------------------

	/**
	 * The parser node's <code>IParserNode</code> children.
	 */
	var children(get, never):Array<IParserNode>;

	//----------------------------------
	//  numChildren
	//----------------------------------

	/**
	 * The parser node's <code>IParserNode</code> child length.
	 */
	var numChildren(get, never):Int;

	/**
	 * @private
	 */

	//----------------------------------
	//  stopToken
	//----------------------------------

	/**
	 * The token this nodes stops at in the token stream.
	 */
	var stopToken(get, set):LinkedListToken;

	/**
	 * @private
	 */

	//----------------------------------
	//  startToken
	//----------------------------------

	/**
	 * The token this nodes starts at in the token stream.
	 */
	var startToken(get, set):LinkedListToken;

	/**
	 * @private
	 */

	//----------------------------------
	//  initialInsertionAfter
	//----------------------------------

	/**
	 * The initial token insertion point after (used in parenthetic updates).
	 */
	var initialInsertionAfter(get, set):LinkedListToken;

	/**
	 * @private
	 */

	//----------------------------------
	//  initialInsertionBefore
	//----------------------------------

	/**
	 * The initial token insertion point before (used in parenthetic updates).
	 */
	var initialInsertionBefore(get, set):LinkedListToken;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Whether this node contains the other.
	 *
	 * @param other The opther parser node to compare.
	 * @return A Boolean indicating whether the node contains the other node.
	 */
	function contains(other:IParserNode):Bool;

	/**
	 * Returns the <code>kind</code> of parser node.
	 *
	 * @param kind A String parser node kind.
	 * @return A Boolean indicating if the kind exists within this parser node.
	 */
	function isKind(kind:String):Bool;

	/**
	 * Returns whether the node has a <code>kind</code> parser node child.
	 *
	 * @param kind A String parser node kind.
	 * @return A Boolean indicating whether the kind exists on the parser node.
	 */
	function hasKind(kind:String):Bool;

	/**
	 * Returns the <code>IParserNode</code> at the specified index.
	 *
	 * @param index An int index to retrieve the child.
	 * @return The <code>IParserNode</code> at the specified index
	 * or <code>null</code>.
	 */
	function getChild(index:Int):IParserNode;

	/**
	 * Returns the child index of the node if it is parented by this node.
	 *
	 * @param node The node to retrieve the index for.
	 * @return An int index number.
	 */
	function getChildIndex(node:IParserNode):Int;

	/**
	 * Returns the first child by node kind.
	 *
	 * @param kind The String kind.
	 * @return The first node or null.
	 */
	function getKind(kind:String):IParserNode;

	/**
	 * Returns the first <code>IParserNode</code> child.
	 *
	 * @return The first <code>IParserNode</code> or <code>null</code>.
	 */
	function getFirstChild():IParserNode;

	/**
	 * Returns the last <code>IParserNode</code> child.
	 *
	 * @return The last <code>IParserNode</code> or <code>null</code>.
	 */
	function getLastChild():IParserNode;

	/**
	 * Adds an <code>IParserNode</code> child to the children of this parser node.
	 *
	 * @param The <code>IParserNode</code> to add.
	 * @return The <code>IParserNode</code> added.
	 */
	function addChild(node:IParserNode):IParserNode;

	/**
	 * Adds an <code>IParserNode</code> child to the children of this parser node
	 * at the specified index.
	 *
	 * @param The <code>IParserNode</code> to add.
	 * @param index The int index to add the child at.
	 * @return The <code>IParserNode</code> added.
	 */
	function addChildAt(node:IParserNode, index:Int):IParserNode;

	/**
	 * Removes the node.
	 *
	 * @param node An IParserNode parser node.
	 * @return A Boolean indicating whether the node was removed from the parser node.
	 */
	function removeChild(node:IParserNode):IParserNode;

	/**
	 * Removes the node at the specified index.
	 *
	 * @param index An int index to remove.
	 * @return A parser node removed.
	 */
	function removeChildAt(index:Int):IParserNode;

	/**
	 * Removes the first <code>kind</code> found.
	 *
	 * @param kind A String parser node kind.
	 * @return A Boolean indicating whether the kind was removed from the parser node.
	 */
	function removeKind(kind:String):Bool;

	/**
	 * Replaces the child at the specified index.
	 *
	 * @param child
	 * @param index
	 */
	function setChildAt(child:IParserNode, index:Int):IParserNode;

	//----------------------------------
	//  Tokens
	//----------------------------------

	/**
	 * Appends a token to the token stream.
	 */
	function appendToken(token:LinkedListToken):Void;

	/**
	 * Adds a token in the token stream at the specified child index.
	 */
	function addTokenAt(token:LinkedListToken, index:Int):Void;

}