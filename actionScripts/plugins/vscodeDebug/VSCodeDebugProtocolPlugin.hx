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
package actionScripts.plugins.vscodeDebug;

import actionScripts.events.ApplicationEvent;
import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import actionScripts.events.EditorPluginEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugins.vscodeDebug.events.LoadVariablesEvent;
import actionScripts.plugins.vscodeDebug.events.StackFrameEvent;
import actionScripts.plugins.vscodeDebug.view.VSCodeDebugProtocolView;
import actionScripts.plugins.vscodeDebug.vo.BaseVariablesReference;
import actionScripts.plugins.vscodeDebug.vo.Scope;
import actionScripts.plugins.vscodeDebug.vo.Source;
import actionScripts.plugins.vscodeDebug.vo.StackFrame;
import actionScripts.plugins.vscodeDebug.vo.Variable;
import actionScripts.plugins.vscodeDebug.vo.VariablesReferenceHierarchicalData;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.DebugHighlightManager;
import actionScripts.ui.editor.text.events.DebugLineEvent;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.FindAndCopyApplicationDescriptor;
import actionScripts.utils.FindOpenPort;
import actionScripts.utils.GetProjectSDKPath;
import actionScripts.valueObjects.Settings;
class VSCodeDebugProtocolPlugin extends PluginBase {

	public var connected(get, set):Bool;

	public static inline var EVENT_SHOW_HIDE_DEBUG_VIEW:String = 'EVENT_SHOW_HIDE_DEBUG_VIEW';

	private static inline var MAX_RETRY_COUNT:Int = 5;

	private static inline var TWO_CRLF:String = '\r\n\r\n';

	private static inline var CONTENT_LENGTH_PREFIX:String = 'Content-Length: ';

	private static inline var MESSAGE_TYPE_REQUEST:String = 'request';

	private static inline var MESSAGE_TYPE_RESPONSE:String = 'response';

	private static inline var MESSAGE_TYPE_EVENT:String = 'event';

	private static inline var COMMAND_INITIALIZE:String = 'initialize';

	private static inline var COMMAND_LAUNCH:String = 'launch';

	private static inline var COMMAND_ATTACH:String = 'attach';

	private static inline var COMMAND_THREADS:String = 'threads';

	private static inline var COMMAND_SET_BREAKPOINTS:String = 'setBreakpoints';

	private static inline var COMMAND_PAUSE:String = 'pause';

	private static inline var COMMAND_CONTINUE:String = 'continue';

	private static inline var COMMAND_NEXT:String = 'next';

	private static inline var COMMAND_STEP_IN:String = 'stepIn';

	private static inline var COMMAND_STEP_OUT:String = 'stepOut';

	private static inline var COMMAND_DISCONNECT:String = 'disconnect';

	private static inline var COMMAND_SCOPES:String = 'scopes';

	private static inline var COMMAND_STACK_TRACE:String = 'stackTrace';

	private static inline var COMMAND_VARIABLES:String = 'variables';

	private static inline var EVENT_INITIALIZED:String = 'initialized';

	private static inline var EVENT_BREAKPOINT:String = 'breakpoint';

	private static inline var EVENT_OUTPUT:String = 'output';

	private static inline var EVENT_STOPPED:String = 'stopped';

	private static inline var EVENT_TERMINATED:String = 'terminated';

	private static inline var REQUEST_LAUNCH:String = 'launch';

	private static inline var OUTPUT_CATEGORY_STDERR:String = 'stderr';

	private static inline var LANGUAGE_SERVER_BIN_PATH:String = 'elements/as3mxml-language-server/bin/';

	override private function get_name():String {
		return 'VSCode Debug Protocol Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Debugs ActionScript and MXML projects with the Visual Studio Code Debug Protocol.';
	}

	private var _breakpoints:Dynamic = {};

	private var _debugPanel:VSCodeDebugProtocolView;

	private var _nativeProcess:NativeProcess;

	private var _socket:Socket;

	private var _byteArray:ByteArray;

	private var _port:Int;

	private var _retryCount:Int;

	private var _paused:Bool = true;

