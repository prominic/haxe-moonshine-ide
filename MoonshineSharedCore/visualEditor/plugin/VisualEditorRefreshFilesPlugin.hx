////////////////////////////////////////////////////////////////////////////////
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package visualEditor.plugin;

import actionScripts.events.NewFileEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.RefreshVisualEditorSourcesEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;

class VisualEditorRefreshFilesPlugin extends PluginBase {

	private var VISUALEDITOR_SRC_FOLDERNAME(default, never):String = 'visualeditor-src';
	private var VISUALEDITOR_FILE_EXTENSION(default, never):String = 'xml';

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Refresh Visual Editor project files';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Translate and copy manually added Visual Editor XML project files to visualeditor-src folder';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(RefreshVisualEditorSourcesEvent.REFRESH_VISUALEDITOR_SRC, visualEditorRefreshSrcHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(RefreshVisualEditorSourcesEvent.REFRESH_VISUALEDITOR_SRC, visualEditorRefreshSrcHandler);
	}

	private function visualEditorRefreshSrcHandler(event:RefreshVisualEditorSourcesEvent):Void {
		var fileWrapper:FileWrapper = event.fileWrapper;
		var project:AS3ProjectVO = event.project;
		var destinationPath:String = fileWrapper.nativePath;

		var isValidSourcePath:Bool = isPathValidForRefresh(fileWrapper.nativePath, project);
		var visualEditorPathForRefresh:String = getFullVisualEditorPathForRefresh(fileWrapper, project);

		if (!isValidSourcePath || fileWrapper.nativePath == project.folderPath) {
			destinationPath = Std.string(project.sourceFolder.fileBridge.nativePath);
			fileWrapper = new FileWrapper(new FileLocation(destinationPath), fileWrapper.isRoot,
					fileWrapper.projectReference, fileWrapper.shallUpdateChildren);
			isValidSourcePath = false;
		}

		var newVisualEditorFiles:Array<Dynamic> = getNewVisualEditorSourceFiles(visualEditorPathForRefresh, destinationPath);

		var newFilesCreated:Bool = createNewVisualEditorFiles(newVisualEditorFiles, fileWrapper, project);
		if (newFilesCreated || isValidSourcePath) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(fileWrapper.nativePath)));
		}
	}

	private function createNewVisualEditorFiles(newVisualEditorFiles:Array<Dynamic>, originWrapper:FileWrapper, ofProject:AS3ProjectVO):Bool {
		var newFilesCreated:Bool = false;

		newVisualEditorFiles = validateNewVisualEditorFiles(newVisualEditorFiles);
		if (newVisualEditorFiles.length == 0) {
			return newFilesCreated;
		}

		for (file in newVisualEditorFiles) {
			var divTemplateFile:Dynamic = Reflect.getProperty(ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_PRIMEFACES, Std.string(0));
			var newFileEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_NEW_VISUAL_EDITOR_FILE,
			null,
			new FileLocation(AS3.string(Reflect.field(divTemplateFile, 'nativePath'))),
			originWrapper,
			{
				'relayEvent': false
			});
			newFileEvent.ofProject = ofProject;
			newFileEvent.fileName = getVisualEditorFileNameWithoutExtension(AS3.string(Reflect.field(file, 'name')));
			newFileEvent.isOpenAfterCreate = false;// important in this place

			dispatcher.dispatchEvent(newFileEvent);

			newFilesCreated = true;
		}

		return newFilesCreated;
	}

	private function validateNewVisualEditorFiles(newVisualEditorFiles:Array<Dynamic>):Array<Dynamic> {
		var validatedFiles:Array<Dynamic> = [];
		for (item in newVisualEditorFiles) {
			var visualEditorFile:FileLocation = Reflect.field(item, 'file');
			var visualEditorXML:FastXML = new FastXML(visualEditorFile.fileBridge.read());

			var rootDiv:FastXMLList = visualEditorXML.node.RootDiv;

			if (rootDiv.length() > 0) {
				visualEditorXML.node.RootDiv.setAttribute("save", true);
				visualEditorFile.fileBridge.save(visualEditorXML.node.toXMLString());

				validatedFiles.push(Reflect.field(item, 'file'));
			}
		}

		return validatedFiles;
	}

	private function getFullVisualEditorPathForRefresh(fileWrapper:FileWrapper, project:AS3ProjectVO):String {
		var isValidSourcePath:Bool = isPathValidForRefresh(fileWrapper.nativePath, project);
		var pathForRefresh:String = fileWrapper.nativePath;
		if (!isValidSourcePath) {
			pathForRefresh = Std.string(project.sourceFolder.fileBridge.nativePath);
		}

		var separator:String = Std.string(project.sourceFolder.fileBridge.separator);
		if (pathForRefresh != project.folderPath) {
			pathForRefresh = separator + getExtractedPathForRefresh(separator, pathForRefresh);
		} else {
			pathForRefresh = separator + 'main' + separator + 'webapp';
		}

		return Std.string(project.folderPath.concat(separator, VISUALEDITOR_SRC_FOLDERNAME, pathForRefresh));
	}

	private function getNewVisualEditorSourceFiles(visualEditorPathForRefresh:String, destinationPath:String):Array<Dynamic> {
		var pathForRefreshLocation:FileLocation = new FileLocation(visualEditorPathForRefresh);
		var separator:String = Std.string(pathForRefreshLocation.fileBridge.separator);

		var dirs:Array<Dynamic> = pathForRefreshLocation.fileBridge.getDirectoryListing();
		var newFiles:Array<Dynamic> = [];

		for (file in dirs) {
			if (!AS3.as(Reflect.field(file, 'isDirectory'), Bool) && Reflect.field(file, 'extension') == VISUALEDITOR_FILE_EXTENSION) {
				var destinationFilePath:String = destinationPath + separator + getVisualEditorFileNameWithoutExtension(AS3.string(Reflect.field(file, 'name'))) + '.xhtml';
				var destinationFileLocation:FileLocation = new FileLocation(destinationFilePath);
				if (!AS3.as(destinationFileLocation.fileBridge.exists, Bool)) {
					newFiles.push({
								'file': new FileLocation(AS3.string(Reflect.field(file, 'nativePath'))),
								'newFile': destinationFileLocation
							});
				}
			}
		}

		return newFiles;
	}

	private function getExtractedPathForRefresh(separator:String, fullPath:String):String {
		var src:String = separator + 'src' + separator;
		var srcIndex:Int = fullPath.indexOf(src) + src.length;

		return fullPath.substr(srcIndex);
	}

	private function isPathValidForRefresh(pathForRefresh:String, project:AS3ProjectVO):Bool {
		return pathForRefresh.indexOf(Std.string(project.sourceFolder.fileBridge.nativePath)) != -1 ||
		pathForRefresh == project.folderPath;
	}

	private function getVisualEditorFileNameWithoutExtension(name:String):String {
		var indexOfFileExtension:Int = name.lastIndexOf(VISUALEDITOR_FILE_EXTENSION);
		return name.substr(0, indexOfFileExtension - 1);
	}

}