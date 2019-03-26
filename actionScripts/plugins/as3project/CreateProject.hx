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
package actionScripts.plugins.as3project;

import flash.errors.Error;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filesystem.File;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.NewProjectEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.settings.NewLibraryProjectSetting;
import actionScripts.plugin.actionscript.as3project.settings.NewProjectSourcePathListSetting;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.LibrarySettingsVO;
import actionScripts.plugin.project.ProjectTemplateType;
import actionScripts.plugin.project.ProjectType;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.DropDownListSetting;
import actionScripts.plugin.settings.vo.MultiOptionSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.plugin.settings.vo.StaticLabelSetting;
import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SharedObjectConst;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.TemplateVO;
class CreateProject {

	public var allProjectTemplates(get, never):ArrayCollection;
	public var isProjectFromExistingSource(get, set):Bool;
	public var projectTemplateType(get, set):String;
	public var libraryProjectTemplateType(get, set):String;
	public var customFlexSDK(get, set):String;

	public var activeType:Int = ProjectType.AS3PROJ_AS_AIR;

	private var newProjectWithExistingSourcePathSetting:NewProjectSourcePathListSetting;

	private var newLibrarySetting:NewLibraryProjectSetting;

	private var newProjectNameSetting:StringSetting;

	private var newProjectPathSetting:PathSetting;

	private var newProjectTypeSetting:MultiOptionSetting;

	private var cookie:SharedObject;

	private var templateLookup:Dynamic = {};

	private var project:AS3ProjectVO;

	private var model:IDEModel = IDEModel.getInstance();

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var isActionScriptProject:Bool;

	private var isMobileProject:Bool;

	private var isOpenProjectCall:Bool;

	private var isFeathersProject:Bool;

	private var isVisualEditorProject:Bool;

	private var isAway3DProject:Bool;

	private var isLibraryProject:Bool;

	private var isCustomTemplateProject:Bool;

	private var isFlexJSRoyalProject:Bool;

	private var isInvalidToSave:Bool;

	private var librarySettingObject:LibrarySettingsVO;

	private var _allProjectTemplates:ArrayCollection;

	private var _isProjectFromExistingSource:Bool;

	private var _projectTemplateType:String;

	private var _libraryProjectTemplateType:String;

	private var _customFlexSDK:String;

	private var _currentCauseToBeInvalid:String;

