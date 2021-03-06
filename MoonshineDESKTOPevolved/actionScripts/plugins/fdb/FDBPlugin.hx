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
package actionScripts.plugins.fdb;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.events.AdvancedDataGridEvent;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.utils.ObjectUtil;
import actionScripts.events.EditorPluginEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugins.fdb.event.FDBEvent;
import actionScripts.plugins.fdb.view.FDBView;
import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.events.DebugLineEvent;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;

class FDBPlugin extends PluginBase implements IPlugin {

	override private function get_name():String {
		return 'Flex Debugger Plugin';
	}

	override private function get_author():String {
		return 'Miha Lunar & Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Debugs AS3 projects with FDB.';
	}

	private static inline var CONSOLE_MODE:String = 'fdb';

	private var fdbPath:String = 'bin/fdb';
	private var outputBuffer:String = '';
	private var cmdFile:File;
	private var cookie:Dynamic;
	private var breakPointArr:ArrayCollection;
	private var currentSDK:File;
	private var debuggerInfo:NativeProcessStartupInfo;
	private var fdb:NativeProcess;

	private var manualMode:Bool = false;
	private var localsNext:Bool = false;
	private var itemQueue:Array<FastXML> = new Array<FastXML>();

	private var debugView:FDBView;
	private var objectTree:XMLListCollection;
	private var nameOfFile:String;
	private var isStepOver:Bool = false;
	private var commandStr:String = '';
	private var isExpanded:Bool = false;
	private var editor:BasicTextEditor;
	private var fschstr:String;
	private var SDKstr:String;
	private var isSession:Bool = false;

	public function new() {
		super();
		if (Settings.os == 'win') {
			fdbPath += '.bat';
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		}//For MacOS
		else {
			//For MacOS
			cmdFile = new File('/bin/bash');
		}

	}

	override public function activate():Void {
		super.activate();

		debugView = new FDBView();
		debugView.addEventListener(AdvancedDataGridEvent.ITEM_OPEN, objectOpened);
		debugView.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, refreshItem);

