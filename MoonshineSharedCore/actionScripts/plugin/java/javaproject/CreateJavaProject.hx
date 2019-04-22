package actionScripts.plugin.java.javaproject;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.utils.ObjectUtil;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.NewProjectEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.java.javaproject.importer.JavaImporter;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.DropDownListSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.plugin.settings.vo.StaticLabelSetting;
import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.utils.SharedObjectConst;
import actionScripts.valueObjects.ConstantsCoreVO;

class CreateJavaProject {

	public function new(event:NewProjectEvent) {
		settingsFileLocation = event.settingsFile;
		createJavaProject(event);
	}

	private var project:JavaProjectVO;
	private var settingsFileLocation:FileLocation;
	private var newProjectNameSetting:StringSetting;
	private var newProjectPathSetting:PathSetting;
	private var isInvalidToSave:Bool = false;
	private var cookie:SharedObject;
	private var templateLookup:Dynamic = {};

	private var model:IDEModel = IDEModel.getInstance();
	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var _currentCauseToBeInvalid:String;

	private var _projectTemplateType:String;

	public var projectTemplateType(get, set):String;
	private function set_projectTemplateType(value:String):String {
		_projectTemplateType = value;
		return value;
	}

	private function get_projectTemplateType():String {
		return _projectTemplateType;
	}

	private function createJavaProject(event:NewProjectEvent):Void {
		var lastSelectedProjectPath:String;

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			if (OSXBookmarkerNotifiers.availableBookmarkedPaths == '') {
				OSXBookmarkerNotifiers.removeFlashCookies();
			}
		}

		cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		if (Reflect.hasField(cookie.data, 'recentProjectPath')) {
			model.recentSaveProjectPath.source = Reflect.field(cookie.data, 'recentProjectPath');
			if (Reflect.hasField(cookie.data, 'lastSelectedProjectPath')) {
				lastSelectedProjectPath = AS3.string(Reflect.field(cookie.data, 'lastSelectedProjectPath'));
			}
		}

		// Remove spaces from project name
		var bracketIndex:Int = AS3.int(event.templateDir.fileBridge.name.indexOf('('));
		var projectName:String = ((bracketIndex != -1)) ? Std.string(event.templateDir.fileBridge.name.substr(0, bracketIndex)) : Std.string(event.templateDir.fileBridge.name);
		projectName = 'New' + new as3hx.Compat.Regex(' ', 'g').replace(projectName, '');

		project = new JavaProjectVO(event.templateDir, projectName);

		var tmpProjectSourcePath:String = ((lastSelectedProjectPath != null && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1)) ?
		lastSelectedProjectPath : Std.string(Reflect.getProperty(model.recentSaveProjectPath.source, Std.string(model.recentSaveProjectPath.length - 1)));
		project.folderLocation = new FileLocation(tmpProjectSourcePath);

		var settingsView:SettingsView = new SettingsView();
		settingsView.exportProject = event.exportProject;
		settingsView.Width = 150;
		settingsView.defaultSaveLabel = (event.isExport) ? 'Export' : 'Create';
		settingsView.isNewProjectSettings = true;

		settingsView.addCategory('');

		var settings:SettingsWrapper = getProjectSettings(project, event);
		settings.getSettingsList().push(
				new DropDownListSetting(this, 'projectTemplateType', 'Select Template Type', ConstantsCoreVO.TEMPLATES_PROJECTS_JAVA, 'title')
		);
		projectTemplateType = event.templateDir.name;

		settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
		settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
		settingsView.addSetting(settings, '');

		settingsView.label = 'New Project';
		settingsView.associatedData = project;

		dispatcher.dispatchEvent(new AddTabEvent(settingsView));

