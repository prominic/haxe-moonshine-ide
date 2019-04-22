package actionScripts.extResources.riaspace.nativeApplicationUpdater.utils;

import haxe.Constraints.Function;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;

@:meta(Event(name = 'complete', type = 'flash.events.Event'))
@:meta(Event(name = 'error', type = 'flash.events.ErrorEvent'))
class HdiutilHelper extends EventDispatcher {

	private var dmg:File;

	private var result:Function;

	private var error:Function;

	private var hdiutilProcess:NativeProcess;

	public var mountPoint:String;

	public function new(dmg:File) {
		super();
		this.dmg = dmg;
		this.result = cast result;
		this.error = cast error;
	}

	public function attach():Void {
		var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		info.executable = new File('/usr/bin/hdiutil');

		var args:Array<String> = new Array<String>();
		args.push('attach');
		args.push('-plist');
		args.push(dmg.nativePath);

		info.arguments = args;

		hdiutilProcess = new NativeProcess();
		hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
		hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
		hdiutilProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
		hdiutilProcess.start(info);
	}

	private function hdiutilProcess_outputHandler(event:ProgressEvent):Void {
		hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
		hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
		hdiutilProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
		hdiutilProcess.exit();

		// Storing current XML settings
		var xmlSettings:Dynamic = FastXML.node.settings();
		// Setting required custom XML settings
		FastXML.node.setSettings(
				{
					'ignoreWhitespace': true,
					'ignoreProcessingInstructions': true,
					'ignoreComments': true,
					'prettyPrinting': false
				}
		);

		var plist:FastXML = new FastXML(hdiutilProcess.standardOutput.readUTFBytes(event.bytesLoaded));
		var dicts:FastXMLList = plist.nodes.dict.descendants('array').descendants('dict');

		// INFO: for some reason E4X didn't work
		for (dict in dicts) {
			for (element in as3hx.Compat.each(dict.descendants('elements')())) {
				if (element.name() == 'key' && element.text() == 'mount-point') {
					mountPoint = Std.string(dict.descendants('child')(element.childIndex() + 1));
					break;
				}
			}
		}

		// Reverting back original XML settings
		FastXML.node.setSettings(xmlSettings);

		if (mountPoint != null) {
			dispatchEvent(new Event(Event.COMPLETE));
		} else {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, 'Couldn\'t find mount point!'));
		}
	}

	private function hdiutilProcess_errorHandler(event:IOErrorEvent):Void {
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, event.text, event.errorID));
	}

}