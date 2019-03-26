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
package actionScripts.utils;

import haxe.Constraints.Function;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import actionScripts.valueObjects.Settings;
class SoftwareVersionChecker {

	@:meta(Bindable())
public static var JAVA_VERSION:String = '- Not Found -';

	@:meta(Bindable())
public static var ANT_VERSION:String = '- Not Found -';

	@:meta(Bindable())
public static var FLEX_SYSTEM_VERSION:String = '- Not Found -';

	@:meta(Bindable())
public static var isMacOS:Bool;

	private var cmdFile:File;

	private var shellInfo:NativeProcessStartupInfo;

	private var nativeProcess:NativeProcess;

	private var checkingQueues:Array<Dynamic>;

	private var currentQueuePosition:Int;

	private var javaPathRetrievalHandler:Function;

	private var nativeInfoReaderHandler:Function;

	/**
	 * CONSTRUCTOR
	 */
	public function new() {}

	/**
	 * Checks some required/optional software installation
	 * and their version if available
	 */
	public function retrieveAboutInformation():Void {
		if (Settings.os == 'win') {
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
			checkingQueues = ['java -version', 'ant -version', 'mxmlc -version'];
			isMacOS = false;
		} else {
			cmdFile = File.documentsDirectory.resolvePath('/bin/bash');
			isMacOS = true;
			checkingQueues = ['java -version'];
		}

		nativeInfoReaderHandler = parseData;
		startCheckingProcess();
	}

	/**
	 * Retrieves Java path in OSX
	 */
	public function getJavaPath(completionHandler:Function):Void {
		javaPathRetrievalHandler = completionHandler;
		cmdFile = File.documentsDirectory.resolvePath('/bin/bash');
		isMacOS = true;
		checkingQueues = ['/usr/libexec/java_home/ -v 1.8'];

		nativeInfoReaderHandler = parseJavaOnlyPath;
		startCheckingProcess();
	}

	private function startCheckingProcess():Void
	// probable termination
	 {

		if (currentQueuePosition >= checkingQueues.length) {
			return;
		}

		var processArgs:Array<String> = new Array<String>();
		shellInfo = new NativeProcessStartupInfo();

		if (Settings.os == 'win') {
			processArgs.push('/C');
		} else {
			processArgs.push('-c');
		}
		processArgs.push(checkingQueues[currentQueuePosition]);
		shellInfo.arguments = processArgs;
		shellInfo.executable = cmdFile;

		initShell();
	}

	private function initShell():Void {
		if (nativeProcess != null) {
			nativeProcess.exit();
		} else {
			startShell();
		}
	}

	private function startShell():Void {
		nativeProcess = new NativeProcess();

		nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		nativeProcess.start(shellInfo);
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardOutput;
		nativeInfoReaderHandler(output.readUTFBytes(output.bytesAvailable));
	}

	private function shellError(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardError;
		nativeInfoReaderHandler(output.readUTFBytes(output.bytesAvailable));
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
		nativeProcess.exit();
		nativeProcess = null;
		currentQueuePosition++;
		startCheckingProcess();
	}

	private function parseData(data:String):Void {
		var match:Array<Dynamic> = data.match(new as3hx.Compat.Regex('java version', ''));
		if (match != null) {
			JAVA_VERSION = (Std.string(data.split('\n')[0])).split('java version')[1];
		}

		match = data.match(new as3hx.Compat.Regex('Ant\\(TM\\) version', ''));
		if (match != null) {
			ANT_VERSION = data.split('\n')[0];
		}

		// mxmlc check
		if (currentQueuePosition == 2 && data.match('Version')) {
			FLEX_SYSTEM_VERSION = data.split('\n')[0];
		}
	}

	private function parseJavaOnlyPath(data:String):Void {
		var match:Array<Dynamic> = data.match(new as3hx.Compat.Regex('Unable to find', ''));
		if (match != null) {
			javaPathRetrievalHandler(null);
		} else {
			match = data.match(new as3hx.Compat.Regex('JavaVirtualMachines', ''));
			if (match != null && (javaPathRetrievalHandler != null))
			// once found between two commands (in queue array)
			{

				javaPathRetrievalHandler(data);
			}
		}

		javaPathRetrievalHandler = null;
	}

}