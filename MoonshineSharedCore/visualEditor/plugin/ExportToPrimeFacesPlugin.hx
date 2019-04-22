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

import flash.display.DisplayObject;
import flash.events.Event;
import actionScripts.events.AddTabEvent;
import actionScripts.events.ExportVisualEditorProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.plugin.settings.vo.StaticLabelSetting;
import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.valueObjects.ConstantsCoreVO;

class ExportToPrimeFacesPlugin extends PluginBase {

	private var exportView:SettingsView;

	private var newProjectNameSetting:StringSetting;
	private var newProjectPathSetting:PathSetting;
	private var projectWithExistingsSourceSetting:BooleanSetting;

	private var _currentProject:AS3ProjectVO;
	private var _exportedProject:AS3ProjectVO;

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Export Visual Editor Project to PrimeFaces Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Exports Visual Editor project to PrimeFaces.';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
				exportVisualEditorProjectToPrimeFacesHandler
		);
		dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
				exportVisualEditorProjectToPrimeFacesHandler
		);
		dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
	}

	private function exportVisualEditorProjectToPrimeFacesHandler(event:Event):Void {
		_currentProject = AS3.as(model.activeProject, AS3ProjectVO);
		if (_currentProject == null || !_currentProject.isPrimeFacesVisualEditorProject) {
			error('This is not Visual Editor PrimeFaces project');
			return;
		}

		_exportedProject = AS3.as(_currentProject.clone(), AS3ProjectVO);
		_exportedProject.projectName = _exportedProject.projectName + '_exported';

		exportView = new SettingsView();
		exportView.exportProject = _exportedProject;
		exportView.Width = 150;
		exportView.defaultSaveLabel = 'Export';
		exportView.isNewProjectSettings = true;

		exportView.addCategory('');

		var settings:SettingsWrapper = getProjectSettings(_exportedProject);
		exportView.addEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
		exportView.addEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
		exportView.addSetting(settings, '');

		exportView.label = 'New Project';
		exportView.associatedData = _exportedProject;

		if (newProjectPathSetting.stringValue != null) {
			newProjectPathSetting.setMessage(Std.string(_exportedProject.folderLocation.resolvePath(_exportedProject.projectName).fileBridge.nativePath));
		}

		dispatcher.dispatchEvent(new AddTabEvent(exportView));
	}

	private function exportTabClosedHandler(event:CloseTabEvent):Void {
		if (event.tab == exportView) {
			cleanUpExportView();
		}
	}

	private function getProjectSettings(project:AS3ProjectVO):SettingsWrapper {
		newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\\'",<.>/?');

		if (!_exportedProject.isExportedToExistingSource) {
			newProjectNameSetting.isEditable = true;
			project.visualEditorExportPath = getDefaultExportPath(project);
		} else {
			newProjectNameSetting.isEditable = false;
		}

		newProjectPathSetting = new PathSetting(project, 'visualEditorExportPath', 'Parent directory', true, null, false);
		projectWithExistingsSourceSetting = new BooleanSetting(project, 'isExportedToExistingSource', 'Project with existing source', true);

		newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
		newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
		projectWithExistingsSourceSetting.addEventListener(BooleanSetting.VALUE_UPDATED, onProjectWithExistingSourceValueUpdated);

		return new SettingsWrapper('Name & Location', [
				new StaticLabelSetting('New ' + project.projectName),
				newProjectNameSetting, projectWithExistingsSourceSetting, newProjectPathSetting
		]);
	}

	private function onProjectNameChanged(event:Event):Void {
		_exportedProject.projectName = newProjectNameSetting.stringValue;
		var newProjectLocation:FileLocation = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);
		if (canSaveProject(newProjectLocation)) {
			newProjectPathSetting.setMessage('(Project can not be created in an existing project directory)\n' + newProjectLocation.fileBridge.nativePath,
					AbstractSetting.MESSAGE_CRITICAL
			);
		} else {
			newProjectPathSetting.setMessage(Std.string(newProjectLocation.fileBridge.nativePath));
		}
	}

	private function onProjectPathChanged(event:Event):Void {
		_exportedProject.projectFolder = null;
		_exportedProject.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
		var separator:String = Std.string(_currentProject.sourceFolder.fileBridge.separator);

		if (_exportedProject.isExportedToExistingSource) {
			if (newProjectPathSetting.stringValue != null) {
				newProjectNameSetting.stringValue = _exportedProject.folderLocation.name;
				newProjectPathSetting.setMessage(newProjectPathSetting.stringValue);
			}
		} else {
			newProjectPathSetting.setMessage(newProjectPathSetting.stringValue + separator + newProjectNameSetting.stringValue);
		}
	}

	private function onProjectWithExistingSourceValueUpdated(event:Event):Void {
		if (_exportedProject.isExportedToExistingSource) {
			newProjectNameSetting.isEditable = false;
			newProjectNameSetting.stringValue = _exportedProject.folderLocation.name;

			if (newProjectPathSetting.stringValue != null) {
				newProjectPathSetting.setMessage(newProjectPathSetting.stringValue);
			}
		} else {
			var separator:String = Std.string(_currentProject.sourceFolder.fileBridge.separator);

			newProjectNameSetting.isEditable = true;
			newProjectNameSetting.stringValue = _currentProject.projectName + '_exported';

			if (newProjectPathSetting.stringValue != null) {
				newProjectPathSetting.setMessage(_exportedProject.projectFolder.nativePath + separator + newProjectNameSetting.stringValue);
			}
		}
	}

	private function onProjectCreateExecute(event:Event):Void {
		if (newProjectPathSetting.stringValue == null) {
			error('Select path for successfully export %s.', _currentProject.projectName);
			return;
		}

		var destination:FileLocation = _exportedProject.folderLocation;
		if (!_exportedProject.isExportedToExistingSource) {
			destination = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);
			_exportedProject.visualEditorExportPath = Std.string(destination.fileBridge.nativePath);
			destination.fileBridge.createDirectory();
		}

		copyPrimeFacesPom(destination);
		copyPrimeFacesWebFile(destination);
		copyPrimeFacesResources(destination);
		copySources(destination);

		_currentProject.isExportedToExistingSource = _exportedProject.isExportedToExistingSource;
		_currentProject.visualEditorExportPath = _exportedProject.visualEditorExportPath;
		_currentProject.saveSettings();

		success('PrimeFaces project ' + newProjectNameSetting.stringValue + ' has been successfully saved.');

		onProjectCreateClose(event);
	}

	private function copySources(destination:FileLocation):Void {
		var webappFolderExported:FileLocation = destination.resolvePath('src/main/webapp');

		var sources:FileLocation = _currentProject.sourceFolder;
		var sourcesToCopy:Array<Dynamic> = sources.fileBridge.getDirectoryListing();
		var mainApplicationFile:FileLocation = _currentProject.targets[0];
		var mainFolder:FileLocation = _currentProject.folderLocation.resolvePath('src/main');

		sourcesToCopy = as3hx.Compat.filter(sourcesToCopy, function(item:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
							return Reflect.field(item, 'nativePath').lastIndexOf('WEB-INF') == -1 && Reflect.field(item, 'nativePath') != mainFolder.fileBridge.nativePath;
						});

		for (item in sourcesToCopy) {
			if (Reflect.field(item, 'nativePath') == mainApplicationFile.fileBridge.nativePath) {
				mainApplicationFile.fileBridge.copyTo(webappFolderExported.resolvePath('index.xhtml'), _exportedProject.isExportedToExistingSource);
			} else {
				item.copyTo(webappFolderExported.resolvePath(AS3.string(Reflect.field(item, 'name'))).fileBridge.getFile, _exportedProject.isExportedToExistingSource);
			}
		}
	}

	private function onProjectCreateClose(event:Event):Void {
		cleanUpExportView();
		dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(event.target, DisplayObject)));
	}

	private function canSaveProject(newProjectLocation:FileLocation):Bool {
		if (!AS3.as(newProjectLocation.fileBridge.exists, Bool)) {
			return false;
		}

		var listing:Array<Dynamic> = newProjectLocation.fileBridge.getDirectoryListing();
		for (file in listing) {
			if (Reflect.field(file, 'extension') == 'veditorproj') {
				return true;
			}
		}

		return false;
	}

	private function copyPrimeFacesPom(destination:FileLocation):Void {
		if (_exportedProject.isExportedToExistingSource) {
			return;
		}

		var currentFolder:FileLocation = _currentProject.folderLocation;
		var projectPom:FileLocation = currentFolder.fileBridge.resolvePath('pom.xml');

		var pomForCopy:FileLocation = destination.fileBridge.resolvePath('pom.xml');
		if (!AS3.as(pomForCopy.fileBridge.exists, Bool)) {
			projectPom.fileBridge.copyTo(pomForCopy, true);
			return;
		}

		FastXML.node.ignoreWhitespace = true;
		FastXML.node.ignoreComments = true;

		var pom:FastXML = FastXML.parse(projectPom.fileBridge.read());

		var qName:QName = new QName('http://maven.apache.org/POM/4.0.0', 'artifactId');
		pom.node.replace(qName, FastXML.parse('<artifactId>{_exportedProject.projectName}</artifactId>'));

		qName = new QName('http://maven.apache.org/POM/4.0.0', 'name');
		pom.node.replace(qName, FastXML.parse('<name>{_exportedProject.projectName}</name>'));

		pomForCopy.fileBridge.save(pom.node.toXMLString());
	}

	private function copyPrimeFacesWebFile(destination:FileLocation):Void {
		destination = destination.resolvePath('src/main/webapp/WEB-INF/web.xml');
		if (AS3.as(destination.fileBridge.exists, Bool) && _exportedProject.isExportedToExistingSource) {
			return;
		}

		var currentFolder:FileLocation = _currentProject.folderLocation;
		var webPath:String = 'src/main/webapp/WEB-INF/web.xml';
		var webForCopy:FileLocation = currentFolder.fileBridge.resolvePath(webPath);

		webForCopy.fileBridge.copyTo(destination);
	}

	private function copyPrimeFacesResources(destination:FileLocation):Void {
		var currentFolder:FileLocation = _currentProject.folderLocation;
		var webPath:String = 'src/main/resources';
		var webForCopy:FileLocation = currentFolder.fileBridge.resolvePath(webPath);
		var dest:FileLocation = destination.resolvePath('src/main/resources');

		if (_exportedProject.isExportedToExistingSource) {
			var grailsStylesheetDest:FileLocation = destination.resolvePath('grails-app/assets/stylesheets');
			if (AS3.as(grailsStylesheetDest.fileBridge.exists, Bool)) {
				webForCopy.fileBridge.copyInto(grailsStylesheetDest);
			} else {
				webForCopy.fileBridge.copyInto(dest);
			}
		} else {
			webForCopy.fileBridge.copyTo(dest);
		}
	}

	private function getDefaultExportPath(project:AS3ProjectVO):String {
		if (project.visualEditorExportPath != null) {
			return project.visualEditorExportPath;
		}

		var parentFolder:FileLocation = new FileLocation(project.folderPath).fileBridge.parent;
		return Std.string(parentFolder.fileBridge.nativePath);
	}

	private function cleanUpExportView():Void {
		exportView.removeEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
		exportView.removeEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
		if (newProjectPathSetting != null) {
			newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			projectWithExistingsSourceSetting.removeEventListener(BooleanSetting.VALUE_UPDATED, onProjectWithExistingSourceValueUpdated);
		}

		newProjectNameSetting = null;
		newProjectPathSetting = null;
		projectWithExistingsSourceSetting = null;

		_currentProject = null;
		_exportedProject = null;

		exportView = null;
	}

}