	private var _seq:Int = 0;

	private var _messageBuffer:String = '';

	private var _bodyLength:Int = -1;

	private var mainThreadID:Int = -1;

	private var _stackFrames:ArrayCollection;

	private var _scopesAndVars:VariablesReferenceHierarchicalData;

	private var _variablesLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var _currentProject:AS3ProjectVO;

	private var isStartupCall:Bool = true;

	private var isDebugViewVisible:Bool;

	private var _connected:Bool = false;

	private function set_connected(value:Bool):Bool {
		DebugHighlightManager.IS_DEBUGGER_CONNECTED = _connected = value;
		return value;
	}

	private function get_connected():Bool {
		return _connected;
	}

	public function new() {
		super();
		_byteArray = new ByteArray();
	}

	override public function activate():Void {
		super.activate();

		this._debugPanel = new VSCodeDebugProtocolView();

		dispatcher.addEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
		dispatcher.addEventListener(ActionScriptBuildEvent.POSTBUILD, dispatcher_postBuildHandler);
		///dispatcher.addEventListener(ActionScriptBuildEvent.PREBUILD, handleCompile);
		dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
		/*dispatcher.addEventListener(MenuPlugin.MENU_SAVE_EVENT, handleEditorSave);
		dispatcher.addEventListener(MenuPlugin.MENU_SAVE_AS_EVENT, handleEditorSave);*/
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
		dispatcher.addEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, stepOverExecutionHandler);
		dispatcher.addEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, continueExecutionHandler);
		dispatcher.addEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, terminateExecutionHandler);
		dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_quitHandler);
		dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);

		DebugHighlightManager.init();
	}

	override public function deactivate():Void {
		super.deactivate();

		dispatcher.removeEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
		dispatcher.removeEventListener(ActionScriptBuildEvent.POSTBUILD, dispatcher_postBuildHandler);
		dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
		dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
		dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_quitHandler);
	}

	private function saveEditorBreakpoints(editor:BasicTextEditor):Void {
		if (editor == null) {
			return;
		}
		if (!editor.currentFile) {
			return;
		}

		var path:String = editor.currentFile.fileBridge.nativePath;
		if (path == '') {
			return;
		}

		this._breakpoints[path] = editor.getEditorComponent().breakpoints;
	}

	private function cleanupSocket():Void {
		if (_socket == null) {
			return;
		}
		_socket.removeEventListener(Event.CONNECT, socket_connectHandler);
		_socket.removeEventListener(IOErrorEvent.IO_ERROR, socketConnect_ioErrorHandler);
		_socket.removeEventListener(IOErrorEvent.IO_ERROR, socket_ioErrorHandler);
		_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socketConnect_securityErrorHandler);
		_socket.removeEventListener(ProgressEvent.SOCKET_DATA, socket_socketDataHandler);
		_socket.removeEventListener(Event.CLOSE, socket_closeHandler);
		_socket = null;
	}

	private function connectToProcess():Void {
		if (_nativeProcess == null) {
			Alert.show('Could not connect to the SWF debugger. Debugger stopped before connection completed.', 'Debug Error', Alert.OK);
			return;
		}
		cleanupSocket();
		_socket = new Socket();
		_socket.addEventListener(Event.CONNECT, socket_connectHandler);
		_socket.addEventListener(IOErrorEvent.IO_ERROR, socketConnect_ioErrorHandler);
		_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketConnect_securityErrorHandler);
		_socket.connect('localhost', _port);
	}

	private function parseMessageBuffer():Void {
		if (this._bodyLength != -1) {
			if (this._messageBuffer.length < this._bodyLength)
			//we don't have the full body yet
			{

				return;
			}
			var body:String = this._messageBuffer.substr(0, this._bodyLength);
			this._messageBuffer = this._messageBuffer.substr(this._bodyLength);
			this._bodyLength = -1;
			var message:Dynamic = haxe.Json.parse(body);
			this.parseProtocolMessage(message);
		} else if (this._messageBuffer.length > CONTENT_LENGTH_PREFIX.length)
		//start with a new header
		{

			var index:Int = this._messageBuffer.indexOf(TWO_CRLF, CONTENT_LENGTH_PREFIX.length);
			if (index == -1)
			//we don't have a full header yet
			{

				return;
			}
			var lengthString:String = this._messageBuffer.substr(CONTENT_LENGTH_PREFIX.length, index - CONTENT_LENGTH_PREFIX.length);
			this._bodyLength = as3hx.Compat.parseInt(lengthString, 10);
			this._messageBuffer = this._messageBuffer.substr(index + TWO_CRLF.length);
		}
		//we don't have a full header yet
		else {

			return;
		}
		//keep trying to parse until we hit one of the return statements
		//above
		this.parseMessageBuffer();
	}

	private function sendRequest(command:String, args:Dynamic = null):Void {
		_seq++;
		var message:Dynamic =
		{
			type: MESSAGE_TYPE_REQUEST,
			seq: _seq,
			command: command
		};
		if (args != null) {
			message.arguments = args;
		}
		sendProtocolMessage(message);
	}

	private function sendProtocolMessage(message:Dynamic):Void {
		var string:String = haxe.Json.stringify(message);
		_byteArray.clear();
		_byteArray.writeUTFBytes(string);
		var contentLength:String = Std.string(_byteArray.length);
		_byteArray.clear();
		_socket.writeUTFBytes(CONTENT_LENGTH_PREFIX);
		_socket.writeUTFBytes(contentLength);
		_socket.writeUTFBytes(TWO_CRLF);
		_socket.writeUTFBytes(string);
		_socket.flush();
	}

	private function parseProtocolMessage(message:Dynamic):Void {
		if (Lambda.has(message, 'type')) {
			var _sw0_ = (message.type);
			switch (_sw0_) {
				case MESSAGE_TYPE_RESPONSE:
				{
					this.parseResponse(message);
				}
				case MESSAGE_TYPE_EVENT:
				{
					this.parseEvent(message);
				}
				case _:
					{
						trace('Cannot parse debug message. Unknown type: "' + message.type + '", Full message:', haxe.Json.stringify(message));
					}
			}
		} else {
			trace('Cannot parse debug message. Missing type. Full message:', haxe.Json.stringify(message));
		}
	}

	private function parseResponse(response:Dynamic):Void {
		if (Lambda.has(response, 'command')) {
			var _sw1_ = (response.command);
			switch (_sw1_) {
				case COMMAND_INITIALIZE:
				{
					this.parseInitializeResponse(response);
				}
				case COMMAND_CONTINUE:
				{
					this.parseContinueResponse(response);
				}
				case COMMAND_THREADS:
				{
					this.parseThreadsResponse(response);
				}
				case COMMAND_SET_BREAKPOINTS:
				{
					this.parseSetBreakpointsResponse(response);
				}
				case COMMAND_STACK_TRACE:
				{
					this.parseStackTraceResponse(response);
				}
				case COMMAND_SCOPES:
				{
					this.parseScopesResponse(response);
				}
				case COMMAND_VARIABLES:
				{
					this.parseVariablesResponse(response);
				}
				case COMMAND_DISCONNECT:
				{
					this.parseDisconnectResponse(response);
				}
				case COMMAND_ATTACH, COMMAND_LAUNCH, COMMAND_PAUSE, COMMAND_STEP_IN, COMMAND_STEP_OUT, COMMAND_NEXT:
				{
					if (response.success == false) {
						trace(response.command + ' command not successful!');
					}
				}
				case _:
					{
						trace('Cannot parse debug response. Unknown command: "' + response.command + '", Full message:', haxe.Json.stringify(response));
					}
			}
		} else {
			trace('Cannot parse debug response. Missing command. Full message:', haxe.Json.stringify(response));
		}
	}

	private function parseEvent(event:Dynamic):Void {
		if (Lambda.has(event, 'event')) {
			var _sw2_ = (event.event);
			switch (_sw2_) {
				case EVENT_INITIALIZED:
				{
					this.parseInitializedEvent(event);
				}
				case EVENT_OUTPUT:
				{
					this.parseOutputEvent(event);
				}
				case EVENT_BREAKPOINT:
				{
					//we don't currently indicate if a breakpoint is verified or
					//not so, we can ignore this one.
					break;
				}
				case EVENT_STOPPED:
				{
					this.parseStoppedEvent(event);
				}
				case EVENT_TERMINATED:
				{
					this.parseTerminatedEvent(event);
				}
				case _:
					{
						trace('Cannot parse debug event. Unknown event:', '"' + event.event + '", Full message:', haxe.Json.stringify(event));
					}
			}
		} else {
			trace('Cannot parse debug event. Missing event. Full message:', haxe.Json.stringify(event));
		}
	}

	private function parseInitializeResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('initialize command not successful!');
			return;
		}
		if (_currentProject.isMobile && !_currentProject.buildOptions.isMobileRunOnSimulator) {
			sendAttachCommand();
		} else {
			sendLaunchCommand();
		}
	}

	private function sendAttachCommand():Void {
		this.sendRequest(COMMAND_ATTACH, {});
	}

	private function sendLaunchCommand():Void
	//try to figure out which "program" to launch, whether it's an
	 {

		//AIR application descriptor, an HTML file, or a SWF
		//var project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
		var body:Dynamic =
		{
			request: REQUEST_LAUNCH,
			program: _currentProject.swfOutput.path.fileBridge.nativePath
		};
		var binLocation:FileLocation = _currentProject.swfOutput.path.fileBridge.parent;
		var swfFile:File = try cast(_currentProject.swfOutput.path.fileBridge.getFile, File) catch (e:Dynamic) null;
		if (_currentProject.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			body.program = findAndCopyApplicationDescriptor(swfFile, _currentProject, try cast(binLocation.fileBridge.getFile, File) catch (e:Dynamic) null);

			if (_currentProject.isMobile) {
				body.profile = 'mobileDevice';

				//these options need to be configurable somehow
				//but these are reasonable defaults until then
				body.screensize = 'NexusOne';
				body.screenDPI = 252;
				body.versionPlatform = 'AND';
			}
		} else {
			var htmlFile:File = try cast(binLocation.resolvePath(_currentProject.swfOutput.path.fileBridge.name.split('.')[0] + '.html').fileBridge.getFile, File) catch (e:Dynamic) null;
			if (htmlFile.exists) {
				body.program = htmlFile.nativePath;
			}
		}
		this.sendRequest(COMMAND_LAUNCH, body);
	}

	private function parseContinueResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('continue command not successful!');
			return;
		}
		this._paused = false;
		refreshView();
	}

	private function parseThreadsResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('threads command not successful!');
			return;
		}
		this._paused = false;
		refreshView();

		var body:Dynamic = response.body;
		if (Lambda.has(body, 'threads')) {
			var threads:Array<Dynamic> = try cast(body.threads, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
			mainThreadID = threads[0].id;
		}
	}

	private function parseSetBreakpointsResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('setbreakpoints command not successful!');
			return;
		}
		if (mainThreadID == -1) {
			this.sendRequest(COMMAND_THREADS);
		}
	}

	private function parseStackTraceResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('stackTrace command not successful!');
			return;
		}
		var body:Dynamic = response.body;
		if (Lambda.has(body, 'stackFrames')) {
			this._stackFrames.removeAll();
			var stackFrames:Array<Dynamic> = try cast(body.stackFrames, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
			var stackFramesCount:Int = stackFrames.length;
			for (i in 0...stackFramesCount) {
				var stackFrame:StackFrame = this.parseStackFrame(stackFrames[i]);
				this._stackFrames.addItem(stackFrame);
			}
		}
		refreshView();
		if (this._stackFrames.length > 0) {
			var firstStackFrame:StackFrame = cast((this._stackFrames.getItemAt(0)), StackFrame);
			this.gotoStackFrame(firstStackFrame);
		}
	}

	private function parseStackFrame(response:Dynamic):StackFrame {
		var vo:StackFrame = new StackFrame();
		vo.id = as3hx.Compat.parseInt(response.id);
		vo.name = Std.string(response.name);
		vo.line = as3hx.Compat.parseInt(response.line);
		vo.column = as3hx.Compat.parseInt(response.column);
		vo.source = this.parseSource(response.source);
		return vo;
	}

	private function parseSource(response:Dynamic):Source {
		if (response == null)
		//the stack trace sometimes includes functions internal to the
		{

			//runtime that don't have a source. That's perfectly fine!
			return null;
		}
		var vo:Source = new Source();
		vo.name = Std.string(response.name);
		vo.path = Std.string(response.path);
		vo.sourceReference = as3hx.Compat.parseFloat(response.sourceReference);
		return vo;
	}

	private function loadVariables(scopeOrVar:BaseVariablesReference):Void {
		var nextSeq:Int = as3hx.Compat.parseInt(_seq + 1);
		this._variablesLookup[nextSeq] = scopeOrVar;
		this.sendRequest(COMMAND_VARIABLES,
				{
					variablesReference: scopeOrVar.variablesReference
				}
		);
	}

	private function gotoStackFrame(stackFrame:StackFrame):Void {
		if (!stackFrame.source)
		//nothing to open! sometimes the stack trace includes functions
		{

			//internal to the runtime that cannot be viewed as source.
			return;
		}
		var filePath:String = stackFrame.source.path;
		var line:Int = as3hx.Compat.parseInt(stackFrame.line - 1);
		var character:Int = stackFrame.column;
		var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.TRACE_LINE,
		[new FileLocation(filePath)], line);
		openEvent.atChar = character;
		dispatcher.dispatchEvent(openEvent);

		this.sendRequest(COMMAND_SCOPES,
				{
					frameId: stackFrame.id
				}
		);
	}

	private function handleDisconnectOrTerminated():Void {
		_paused = true;
		this._variablesLookup = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
		this._scopesAndVars.removeAll();
		this._stackFrames.removeAll();
		if (_socket != null && _socket.connected) {
			this._socket.close();
		}
		this.cleanupSocket();
		connected = false;
		refreshView();
	}

	private function parseScopesResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('scopes command not successful!');
			return;
		}
		var body:Dynamic = response.body;
		if (Lambda.has(body, 'scopes')) {
			this._variablesLookup = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
			var resultScopes:Array<Dynamic> = [];
			var scopes:Array<Dynamic> = try cast(body.scopes, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
			var scopesCount:Int = scopes.length;
			for (i in 0...scopesCount) {
				var scope:Scope = this.parseScope(scopes[i]);
				resultScopes.push(scope);
			}
			this._scopesAndVars.setScopes(resultScopes);
			if (resultScopes.length > 0) {
				this.loadVariables(resultScopes[0]);
			}
		}
	}

	private function parseScope(response:Dynamic):Scope {
		var vo:Scope = new Scope();
		vo.name = Std.string(response.name);
		vo.variablesReference = as3hx.Compat.parseFloat(response.variablesReference);
		vo.expensive = response.expensive == true;
		return vo;
	}

	private function parseVariablesResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('variables command not successful!');
			return;
		}
		var body:Dynamic = response.body;
		if (Lambda.has(body, 'variables')) {
			var requestID:Int = response.request_seq;
			if (!(Lambda.has(this._variablesLookup, requestID)))
			//we have new scopes, so we don't care anymore
			{

				return;
			}
			var scopeOrVar:BaseVariablesReference = cast((this._variablesLookup[requestID]), BaseVariablesReference);
			;
			var resultVariables:Array<Dynamic> = [];
			var variables:Array<Dynamic> = try cast(body.variables, Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
			var variablesCount:Int = variables.length;
			for (i in 0...variablesCount) {
				var variable:Variable = this.parseVariable(variables[i]);
				resultVariables[i] = variable;
			}
			this._scopesAndVars.setVariablesForScopeOrVar(resultVariables, scopeOrVar);
		}
	}

	private function parseVariable(response:Dynamic):Variable {
		var vo:Variable = new Variable();
		vo.name = Std.string(response.name);
		vo.value = Std.string(response.value);
		if (Lambda.has(response, 'variablesReference'))
		//only populate if it exists!
		{

			vo.variablesReference = as3hx.Compat.parseFloat(response.variablesReference);
		} else {
			vo.variablesReference = -1;
		}
		vo.type = Std.string(response.type);
		return vo;
	}

	private function parseDisconnectResponse(response:Dynamic):Void {
		if (!response.success) {
			trace('disconnect command not successful!');
			return;
		}
		this.handleDisconnectOrTerminated();
	}

	private function parseInitializedEvent(event:Dynamic):Void {
		var hasBreakpoints:Bool = false;
		for (key in Reflect.fields(_breakpoints)) {
			hasBreakpoints = true;
			sendSetBreakpointsRequestForPath(key);
		}
		if (!hasBreakpoints) {
			this.sendRequest(COMMAND_THREADS);
		}
	}

	private function parseOutputEvent(event:Dynamic):Void {
		var output:String = null;
		var category:String = 'console';
		if (Lambda.has(event, 'body')) {
			var body:Dynamic = event.body;
			if (Lambda.has(body, 'output')) {
				output = Std.string(body.output);
			}
			if (Lambda.has(body, 'category')) {
				category = Std.string(body.category);
			}
		}
		if (output != null) {
			if (category == OUTPUT_CATEGORY_STDERR) {
				error(output);
			} else {
				print(output);
			}
		}
	}

	private function parseStoppedEvent(event:Dynamic):Void {
		this.sendRequest(COMMAND_STACK_TRACE,
				{
					threadId: mainThreadID
				}
		);
		_paused = true;
		refreshView();
	}

	private function parseTerminatedEvent(event:Dynamic):Void {
		this.handleDisconnectOrTerminated();
		if (_nativeProcess != null)
		//the process won't exit automatically
		{

			_nativeProcess.exit(true);
		}
	}

	private function initializeDebugViewEventHandlers(event:Event):Void {
		_debugPanel.playButton.addEventListener(MouseEvent.CLICK, playButton_clickHandler);
		_debugPanel.pauseButton.addEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
		_debugPanel.stepOverButton.addEventListener(MouseEvent.CLICK, stepOverButton_clickHandler);
		_debugPanel.stepIntoButton.addEventListener(MouseEvent.CLICK, stepIntoButton_clickHandler);
		_debugPanel.stepOutButton.addEventListener(MouseEvent.CLICK, stepOutButton_clickHandler);
		_debugPanel.stopButton.addEventListener(MouseEvent.CLICK, stopButton_clickHandler);
		_debugPanel.addEventListener(Event.REMOVED_FROM_STAGE, debugPanel_RemovedFromStage);
		_debugPanel.addEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
		_debugPanel.addEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
	}

	private function cleanupDebugViewEventHandlers():Void {
		_debugPanel.playButton.removeEventListener(MouseEvent.CLICK, playButton_clickHandler);
		_debugPanel.pauseButton.removeEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
		_debugPanel.stepOverButton.removeEventListener(MouseEvent.CLICK, stepOverButton_clickHandler);
		_debugPanel.stepIntoButton.removeEventListener(MouseEvent.CLICK, stepIntoButton_clickHandler);
		_debugPanel.stepOutButton.removeEventListener(MouseEvent.CLICK, stepOutButton_clickHandler);
		_debugPanel.stopButton.removeEventListener(MouseEvent.CLICK, stopButton_clickHandler);
		_debugPanel.removeEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
		_debugPanel.removeEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
		_debugPanel.removeEventListener(Event.REMOVED_FROM_STAGE, debugPanel_RemovedFromStage);
	}

	private function refreshView():Void {
		if (!_debugPanel.parent) {
			return;
		}
		_debugPanel.playButton.enabled = this.connected && this._paused;
		_debugPanel.pauseButton.enabled = this.connected && !this._paused;
		_debugPanel.stepOverButton.enabled = this.connected && this._paused;
		_debugPanel.stepIntoButton.enabled = this.connected && this._paused;
		_debugPanel.stepOutButton.enabled = this.connected && this._paused;
		_debugPanel.stopButton.enabled = this.connected;
		_debugPanel.stackFrames = this._stackFrames;
		_debugPanel.scopesAndVars = this._scopesAndVars;
	}

	private function sendSetBreakpointsRequestForPath(path:String):Void {
		if (!(Lambda.has(_breakpoints, path))) {
			return;
		}
		var breakpoints:Array<Dynamic> = try cast(Reflect.field(_breakpoints, path), Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
		breakpoints = breakpoints.map(function(item:Int, index:Int, source:Array<Dynamic>):Dynamic
						//the debugger expects breakpoints to start at line 1
						 {

							//but moonshine stores breakpoints from line 0
							return {
								line: item + 1
							};
						});
		this.sendRequest(COMMAND_SET_BREAKPOINTS,
				{
					source: {
						path: path
					},
					breakpoints: breakpoints
				}
		);
	}

	private function dispatcher_showDebugViewHandler(event:Event):Void {
		if (!isDebugViewVisible) {
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
			initializeDebugViewEventHandlers(event);
			isDebugViewVisible = true;
		} else {
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, this._debugPanel));
			cleanupDebugViewEventHandlers();
			isDebugViewVisible = false;
		}
		isStartupCall = false;
	}

	private function stepOverExecutionHandler(event:Event):Void {
		if (!connected) {
			return;
		}

		if (_debugPanel.stepOverButton.enabled) {
			stepOverButton_clickHandler(null);
		}
	}

	private function continueExecutionHandler(event:Event):Void {
		if (!connected) {
			return;
		}

		if (_debugPanel.playButton.enabled) {
			playButton_clickHandler(null);
		}
	}

	private function terminateExecutionHandler(event:Event):Void {
		if (!connected) {
			return;
		}

		if (_debugPanel.stopButton.enabled) {
			stopButton_clickHandler(null);
		}
	}

	private function dispatcher_editorOpenHandler(event:EditorPluginEvent):Void {
		if (event.newFile || !event.file) {
			return;
		}

		var path:String = event.file.fileBridge.nativePath;
		var breakpoints:Array<Dynamic> = try cast(this._breakpoints[path], Array</*AS3HX WARNING no type*/>) catch (e:Dynamic) null;
		if (breakpoints != null)
		//restore the breakpoints
		{

			event.editor.breakpoints = breakpoints;
		}
	}

	private function dispatcher_closeTabHandler(event:Event):Void {
		if (Std.is(event, CloseTabEvent)) {
			var editor:BasicTextEditor = try cast(cast((event), CloseTabEvent).tab, BasicTextEditor) catch (e:Dynamic) null;
			this.saveEditorBreakpoints(editor);
		}
	}

	private function dispatcher_setDebugLineHandler(event:DebugLineEvent):Void {
		var editor:BasicTextEditor = try cast(model.activeEditor, BasicTextEditor) catch (e:Dynamic) null;
		saveEditorBreakpoints(editor);
		if (connected) {
			var path:String = editor.currentFile.fileBridge.nativePath;
			sendSetBreakpointsRequestForPath(path);
		}
	}

	private function dispatcher_postBuildHandler(event:ProjectEvent):Void {
		this._currentProject = try cast(event.project, AS3ProjectVO) catch (e:Dynamic) null;
		this._stackFrames = new ArrayCollection();
		this._scopesAndVars = new VariablesReferenceHierarchicalData();
		if (_nativeProcess != null)
		//if we're already debugging, kill the previous process
		{

			_nativeProcess.exit(true);
		}

		connected = false;
		refreshView();
		_port = findOpenPort();

		var processArgs:Array<String> = [];
		var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		//var project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
		var sdkFile:File = new File(getProjectSDKPath(_currentProject, model));
		processArgs.push('-Dflexlib=' + sdkFile.resolvePath('frameworks').nativePath);
		processArgs.push('-Dworkspace=' + _currentProject.folderLocation.fileBridge.nativePath);
		processArgs.push('-cp');
		var cp:String = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_BIN_PATH).nativePath + File.separator + '*';
		if (Settings.os == 'win') {
			cp += ';';
		} else {
			cp += ':';
		}
		cp += sdkFile.resolvePath('lib/*').nativePath;
		processArgs.push(cp);
		processArgs.push('com.as3mxml.vscode.SWFDebug');
		processArgs.push('--server=' + _port);
		var cwd:File = new File(_currentProject.folderLocation.resolvePath('bin-debug').fileBridge.nativePath);
		startupInfo.workingDirectory = cwd;
		startupInfo.arguments = processArgs;
		var javaFile:File = cast((model.javaPathForTypeAhead.fileBridge.getFile), File);
		var javaFileName:String = ((Settings.os == 'win')) ? 'java.exe' : 'java';
		startupInfo.executable = javaFile.resolvePath('bin/' + javaFileName);
		_nativeProcess = new NativeProcess();
		_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
		_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
		_nativeProcess.start(startupInfo);

		//connect after a delay because it's not clear when the server has
		//been started by the process
		_retryCount = 0;
		mainThreadID = -1;
		as3hx.Compat.setTimeout(connectToProcess, 100);
	}

	private function socket_connectHandler(event:Event):Void {
		connected = true;
		refreshView();
		_socket.removeEventListener(IOErrorEvent.IO_ERROR, socketConnect_ioErrorHandler);
		_socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioErrorHandler);
		_socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketDataHandler);
		_socket.addEventListener(Event.CLOSE, socket_closeHandler);

		dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
		initializeDebugViewEventHandlers(event);
		isDebugViewVisible = true;

		sendRequest(COMMAND_INITIALIZE,
				{
					clientID: 'moonshine',
					adapterID: 'swf'
				}
		);
	}

	private function socketConnect_ioErrorHandler(event:IOErrorEvent):Void {
		if (_nativeProcess != null) {
			_retryCount++;
			if (_retryCount == MAX_RETRY_COUNT) {
				Alert.show('Could not connect to the SWF debugger Retried ' + _retryCount + ' times.', 'Debug Error', Alert.OK);
				cleanupSocket();
				return;
			}
			//try again if the process is still running
			as3hx.Compat.setTimeout(connectToProcess, 100);
			return;
		}
		cleanupSocket();
	}

	private function socketConnect_securityErrorHandler(event:SecurityErrorEvent):Void {
		Alert.show('Could not connect to the SWF debugger. Internal error.', 'Debug Error', Alert.OK);
		cleanupSocket();
	}

	private function socket_ioErrorHandler(event:IOErrorEvent):Void {
		error('Socket connection problem: %s', Std.string(event));
	}

	private function socket_socketDataHandler(event:ProgressEvent):Void {
		this._messageBuffer += _socket.readUTFBytes(_socket.bytesAvailable);
		this.parseMessageBuffer();
	}

	private function socket_closeHandler(event:Event):Void {
		connected = false;
		refreshView();
		cleanupSocket();
	}

	private function nativeProcess_standardErrorDataHandler(event:ProgressEvent):Void {
		var output:IDataInput = _nativeProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		error('Process error: %s', data);
	}

	private function nativeProcess_exitHandler(event:NativeProcessExitEvent):Void {
		_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
		_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
		_nativeProcess.exit();
		_nativeProcess = null;
	}

	private function dispatcher_quitHandler(event:Event):Void {
		if (_nativeProcess == null) {
			return;
		}
		_nativeProcess.exit(true);
	}

	private function debugPanel_loadVariablesHandler(event:LoadVariablesEvent):Void {
		this.loadVariables(event.scopeOrVar);
	}

	private function debugPanel_gotoStackFrameHandler(event:StackFrameEvent):Void {
		this.gotoStackFrame(event.stackFrame);
	}

	private function stopButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_DISCONNECT);
		dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
	}

	private function pauseButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_PAUSE);
	}

	private function playButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_CONTINUE);
		dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
	}

	private function stepOverButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_NEXT);
	}

	private function stepIntoButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_STEP_IN);
	}

	private function stepOutButton_clickHandler(event:MouseEvent):Void {
		this.sendRequest(COMMAND_STEP_OUT);
	}

	private function debugPanel_RemovedFromStage(event:Event):Void {
		isDebugViewVisible = false;
	}

}