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
package actionScripts.utils;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.StaticLabelSetting;
import actionScripts.plugin.templating.settings.PathAccessSetting;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.valueObjects.ProjectVO;
import components.popup.DefineWorkspacePopup;

class OSXBookmarkerNotifiers {

	public static var workspaceLocation:FileLocation;
	public static var isWorkspaceAcknowledged:Bool = false;
	public static var availableBookmarkedPaths:String = '';

	private static inline var ERROR_TYPE_UNACCESSIBLE:String = 'ERROR_TYPE_UNACCESSIBLE';
	private static inline var ERROR_TYPE_NOT_EXISTS:String = 'ERROR_TYPE_NOT_EXISTS';

	private static var workspacePopup:DefineWorkspacePopup;
	private static var accessManagerPopup:IFlexDisplayObject;

	public static var availableBookmarkedPathsArr(get, never):Array<Dynamic>;
	private static function get_availableBookmarkedPathsArr():Array<Dynamic> {
		return cast ((availableBookmarkedPaths != null) ? availableBookmarkedPaths.split(',') : []);
	}

	public static function defineWorkspace():Void {
		workspacePopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), DefineWorkspacePopup, false), DefineWorkspacePopup);
		workspacePopup.addEventListener(CloseEvent.CLOSE, onWorkspaceClosed, false, 0, true);
		PopUpManager.centerPopUp(workspacePopup);
	}

	public static function checkAccessDependencies(projects:ArrayCollection, title:String = 'Access Manager', openByMenu:Bool = false):Bool {
		// gets bookmark access
		var settings:Array<ISetting> = new Array<ISetting>();
		for (project in projects) {
			var classSettings:Array<ISetting>;

			// check project's root path
			if (!isPathBookmarked(AS3.string(Reflect.field(Reflect.field(Reflect.field(project, 'folderLocation'), 'fileBridge'), 'nativePath')))) {
				classSettings = new Array<ISetting>();
				classSettings.push(getNewPathSetting(ERROR_TYPE_UNACCESSIBLE, false, Reflect.field(project, 'folderLocation'), AS3.string(Reflect.field(Reflect.field(Reflect.field(project, 'folderLocation'), 'fileBridge'), 'nativePath')), project));

				var fileLabel:StaticLabelSetting = new StaticLabelSetting('Project Path', 14);
				classSettings.unshift(fileLabel);
				settings = settings.concat(classSettings);
			}

			// check property existence basis
			if (Reflect.hasField(project, 'classpaths')) {
				classSettings = cast getUnbookmarkedPaths(project, 'classpaths', availableBookmarkedPathsArr, 'Class Paths: ' + Reflect.field(project, 'name'));
				if (classSettings.length > 0) {
					settings = settings.concat(classSettings);
				}
			}
			if (Reflect.hasField(project, 'resourcePaths')) {
				classSettings = cast getUnbookmarkedPaths(project, 'resourcePaths', availableBookmarkedPathsArr, 'Resource Paths: ' + Reflect.field(project, 'name'));
				if (classSettings.length > 0) {
					settings = settings.concat(classSettings);
				}
			}
			if (Reflect.hasField(project, 'externalLibraries')) {
				classSettings = cast getUnbookmarkedPaths(project, 'externalLibraries', availableBookmarkedPathsArr, 'External Libraries: ' + Reflect.field(project, 'name'));
				if (classSettings.length > 0) {
					settings = settings.concat(classSettings);
				}
			}
			if (Reflect.hasField(project, 'libraries')) {
				classSettings = cast getUnbookmarkedPaths(project, 'libraries', availableBookmarkedPathsArr, 'Libraries: ' + Reflect.field(project, 'name'));
				if (classSettings.length > 0) {
					settings = settings.concat(classSettings);
				}
			}
			if (Reflect.hasField(project, 'nativeExtensions')) {
				classSettings = cast getUnbookmarkedPaths(project, 'nativeExtensions', availableBookmarkedPathsArr, 'Native Extensions: ' + Reflect.field(project, 'name'));
				if (classSettings.length > 0) {
					settings = settings.concat(classSettings);
				}
			}
		}

		// # Opening the access manager popup if requires
		// ====================================================
		if (settings.length > 0 || projects.length == 0 || openByMenu) {
			// Show About Panel in Tab
			var model:IDEModel = IDEModel.getInstance();
			for (tab in model.editors) {
				if (tab == accessManagerPopup) {
					Reflect.setField(tab, 'label', title);
					Reflect.setField(tab, 'requisitePaths', settings);
					model.activeEditor = tab;
					return false;
				}
			}

			if (accessManagerPopup == null) {
				accessManagerPopup = model.flexCore.getAccessManagerPopup();
				accessManagerPopup.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAccessManagerClosed, false, 0, true);
			}

			/*var classType: Class = IDEModel.getInstance().flexCore.getAccessManagerPopup();
			accessManagerPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, Class(classType), false);
			accessManagerPopup.addEventListener(CloseEvent.CLOSE, onAccessManagerClosed, false, 0, true);*/
			Reflect.setProperty(accessManagerPopup, 'label', title);
			Reflect.setProperty(accessManagerPopup, 'requisitePaths', settings);
			//PopUpManager.centerPopUp(accessManagerPopup);

			GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(AS3.as(accessManagerPopup, IContentWindow))
			);

			return false;
		}

		// this means all good no problem
		return true;
	}

	public static function isPathBookmarked(value:String):Bool {
		// sandbox application default directory
		if (value.indexOf('Library/Containers/com.moonshine-ide/Data/Documents') != -1) {
			return true;
		}

		var separator:String = Std.string(IDEModel.getInstance().fileCore.separator);

		// # Resources that may needs access parse
		// ====================================================
		//availableBookmarkedPathsArr = (availableBookmarkedPaths) ? availableBookmarkedPaths.split(",") : [];
		if (availableBookmarkedPathsArr.length >= 1) {
			if (availableBookmarkedPathsArr[0] == '') {
				availableBookmarkedPathsArr.shift();
			}// [0] will always blank
			else if (availableBookmarkedPathsArr[0] == 'INITIALIZED') {
				availableBookmarkedPathsArr.shift();
			}// very first time initialization after Moonshine installation
		}

		for (i_ in availableBookmarkedPathsArr) {
			var i:String = cast i_;
			if ((value.indexOf(Std.string(i)) != -1) ||
				(value.indexOf(i + separator) != -1)) {
				return true;
			}
		}

		return false;
	}

	public static function isValidLocalePath(file:FileLocation):String {
		var classPath:String = Std.string(file.fileBridge.nativePath);
		if (classPath.indexOf('{locale}') != -1) {
			var tmpLocalePath:Array<String> = classPath.split(Std.string(file.fileBridge.separator));
			if (tmpLocalePath[tmpLocalePath.length - 1] == '{locale}') {
				tmpLocalePath.splice(tmpLocalePath.length - 1, 1);
				classPath = tmpLocalePath.join(Std.string(file.fileBridge.separator));
				return classPath;
			}
		}

		// if invalid
		return null;
	}

	public static function removeFlashCookies():Void {
		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		Reflect.deleteField(cookie.data, 'lastSelectedProjectPath');
		Reflect.deleteField(cookie.data, 'recentProjectPath');
		cookie.flush();

		IDEModel.getInstance().recentSaveProjectPath = new ArrayCollection();
	}

	private static function getUnbookmarkedPaths(provider:Dynamic, className:String, bList:Array<Dynamic>, title:String):Array<ISetting> {
		var settings:Array<ISetting> = new Array<ISetting>();
		var projectNativePath:String = Std.string(ProjectVO(provider).folderLocation.fileBridge.nativePath);

		// check if project's varied file fields has access
		for (i in as3hx.Compat.each(Reflect.field(provider, className))) {
			var classPath:String = AS3.string(Reflect.field(Reflect.field(i, 'fileBridge'), 'nativePath'));
			var isLocalePath:Bool = false;

			// special case to treating {locale} attribute
			var tmpLocalCheckPath:String = isValidLocalePath(i);
			if (tmpLocalCheckPath != null) {
				isLocalePath = true;
				classPath = tmpLocalCheckPath;
			}

			// usual cases continues
			var isFound:Bool = false;
			var path:PathAccessSetting = null;
			if (classPath.indexOf(projectNativePath) != -1) {
				isFound = true;
			} else {
				for (j_ in bList) {
					var j:String = cast j_;
					if (classPath.indexOf(Std.string(j)) != -1) {
						isFound = true;
						break;
					}
				}
			}

			if (!isFound) {
				path = getNewPathSetting(ERROR_TYPE_UNACCESSIBLE, isLocalePath, i, (!isLocalePath) ? classPath : AS3.string(Reflect.field(Reflect.field(i, 'fileBridge'), 'nativePath')), AS3.as(provider, ProjectVO));
				settings.push(path);
			}

			if (!AS3.as(Reflect.field(Reflect.field(i, 'fileBridge'), 'exists'), Bool)) {
				// in case of {locale} case
				if (isLocalePath && (AS3.as(new FileLocation(classPath).fileBridge.exists, Bool))) {
					break;
				}

				if (path != null) {
					path.errorType = 'The dependency file/folder does not exist:\n' + ((!isLocalePath) ? classPath : Std.string(Reflect.field(Reflect.field(i, 'fileBridge'), 'nativePath')));
				} else {
					settings.push(getNewPathSetting(ERROR_TYPE_NOT_EXISTS, isLocalePath, i, (!isLocalePath) ? classPath : AS3.string(Reflect.field(Reflect.field(i, 'fileBridge'), 'nativePath')), AS3.as(provider, ProjectVO)));
				}
			}
		}

		// do only if there are items in settings
		if (settings.length > 0) {
			var fileLabel:StaticLabelSetting = new StaticLabelSetting(title, 14);
			settings.unshift(fileLabel);
		}

		return settings;
	}

	private static function getNewPathSetting(errorType:String, isLocale:Bool, fl:FileLocation, finalPath:String, project:ProjectVO):PathAccessSetting {
		var path:PathAccessSetting = new PathAccessSetting(fl);
		path.project = project;
		path.isLocalePath = isLocale;

		switch (errorType) {
			case ERROR_TYPE_UNACCESSIBLE:
				path.errorType = 'Moonshine does not have access to:\n' + finalPath;
			case ERROR_TYPE_NOT_EXISTS:
				path.errorType = 'The dependency file/folder does not exist:\n' + finalPath;
		}

		return path;
	}

	private static function onWorkspaceClosed(event:CloseEvent):Void {
		workspacePopup.removeEventListener(CloseEvent.CLOSE, onWorkspaceClosed);
		workspacePopup = null;
	}

	private static function onAccessManagerClosed(event:Event):Void {
		accessManagerPopup.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAccessManagerClosed);
		accessManagerPopup = null;
	}

}