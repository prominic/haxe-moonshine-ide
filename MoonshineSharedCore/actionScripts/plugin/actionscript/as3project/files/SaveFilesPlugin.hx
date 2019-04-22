// ActionScript file
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
package actionScripts.plugin.actionscript.as3project.files;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ButtonSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.valueObjects.ConstantsCoreVO;

class SaveFilesPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	override private function get_name():String {
		return 'General';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'General options to Moonshine';
	}

	public var resetLabel:String = 'Reset to Default';

	private var _workspacePath:String;
	private var _isSaveFiles:Bool = false;
	private var _openPreviouslyOpenedProjects:Bool = false;
	private var _openPreviouslyOpenedProjectBranches:Bool = false;
	private var _openPreviouslyOpenedFiles:Bool = false;
	private var _showHiddenPaths:Bool = false;

	public function new() {
		super();

		openPreviouslyOpenedProjects = true;
		openPreviouslyOpenedFiles = true;
		openPreviouslyOpenedProjectBranches = true;
	}

	public var isSaveFiles(get, set):Bool;
	private function get_isSaveFiles():Bool {
		return _isSaveFiles;
	}

	private function set_isSaveFiles(value:Bool):Bool {
		_isSaveFiles = value;
		model.saveFilesBeforeBuild = value;
		return value;
	}

	public var workspacePath(get, set):String;
	private function get_workspacePath():String {
		return _workspacePath;
	}

	private function set_workspacePath(value:String):String {
		_workspacePath = value;
		OSXBookmarkerNotifiers.workspaceLocation = (value != null) ? new FileLocation(_workspacePath) : null;
		return value;
	}

	public var openPreviouslyOpenedProjects(get, set):Bool;
	private function get_openPreviouslyOpenedProjects():Bool {
		return _openPreviouslyOpenedProjects;
	}

	private function set_openPreviouslyOpenedProjects(value:Bool):Bool {
		_openPreviouslyOpenedProjects = value;
		model.openPreviouslyOpenedProjects = value;
		return value;
	}

	public var openPreviouslyOpenedProjectBranches(get, set):Bool;
	private function get_openPreviouslyOpenedProjectBranches():Bool {
		return _openPreviouslyOpenedProjectBranches;
	}

	private function set_openPreviouslyOpenedProjectBranches(value:Bool):Bool {
		_openPreviouslyOpenedProjectBranches = value;
		model.openPreviouslyOpenedProjectBranches = value;
		return value;
	}

	public var openPreviouslyOpenedFiles(get, set):Bool;
	private function get_openPreviouslyOpenedFiles():Bool {
		return _openPreviouslyOpenedFiles;
	}

	private function set_openPreviouslyOpenedFiles(value:Bool):Bool {
		_openPreviouslyOpenedFiles = value;
		model.openPreviouslyOpenedFiles = value;
		return value;
	}

	public var confirmApplicationExit(get, set):Bool;
	private function get_confirmApplicationExit():Bool {
		return model.confirmApplicationExit;
	}

	private function set_confirmApplicationExit(value:Bool):Bool {
		model.confirmApplicationExit = value;
		return value;
	}

	public var showHiddenPaths(get, set):Bool;
	private function get_showHiddenPaths():Bool {
		return model.showHiddenPaths;
	}

	private function set_showHiddenPaths(value:Bool):Bool {
		_showHiddenPaths = value;
		model.showHiddenPaths = value;
		return value;
	}

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(ActionScriptBuildEvent.SAVE_BEFORE_BUILD, saveBeforeBuild);
		//dispatcher.addEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
		dispatcher.addEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(ActionScriptBuildEvent.SAVE_BEFORE_BUILD, saveBeforeBuild);
		//dispatcher.removeEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
		dispatcher.removeEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
	}

	override public function resetSettings():Void {
		workspacePath = null;
		isSaveFiles = false;
		OSXBookmarkerNotifiers.isWorkspaceAcknowledged = false;
		model.saveFilesBeforeBuild = false;
	}

	public function getSettingsList():Array<ISetting> {
		// update local path
		if (OSXBookmarkerNotifiers.workspaceLocation != null && AS3.as(OSXBookmarkerNotifiers.workspaceLocation.fileBridge.exists, Bool)) {
			workspacePath = Std.string(OSXBookmarkerNotifiers.workspaceLocation.fileBridge.nativePath);
		}

		return [
				new PathSetting(this, 'workspacePath', ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Workspace', true),
				new BooleanSetting(this, 'isSaveFiles', 'Save automatically before Build'),
				new BooleanSetting(this, 'showHiddenPaths', 'Show hidden files/folders'),
				new BooleanSetting(this, 'confirmApplicationExit', 'Confirm application exit'),
				new BooleanSetting(this, 'openPreviouslyOpenedProjects', 'Open previously opened projects on startup'),
				new BooleanSetting(this, 'openPreviouslyOpenedFiles', 'Open previously opened files for project'),
				new BooleanSetting(this, 'openPreviouslyOpenedProjectBranches', 'Open previously opened project branches'),
				new ButtonSetting(this, 'resetLabel', 'Reset all Settings (Hard)', 'resetApplication', ButtonSetting.STYLE_DANGER)
		];
	}

	private function saveBeforeBuild(e:Event):Void {
		isSaveFiles = true;// DO not show prompt again
	}

	private function setWorkspace(event:Event):Void {
		OSXBookmarkerNotifiers.defineWorkspace();
	}

	private function openAccessManager(event:Event):Void {
		OSXBookmarkerNotifiers.checkAccessDependencies(model.projects, 'Access Manager', true);
	}

	private function onResetHandler(event:CloseEvent):Void {
		Alert.yesLabel = 'Yes';
		Alert.buttonWidth = 65;
		if (event.detail == Alert.YES) {
			if (model.activeEditor != null) {
				dispatcher.dispatchEvent(new GeneralEvent(GeneralEvent.RESET_ALL_SETTINGS));
				dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(model.activeEditor, DisplayObject)));
			}
		}
	}

	public function resetApplication():Void {
		Alert.yesLabel = 'Reset everything';
		Alert.buttonWidth = 120;
		Alert.show('Are you sure you want to reset all Moonshine settings?', 'Warning!', Alert.YES | Alert.CANCEL, AS3.as(FlexGlobals.topLevelApplication, Sprite), onResetHandler, null, Alert.CANCEL);
	}

}