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
package actionScripts.utils;

import haxe.Constraints.Function;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import mx.controls.Alert;
import actionScripts.extResources.deng.fzip.fzip.FZip;
import actionScripts.extResources.deng.fzip.fzip.FZipErrorEvent;
import actionScripts.extResources.deng.fzip.fzip.FZipFile;

@:meta(Event(name = 'FILE_LOAD_SUCCESS', type = 'flash.events.Event'))
@:meta(Event(name = 'FILE_LOAD_ERROR', type = 'flash.events.Event'))
class Unzip extends EventDispatcher {

	public static inline var FILE_LOAD_SUCCESS:String = 'fileLoadSuccess';
	public static inline var FILE_LOAD_ERROR:String = 'fileLoadError';

	private var fZip:FZip;
	private var loader:Loader;
	private var filesUnzippedCount:Int = 0;

	private var _filesCount:Int = 0;

	public var filesCount(get, never):Int;
	private function get_filesCount():Int {
		return _filesCount;
	}

	public function new(zipFile:File) {
		super();
		// @NOTE
		// Since load method as provided by the FZip
		// fails on macOS for some reason, we need
		// manual handling to loads its bytes data
		FileUtils.readFromFileAsync(zipFile, FileUtils.DATA_FORMAT_BYTEARRAY, onReadCompletes, onReadIOError);
	}

	private function onReadCompletes(value:ByteArray):Void {
		fZip = new FZip();
		fZip.loadBytes(value);

		_filesCount = fZip.getFileCount();
		dispatchEvent(new Event(FILE_LOAD_SUCCESS));
	}

	private function onReadIOError(value:String):Void {
		dispatchEvent(new Event(FILE_LOAD_ERROR));
	}

	public function getFileAt(index:Int):FZipFile {
		if (fZip != null && (index < filesCount)) {
			return fZip.getFileAt(index);
		}
		return null;
	}

	public function getFilesList():Array<Dynamic> {
		if (fZip != null) {
			var filesList:Array<Dynamic> = [];
			for (i in 0...filesCount) {
				filesList.push(fZip.getFileAt(i));
			}
			return filesList;
		}

		return null;
	}

	public function getFileByName(fileName:String):FZipFile {
		if (fZip != null) {
			var fzipFile:FZipFile;
			for (i in 0...filesCount) {
				fzipFile = (AS3.as(fZip.getFileAt(i), FZipFile));
				if (fzipFile.filename == fileName) {
					return fzipFile;
				}
			}
		}

		return null;
	}

	public function getFilesByExtension(extensionName:String):Array<Dynamic> {
		if (fZip != null) {
			var filesList:Array<Dynamic> = [];
			var fzipFile:FZipFile;
			for (i in 0...filesCount) {
				fzipFile = (AS3.as(fZip.getFileAt(i), FZipFile));
				if (!AS3.as(fzipFile.isDirectory, Bool)) {
					if (fzipFile.extension == extensionName) {
						filesList.push(fzipFile);
					}
				}
			}
			return filesList;
		}

		return null;
	}

	public function unzipTo(destination:File, onCompletion:Function = null):Void {
		function onSuccessWrite():Void {
			filesUnzippedCount++;
			unzipTo(destination, cast onCompletion);
		};
		if (fZip == null || !AS3.as(destination.exists, Bool)) {
			return;
		}

		var fzipFile:FZipFile;
		var bytes:ByteArray;
		var toFile:File;
		var fs:FileStream; /*
		 * @local
		 */
		if (filesUnzippedCount < filesCount) {
			fzipFile = (AS3.as(fZip.getFileAt(filesUnzippedCount), FZipFile));
			toFile = destination.resolvePath(fzipFile.filename);
			if (AS3.as(fzipFile.isDirectory, Bool)) {
				toFile.createDirectory();
				onSuccessWrite();
			} else {
				FileUtils.writeToFileAsync(toFile, fzipFile.content, onSuccessWrite, onErrorWrite);
			}
		} else if (onCompletion != null) {
			filesUnzippedCount = 0;
			onCompletion(destination);
		}
		var onErrorWrite:String->Void = function(value:String):Void {
			filesUnzippedCount = 0;
		}
	}

	private function addListeners(isAdd:Bool):Void {
		if (isAdd) {
			fZip.addEventListener(Event.COMPLETE, onFzipFileLoaded);
			fZip.addEventListener(FZipErrorEvent.PARSE_ERROR, onFzipParserError);
			fZip.addEventListener(IOErrorEvent.IO_ERROR, onFzipIOError);
		} else {
			fZip.removeEventListener(Event.COMPLETE, onFzipFileLoaded);
			fZip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onFzipParserError);
			fZip.removeEventListener(IOErrorEvent.IO_ERROR, onFzipIOError);
		}
	}

	private function onFzipFileLoaded(event:Event):Void {
		addListeners(false);
		_filesCount = fZip.getFileCount();
		dispatchEvent(new Event(FILE_LOAD_SUCCESS));
	}

	private function onFzipParserError(event:FZipErrorEvent):Void {
		// in zip error cases
		Alert.show('Unable to load zip file:\n' + event.text, 'Error');
		addListeners(false);
		dispatchEvent(new Event(FILE_LOAD_ERROR));
	}

	private function onFzipIOError(event:IOErrorEvent):Void {
		// in file/read error cases
		Alert.show('Unable to load zip file:\n' + event.text, 'Error');
		addListeners(false);
		dispatchEvent(new Event(FILE_LOAD_ERROR));
	}

}