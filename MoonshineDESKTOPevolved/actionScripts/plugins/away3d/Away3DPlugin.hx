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
package actionScripts.plugins.away3d;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.System;
import flash.utils.IDataInput;
import actionScripts.events.AddTabEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.Settings;
import components.containers.AwayBuilderView;

class Away3DPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public static inline var OPEN_AWAY3D_BUILDER:String = 'OPEN_AWAY3D_BUILDER';

	private static inline var APP_EXT_COUNT:Int = 3;
	private static inline var APP_INTERNAL_PATH_TO_EXEC:String = '/Contents/MacOS/';
	private static inline var APP_INTERNAL_PATH_TO_PLIST:String = '/Contents/Info.plist';

	override private function get_name():String {
		return 'Away3D';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'The Away3D Moonshine Plugin.';
	}

	private var customProcess:NativeProcess;
	private var customInfo:NativeProcessStartupInfo;
	private var currentFile:File;
	private var abView:AwayBuilderView;

	private var finalExecutablePath:String;

	public var executablePath(get, set):String;
	private function get_executablePath():String {
		return finalExecutablePath;
	}

	private function set_executablePath(value:String):String {
		var path:String = validatePath(value);
		finalExecutablePath = (path != null) ? path : value;
		return value;
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder, false, 0, true);
		dispatcher.addEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen, false, 0, true);
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder);
		dispatcher.removeEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen);
	}

	override public function resetSettings():Void {
		currentFile = null;
	}

	public function getSettingsList():Array<ISetting> {
		return null;
	}

	private function openAway3DBuilder(event:Event):Void {
		if (abView != null) {
			abView.currentFile = currentFile;
			model.activeEditor = abView;
			abView.loadAwayBuilderFile();
			return;
		}

		// lets remove the listener until builder loaded completely
		// else it'll create open file queue against every double-click
		// from .awd files and inject them all at once to the builder
		// which will cause event injection problem to the builder
		dispatcher.removeEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen);

		abView = new AwayBuilderView();
		abView.currentFile = currentFile;
		abView.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAwayBuilderTabClosed);
		abView.addEventListener(Event.COMPLETE, onAwayBuilderReady);
		dispatcher.dispatchEvent(new AddTabEvent(AS3.as(abView, IContentWindow)));
	}

	private function onAwayBuilderReady(event:Event):Void {
		abView.removeEventListener(Event.COMPLETE, onAwayBuilderReady);

		// add back the listener after a second else queued mouse-events
		// may injected all along
		var interval:Int = as3hx.Compat.setTimeout(function():Void {
					dispatcher.addEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen, false, 0, true);
					as3hx.Compat.clearTimeout(interval);
				}, 1000);
	}

	private function onAway3DSettingsUpdated(event:Event):Void {
		if (executablePath != null) {
			runAwdFile(currentFile);
		} else {
			error('Application unavailable. Terminating.');
		}
	}

	private function onAway3DSettingsCanceled(event:Event):Void {
		event.target.removeEventListener(SettingsView.EVENT_SAVE, onAway3DSettingsUpdated);
		event.target.removeEventListener(SettingsView.EVENT_CLOSE, onAway3DSettingsCanceled);
	}

	private function onAwayBuilderTabClosed(event:CloseTabEvent):Void {
		abView.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAwayBuilderTabClosed);
		abView = null;
	}

	private function onAway3DProjectOpen(event:ProjectEvent):Void {
		currentFile = AS3.as(FileLocation(event.anObject).fileBridge.getFile, File);

		if (currentFile != null) {
			if (executablePath == null) {
				openAway3DBuilder(null);
			} else {
				runAwdFile(currentFile);
			}
		} else {
			error('No Away3D file found.');
		}
	}

	private function runAwdFile(withFile:File = null):Void {
		var executableFile:File = ((Settings.os == 'win')) ? new File('c:\\Windows\\System32\\cmd.exe') : new File('/bin/bash');
		var processArgs:Array<String> = new Array<String>();
		customInfo = new NativeProcessStartupInfo();

		if (Settings.os == 'win') {
			processArgs.push('/c');
		} else {
			processArgs.push('-c');
		}
		processArgs.push('\'' + finalExecutablePath + '\' \'' + withFile.nativePath + '\'');

		customInfo.arguments = processArgs;
		customInfo.executable = executableFile;

		if (customProcess != null) {
			startShell(false);
		}
		startShell(true);
	}

	private function startShell(start:Bool):Void {
		if (start) {
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			customProcess.start(customInfo);
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
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (customProcess != null) {
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var syntaxMatch:Array<Dynamic>;
			var generalMatch:Array<Dynamic>;
			var initMatch:Array<Dynamic>;

			syntaxMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
			if (syntaxMatch != null) {
				var pathStr:String = Std.string(syntaxMatch[1]);
				var lineNum:Int = AS3.int(syntaxMatch[2]);
				var colNum:Int = AS3.int(syntaxMatch[3]);
				var errorStr:String = Std.string(syntaxMatch[4]);
			}

			generalMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?): Error: (.*).*', ''));
			if (syntaxMatch == null && generalMatch != null) {
				pathStr = Std.string(generalMatch[1]);
				errorStr = Std.string(generalMatch[2]);
				pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);
				debug('%s', data);
			} else {
				debug('%s', data);
			}

			startShell(false);
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		startShell(false);
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = customProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		debug('%s', data);
	}

	/**
	 * Checks any given path (executable)
	 * existance in the application
	 *
	 * @required
	 * executable path
	 * @return
	 * Boolean
	 */
	private function validatePath(path:String):String {
		var finalExecPath:String;
		var splitPath:Array<String> = path.split('/');

		// for the macOS platform
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			// i.e. /applications/cord.app
			finalExecPath = ((path.substr(path.length - APP_EXT_COUNT, APP_EXT_COUNT) != 'app')) ? path + '.app' : path;
			if (finalExecPath.charAt(0) != '/') {
				finalExecPath = '/' + finalExecPath;
			}

			/*
			* @note
			* we need some info.plist reading here,
			* as some of the app has different name/cases
			* for their executable file in Contents/MacOS folder
			* and some mac system may has case-sensitive setup.
			*/
			var file:File = new File(finalExecPath + APP_INTERNAL_PATH_TO_PLIST);
			if (AS3.as(file.exists, Bool)) {
				var fs:FileStream = new FileStream();
				// following synchronous call as this method
				// requires to return a value in synchronous way
				fs.open(file, FileMode.READ);
				// following String mode read instead as XML
				// as the file values has no nested tag but as:
				// <key/>
				// <string/>
				// it could be hard to find a particular key's value
				// as there will be several such tags runs
				// one after another without having any
				// internal-relation between each other
				var executableFileName:String;
				var loopedCount:Int;
				var plistXML:FastXML = FastXML.parse(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();

				// we don't want any unwanted namespace that problem in parsing
				var plistToString:String = Std.string(plistXML.node.toXMLString());
				var xmlnsPattern:as3hx.Compat.Regex = new as3hx.Compat.Regex('xmlns[^"]*"[^"]*"', 'gi');
				plistToString = xmlnsPattern.replace(plistToString, '');

				// removing all the whitespace/white-lines to form proper XML
				plistToString = new as3hx.Compat.Regex('\\s*\\R', 'g').replace(plistToString, '\n');
				plistToString = new as3hx.Compat.Regex('^\\s*|[\\t ]+$', 'gm').replace(plistToString, '');
				plistToString = new as3hx.Compat.Regex('\\n', 'g').replace(plistToString, '');
				plistXML = new FastXML(plistToString);

				for (j in as3hx.Compat.each(plistXML.nodes.dict.descendants('children')())) {
					if (AS3.as(j.contains(FastXML.parse('<key>CFBundleExecutable</key>')), Bool)) {
						// its mandatory as per plist arc that appropriate value should
						// come after the 'key' declaration, so we assume
						// the next value is 'string' (value)
						executableFileName = Std.string(Reflect.getProperty(plistXML.nodes.dict.descendants('children')(), Std.string(loopedCount + 1)));
						// if the plist is malformed with inappropriate ordering
						// then it won't take the plist as a valid source of
						// information and executableFileName may have any value
						// which eventually will gets into (!File.exist) condition, next
						break;
					}

					loopedCount++;
				}

				// release
				System.disposeXML(plistXML);

				// to overcome some silly mis-cnfiguration issue
				// one which came for Cyberlink where info.plist
				// mentioned with executable with wrong casing.
				// to overcome such situation another round of
				// painful checking we've decided to take for
				// every other application validation
				var exeFolderPath:String = finalExecPath + APP_INTERNAL_PATH_TO_EXEC;
				finalExecPath += APP_INTERNAL_PATH_TO_EXEC + executableFileName;
				file = new File(finalExecPath);
				// if problem in case matching
				// in case-sensitive system
				if (!AS3.as(file.exists, Bool)) {
					file = new File(exeFolderPath);
					var fileLists:Array<Dynamic> = file.getDirectoryListing();
					for (i in ...fileLists.length) {
						if (finalExecPath.toLowerCase() == Std.string(Reflect.field(fileLists[i], 'nativePath').toLowerCase())) {
							finalExecPath = AS3.string(Reflect.field(fileLists[i], 'nativePath'));
							break;
						}
					}
				}
			}

			// for Windows
		} else {
			finalExecPath = path;
		}

		// searching for the existing file
		file = new File(finalExecPath);
		if (AS3.as(file.exists, Bool)) {
			file.canonicalize();
			return Std.string(file.nativePath);
		}

		// unless
		return null;
	}

	public function new() {
		super();
	}

}