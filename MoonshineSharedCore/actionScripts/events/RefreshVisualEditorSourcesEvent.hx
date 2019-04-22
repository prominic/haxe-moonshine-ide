package actionScripts.events;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.FileWrapper;
import flash.events.Event;

class RefreshVisualEditorSourcesEvent extends Event {

	public static inline var REFRESH_VISUALEDITOR_SRC:String = 'refreshVisualEditorSrc';

	private var _fileWrapper:FileWrapper;
	private var _project:AS3ProjectVO;

	public function new(type:String, fileWrapper:FileWrapper, project:AS3ProjectVO) {
		super(type, false, false);

		_fileWrapper = fileWrapper;
		_project = project;
	}

	public var fileWrapper(get, never):FileWrapper;
	private function get_fileWrapper():FileWrapper {
		return _fileWrapper;
	}

	public var project(get, never):AS3ProjectVO;
	private function get_project():AS3ProjectVO {
		return _project;
	}

	override public function clone():Event {
		return new RefreshVisualEditorSourcesEvent(this.type, this.fileWrapper, this.project);
	}

}