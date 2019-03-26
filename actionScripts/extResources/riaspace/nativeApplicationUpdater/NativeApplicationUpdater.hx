package actionScripts.extResources.riaspace.nativeApplicationUpdater;

import flash.errors.Error;import haxe.Constraints.Function;

import flash.desktop.NativeApplication;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.ErrorEvent;
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
import flash.system.Capabilities;
import flash.utils.ByteArray;
import mx.controls.Alert;
import actionScripts.extResources.riaspace.nativeApplicationUpdater.utils.HdiutilHelper;
import air.update.events.DownloadErrorEvent;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.StatusUpdateEvent;
import air.update.events.UpdateEvent;

@:meta(Event(name = 'initialized', type = 'air.update.events.UpdateEvent'))

@:meta(Event(name = 'checkForUpdate', type = 'air.update.events.UpdateEvent'))

@:meta(Event(name = 'updateStatus', type = 'air.update.events.StatusUpdateEvent'))

@:meta(Event(name = 'updateError', type = 'air.update.events.StatusUpdateErrorEvent'))

@:meta(Event(name = 'downloadStart', type = 'air.update.events.UpdateEvent'))

@:meta(Event(name = 'downloadError', type = 'air.update.events.DownloadErrorEvent'))

@:meta(Event(name = 'downloadComplete', type = 'air.update.events.UpdateEvent'))

@:meta(Event(name = 'progress', type = 'flash.events.ProgressEvent'))

@:meta(Event(name = 'error', type = 'flash.events.ErrorEvent'))
class NativeApplicationUpdater extends EventDispatcher {

	public var currentVersion(get, set):String;
	public var updateVersion(get, set):String;
	public var updateDescriptor(get, set):FastXML;
	public var currentState(get, set):String;
	public var downloadedFile(get, set):File;
	public var isNewerVersionFunction(get, set):Function;
	public var installerType(get, set):String;
	public var updatePackageURL(get, set):String;
	public var updateDescription(get, set):String;

	/**
	 * The updater has not been initialized.
	 **/
	public static inline var UNINITIALIZED:String = 'UNINITIALIZED';

	/**
	 * The updater is initializing.
	 **/
	public static inline var INITIALIZING:String = 'INITIALIZING';

	/**
	 * The updater has been initialized.
	 **/
	public static inline var READY:String = 'READY';

	/**
	 * The updater has not yet checked for the update descriptor file.
	 **/
	public static inline var BEFORE_CHECKING:String = 'BEFORE_CHECKING';

	/**
	 * The updater is checking for an update descriptor file.
	 **/
	public static inline var CHECKING:String = 'CHECKING';

	/**
	 * The update descriptor file is available.
	 **/
	public static inline var AVAILABLE:String = 'AVAILABLE';

	/**
	 * The updater is downloading the AIR file.
	 **/
	public static inline var DOWNLOADING:String = 'DOWNLOADING';

	/**
	 * The updater has downloaded the AIR file.
	 **/
	public static inline var DOWNLOADED:String = 'DOWNLOADED';

	/**
	 * The updater is installing the AIR file.
	 **/
	public static inline var INSTALLING:String = 'INSTALLING';

	@:meta(Bindable())
public var updateURL:String;

	private var _isNewerVersionFunction:Function;

	private var _updateDescriptor:FastXML;

	private var _updateVersion:String;

	private var _updatePackageURL:String;

	private var _updateDescription:String;

	private var _currentVersion:String;

	private var _downloadedFile:File;

	private var _installerType:String;

	private var _currentState:String = UNINITIALIZED;

	private var _currentMajor:Int = -1;

	private var _currentMinor:Int = -1;

	private var _currentRevision:Int = -1;

	private var updateDescriptorLoader:URLLoader;

	private var os:String = Capabilities.os.toLowerCase();

	private var urlStream:URLStream;

	private var fileStream:FileStream;

	private var hideAlert:Bool;

	public function new() {
		super();
	}

