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
package actionScripts.plugin.actionscript.as3project;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.MenuEvent;
import actionScripts.events.NewProjectEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.project.ProjectTemplateType;
import actionScripts.plugin.project.ProjectType;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.plugin.templating.event.TemplateEvent;
import actionScripts.utils.FileCoreUtil;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import components.popup.NativeExtensionMessagePopup;
import components.popup.OpenFlexProject;

class AS3ProjectPlugin extends PluginBase {

	public static inline var EVENT_IMPORT_FLASHBUILDER_PROJECT:String = 'importFBProjectEvent';
	public static inline var EVENT_IMPORT_FLASHDEVELOP_PROJECT:String = 'importFDProjectEvent';
	public static inline var AS3PROJ_AS_AIR:Int = 1;
	public static inline var AS3PROJ_AS_WEB:Int = 2;
	public static inline var AS3PROJ_AS_ANDROID:Int = 3;
	public static inline var AS3PROJ_AS_IOS:Int = 4;

	public var activeType:Int = ProjectType.AS3PROJ_AS_AIR;

	// projectvo:templatedir
	private var importProjectPopup:OpenFlexProject;
	private var flashBuilderProjectFile:FileLocation;
	private var flashDevelopProjectFile:FileLocation;
	private var nonProjectFolderLocation:FileLocation;
	private var aneMessagePopup:NativeExtensionMessagePopup;

	override private function get_name():String {
		return 'AS3 Project Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'AS3 project importing, exporting & scaffolding.';
	}

	public function new() {
		super();
	}

