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
package actionScripts.impls;

import flash.errors.Error;import haxe.Constraints.Function;

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IFileBridge;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.ConstantsCoreVO;
import org.as3commons.asblocks.utils.FileUtil;
import actionScripts.interfaces.IScopeBookmarkInterface;
import actionScripts.utils.OSXBookmarkerNotifiers;
import flash.events.IOErrorEvent;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.events.GlobalEventDispatcher;
import mx.controls.Alert;
import actionScripts.utils.FileUtils;
import flash.utils.ByteArray;

// CONFIG::OSX
// {
// 	// ** IMPORTANT **
// 	// DO NOT DELETE THE IMPORT EVEN IF
// 	// IT'S SHOWING WARNING AS NON-USED CLASS
// 	import net.prominic.SecurityScopeBookmark.Main;
// }
/**
 * IFileBridgeImp
 *
 * @date 10.28.2015
 * @version 1.0
 */
class IFileBridgeImp implements IFileBridge {

	public var url(get, set):String;
	public var parent(get, never):FileLocation;
	public var separator(get, never):String;
	public var getFile(get, never):Dynamic;
	public var exists(get, set):Bool;
	public var icon(get, set):Dynamic;
	public var isDirectory(get, set):Bool;
	public var isHidden(get, set):Bool;
	public var isPackaged(get, set):Bool;
	public var nativePath(get, set):String;
	public var nativeURL(get, set):String;
	public var creator(get, set):String;
	public var extension(get, set):String;
	public var name(get, set):String;
	public var type(get, set):String;
	public var creationDate(get, set):Date;
	public var modificationDate(get, set):Date;
	public var data(get, set):Dynamic;
	public var nameWithoutExtension(get, never):String;

	private var _file:File = File.desktopDirectory;

	// CONFIG::OSX
	// {
	// 	private var _ssb:Main = new Main();

	// 	public function getSSBInterface():IScopeBookmarkInterface
	// 	{
	// 		return _ssb;
	// 	}
	// }
	public function getDirectoryListing():Array<Dynamic> {
		if (!checkFileExistenceAndReport()) {
			return [];
		}
		return _file.getDirectoryListing();
	}

	public function deleteFileOrDirectory():Void {}

	public function canonicalize():Void {
		_file.canonicalize();
	}

