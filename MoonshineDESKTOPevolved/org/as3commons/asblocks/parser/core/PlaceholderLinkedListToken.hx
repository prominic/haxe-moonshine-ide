package org.as3commons.asblocks.parser.core;

import org.as3commons.asblocks.parser.api.IParserNode;

class PlaceholderLinkedListToken extends LinkedListToken {

	//----------------------------------
	//  held
	//----------------------------------

	/**
	 * @private
	 */
	private var _held:IParserNode;

	/**
	 * doc
	 */
	public var held(get, never):IParserNode;
	private function get_held():IParserNode {
		return _held;
	}

	public function new(node:IParserNode) {
		super('virtual-placeholder', '');

		//channel = channel-placeholder

		_held = node;
		_held.startToken = this;
		_held.stopToken = this;
	}

}