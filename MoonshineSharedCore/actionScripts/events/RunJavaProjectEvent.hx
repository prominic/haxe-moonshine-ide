package actionScripts.events;

import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import flash.events.Event;

class RunJavaProjectEvent extends Event {

	public static inline var RUN_JAVA_PROJECT:String = 'runJavaProject';

	private var _project:JavaProjectVO;

	public function new(type:String, project:JavaProjectVO) {
		super(type, false, false);

		_project = project;
	}

	public var project(get, never):JavaProjectVO;
	private function get_project():JavaProjectVO {
		return _project;
	}

}