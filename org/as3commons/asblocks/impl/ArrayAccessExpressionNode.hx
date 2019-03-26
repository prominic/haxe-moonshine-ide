package org.as3commons.asblocks.impl;

import org.as3commons.asblocks.api.IArrayAccessExpression;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IArrayAccessExpression</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ArrayAccessExpressionNode extends ExpressionNode implements IArrayAccessExpression {

	public var target(get, set):IExpression;
	public var subscript(get, set):IExpression;

	//--------------------------------------------------------------------------
	//
	//  IArrayAccessExpression API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  target
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IArrayAccessExpression#target
	 */
	private function get_target():IExpression {
		return ExpressionBuilder.build(node.getFirstChild());
	}

	/**
	 * @private
	 */
	private function set_target(value:IExpression):IExpression {
		node.setChildAt(value.node, 0);
		return value;
	}

	//----------------------------------
	//  subscript
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IArrayAccessExpression#subscript
	 */
	private function get_subscript():IExpression {
		return ExpressionBuilder.build(node.getLastChild());
	}

	/**
	 * @private
	 */
	private function set_subscript(value:IExpression):IExpression {
		node.setChildAt(value.node, 1);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(node:IParserNode) {
		super(node);
	}

}