		Reflect.setField(templateLookup, Std.string(project), event.templateDir);
	}

	private function getProjectSettings(project:JavaProjectVO, eventObject:NewProjectEvent):SettingsWrapper {
		var historyPaths:ArrayCollection = AS3.as(ObjectUtil.copy(model.recentSaveProjectPath), ArrayCollection);
		if (historyPaths.length == 0) {
			historyPaths.addItem(project.folderPath);
		}

		newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\\'",<.>/?');
		newProjectPathSetting = new PathSetting(project, 'folderPath', 'Parent directory', true, null, false, true);
		newProjectPathSetting.dropdownListItems = historyPaths;

		newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
		newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);

		if (eventObject.isExport) {
			//newProjectNameSetting.isEditable = false;
			return new SettingsWrapper('Name & Location', [
					new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
					newProjectNameSetting, // No space input either plx
					newProjectPathSetting
			]);
		}

		return new SettingsWrapper('Name & Location', [
				new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
				newProjectNameSetting, // No space input either plx
				newProjectPathSetting
		]);
	}

	private function checkIfProjectDirectory(value:FileLocation):Void {
		var tmpFile:FileLocation = JavaImporter.test(value.fileBridge.getFile);
		if (tmpFile == null && AS3.as(value.fileBridge.exists, Bool)) {
			tmpFile = value;
		}

		if (tmpFile != null) {
			newProjectPathSetting.setMessage(_currentCauseToBeInvalid = 'Project can not be created to an existing project directory:\n' + value.fileBridge.nativePath, AbstractSetting.MESSAGE_CRITICAL);
		} else {
			newProjectPathSetting.setMessage(Std.string(value.fileBridge.nativePath));
		}

		if (newProjectPathSetting.stringValue == '') {
			isInvalidToSave = true;
			_currentCauseToBeInvalid = 'Unable to access Project Directory:\n' + value.fileBridge.nativePath + '\nPlease try to create the project again and use the "Change" link to open the target directory again.';
		} else {
			isInvalidToSave = (tmpFile != null) ? true : false;
		}
	}

	private function onProjectPathChanged(event:Event, makeNull:Bool = true):Void {
		if (makeNull) {
			project.projectFolder = null;
		}
		project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
		newProjectPathSetting.label = 'Parent Directory';
		checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
	}

	private function onProjectNameChanged(event:Event):Void {
		checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
	}

	private function createClose(event:Event):Void {
		var settings:SettingsView = AS3.as(event.target, SettingsView);

		settings.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
		settings.removeEventListener(SettingsView.EVENT_SAVE, createSave);
		if (newProjectPathSetting != null) {
			newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
		}

		Reflect.deleteField(templateLookup, settings.associatedData);

		dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(event.target, DisplayObject))
		);
	}

	private function createSave(event:Event):Void {
		if (isInvalidToSave) {
			throwError();
			return;
		}

		var view:SettingsView = AS3.as(event.target, SettingsView);
		var project:JavaProjectVO = AS3.as(view.associatedData, JavaProjectVO);

		//save project path in shared object
		cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		var tmpParent:FileLocation = project.folderLocation;

		if (!AS3.as(model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath), Bool)) {
			model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
		}

		Reflect.setField(cookie.data, 'lastSelectedProjectPath', project.folderLocation.fileBridge.nativePath);
		Reflect.setField(cookie.data, 'recentProjectPath', model.recentSaveProjectPath.source);
		cookie.flush();

		project = createFileSystemBeforeSave(project, AS3.as(view.exportProject, JavaProjectVO));
		if (project == null) {
			return;
		}

		// Close settings view
		createClose(event);

		// Open main file for editing
		dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
		);

		/*dispatcher.dispatchEvent(
			new OpenFileEvent(OpenFileEvent.OPEN_FILE, project.targets[0], -1, project.projectFolder)
		);*/

		if (view.exportProject != null) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
		}
	}

	private function throwError():Void {
		Alert.show(_currentCauseToBeInvalid + ' Project creation terminated.', 'Error!');
		//dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, _currentCauseToBeInvalid +"\nProject creation terminated.", false, false, ConsoleOutputEvent.TYPE_ERROR));
	}

	private function createFileSystemBeforeSave(pvo:JavaProjectVO, exportProject:JavaProjectVO = null):JavaProjectVO {
		// in case of create new project through Open Project option
		// we'll need to get the template project directory by it's name
		//pvo = getProjectWithTemplate(pvo, exportProject);

		var templateDir:FileLocation = Reflect.field(templateLookup, Std.string(pvo));
		var projectName:String = pvo.projectName;

		var targetFolder:FileLocation = pvo.folderLocation;

		// Create project root directory
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			if (!OSXBookmarkerNotifiers.isPathBookmarked(Std.string(targetFolder.fileBridge.nativePath))) {
				_currentCauseToBeInvalid = 'Unable to access Parent Directory:\n' + targetFolder.fileBridge.nativePath + '\nPlease try to create the project again and use the "Change" link to open the target directory again.';
				throwError();
				return null;
			}
		}

		targetFolder = targetFolder.resolvePath(projectName);
		targetFolder.fileBridge.createDirectory();

		// Time to do the templating thing!
		var th:TemplatingHelper = new TemplatingHelper();
		th.isProjectFromExistingSource = false;
		Reflect.setField(th.templatingData, '$ProjectName', projectName);

		var pattern:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('(_)', 'g'));
		Reflect.setField(th.templatingData, '$ProjectID', pattern.replace(projectName, ''));
		Reflect.setField(th.templatingData, '$Settings', projectName);

		th.projectTemplate(templateDir, targetFolder);

		return JavaImporter.parse(targetFolder, projectName, settingsFileLocation);
	}

}