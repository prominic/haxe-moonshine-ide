package actionScripts.events;

import actionScripts.valueObjects.Diagnostic;
import flash.events.Event;

class DiagnosticsEvent extends Event {

	public static inline var EVENT_SHOW_DIAGNOSTICS:String = 'newShowDiagnostics';

	public var path:String;
	public var diagnostics:Array<Diagnostic>;

	public function new(type:String, path:String, diagnostics:Array<Diagnostic>) {
		super(type, false, false);
		this.path = path;
		this.diagnostics = cast diagnostics;
	}

}