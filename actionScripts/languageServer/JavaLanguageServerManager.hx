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
package actionScripts.languageServer;

import flash.errors.Error;import flash.errors.URIError;import haxe.Constraints.Function;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.languageServer.LanguageClient;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.utils.HtmlFormatter;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import no.doomsday.console.ConsoleUtil;
import flash.events.EventDispatcher;
import mx.utils.SHA256;
import flash.utils.ByteArray;
import components.popup.StandardPopup;
import spark.components.Button;
import flash.events.MouseEvent;
import mx.managers.PopUpManager;
import mx.core.FlexGlobals;
import flash.display.DisplayObject;
import actionScripts.events.ExecuteLanguageServerCommandEvent;
import flash.net.URLRequest;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.ui.editor.JavaTextEditor;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.events.StatusBarEvent;
import actionScripts.utils.ApplyWorkspaceEdit;
import actionScripts.valueObjects.WorkspaceEdit;
import actionScripts.events.FilePluginEvent;
import actionScripts.utils.GetProjectSDKPath;
import actionScripts.factory.FileLocation;

@:meta(Event(name = 'init', type = 'flash.events.Event'))

@:meta(Event(name = 'close', type = 'flash.events.Event'))
class JavaLanguageServerManager extends EventDispatcher implements ILanguageServerManager {

	public var project(get, never):ProjectVO;
	public var uriSchemes(get, never):Array<String>;
	public var fileExtensions(get, never):Array<String>;
	public var active(get, never):Bool;

	//when updating the JDT language server, the name of this JAR file will
	//change, and Moonshine will automatically update the version that is
	//copied to File.applicationStorageDirectory
	private static inline var LANGUAGE_SERVER_JAR_PATH:String = 'plugins/org.eclipse.equinox.launcher_1.5.200.v20180922-1751.jar';

	private static inline var LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = 'config_win';

	private static inline var LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = 'config_mac';

	private static inline var PATH_WORKSPACE_STORAGE:String = 'java/workspaces';

	private static inline var PATH_JDT_LANGUAGE_SERVER_APP:String = 'elements/jdt-language-server';

	private static inline var PATH_JDT_LANGUAGE_SERVER_STORAGE:String = 'java/jdt-language-server';

	private static inline var LANGUAGE_ID_JAVA:String = 'java';

	private static inline var METHOD_LANGUAGE__STATUS:String = 'language/status';

	private static inline var METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = 'language/actionableNotification';

	private static inline var COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:String = 'java.ignoreIncompleteClasspath.help';

	private static inline var COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:String = 'java.ignoreIncompleteClasspath';

	private static inline var COMMAND_JAVA_APPLY_WORKSPACE_EDIT:String = 'java.apply.workspaceEdit';

	private static inline var URI_SCHEME_FILE:String = 'file';

	private static var URI_SCHEMES:Array<String> = [];

	private static var FILE_EXTENSIONS:Array<String> = ['java'];

	private var _project:JavaProjectVO;

	private var _languageClient:LanguageClient;

	private var _model:IDEModel = IDEModel.getInstance();

	private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var _shellInfo:NativeProcessStartupInfo;

	private var _nativeProcess:NativeProcess;

	private var _languageStatusDone:Bool = false;

	private var _waitingToRestart:Bool = false;

	private var _previousJDKPath:String = null;

	public function new(project:JavaProjectVO) {
		super();
		_project = project;

		//when adding new listeners, don't forget to also remove them in
		//dispose()
		_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
		_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);

