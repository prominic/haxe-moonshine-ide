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

import flash.errors.URIError;
import actionScripts.events.SdkEvent;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.utils.HtmlFormatter;
import actionScripts.utils.GetProjectSDKPath;
import actionScripts.valueObjects.Settings;
import no.doomsday.console.ConsoleUtil;
import actionScripts.valueObjects.ProjectVO;
import flash.events.EventDispatcher;
import actionScripts.ui.editor.ActionScriptTextEditor;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.events.EditorPluginEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.events.FilePluginEvent;

@:meta(Event(name = 'init', type = 'flash.events.Event'))
@:meta(Event(name = 'close', type = 'flash.events.Event'))
class ActionScriptLanguageServerManager extends EventDispatcher implements ILanguageServerManager {

	private static inline var LANGUAGE_SERVER_BIN_PATH:String = 'elements/as3mxml-language-server/bin/';
	private static inline var BUNDLED_COMPILER_PATH:String = 'elements/as3mxml-language-server/bundled-compiler/';
	private static inline var LANGUAGE_ID_ACTIONSCRIPT:String = 'nextgenas';
	private static inline var METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = 'workspace/didChangeConfiguration';
	private static inline var METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION:String = 'moonshine/didChangeProjectConfiguration';

	private static inline var URI_SCHEME_FILE:String = 'file';
	private static inline var URI_SCHEME_SWC:String = 'swc';

	private static var URI_SCHEMES(default, never):Array<String> = [URI_SCHEME_SWC];
	private static var FILE_EXTENSIONS(default, never):Array<String> = ['as', 'mxml'];

	private var _project:AS3ProjectVO;
	private var _port:Int = 0;
	private var _languageClient:LanguageClient;
	private var _model:IDEModel = IDEModel.getInstance();
	private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var _shellInfo:NativeProcessStartupInfo;
	private var _nativeProcess:NativeProcess;
	private var _waitingToRestart:Bool = false;
	private var _previousJavaPath:String = null;
	private var _previousSDKPath:String = null;

