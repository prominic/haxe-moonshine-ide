package actionScripts.plugin.actionscript.as3project.files;

import actionScripts.events.HiddenFilesEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;

class HiddenFilesPlugin extends PluginBase implements IPlugin {

	override private function get_name():String {
		return 'Hidden Files';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Handle hide/show operations on folders in Project Tree';
	}

	public function new() {
		super();
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
		dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
		dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
	}

	private function hideFilesHandler(event:HiddenFilesEvent):Void {
		var fileWrapper:FileWrapper = event.fileWrapper;
		var project:AS3ProjectVO = AS3.as(UtilsCore.getProjectFromProjectFolder(fileWrapper), AS3ProjectVO);
		project.hiddenPaths.push(new FileLocation(fileWrapper.nativePath));
		project.saveSettings();

		dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
	}

	private function showFilesHandler(event:HiddenFilesEvent):Void {
		var fileWrapper:FileWrapper = event.fileWrapper;
		var project:AS3ProjectVO = AS3.as(UtilsCore.getProjectFromProjectFolder(fileWrapper), AS3ProjectVO);
		var fileIndex:Int = -1;
		if (AS3.as(project.hiddenPaths.some(function(item:FileLocation, index:Int, arr:Array<FileLocation>):Bool {
								if (item.fileBridge.nativePath == fileWrapper.nativePath) {
									fileIndex = index;
									return true;
								}
								return false;
							}), Bool)) {
			project.hiddenPaths.splice(fileIndex, 1)[0];
			project.saveSettings();

			dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
		}
	}

}