	public function initialize(_hideAlert:Bool = true):Void
	/*if (currentState == UNINITIALIZED)
			{*/
	 {

		hideAlert = _hideAlert;
		currentState = INITIALIZING;

		var applicationDescriptor:FastXML = NativeApplication.nativeApplication.applicationDescriptor;
		var xmlns:Namespace = new Namespace(applicationDescriptor.node.namespace.innerData());

		if (xmlns.uri == 'http://ns.adobe.com/air/application/2.1') {
			currentVersion = applicationDescriptor.node.xmlns::version.innerData;
		} else {
			currentVersion = applicationDescriptor.node.xmlns::versionNumber.innerData;
		}

		if (os.indexOf('win') > -1) {
			installerType = 'exe';
		} else if (os.indexOf('mac') > -1) {
			installerType = 'dmg';
		} else if (os.indexOf('linux') > -1) {
			if ((new File('/usr/bin/dpkg')).exists) {
				installerType = 'deb';
			} else {
				installerType = 'rpm';
			}
		} else {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, 'Not supported os type!', UpdaterErrorCodes.ERROR_9000));
		}

		currentState = READY;
		dispatchEvent(new UpdateEvent(UpdateEvent.INITIALIZED));
	}

	public function checkNow():Void {
		if (currentState == READY) {
			currentState = BEFORE_CHECKING;

			var checkForUpdateEvent:UpdateEvent = new UpdateEvent(UpdateEvent.CHECK_FOR_UPDATE, false, true);
			dispatchEvent(checkForUpdateEvent);

			if (!checkForUpdateEvent.isDefaultPrevented()) {
				addEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus, false, 0, true);
				addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadCompleted, false, 0, true);

				checkForUpdate();
			}
		}
	}

	private function onUpdateStatus(event:StatusUpdateEvent):Void {
		if (event.available && !event.isDefaultPrevented()) {
			downloadUpdate();
		} else if (!event.isDefaultPrevented() && !hideAlert) {
			Alert.show('No new updates available.', 'NOTE!');
		}
	}

	private function onDownloadCompleted(event:UpdateEvent):Void {
		if (!event.isDefaultPrevented()) {
			installUpdate();
		}
	}

	/**
	 * ------------------------------------ CHECK FOR UPDATE SECTION -------------------------------------
	 */

	/**
	 * Checks for update, this can be runned only in situation when UpdateEvent.CHECK_FOR_UPDATE was cancelled.
	 */
	public function checkForUpdate():Void {
		if (currentState == BEFORE_CHECKING) {
			currentState = CHECKING;

			updateDescriptorLoader = new URLLoader();
			updateDescriptorLoader.addEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
			updateDescriptorLoader.addEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
			try {
				updateDescriptorLoader.load(new URLRequest(updateURL));
			} catch (error:Error) {
				dispatchEvent(new StatusUpdateErrorEvent(StatusUpdateErrorEvent.UPDATE_ERROR, false, false,
						'Error downloading update descriptor file: ' + error.message,
						UpdaterErrorCodes.ERROR_9002, error.errorID));
			}
		}
	}

	/**
	 * Cancel an open updation process
	 */
	public function cancelUpdate():Void {
		if (currentState == DOWNLOADING) {
			urlStream_completeHandler(null);
		}
	}

	private function updateDescriptorLoader_completeHandler(event:Event):Void {
		updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
		updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
		updateDescriptorLoader.close();

		updateDescriptor = new FastXML(updateDescriptorLoader.data);

		if (updateDescriptor.node.namespace.innerData() == UPDATE_XMLNS_1_0) { // updateVersion = updateDescriptor.UPDATE_XMLNS_1_0::version;
			// updateDescription = updateDescriptor.UPDATE_XMLNS_1_0::description;
			// updatePackageURL = updateDescriptor.UPDATE_XMLNS_1_0::urls.UPDATE_XMLNS_1_1::[installerType];

		} else { // var typeXml:XMLList = updateDescriptor.UPDATE_XMLNS_1_1::[installerType];
			// if (typeXml.length() > 0)
			// {
			// 	updateVersion = typeXml.UPDATE_XMLNS_1_1::version;
			// 	updateDescription = typeXml.UPDATE_XMLNS_1_1::description;
			// 	updatePackageURL = typeXml.UPDATE_XMLNS_1_1::url;
			// }

		}

		if (updateVersion == null || updatePackageURL == null) {
			dispatchEvent(new StatusUpdateErrorEvent(StatusUpdateErrorEvent.UPDATE_ERROR, false, false,
					'Update package is not defined for current installerType: ' + installerType, UpdaterErrorCodes.ERROR_9001));
			return;
		}

		currentState = AVAILABLE;
		dispatchEvent(new StatusUpdateEvent(
				StatusUpdateEvent.UPDATE_STATUS, false, true,
				Reflect.callMethod(null, isNewerVersionFunction, [currentVersion, updateVersion]), updateVersion));
	}

	private function updateDescriptorLoader_ioErrorHandler(event:IOErrorEvent):Void {
		updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
		updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
		updateDescriptorLoader.close();

		dispatchEvent(new StatusUpdateErrorEvent(StatusUpdateErrorEvent.UPDATE_ERROR, false, false,
				'Error downloading updater file, try again later.',
				UpdaterErrorCodes.ERROR_9003, event.errorID));
	}

	/**
	 * ------------------------------------ DOWNLOAD UPDATE SECTION -------------------------------------
	 */

	/**
	 * Starts downloading update.
	 */
	public function downloadUpdate():Void {
		if (currentState == AVAILABLE) {
			var fileName:String = updatePackageURL.substr(updatePackageURL.lastIndexOf('/') + 1);
			downloadedFile = File.createTempDirectory().resolvePath(fileName);

			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			fileStream.addEventListener(Event.CLOSE, fileStream_closeHandler);
			fileStream.openAsync(downloadedFile, FileMode.WRITE);

			urlStream = new URLStream();
			urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);

			try {
				urlStream.load(new URLRequest(updatePackageURL));
			} catch (error:Error) {
				dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false,
						'Error downloading update file: ' + error.message, UpdaterErrorCodes.ERROR_9004, error.message));
			}
		}
	}

	private function urlStream_openHandler(event:Event):Void {
		currentState = NativeApplicationUpdater.DOWNLOADING;
		dispatchEvent(new UpdateEvent(UpdateEvent.DOWNLOAD_START));
	}

	private function fileStream_closeHandler(event:Event):Void {
		fileStream.removeEventListener(Event.CLOSE, fileStream_closeHandler);
		fileStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);

		currentState = NativeApplicationUpdater.DOWNLOADED;
		dispatchEvent(new UpdateEvent(UpdateEvent.DOWNLOAD_COMPLETE, false, true));
	}

	private function urlStream_progressHandler(event:ProgressEvent):Void {
		var bytes:ByteArray = new ByteArray();
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

		dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false,
				'Error downloading update file: ' + event.text, UpdaterErrorCodes.ERROR_9005, event.errorID));
	}

	/**
	 * ------------------------------------ INSTALL UPDATE SECTION -------------------------------------
	 */

	/**
	 * Installs downloaded update
	 */
	public function installUpdate():Void {
		if (currentState == DOWNLOADED) {
			installFromFile(downloadedFile);
		}
	}

	private function hdiutilHelper_errorHandler(event:ErrorEvent):Void {
		var hdiutilHelper:HdiutilHelper = try cast(event.target, HdiutilHelper) catch (e:Dynamic) null;
		hdiutilHelper.removeEventListener(Event.COMPLETE, hdiutilHelper_completeHandler);
		hdiutilHelper.removeEventListener(ErrorEvent.ERROR, hdiutilHelper_errorHandler);

		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false,
				'Error attaching dmg file!', UpdaterErrorCodes.ERROR_9008));
	}

	private function hdiutilHelper_completeHandler(event:Event):Void {
		var hdiutilHelper:HdiutilHelper = try cast(event.target, HdiutilHelper) catch (e:Dynamic) null;
		hdiutilHelper.removeEventListener(Event.COMPLETE, hdiutilHelper_completeHandler);
		hdiutilHelper.removeEventListener(ErrorEvent.ERROR, hdiutilHelper_errorHandler);

		var attachedDmg:File = new File(hdiutilHelper.mountPoint);
		var files:Array<Dynamic> = attachedDmg.getDirectoryListing();

		if (files.length == 1) {
			var installFileFolder:File = cast((files[0]), File).resolvePath('Contents/MacOS');
			var installFiles:Array<Dynamic> = installFileFolder.getDirectoryListing();

			if (installFiles.length == 1) {
				installFromFile(installFiles[0]);
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false,
						'Contents/MacOS folder should contain only 1 install file!', UpdaterErrorCodes.ERROR_9006));
			}
		} else {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false,
					'Mounted volume should contain only 1 install file!', UpdaterErrorCodes.ERROR_9007));
		}
	}

	private function installFromFile(updateFile:File):Void {
		var beforeInstallEvent:UpdateEvent = new UpdateEvent(UpdateEvent.BEFORE_INSTALL, false, true);
		dispatchEvent(beforeInstallEvent);

		if (!beforeInstallEvent.isDefaultPrevented()) {
			currentState = INSTALLING;

			if (os.indexOf('win') == -1) {
				updateFile.openWithDefaultApplication();
			} else {
				var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var cmdExe:File = ((os.indexOf('win') > -1)) ? new File('C:\\Windows\\System32\\cmd.exe') : null;
				if (cmdExe != null && cmdExe.exists) {
					var args:Array<String> = new Array<String>();
					args.push('/c');
					args.push(updateFile.nativePath);

					info.executable = cmdExe;
					info.arguments = args;
				} else {
					info.executable = updateFile;
				}

				var installProcess:NativeProcess = new NativeProcess();
				installProcess.start(info);
			}

			as3hx.Compat.setTimeout(NativeApplication.nativeApplication.exit, 200);
		}
	}

	@:meta(Bindable())
