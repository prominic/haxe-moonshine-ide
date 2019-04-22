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
import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import mx.controls.Alert;
import mx.events.CloseEvent;
import actionScripts.events.FileCopyPasteEvent;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;

class FilesCopyPlugin extends PluginBase {

	override private function get_name():String {
		return 'FilesCopyPlugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Files Copy/Paste Plugin. Esc exits.';
	}

	private var filesToBeCopied:Array<Dynamic>;
	private var foldersOnlyToBeCopied:Array<Dynamic> = [];
	private var manchurian:String;

	override public function activate():Void {
		super.activate();

		// file copy/paste listener
		dispatcher.addEventListener(FileCopyPasteEvent.EVENT_COPY_FILE, onFileCopyRequest, false, 0, true);
		dispatcher.addEventListener(FileCopyPasteEvent.EVENT_PASTE_FILES, onPasteFilesRequest, false, 0, true);
	}

	private function onFileCopyRequest(event:FileCopyPasteEvent):Void {
		var files:Array<Dynamic> = [];
		for (fw in as3hx.Compat.each(event.wrappers)) {
			files.push(Reflect.field(Reflect.field(Reflect.field(fw, 'file'), 'fileBridge'), 'getFile'));
		}

		Clipboard.generalClipboard.setData(ClipboardFormats.FILE_LIST_FORMAT, files);
	}

	private function onPasteFilesRequest(event:FileCopyPasteEvent):Void {
		filesToBeCopied = cast AS3.asArray(Clipboard.generalClipboard.getData(ClipboardFormats.FILE_LIST_FORMAT));
		extractFoldersOnly(filesToBeCopied);

		initiateFileCopyingProcess(Reflect.getProperty(event.wrappers, Std.string(0)), AS3.as(Reflect.getProperty(event.wrappers, Std.string(0)).file.fileBridge.getFile, File));
	}

	private function extractFoldersOnly(files:Array<Dynamic>):Void {
		function generatePathPrefix(file:File):Void {
			var folderName:String = Std.string(file.name);
			manchurian = Std.string(file.nativePath.substring(0, file.nativePath.indexOf(File.separator + folderName)));
		};
		var i:Int;
		while (i < files.length) {
			if (AS3.as(Reflect.field(files[i], 'isDirectory'), Bool)) {
				if (manchurian == null) {
					generatePathPrefix(files[i]);
				}

				foldersOnlyToBeCopied.push(files.splice(i, 1)[0]);
				i--;
			}
			i++;
		} /*
		* @local
		*/

		if (manchurian == null) {
			generatePathPrefix(files[0]);
		}
	}

	private function initiateFileCopyingProcess(destinationWrapper:FileWrapper, destination:File, overwrite:Bool = false, overwriteAll:Bool = false, cancel:Bool = false):Void {
		function onFileNotification(ev:CloseEvent):Void {
			if (ev.detail == Alert.YES) {
				initiateFileCopyingProcess(destinationWrapper, destination, false, true);
			} else if (ev.detail == Alert.NO) {
				filesToBeCopied.shift();
				initiateFileCopyingProcess(destinationWrapper, destination);
			} else if (ev.detail == Alert.OK) {
				initiateFileCopyingProcess(destinationWrapper, destination, true);
			} else if (ev.detail == Alert.CANCEL) {
				resetAndNotifyCaller();
			}
		};
		var copiedFileDestination:File;
		var relativePathToCopiedFileDestination:String; /*
		* @local
		*/
		if (foldersOnlyToBeCopied.length != 0) {
			adjustDestinationFilePath(foldersOnlyToBeCopied[0]);
			if (copiedFileDestination.nativePath.indexOf(Reflect.field(foldersOnlyToBeCopied[0], 'nativePath') + File.separator) != -1) {
				// parent not permitted to copied as children
				Alert.show('Parent is not permitted to copy as children:\n' + destination.name + File.separator + relativePathToCopiedFileDestination + '\nCopy terminates.', 'Error!');
				resetAndNotifyCaller();
				return;
			} else if (!overwrite && !overwriteAll && AS3.as(copiedFileDestination.exists, Bool)) {
				setAlerts(true);
				Alert.show('Directory already exists to destination path:\n' + destination.name + File.separator + relativePathToCopiedFileDestination, 'Confirm!', Alert.YES | Alert.NO | Alert.OK | Alert.CANCEL, null, onFolderOnlyNotification);
			} else {
				// copy folder and all its contents
				(AS3.as(foldersOnlyToBeCopied[0], File)).addEventListener(Event.COMPLETE, onFileCopyingCompletes);
				(AS3.as(foldersOnlyToBeCopied[0], File)).addEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
				(AS3.as(foldersOnlyToBeCopied[0], File)).copyToAsync(copiedFileDestination, true);
			}
		} else {
			// go for folder copying
			if (filesToBeCopied.length != 0) {
				adjustDestinationFilePath(filesToBeCopied[0]);
				if (!overwrite && !overwriteAll && AS3.as(copiedFileDestination.exists, Bool)) {
					setAlerts(false);
					Alert.show('File already exists to destination path:\n' + destination.name + File.separator + relativePathToCopiedFileDestination, 'Confirm!', Alert.YES | Alert.NO | Alert.OK | Alert.CANCEL, null, onFileNotification);
				} else {
					// copy the file
					(AS3.as(filesToBeCopied[0], File)).addEventListener(Event.COMPLETE, onFileCopyingCompletes);
					(AS3.as(filesToBeCopied[0], File)).addEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
					(AS3.as(filesToBeCopied[0], File)).copyToAsync(copiedFileDestination, true);
				}

				return;
			}

			// end of the list
			resetAndNotifyCaller();
		}

		var onFolderOnlyNotification:CloseEvent->Void = function(ev:CloseEvent):Void {
			if (ev.detail == Alert.YES) {
				initiateFileCopyingProcess(destinationWrapper, destination, true);
			} else if (ev.detail == Alert.NO) {
				foldersOnlyToBeCopied.shift();
				initiateFileCopyingProcess(destinationWrapper, destination);
			} else if (ev.detail == Alert.OK) {
				(AS3.as(foldersOnlyToBeCopied[0], File)).addEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListingCompleted);
				(AS3.as(foldersOnlyToBeCopied[0], File)).getDirectoryListingAsync();
			} else if (ev.detail == Alert.CANCEL) {
				resetAndNotifyCaller();
			}
		}

