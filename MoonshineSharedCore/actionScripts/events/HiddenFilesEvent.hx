package actionScripts.events;

import actionScripts.valueObjects.FileWrapper;
import flash.events.Event;

class HiddenFilesEvent extends Event {

	public static inline var MARK_FILES_AS_VISIBLE:String = 'markFilesAsVisible';
	public static inline var MARK_FILES_AS_HIDDEN:String = 'markFilesAsHidden';

	private var _fileWrapper:FileWrapper;

	public function new(type:String, fileWrapper:FileWrapper) {
		super(type);

		_fileWrapper = fileWrapper;
	}

	public var fileWrapper(get, never):FileWrapper;
	private function get_fileWrapper():FileWrapper {
		return _fileWrapper;
	}

}