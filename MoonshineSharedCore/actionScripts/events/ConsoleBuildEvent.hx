package actionScripts.events;

import actionScripts.factory.FileLocation;
import flash.events.Event;

class ConsoleBuildEvent extends Event {

	private var _arguments:Array<Dynamic>;
	private var _buildDirectory:FileLocation;

	public function new(type:String, arguments:Array<Dynamic> = null, buildDirectory:FileLocation = null) {
		super(type, false, false);

		_arguments = arguments;
		_buildDirectory = buildDirectory;
	}

	public var arguments(get, never):Array<Dynamic>;
	private function get_arguments():Array<Dynamic> {
		return _arguments;
	}

	public var buildDirectory(get, never):FileLocation;
	private function get_buildDirectory():FileLocation {
		return _buildDirectory;
	}

}