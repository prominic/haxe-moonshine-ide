package actionScripts.events;

import actionScripts.valueObjects.Location;
import flash.events.Event;

class ReferencesEvent extends Event {

	public static inline var EVENT_SHOW_REFERENCES:String = 'newShowReferences';

	public var references:Array<Location>;

	public function new(type:String, references:Array<Location>) {
		super(type, false, false);
		this.references = cast references;
	}

}