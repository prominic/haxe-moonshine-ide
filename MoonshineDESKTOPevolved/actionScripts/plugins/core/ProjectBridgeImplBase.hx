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
package actionScripts.plugins.core;

import haxe.Constraints.Function;
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import mx.controls.Alert;
import actionScripts.events.NewProjectEvent;
import actionScripts.plugins.as3project.CreateProject;
import actionScripts.plugins.as3project.ImportArchiveProject;
import actionScripts.valueObjects.FileWrapper;

class ProjectBridgeImplBase {

	private var executeCreateProject:CreateProject;

	private var filesToBeDeleted:Array<Dynamic>;
	private var deletableProjectWrapper:FileWrapper;
	private var projectDeleteCompletionMethod:Function;

	public function createProject(event:NewProjectEvent):Void {
		executeCreateProject = new CreateProject(event);
	}

	public function importArchiveProject():Void {
		new ImportArchiveProject();
	}

	public function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Bool = false):Void {
		if (isDeleteRoot) {
			projectWrapper.file.fileBridge.deleteDirectory(true);
			finishHandler(projectWrapper);
		} else {
			filesToBeDeleted = projectWrapper.children;
			deletableProjectWrapper = projectWrapper;
			projectDeleteCompletionMethod = cast finishHandler;

			deleteFilesAsync();
		}
	}

	private function deleteFilesAsync():Void {
		if (filesToBeDeleted != null && filesToBeDeleted.length != 0) {
			var tmpWrapper:FileWrapper = AS3.as(filesToBeDeleted[0], FileWrapper);
			addRemoveListeners(tmpWrapper.file.fileBridge.getFile, true);

			if (AS3.as(tmpWrapper.file.fileBridge.isDirectory, Bool)) {
				tmpWrapper.file.fileBridge.deleteDirectoryAsync(true);
			} else {
				tmpWrapper.file.fileBridge.deleteFileAsync();
			}

			return;
		} else if (AS3.as(deletableProjectWrapper.file.fileBridge.exists, Bool) && deletableProjectWrapper.file.fileBridge.getDirectoryListing().length == 0) {
			// remove root only if children is 0
			addRemoveListeners(deletableProjectWrapper.file.fileBridge.getFile, true);
			deletableProjectWrapper.file.fileBridge.deleteDirectoryAsync(true);
		}

		// confirm to the caller
		projectDeleteCompletionMethod([deletableProjectWrapper]);

		// remove footprint
		filesToBeDeleted = null;
		deletableProjectWrapper = null;
		projectDeleteCompletionMethod = null;
	}

	private function onFileFolderDeleted(event:Event):Void {
		onFileFolderDeletionError(event, false);
		if (filesToBeDeleted != null) {
			filesToBeDeleted.shift();
			deleteFilesAsync();
		}
	}

	private function onFileFolderDeletionError(event:Event, showError:Bool = true):Void {
		if (showError) {
			Alert.show(Std.string(event));
		}

		if (event != null) {
			addRemoveListeners(event.target, false);
		} else {
			addRemoveListeners(Reflect.field(Reflect.field(Reflect.field(filesToBeDeleted[0], 'file'), 'fileBridge'), 'getFile'), false);
		}
	}

	private function addRemoveListeners(file:Dynamic, isAdd:Bool):Void {
		if (isAdd) {
			file.addEventListener(Event.COMPLETE, onFileFolderDeleted);
			file.addEventListener(IOErrorEvent.IO_ERROR, onFileFolderDeletionError);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileFolderDeletionError);
		} else if (AS3.as(file, Bool)) {
			file.removeEventListener(Event.COMPLETE, onFileFolderDeleted);
			file.removeEventListener(IOErrorEvent.IO_ERROR, onFileFolderDeletionError);
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileFolderDeletionError);
		}
	}

	public function new() {}

}