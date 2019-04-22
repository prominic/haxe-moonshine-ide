package actionScripts.plugins.build;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.utils.IDataInput;
import actionScripts.factory.FileLocation;
import actionScripts.utils.EnvironmentSetupUtils;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.Settings;

class ConsoleBuildPluginBase extends CompilerPluginBase {

	private var nativeProcess:NativeProcess;
	private var nativeProcessStartupInfo:NativeProcessStartupInfo;

	public function new() {
		super();
	}

	private var _running:Bool = false;

	private var running(get, set):Bool;
	private function get_running():Bool {
		return _running;
	}

	private function set_running(value:Bool):Bool {
		_running = value;
		return value;
	}

	override public function activate():Void {
		super.activate();

		var console:FileLocation = new FileLocation(UtilsCore.getConsolePath());
		nativeProcess = new NativeProcess();
		nativeProcessStartupInfo = new NativeProcessStartupInfo();

		var executable:Dynamic = console.fileBridge.getFile;
		nativeProcessStartupInfo.executable = executable;

		addNativeProcessEventListeners();
	}

	override public function deactivate():Void {
		super.deactivate();

		removeNativeProcessEventListeners();

		nativeProcess = null;
		nativeProcessStartupInfo = null;
	}

	public function start(args:Array<String>, buildDirectory:Dynamic):Void {
		function onEnvironmentPrepared(value:String):Void {
			if (AS3.as(nativeProcess.running, Bool)) {
				removeNativeProcessEventListeners();
				nativeProcess = new NativeProcess();
			}

			var processArgs:Array<String> = new Array<String>();
			if (Settings.os == 'win') {
				processArgs.push('/c');
				processArgs.push(value);
			} else {
				processArgs.push('-c');
				processArgs.push(value);
			}

			running = true;

			addNativeProcessEventListeners();

			//var workingDirectory:File = currentSDK.resolvePath("bin/");
			nativeProcessStartupInfo.arguments = processArgs;
			nativeProcessStartupInfo.workingDirectory = Reflect.field(Reflect.field(buildDirectory, 'fileBridge'), 'getFile');

			nativeProcess.start(nativeProcessStartupInfo);
		};
		if (AS3.as(nativeProcess.running, Bool) && _running) {
			warning('Build is running. Wait for finish...');
			return;
		}

		// remove -c or /c
		// we'll use them later
		var firstArgument:String = (args != null) ? args[0].toLowerCase() : null;
		if (firstArgument != null &&
			(firstArgument == '/c' || firstArgument == '-c')) {
			args.shift();
		}

		var newArray:Array<Dynamic> = new Array<Dynamic>().concat(args); /*
		* @local
		*/
		EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, null, newArray);
	}

	public function stop(forceStop:Bool = false):Void {
		if (running || forceStop) {
			nativeProcess.exit(forceStop);
		}

		running = false;
	}

	public function complete():Void {
		running = false;
	}

	private function stopConsoleBuildHandler(event:Event):Void {}

	private function startConsoleBuildHandler(event:Event):Void {}

	private function onNativeProcessStandardOutputData(event:ProgressEvent):Void {
		print('%s', getDataFromBytes(nativeProcess.standardOutput));
	}

	private function onNativeProcessIOError(event:IOErrorEvent):Void {
		error('%s', event.text);

		removeNativeProcessEventListeners();
		running = false;
	}

	private function onNativeProcessStandardErrorData(event:ProgressEvent):Void {
		error('%s', getDataFromBytes(nativeProcess.standardError));

		removeNativeProcessEventListeners();
		running = false;
	}

	private function onNativeProcessStandardInputClose(event:Event):Void {}

	private function onNativeProcessExit(event:NativeProcessExitEvent):Void {
		removeNativeProcessEventListeners();
	}

	private function getDataFromBytes(data:IDataInput):String {
		return data.readUTFBytes(data.bytesAvailable);
	}

	private function addNativeProcessEventListeners():Void {
		nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
		nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
		nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
		nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
		nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
		nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, onNativeProcessStandardInputClose);
		nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
	}

	private function removeNativeProcessEventListeners():Void {
		nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
		nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
		nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
		nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
		nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
		nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
	}

}