////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils;

import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import mx.utils.ObjectUtil;
import mx.utils.UIDUtil;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;

class SharedObjectUtil {

	public static function getMoonshineIDEProjectSO(name:String):SharedObject {
		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		var model:IDEModel = IDEModel.getInstance();
		if (name.indexOf('projectTree') > -1 && !model.openPreviouslyOpenedProjectBranches) {
			return null;
		}
		if (name.indexOf('projectFiles') > -1 && !model.openPreviouslyOpenedFiles) {
			return null;
		}
		if (name.indexOf('projects') > -1 && !model.openPreviouslyOpenedProjects) {
			return null;
		}

		for (item in Reflect.fields(cookie.data)) {
			if (item.indexOf(name) > -1) {
				return cookie;
			}
		}

		return null;
	}

	public static function resetMoonshineIdeProjectSO():Void {
		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		Reflect.deleteField(cookie.data, 'projectTree');
		for (item in Reflect.fields(cookie.data)) {
			Reflect.deleteField(cookie.data, item);
		}

		cookie.flush();
	}

	public static function getRepositoriesFromSO():ArrayCollection {
		var tmpCollection:ArrayCollection = new ArrayCollection();
		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
		var tmpRepository:RepositoryItemVO;
		if (Reflect.hasField(cookie.data, 'savedRepositories')) {
			for (item in as3hx.Compat.each(Reflect.field(cookie.data, 'savedRepositories'))) {
				tmpRepository = AS3.as(ObjectTranslator.objectToInstance(item, RepositoryItemVO), RepositoryItemVO);
				tmpRepository.udid = Std.string(UIDUtil.createUID());
				if (tmpRepository.children != null) {
					if (tmpRepository.type == VersionControlTypes.GIT) {
						// only in the case of Git type
						// we shall parse children to parse saved
						// git-meta (#503)
						var children:Array<Dynamic> = tmpRepository.children;
						var subRepository:RepositoryItemVO;
						tmpRepository.children = [];
						for (subItem in children) {
							subRepository = AS3.as(ObjectTranslator.objectToInstance(subItem, RepositoryItemVO), RepositoryItemVO);
							subRepository.udid = Std.string(UIDUtil.createUID());
							tmpRepository.children.push(subRepository);
						}
					} else {
						// in case of SVN we'll continue
						// to update children at runtime only
						tmpRepository.children = [];
					}
				}
				tmpCollection.addItem(tmpRepository);
			}
		}

		return tmpCollection;
	}

	public static function saveRepositoriesToSO(collection:ArrayCollection):Void {
		var duplicate:ArrayCollection = AS3.as(ObjectUtil.copy(collection), ArrayCollection);

		// we don't want to store children data
		// only in case of non-Git item type.
		// continue to save children to save any
		// already parsed git-meta (#503)
		for (repo in duplicate) {
			if (AS3.as(Reflect.field(repo, 'children'), Bool) &&
				Reflect.field(repo, 'children').length > 0 &&
				Reflect.field(repo, 'type') == VersionControlTypes.SVN) {
				Reflect.setField(repo, 'children', []);
			}

			// also don't store any password if asked to
			// save for current session
			Reflect.setField(repo, 'userPassword', null);
		}

		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
		Reflect.setField(cookie.data, 'savedRepositories', duplicate);
		cookie.flush();
	}

	public static function resetRepositoriesSO():Void {
		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
		cookie.clear();
		cookie.flush();
	}

	public static function saveProjectTreeItemForOpen(item:Dynamic, propertyNameKey:String,
			propertyNameKeyValue:String):Void {
		if (!IDEModel.getInstance().openPreviouslyOpenedProjectBranches) {
			return;
		}

		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		if (!AS3.as(Reflect.field(Reflect.field(cookie, 'data'), 'projectTree'), Bool)) {
			Reflect.setField(Reflect.field(cookie, 'data'), 'projectTree', []);
		}

		saveProjectItem(item, propertyNameKey, propertyNameKeyValue, 'projectTree');
	}

	public static function removeProjectTreeItemFromOpenedItems(item:Dynamic, propertyNameKey:String,
			propertyNameKeyValue:String):Void {
		if (!IDEModel.getInstance().openPreviouslyOpenedProjectBranches) {
			return;
		}

		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		var projectTree:Array<Dynamic> = Reflect.field(Reflect.field(cookie, 'data'), 'projectTree');
		if (projectTree == null) {
			return;
		}
		var cookieName:String = 'projectTree';
		var isItemRemoved:Bool = removeProjectItem(item, propertyNameKey, propertyNameKeyValue, cookieName);
		if (isItemRemoved && propertyNameKeyValue == 'path') {
			removeProjectLefovers(item, propertyNameKeyValue);
		}
	}

	public static function saveLocationOfOpenedProjectFile(fileName:String, filePath:String, projectPath:String):Void {
		var model:IDEModel = IDEModel.getInstance();
		if (!model.openPreviouslyOpenedFiles) {
			return;
		}

		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		var projectLocation:FileLocation = new FileLocation(projectPath);
		var projectReferenceVO:ProjectReferenceVO = new ProjectReferenceVO();
		projectReferenceVO.path = projectPath;
		var fileProjectWrapper:FileWrapper = new FileWrapper(projectLocation, false, projectReferenceVO, false);

		var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fileProjectWrapper);
		if (project == null) {
			return;
		}