private function get_currentVersion():String {
		return _currentVersion;
	}

	private function set_currentVersion(value:String):String {
		_currentVersion = value;

		// split the value to three
		var tmpArr:Array<Dynamic> = value.split('.');
		if (tmpArr.length == 3) {
			_currentMajor = as3hx.Compat.parseInt(tmpArr[0]);
			_currentMinor = as3hx.Compat.parseInt(tmpArr[1]);
			_currentRevision = as3hx.Compat.parseInt(tmpArr[2]);
		}
		return value;
	}

	@:meta(Bindable())
private function get_updateVersion():String {
		return _updateVersion;
	}

	private function set_updateVersion(value:String):String {
		_updateVersion = value;
		return value;
	}

	@:meta(Bindable())
private function get_updateDescriptor():FastXML {
		return _updateDescriptor;
	}

	private function set_updateDescriptor(value:FastXML):FastXML {
		_updateDescriptor = value;
		return value;
	}

	@:meta(Bindable())
private function get_currentState():String {
		return _currentState;
	}

	private function set_currentState(value:String):String {
		_currentState = value;
		return value;
	}

	@:meta(Bindable())
private function get_downloadedFile():File {
		return _downloadedFile;
	}

	private function set_downloadedFile(value:File):File {
		_downloadedFile = value;
		return value;
	}

	@:meta(Bindable())
