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

import flash.errors.Error;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import mx.controls.Alert;
import actionScripts.events.GeneralEvent;
import actionScripts.extResources.riaspace.nativeApplicationUpdater.UpdaterErrorCodes;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.HelperConstants;
import air.update.events.DownloadErrorEvent;
import air.update.events.UpdateEvent;

class MSDKIdownloadUtil extends EventDispatcher {

	private var downloadingFile:File;
	private var fileStream:FileStream;
	private var urlStream:URLStream;
	private var isDownloading:Bool = false;
	private var isUpdateChecking:Bool = false;
	private var isUpdateChecked:Bool = false;
	private var updateDescriptorLoader:URLLoader;

	private var _executableFile:File;

	private var executableFile(get, never):File;
	private function get_executableFile():File {
		if (_executableFile == null) {
			_executableFile = (new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY)).resolvePath('Moonshine SDK Installer.exe');
		}
		return _executableFile;
	}

	private static var instance:MSDKIdownloadUtil;

	public static function getInstance():MSDKIdownloadUtil {
		if (instance == null) {
			instance = new MSDKIdownloadUtil();
		}
		return instance;
	}

	public function is64BitSDKInstallerExists():Bool {
		return AS3.as(executableFile.exists, Bool);
	}

	public function runOrDownloadSDKInstaller():Void {
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			runAppStoreHelperOSX();
		} else if (!AS3.as(executableFile.exists, Bool)) {
			// prevent multi-execution
			if (isDownloading) {
				return;
			}
			initiate64BitDownloadProcess();
		} else if (!isUpdateChecking && !isDownloading) {
			// make sure we does this check once
			// in an application lifecycle
			if (!isUpdateChecked) {
				isUpdateChecking = true;
				checkForUpdates();
			} else {
				runAppStoreHelperWindows();
			}
		}
	}

	private function checkForUpdates():Void {
		if (updateDescriptorLoader != null) {
			return;
		}

		updateDescriptorLoader = new URLLoader();
		updateDescriptorLoader.addEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
		updateDescriptorLoader.addEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
		try {
			updateDescriptorLoader.load(new URLRequest(Std.string(HelperConstants.INSTALLER_UPDATE_CHECK_URL)));
		} catch (error:Error) {
			runAppStoreHelperWindows();
		}
	}

	private function runAppStoreHelperOSX():Void {
		var arg:Array<String> = new Array<String>();
		var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		npInfo.executable = File.documentsDirectory.resolvePath('/bin/bash');

		if (AS3.as(HelperConstants.IS_MACOS, Bool)) {
			var scriptFile:File = File.applicationDirectory.resolvePath('macOScripts/SendToASH.sh');
			var pattern:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('( )', 'g'));
			var shPath:String = Std.string(scriptFile.nativePath.replace(pattern, '\\ '));

			arg.push('-c');
			arg.push(shPath);
		}

		npInfo.arguments = arg;
		var process:NativeProcess = new NativeProcess();
		process.start(npInfo);
	}

	private function runAppStoreHelperWindows():Void {
		var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		npInfo.executable = executableFile;
		npInfo.arguments = new Array<String>();
		var process:NativeProcess = new NativeProcess();
		process.start(npInfo);
	}

	private function initiate64BitDownloadProcess(downloadUrl:String = null):Void {
		downloadUrl = Std.string((downloadUrl != null) ? downloadUrl : Std.string(HelperConstants.WINDOWS_64BIT_DOWNLOAD_URL));

		var fileName:String = downloadUrl.substr(downloadUrl.lastIndexOf('/') + 1);
		downloadingFile = new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY);
		if (!AS3.as(downloadingFile.exists, Bool)) {
			downloadingFile.createDirectory();
		}
		downloadingFile = downloadingFile.resolvePath(fileName);

		fileStream = new FileStream();
		fileStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
		fileStream.addEventListener(Event.CLOSE, fileStream_closeHandler);
		fileStream.openAsync(downloadingFile, FileMode.WRITE);

		urlStream = new URLStream();
		urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
		urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
		urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
		urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);

		try {
			urlStream.load(new URLRequest(downloadUrl));
			isDownloading = true;
		} catch (error:Error) {
			dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false,
					'Error downloading update file: ' + error.message, UpdaterErrorCodes.ERROR_9004, error.message));
		}
	}

	private function unzipDownloadedFile():Void {
		function onFileLoadedInMemory(event:Event):Void {
			event.target.removeEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
			unZip.unzipTo(new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY), onUnzipCompleted);
		};
		var unZip:Unzip = new Unzip(downloadingFile); /*
		* @local
		*/
		unZip.addEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
		var onUnzipCompleted:File->Void = function(destination:File):Void {
			dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
			runAppStoreHelperWindows();
			try {
				downloadingFile.deleteFile();
			} catch (e:Error) {
				downloadingFile.deleteFileAsync();
			}
		}
	}

	private function isNewerVersionFunction(updateVersion:String, currentVersion:String):Bool {
		var tmpSplit:Array<String> = updateVersion.split('.');
		var uv1:Float = as3hx.Compat.parseFloat(tmpSplit[0]);
		var uv2:Float = as3hx.Compat.parseFloat(tmpSplit[1]);
		var uv3:Float = as3hx.Compat.parseFloat(tmpSplit[2]);

		var tmpSplit2:Array<String> = currentVersion.split('.');
		var cv1:Float = as3hx.Compat.parseFloat(tmpSplit2[0]);
		var cv2:Float = as3hx.Compat.parseFloat(tmpSplit2[1]);
		var cv3:Float = as3hx.Compat.parseFloat(tmpSplit2[2]);

		if (uv1 > cv1) {
			return true;
		} else if (uv1 >= cv1 && uv2 > cv2) {
			return true;
		} else if (uv1 >= cv1 && uv2 >= cv2 && uv3 > cv3) {
			return true;
		}

		return false;
	}

	private function urlStream_ioErrorHandler(event:IOErrorEvent):Void {
		fileStream.removeEventListener(Event.CLOSE, fileStream_closeHandler);
		fileStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
		fileStream.close();

		urlStream.removeEventListener(Event.OPEN, urlStream_openHandler);
		urlStream.removeEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
		urlStream.removeEventListener(Event.COMPLETE, urlStream_completeHandler);
		urlStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
		urlStream.close();

		isDownloading = false;
		dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false,
				'Error downloading update file: ' + event.text, UpdaterErrorCodes.ERROR_9005, event.errorID));
	}

	private function fileStream_closeHandler(event:Event):Void {
		fileStream.removeEventListener(Event.CLOSE, fileStream_closeHandler);
		fileStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);

		isDownloading = false;
		unzipDownloadedFile();
	}

	private function urlStream_openHandler(event:Event):Void {
		dispatchEvent(new UpdateEvent(UpdateEvent.DOWNLOAD_START));
	}

	private function urlStream_progressHandler(event:ProgressEvent):Void {
		var bytes:ByteArray = as3hx.Compat.newByteArray();
		urlStream.readBytes(bytes);
		fileStream.writeBytes(bytes);
		dispatchEvent(event);
	}

	private function urlStream_completeHandler(event:Event):Void {
		urlStream.removeEventListener(Event.OPEN, urlStream_openHandler);
		urlStream.removeEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
		urlStream.removeEventListener(Event.COMPLETE, urlStream_completeHandler);
		urlStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
		urlStream.close();
		fileStream.close();
		isDownloading = false;
	}

	@:access(FastXML) private function updateDescriptorLoader_completeHandler(event:Event):Void {
		isUpdateChecked = true;
		isUpdateChecking = false;
		updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
		updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
		updateDescriptorLoader.close();

		// store remote information
		var updateDescriptor:FastXML = new FastXML(updateDescriptorLoader.data);
		var updateVersion:String = Std.string(updateDescriptor.nodes.exe.descendants('version'));
		var updateVersionUrl:String = Std.string(updateDescriptor.nodes.exe.descendants('url'));

		updateDescriptorLoader = null;

		// load local information
		var localDescriptor:File = new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY).resolvePath('META-INF/AIR/application.xml');
		if (!AS3.as(localDescriptor.exists, Bool)) {
			return;
		}
		var currentVersion:String;
		var applicationDescriptor:FastXML = new FastXML(FileUtils.readFromFile(localDescriptor));
		var xmlns:Namespace = new Namespace(applicationDescriptor.node.namespace());

		if (xmlns.uri == 'http://ns.adobe.com/air/application/2.1') {
			currentVersion = Std.string(applicationDescriptor.version);
		} else {
			currentVersion = Std.string(applicationDescriptor.versionNumber);
		}

		if (isNewerVersionFunction(updateVersion, currentVersion)) {
			// initiate new download
			initiate64BitDownloadProcess(updateVersionUrl);
		}// continue running existing download
		else {
			// continue running existing download
			runAppStoreHelperWindows();
		}
	}

	private function updateDescriptorLoader_ioErrorHandler(event:IOErrorEvent):Void {
		updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
		updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
		updateDescriptorLoader.close();
		updateDescriptorLoader = null;

		isUpdateChecked = true;
		isUpdateChecking = false;
		Alert.show('Error downloading Installer updater file, try again later.\n' + event.text, 'Error!');
	}

	public function new() {
		super();
	}

}