	public function new(event:NewProjectEvent) {
		if (allProjectTemplates == null) {
			_allProjectTemplates = new ArrayCollection();
			_allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS);
			_allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS);
		}

		// determine if a given project is custom or Moonshine default
		var customTemplateDirectory:FileLocation = model.fileCore.resolveApplicationStorageDirectoryPath('templates/projects');
		if (event.templateDir.fileBridge.nativePath.indexOf(customTemplateDirectory.fileBridge.nativePath) != -1) {
			isCustomTemplateProject = true;
		}

		if (isCustomTemplateProject) {
			createCustomOrAway3DProject(event);
		} else if (isAllowedTemplateFile(event.projectFileEnding)) {
			createAS3Project(event);
		}
	}

	private function get_allProjectTemplates():ArrayCollection {
		if (!isOpenProjectCall) {
			return _allProjectTemplates;
		}

		var tmpCollection:ArrayCollection = new ArrayCollection();
		for (i /* AS3HX WARNING could not determine type for var: i exp: EIdent(_allProjectTemplates) type: ArrayCollection */ in _allProjectTemplates)
		// lets not include Library Project option in case of
		{

			// project with existing source for cutting complexities
			if (i.title != ProjectTemplateType.LIBRARY_PROJECT) {
				tmpCollection.addItem(i);
			}
		}

		return tmpCollection;
	}

	private function get_isProjectFromExistingSource():Bool {
		return _isProjectFromExistingSource;
	}

	private function set_isProjectFromExistingSource(value:Bool):Bool {
		_isProjectFromExistingSource = project.isProjectFromExistingSource = value;
		onProjectPathChanged(null, false);
		newProjectWithExistingSourcePathSetting.visible = _isProjectFromExistingSource;

		// lets scroll-up the project creation dialog
		// so user can see changed project path clearly - if
		// s/he is working in a shorter frame where project path
		// may cut-off in displaying frame
		dispatcher.dispatchEvent(
				new GeneralEvent(GeneralEvent.SCROLL_TO_TOP)
		);
		return value;
	}

	private function set_projectTemplateType(value:String):String {
		_projectTemplateType = value;
		return value;
	}

	private function get_projectTemplateType():String {
		return _projectTemplateType;
	}

	private function set_libraryProjectTemplateType(value:String):String {
		_libraryProjectTemplateType = value;
		return value;
	}

	private function get_libraryProjectTemplateType():String {
		return _libraryProjectTemplateType;
	}

	private function get_customFlexSDK():String {
		return _customFlexSDK;
	}

	private function set_customFlexSDK(value:String):String {
		_customFlexSDK = value;
		return value;
	}

	private function createAS3Project(event:NewProjectEvent):Void
	// Only template for those we can handle
	 {

		if (!isAllowedTemplateFile(event.projectFileEnding)) {
			return;
		}

		var lastSelectedProjectPath:String;

		setProjectType(event.templateDir.fileBridge.name);

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			if (OSXBookmarkerNotifiers.availableBookmarkedPaths == '') {
				OSXBookmarkerNotifiers.removeFlashCookies();
			}
		}

		cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		//Read recent project path from shared object

		// if opened by Open project, event.settingsFile will be false
		// and event.templateDir will be open folder location
		isOpenProjectCall = !event.settingsFile;

		if (isOpenProjectCall) {
			project = new AS3ProjectVO(event.templateDir, null, false);
		} else {
			project = FlashDevelopImporter.parse(event.settingsFile, null, null, false);
		}

		project.isVisualEditorProject = isVisualEditorProject;
		project.isLibraryProject = isLibraryProject;

		if (cookie.data.exists('recentProjectPath')) {
			model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
			if (cookie.data.exists('lastSelectedProjectPath')) {
				lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
			}
		} else if (!isOpenProjectCall) {
			project.folderLocation = new FileLocation(File.documentsDirectory.nativePath);
			if (!model.recentSaveProjectPath.contains(project.folderLocation.fileBridge.nativePath)) {
				model.recentSaveProjectPath.addItem(project.folderLocation.fileBridge.nativePath);
			}
		}

		isFlexJSRoyalProject = event.templateDir.fileBridge.name.indexOf('Royale') != -1 || event.templateDir.fileBridge.name.indexOf('FlexJS') != -1;
		// remove any ( or ) stuff
		if (!isOpenProjectCall) {
			var tempName:String = ((event.templateDir.fileBridge.name.indexOf('(') != -1)) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf('(')) : event.templateDir.fileBridge.name;
			if (isFlexJSRoyalProject) {
				project.projectName = 'NewJavaScriptBrowserProject';
			} else {
				project.projectName = (event.exportProject) ? event.exportProject.name + '_exported' : 'New' + tempName;
			}
		}

		if (isOpenProjectCall) {
			if (!model.recentSaveProjectPath.contains(event.templateDir.fileBridge.nativePath)) {
				model.recentSaveProjectPath.addItem(event.templateDir.fileBridge.nativePath);
			}
			project.projectName = 'ExternalProject';
			project.isProjectFromExistingSource = true;
		} else {
			var tmpProjectSourcePath:String = ((lastSelectedProjectPath != null && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1)) ? lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
			project.folderLocation = new FileLocation(tmpProjectSourcePath);
		}

		var settingsView:SettingsView = new SettingsView();
		settingsView.exportProject = event.exportProject;
		settingsView.Width = 150;
		settingsView.defaultSaveLabel = (event.isExport) ? 'Export' : 'Create';
		settingsView.isNewProjectSettings = true;

		settingsView.addCategory('');
		// Remove spaces from project name
		project.projectName = project.projectName.replace(new as3hx.Compat.Regex(' ', 'g'), '');

		var nvps:Array<NameValuePair> = [
				new NameValuePair('AIR', ProjectType.AS3PROJ_AS_AIR),
				new NameValuePair('Web', ProjectType.AS3PROJ_AS_WEB),
				new NameValuePair('Visual Editor', ProjectType.VISUAL_EDITOR)
		];

		var settings:SettingsWrapper = getProjectSettings(project, event);

		if (newProjectWithExistingSourcePathSetting != null) {
			if (isOpenProjectCall) {
				isProjectFromExistingSource = project.isProjectFromExistingSource;
			}
			newProjectWithExistingSourcePathSetting.visible = project.isProjectFromExistingSource;
		}

		if (isActionScriptProject) {
			isActionScriptProject = true;
			newProjectTypeSetting = new MultiOptionSetting(this, 'activeType', 'Select project type', nvps);
			settings.getSettingsList().splice(4, 0, newProjectTypeSetting);
		}

		if (isOpenProjectCall) {
			settings.getSettingsList().splice(3, 0, new DropDownListSetting(this, 'projectTemplateType', 'Select Template Type', allProjectTemplates, 'title'));
		} else if (isFlexJSRoyalProject) {
			settings.getSettingsList().splice(3, 0,
					new DropDownListSetting(this, 'projectTemplateType', 'Select Template Type', ConstantsCoreVO.TEMPLATES_PROJECTS_ROYALE, 'title')
			);
		} else if (isLibraryProject) {
			newLibrarySetting = new NewLibraryProjectSetting(this, 'librarySettingObject');
			settings.getSettingsList().splice(3, 0, newLibrarySetting);
		}

		settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
		settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
		settingsView.addSetting(settings, '');

		settingsView.label = 'New Project';
		settingsView.associatedData = project;

		dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
		);

		Reflect.setField(templateLookup, Std.string(project), event.templateDir);
	}

	private function createCustomOrAway3DProject(event:NewProjectEvent):Void {
		var lastSelectedProjectPath:String;
		var tempName:String = ((event.templateDir.fileBridge.name.indexOf('(') != -1)) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf('(')) : event.templateDir.fileBridge.name;
		tempName = new as3hx.Compat.Regex(' ', 'g').replace(tempName, '');

		project = new AS3ProjectVO(model.fileCore.resolveDocumentDirectoryPath(), tempName, false);
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			if (OSXBookmarkerNotifiers.availableBookmarkedPaths == '') {
				OSXBookmarkerNotifiers.removeFlashCookies();
			}
		}

		cookie = SharedObject.getLocal('moonshine-ide-local');

		if (cookie.data.exists('recentProjectPath')) {
			model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
			if (cookie.data.exists('lastSelectedProjectPath')) {
				lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
			}
		} else if (!model.recentSaveProjectPath.contains(project.folderLocation.fileBridge.nativePath)) {
			model.recentSaveProjectPath.addItem(project.folderLocation.fileBridge.nativePath);
		}

		var tmpProjectSourcePath:String = ((lastSelectedProjectPath != null && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1)) ? lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
		project.folderLocation = new FileLocation(tmpProjectSourcePath);

		var settingsView:SettingsView = new SettingsView();
		settingsView.Width = 150;
		settingsView.defaultSaveLabel = 'Create';
		settingsView.isNewProjectSettings = true;

		settingsView.addCategory('');

		var settings:SettingsWrapper = getProjectSettings(project, event);

		settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
		settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
		settingsView.addSetting(settings, '');

		settingsView.label = 'New Project';
		settingsView.associatedData = project;

		dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
		);

		Reflect.setField(templateLookup, Std.string(project), event.templateDir);
	}

	private function isAllowedTemplateFile(projectFileExtension:String):Bool {
		return projectFileExtension != 'as3proj' || projectFileExtension != 'veditorproj' || !projectFileExtension;
	}

	private function getProjectSettings(project:AS3ProjectVO, eventObject:NewProjectEvent):SettingsWrapper {
		newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\\",<.>/?');
		newProjectPathSetting = new PathSetting(project, 'folderPath', 'Parent directory', true, null, false, true);
		newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
		newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);

		if (eventObject.isExport)
		//newProjectNameSetting.isEditable = false;
		{

			return new SettingsWrapper('Name & Location', [
					new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
					newProjectNameSetting,  // No space input either plx
					newProjectPathSetting
			]);
		}

		if (isCustomTemplateProject) {
			return new SettingsWrapper('Name & Location', [
					new StaticLabelSetting((isCustomTemplateProject) ? 'New ' + eventObject.templateDir.fileBridge.name : 'New Away3D Project'),
					newProjectNameSetting,
					newProjectPathSetting
			]);
		}

		newProjectWithExistingSourcePathSetting = new NewProjectSourcePathListSetting(project,
				'projectWithExistingSourcePaths', 'Main source folder');

		if (project.isVisualEditorProject && !eventObject.isExport) {
			return new SettingsWrapper('Name & Location', [
					new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
					newProjectNameSetting,  // No space input either plx
					newProjectPathSetting,
					new DropDownListSetting(this, 'projectTemplateType', 'Select Template Type', new ArrayCollection([ProjectTemplateType.VISUAL_EDITOR_FLEX, ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES]))
			]);
		}

		return new SettingsWrapper('Name & Location', [
				new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
				newProjectNameSetting,  // No space input either plx
				newProjectPathSetting,
				new PathSetting(this, 'customFlexSDK', 'Apache Flex®, Apache Royale® or Feathers SDK', true, customFlexSDK, true),
				new BooleanSetting(this, 'isProjectFromExistingSource', 'Project with existing source', true),
				newProjectWithExistingSourcePathSetting
		]);
	}

	private function checkIfProjectDirectory(value:FileLocation):Void {
		var tmpFile:FileLocation = FlashDevelopImporter.test(try cast(value.fileBridge.getFile, File) catch (e:Dynamic) null);
		if (tmpFile == null) {
			tmpFile = FlashBuilderImporter.test(try cast(value.fileBridge.getFile, File) catch (e:Dynamic) null);
		}
		if (tmpFile == null && !isProjectFromExistingSource && value.fileBridge.exists) {
			tmpFile = value;
		}

		if (tmpFile != null) {
			newProjectPathSetting.setMessage(_currentCauseToBeInvalid = 'Project can not be created to an existing project directory:\n' + value.fileBridge.nativePath, AbstractSetting.MESSAGE_CRITICAL);
		} else if (isProjectFromExistingSource) {
			newProjectPathSetting.setMessage('(Note) Project with existing source directory is:\n' + value.fileBridge.nativePath, AbstractSetting.MESSAGE_IMPORTANT);
		} else {
			newProjectPathSetting.setMessage(value.fileBridge.nativePath);
		}

		if (newProjectPathSetting.stringValue == '') {
			isInvalidToSave = true;
			_currentCauseToBeInvalid = 'Unable to access Project Directory:\n' + value.fileBridge.nativePath + '\nPlease try to create the project again and use the "Change" link to open the target directory again.';
		} else {
			isInvalidToSave = (tmpFile != null) ? true : false;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE LISTENERS
	//
	//--------------------------------------------------------------------------
	private function onProjectPathChanged(event:Event, makeNull:Bool = true):Void {
		if (makeNull) {
			project.projectFolder = null;
		}
		project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
		if (_isProjectFromExistingSource) {
			project.projectName = newProjectNameSetting.stringValue;
			newProjectWithExistingSourcePathSetting.project = project;
			newProjectPathSetting.label = 'Existing Project Directory';
			checkIfProjectDirectory(project.folderLocation);
		} else {
			newProjectPathSetting.label = 'Parent Directory';
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
	}

	private function onProjectNameChanged(event:Event):Void {
		if (!isProjectFromExistingSource) {
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
	}

	private function createClose(event:Event):Void {
		var settings:SettingsView = try cast(event.target, SettingsView) catch (e:Dynamic) null;

		settings.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
		settings.removeEventListener(SettingsView.EVENT_SAVE, createSave);
		if (newProjectPathSetting != null) {
			newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
		}

		Reflect.deleteField(templateLookup, settings.associatedData);

		dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, try cast(event.target, DisplayObject) catch (e:Dynamic) null)
		);
	}

	private function throwError():Void {
		Alert.show(_currentCauseToBeInvalid + ' Project creation terminated.', 'Error!');
	}

	private function createSave(event:Event):Void {
		if (isInvalidToSave) {
			throwError();
			return;
		}

		var view:SettingsView = try cast(event.target, SettingsView) catch (e:Dynamic) null;
		var project:AS3ProjectVO = try cast(view.associatedData, AS3ProjectVO) catch (e:Dynamic) null;
		//var targetFolder:FileLocation = project.folderLocation = _isProjectFromExistingSource ? project.folderLocation.resolvePath(project.name) : project.folderLocation;
		var targetFolder:FileLocation = project.folderLocation;

		//save  project path in shared object
		cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		var tmpParent:FileLocation;
		if (_isProjectFromExistingSource)
		// validate if all requirement supplied
		{

			if (newProjectWithExistingSourcePathSetting.stringValue == '') {
				event.target.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
				var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
							event.target.addEventListener(SettingsView.EVENT_CLOSE, createClose);
							as3hx.Compat.clearTimeout(timeoutValue);
						}, 500);

				Alert.show((isLibraryProject) ? 'Please provide the source folder location to proceed.' : 'Please provide the source folder and application file location to proceed.', 'Error!');
				return;
			}

			var tmpIndex:Int = model.recentSaveProjectPath.getItemIndex(project.folderLocation.fileBridge.nativePath);
			if (tmpIndex != -1) {
				model.recentSaveProjectPath.removeItemAt(tmpIndex);
			}
			tmpParent = project.folderLocation.fileBridge.parent;
		} else {
			tmpParent = project.folderLocation;
		}

		if (!model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath)) {
			model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
		}

		// don't save this if from a open project call
		if (!isOpenProjectCall && !_isProjectFromExistingSource) {
			cookie.data['lastSelectedProjectPath'] = project.folderLocation.fileBridge.nativePath;
			cookie.data['recentProjectPath'] = model.recentSaveProjectPath.source;
			cookie.flush();
		}

		project = createFileSystemBeforeSave(project, try cast(view.exportProject, AS3ProjectVO) catch (e:Dynamic) null);
		if (project == null) {
			return;
		}

		if (view.exportProject) {
			exportVisualEditorProject(project, try cast(view.exportProject, AS3ProjectVO) catch (e:Dynamic) null);
		}

		if (!_isProjectFromExistingSource) {
			targetFolder = targetFolder.resolvePath(project.projectName);
		}

		// Close settings view
		createClose(event);

		// Open main file for editing
		dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
		);

		if (!isCustomTemplateProject && !isLibraryProject) {
			dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [project.targets[0]], -1, [project.projectFolder])
			);
		}

		if (view.exportProject) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
		}
	}

	private function exportVisualEditorProject(project:AS3ProjectVO, exportProject:AS3ProjectVO):Void {
		var mainExportedFile:FileLocation = exportProject.targets[0];
		var mainProjectFile:FileLocation = project.targets[0];

		mainExportedFile.fileBridge.copyTo(mainProjectFile, true);

		var filesForExport:Array<Dynamic> = exportProject.sourceFolder.fileBridge.getDirectoryListing();
		var filesForExportCount:Int = filesForExport.length;
		for (i in 0...filesForExportCount) {
			var fileForCopy:File = filesForExport[i];
			if (fileForCopy.name == mainExportedFile.fileBridge.name) {
				continue;
			}

			var destinationPath:String = UtilsCore.fixSlashes(project.sourceFolder.fileBridge.getFile.nativePath + '\\' + fileForCopy.name);
			var destination:File = new File(destinationPath);
			fileForCopy.copyTo(destination, true);
		}
	}

	private function createFileSystemBeforeSave(pvo:AS3ProjectVO, exportProject:AS3ProjectVO = null):AS3ProjectVO
	// in case of create new project through Open Project option
	 {

		// we'll need to get the template project directory by it's name
		pvo = getProjectWithTemplate(pvo, exportProject);

		var templateDir:FileLocation = Reflect.field(templateLookup, Std.string(pvo));
		var projectName:String = pvo.projectName;
		var sourceFile:String = ((_isProjectFromExistingSource && !isLibraryProject)) ? pvo.projectWithExistingSourcePaths[1].fileBridge.name.split('.')[0] : pvo.projectName;
		var sourceFileWithExtension:String;
		var sourcePath:String = (_isProjectFromExistingSource) ?
		pvo.folderLocation.fileBridge.getRelativePath(pvo.projectWithExistingSourcePaths[0]) :
		'src';
		if (!_isProjectFromExistingSource && isVisualEditorProject && projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES) {
			sourcePath = 'src/main/webapp';
		}

		var targetFolder:FileLocation = pvo.folderLocation;

		if (_isProjectFromExistingSource && !isLibraryProject) {
			sourceFileWithExtension = pvo.projectWithExistingSourcePaths[1].fileBridge.name;
		} else if (isActionScriptProject || isFeathersProject || isAway3DProject) {
			sourceFileWithExtension = pvo.projectName + '.as';
		} else if (isLibraryProject)
		// we creates library project without any default created file inside
		{

			sourceFileWithExtension = null;
		} else if (isVisualEditorProject && projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES) {
			sourceFileWithExtension = pvo.projectName + '.xhtml';
		} else {
			sourceFileWithExtension = pvo.projectName + '.mxml';
		}

		// lets load the target flash/air player version
		// since swf and air player both versioning same now,
		// we can load anyone's config file
		var movieVersion:String = Std.string(SDKUtils.getSdkSwfMajorVersion()) + '.0';

		// Create project root directory
		if (!_isProjectFromExistingSource)
		/* AS3HX WARNING namespace modifier CONFIG::OSX */
		{
			{
				if (!OSXBookmarkerNotifiers.isPathBookmarked(targetFolder.fileBridge.nativePath)) {
					_currentCauseToBeInvalid = 'Unable to access Parent Directory:\n' + targetFolder.fileBridge.nativePath + '\nPlease try to create the project again and use the "Change" link to open the target directory again.';
					throwError();
					return null;
				}
			}

			targetFolder = targetFolder.resolvePath(projectName);
			targetFolder.fileBridge.createDirectory();
		}

		// Time to do the templating thing!
		var th:TemplatingHelper = new TemplatingHelper();
		th.isProjectFromExistingSource = _isProjectFromExistingSource;
		th.templatingData['$ProjectName'] = projectName;

		var pattern:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('(_)', 'g'));
		th.templatingData['$ProjectID'] = pattern.replace(projectName, '');
		th.templatingData['$SourcePath'] = sourcePath;
		th.templatingData['$SourceFile'] = (sourceFileWithExtension != null) ? (sourcePath + File.separator + sourceFileWithExtension) : '';
		th.templatingData['$SourceNameOnly'] = sourceFile;
		th.templatingData['$ProjectSWF'] = sourceFile + '.swf';
		th.templatingData['$ProjectSWC'] = sourceFile + '.swc';
		th.templatingData['$ProjectFile'] = (sourceFileWithExtension != null) ? sourceFileWithExtension : '';
		th.templatingData['$DesktopDescriptor'] = sourceFile;
		th.templatingData['$Settings'] = projectName;
		th.templatingData['$Certificate'] = projectName + 'Certificate';
		th.templatingData['$Password'] = projectName + 'Certificate';
		th.templatingData['$FlexHome'] = (model.defaultSDK) ? model.defaultSDK.fileBridge.nativePath : '';
		th.templatingData['$MovieVersion'] = movieVersion;
		th.templatingData['$pom'] = 'pom';

		if (_customFlexSDK != null) {
			th.templatingData['${flexlib}'] = _customFlexSDK;
		} else {
			th.templatingData['${flexlib}'] = ((model.defaultSDK)) ? model.defaultSDK.fileBridge.nativePath : '${SDK_PATH}';
		}

		th.projectTemplate(templateDir, targetFolder);

		// we copy everything from template to target folder
		// in case of custom project template and terminate
		if (isCustomTemplateProject)
		// re-create the vo so all the requisite fields
		{

			// updated with final target folder path
			pvo = new AS3ProjectVO(targetFolder, pvo.name);
			pvo.classpaths[0] = targetFolder;
			return pvo;
		}

		// If this an ActionScript Project then we need to copy selective file/folders for web or desktop
		var descriptorFileLocation:FileLocation;
		var isAIR:Bool = templateDir.resolvePath('build_air').fileBridge.exists;
		if (isActionScriptProject || isAIR || isMobileProject) {
			if (activeType == ProjectType.AS3PROJ_AS_AIR)
			// build folder modification
			{

				th.projectTemplate(templateDir.resolvePath('build_air'), targetFolder.resolvePath('build'));
				if (isAway3DProject) {
					th.projectTemplate(templateDir.resolvePath('libs'), targetFolder.resolvePath('libs'));
				}
				descriptorFileLocation = targetFolder.resolvePath('build/' + sourceFile + '-app.xml');
				try {
					descriptorFileLocation.fileBridge.moveTo(targetFolder.resolvePath(sourcePath + File.separator + sourceFile + '-app.xml'), true);
				} catch (e:Error) {
					descriptorFileLocation.fileBridge.moveToAsync(targetFolder.resolvePath(sourcePath + File.separator + sourceFile + '-app.xml'), true);
				}
			} else {
				th.projectTemplate(templateDir.resolvePath('build_web'), targetFolder.resolvePath('build'));
				th.projectTemplate(templateDir.resolvePath('bin-debug_web'), targetFolder.resolvePath('bin-debug'));
				th.projectTemplate(templateDir.resolvePath('html-template_web'), targetFolder.resolvePath('html-template'));
			}

			// we also needs to delete unnecessary folders
			var folderToDelete1:FileLocation = targetFolder.resolvePath('build_air');
			var folderToDelete2:FileLocation = targetFolder.resolvePath('build_web');
			var folderToDelete3:FileLocation = targetFolder.resolvePath('bin-debug_web');
			var folderToDelete4:FileLocation = targetFolder.resolvePath('html-template_web');
			var folderToDelete5:FileLocation = targetFolder.resolvePath('build');

			folderToDelete1.fileBridge.deleteDirectory(true);
			if (isActionScriptProject) {
				folderToDelete2.fileBridge.deleteDirectory(true);
				folderToDelete3.fileBridge.deleteDirectory(true);
				folderToDelete4.fileBridge.deleteDirectory(true);
			}
			if (isAway3DProject) {
				folderToDelete5.fileBridge.deleteDirectory(true);
			}
		}
		if (isVisualEditorProject) {
			if (projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_FLEX) {
				th.projectTemplate(templateDir.resolvePath('src_flex'), targetFolder.resolvePath('src'));
			} else if (projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES) {
				th.projectTemplate(templateDir.resolvePath('src_primeface'), targetFolder.resolvePath('src'));
			}

			var folderToDelete6:FileLocation = targetFolder.resolvePath('src_primeface');
			var folderToDelete7:FileLocation = targetFolder.resolvePath('src_flex');

			folderToDelete6.fileBridge.deleteDirectory(true);
			folderToDelete7.fileBridge.deleteDirectory(true);
		}
		if (isLibraryProject)
		// get the configuration from the library settings component
		{

			librarySettingObject = newLibrarySetting.librarySettingObject;

			var folderToCreate:FileLocation = targetFolder.resolvePath('src');
			if (!folderToCreate.fileBridge.exists) {
				folderToCreate.fileBridge.createDirectory();
			}
			folderToCreate = targetFolder.resolvePath('bin-debug');
			if (!folderToCreate.fileBridge.exists) {
				folderToCreate.fileBridge.createDirectory();
			}
		}

		// creating certificate conditional checks
		if (descriptorFileLocation == null || !descriptorFileLocation.fileBridge.exists) {
			descriptorFileLocation = targetFolder.resolvePath('application.xml');
			if (!descriptorFileLocation.fileBridge.exists) {
				descriptorFileLocation = targetFolder.resolvePath(sourcePath + File.separator + sourceFile + '-app.xml');
			}
		}

		if (descriptorFileLocation.fileBridge.exists)
		// lets update $SWFVersion with SWF version now
		{

			var stringOutput:String = Std.string(descriptorFileLocation.fileBridge.read());
			var firstNamespaceQuote:Int = as3hx.Compat.parseInt(stringOutput.indexOf('"', stringOutput.indexOf('<application xmlns=')) + 1);
			var lastNamespaceQuote:Int = stringOutput.indexOf('"', firstNamespaceQuote);
			var currentAIRNamespaceVersion:String = stringOutput.substring(firstNamespaceQuote, lastNamespaceQuote);

			stringOutput = StringTools.replace(stringOutput, currentAIRNamespaceVersion, 'http://ns.adobe.com/air/application/' + movieVersion);
			descriptorFileLocation.fileBridge.save(stringOutput);
		}

		var projectSettingsFile:String = isVisualEditorProject && !(exportProject != null) ?
		projectName + '.veditorproj' :
		projectName + '.as3proj';

		// Figure out which one is the settings file
		var settingsFile:FileLocation = targetFolder.resolvePath(projectSettingsFile);
		var descriptorFile:File = ((isMobileProject || (isActionScriptProject && activeType == ProjectType.AS3PROJ_AS_AIR))) ?
		new File(project.folderLocation.fileBridge.nativePath + File.separator + sourcePath + File.separator + sourceFile + '-app.xml') :
		null;

		// Set some stuff to get the paths right
		pvo = FlashDevelopImporter.parse(settingsFile, projectName, descriptorFile);
		pvo.projectName = projectName;
		pvo.isLibraryProject = isLibraryProject;
		if (pvo.isLibraryProject) {
			pvo.air = librarySettingObject.includeAIR;
			pvo.isMobile = (librarySettingObject.type == LibrarySettingsVO.MOBILE_LIBRARY || librarySettingObject.output == LibrarySettingsVO.MOBILE);
			if (pvo.air) {
				pvo.buildOptions.additional = '+configname=air';
			}
			if (pvo.isMobile) {
				pvo.buildOptions.additional = '+configname=airmobile';
			}
			if (!pvo.air && !pvo.isMobile) {
				pvo.buildOptions.additional = '+configname=flex';
			}
		}

		if (isVisualEditorProject) {
			pvo.isPrimeFacesVisualEditorProject = projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES;
		}

		pvo.buildOptions.customSDKPath = _customFlexSDK;
		pvo.menuType = getProjectMenuType(pvo);
		_customFlexSDK = null;

		// in case of Flex project (where mx or spark controls can be included)
		// we need to populate the project's intrinsic libraries. this will also help
		// when next time project opens we can detect between pure AS and flex type of project
		if ((isLibraryProject && librarySettingObject.type != LibrarySettingsVO.ACTIONSCRIPT_LIBRARY) || (!isLibraryProject && !isActionScriptProject && !isFeathersProject)) {
			pvo.intrinsicLibraries.push('Library\\AS3\\frameworks\\Flex4');
			pvo.isActionScriptOnly = false;
		}

		// Write settings
		FlashDevelopExporter.export(pvo, settingsFile);

		return pvo;
	}

	private function getProjectWithTemplate(pvo:AS3ProjectVO, exportProject:AS3ProjectVO = null):AS3ProjectVO {
		if (projectTemplateType == null) {
			return pvo;
		}

		if (isOpenProjectCall || isFlexJSRoyalProject) {
			setProjectType(projectTemplateType);
			var projectsTemplates:ArrayCollection = (isFlexJSRoyalProject) ?
			ConstantsCoreVO.TEMPLATES_PROJECTS_ROYALE :
			allProjectTemplates;

			for (i /* AS3HX WARNING could not determine type for var: i exp: EIdent(projectsTemplates) type: ArrayCollection */ in projectsTemplates) {
				if (i.title == projectTemplateType) {
					setProjectType(i.title);

					var templateSettingsName:String = isVisualEditorProject && !(exportProject != null) ?
					'$Settings.veditorproj.template' :
					'$Settings.as3proj.template';

					var tmpLocation:FileLocation = pvo.folderLocation;
					var tmpName:String = pvo.projectName;
					var tmpExistingSource:Array<FileLocation> = pvo.projectWithExistingSourcePaths;
					var tmpIsExistingProjectSource:Bool = pvo.isProjectFromExistingSource;
					Reflect.setField(templateLookup, Std.string(pvo), i.file);
					pvo = FlashDevelopImporter.parse(i.file.fileBridge.resolvePath(templateSettingsName));
					pvo.folderLocation = tmpLocation;
					pvo.projectName = tmpName;
					pvo.projectWithExistingSourcePaths = tmpExistingSource;
					pvo.isProjectFromExistingSource = tmpIsExistingProjectSource;
					break;
				}
			}
		}

		return pvo;
	}

	private function setProjectType(templateName:String):Void {
		if (templateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) != -1) {
			isVisualEditorProject = true;
		}

		if (templateName.indexOf(ProjectTemplateType.LIBRARY_PROJECT) != -1) {
			isLibraryProject = true;
		}

		if (templateName.indexOf(ProjectTemplateType.FEATHERS) != -1) {
			isFeathersProject = true;
		}

		if (templateName.indexOf(ProjectTemplateType.ACTIONSCRIPT) != -1) {
			isActionScriptProject = true;
		} else if (templateName.indexOf(ProjectTemplateType.MOBILE) != -1) {
			isMobileProject = true;
		} else if (templateName.indexOf(ProjectTemplateType.AWAY3D) != -1) {
			isAway3DProject = true;
		} else {
			isActionScriptProject = false;
		}
	}

	private function getProjectMenuType(pvo:AS3ProjectVO):String {
		if (pvo.isPrimeFacesVisualEditorProject) {
			return ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES;
		}
		if (pvo.isActionScriptOnly) {
			return ProjectMenuTypes.PURE_AS;
		}
		if (isVisualEditorProject) {
			return ProjectMenuTypes.VISUAL_EDITOR_FLEX;
		}

		if (isLibraryProject) {
			return ProjectMenuTypes.LIBRARY_FLEX_AS;
		}

		if (isFlexJSRoyalProject) {
			return ProjectMenuTypes.JS_ROYALE;
		}

		return ProjectMenuTypes.FLEX_AS;
	}

}