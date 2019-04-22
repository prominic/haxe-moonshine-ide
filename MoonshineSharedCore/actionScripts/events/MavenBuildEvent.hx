package actionScripts.events;

import flash.events.Event;

class MavenBuildEvent extends Event {

	public static inline var START_MAVEN_BUILD:String = 'startMavenBuild';
	public static inline var STOP_MAVEN_BUILD:String = 'stopMavenBuild';

	public static inline var MAVEN_BUILD_FAILED:String = 'mavenBuildFailed';
	public static inline var MAVEN_BUILD_COMPLETE:String = 'mavenBuildComplete';
	public static inline var MAVEN_BUILD_TERMINATED:String = 'mavenBuildTerminated';

	private var _buildId:String;
	private var _buildDirectory:String;
	private var _preCommands:Array<Dynamic>;
	private var _commands:Array<Dynamic>;

	private var _status:Int = 0;

	public function new(type:String, buildId:String, status:Int, buildDirectory:String = null, preCommands:Array<Dynamic> = null, commands:Array<Dynamic> = null) {
		super(type, false, false);

		_buildId = buildId;
		_buildDirectory = buildDirectory;
		_preCommands = (preCommands != null) ? preCommands : [];
		_commands = (commands != null) ? commands : [];
	}

	public var buildId(get, never):String;
	private function get_buildId():String {
		return _buildId;
	}

	public var buildDirectory(get, never):String;
	private function get_buildDirectory():String {
		return _buildDirectory;
	}

	public var preCommands(get, never):Array<Dynamic>;
	private function get_preCommands():Array<Dynamic> {
		return _preCommands;
	}

	public var commands(get, never):Array<Dynamic>;
	private function get_commands():Array<Dynamic> {
		return _commands;
	}

	public var status(get, never):Int;
	private function get_status():Int {
		return _status;
	}

}