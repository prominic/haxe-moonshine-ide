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
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import flash.utils.Timer;
import mx.controls.Alert;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.SDKReferenceVO;
import actionScripts.valueObjects.SDKTypes;

class EnvironmentSetupUtils {

	private static var instance:EnvironmentSetupUtils;

	private var model:IDEModel = IDEModel.getInstance();
	private var customProcess:NativeProcess;
	private var customInfo:NativeProcessStartupInfo;
	private var isErrorClose:Bool = false;
	private var watchTimer:Timer;
	private var windowsBatchFile:File;
	private var externalCallCompletionHandler:Function;
	private var executeWithCommands:Array<Dynamic>;
	private var customSDKPath:String;
	private var isDelayRunInProcess:Bool = false;

	public static function getInstance():EnvironmentSetupUtils {
		if (instance == null) {
			instance = new EnvironmentSetupUtils();
		}
		return instance;
	}

	public function updateToCurrentEnvironmentVariable():Void {
		function onWatchTimerCompletes(event:TimerEvent):Void {
			watchTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onWatchTimerCompletes);
			watchTimer.stop();
			watchTimer = null;

			cleanUp();
			execute();
		};
		// don't execute in a race condition
		if (watchTimer != null && watchTimer.running) {
			return;
		} /*
		* @local
		*/
		if (watchTimer == null) {
			watchTimer = new Timer(2000, 1);
			watchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onWatchTimerCompletes);
			watchTimer.start();
		}
	}

	public function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDK:String = null, withCommands:Array<Dynamic> = null):Void {
		cleanUp();
		externalCallCompletionHandler = cast completion;
		executeWithCommands = withCommands;
		customSDKPath = customSDK;
		execute();
	}

	private function cleanUp():Void {
		externalCallCompletionHandler = null;
		executeWithCommands = null;
		windowsBatchFile = null;
		customSDKPath = null;
	}

	private function execute():Void {
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			executeOSX();
		} else {
			executeWindows();
		}
	}

	private function executeWindows():Void {
		var setCommand:String = getPlatformCommand();

		// do not proceed if no path to set
		if (setCommand == null) {
			if (externalCallCompletionHandler != null) {
				externalCallCompletionHandler(null);
			}
			return;
		}

		windowsBatchFile = File.applicationStorageDirectory.resolvePath('setLocalEnvironment.cmd');
		FileUtils.writeToFileAsync(windowsBatchFile, setCommand, onBatchFileWriteComplete, onBatchFileWriteError);
	}

	private function executeOSX():Void {
		var setCommand:String = getPlatformCommand();

		// do not proceed if no path to set
		if (setCommand == null) {
			if (externalCallCompletionHandler != null) {
				externalCallCompletionHandler(null);
			}
			return;
		}

		if (externalCallCompletionHandler != null) {
			// in case of macOS - instead of retuning any
			// bash script file path return the full command
			// to execute by caller's own nativeProcess process
			externalCallCompletionHandler(setCommand);
			cleanUp();
		} else {
			onCommandLineExecutionWith(setCommand);
		}
	}

	private function getPlatformCommand():String {
		var setCommand:String = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '' : '@echo off\r\n';
		var isValidToExecute:Bool;
		var setPathCommand:String = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'export PATH=' : 'set PATH=';
		var defaultOrCustomSDKPath:String;
		var additionalCommandLines:String = '';
		var defaultSDKtype:String;
		var defaultSDKreferenceVo:SDKReferenceVO;

		if (customSDKPath != null && AS3.as(FileUtils.isPathExists(customSDKPath), Bool)) {
			defaultOrCustomSDKPath = customSDKPath;
		} else if (AS3.as(UtilsCore.isDefaultSDKAvailable(), Bool)) {
			defaultOrCustomSDKPath = Std.string(model.defaultSDK.fileBridge.nativePath);
		}

		defaultSDKreferenceVo = SDKUtils.getSDKFromSavedList(defaultOrCustomSDKPath);
		if (defaultSDKreferenceVo != null) {
			defaultSDKtype = Std.string(defaultSDKreferenceVo.type);
		}

		if (AS3.as(UtilsCore.isJavaForTypeaheadAvailable(), Bool)) {
			setCommand += getSetExportCommand('JAVA_HOME', Std.string(model.javaPathForTypeAhead.fileBridge.nativePath));
			setPathCommand += ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '$JAVA_HOME/bin:' : '%JAVA_HOME%\\bin;');
			isValidToExecute = true;
		}
		if (AS3.as(UtilsCore.isAntAvailable(), Bool)) {
			setCommand += getSetExportCommand('ANT_HOME', Std.string(model.antHomePath.fileBridge.nativePath));
			setPathCommand += ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '$ANT_HOME/bin:' : '%ANT_HOME%\\bin;');
			isValidToExecute = true;
		}
		if (AS3.as(UtilsCore.isMavenAvailable(), Bool)) {
			setCommand += getSetExportCommand('MAVEN_HOME', Std.string(model.mavenPath));
			setPathCommand += ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '$MAVEN_HOME/bin:' : '%MAVEN_HOME%\\bin;');
			isValidToExecute = true;
		}
		if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool) && AS3.as(UtilsCore.isGitPresent(), Bool)) {
			// moonshine stores gir path with 'bin\git.exe' format
			// we need to find probable sdk root instead
			// next add command to set caFile
			var substrIndex:Int = AS3.int(model.gitPath.indexOf(File.separator + 'bin' + File.separator + 'git.exe'));
			if (substrIndex != -1) {
				var gitRootPath:String = Std.string(model.gitPath.substring(0, substrIndex));
				if (AS3.as(FileUtils.isPathExists(gitRootPath + '\\mingw64\\ssl\\cert.pem'), Bool)) {
					setCommand += getSetExportCommand('GIT_HOME', gitRootPath);
					additionalCommandLines += '%GIT_HOME%\\bin\\git config --global http.sslCAInfo %GIT_HOME%\\mingw64\\ssl\\cert.pem\r\n';
					isValidToExecute = true;
				}
			}
		}
		if (defaultOrCustomSDKPath != null) {
			var flexRoyaleHomeType:String = ((defaultSDKtype != null && defaultSDKtype == Std.string(SDKTypes.ROYALE))) ? 'ROYALE_HOME' : 'FLEX_HOME';
			setCommand += getSetExportCommand(flexRoyaleHomeType, defaultOrCustomSDKPath);
			setPathCommand += ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '$' + flexRoyaleHomeType + '/bin:' : '%' + flexRoyaleHomeType + '%\\bin;');
			isValidToExecute = true;
		}

		// if nothing found in above three don't run
		if (!isValidToExecute) {
			return null;
		}

		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			setCommand += setPathCommand + '$PATH;';
			if (additionalCommandLines != '') {
				setCommand += additionalCommandLines;
			}
			if (executeWithCommands != null) {
				setCommand += executeWithCommands.join(';');
			}
		} else {
			// need to set PATH under application shell
			setCommand += setPathCommand + '%PATH%\r\n';
			if (additionalCommandLines != '') {
				setCommand += additionalCommandLines;
			}
			if (executeWithCommands != null) {
				setCommand += executeWithCommands.join('\r\n');
			}
		}

		return setCommand;
	}

	private function getSetExportCommand(field:String, path:String):String {
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			return 'export ' + field + '=\'' + path + '\';';
		}
		return 'set ' + field + '=' + path + '\r\n';
	}

	private function onBatchFileWriteComplete():Void {
		// following timeout is to overcome process-holding error
		// in vagarant as reported by Joel at
		// https://github.com/prominic/Moonshine-IDE/issues/449#issuecomment-473418675
		var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
					as3hx.Compat.clearTimeout(timeoutValue);
					if (externalCallCompletionHandler != null) {
						// returns batch file path to be
						// executed by the caller's nativeProcess process
						if (windowsBatchFile != null) {
							externalCallCompletionHandler(windowsBatchFile.nativePath);
						}
						cleanUp();
					} else if (windowsBatchFile != null) {
						onCommandLineExecutionWith(Std.string(windowsBatchFile.nativePath));
					}
				}, 1000);
	}

	private function onCommandLineExecutionWith(command:String):Void {
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ?
				File.documentsDirectory.resolvePath('/bin/bash') : new File('c:\\Windows\\System32\\cmd.exe');

		customInfo.arguments = [(AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '-c' : '/c', command];
		customProcess = new NativeProcess();
		startShell(true);
		customProcess.start(customInfo);
	}

	private function onBatchFileWriteError(value:String):Void {
		Alert.show('Local environment setup failed[1]!\n' + value, 'Error!');
	}

	private function startShell(start:Bool):Void {
		if (start) {
			isErrorClose = false;
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		} else {
			if (customProcess == null) {
				return;
			}
			if (AS3.as(customProcess.running, Bool)) {
				customProcess.exit();
			}
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			customProcess = null;
			isErrorClose = false;
		}
	}

	private function shellError(event:ProgressEvent):Void {
		if (customProcess != null) {
			/*var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();

			Alert.show("Local environment setup failed[2]!\n"+ data);*/
			startShell(false);
		}
	}

	private function shellExit(event:NativeProcessExitEvent):Void {
		if (customProcess != null) {
			startShell(false);
		}
	}

	private function shellData(event:ProgressEvent):Void {
		/*var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		Alert.show(data, "shell Data");*/
	}

	public function new() {}

}