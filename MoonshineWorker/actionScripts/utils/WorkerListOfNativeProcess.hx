package actionScripts.utils;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import actionScripts.events.WorkerEvent;
import actionScripts.valueObjects.WorkerNativeProcessResult;

class WorkerListOfNativeProcess {

	public var worker:MoonshineWorker;
	public var subscriberUdid:String;

	private var customProcess:NativeProcess;
	private var customInfo:NativeProcessStartupInfo;
	private var queue:Array<Dynamic> = new Array<Dynamic>();
	private var pendingQueue:Array<Dynamic> = [];
	private var isErrorClose:Bool = false;
	private var presentRunningQueue:Dynamic;
	private var currentWorkingDirectory:File;

	public function new() {}

	public function runProcesses(processDescriptor:Dynamic):Void {
		if (customProcess != null && AS3.as(customProcess.running, Bool)) {
			pendingQueue.push(processDescriptor);
			return;
		}

		if (customProcess != null) {
			startShell(false);
		}
		customInfo = renewProcessInfo();

		queue = Reflect.field(processDescriptor, 'queue');
		if (Reflect.field(processDescriptor, 'workingDirectory') != null) {
			currentWorkingDirectory = new File(Reflect.field(processDescriptor, 'workingDirectory'));
		}

		startShell(true);
		flush();
	}

	private function renewProcessInfo():NativeProcessStartupInfo {
		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = (!MoonshineWorker.IS_MACOS) ? new File('c:\\Windows\\System32\\cmd.exe') : new File('/bin/bash');

		return customInfo;
	}

	private function flush():Void {
		if (queue.length == 0) {
			startShell(false);
			worker.workerToMain.send({
						'event': WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED,
						'value': null,
						'subscriberUdid': subscriberUdid
					});

			if (pendingQueue.length != 0) {
				runProcesses(pendingQueue.shift());
			}
			return;
		}

		if (AS3.as(Reflect.field(queue[0], 'showInConsole'), Bool)) {
			worker.workerToMain.send({
						'event': WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT,
						'value': 'Sending to command: ' + Reflect.field(queue[0], 'com'),
						'subscriberUdid': subscriberUdid
					});
		}

		var tmpArr:Array<Dynamic> = Reflect.field(queue[0], 'com').split('&&');

		if (!MoonshineWorker.IS_MACOS) {
			tmpArr.unshift('/c');
		} else {
			tmpArr.unshift('-c');
		}
		customInfo.arguments = tmpArr;
		customInfo.workingDirectory = currentWorkingDirectory;

		presentRunningQueue = queue.shift(); /** type of NativeProcessQueueVO **/
		worker.workerToMain.send({
					'event': WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK,
					'value': presentRunningQueue,
					'subscriberUdid': subscriberUdid
				});
		customProcess.start(customInfo);
	}

	private function startShell(start:Bool):Void {
		if (start) {
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);

			// @note
			// for some strange reason all the standard output turns to standard error output by git command line.
			// to have them dictate and continue the native process (without terminating by assuming as an error)
			// let's listen standard errors to shellData method only
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);

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
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			customProcess = null;
			presentRunningQueue = null;
			isErrorClose = false;
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (customProcess != null) {
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();

			var syntaxMatch:Array<Dynamic>;
			var generalMatch:Array<Dynamic>;
			var initMatch:Array<Dynamic>;
			var hideDebug:Bool;

			syntaxMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) error: (.*).*', ''));
			if (syntaxMatch != null) {
				var pathStr:String = Std.string(syntaxMatch[1]);
				var lineNum:Int = AS3.int(syntaxMatch[2]);
				var colNum:Int = AS3.int(syntaxMatch[3]);
				var errorStr:String = Std.string(syntaxMatch[4]);
			}

			generalMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?): error: (.*).*', ''));
			if (syntaxMatch == null && generalMatch != null) {
				pathStr = Std.string(generalMatch[1]);
				errorStr = Std.string(generalMatch[2]);
				pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);
				worker.workerToMain.send({
							'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
							'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, data),
							'subscriberUdid': subscriberUdid
						});
				hideDebug = true;
			}

			if (!hideDebug) {
				worker.workerToMain.send({
							'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
							'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, data),
							'subscriberUdid': subscriberUdid
						});
			}
			isErrorClose = true;
			startShell(false);
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		if (customProcess != null) {
			if (!isErrorClose) {
				worker.workerToMain.send({
							'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
							'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE, null, presentRunningQueue),
							'subscriberUdid': subscriberUdid
						});
				flush();
			}
		}
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = ((customProcess.standardOutput.bytesAvailable != 0)) ? customProcess.standardOutput : customProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		var match:Array<Dynamic>;
		var isFatal:Bool;

		match = as3hx.Compat.match(data, new as3hx.Compat.Regex('fatal: .*', ''));
		if (match != null) {
			isFatal = true;
			worker.workerToMain.send({
						'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
						'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_DATA, data, presentRunningQueue),
						'subscriberUdid': subscriberUdid
					});
		}

		if (match == null) {
			match = as3hx.Compat.match(data.toLowerCase(), new as3hx.Compat.Regex('(.*?)error: (.*).*', ''));
		}
		if (match == null) {
			match = as3hx.Compat.match(data.toLowerCase(), new as3hx.Compat.Regex('\'git\' is not recognized as an internal or external command', ''));
		}

		if (match != null) {
			if (!isFatal) {
				worker.workerToMain.send({
							'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
							'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, presentRunningQueue),
							'subscriberUdid': subscriberUdid
						});
			}
			isErrorClose = true;
			startShell(false);
			return;
		}

		isErrorClose = false;
		if (!isFatal) {
			worker.workerToMain.send({
						'event': WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
						'value': new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_DATA, data, presentRunningQueue),
						'subscriberUdid': subscriberUdid
					});
		}
		//worker.workerToMain.send({event:WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT, value:data, subscriberUdid:subscriberUdid});
	}

}