		dispatcher.addEventListener(ActionScriptBuildEvent.POSTBUILD, postbuild);
		dispatcher.addEventListener(ActionScriptBuildEvent.PREBUILD, handleCompile);
		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		dispatcher.addEventListener(MenuPlugin.MENU_SAVE_EVENT, handleEditorSave);
		dispatcher.addEventListener(MenuPlugin.MENU_SAVE_AS_EVENT, handleEditorSave);
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, handleEditorSave);
		dispatcher.addEventListener(FDBEvent.SHOW_DEBUG_VIEW, handleShowDebugView);
		dispatcher.addEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, continueExecutionHandler);
		dispatcher.addEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, terminateExecutionHandler);

		var fdbObj:Dynamic = {};
		Reflect.setField(fdbObj, 'callback', fdbCommand);
		Reflect.setField(fdbObj, 'commandDesc', 'Debug a Flex Application.  CURRENTLY UNAVAILABLE.');
		registerCommand(CONSOLE_MODE, fdbObj);

		cookie = {};
		breakPointArr = new ArrayCollection();
	}

	//"F6" will call below function and step over the line
	private function handleCodeStepOver(e:Event):Void {
		send('next');
		debug('>>> %s <<<', 'fdb next');
	}

	//Continue Execution
	private function continueExecutionHandler(e:Event):Void {
		if (fdb != null) {
			send('continue');
			var ed:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
			if (ed != null) {
				ed.getEditorComponent().model.hasTraceSelection = false;
				ed.getEditorComponent().updateSelection();
				ed.getEditorComponent().updateTraceSelection();
				ed.getEditorComponent().removeTraceSelection();
			}
		}
	}

	//Terminate execution of running application
	private function terminateExecutionHandler(e:Event):Void {
		if (fdb != null) {
			stopDebugger();
		}
	}

	private function exitFDBHandler(e:ActionScriptBuildEvent):Void {
		if (fdb != null) {
			send('quit');
		}
	}

	private function handleShowDebugView(e:Event):Void {
		IDEModel.getInstance().mainView.addPanel(debugView);
	}

	private function objectOpened(e:AdvancedDataGridEvent):Void {
		var item:FastXML = FastXML.parse(e.item);
		if (item.node.children().length() == 0) {
			updateItem(item);
		}
		isExpanded = true;
	}

	private function refreshItem(e:ListEvent):Void {
		var item:FastXML = FastXML.parse(e.itemRenderer.data);
		updateItem(item);
	}

	private function updateItem(item:FastXML):Void {
		item.setAttribute("label", 'updating...');
		itemQueue.push(item);
		send('print ' + item.att.path + ((item.att.isBranch == 'true') ? '.' : ''));
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(ActionScriptBuildEvent.POSTBUILD, postbuild);

		unregisterCommand(CONSOLE_MODE);

		if (fdb != null) {
			startShell(false);
		}
	}

	private function handleEditorOpen(event:EditorPluginEvent):Void {
		if (AS3.as(event.newFile, Bool) || !AS3.as(event.file, Bool)) {
			return;
		}

		var path:String = Std.string(event.file.fileBridge.nativePath);
		var breakpoints:Array<Dynamic> = cast AS3.asArray(Reflect.field(cookie, path));
		if (breakpoints != null) {
			event.editor.breakpoints = breakpoints;
		}
	}

	private function handleEditorSave(event:Event):Void {
		var editor:BasicTextEditor;
		if (Std.is(event, CloseTabEvent)) {
			editor = AS3.as(CloseTabEvent(event).tab, BasicTextEditor);
		} else {
			editor = AS3.as(IDEModel.getInstance().activeEditor, BasicTextEditor);
		}

		saveForEditor(editor);
	}

	private function handleCompile(event:MXMLCPluginEvent):Void {
		currentSDK = AS3.as(event.sdk.fileBridge.getFile, File);
		// Make sure we have stuff from all editors. (even unsaved?)
		dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE, debugLineHandler);
	}

	//Adding/removing breakpoints at runtime
	private function debugLineHandler(event:DebugLineEvent):Void {
		editor = AS3.as(IDEModel.getInstance().activeEditor, BasicTextEditor);
		if (editor == null) {
			return;
		}
		if (!AS3.as(editor.currentFile, Bool)) {
			return;
		}

		var path:String = Std.string(editor.currentFile.fileBridge.nativePath);
		if (path == '') {
			return;
		}
		var bp:Array<Dynamic> = cast AS3.asArray(Reflect.field(cookie, path));
		if (bp == null) {
			bp = new Array<Dynamic>();
		}
		if (AS3.as(event.breakPoint, Bool)) {
			var f:File = new File(path);
			bp.push(event.breakPointLine);
			Reflect.setField(cookie, path, bp);
			if (fdb != null) {
				commandStr = 'break ' + f.name + ':' + (event.breakPointLine + 1);
				send('break ' + f.name + ':' + (event.breakPointLine + 1));
			}
		} else if (fdb != null) {
			var index:Int;
			for (filePath in Reflect.fields(cookie)) {
				f = new File(filePath);
				for (bpObj in breakPointArr) {
					if (f.name == Reflect.field(bpObj, 'bpFile') && AS3.int(Reflect.field(bpObj, 'bpLine')) == AS3.int(event.breakPointLine)) {
						if (f.name == Reflect.field(bpObj, 'bpFile') && AS3.int(Reflect.field(bpObj, 'bpLine')) == AS3.int(event.breakPointLine)) {
							commandStr = 'delete ' + Reflect.field(bpObj, 'bpNum');
							send('delete ' + Reflect.field(bpObj, 'bpNum'));
							breakPointArr.removeItem(bpObj);
							index = AS3.int(Lambda.indexOf(bp, event.breakPointLine));
							bp.splice(index, 1);
							Reflect.setField(cookie, path, bp);
							break;
						}
					}
				}
			}
		}
	}

	private function saveForEditor(editor:BasicTextEditor):Void {
		if (editor == null) {
			return;
		}
		if (!AS3.as(editor.currentFile, Bool)) {
			return;
		}

		var path:String = Std.string(editor.currentFile.fileBridge.nativePath);
		if (path == '') {
			return;
		}

		Reflect.setField(cookie, path, editor.getEditorComponent().breakpoints);
	}

	private function fdbCommand(args:Array<Dynamic>):Void {
		if (args.length == 0) {
			enterConsoleMode(CONSOLE_MODE);
			manualMode = true;
		} else if (args[0] == 'exit') {
			exitConsoleMode();
			manualMode = false;
			if (fdb != null) {
				send(args.join(' '));
			}
		} else {
			print('FDB ' + args.join(' '));
			if (fdb == null) {
				// start debugg process
				GlobalEventDispatcher.getInstance().dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.BUILD_AND_DEBUG, false, false));
				//send(args.join(" "));
				//print("FDB not running, please build the project you want to debug at least once.");
			} else {
				send(args.join(' '));
			}
		}
	}

	// init debugger
	private function initDebugger():Void {
		if (currentSDK == null) {
			error('No Flex SDK set, check settings.');
			return;
		}
		objectTree = debugView.objectTree;
		var fdbFile:File = currentSDK.resolvePath(fdbPath);
		debuggerInfo = new NativeProcessStartupInfo();
		var processArgs:Array<String> = new Array<String>();

		fschstr = Std.string(fdbFile.nativePath);
		fschstr = Std.string(UtilsCore.convertString(fschstr));

		SDKstr = Std.string(currentSDK.nativePath);
		SDKstr = Std.string(UtilsCore.convertString(SDKstr));

		if (Settings.os == 'win') {
			processArgs.push('/c');
			processArgs.push('set FLEX_HOME=' + SDKstr + '&& ' + fschstr);
		} else {
			processArgs.push('-c');
			processArgs.push('export FLEX_HOME=' + SDKstr + '&& ' + fschstr);
		}

		debuggerInfo.arguments = processArgs;
		debuggerInfo.executable = cmdFile;

		if (AS3.as(model.activeProject, Bool)) {
			debuggerInfo.workingDirectory = AS3.as(model.activeProject.folderLocation.fileBridge.getFile, File);
		}
		print('3 in FDBPlugin debugafterBuild');
		startShell(true);
	}

	private function startShell(start:Bool):Void {
		if (start) {
			fdb = new NativeProcess();
			fdb.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, debuggerData);
			fdb.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, debuggerError);
			fdb.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, debuggerError);
			fdb.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, debuggerError);
			fdb.addEventListener(NativeProcessExitEvent.EXIT, debuggerExit);
			fdb.start(debuggerInfo);

			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, model.activeProject.projectName, 'Debugging '));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
		} else {
			if (fdb == null) {
				return;
			}
			if (AS3.as(fdb.running, Bool)) {
				fdb.exit();
			}
			fdb.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, debuggerData);
			fdb.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, debuggerError);
			fdb.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, debuggerError);
			fdb.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, debuggerError);
			fdb.removeEventListener(NativeProcessExitEvent.EXIT, debuggerExit);
			fdb = null;

			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
		}
	}

	private function onTerminateBuildRequest(event:StatusBarEvent):Void {
		if (fdb != null && AS3.as(fdb.running, Bool)) {
			stopDebugHandler(null);
		}
	}

	private function getMainTargetFolder():File {
		var project:AS3ProjectVO = AS3ProjectVO(IDEModel.getInstance().activeProject);
		return (project.targets.length == 0) ? null : (AS3.as(FileLocation(Reflect.getProperty(project.targets, Std.string(0))).fileBridge.getFile, File)).parent;
	}

	/**
	 * Returns the file path relative to the project's main target path
	 */
	private function getRelativeTargetPath(f:File):String {
		return Std.string(getMainTargetFolder().getRelativePath(f, true));
	}

	/**
	 * Resolves the path based on the project's main target path
	 */
	private function resolveTargetPath(path:String):File {
		var f:File = getMainTargetFolder().resolvePath(path);
		return f;
	}

	private function getFileTargetPath(path:String):FileLocation {
		for (path in Reflect.fields(cookie)) {
			var f:FileLocation = new FileLocation(path);
			if (f.fileBridge.name == nameOfFile) {
				break;
			}
		}
		return f;
	}

	private function sessionStart():Void {
		var editors:Array<Dynamic> = IDEModel.getInstance().editors.source;
		for (i in 0...editors.length) {
			saveForEditor(AS3.as(editors[i], BasicTextEditor));
		}

		send('delete');
		send('y');
		send('run');

		for (path in Reflect.fields(cookie)) {
			var f:File = new File(path);
			send('cf ' + getRelativeTargetPath(f));
			var breakpoints:Array<Dynamic> = Reflect.field(cookie, path);
			for (i in 0...breakpoints.length) {
				send('break ' + f.name + ':' + (breakpoints[i] + 1));
			}
		}
		if (!manualMode) {
			send('continue');
		}

		// Add debugview if not visible
		if (!AS3.as(debugView.stage, Bool)) {
			model.mainView.addPanel(debugView);
		}

		// Make session flag true
		isSession = true;
	}

	private function sessionStop():Void {
		//if (debugView.stage) debugView.parent.removeChild(debugView);
		debugView.objectTree = new XMLListCollection();
	}

	private function debuggerData(e:ProgressEvent):Void {
		var output:IDataInput = fdb.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		//Alert.show(data);
		var match:Array<Dynamic>;
		var project:ProjectVO = IDEModel.getInstance().activeProject;
		var isMatchFound:Bool;

		//A new filter added here which will detect command for FDB exit
		match = as3hx.Compat.match(data, new as3hx.Compat.Regex('.*\\(fdb\\) The program is running.  Exit anyway.*', ''));
		if (match != null) {
			send('y');
			isMatchFound = true;
		} else {
			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('Waiting for Player to connect', ''));
			if (match != null) {
				GlobalEventDispatcher.getInstance().dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.RUN_AFTER_DEBUG));
				isMatchFound = true;
			}
			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('.*Player connected; session starting\\..*', ''));
			if (match != null) {
				sessionStart();
				isMatchFound = true;
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('.*Player session terminated.*', ''));
			if (match != null) {
				//send("quit");
				sessionStop();
				isMatchFound = true;
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('\\[trace\\] (.*)\\n', 's'));
			if (match != null) {
				print(match[1]);
				outputBuffer += data;
				isMatchFound = true;
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('Do you want to attempt to halt execution.*?', ''));
			if (match != null) {
				send('y');
				isMatchFound = true;
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('Attempting to halt.', ''));
			if (match != null) {
				if (commandStr != '') {
					send(commandStr);
					send('continue');
					commandStr = '';
				}
				isMatchFound = true;
			} else {
				outputBuffer += data;
			}
		}
		match = as3hx.Compat.match(outputBuffer, new as3hx.Compat.Regex('(.*)\\n\\(fdb\\) ', 's'));
		if (match != null) {
			var buffer:String = Std.string(match[1]);
			if (manualMode) {
				print('fdb> ' + buffer);
			} else if (itemQueue.length > 0) {
				var item:FastXML = itemQueue.shift();

				var branch:Bool = item.att.isBranch == 'true';
				// Remove all items first
				if (branch) {
					item.node.setChildren(new FastXMLList());
				}

				var objects:Array<String> = new as3hx.Compat.Regex('\\r\\n', 'g').replace(buffer, '\n').split('\n');
				var skipFirst:Bool = !localsNext && branch;
				for (objLine in objects) {
					if (skipFirst) {
						skipFirst = false;
						continue;
					}
					match = as3hx.Compat.match(objLine, ' ?(.*?) = (.*)');
					if (match == null) {
						continue;
					}

					var objName:String = Std.string(match[1]);
					var objValue:String = Std.string(match[2]);
					if (branch) {
						var complex:Bool = AS3.as(AS3.as(as3hx.Compat.match(objValue, new as3hx.Compat.Regex('^\\[Object .*?\\]$', '')), Bool), Bool);
						var newItem:FastXML;
						if (complex) {
							var objMatch:Array<Dynamic> = as3hx.Compat.match(objValue, new as3hx.Compat.Regex('Object (\\d*), class=\'(.*)\']', ''));
							if (objMatch != null) {
								newItem = FastXML.parse('<item label={objName} path={item.@path + (item.@path == "" ? "" : ".") + objName} name={objName} value={objMatch[2]+" (@"+objMatch[1]+")"}/>');
							}
							newItem.setAttribute("isBranch", 'true');

						} else {
							newItem = FastXML.parse('<item label={objName} path={item.@path + (item.@path == "" ? "" : ".") + objName} name={objName} value={objValue}/>');
						}
						item.node.appendChild(newItem);

					} else {
						item.setAttribute("value", objValue);
					}

				}
				item.setAttribute("label", item.setAttribute("name", ));
				localsNext = false;
				isMatchFound = true;
			}

			match = as3hx.Compat.match(buffer, '/There is no executable code on the specified line./');
			if (match != null) {}

			match = (AS3.as(as3hx.Compat.match(buffer, new as3hx.Compat.Regex('^\\[SWF\\].*?Additional ActionScript code has been loaded from a SWF or a frame', '')), Bool)) ? as3hx.Compat.match(buffer, new as3hx.Compat.Regex('^\\[SWF\\].*?Additional ActionScript code has been loaded from a SWF or a frame', '')) : as3hx.Compat.match(buffer, new as3hx.Compat.Regex('.*Additional ActionScript code has been loaded from a SWF or a frame', ''));
			if (match != null) {
				send('continue');
				isMatchFound = true;
			}

			match = as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Resolved breakpoint (\\d*?) to (.*?):(\\d*).*+', 'g'));
			if (match.length > 0) {
				for (m_ in match) {
					var m:String = cast m_;
					var subStrMatch:Array<Dynamic> = m.match(new as3hx.Compat.Regex('Resolved breakpoint (\\d*?) to (.*?):(\\d*).*?', ''));
					if (subStrMatch != null) {
						var bpFile:String;
						var bpLine:Int;
						var bpNum:Int;
						if (subStrMatch[0].indexOf('()') != -1) {
							var fileNamearr:Array<String> = Std.string(subStrMatch[2]).split(' ');
							bpFile = fileNamearr[fileNamearr.length - 1];
							bpLine = AS3.int(AS3.int(subStrMatch[3]) - 1);
							bpNum = AS3.int(subStrMatch[1]);
							AddBreakpoint(bpFile, bpLine, bpNum);
						} else {
							bpFile = Std.string(subStrMatch[2]);
							bpLine = AS3.int(AS3.int(subStrMatch[3]) - 1);
							bpNum = AS3.int(subStrMatch[1]);
							AddBreakpoint(bpFile, bpLine, bpNum);
						}

					}
				}
				isMatchFound = true;
			}

			match = as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Breakpoint (\\d*?): file (.*?), line (\\d*).*?', ''));
			if (match != null) {
				var bpFile1:String = Std.string(match[2]);
				var bpLine1:Int = AS3.int(match[3]) - 1;
				var bpNum1:Int = AS3.int(match[1]);
				AddBreakpoint(bpFile1, bpLine1, bpNum1);
				isMatchFound = true;
			}

			match = (AS3.as(as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Breakpoint (\\d*?), (.*?) at (.*?):(\\d*).*?', '')), Bool)) ? as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Breakpoint (\\d*?), (.*?) at (.*?):(\\d*).*?', '')) : as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Breakpoint (\\d*?), (.*?):(\\d*).*?', ''));
			if (match != null) {
				var bpFunc:String = '';
				var bpNum2:Int = AS3.int(match[1]);
				var bpFile2:String = '';
				var bpLine2:Int = 0;
				if (match[0].indexOf('()') != -1) {
					bpFunc = Std.string(match[2]);
					bpFile2 = nameOfFile = Std.string(match[3]);
					bpLine2 = AS3.int(AS3.int(match[4]) - 1);
					AddBreakpoint(bpFile2, bpLine2, bpNum2);
					print('Breakpoint in ' + bpFunc + ' at line ' + (bpLine2 + 1) + ' of ' + bpFile2);

				} else {
					bpFile2 = nameOfFile = Std.string(match[2]);
					bpLine2 = AS3.int(AS3.int(match[3]) - 1);
					AddBreakpoint(bpFile2, bpLine2, bpNum2);
					print('Breakpoint in at line ' + (bpLine2 + 1) + ' of ' + bpFile2);

				}
				// Open file & scroll & select the given line
				dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.TRACE_LINE, [getFileTargetPath(nameOfFile)], bpLine2));
				// Chances are we're not in focus here, so let's focus Moonshine
				// This slows everything down like /crazy/. Why?
				// NativeApplication.nativeApplication.activate(NativeApplication.nativeApplication.openedWindows[0]);
				if (!manualMode) {
					isStepOver = true;
					dispatcher.addEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, handleCodeStepOver);
					objectTree.removeAll();
					var itemThis:FastXML = FastXML.parse('<item label="this" path="this" name="this" value="this" isBranch="true" />');
					var itemLocals:FastXML = FastXML.parse('<item label="locals" path="" name="locals" value="locals" isBranch="true" />');
					objectTree.addItem(itemThis);
					objectTree.addItem(itemLocals);
					if (isExpanded) {
						debugView.expandItem(itemThis);
					}
					itemQueue.push(itemThis);
					send('print this.');
					localsNext = true;
				}
				isMatchFound = true;
			}

			match = as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Execution halted,(.*?):(\\d*)*', ''));
			if (match != null) {
				var lineNum:Array<Dynamic> = new Array<Dynamic>();
				var nextLine:Int = 0;

				if (match[0].indexOf('()') != -1) {
					lineNum = Std.string(match[0]).split(':');
					nextLine = AS3.int(lineNum[1]);
					var tempArr:Array<Dynamic> = Std.string(match[1]).split(' ');
					nameOfFile = Std.string(tempArr[tempArr.length - 1]);
				} else {
					lineNum = Std.string(match[0]).split(':');
					nextLine = AS3.int(lineNum[1]);

					nameOfFile = Std.string(StringTools.trim(match[1]));
				}

				send('continue');
				isMatchFound = true;
			}

			match = as3hx.Compat.match(buffer, new as3hx.Compat.Regex('Execution halted .* at .*', ''));
			if (match != null) {
				send('continue');
				//Remove traceline selection from the view
				for (contentWindow in as3hx.Compat.each(model.editors)) {
					var ed:BasicTextEditor = AS3.as(contentWindow, BasicTextEditor);
					if (ed != null) {
						ed.getEditorComponent().model.hasTraceSelection = false;
						ed.getEditorComponent().updateSelection();
						ed.getEditorComponent().updateTraceSelection();
						ed.getEditorComponent().removeTraceSelection();
						var path:String = Std.string(ed.currentFile.fileBridge.nativePath);
						Reflect.setField(cookie, path, ed.getEditorComponent().breakpoints);
					}
				}
				//unregister "F6" command
				dispatcher.removeEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, handleCodeStepOver);
				isMatchFound = true;
			}

			// match = buffer.match(/[\(fdb)\]*^\s[0-9]+[\s*]+\w*/);
			if (match != null && isStepOver) {
				match = as3hx.Compat.match(buffer, new as3hx.Compat.Regex('^\\s[0-9]+[\\s*]', ''));
				if (match != null) {
					var nextLine3:Int = AS3.int(match[0]);
					dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.TRACE_LINE, [getFileTargetPath(nameOfFile)], nextLine3 - 1));
					dispatcher.addEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, handleCodeStepOver);
				}
				isMatchFound = true;
			}

			outputBuffer = '';
		}
		// This line is for dev. purpose to display fdb data in console
		if (!isMatchFound) {
			debug('>>> %s <<<', data);
		}
	}

	//Adding breakpoint at runtime
	private function AddBreakpoint(bpFile:String, bpLine:Int, bpNum:Int):Void {
		var flag:Bool = false;
		var bpObj:Dynamic = {
			'bpNum': bpNum,
			'bpFile': bpFile,
			'bpLine': bpLine
		};

		var index:Int = AS3.int(breakPointArr.getItemIndex(bpObj));
		for (item in breakPointArr) {
			if (ObjectUtil.compare(item, bpObj, 0) == 0) {
				flag = true;
			}
		}
		if (!flag) {
			breakPointArr.addItem(bpObj);
		}
	}

	private function debuggerError(e:ProgressEvent):Void {
		var output:IDataInput = fdb.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		if (data.charAt(data.length - 1) == '\n') {
			data = data.substr(0, data.length - 1);
		}
		if (manualMode) {
			print('fdb> ' + data);
		}

		debug('Error: %s', data);
		fdb = null;
	}

	private function debuggerExit(e:NativeProcessExitEvent):Void {
		debug('FDB exit code %s', e.exitCode);
		GlobalEventDispatcher.getInstance().removeEventListener(ActionScriptBuildEvent.STOP_DEBUG, stopDebugHandler);
		fdb = null;
	}

	private function postbuild(e:Event):Void {
		function alertListener(eventObj:CloseEvent):Void {
			// Check to see if the OK button was pressed.
			if (eventObj.detail == Alert.YES) {
				stopDebugger();
				as3hx.Compat.setTimeout(postbuild, 1000, [e]);
			} else {
				return;
			}
		};
		// In case we have no SDK set we fail silently (MXMLCPlugin will be all over it).
		if (currentSDK == null) {
			return;
		}
		if (fdb == null) {
			print('2 in MXMLCPlugin debugafterBuild');
			initDebugger();
			send('run');
			GlobalEventDispatcher.getInstance().addEventListener(ActionScriptBuildEvent.STOP_DEBUG, stopDebugHandler);
			GlobalEventDispatcher.getInstance().addEventListener(ActionScriptBuildEvent.EXIT_FDB, exitFDBHandler);
		}// Alert for terminate current debug session
		else {
			// Alert for terminate current debug session
			Alert.show('You are already debugging an application. Do you wish to terminate the existing debugging session, and start a new session?', '', Alert.YES | Alert.CANCEL, null, alertListener, null, Alert.CANCEL);
		}
	}

	private function stopDebugHandler(e:ActionScriptBuildEvent):Void {
		if (fdb != null) {
			stopDebugger();
		}
		GlobalEventDispatcher.getInstance().removeEventListener(ActionScriptBuildEvent.STOP_DEBUG, stopDebugHandler);
	}

	// remoce trace line from editor and unlaunch swf
	private function stopDebugger():Void {
		for (contentWindow in as3hx.Compat.each(model.editors)) {
			var ed:BasicTextEditor = AS3.as(contentWindow, BasicTextEditor);
			if (ed != null) {
				ed.getEditorComponent().model.hasTraceSelection = false;
				ed.getEditorComponent().updateSelection();
				ed.getEditorComponent().updateTraceSelection();
				ed.getEditorComponent().removeTraceSelection();
			}
		}
		//unregister "F6" command
		dispatcher.removeEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, handleCodeStepOver);
		if (!isSession) {
			fdb.closeInput();
		}
		sessionStop();
		fdb.exit(true);
		startShell(false);
		GlobalEventDispatcher.getInstance().dispatchEvent(new SWFLaunchEvent(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, null));
	}

	private function send(msg:String):Void {
		debug('Send to fdb: %s', msg);
		var input:IDataOutput = fdb.standardInput;
		input.writeUTFBytes(msg + '\n');
	}

}