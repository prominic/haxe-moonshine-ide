package org.as3commons.asblocks.visitor;

import org.as3commons.asblocks.api.IScriptNode;

class BeforeAfterStrategy extends FilterStrategy {

	//----------------------------------
	//  before
	//----------------------------------

	/**
	 * @private
	 */
	private var _before:IScriptNodeStrategy;

	/**
	 * doc
	 */
	public var before(get, set):IScriptNodeStrategy;
	private function get_before():IScriptNodeStrategy {
		return _before;
	}

	/**
	 * @private
	 */
	private function set_before(value:IScriptNodeStrategy):IScriptNodeStrategy {
		_before = value;
		return value;
	}

	//----------------------------------
	//  after
	//----------------------------------

	/**
	 * @private
	 */
	private var _after:IScriptNodeStrategy;

	/**
	 * doc
	 */
	public var after(get, set):IScriptNodeStrategy;
	private function get_after():IScriptNodeStrategy {
		return _after;
	}

	/**
	 * @private
	 */
	private function set_after(value:IScriptNodeStrategy):IScriptNodeStrategy {
		_after = value;
		return value;
	}

	public function new(filtered:FilterStrategy,
			before:IScriptNodeStrategy = null,
			after:IScriptNodeStrategy = null) {
		super(filtered);
		this.before = before;
		this.after = after;
	}

	override public function handle(element:IScriptNode):Void {
		handleBefore(element);
		super.handle(element);
		handleAfter(element);
	}

	private function handleBefore(element:IScriptNode):Void {
		if (before != null) {
			before.handle(element);
		}
	}

	private function handleAfter(element:IScriptNode):Void {
		if (after != null) {
			after.handle(element);
		}
	}

}