	public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function = null, startFromLocation:String = null):Void {
		setFileInternalPath(startFromLocation);

		if (ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_DEVELOPMENT_MODE) {
			var selectedPathValue:String;
			var relativePathToOpen:String = '';
			try {
				if (_file != null && exists) {
					relativePathToOpen = 'file://' + _file.nativePath;
				}
			} catch (e:Error) {}
			/* AS3HX WARNING namespace modifier CONFIG::OSX */{
				selectedPathValue = _ssb.addNewPath(relativePathToOpen, true);
			}

			if (selectedPathValue != null) {
				if (selectedPathValue == 'null') {
					if (cancelListener != null) {
						cancelListener();
					}
					return;
				}

				// update the path to bookmarked list
				var tmpArr:Array<Dynamic> = OSXBookmarkerNotifiers.availableBookmarkedPaths.split(',');
				if (Lambda.indexOf(tmpArr, selectedPathValue) == -1) {
					OSXBookmarkerNotifiers.availableBookmarkedPaths += ',' + selectedPathValue;
				}
				_file.nativePath = selectedPathValue;

				selectListner(new File(selectedPathValue));
			} else if (cancelListener != null) {
				cancelListener();
			}
		} else {
			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForDirectory(title);
		}

		/*
		 *@local
		 */
		function onSelectHandler(event:Event):Void {
			_file.nativePath = (try cast(event.target, File) catch (e:Dynamic) null).nativePath;
			onCancelHandler(event);
			selectListner(try cast(event.target, File) catch (e:Dynamic) null);
		};
		var onCancelHandler:Event->Void = function(event:Event):Void {
			event.target.removeEventListener(Event.SELECT, onSelectHandler);
			event.target.removeEventListener(Event.CANCEL, onCancelHandler);
		}
	}

	public function onSuccessDelete(value:Dynamic, message:String = null):Void {}

	public function onFault(message:String = null):Void {}

	public function createDirectory():Void {
		try {
			_file.createDirectory();
		} catch (e:Error) {
			reportPathAccessError(true);
		}
	}

	public function getRelativePath(ref:FileLocation, useDotDot:Bool = false):String {
		if (ref.fileBridge.nativePath == FileUtil.separator) {
			return ref.fileBridge.nativePath;
		}
		return _file.getRelativePath(try cast(ref.fileBridge.getFile, File) catch (e:Dynamic) null, useDotDot);
	}

	public function copyTo(value:FileLocation, overwrite:Bool = false):Void {
		_file.copyTo(try cast(value.fileBridge.getFile, File) catch (e:Dynamic) null, overwrite);
	}

	public function copyInto(locationCopyingTo:FileLocation, copyEmptyFolders:Bool = true):Void {
		var directory:Array<Dynamic> = _file.getDirectoryListing();

		for (f in directory) {
			if (f.isDirectory)
			// Copies a folder whether it is empty or not.
			{

				if (copyEmptyFolders) {
					f.copyTo(locationCopyingTo.fileBridge.getFile.resolvePath(f.name), true);
				}

				// Recurse thru folder.
				new FileLocation(f.nativePath).fileBridge.copyInto(locationCopyingTo.fileBridge.resolvePath(f.name));
			} else {
				f.copyTo(locationCopyingTo.fileBridge.getFile.resolvePath(f.name), true);
			}
		}
	}

	public function moveToTrashAsync():Void {
		_file.moveToTrashAsync();
	}

	public function load():Void {
		if (checkFileExistenceAndReport()) {
			_file.load();
		}
	}

	public function copyFileTemplate(dst:FileLocation, data:Dynamic = null):Void {
		var r:FileStream = new FileStream();
		r.open(_file, FileMode.READ);
		var content:String = r.readUTFBytes(_file.size);
		r.close();

		content = replace(content, data);

		var w:FileStream = new FileStream();
		w.open(try cast(dst.fileBridge.getFile, File) catch (e:Dynamic) null, FileMode.WRITE);
		w.writeUTFBytes(content);
		w.close();
	}

	public function createFile(forceIsDirectory:Bool = false):Void {
		FileUtil.createFile(_file, forceIsDirectory);
	}

	public function save(content:Dynamic):Void {
		var fs:FileStream = new FileStream();
		fs.open(_file, FileMode.WRITE);
		fs.writeUTFBytes(Std.string(content));
		fs.close();
	}

	public function browseForSave(selected:Function, canceled:Function = null, title:String = null, startFromLocation:String = null):Void {
		setFileInternalPath(startFromLocation);

		_file.addEventListener(Event.SELECT, onSelectHandler);
		_file.addEventListener(Event.CANCEL, onCancelHandler);
		_file.browseForSave((title != null) ? title : '');

		/*
		 *@local
		 */
		function onSelectHandler(event:Event):Void {
			_file.nativePath = (try cast(event.target, File) catch (e:Dynamic) null).nativePath;
			removeListeners(event);
			selected(try cast(event.target, File) catch (e:Dynamic) null);
		};
		var onCancelHandler:Event->Void = function(event:Event):Void {
			removeListeners(event);
			if (canceled != null) {
				canceled(event);
			}
		}
		var removeListeners:Event->Void = function(event:Event):Void {
			event.target.removeEventListener(Event.SELECT, onSelectHandler);
			event.target.removeEventListener(Event.CANCEL, onCancelHandler);
		}
	}

	public function moveTo(newLocation:FileLocation, overwrite:Bool = false):Void {
		if (checkFileExistenceAndReport()) {
			_file.moveTo(try cast(newLocation.fileBridge.getFile, File) catch (e:Dynamic) null, overwrite);
		}
	}

	public function moveToAsync(newLocation:FileLocation, overwrite:Bool = false):Void {
		if (checkFileExistenceAndReport()) {
			_file.moveToAsync(try cast(newLocation.fileBridge.getFile, File) catch (e:Dynamic) null, overwrite);
		}
	}

	public function deleteDirectory(deleteDirectoryContents:Bool = false):Void {
		try {
			_file.deleteDirectory(deleteDirectoryContents);
		} catch (e:Error) {
			deleteDirectoryAsync(deleteDirectoryContents);
		}
	}

	public function deleteDirectoryAsync(deleteDirectoryContents:Bool = false):Void {
		try {
			_file.deleteDirectoryAsync(deleteDirectoryContents);
		} catch (e:Error) {
			reportPathAccessError(true);
		}
	}

	public function resolveDocumentDirectoryPath(pathWith:String = null):FileLocation {
		if (pathWith == null) {
			return (new FileLocation(File.documentsDirectory.nativePath));
		}
		return (new FileLocation(File.documentsDirectory.resolvePath(pathWith).nativePath));
	}

	public function resolveUserDirectoryPath(pathWith:String = null):FileLocation {
		if (pathWith == null) {
			return (new FileLocation(File.userDirectory.nativePath));
		}
		return (new FileLocation(File.userDirectory.resolvePath(pathWith).nativePath));
	}

	public function resolveApplicationStorageDirectoryPath(pathWith:String = null):FileLocation {
		if (pathWith == null) {
			return (new FileLocation(File.applicationStorageDirectory.nativePath));
		}
		return (new FileLocation(File.applicationStorageDirectory.resolvePath(pathWith).nativePath));
	}

	public function resolveApplicationDirectoryPath(pathWith:String = null):FileLocation {
		if (pathWith == null) {
			return (new FileLocation(File.applicationDirectory.nativePath));
		}
		return (new FileLocation(File.applicationDirectory.resolvePath(pathWith).nativePath));
	}

	public function resolvePath(path:String, toRelativePath:String = null):FileLocation {
		var tmpFile:File = (toRelativePath != null) ? new File(toRelativePath).resolvePath(path) : _file.resolvePath(path);
		return (new FileLocation(tmpFile.nativePath));
	}

	public function read():Dynamic {
		var saveData:Dynamic;
		try {
			if (checkFileExistenceAndReport()) {
				var stream:FileStream = new FileStream();
				stream.open(_file, FileMode.READ);
				saveData = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
			}
		} catch (e:Error) {
			trace(e.getStackTrace());
		}

		return saveData;
	}

	public function readAsync(provider:Dynamic, fieldTypeReadObject:Dynamic, fieldTypeProvider:Dynamic, fieldInProvider:String = null, fieldInReadObject:String = null):Void {
		FileUtils.readFromFileAsync(_file, FileUtils.DATA_FORMAT_STRING, onReadComplete, onReadIO);

		/*
		 * @local
		 */
		function onReadComplete(value:String):Void {
			var readObj:Dynamic = fieldTypeReadObject(value);
			if (fieldInProvider != null) {
				Reflect.setField(provider, fieldInProvider, (fieldInReadObject != null) ? fieldTypeProvider(Reflect.field(readObj, fieldInReadObject)) : fieldTypeProvider(readObj));
			} else {
				provider = (fieldInReadObject != null) ? fieldTypeProvider(Reflect.field(readObj, fieldInReadObject)) : fieldTypeProvider(readObj);
			}
		};
		var onReadIO:String->Void = function(value:String):Void { //Alert.show(event.toString());

		}
	}

	public function deleteFile():Void {
		try {
			_file.deleteFile();
		} catch (e:Error) {
			deleteFileAsync();
		}
	}

	public function deleteFileAsync():Void {
		try {
			_file.deleteFileAsync();
		} catch (e:Error) {
			reportPathAccessError(false);
		}
	}

	public function browseForOpen(title:String, selectListner:Function, cancelListener:Function = null, fileFilters:Array<Dynamic> = null, startFromLocation:String = null):Void {
		setFileInternalPath(startFromLocation);

		var filters:Array<Dynamic>;
		var filtersForExt:Array<Dynamic> = [];
		if (fileFilters != null) {
			filters = [];
			//"*.as;*.mxml;*.css;*.txt;*.js;*.xml"
			for (i in fileFilters) {
				filters.push(new FileFilter('Open', i));
				var extSplit:Array<Dynamic> = i.split(';');
				for (j in extSplit) {
					filtersForExt.push(j.split('.')[1]);
				}
			}
		}

		if (ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_DEVELOPMENT_MODE) {
			var selectedPathValue:String;
			var relativePathToOpen:String = '';
			try {
				if (_file != null && exists) {
					relativePathToOpen = 'file://' + _file.nativePath;
				}
			} catch (e:Error) {}
			/* AS3HX WARNING namespace modifier CONFIG::OSX */{
				selectedPathValue = _ssb.addNewPath(relativePathToOpen, false, ((filtersForExt.length > 0)) ? filtersForExt.join(',') : '');
			}

			if (selectedPathValue != null) {
				if (selectedPathValue == 'null') {
					if (cancelListener != null) {
						cancelListener();
					}
					return;
				}

				_file.nativePath = selectedPathValue;
				selectListner(new File(selectedPathValue));
			} else if (cancelListener != null) {
				cancelListener();
			}
		} else {
			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForOpen(title, filters);
		}

		/*
		*@local
		*/
		function onSelectHandler(event:Event):Void {
			_file.nativePath = (try cast(event.target, File) catch (e:Dynamic) null).nativePath;
			onCancelHandler(event);
			selectListner(try cast(event.target, File) catch (e:Dynamic) null);
		};
		var onCancelHandler:Event->Void = function(event:Event):Void {
			event.target.removeEventListener(Event.SELECT, onSelectHandler);
			event.target.removeEventListener(Event.CANCEL, onCancelHandler);
		}
	}

	public function openWithDefaultApplication():Void {
		if (checkFileExistenceAndReport()) {
			_file.openWithDefaultApplication();
		}
	}

	private function get_url():String {
		return _file.url;
	}

	private function set_url(value:String):String {
		_file.url = value;
		return value;
	}

	private function get_parent():FileLocation {
		return (new FileLocation(_file.parent.nativePath));
	}

	private function get_separator():String {
		return File.separator;
	}

	private function get_getFile():Dynamic {
		return _file;
	}

	private function get_exists():Bool {
		try {
			return _file.exists;
		} catch (e:Error) {}

		return false;
	}

	private function set_exists(value:Bool):Bool {
		return value;
	}

	private function get_icon():Dynamic {
		return _file.icon;
	}

	private function set_icon(value:Dynamic):Dynamic {
		return value;
	}

	private function get_isDirectory():Bool {
		return _file.isDirectory;
	}

	private function set_isDirectory(value:Bool):Bool {
		return value;
	}

	private function get_isHidden():Bool {
		return _file.isHidden;
	}

	private function set_isHidden(value:Bool):Bool {
		return value;
	}

	private function get_isPackaged():Bool {
		return _file.isPackage;
	}

	private function set_isPackaged(value:Bool):Bool {
		return value;
	}

	private function get_nativePath():String {
		return _file.nativePath;
	}

	private function set_nativePath(value:String):String {
		try {
			if (checkFileExistenceAndReport()) {
				_file.nativePath = value;
			}
		} catch (e:Error) {
			trace(value + ': ' + e.message);
		}
		return value;
	}

	private function get_nativeURL():String {
		return _file.nativePath;
	}

	private function set_nativeURL(value:String):String {
		return value;
	}

	private function get_creator():String {
		return _file.creator;
	}

	private function set_creator(value:String):String {
		return value;
	}

	private function get_extension():String {
		return _file.extension;
	}

	private function set_extension(value:String):String {
		return value;
	}

	private function get_name():String {
		return _file.name;
	}

	private function set_name(value:String):String {
		return value;
	}

	private function get_type():String {
		return _file.type;
	}

	private function set_type(value:String):String {
		return value;
	}

	private function get_creationDate():Date {
		if (_file != null && _file.exists) {
			return _file.creationDate;
		}
		return (Date.now());
	}

	private function set_creationDate(value:Date):Date {
		return value;
	}

	private function get_modificationDate():Date {
		if (_file != null && _file.exists) {
			_file.modificationDate;
		}
		return null;
	}

	private function set_modificationDate(value:Date):Date {
		return value;
	}

	private function get_data():Dynamic {
		return _file.data;
	}

	private function set_data(value:Dynamic):Dynamic {
		return value;
	}

	private function get_nameWithoutExtension():String {
		var extensionIndex:Int = this.name.lastIndexOf(extension);
		if (extensionIndex > -1) {
			return this.name.substring(0, extensionIndex - 1);
		}

		return null;
	}

	public function checkFileExistenceAndReport():Bool
	// we want to keep this method separate from
	 {

		// 'exists' and not add these alerts to the
		// said method, because file.exists uses against many
		// internal checks which are not intentional to throw an alert
		if (!_file.exists) {
			Alert.show(_file.name + ' does not exist on the filesystem.\nOperation canceled.', 'Error!');
			reportPathAccessError(_file.isDirectory, false);
			return false;
		}

		return true;
	}

	public static function replace(content:String, data:Dynamic):String {
		for (key in Reflect.fields(data)) {
			var re:as3hx.Compat.Regex = new as3hx.Compat.Regex(TextUtil.escapeRegex(key), 'g');
			content = re.replace(content, Reflect.field(data, key));
		}

		return content;
	}

	private function reportPathAccessError(isDirectory:Bool, isExists:Bool = true):Void {
		var errorMessage:String = '\nUnable to access ' + ((isDirectory) ? 'directory:' : 'file:') + _file.nativePath;
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			if (isDirectory && isExists) {
				errorMessage += '\nPlease open File > Access Manager and click "Add Access" to to allow access to this directory.';
			}
		}

		GlobalEventDispatcher.getInstance().dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, errorMessage, false, false, ConsoleOutputEvent.TYPE_ERROR)
		);
	}

	private function setFileInternalPath(startFromLocation:String):Void
	// set file path if requires
	 {

		try {
			var pathExists:File = new File(startFromLocation);
			if (startFromLocation != null && pathExists.exists) {
				_file.nativePath = startFromLocation;
			}
		} catch (e:Error) {}
	}

	public function new() {}

}