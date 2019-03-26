package actionScripts.plugins.help.view.events;

import flash.events.Event;
class VisualEditorEvent extends Event {

	public static inline var DUPLICATE_ELEMENT:String = 'duplicateElement';

	public function new(type:String) {
		super(type, false, false);
	}

	override public function clone():Event {
		return new VisualEditorEvent(type);
	}

}