		prepareApplicationStorage();
		startNativeProcess();
	}

	private function get_project():ProjectVO {
		return _project;
	}

	private function get_uriSchemes():Array<String> {
		return URI_SCHEMES;
	}

	private function get_fileExtensions():Array<String> {
		return FILE_EXTENSIONS;
	}

	private function get_active():Bool {
		return _languageClient && _languageClient.initialized;
	}

	public function createTextEditorForUri(uri:String, readOnly:Bool = false):BasicTextEditor {
		var colonIndex:Int = uri.indexOf(':');
		if (colonIndex == -1) {
			throw new URIError('Invalid URI: ' + uri);
		}
		var scheme:String = uri.substr(0, colonIndex);

		var editor:JavaTextEditor = new JavaTextEditor(readOnly);
		if (scheme == URI_SCHEME_FILE)
		//the regular OpenFileEvent should be used to open this one
		{

			return editor;
		}
		switch (scheme) {
			case _:
				{
					throw new URIError('Unknown URI scheme for Java: ' + scheme);
				}
		}
		return editor;
	}

	private function dispose():Void {
		_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
		_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
		cleanupLanguageClient();
	}

	private function cleanupLanguageClient():Void {
		if (_languageClient == null) {
			return;
		}
		_languageStatusDone = false;
		_languageClient.removeNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
		_languageClient.removeNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
		_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
		_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
		_languageClient = null;
	}

	private function prepareApplicationStorage():Void {
		var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
		var jarFile:File = storageFolder.resolvePath(LANGUAGE_SERVER_JAR_PATH);
		if (jarFile.exists)
		//we've already copied the files to application storage, so
		{

			//we're good to go!
			return;
		}
		var appFolder:File = File.applicationDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_APP);
		//this directory may already exist, if an older version of Moonshine
		//with an older version of the JDT language server was installed
		//we don't want conflicts between JDT language server versions, so
		//delete the entire directory and start fresh
		var showStorageError:Bool = false;
		try {
			if (storageFolder.exists) {
				storageFolder.deleteDirectory(true);
			}
			appFolder.copyTo(storageFolder);
		} catch (error:Error) {
			showStorageError = true;
		}
		if (showStorageError || !storageFolder.exists || !jarFile.exists)
		//something went wrong!
		{

			var message:String = 'Error initializing Java language server. Please delete the following folder, if it exists, and restart Moonshine: ' + storageFolder.nativePath;
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);
		}
	}

	private function startNativeProcess():Void {
		if (_nativeProcess != null) {
			trace('Error: Java language server process already exists!');
			return;
		}
		var jdkPath:String = getProjectSDKPath(_project, _model);
		_previousJDKPath = jdkPath;
		if (jdkPath == null) {
			return;
		}

		var jdkFolder:File = new File(jdkPath);

		var javaFileName:String = ((Settings.os == 'win')) ? 'java.exe' : 'java';
		var cmdFile:File = jdkFolder.resolvePath(javaFileName);
		if (!cmdFile.exists) {
			cmdFile = jdkFolder.resolvePath('bin/' + javaFileName);
		}

		var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
		var processArgs:Array<String> = [];
		_shellInfo = new NativeProcessStartupInfo();
		var jarFile:File = storageFolder.resolvePath(LANGUAGE_SERVER_JAR_PATH);
		processArgs.push('-Declipse.application=org.eclipse.jdt.ls.core.id1');
		processArgs.push('-Dosgi.bundles.defaultStartLevel=4');
		processArgs.push('-Declipse.product=org.eclipse.jdt.ls.core.product');
		processArgs.push('-noverify');
		processArgs.push('-Xmx1G');
		processArgs.push('-XX:+UseG1GC');
		processArgs.push('-XX:+UseStringDeduplication');
		processArgs.push('-jar');
		processArgs.push(jarFile.nativePath);
		processArgs.push('-configuration');
		var configFile:File = null;
		if (ConstantsCoreVO.IS_MACOS) {
			configFile = storageFolder.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
		} else {
			configFile = storageFolder.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
		}
		processArgs.push(configFile.nativePath);
		processArgs.push('-data');
		//this is a file outside of the project folder due to limitations
		//of the language server, which is based on Eclipse
		processArgs.push(getWorkspaceNativePath());
		_shellInfo.arguments = processArgs;
		_shellInfo.executable = cmdFile;
		_shellInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);

		_nativeProcess = new NativeProcess();
		_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		_nativeProcess.start(_shellInfo);

		initializeLanguageServer(jdkPath);
	}

	private function getWorkspaceNativePath():String
	//we need to store the language server's data files somewhere, but
	 {

		//it CANNOT be inside the project directory. let's put them in the
		//app storage directory instead.
		var projectPath:String = _project.folderLocation.fileBridge.nativePath;
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes(projectPath);
		//we need to differentiate between different projects that have
		//the same name, so let's use a hash of the full path
		var digest:String = SHA256.computeDigest(bytes);
		bytes.clear();
		var workspaceLocation:File = File.applicationStorageDirectory.resolvePath(PATH_WORKSPACE_STORAGE).resolvePath(digest);
		return workspaceLocation.nativePath;
	}

	private function initializeLanguageServer(sdkPath:String):Void {
		if (_languageClient != null)
		//we're already initializing or initialized...
		{

			trace('Error: Java language client already exists!');
			return;
		}

		trace('Java language server workspace root: ' + project.folderPath);
		trace('Java language Server JDK: ' + sdkPath);

		var initOptions:Dynamic =
		{
			bundles: [],
			workspaceFolders: [_project.projectFolder.file.fileBridge.url],
			settings: { /*java: getJavaConfiguration()*/
			},
			extendedClientCapabilities:
			{
				progressReportProvider: false,
				classFileContentsSupport: false
			}
		};

		_languageStatusDone = false;
		var debugMode:Bool = false;
		_languageClient = new LanguageClient(LANGUAGE_ID_JAVA, _project, debugMode, initOptions,
				_dispatcher, _nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
		_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
		_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
		_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
		_languageClient.addNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
	}

	private function restartLanguageServer():Void {
		if (_waitingToRestart)
		//we'll just continue waiting
		{

			return;
		}
		_waitingToRestart = false;
		if (_languageClient != null) {
			_waitingToRestart = true;
			_languageClient.stop();
		} else if (_nativeProcess != null) {
			_waitingToRestart = true;
			_nativeProcess.exit();
		}

		if (!_waitingToRestart) {
			startNativeProcess();
		}
	}

	private function createCommandListener(command:String, args:Array<Dynamic>, popup:StandardPopup):Function {
		return function(event:Event):Void {
			_dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
					ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
					command, (args != null) ? args : []));
			if (popup != null) {
				PopUpManager.removePopUp(popup);
				popup.data = null;
			}
		};
	}

	private function shellError(e:ProgressEvent):Void {
		var output:IDataInput = _nativeProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		ConsoleUtil.print('shellError ' + data + '.');
		ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
		trace(data);
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		if (_languageClient != null)
		//this should have already happened, but we should clean it up
		{

			//just to be safe
			cleanupLanguageClient();
		}
		_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
		_nativeProcess.exit();
		_nativeProcess = null;
		if (_waitingToRestart) {
			_waitingToRestart = false;
			startNativeProcess();
		}
	}

	private function jdkPathSaveHandler(event:FilePluginEvent):Void
	//restart only when the path has changed
	 {

		if (getProjectSDKPath(_project, _model) != _previousJDKPath) {
			restartLanguageServer();
		}
	}

	private function executeLanguageServerCommandHandler(event:ExecuteLanguageServerCommandEvent):Void {
		if (event.isDefaultPrevented())
		//already handled somewhere else
		{

			return;
		}
		var _sw0_ = (event.command);
		switch (_sw0_) {
			case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:
			{
				event.preventDefault();
				trace('TODO: update the java.errors.incompleteClasspath.severity setting');
			}
			case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:
			{
				event.preventDefault();
				flash.Lib.getURL(new URLRequest('https://github.com/redhat-developer/vscode-java/wiki/%22Classpath-is-incomplete%22-warning'), '_blank');
			}
			case COMMAND_JAVA_APPLY_WORKSPACE_EDIT:
			{
				event.preventDefault();
				var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(event.arguments[0]);
				applyWorkspaceEdit(workspaceEdit);
			}
		}
	}

	private function languageClient_initHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.INIT));
	}

	private function languageClient_closeHandler(event:Event):Void {
		if (_waitingToRestart) {
			cleanupLanguageClient();
		} else {
			dispose();
		}
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function language__status(message:Dynamic):Void {
		if (_languageStatusDone) {
			return;
		}
		var _sw1_ = (message.params.type);
		switch (_sw1_) {
			case 'Starting':
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						'Java', message.params.message, false));
			}
			case 'Message':
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						'Java', message.params.message, false));
			}
			case 'Started':
			{
				_languageStatusDone = true;
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS));
			}
			case 'Error':
			{
				_languageStatusDone = true;
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS));
			}
			case _:
				{
					trace('Unknown ' + METHOD_LANGUAGE__STATUS + ' message type:', message.params.type);
					break;
				}
		}
	}

	private function language__actionableNotification(notification:Dynamic):Void {
		var params:Dynamic = notification.params;
		var severity:Int = as3hx.Compat.parseInt(notification.severity);
		var message:String = params.message;
		var commands:Array<Dynamic> = try cast(params.commands, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;

		if (severity == 4)
		//log
		{

			{
				_dispatcher.dispatchEvent(
						new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, ConsoleOutputEvent.TYPE_INFO)
			);
				trace(message);
				return;
			}
		}

		var popup:StandardPopup = new StandardPopup();
		popup.data = this; // Keep the command from getting GC'd
		popup.text = message;

		var buttons:Array<Dynamic> = [];
		var commandCount:Int = commands.length;
		for (i in 0...commandCount) {
			var command:Dynamic = commands[i];
			var title:String = Std.string(command.title);
			var commandName:String = command.command;
			var args:Array<Dynamic> = try cast(command.arguments, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;

			var button:Button = new Button();
			button.styleName = 'lightButton';
			button.label = title;
			button.addEventListener(MouseEvent.CLICK, createCommandListener(commandName, args, popup), false, 0, false);
			buttons.push(button);
		}

		popup.buttons = buttons;

		PopUpManager.addPopUp(popup, try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, true);
		popup.y = ((ConstantsCoreVO.IS_MACOS)) ? 25 : 45;
		popup.x = (FlexGlobals.topLevelApplication.width - popup.width) / 2;
	}

}