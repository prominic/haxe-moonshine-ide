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
import org.as3commons.asblocks.parser.api.ITokenListUpdateDelegate;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * A parser node that contains parser node children.
 *
 * <p>Initial API; Adobe Systems, Incorporated</p>
 *
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
class NestedNode {

	public var parent(get, set):IParserNode;
	public var kind(get, set):String;
	public var children(get, never):Array<IParserNode>;
	public var numChildren(get, never):Int;

	public var noUpdate:Bool = false;

	public var tokenListUpdater:ITokenListUpdateDelegate;

	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  parent
	//----------------------------------

	/**
	 * @private
	 */
	private var _parent:IParserNode;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#parent
	 */
	private function get_parent():IParserNode {
		return _parent;
	}

	/**
	 * @private
	 */
	private function set_parent(value:IParserNode):IParserNode {
		_parent = value;
		return value;
	}

	//----------------------------------
	//  kind
	//----------------------------------

	/**
	 * @private
	 */
	private var _kind:String;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#kind
	 */
	private function get_kind():String {
		return _kind;
	}

	/**
	 * @private
	 */
	private function set_kind(value:String):String {
		_kind = value;
		return value;
	}

	//----------------------------------
	//  children
	//----------------------------------

	/**
	 * @private
	 */
	private var _children:Array<IParserNode>;

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#children
	 */
	private function get_children():Array<IParserNode> {
		return _children;
	}

	//----------------------------------
	//  numChildren
	//----------------------------------

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#numChildren
	 */
	private function get_numChildren():Int {
		if (_children == null) {
			return 0;
		}
		return _children.length;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Creates a new Node instance.
	 *
	 * @param kind A String parser node kind.
	 * @param child The node child.
	 */
	public function new(kind:String, child:IParserNode) {
		_kind = kind;

		addChild(child);
	}

	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#contains()
	 */
	public function contains(node:IParserNode):Bool {
		if (numChildren == 0) {
			return false;
		}

		var kind:String = node.kind;
		var unique:Array<IParserNode> = ASTUtil.getNodes(kind, cast((this), IParserNode));
		if (unique == null || unique.length == 0) {
			return false;
		}

		var len:Int = unique.length;
		for (i in 0...len) {
			if (unique[i] == node) {
				return true;
			}
		}

		return false;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#isKind()
	 */
	public function isKind(kind:String):Bool {
		if (_kind == kind) {
			return true;
		}
		return false;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#hasKind()
	 */
	public function hasKind(kind:String):Bool {
		if (numChildren == 0) {
			return false;
		}

		var len:Int = children.length;
		for (i in 0...len) {
			if (children[i].isKind(kind)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getChild()
	 */
	public function getChild(index:Int):IParserNode {
		if (_children == null || _children.length == 0) {
			return null;
		}

		if (index < 0 || index > _children.length - 1) {
			return null;
		}

		return _children[index];
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getChildIndex()
	 */
	public function getChildIndex(child:IParserNode):Int {
		if (numChildren == 0) {
			return -1;
		}

		var len:Int = children.length;
		for (i in 0...len) {
			if (children[i] == child) {
				return i;
			}
		}

		return -1;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getKind()
	 */
	public function getKind(kind:String):IParserNode {
		if (numChildren == 0) {
			return null;
		}

		var len:Int = children.length;
		for (i in 0...len) {
			if (children[i].isKind(kind)) {
				return children[i];
			}
		}

		return null;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getFirstChild()
	 */
	public function getFirstChild():IParserNode {
		if (_children == null || _children.length == 0) {
			return null;
		}

		return _children[0];
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getLastChild()
	 */
	public function getLastChild():IParserNode {
		if (_children == null || _children.length == 0) {
			return null;
		}

		return _children[_children.length - 1];
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addChild()
	 */
	public function addChild(child:IParserNode):IParserNode {
		if (child == null) {
			return null;
		}

		if (_children == null) {
			_children = new Array<IParserNode>();
		}

		_children.push(child);

		if (child != null) {
			child.parent = try cast(this, IParserNode) catch (e:Dynamic) null;
		}

		if (!noUpdate && tokenListUpdater != null) {
			tokenListUpdater.addedChild(try cast(this, IParserNode) catch (e:Dynamic) null, child);
		}

		return child;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addChildAt()
	 */
	public function addChildAt(child:IParserNode, index:Int):IParserNode {
		if (child == null) {
			return null;
		}

		if (index > numChildren) {
			index = numChildren;
		}

		if (_children == null) {
			_children = new Array<IParserNode>();
		}

		as3hx.Compat.arraySplice(_children, index, 0, [child]);

		if (child != null) {
			child.parent = try cast(this, IParserNode) catch (e:Dynamic) null;
		}

		if (!noUpdate && tokenListUpdater != null) {
			tokenListUpdater.addedChildAt(try cast(this, IParserNode) catch (e:Dynamic) null, index, child);
		}

		return child;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeKind()
	 */
	public function removeKind(kind:String):Bool {
		if (!hasKind(kind)) {
			return false;
		}

		var len:Int = children.length;
		for (i in 0...len) {
			if (children[i].isKind(kind)) {
				children.splice(i, 1);
				return true;
			}
		}

		return false;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeChild()
	 */
	public function removeChild(node:IParserNode):IParserNode {
		if (numChildren == 0) {
			return null;
		}

		var len:Int = children.length;
		for (i in 0...len) {
			if (children[i] == node) {
				children.splice(i, 1);

				if (!noUpdate && tokenListUpdater != null) {
					tokenListUpdater.deletedChild(try cast(this, IParserNode) catch (e:Dynamic) null, i, node);
					node.parent = null;
				}
				return node;
			}
		}

		return null;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeChildAt()
	 */
	public function removeChildAt(index:Int):IParserNode {
		if (numChildren == 0) {
			return null;
		}

		var old:IParserNode = getChild(index);
		children.splice(index, 1);

		if (!noUpdate && tokenListUpdater != null) {
			tokenListUpdater.deletedChild(try cast(this, IParserNode) catch (e:Dynamic) null, index, old);
			old.parent = null;
		}

		return old;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#setChildAt()
	 */
	public function setChildAt(child:IParserNode, index:Int):IParserNode {
		if (child == null) {
			return null;
		}

		if (index > numChildren) {
			index = numChildren;
		}

		if (_children == null) {
			_children = new Array<IParserNode>();
		}

		var old:IParserNode = getChild(index);
		if (old != null) {
			old.parent = null;
		}
		try cast(as3hx.Compat.arraySplice(_children, index, 1, [child]), IParserNode) catch (e:Dynamic) null;

		if (!noUpdate && tokenListUpdater != null) {
			tokenListUpdater.replacedChild(cast((this), IParserNode), index, child, old);
		}

		return old;
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addTokenAt()
	 */
	public function addTokenAt(token:LinkedListToken, index:Int):Void {
		tokenListUpdater.addToken(cast((this), IParserNode), index, token);
	}

	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#appendToken()
	 */
	public function appendToken(token:LinkedListToken):Void {
		if (!noUpdate && tokenListUpdater != null) {
			tokenListUpdater.appendToken(cast((this), IParserNode), token);
		}
	}

	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function addRawChild(kind:String,
			line:Int,
			column:Int,
			stringValue:String):IParserNode {
		return addChild(Node.create(kind, line, column, stringValue));
	}

	/**
	 * @private
	 */
	public function addNodeChild(kind:String,
			line:Int,
			column:Int,
			sibling:IParserNode):IParserNode {
		var node:IParserNode = Node.create(kind, line, column, null);
		node.addChild(sibling);
		return addChild(node);
	}

}