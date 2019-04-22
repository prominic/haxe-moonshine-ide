package actionScripts.events;

import flash.events.Event;
import actionScripts.valueObjects.CodeAction;

class CodeActionsEvent extends Event {

	public static inline var EVENT_SHOW_CODE_ACTIONS:String = 'newShowCodeActions';

	public var path:String;
	public var codeActions:Array<CodeAction>;

	public function new(type:String, path:String, codeActions:Array<CodeAction>) {
		super(type, false, false);
		this.path = path;
		this.codeActions = cast codeActions;
	}

}