	public function new(project:AS3ProjectVO) {
		super();
		_project = project;

		_project.addEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
		_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
		_dispatcher.addEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler);
		_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler);
		//when adding new listeners, don't forget to also remove them in
		//dispose()

		startNativeProcess();
	}

	public var project(get, never):ProjectVO;
	private function get_project():ProjectVO {
		return _project;
	}

	public var uriSchemes(get, never):Array<String>;
	private function get_uriSchemes():Array<String> {
		return URI_SCHEMES;
	}

	public var fileExtensions(get, never):Array<String>;
	private function get_fileExtensions():Array<String> {
		return FILE_EXTENSIONS;
	}

	public var active(get, never):Bool;
	private function get_active():Bool {
		return _languageClient != null && _languageClient.initialized;
	}

	public function createTextEditorForUri(uri:String, readOnly:Bool = false):BasicTextEditor {
		var colonIndex:Int = uri.indexOf(':');
		if (colonIndex == -1) {
			throw new URIError('Invalid URI: ' + uri);
		}
		var scheme:String = uri.substr(0, colonIndex);

		var editor:ActionScriptTextEditor = new ActionScriptTextEditor(readOnly);
		if (scheme == URI_SCHEME_FILE) {
			//the regular OpenFileEvent should be used to open this one
			return editor;
		}
		switch (scheme) {
			case URI_SCHEME_SWC:
				var label:String = uri;
				var args:String = null;
				var argsIndex:Int = uri.indexOf('?');
				if (argsIndex != -1) {
					label = uri.substr(0, argsIndex);
					args = uri.substr(argsIndex + 1);
				}
				var lastSlashIndex:Int = label.lastIndexOf('/');
				if (lastSlashIndex != -1) {
					label = label.substr(lastSlashIndex + 1);
				}
				args = StringTools.urlDecode(args);

				var extension:String = '';
				var dotIndex:Int = label.lastIndexOf('.');
				if (dotIndex != -1) {
					extension = label.substr(dotIndex + 1);
				}
				editor.defaultLabel = label;

				var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
				editorEvent.editor = editor.getEditorComponent();
				editorEvent.fileExtension = extension;
				GlobalEventDispatcher.getInstance().dispatchEvent(editorEvent);

				//editor.open() must be called after EditorPluginEvent.EVENT_EDITOR_OPEN
				//is dispatched or the syntax highlighting will not work
				editor.open(null, args);
			case _:
				{
					throw new URIError('Unknown URI scheme for ActionScript and MXML: ' + scheme);
				}
		}
		return editor;
	}

	private function dispose():Void {
		cleanupLanguageClient();

		_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
		_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
		_dispatcher.removeEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler);
		_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler);
	}

	private function cleanupLanguageClient():Void {
		if (_languageClient == null) {
			return;
		}
		_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
		_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
		_languageClient = null;
	}

	private function startNativeProcess():Void {
		if (_nativeProcess != null) {
			trace('Error: AS3 & MXML language server process already exists!');
			return;
		}
		var jdkFolder:File = null;
		if (AS3.as(_model.javaPathForTypeAhead, Bool)) {
			jdkFolder = AS3.as(_model.javaPathForTypeAhead.fileBridge.getFile, File);
		}
		var sdkPath:String = Std.string(GetProjectSDKPath.getProjectSDKPath(_project, _model));
		if (jdkFolder == null || sdkPath == null) {
			//we'll need to try again later if the settings change
			_previousJavaPath = null;
			_previousSDKPath = null;
			return;
		}
		_previousJavaPath = Std.string(jdkFolder.nativePath);
		_previousSDKPath = sdkPath;

		var javaFileName:String = ((Settings.os == 'win')) ? 'java.exe' : 'java';
		var cmdFile:File = jdkFolder.resolvePath(javaFileName);
		if (!AS3.as(cmdFile.exists, Bool)) {
			cmdFile = jdkFolder.resolvePath('bin/' + javaFileName);
		}

		var frameworksPath:String = Std.string((new File(sdkPath)).resolvePath('frameworks').nativePath);

		var processArgs:Array<String> = [];
		_shellInfo = new NativeProcessStartupInfo();
		var cp:String = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_BIN_PATH).nativePath + File.separator + '*';
		if (Settings.os == 'win') {
			cp += ';';
		} else {
			cp += ':';
		}
		cp += File.applicationDirectory.resolvePath(BUNDLED_COMPILER_PATH).nativePath + File.separator + '*';
		processArgs.push('-Dfile.encoding=UTF8');
		processArgs.push('-Droyalelib=' + frameworksPath);
		processArgs.push('-cp');
		processArgs.push(cp);
		processArgs.push('moonshine.Main');
		_shellInfo.arguments = processArgs;
		_shellInfo.executable = cmdFile;
		_shellInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);

		_nativeProcess = new NativeProcess();
		_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		_nativeProcess.start(_shellInfo);

		initializeLanguageServer(sdkPath);

		GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS, 'ActionScript', 'Starting ActionScript & MXML code intelligence...'));
	}

	private function initializeLanguageServer(sdkPath:String):Void {
		if (_languageClient != null) {
			//we're already initializing or initialized...
			trace('Error: AS3 & MXML language client already exists!');
			return;
		}

		trace('AS3 & MXML language server workspace root: ' + project.folderPath);
		trace('AS3 & MXML language server SDK: ' + sdkPath);

		var debugMode:Bool = false;
		_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT, _project, debugMode, {},
				_dispatcher, _nativeProcess.standardOutput, _nativeProcess, Std.string(ProgressEvent.STANDARD_OUTPUT_DATA), _nativeProcess.standardInput);
		_languageClient.registerScheme('swc');
		_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
		_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
	}

	private function restartLanguageServer():Void {
		if (_waitingToRestart) {
			//we'll just continue waiting
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

	private function sendWorkspaceSettings():Void {
		if (_languageClient == null || !_languageClient.initialized) {
			return;
		}
		var frameworkSDK:String = Std.string(GetProjectSDKPath.getProjectSDKPath(_project, _model));
		var settings:Dynamic = {
			'as3mxml': {
				'sdk': {
					'framework': frameworkSDK
				}
			}
		};

		var params:Dynamic = {};
		Reflect.setField(params, 'settings', settings);
		_languageClient.sendNotification(METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION, params);
	}

	private function sendProjectConfiguration():Void {
		if (_languageClient == null || !_languageClient.initialized) {
			return;
		}
		var buildOptions:BuildOptions = _project.buildOptions;
		var type:String = 'app';
		if (AS3.as(_project.isLibraryProject, Bool)) {
			type = 'lib';
		}
		var config:String = 'flex';
		if (AS3.as(_project.air, Bool)) {
			if (AS3.as(_project.isMobile, Bool)) {
				config = 'airmobile';
			} else {
				config = 'air';
			}
		} else if (AS3.as(_project.isRoyale, Bool)) {
			config = 'royale';
		}

		//the config file may not exist, or it may be out of date, so
		//we're going to tell the project to update it immediately
		_project.updateConfig();
		if (AS3.as(_project.config.file, Bool)) {
			var projectPath:File = new File(project.folderLocation.fileBridge.nativePath);
			var configPath:File = new File(_project.config.file.fileBridge.nativePath);
			var buildArgs:String = '-load-config+=' +
			projectPath.getRelativePath(configPath, true);' ' +
			buildOptions.getArguments();
		} else {
			buildArgs = Std.string(buildOptions.getArguments());
		}

		var files:Array<Dynamic> = [];
		var filesCount:Int = AS3.int(_project.targets.length);
		for (i in 0...filesCount) {
			var file:String = Std.string(Reflect.getProperty(_project.targets, Std.string(i)).fileBridge.nativePath);
			files[i] = file;
		}

		//all of the compiler options are actually included in buildArgs,
		//but the language server needs to be able to read some of them more
		//easily, so we pass them in manually
		var compilerOptions:Dynamic = {};
		var sourcePathCount:Int = AS3.int(_project.classpaths.length);
		if (sourcePathCount > 0) {
			var sourcePaths:Array<Dynamic> = [];
			for (i in 0...sourcePathCount) {
				var sourcePath:String = Std.string(Reflect.getProperty(_project.classpaths, Std.string(i)).fileBridge.nativePath);
				sourcePaths[i] = sourcePath;
			}
			Reflect.setField(compilerOptions, 'source-path', sourcePaths);
		}

		//this object is designed to be similar to the asconfig.json
		//format used by vscode-nextgenas
		//https://github.com/BowlerHatLLC/vscode-nextgenas/wiki/asconfig.json
		//https://github.com/BowlerHatLLC/vscode-nextgenas/blob/master/distribution/src/assembly/schemas/asconfig.schema.json
		var params:Dynamic = {};
		Reflect.setField(params, 'type', type);
		Reflect.setField(params, 'config', config);
		Reflect.setField(params, 'files', files);
		Reflect.setField(params, 'compilerOptions', compilerOptions);
		Reflect.setField(params, 'additionalOptions', buildArgs);
		_languageClient.sendNotification(METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION, params);
	}

	private function shellError(e:ProgressEvent):Void {
		var output:IDataInput = _nativeProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		ConsoleUtil.print('shellError ' + data + '.');
		ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
		trace(data);
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		if (_languageClient != null) {
			//this should have already happened, but if the process exits
			//abnormally, it might not have
			_languageClient.stop();

			ConsoleOutputter.formatOutput(
					'ActionScript & MXML language server exited unexpectedly. Close the ' + project.name + ' project and re-open it to enable code intelligence.',
					'warning'
			);
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

	private function languageClient_initHandler(event:Event):Void {
		sendProjectConfiguration();

		this.dispatchEvent(new Event(Event.INIT));

		GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS));
	}

	private function languageClient_closeHandler(event:Event):Void {
		if (_waitingToRestart) {
			cleanupLanguageClient();
			//the native process will automatically exit, so we continue
			//waiting for that to complete
		} else {
			this.dispose();
		}
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function projectChangeCustomSDKHandler(event:Event):Void {
		//restart only when the path has changed
		if (GetProjectSDKPath.getProjectSDKPath(_project, _model) != _previousSDKPath) {
			restartLanguageServer();
		}
	}

	private function changeMenuSDKStateHandler(event:Event):Void {
		//restart only when the path has changed
		if (GetProjectSDKPath.getProjectSDKPath(_project, _model) != _previousSDKPath) {
			restartLanguageServer();
		}
	}

	private function javaPathSaveHandler(event:FilePluginEvent):Void {
		var javaPath:String = null;
		if (AS3.as(_model.javaPathForTypeAhead, Bool)) {
			var javaFile:File = AS3.as(_model.javaPathForTypeAhead.fileBridge.getFile, File);
			javaPath = Std.string(javaFile.nativePath);
		}
		//restart only when the path has changed
		if (javaPath != _previousJavaPath) {
			restartLanguageServer();
		}
	}

	private function saveProjectSettingsHandler(event:ProjectEvent):Void {
		if (event.project != _project) {
			return;
		}
		sendProjectConfiguration();
	}

}