package org.as3commons.asblocks.parser.api;

import org.as3commons.asblocks.parser.core.LinkedListToken;
interface ITokenListUpdateDelegate {

	function addedChild(parent:IParserNode,
			child:IParserNode):Void;

	function addedChildAt(parent:IParserNode,
			index:Int,
			child:IParserNode):Void;

	function appendToken(parent:IParserNode,
			append:LinkedListToken):Void;

	function addToken(parent:IParserNode,
			index:Int,
			append:LinkedListToken):Void;

	function deletedChild(parent:IParserNode,
			index:Int,
			child:IParserNode):Void;

	function replacedChild(tree:IParserNode,
			index:Int,
			child:IParserNode,
			oldChild:IParserNode):Void;

}