	override public function activate():Void {
		dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
		dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
		dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE, importArchiveProject);
		dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, importProjectWithoutDialog);
		dispatcher.addEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
		dispatcher.addEventListener(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE, onNativeExtensionMessage);

		super.activate();
	}

	override public function deactivate():Void {
		dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
		dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
		dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE, importArchiveProject);
		dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, importProjectWithoutDialog);
		dispatcher.removeEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
		dispatcher.removeEventListener(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE, onNativeExtensionMessage);

		super.deactivate();
	}

	// If user opens project file, open project automagically
	private function importFDProject(projectFile:FileLocation = null, openWithChoice:Bool = false, openByProject:ProjectVO = null):Void {
		// Is file in an already opened project?
		for (p in model.projects) {
			if (projectFile.fileBridge.parent.fileBridge.nativePath == Reflect.field(Reflect.field(Reflect.field(p, 'folderLocation'), 'fileBridge'), 'nativePath')) {
				warning('Project already opened. Ignoring.');
				return;
			}
		}

		// Assume user wants to open project by clicking settings file
		openProject(projectFile, openWithChoice, openByProject);
	}

	private function openProject(projectFile:FileLocation, openWithChoice:Bool = false, openByProject:ProjectVO = null):Void {
		var project:ProjectVO = (openByProject != null) ? openByProject : model.flexCore.parseFlashDevelop(null, projectFile);
		project.projectFile = projectFile;

		dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project, ((openWithChoice)) ? ProjectEvent.LAST_OPENED_AS_FD_PROJECT : null));
	}

	private function importProject(event:Event):Void {
		// for AIR
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			model.fileCore.browseForDirectory('Flex Project Directory', openFile, onFileSelectionCancelled);
		}// for WEB
		else {
			importProjectPopup = new OpenFlexProject();
			importProjectPopup.jumptToLoadProject = MenuEvent(event).data;
			PopUpManager.addPopUp(importProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
			PopUpManager.centerPopUp(importProjectPopup);
		}
	}

	private function importArchiveProject(event:Event):Void {
		model.flexCore.importArchiveProject();
	}

	private function importProjectWithoutDialog(event:ProjectEvent):Void {
		if (!AS3.as(event.anObject, Bool)) {
			return;
		}

		openFile(event.anObject);
	}

	private function onFileSelectionCancelled():Void {
		/*event.target.removeEventListener(Event.SELECT, openFile);
		event.target.removeEventListener(Event.CANCEL, onFileSelectionCancelled);*/
	}

	private function openFile(dir:Dynamic):Void {
		//onFileSelectionCancelled(event);
		// probable termination due to error at objC side
		if (!AS3.as(dir, Bool)) {
			return;
		}

		var isFBProject:Bool;
		var isFDProject:Bool;
		flashDevelopProjectFile = model.flexCore.testFlashDevelop(dir);
		flashBuilderProjectFile = model.flexCore.testFlashBuilder(dir);
		if (flashBuilderProjectFile != null) {
			isFBProject = true;
		}
		if (flashDevelopProjectFile != null) {
			isFDProject = true;
		}

		// for Java projects
		if (flashBuilderProjectFile == null && flashDevelopProjectFile == null) {
			flashDevelopProjectFile = model.javaCore.testJava(dir);
			if (flashDevelopProjectFile != null) {
				importFDProject(flashDevelopProjectFile, false, model.javaCore.parseJava(new FileLocation(AS3.string(Reflect.field(dir, 'nativePath')))));
				return;
			}
		}

		if (!isFBProject && !isFDProject) {
			nonProjectFolderLocation = new FileLocation(AS3.string(Reflect.field(dir, 'nativePath')));
			Alert.show('This directory is missing the Moonshine project configuration files. Do you want to generate a new project by locating existing source?', 'Error!', Alert.YES | Alert.NO, null, onExistingSourceProjectConfirm);
		} else if (isFBProject && isFDProject) {
			// @devsena
			// check change log in AS3ProjectVO.as against
			// commenting the following process

			/*Alert.okLabel = "Flash Builder Project";
			Alert.yesLabel = "FlashDevelop Project";
			Alert.buttonWidth = 150;

			Alert.show("Project directory contains different types of Flex projects. Please, choose an option how you want it to be open.", "Project Type Choice", Alert.OK|Alert.YES|Alert.CANCEL, null, projectChoiceHandler);
			Alert.okLabel = "OK";
			Alert.yesLabel = "YES";
			Alert.buttonWidth = 65;*/

			importFDProject(flashDevelopProjectFile);
		} else if (isFBProject) {
			importFBProject();
		} else if (isFDProject) {
			importFDProject(flashDevelopProjectFile);
		}
	}

	private function onExistingSourceProjectConfirm(event:CloseEvent):Void {
		if (event.detail == Alert.YES) {
			createAS3Project(new NewProjectEvent('', 'as3proj', null, nonProjectFolderLocation));
		}

		nonProjectFolderLocation = null;
	}

	private function projectChoiceHandler(event:CloseEvent):Void {
		as3hx.Compat.setTimeout(function():Void {
					if (event.detail == Alert.OK) {
						importFBProject(true);
					} else if (event.detail == Alert.YES) {
						importFDProject(flashDevelopProjectFile, true);
					}
				}, 300);
	}

	private function importFBProject(openWithChoice:Bool = false):Void {
		var p:AS3ProjectVO = model.flexCore.parseFlashBuilder(flashBuilderProjectFile);
		dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, p, ((openWithChoice)) ? ProjectEvent.LAST_OPENED_AS_FB_PROJECT : null)
		);
	}

	private function handleTemplatingDataRequest(event:TemplateEvent):Void {
		if (TemplatingHelper.getExtension(event.template) == 'as') {
			if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && event.location != null) {
				// Find project it belongs to
				for (project in model.projects) {
					if (Std.is(project, AS3ProjectVO) && AS3.as(Reflect.field(project, 'projectFolder').containsFile(event.location), Bool)) {
						// Populate templating data
						event.templatingData = getTemplatingData(event.location, AS3.as(project, AS3ProjectVO));
						return;
					}
				}
			}

			// If nothing is found - guess the data
			event.templatingData = {};
			Reflect.setField(event.templatingData, '$projectName', 'New');
			Reflect.setField(event.templatingData, '$packageName', '');
			Reflect.setField(event.templatingData, '$fileName', 'New');
		}
	}

	private function getTemplatingData(file:FileLocation, project:AS3ProjectVO):Dynamic {
		var toRet:Dynamic = {};
		Reflect.setField(toRet, '$projectName', project.name);

		// Figure out package name
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			for (dir in project.classpaths) {
				if (FileCoreUtil.contains(dir, flashBuilderProjectFile)) {
					// Convert path to package name in dot-style
					var relativePath:String = Std.string(dir.fileBridge.getRelativePath(flashBuilderProjectFile));
					var packagePath:String = relativePath.substring(0, relativePath.indexOf(Std.string(flashBuilderProjectFile.fileBridge.name)));
					if (packagePath.charAt(packagePath.length - 1) == model.fileCore.separator) {
						packagePath = packagePath.substring(0, packagePath.length - 1);
					}
					var packageName:String = packagePath.split(Std.string(model.fileCore.separator)).join('.');
					Reflect.setField(toRet, '$packageName', packageName);
					break;
				}
			}

			var name:String = Std.string(Reflect.getProperty(flashBuilderProjectFile.fileBridge.name.split('.'), Std.string(0)));
			Reflect.setField(toRet, '$fileName', name);
		}

		return toRet;
	}

	// Create new AS3 Project
	private function createAS3Project(event:NewProjectEvent):Void {
		if (!canCreateProject(event)) {
			return;
		}

		model.flexCore.createProject(event);
	}

	private function onNativeExtensionMessage(event:Event):Void {
		if (aneMessagePopup == null) {
			aneMessagePopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), NativeExtensionMessagePopup), NativeExtensionMessagePopup);
			aneMessagePopup.addEventListener(CloseEvent.CLOSE, onAneMessageClosed, false, 0, true);
			PopUpManager.centerPopUp(aneMessagePopup);
		} else {
			PopUpManager.bringToFront(aneMessagePopup);
		}
	}

	private function onAneMessageClosed(event:CloseEvent):Void {
		aneMessagePopup.removeEventListener(CloseEvent.CLOSE, onAneMessageClosed);
		aneMessagePopup = null;
	}

	private function canCreateProject(event:NewProjectEvent):Bool {
		var projectTemplateName:String = Std.string(event.templateDir.fileBridge.name);
		return projectTemplateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) == -1 && projectTemplateName.indexOf(ProjectTemplateType.JAVA) == -1;
	}

}