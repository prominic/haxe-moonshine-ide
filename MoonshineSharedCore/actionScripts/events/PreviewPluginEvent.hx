package actionScripts.events;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import flash.events.Event;

class PreviewPluginEvent extends Event {

	public static inline var START_VISUALEDITOR_PREVIEW:String = 'startVisualEditorPreview';
	public static inline var STOP_VISUALEDITOR_PREVIEW:String = 'stopVisualEditorPreview';

	public static inline var PREVIEW_START_COMPLETE:String = 'previewStartComplete';
	public static inline var PREVIEW_STARTING:String = 'previewStarting';
	public static inline var PREVIEW_START_FAILED:String = 'previewStartFailed';
	public static inline var PREVIEW_STOPPED:String = 'previewStopped';

	public function new(type:String, fileWrapper:Dynamic = null, project:AS3ProjectVO = null) {
		super(type, false, false);

		_fileWrapper = fileWrapper;
		_project = project;
	}

	private var _fileWrapper:Dynamic;

	public var fileWrapper(get, never):Dynamic;
	private function get_fileWrapper():Dynamic {
		return _fileWrapper;
	}

	private var _project:AS3ProjectVO;

	public var project(get, never):AS3ProjectVO;
	private function get_project():AS3ProjectVO {
		return _project;
	}

}