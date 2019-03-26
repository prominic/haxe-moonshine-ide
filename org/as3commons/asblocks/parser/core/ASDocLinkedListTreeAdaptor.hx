package org.as3commons.asblocks.parser.core;

import org.as3commons.asblocks.parser.api.ASDocNodeKind;
class ASDocLinkedListTreeAdaptor extends LinkedListTreeAdaptor {

	public function new() {
		super();
	}

	override public function createNode(payload:LinkedListToken):TokenNode {
		var result:TokenNode = new TokenNode(
		payload.kind,
		payload.text,
		payload.line,
		payload.column);

		cast((result), TokenNode).token = payload;

		cast((result), TokenNode).tokenListUpdater = delegate;

		if (payload.kind == ASDocNodeKind.DESCRIPTION) {
			cast((result), TokenNode).tokenListUpdater =
					new ParentheticListUpdateDelegate(
					ASDocNodeKind.ML_START, ASDocNodeKind.ML_END);
		}

		if (Std.is(payload, LinkedListToken)) {
			result.startToken = cast((payload), LinkedListToken);
			result.stopToken = cast((payload), LinkedListToken);
		}

		return result;
	}

}