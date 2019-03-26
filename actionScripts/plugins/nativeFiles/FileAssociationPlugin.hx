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
package actionScripts.plugins.nativeFiles;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.InteractiveObject;
import flash.events.InvokeEvent;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
import mx.core.FlexGlobals;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
class FileAssociationPlugin extends PluginBase {

	override private function get_name():String {
		return 'FileAssociationPlugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'File Association Plugin. Esc exits.';
	}

	private static var projectFileTypes:Array<Dynamic> = ['as3proj', 'veditorproj'];

	override public function activate():Void {
		super.activate();

		// open-with listener
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);

		// drag-drop listeners
		FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onNativeItemDragEnter, false, 0, true);
		FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onNativeItemDragDrop, false, 0, true);
	}

	private function onAppInvokeEvent(event:InvokeEvent):Void {
		if (event.arguments.length) {
			openFilesByPath(event.arguments);
		}

		// to rail the event in other parts of the applciation
		// where it may needed
		dispatcher.dispatchEvent(event);
	}

	private function onNativeItemDragEnter(event:NativeDragEvent):Void {
		if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
			return;
		}

		var files:Array<Dynamic> = try cast(event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT), Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
		for (i in files) {
			if (i.isDirectory) {
				return;
			}
		}

		// accept drop
		NativeDragManager.acceptDragDrop(cast((event.currentTarget), InteractiveObject));
	}

	private function onNativeItemDragDrop(event:NativeDragEvent):Void {
		if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
			return;
		}

		var files:Array<Dynamic> = try cast(event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT), Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
		files = files.map(function(element:Dynamic, index:Int, arr:Array<Dynamic>):String {
							return element.nativePath;
						});

		openFilesByPath(files);
	}

	private function openFilesByPath(paths:Array<Dynamic>):Void
	// since multi-folder-file selection is not possible
	 {

		// to open multiple projects at a time, we don't
		// need the following to be an array; also single
		// folder is suppose to have only configuration than
		// multiple
		var projectFile:FileLocation;

		for (i in paths) {
			var tmpFl:FileLocation = new FileLocation(i);
			// separate project-configuration files
			if (Lambda.indexOf(projectFileTypes, tmpFl.fileBridge.extension) != -1) {
				projectFile = tmpFl;
			}
			// open to editor any other redable files
			else {

				var tmpOpenEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpFl]);
				tmpOpenEvent.independentOpenFile = true;

				dispatcher.dispatchEvent(tmpOpenEvent);
			}
		}

		// for project-configurations
		if (projectFile != null)
		// considering file is the only configuration file
		{

			// containing to its parent folder
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, projectFile.fileBridge.parent.fileBridge.getFile)
			);
		}
	}

	public function new() {
		super();
	}

}