private function get_isNewerVersionFunction():Function {
		if (_isNewerVersionFunction != null) {
			return _isNewerVersionFunction;
		} else {
			return function(currentVersion:String, updateVersion:String):Bool {
				var tmpSplit:Array<Dynamic> = updateVersion.split('.');
				var uv1:Float = as3hx.Compat.parseFloat(tmpSplit[0]);
				var uv2:Float = as3hx.Compat.parseFloat(tmpSplit[1]);
				var uv3:Float = as3hx.Compat.parseFloat(tmpSplit[2]);

				if (uv1 > _currentMajor) {
					return true;
				} else if (uv1 >= _currentMajor && uv2 > _currentMinor) {
					return true;
				} else if (uv1 >= _currentMajor && uv2 >= _currentMinor && uv3 > _currentRevision) {
					return true;
				}

				return false;
			};
		}
	}

	private function set_isNewerVersionFunction(value:Function):Function {
		_isNewerVersionFunction = value;
		return value;
	}

	@:meta(Bindable())
private function get_installerType():String {
		return _installerType;
	}

	private function set_installerType(value:String):String {
		_installerType = value;
		return value;
	}

	@:meta(Bindable())
private function get_updatePackageURL():String {
		return _updatePackageURL;
	}

	private function set_updatePackageURL(value:String):String {
		_updatePackageURL = value;
		return value;
	}

	@:meta(Bindable())
private function get_updateDescription():String {
		return _updateDescription;
	}

	private function set_updateDescription(value:String):String {
		_updateDescription = value;
		return value;
	}

	private static var NativeApplicationUpdater_static_initializer = {
		namespace;
		UPDATE_XMLNS_1_0 = 'http://ns.riaspace.com/air/framework/update/description/1.0';
		namespace;
		UPDATE_XMLNS_1_1 = 'http://ns.riaspace.com/air/framework/update/description/1.1';
		true;
	}

}