		var cookieName:String = 'projectFiles' + project.name;
		if (Reflect.field(Reflect.field(cookie, 'data'), cookieName) == null) {
			Reflect.setField(Reflect.field(cookie, 'data'), cookieName, []);
		}

		saveProjectItem({
					'name': fileName,
					'path': filePath
				}, 'name', 'path', cookieName);
	}

	public static function removeLocationOfClosingProjectFile(fileName:String, filePath:String, projectPath:String):Void {
		var model:IDEModel = IDEModel.getInstance();
		if (!model.openPreviouslyOpenedFiles) {
			return;
		}

		var projectLocation:FileLocation = new FileLocation(projectPath);
		var projectReferenceVO:ProjectReferenceVO = new ProjectReferenceVO();
		projectReferenceVO.path = projectPath;
		var fileProjectWrapper:FileWrapper = new FileWrapper(projectLocation, false, projectReferenceVO, false);

		var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fileProjectWrapper);
		if (project == null) {
			return;
		}

		removeProjectItem({
					'name': fileName,
					'path': filePath
				}, 'name', 'path', 'projectFiles' + project.name);
	}

	public static function saveProjectForOpen(projectFolderPath:String, projectName:String):Void {
		var model:IDEModel = IDEModel.getInstance();
		if (!model.openPreviouslyOpenedProjects) {
			return;
		}

		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		if (Reflect.field(Reflect.field(cookie, 'data'), 'projects') == null) {
			Reflect.setField(Reflect.field(cookie, 'data'), 'projects', []);
		}

		saveProjectItem({
					'name': projectFolderPath,
					'path': projectName
				}, 'name', 'path', 'projects');
	}

	public static function removeProjectFromOpen(projectFolderPath:String, projectName:String):Void {
		var model:IDEModel = IDEModel.getInstance();
		if (!model.openPreviouslyOpenedProjects) {
			return;
		}

		removeProjectItem({
					'name': projectFolderPath,
					'path': projectName
				}, 'name', 'path', 'projects');
	}

	public static function removeCookieByName(cookieName:String):Void {
		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		if (Reflect.hasField(Reflect.field(cookie, 'data'), cookieName)) {
			Reflect.deleteField(Reflect.field(cookie, 'data'), cookieName);
			cookie.flush();
		}
	}

	private static function saveProjectItem(item:Dynamic, propertyNameKey:String,
			propertyNameKeyValue:String, cookieName:String):Void {
		function hasSomeItemForOpen(itemForOpen:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return Reflect.hasField(itemForOpen, Std.string(Reflect.field(item, propertyNameKey))) && Reflect.field(itemForOpen, Std.string(Reflect.field(item, propertyNameKey))) == Reflect.field(item, propertyNameKeyValue);
		};
		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		if (AS3.as(item, Bool) && Reflect.hasField(item, propertyNameKeyValue) && Reflect.hasField(item, propertyNameKey)) {
			var hasItemForOpen:Bool = AS3.as(Reflect.field(Reflect.field(cookie, 'data'), cookieName).some(), Bool);

			if (!hasItemForOpen) {
				var itemForSave:Dynamic = {};
				Reflect.setField(itemForSave, Std.string(Reflect.field(item, propertyNameKey)), Reflect.field(item, propertyNameKeyValue));
				Reflect.field(Reflect.field(cookie, 'data'), cookieName).push(itemForSave);

				cookie.flush();
			}
		}
	}

	private static function removeProjectItem(item:Dynamic, propertyNameKey:String,
			propertyNameKeyValue:String, cookieName:String):Bool {
		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);

		if (AS3.as(item, Bool) && Reflect.hasField(item, propertyNameKeyValue) && Reflect.hasField(item, propertyNameKey)) {
			var data:Dynamic = Reflect.field(cookie, 'data');
			if (!Reflect.hasField(data, cookieName)) {
				return false;
			}

			for (i in 0...Reflect.field(data, cookieName).length) {
				var itemForRemove:Dynamic = Reflect.field(Reflect.field(data, cookieName), Std.string(i));
				var itemForRemoveProperty:String = AS3.string(Reflect.field(itemForRemove, Std.string(Reflect.field(item, propertyNameKey))));
				var itemValue:String = AS3.string(Reflect.field(item, propertyNameKeyValue));
				if (Reflect.hasField(itemForRemove, Std.string(Reflect.field(item, propertyNameKey))) &&
					itemForRemoveProperty == itemValue) {
					Reflect.field(data, cookieName).removeAt(i);
					cookie.flush();
					return true;
				}
			}
		}

		return false;
	}

	private static function removeProjectLefovers(item:Dynamic, propertyNameKeyValue:String):Void {
		var cookie:Dynamic = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
		var cookieName:String = 'projectTree';

		var data:Dynamic = Reflect.field(cookie, 'data');
		for (i in 0...Reflect.field(data, cookieName).length) {
			var itemForRemove:Dynamic = Reflect.field(Reflect.field(data, cookieName), Std.string(i));
			var itemValue:String = AS3.string(Reflect.field(item, propertyNameKeyValue));

			for (itemRemove in Reflect.fields(itemForRemove)) {
				var itemProperty:String = AS3.string(Reflect.field(itemForRemove, itemRemove));
				if (itemProperty.indexOf(itemValue) > -1) {
					Reflect.field(data, cookieName).removeAt(i);
					cookie.flush();
				}
			}
		}
	}

}