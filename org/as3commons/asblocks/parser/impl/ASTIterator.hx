package org.as3commons.asblocks.parser.impl;

import flash.errors.Error;

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
class ASTIterator {

	public var current(get, never):IParserNode;
	public var currentIndex(get, never):Int;

	private var parent:IParserNode;

	private var index:Int = -1;

	private function get_current():IParserNode {
		return parent.getChild(index);
	}

	public function new(parent:IParserNode) {
		if (parent == null)
		//IllegalArgumentException
		{

			throw new Error('null not allowed');
		}
		this.parent = parent;
	}

	public function hasNext():Bool {
		return index < parent.numChildren - 1;
	}

	public function next(tokenKind:String = null):IParserNode {
		if (!hasNext())
		// IllegalStateException
		{

			throw new Error('expected ' + ASTUtil.tokenName(tokenKind) + ' but reached last child');
		}
		if (tokenKind != null && parent.getChild(index + 1).kind != tokenKind)
		// IllegalStateException
		{

			throw new Error('expected ' + ASTUtil.tokenName(tokenKind) + ' but got ' + parent.getChild(index + 1));
		}

		if (!hasNext())
		// NoSuchElementException
		{

			throw new Error();
		}

		index++;

		return parent.getChild(index);
	}

	/**
	 * After a call to remove, another call to next() is required to access
	 * the element following the one just deleted.
	 */
	public function remove():Void {
		parent.removeChildAt(index);
		index--;
	}

	public function replace(replacement:IParserNode):Void {
		parent.setChildAt(replacement, index);
	}

	public function moveTo(index:Int):IParserNode {
		while (hasNext()) {
			var ast:IParserNode = next();
			if (this.index == index) {
				return ast;
			}
		}
		return null;
	}

	public function search(tokenKind:String):IParserNode {
		while (hasNext()) {
			var ast:IParserNode = next();
			if (ast.isKind(tokenKind)) {
				return ast;
			}
		}
		return null;
	}

	public function find(tokenKind:String):IParserNode {
		var result:IParserNode = search(tokenKind);
		if (result != null) {
			return result;
		}
		// IllegalStateException
		throw new Error('expected ' + ASTUtil.tokenName(tokenKind) + ' but not found');
	}

	public function insertBeforeCurrent(insert:IParserNode):Void {
		parent.addChildAt(insert, index);
	}

	public function insertAfterCurrent(insert:IParserNode):Void {
		parent.addChildAt(insert, index + 1);
	}

	private function get_currentIndex():Int {
		return index;
	}

	public function reset(parent:IParserNode = null):Void {
		if (parent != null) {
			this.parent = parent;
		}
		index = -1;
	}

}