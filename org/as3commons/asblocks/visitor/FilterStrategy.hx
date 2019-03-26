package org.as3commons.asblocks.visitor;

import org.as3commons.asblocks.api.IScriptNode;
class FilterStrategy implements IScriptNodeStrategy {

	public var filtered(get, set):IScriptNodeStrategy;

	//----------------------------------
	//  filtered
	//----------------------------------

	/**
	 * @private
	 */
	private var _filtered:IScriptNodeStrategy;

	/**
	 * doc
	 */
	private function get_filtered():IScriptNodeStrategy {
		return _filtered;
	}

	/**
	 * @private
	 */
	private function set_filtered(value:IScriptNodeStrategy):IScriptNodeStrategy {
		_filtered = value;
		return value;
	}

	public function new(filtered:IScriptNodeStrategy = null) {
		this.filtered = filtered;
	}

	public function handle(element:IScriptNode):Void {}

}