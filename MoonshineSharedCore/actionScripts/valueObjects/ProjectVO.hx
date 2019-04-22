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
package actionScripts.valueObjects;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.events.Event;
import flash.events.EventDispatcher;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import actionScripts.controllers.DataAgent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.vo.SettingsWrapper;

class ProjectVO extends EventDispatcher {

	public static inline var PROJECTS_DATA_UPDATED:String = 'PROJECTS_DATA_UPDATED';
	public static inline var PROJECTS_DATA_FAULT:String = 'PROJECTS_DATA_FAULT';

	@:meta(Bindable())public var folderNamesOnly:Array<String> = new Array<String>();

	public var folderLocation:FileLocation;

	public var projectFile:FileLocation;
	public var projectRemotePath:String;
	public var projectName:String;
	public var fileNamesOnly:Array<String>;
	public var classFilesInProject:ArrayCollection;
	public var hasVersionControlType:String;// of VersionControlTypes
	public var menuType:String = '';

	private var _projectFolder:FileWrapper;

	private var loader:DataAgent;
	private var projectConfigurationFile:FileWrapper;
	private var shallUpdateToTreeView:Bool = false;
	private var isFlashDevelopProject:Bool = false;
	private var isFlashBuilderProject:Bool = false;
	private var rootFound:Bool = false;

	private var timeoutProjectConfigValue:Int = 0;

	private var projectReference:ProjectReferenceVO;

	private var model:IDEModel = IDEModel.getInstance();

