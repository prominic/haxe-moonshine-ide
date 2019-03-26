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

/**
 * Class for isNewerFunction
 */
@:final class ClassForIsNewerFunction {

	import flash.events.ErrorEvent;
	import flash.events.Event;

	import mx.controls.Alert;

	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	// [Bindable] protected var downlaoding:Boolean = false;
	// [Bindable] protected var isUpdater:Boolean;
	private function isNewerFunction(currentVersion:String, updateVersion:String):Bool
	// Example of custom isNewerFunction function, it can be omitted if one doesn't want
	 {

		// to implement it's own version comparison logic. Be default it does simple string
		// comparison.
		return true;
	}

	public function new() {}

}

/**
 * Class for updater_errorHandler
 */
@:final class ClassForUpdaterErrorHandler {

	private function updater_errorHandler(event:ErrorEvent):Void {
		Alert.show(event.text);
	}

	public function new() {}

}

/**
 * Class for updater_initializedHandler
 */
@:final class ClassForUpdaterInitializedHandler {

	private function updater_initializedHandler(event:UpdateEvent):Void
	// When NativeApplicationUpdater is initialized you can call checkNow function
	 {

		updater.checkNow();
	}

	public function new() {}

}

/**
 * Class for updater_updateStatusHandler
 */
@:final class ClassForUpdaterUpdateStatusHandler {

	private function updater_updateStatusHandler(event:StatusUpdateEvent):Void {
		if (event.available)
		// In case update is available prevent default behavior of checkNow() function
		{

			// and switch to the view that gives the user ability to decide if he wants to
			// install new version of the application.
			event.preventDefault();
			//currentState = "Update";
			isUpdater = true;
		} else { //Alert.show("Your application is up to date!");

		}
	}

	public function new() {}

}

/**
 * Class for btnNo_clickHandler
 */
@:final class ClassForBtnNoClickHandler {

	private function btnNo_clickHandler(event:Event):Void {
		isUpdater = false;
	}

	public function new() {}

}

/**
 * Class for btnCancel_clickHandler
 */
@:final class ClassForBtnCancelClickHandler {

	private function btnCancel_clickHandler(event:Event):Void {
		updater.cancelUpdate();
		isUpdater = false;
	}

	public function new() {}

}

/**
 * Class for btnYes_clickHandler
 */
@:final class ClassForBtnYesClickHandler {

	private function btnYes_clickHandler(event:Event):Void
	// In case user wants to download and install update display download progress bar
	 {

		// and invoke downloadUpdate() function.
		downlaoding = true;
		updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
		updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
		updater.downloadUpdate();
	}

	public function new() {}

}

/**
 * Class for updater_downloadCompleteHandler
 */
@:final class ClassForUpdaterDownloadCompleteHandler {

	private function updater_downloadCompleteHandler(event:UpdateEvent):Void
	// When update is downloaded install it.
	 {

		updater.installUpdate();
	}

	public function new() {}

}

/**
 * Class for updater_downloadErrorHandler
 */
@:final class ClassForUpdaterDownloadErrorHandler {

	private function updater_downloadErrorHandler(event:DownloadErrorEvent):Void {
		Alert.show('Error downloading update file, try again later.');
	}

	public function new() {}

}