		var setAlerts:Bool->Void = function(forDirectory:Bool):Void {
			Alert.buttonWidth = 90;
			Alert.noLabel = 'Skip File';
			Alert.cancelLabel = 'Cancel All';
			if (!forDirectory) {
				Alert.okLabel = 'Overwrite';
				Alert.yesLabel = 'Overwrite All';
			} else {
				Alert.okLabel = 'Check Files';
				Alert.yesLabel = 'Overwrite';
			}
		}

		var resetAndNotifyCaller:Void->Void = function():Void {
			resetFields();
			// send the completed list of file to
			// treeView to update the tree
			dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILES_FOLDERS_COPIED, null, destinationWrapper));
		}

		var adjustDestinationFilePath:File->Void = function(file:File):Void {
			relativePathToCopiedFileDestination = Std.string(file.nativePath.substring(manchurian.length + 1, file.nativePath.length));
			copiedFileDestination = destination.resolvePath(relativePathToCopiedFileDestination);
		}

		var onFileCopyingCompletes:Event->Void = function(ev:Event):Void {
			releaseListeners(ev.target);

			if (AS3.as(Reflect.field(ev.target, 'isDirectory'), Bool)) {
				foldersOnlyToBeCopied.shift();
			} else {
				filesToBeCopied.shift();
			}
			initiateFileCopyingProcess(destinationWrapper, destination, false, overwriteAll);
		}

		var onFileCopyingError:Event->Void = function(ev:Event):Void {
			releaseListeners(ev.target);
			resetFields();
		}

		var onDirectoryListingCompleted:FileListEvent->Void = function(ev:FileListEvent):Void {
			ev.target.removeEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListingCompleted);

			filesToBeCopied = ev.files;
			if (filesToBeCopied.length == 0) {
				// in case there is no files in the targeted folder
				resetFields();
				Alert.show('The folder contains no file or folder.\nProcess terminates.', 'Note!');
				return;
			}

			foldersOnlyToBeCopied.splice(0, 1);
			extractFoldersOnly(filesToBeCopied);
			initiateFileCopyingProcess(destinationWrapper, destination, false, overwriteAll);
		}

		var releaseListeners:Dynamic->Void = function(origin:Dynamic):Void {
			origin.removeEventListener(Event.COMPLETE, onFileCopyingCompletes);
			origin.removeEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
		}

		var resetFields:Void->Void = function():Void {
			manchurian = null;
			filesToBeCopied = [];
			foldersOnlyToBeCopied = [];

			Alert.buttonWidth = 65;
			Alert.yesLabel = 'Yes';
			Alert.noLabel = 'No';
			Alert.okLabel = 'OK';
			Alert.cancelLabel = 'Cancel';
		}
	}

	public function new() {
		super();
	}

}