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
package actionScripts.plugin.templating;

import flash.errors.Error;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.TextUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;

class TemplatingHelper {

	// Replace values for templates {$ProjectName:"My New Project"}
	public var templatingData:Dynamic = {};
	public var isProjectFromExistingSource:Bool = false;

	public function fileTemplate(fromTemplate:FileLocation, toFile:FileLocation):Void {
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			toFile.fileBridge.createFile();
			fromTemplate.fileBridge.copyFileTemplate(toFile, templatingData);
		}
	}

	public function projectTemplate(fromDir:FileLocation, toDir:FileLocation):Void {
		copyFiles(fromDir, toDir);
	}

	private function copyFiles(fromDir:FileLocation, toDir:FileLocation):Void {
		var files:Array<Dynamic> = fromDir.fileBridge.getDirectoryListing();
		var newFile:FileLocation;
		var template:Bool;

		for (file in files) {
			file = new FileLocation(AS3.string(Reflect.field(file, 'nativePath')));
			if (AS3.as(FileLocation(file).fileBridge.isDirectory, Bool)) {
				var directorySourceName:String = Std.string(FileLocation(file).fileBridge.name);
				// do not copy stocked 'src' and 'visualeditor-src' folder if user choose to create a project with his/her existing source
				if (!isProjectFromExistingSource || (directorySourceName != 'src' && directorySourceName != 'visualeditor-src')) {
					if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
						newFile = toDir.resolvePath(templatedFileName(AS3.as(file, FileLocation)));
						newFile.fileBridge.createDirectory();
					}

					copyFiles(AS3.as(file, FileLocation), newFile);
				}
			} else {
				template = (FileLocation(file).fileBridge.name.indexOf('.template') > -1);

				if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
					newFile = toDir.resolvePath(templatedFileName(AS3.as(file, FileLocation)));
				}
				try {
					if (template) {
						Reflect.field(file, 'fileBridge').copyFileTemplate(newFile, templatingData);
					} else {
						copyFileContents(AS3.as(file, FileLocation), newFile);
					}
				} catch (e:Error) {}
			}
		}
	}

	private function templatedFileName(src:FileLocation):String {
		var name:String = Std.string(src.fileBridge.name);
		if (name.indexOf('$') > -1) {
			var m:Int;
			for (key in Reflect.fields(templatingData)) {
				m = name.indexOf(key);
				if (m > -1) {
					name = name.substr(0, m) + Reflect.field(templatingData, key) + name.substr(m + key.length);
				}
			}
		}

		if (name.indexOf('.template') > -1) {
			name = name.substr(0, name.indexOf('.template'));
		}

		return name;
	}

	private function copyFileContents(src:FileLocation, dst:FileLocation):Void {
		src.fileBridge.copyTo(dst);
	}

	public static function replace(content:String, data:Dynamic):String {
		for (key in Reflect.fields(data)) {
			var re:as3hx.Compat.Regex = new as3hx.Compat.Regex(TextUtil.escapeRegex(key), 'g');
			content = re.replace(content, Reflect.field(data, key));
		}

		return content;
	}

	public static function getTemplateLabel(template:FileLocation):String {
		var name:String = Std.string(template.fileBridge.name);

		name = stripTemplate(name);

		if (name.indexOf('.') > -1) {
			name = name.substr(0, name.indexOf('.'));
		}

		return name;
	}

	public static function getTemplateMenuType(file:String):Array<Dynamic> {
		switch (file) {
			case 'MXML File':
				return cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS];
			case 'AS3 Class', 'AS3 Interface':
				return cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS];
			case 'CSS File', 'XML File':
				return cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS];
			case 'File':
				return cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.VISUAL_EDITOR_FLEX, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES];
			case 'Visual Editor Flex File':
				return cast [ProjectMenuTypes.VISUAL_EDITOR_FLEX];
			case 'Visual Editor PrimeFaces File':
				return cast [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES];
			case 'Java File':
				return cast [ProjectMenuTypes.JAVA];
		}

		return [];
	}

	public static function stripTemplate(from:String):String {
		if (from.indexOf('.template') > -1) {
			from = from.substr(0, from.indexOf('.template'));
		}

		return from;
	}

	public static function getExtension(template:FileLocation):String {
		var name:String = stripTemplate(Std.string(template.fileBridge.name));

		if (name.lastIndexOf('.') > -1) {
			return name.substr(name.lastIndexOf('.') + 1);
		}

		return null;
	}

	public static function setFileAsDefaultApplication(fw:FileWrapper, parent:FileWrapper):Void {
		if (!AS3.as(fw.file.fileBridge.checkFileExistenceAndReport(), Bool)) {
			return;
		}

		var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		var project:AS3ProjectVO = AS3.as(UtilsCore.getProjectFromProjectFolder(fw), AS3ProjectVO);

		var nameOnlyPreviousSourceFileArray:Array<Dynamic> = project.targets[0].fileBridge.name.split('.');
		nameOnlyPreviousSourceFileArray.pop();
		var nameOnlyPreviousSourceFile:String = nameOnlyPreviousSourceFileArray.join('.');

		var nameOnlyRequestedSourceFileArray:Array<String> = fw.file.name.split('.');
		nameOnlyRequestedSourceFileArray.pop();
		var nameOnlyRequestedSourceFile:String = nameOnlyRequestedSourceFileArray.join('.');

		if (project.air) {
			var tmpAppDescData:String = Std.string(project.targets[0].fileBridge.parent.resolvePath(nameOnlyPreviousSourceFile + '-app.xml').fileBridge.read());
			tmpAppDescData = new as3hx.Compat.Regex('<id>(.*?)<\\/id>', '').replace(tmpAppDescData, '<id>' + nameOnlyRequestedSourceFile + '<\/id>');
			tmpAppDescData = new as3hx.Compat.Regex('<filename>(.*?)<\\/filename>', '').replace(tmpAppDescData, '<filename>' + nameOnlyRequestedSourceFile + '<\/filename>');
			tmpAppDescData = new as3hx.Compat.Regex('<name>(.*?)<\\/name>', '').replace(tmpAppDescData, '<name>' + nameOnlyRequestedSourceFile + '<\/name>');

			var newDescriptorFile:FileLocation = fw.file.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFileArray.join('.') + '-app.xml');
			if (!AS3.as(newDescriptorFile.fileBridge.exists, Bool)) {
				newDescriptorFile.fileBridge.save(tmpAppDescData);

				// refresh to project tree UI
				var tmpTreeEvent:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, Std.string(newDescriptorFile.fileBridge.nativePath), parent);
				tmpTreeEvent.extra = newDescriptorFile;
				dispatcher.dispatchEvent(tmpTreeEvent);
			} else {
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, parent));
			}
		} else {
			var htmlFile:FileLocation = project.folderLocation.resolvePath('bin-debug');
			if (AS3.as(htmlFile.fileBridge.exists, Bool)) {
				htmlFile = htmlFile.resolvePath(nameOnlyPreviousSourceFile + '.html');
				if (AS3.as(htmlFile.fileBridge.exists, Bool)) {
					var htmlData:String = Std.string(htmlFile.fileBridge.read());
					var searchExp:as3hx.Compat.Regex = new as3hx.Compat.Regex(TextUtil.escapeRegex(nameOnlyPreviousSourceFile), 'g');
					htmlData = searchExp.replace(htmlData, nameOnlyRequestedSourceFile);

					htmlFile.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFile + '.html').fileBridge.save(htmlData);

					// refresh bin-debug folder
					var binDebugWrapper:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(project.projectFolder, htmlFile.fileBridge.parent);
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, binDebugWrapper));
				}
			}
		}

		project.targets[0] = fw.file;
		project.swfOutput.path = project.swfOutput.path.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFile + '.swf');
		project.saveSettings();
	}

	public function new() {}

}