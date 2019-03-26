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

package org.as3commons.asblocks.parser.core;

import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * A parser node that does not contain parser node children.
 *
 * <p>Initial API; Adobe Systems, Incorporated</p>
 *
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
class Node extends NestedNode implements IParserNode {

	public var start(get, set):Int;
	public var end(get, set):Int;
	public var column(get, set):Int;
	public var line(get, set):Int;
	public var stringValue(get, set):String;
	public var startToken(get, set):LinkedListToken;
	public var stopToken(get, set):LinkedListToken;
	public var initialInsertionAfter(get, set):LinkedListToken;
	public var initialInsertionBefore(get, set):LinkedListToken;

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  start
	//----------------------------------

	/**
	 * @private
	 */
	private var _start:Int;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#start
	 */
	private function get_start():Int {
		return _start;
	}

	/**
	 * @private
	 */
	private function set_start(value:Int):Int {
		_start = value;
		return value;
	}

	//----------------------------------
	//  end
	//----------------------------------

	/**
	 * @private
	 */
	private var _end:Int;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#end
	 */
	private function get_end():Int {
		return _end;
	}

	/**
	 * @private
	 */
	private function set_end(value:Int):Int {
		_end = value;
		return value;
	}

	//----------------------------------
	//  column
	//----------------------------------

	/**
	 * @private
	 */
	private var _column:Int;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#column
	 */
	private function get_column():Int {
		return _column;
	}

	/**
	 * @private
	 */
	private function set_column(value:Int):Int {
		_column = value;
		return value;
	}

	//----------------------------------
	//  line
	//----------------------------------

	/**
	 * @private
	 */
	private var _line:Int;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#line
	 */
	private function get_line():Int {
		return _line;
	}

	/**
	 * @private
	 */
	private function set_line(value:Int):Int {
		_line = value;
		return value;
	}

	//----------------------------------
	//  stringValue
	//----------------------------------

	/**
	 * @private
	 */
	private var _stringValue:String;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#stringValue
	 */
	private function get_stringValue():String {
		return _stringValue;
	}

	/**
	 * @private
	 */
	private function set_stringValue(value:String):String {
		_stringValue = value;
		return value;
	}

	//----------------------------------
	//  startToken
	//----------------------------------

	/**
	 * @private
	 */
	private var _startToken:LinkedListToken;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#startToken
	 */
	private function get_startToken():LinkedListToken {
		return _startToken;
	}

	/**
	 * @private
	 */
	private function set_startToken(value:LinkedListToken):LinkedListToken {
		if (parent) {
			cast((parent), TokenNode).notifyChildStartTokenChange(this, value);
		}

		_startToken = value;
		return value;
	}

	//----------------------------------
	//  stopToken
	//----------------------------------

	/**
	 * @private
	 */
	private var _stopToken:LinkedListToken;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#stopToken
	 */
	private function get_stopToken():LinkedListToken {
		return _stopToken;
	}

	/**
	 * @private
	 */
	private function set_stopToken(value:LinkedListToken):LinkedListToken {
		if (parent) {
			cast((parent), TokenNode).notifyChildStopTokenChange(this, value);
		}

		_stopToken = value;
		return value;
	}

	//----------------------------------
	//  initialInsertionAfter
	//----------------------------------

	/**
	 * @private
	 */
	private var _initialInsertionAfter:LinkedListToken;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#initialInsertionAfter
	 */
	private function get_initialInsertionAfter():LinkedListToken {
		return _initialInsertionAfter;
	}

	/**
	 * @private
	 */
	private function set_initialInsertionAfter(value:LinkedListToken):LinkedListToken {
		_initialInsertionAfter = value;
		return value;
	}

	//----------------------------------
	//  initialInsertionBefore
	//----------------------------------

	/**
	 * @private
	 */
	private var _initialInsertionBefore:LinkedListToken;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#initialInsertionBefore
	 */
	private function get_initialInsertionBefore():LinkedListToken {
		return _initialInsertionBefore;
	}

	/**
	 * @private
	 */
	private function set_initialInsertionBefore(value:LinkedListToken):LinkedListToken {
		_initialInsertionBefore = value;
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 *
	 * @param kind The parser node kind.
	 * @param line The parser node line.
	 * @param column The parser node column.
	 * @param stringValue The parser node stringValue.
	 */
	public function new(kind:String,
			line:Int,
			column:Int,
			stringValue:String) {
		super(kind, null);

		_line = line;
		_column = column;
		_stringValue = stringValue;
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function toString():String {
		return kind;
	}

	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new <code>Node</code> instance.
	 *
	 * @param kind A String <code>NodeKind</code> indicating the kind of node.
	 * @param line The Integer line number.
	 * @param column The Integer column number.
	 * @param stringValue The String value of the node, can be null.
	 * @return A new <code>Node</code> instance.
	 * @deprecated
	 */
	public static function create(kind:String,
			line:Int,
			column:Int,
			stringValue:String = null):Node {
		return new Node(kind, line, column, stringValue);
	}

	/**
	 * Creates a new <code>Node</code> instance that will parent the
	 * <code>child</code>.
	 *
	 * @param kind A String <code>NodeKind</code> indicating the kind of node.
	 * @param line The Integer line number.
	 * @param column The Integer column number.
	 * @param child The <code>Node</code> that will be added as a child to the
	 * new <code>Node</code> created and returned.
	 * @return A new <code>Node</code> instance that is parenting the
	 * <code>child</code> node.
	 * @deprecated
	 */
	public static function createChild(kind:String,
			line:Int,
			column:Int,
			child:IParserNode):Node {
		var node:Node = new Node(kind, line, column, null);
		node.addChild(child);
		return node;
	}

}