	public function new(folder:FileLocation, projectName:String = null, updateToTreeView:Bool = true) {
		super();
		classFilesInProject = new ArrayCollection();

		folderLocation = folder;

		// we need to keep a reference of owner project to every
		// filewrapper reference for later use, i.e. to determine
		// a filewrapper belongs to which project
		projectReference = new ProjectReferenceVO();
		projectReference.name = projectName;
		projectReference.path = Std.string(folder.fileBridge.nativePath);

		folderLocation = folder;

		folderLocation.fileBridge.name = this.projectName = projectName;
		shallUpdateToTreeView = updateToTreeView;

		// download the directory structure from remote
		// for the project if a Web run
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool) && _projectFolder == null) {
			loader = new DataAgent(Std.string(folder.fileBridge.nativePath), onProjectDataLoaded, onFault);
		}
	}

	@:meta(Bindable(event = 'projectFolderChanged'))
	public var projectFolder(get, set):FileWrapper;
	private function get_projectFolder():FileWrapper {
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool) && (_projectFolder == null ||
			_projectFolder.file.fileBridge.nativePath != folderLocation.fileBridge.nativePath)) {
			_projectFolder = new FileWrapper(folderLocation, true, projectReference, shallUpdateToTreeView);
		}

		return _projectFolder;
	}

	private function set_projectFolder(value:FileWrapper):FileWrapper {
		if (_projectFolder != value) {
			_projectFolder = value;
			dispatchEvent(new Event('projectFolderChanged'));
		}
		return value;
	}

	public var name(get, never):String;
	private function get_name():String {
		return Std.string(folderLocation.fileBridge.name);
	}

	public var folderPath(get, set):String;
	private function get_folderPath():String {
		return Std.string(folderLocation.fileBridge.nativePath);
	}

	private function set_folderPath(v:String):String {
		folderLocation.fileBridge.nativePath = v;
		return v;
	}

	public function saveSettings():Void {
		throw new Error('saveSettings() not implemented yet');
	}

	public function getSettings():Array<SettingsWrapper> {
		return [];
	}

	//--------------------------------------------------------------------------
	//
	//  WEB API
	//
	//--------------------------------------------------------------------------

	public function getFileByName(wrapper:FileWrapper, value:String):Void {
		if ((Std.is(wrapper.children, Array)) && (AS3.asArray(wrapper.children)).length > 0) {
			for (c_ in wrapper.children) {
				var c:FileWrapper = cast c_;
				if (Reflect.field(Reflect.field(Reflect.field(c, 'file'), 'fileBridge'), 'name') == value) {
					projectConfigurationFile = c;
					return;
				}
				getFileByName(c, value);
			}
		}
	}

	private function onProjectDataLoaded(value:Dynamic, message:String = null):Void {
		// probable termination
		if (!AS3.as(value, Bool)) {
			return;
		}

		fileNamesOnly = new Array<String>();

		var jsonString:String = Std.string(value);
		var jsonObj:Dynamic;
		try {
			jsonObj = haxe.Json.parse(jsonString);
		} catch (e:Error) {
			if (jsonString != null) {
				Alert.show(jsonString, 'Error!');
			}
			return;
		}
		// before moving any further let's check
		// if the project has created by FlashDevelop or FlashBuilder
		// @note
		// if both file types are persent in directory
		// we'll go to load FlashDevelop configuration
		if (jsonString.indexOf('.as3proj') != -1) {
			isFlashDevelopProject = true;
		} else if (jsonString.indexOf('.actionScriptProperties') != -1) {
			isFlashBuilderProject = true;
		}

		folderLocation.fileBridge.name = projectName;
		folderLocation.fileBridge.isDirectory = true;
		_projectFolder = parseChildrens(jsonObj);
		loader = null;

		if (shallUpdateToTreeView) {
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.TREE_DATA_UPDATES, this));
		} else {
			dispatchEvent(new Event(PROJECTS_DATA_UPDATED));
		}
		loader = null;

		// continue loading project configuration
		var tmpConfigName:String;
		if (isFlashDevelopProject) {
			tmpConfigName = projectName + '.as3proj';
		} else if (isFlashBuilderProject) {
			tmpConfigName = '.actionScriptProperties';
		} else {
			return;
		}
		getFileByName(projectFolder, tmpConfigName);
		timeoutProjectConfigValue = as3hx.Compat.setTimeout(loadConfiguration, 1000);
	}

	private function loadConfiguration():Void {
		if (projectConfigurationFile == null) {
			return;
		}

		var successFunction:Function;
		successFunction = ((isFlashDevelopProject)) ? onFDProjectLoaded : onFBProjectLoaded;
		loader = new DataAgent(URLDescriptorVO.FILE_OPEN, cast successFunction, onFault, {
					'path': projectConfigurationFile.file.fileBridge.nativePath
				});

		as3hx.Compat.clearTimeout(timeoutProjectConfigValue);
	}

	private function onFDProjectLoaded(value:Dynamic, message:String = null):Void {
		var rawData:String = Std.string(value);
		var jsonObj:Dynamic = haxe.Json.parse(rawData);

		ConstantsCoreVO.AS3PROJ_CONFIG_SOURCE = FastXML.parse(Reflect.field(jsonObj, 'text'));
		model.flexCore.parseFlashDevelop(AS3.as(IDEModel.getInstance().activeProject, AS3ProjectVO));
	}

	private function onFBProjectLoaded(value:Dynamic, message:String = null):Void {
		trace(value);
	}

	private function onFault(message:String):Void {
		loader = null;
		dispatchEvent(new Event(PROJECTS_DATA_FAULT));
	}

	private function parseChildrens(value:Dynamic):FileWrapper {
		if (!AS3.as(value, Bool)) {
			return null;
		}
		if (AS3.as(Reflect.field(value, 'error'), Bool)) {
			Alert.show(Reflect.field(value, 'error'), 'Error!');
			return null;
		}

		var tmpLocation:FileLocation = new FileLocation(AS3.string(Reflect.field(value, 'nativePath')));
		tmpLocation.fileBridge.isDirectory = ((Std.string(Reflect.field(value, 'isDirectory')) == 'true')) ? true : false;
		tmpLocation.fileBridge.isHidden = ((Std.string(Reflect.field(value, 'isHidden')) == 'true')) ? true : false;
		tmpLocation.fileBridge.name = ((!rootFound)) ? folderLocation.fileBridge.name : Std.string(Reflect.field(value, 'name'));
		tmpLocation.fileBridge.extension = Std.string(Reflect.field(value, 'extension'));
		tmpLocation.fileBridge.exists = true;

		if (!AS3.as(tmpLocation.fileBridge.isDirectory, Bool)) {
			fileNamesOnly.push(tmpLocation.fileBridge.nativePath);
		}

		var tmpFW:FileWrapper = new FileWrapper(tmpLocation, !rootFound, projectReference);
		rootFound = true;
		if ((Std.is(Reflect.field(value, 'children'), Array)) && (AS3.asArray(Reflect.field(value, 'children'))).length > 0) {
			var tmpSubChildren:Array<Dynamic> = [];
			for (c in as3hx.Compat.each(Reflect.field(value, 'children'))) {
				tmpSubChildren.push(parseChildrens(c));
			}

			tmpFW.children = tmpSubChildren;
		}

		if (tmpFW.children.length == 0 && !AS3.as(tmpFW.file.fileBridge.isDirectory, Bool)) {
			tmpFW.children = null;
		}
		return tmpFW;
	}

}