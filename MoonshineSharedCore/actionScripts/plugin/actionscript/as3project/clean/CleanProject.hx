////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.actionscript.as3project.clean;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IOErrorEvent;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import actionScripts.controllers.DataAgent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.core.compiler.ProjectActionEvent;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import components.popup.SelectOpenedFlexProject;
import components.views.project.TreeView;

class CleanProject extends PluginBase implements IPlugin {

	private var loader:DataAgent;
	private var selectProjectPopup:SelectOpenedFlexProject;

	private var currentTargets:Array<Dynamic>;
	private var folderCount:Int = 0;
	private var currentProjectName:String;

	override private function get_name():String {
		return 'Clean Project';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Clean swf file from output dir.';
	}

	public function new() {
		super();

		currentTargets = [];
	}

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(ProjectActionEvent.CLEAN_PROJECT, cleanSelectedProject);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(ProjectActionEvent.CLEAN_PROJECT, cleanSelectedProject);
	}

	private function cleanSelectedProject(e:Event):Void {
		//check if any project is selected in project view or not
		checkProjectCount();
	}

	private function checkProjectCount():Void {
		function onProjectSelected(event:Event):Void {
			cleanActiveProject(selectProjectPopup.selectedProject);
			onProjectSelectionCancelled(null);
		}; /*
		* @local
		*/
		if (model.projects.length > 1) {
			// check if user has selection/select any particular project or not
			if (model.mainView.isProjectViewAdded) {
				var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
				var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
				if (projectReference != null) {
					cleanActiveProject(projectReference);
					return;
				}
			}

			// if above is false open popup for project selection
			selectProjectPopup = new SelectOpenedFlexProject();
			PopUpManager.addPopUp(selectProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
			PopUpManager.centerPopUp(selectProjectPopup);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		} else {
			cleanActiveProject(AS3.as(Reflect.getProperty(model.projects, Std.string(0)), ProjectVO));
		}

		var onProjectSelectionCancelled:Event->Void = function(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		}
	}

	private function cleanActiveProject(project:ProjectVO):Void {
		cleanProjectData();

		//var pvo:ProjectVO = IDEModel.getInstance().activeProject;
		// Don't compile if there is no project. Don't warn since other compilers might take the job.
		if (project == null) {
			return;
		}

		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool) && loader == null) {
			print('Clean project: ' + project.name + '. Invoking compiler on remote server...');
		} else if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			currentProjectName = project.name;

			if (Std.is(project, AS3ProjectVO)) {
				cleanAS3Project(AS3.as(project, AS3ProjectVO));
			} else if (Std.is(project, JavaProjectVO)) {
				cleanJavaProject(AS3.as(project, JavaProjectVO));
			}
		}
	}

	private function cleanJavaProject(project:JavaProjectVO):Void {
		var target:FileLocation = project.folderLocation.resolvePath('target');
		if (AS3.as(target.fileBridge.exists, Bool)) {
			currentTargets.push(target);

			target.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
			target.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
			target.fileBridge.deleteDirectoryAsync(true);
		} else {
			success('Project files cleaned successfully : ' + project.name);
		}
	}

	private function cleanAS3Project(as3Project:AS3ProjectVO):Void {
		var outputFile:FileLocation;
		var swfPath:FileLocation;
		var swfFolderPath:FileLocation;

		if (as3Project.swfOutput.path != null) {
			outputFile = as3Project.swfOutput.path;
			swfFolderPath = outputFile.fileBridge.parent;
		}

		if (AS3.as(swfFolderPath.fileBridge.exists, Bool)) {
			var directoryItems:Array<Dynamic> = swfFolderPath.fileBridge.getDirectoryListing();
			for (directory in directoryItems) {
				folderCount++;
				currentTargets.push(swfFolderPath);

				directory.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
				directory.addEventListener(Event.COMPLETE, onProjectFolderComplete);

				if (AS3.as(Reflect.field(directory, 'isDirectory'), Bool)) {
					directory.deleteDirectoryAsync(true);
				} else {
					directory.deleteFileAsync();
				}
			}
		}

		if (as3Project.isFlexJS || as3Project.isRoyale) {
			var binFolder:FileLocation = as3Project.folderLocation.resolvePath(as3Project.jsOutputPath).resolvePath('bin');
			if (!AS3.as(binFolder.fileBridge.exists, Bool)) {
				binFolder = as3Project.folderLocation.fileBridge.resolvePath('bin');
			}

			if (AS3.as(binFolder.fileBridge.exists, Bool)) {
				var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
							var jsDebugFolder:FileLocation = binFolder.resolvePath('js-debug');
							var jsDebugFolderExists:Bool = AS3.as(jsDebugFolder.fileBridge.exists, Bool);
							if (jsDebugFolderExists) {
								folderCount++;
								currentTargets.push(jsDebugFolder);
							}

							var jsReleaseFolder:FileLocation = binFolder.resolvePath('js-release');
							var jsReleaseFolderExists:Bool = AS3.as(jsReleaseFolder.fileBridge.exists, Bool);
							if (jsReleaseFolderExists) {
								folderCount++;
								currentTargets.push(jsReleaseFolder);
							}

							if (jsDebugFolderExists) {
								jsDebugFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
								jsDebugFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
								jsDebugFolder.fileBridge.deleteDirectoryAsync(true);
							}

							if (jsReleaseFolderExists) {
								jsReleaseFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
								jsReleaseFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
								jsReleaseFolder.fileBridge.deleteDirectoryAsync(true);
							}

							if (folderCount == 0) {
								success('JavaScript project files cleaned successfully: ' + as3Project.name);
							}

							as3hx.Compat.clearTimeout(timeoutValue);
						}, 300);
			} else if ((swfPath == null || !AS3.as(swfPath.fileBridge.exists, Bool)) && !AS3.as(binFolder.fileBridge.exists, Bool)) {
				success('Project files cleaned successfully: ' + as3Project.name);
			}
		}
	}

	private function cleanProjectData():Void {
		currentProjectName = null;
		currentTargets.splice(0, currentTargets.length);
		folderCount = 0;
	}

	private function onProjectFolderComplete(event:Event):Void {
		event.target.removeEventListener(Event.COMPLETE, onProjectFolderComplete);
		event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);

		if (currentTargets != null) {
			folderCount--;
			if (folderCount <= 0) {
				for (i in 0...currentTargets.length) {
					dispatcher.dispatchEvent(new RefreshTreeEvent(currentTargets[i], true));
				}

				success('Project files cleaned successfully: ' + currentProjectName);
				cleanProjectData();
			}
		}
	}

	private function onCleanProjectIOException(event:IOErrorEvent):Void {
		event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
		error('Cannot delete file or folder: ' + Reflect.field(event.target, 'nativePath') + '\nError: ' + event.text);
	}

}