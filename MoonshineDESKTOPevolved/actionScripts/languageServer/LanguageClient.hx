package actionScripts.languageServer;

import flash.errors.Error;
import haxe.Constraints.Function;
import actionScripts.events.ApplicationEvent;
import actionScripts.events.CompletionItemsEvent;
import actionScripts.events.DiagnosticsEvent;
import actionScripts.events.ExecuteLanguageServerCommandEvent;
import actionScripts.events.GotoDefinitionEvent;
import actionScripts.events.HoverEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.ReferencesEvent;
import actionScripts.events.SignatureHelpEvent;
import actionScripts.events.SymbolsEvent;
import actionScripts.events.LanguageServerEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.valueObjects.Command;
import actionScripts.valueObjects.CompletionItem;
import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.Location;
import actionScripts.valueObjects.ParameterInformation;
import actionScripts.valueObjects.Position;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Range;
import actionScripts.valueObjects.SignatureHelp;
import actionScripts.valueObjects.SignatureInformation;
import actionScripts.valueObjects.SymbolInformation;
import actionScripts.valueObjects.TextEdit;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.filesystem.File;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import actionScripts.events.OpenLocationEvent;
import actionScripts.events.LanguageServerMenuEvent;
import actionScripts.events.MenuEvent;
import actionScripts.events.CodeActionsEvent;
import actionScripts.valueObjects.CodeAction;
import actionScripts.utils.LSPUtil;
import actionScripts.valueObjects.DocumentSymbol;
import actionScripts.valueObjects.WorkspaceEdit;
import actionScripts.utils.ApplyWorkspaceEdit;
import actionScripts.valueObjects.TextDocumentEdit;
import actionScripts.valueObjects.TextDocumentIdentifier;
import actionScripts.valueObjects.RenameFile;
import actionScripts.valueObjects.DeleteFile;
import actionScripts.valueObjects.CreateFile;
import actionScripts.events.ResolveCompletionItemEvent;

/**
 * Dispatched when the language client has been initialized.
 *
 * @see #initializing
 * @see #initialized
 */
@:meta(Event(name = 'init'))
/**
 * Dispatched when the language client sends its exit request.
 *
 * @see #stopping
 * @see #stopped
 */
@:meta(Event(name = 'close'))
/**
 * An implementation of the language server protocol for Moonshine IDE.
 *
 * @see https://microsoft.github.io/language-server-protocol/specification Language Server Protocol Specification
 */
class LanguageClient extends EventDispatcher {

	private static var HELPER_BYTES(default, never):ByteArray = as3hx.Compat.newByteArray();
	private static inline var PROTOCOL_HEADER_FIELD_CONTENT_LENGTH:String = 'Content-Length: ';
	private static inline var PROTOCOL_HEADER_DELIMITER:String = '\r\n';
	private static inline var PROTOCOL_END_OF_HEADER:String = '\r\n\r\n';
	private static inline var FIELD_METHOD:String = 'method';
	private static inline var FIELD_RESULT:String = 'result';
	private static inline var FIELD_ERROR:String = 'error';
	private static inline var FIELD_ID:String = 'id';
	private static inline var FIELD_CHANGES:String = 'changes';
	private static inline var FIELD_DOCUMENT_CHANGES:String = 'documentChanges';
	private static inline var FIELD_CONTENTS:String = 'contents';
	private static inline var FIELD_SIGNATURES:String = 'signatures';
	private static inline var FIELD_ITEMS:String = 'items';
	private static inline var FIELD_LOCATION:String = 'location';
	private static inline var JSON_RPC_VERSION:String = '2.0';
	private static inline var METHOD_INITIALIZE:String = 'initialize';
	private static inline var METHOD_INITIALIZED:String = 'initialized';
	private static inline var METHOD_SHUTDOWN:String = 'shutdown';
	private static inline var METHOD_EXIT:String = 'exit';
	private static inline var METHOD_CANCEL_REQUEST:String = '$/cancelRequest';
	private static inline var METHOD_TEXT_DOCUMENT__DID_CHANGE:String = 'textDocument/didChange';
	private static inline var METHOD_TEXT_DOCUMENT__DID_OPEN:String = 'textDocument/didOpen';
	private static inline var METHOD_TEXT_DOCUMENT__DID_CLOSE:String = 'textDocument/didClose';
	private static inline var METHOD_TEXT_DOCUMENT__WILL_SAVE:String = 'textDocument/willSave';
	private static inline var METHOD_TEXT_DOCUMENT__DID_SAVE:String = 'textDocument/didSave';
	private static inline var METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:String = 'textDocument/publishDiagnostics';
	private static inline var METHOD_TEXT_DOCUMENT__COMPLETION:String = 'textDocument/completion';
	private static inline var METHOD_TEXT_DOCUMENT__SIGNATURE_HELP:String = 'textDocument/signatureHelp';
	private static inline var METHOD_TEXT_DOCUMENT__HOVER:String = 'textDocument/hover';
	private static inline var METHOD_TEXT_DOCUMENT__DEFINITION:String = 'textDocument/definition';
	private static inline var METHOD_TEXT_DOCUMENT__TYPE_DEFINITION:String = 'textDocument/typeDefinition';
	private static inline var METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL:String = 'textDocument/documentSymbol';
	private static inline var METHOD_TEXT_DOCUMENT__REFERENCES:String = 'textDocument/references';
	private static inline var METHOD_TEXT_DOCUMENT__RENAME:String = 'textDocument/rename';
	private static inline var METHOD_TEXT_DOCUMENT__CODE_ACTION:String = 'textDocument/codeAction';
	private static inline var METHOD_WORKSPACE__APPLY_EDIT:String = 'workspace/applyEdit';
	private static inline var METHOD_WORKSPACE__SYMBOL:String = 'workspace/symbol';
	private static inline var METHOD_WORKSPACE__EXECUTE_COMMAND:String = 'workspace/executeCommand';
	private static inline var METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = 'workspace/didChangeConfiguration';
	private static inline var METHOD_WINDOW__LOG_MESSAGE:String = 'window/logMessage';
	private static inline var METHOD_WINDOW__SHOW_MESSAGE:String = 'window/showMessage';
	private static inline var METHOD_CLIENT__REGISTER_CAPABILITY:String = 'client/registerCapability';
	private static inline var METHOD_TELEMETRY__EVENT:String = 'telemetry/event';
	private static inline var METHOD_COMPLETION_ITEM__RESOLVE:String = 'completionItem/resolve';

	public function new(languageID:String, project:ProjectVO,
			debugMode:Bool, initializationOptions:Dynamic,
			globalDispatcher:IEventDispatcher, input:IDataInput, inputDispatcher:IEventDispatcher, inputEvent:String,
			output:IDataOutput, outputFlushCallback:Function = null) {
		super();
		_languageID = languageID;
		_project = project;
		this.debugMode = debugMode;
		_initializationOptions = initializationOptions;
		_globalDispatcher = globalDispatcher;
		_input = input;
		_inputDispatcher = inputDispatcher;
		_inputEvent = inputEvent;
		_output = output;
		_outputFlushCallback = cast outputFlushCallback;

		_inputDispatcher.addEventListener(_inputEvent, input_onData);

		_globalDispatcher.addEventListener(Std.string(ProjectEvent.REMOVE_PROJECT), removeProjectHandler);
		_globalDispatcher.addEventListener(Std.string(ApplicationEvent.APPLICATION_EXIT), applicationExitHandler);
		_globalDispatcher.addEventListener(Std.string(ProjectEvent.SAVE_PROJECT_SETTINGS), saveProjectSettingsHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DIDOPEN), didOpenCall);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DIDCHANGE), didChangeCall);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DIDCLOSE), didCloseCall);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_WILLSAVE), willSaveCall);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DIDSAVE), didSaveCall);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_COMPLETION), completionHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_SIGNATURE_HELP), signatureHelpHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_HOVER), hoverHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DEFINITION_LINK), definitionLinkHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS), workspaceSymbolsHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS), documentSymbolsHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_FIND_REFERENCES), findReferencesHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_CODE_ACTION), codeActionHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION), gotoDefinitionHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION), gotoTypeDefinitionHandler);
		_globalDispatcher.addEventListener(Std.string(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND), executeCommandHandler);
		_globalDispatcher.addEventListener(Std.string(LanguageServerEvent.EVENT_RENAME), renameHandler);
		_globalDispatcher.addEventListener(Std.string(ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM), resolveCompletionHandler);
		//when adding new listeners, don't forget to remove them in stop()

		sendInitialize();
	}

	private var _languageID:String;
	private var _project:ProjectVO;
	private var _initializationOptions:Dynamic;
	private var _input:IDataInput;
	private var _output:IDataOutput;
	private var _inputDispatcher:IEventDispatcher;
	private var _inputEvent:String;
	private var _outputFlushCallback:Function;
	private var _globalDispatcher:IEventDispatcher;
	private var _model:IDEModel = IDEModel.getInstance();

	private var _initialized:Bool = false;

	public var initialized(get, never):Bool;
	private function get_initialized():Bool {
		return this._initialized;
	}

	public var initializing(get, never):Bool;
	private function get_initializing():Bool {
		return this._initializeID != -1;
	}

	private var _stopped:Bool = false;

	public var stopped(get, never):Bool;
	private function get_stopped():Bool {
		return this._stopped;
	}

	public var stopping(get, never):Bool;
	private function get_stopping():Bool {
		return this._shutdownID != -1;
	}

	public var debugMode:Bool = false;

	private var _initializeID:Int = -1;
	private var _shutdownID:Int = -1;
	private var _requestID:Int = 0;
	private var _documentVersion:Int = 1;
	private var _contentLength:Int = -1;
	private var _socketBuffer:String = '';
	private var _gotoDefinitionLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _definitionLinkLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _findReferencesLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _gotoTypeDefinitionLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _codeActionLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _resolveCompletionLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _completionLookup:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var _previousActiveFilePath:String = null;
	private var _previousActiveResult:Bool = false;
	private var _schemes:Array<String> = [];
	private var _savedDiagnostics:Dynamic = {};

	private var _notificationListeners:Dynamic = {};

	private var _capabilities:Dynamic = null;

	public var capabilities(get, never):Dynamic;
	private function get_capabilities():Dynamic {
		return this._capabilities;
	}

	private var supportsCompletion:Bool = false;
	private var resolveCompletion:Bool = false;
	private var supportsHover:Bool = false;
	private var supportsSignatureHelp:Bool = false;
	private var supportsGotoDefinition:Bool = false;
	private var supportsGotoTypeDefinition:Bool = false;
	private var supportsReferences:Bool = false;
	private var supportsDocumentSymbols:Bool = false;
	private var supportsWorkspaceSymbols:Bool = false;
	private var supportedCommands:Array<String> = [];
	private var supportsRename:Bool = false;
	private var supportsCodeAction:Bool = false;

	public function stop():Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}

		this.cleanup();
		_shutdownID = sendRequest(METHOD_SHUTDOWN, null);
	}

	public function registerScheme(scheme:String):Void {
		this._schemes.push(scheme);
	}

	public function sendNotification(method:String, params:Dynamic):Void {
		if (!_initialized && method != METHOD_INITIALIZE && method != METHOD_EXIT) {
			throw new IllegalOperationError('Notification failed. Language server is not initialized. Unexpected method: ' + method);
		}
		if (_stopped) {
			throw new IllegalOperationError('Notification failed. Language server is stopped. Unexpected method: ' + method);
		}

		var contentPart:Dynamic = {};
		Reflect.setField(contentPart, 'jsonrpc', JSON_RPC_VERSION);
		Reflect.setField(contentPart, 'method', method);
		Reflect.setField(contentPart, 'params', params);
		var contentJSON:String = Std.string(haxe.Json.stringify(contentPart));

		HELPER_BYTES.clear();
		HELPER_BYTES.writeUTFBytes(contentJSON);
		var contentLength:Int = HELPER_BYTES.length;
		HELPER_BYTES.clear();

		var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
		var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;

		if (debugMode) {
			trace('>>> (NOTIFICATION)', contentJSON);
		}

		try {
			_output.writeUTFBytes(message);
		} catch (error:Error) {
			//if there's something wrong with the IDataOutput, we can't
			//send a final shutdown request
			stop();
			return;
		}
		if (_outputFlushCallback != null) {
			_outputFlushCallback();
		}
	}

	private function cleanup():Void {
		//clear any remaining diagnostics
		for (uri in Reflect.fields(this._savedDiagnostics)) {
			var path:String = Std.string((new File(uri)).nativePath);
			Reflect.deleteField(this._savedDiagnostics, uri);
			var diagnostics:Array<Diagnostic> = [];
			_globalDispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
		}

		_globalDispatcher.removeEventListener(Std.string(ProjectEvent.REMOVE_PROJECT), removeProjectHandler);
		_globalDispatcher.removeEventListener(Std.string(ApplicationEvent.APPLICATION_EXIT), applicationExitHandler);
		_globalDispatcher.removeEventListener(Std.string(ProjectEvent.SAVE_PROJECT_SETTINGS), saveProjectSettingsHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_DIDOPEN), didOpenCall);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_DIDCHANGE), didChangeCall);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_COMPLETION), completionHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_SIGNATURE_HELP), signatureHelpHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_HOVER), hoverHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_DEFINITION_LINK), definitionLinkHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS), workspaceSymbolsHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS), documentSymbolsHandler);
		_globalDispatcher.removeEventListener(Std.string(LanguageServerEvent.EVENT_FIND_REFERENCES), findReferencesHandler);
		_globalDispatcher.removeEventListener(Std.string(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND), executeCommandHandler);
	}

	private function sendRequest(method:String, params:Dynamic):Int {
		if (!_initialized && method != METHOD_INITIALIZE) {
			throw new IllegalOperationError('Request failed. Language server is not initialized. Unexpected method: ' + method);
		}

		var id:Int = getNextRequestID();
		var contentPart:Dynamic = {};
		Reflect.setField(contentPart, 'jsonrpc', JSON_RPC_VERSION);
		Reflect.setField(contentPart, 'id', id);
		Reflect.setField(contentPart, 'method', method);
		if (params != null) {
			//omit it completely to avoid errors in servers that try to
			//parse an object
			Reflect.setField(contentPart, 'params', params);
		}
		var contentJSON:String = Std.string(haxe.Json.stringify(contentPart));

		HELPER_BYTES.clear();
		HELPER_BYTES.writeUTFBytes(contentJSON);
		var contentLength:Int = HELPER_BYTES.length;
		HELPER_BYTES.clear();

		var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
		var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;

		if (debugMode) {
			trace('>>> (REQUEST)', contentJSON);
		}

		try {
			_output.writeUTFBytes(message);
		} catch (error:Error) {
			//if we're already trying to shut down, don't do it again
			if (method != METHOD_SHUTDOWN) {
				//if there's something wrong with the IDataOutput, we can't
				//send a final shutdown request
				stop();
			} else {
				//something went wrong while sending the shutdown request
				//there's nothing that we can do about that, so notify
				//any listeners that we've stopped
				_stopped = true;
				dispatchEvent(new Event(Event.CLOSE));
			}
			return id;
		}
		if (_outputFlushCallback != null) {
			_outputFlushCallback();
		}

		return id;
	}

	public function addNotificationListener(method:String, listener:Function):Void {
		if (!(Reflect.hasField(this._notificationListeners, method))) {
			Reflect.setField(this._notificationListeners, method, []);
		}
		var listeners:Array<Function> = try cast(Reflect.field(this._notificationListeners, method), Vector) catch(e:Dynamic) null;
		var index:Int = AS3.int(Lambda.indexOf(listeners, listener));
		if (index != -1) {
			//already added
			return;
		}
		listeners.push(listener);
	}

	public function removeNotificationListener(method:String, listener:Function):Void {
		if (!(Reflect.hasField(this._notificationListeners, method))) {
			//nothing to remove
			return;
		}
		var listeners:Array<Function> = try cast(Reflect.field(this._notificationListeners, method), Vector) catch(e:Dynamic) null;
		var index:Int = AS3.int(Lambda.indexOf(listeners, listener));
		if (index == -1) {
			//nothing to remove
			return;
		}
		listeners.splice(index, 1)[0];
	}

	private function sendResponse(id:Dynamic, result:Dynamic = null, error:Dynamic = null):Void {
		if (!_initialized) {
			throw new IllegalOperationError('Response failed. Language server is not initialized.');
		}

		var contentPart:Dynamic = {};
		Reflect.setField(contentPart, 'jsonrpc', JSON_RPC_VERSION);
		Reflect.setField(contentPart, 'id', id);
		if (AS3.as(result, Bool)) {
			Reflect.setField(contentPart, 'result', result);
		}
		if (AS3.as(error, Bool)) {
			Reflect.setField(contentPart, 'error', error);
		}
		var contentJSON:String = Std.string(haxe.Json.stringify(contentPart));

		HELPER_BYTES.clear();
		HELPER_BYTES.writeUTFBytes(contentJSON);
		var contentLength:Int = HELPER_BYTES.length;
		HELPER_BYTES.clear();

		var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
		var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;

		if (debugMode) {
			trace('>>> (RESPONSE)', contentJSON);
		}

		try {
			_output.writeUTFBytes(message);
		} catch (error:Error) {
			//if there's something wrong with the IDataOutput, we can't
			//send a final shutdown request
			stop();
			return;
		}
		if (_outputFlushCallback != null) {
			_outputFlushCallback();
		}
	}

	private function getNextRequestID():Int {
		_requestID++;
		return _requestID;
	}

	private function sendInitialize():Void {
		var params:Dynamic = {};
		Reflect.setField(params, 'rootUri', _project.folderLocation.fileBridge.url);
		Reflect.setField(params, 'rootPath', _project.folderLocation.fileBridge.nativePath);
		Reflect.setField(params, 'capabilities',
		{
			'workspace':
			{
				'applyEdit': true,
				'workspaceEdit':
				{
					'documentChanges': false
				},
				'didChangeConfiguration':
				{
					'dynamicRegistration': false
				},
				'didChangeWatchedFiles':
				{
					'dynamicRegistration': false
				},
				'symbol':
				{
					'dynamicRegistration': false
				},
				'executeCommand':
				{
					'dynamicRegistration': false
				},
				'workspaceFolders': false,
				'configuration': false
			},
			'textDocument':
			{
				'synchronization':
				{
					'dynamicRegistration': false,
					'willSave': true,
					'willSaveWaitUntil': false,
					'didSave': true
				},
				'completion':
				{
					'dynamicRegistration': false,
					'completionItem':
					{
						'snippetSupport': false,
						'commitCharactersSupport': false,
						'documentationFormat': ['plaintext'],
						'deprecatedSupport': false
					},
					'completionItemKind':
					{
						//valueSet: []
					},
					'contextSupport': false
				},
				'hover':
				{
					'dynamicRegistration': false,
					'contentFormat': ['plaintext']
				},
				'signatureHelp':
				{
					'dynamicRegistration': false,
					'signatureInformation':
					{
						'documentationFormat': ['plaintext']
					}
				},
				'references':
				{
					'dynamicRegistration': false
				},
				'documentHighlight':
				{
					'dynamicRegistration': false
				},
				'documentSymbol':
				{
					'dynamicRegistration': false,
					'hierarchicalDocumentSymbolSupport': false,
					'symbolKind':
					{
						//valueSet: []
					}
				},
				'formatting':
				{
					'dynamicRegistration': false
				},
				'rangeFormatting':
				{
					'dynamicRegistration': false
				},
				'onTypeFormatting':
				{
					'dynamicRegistration': false
				},
				'definition':
				{
					'dynamicRegistration': false
				},
				'typeDefinition':
				{
					'dynamicRegistration': false
				},
				'implementation':
				{
					'dynamicRegistration': false
				},
				'codeAction':
				{
					'dynamicRegistration': false,
					'codeActionLiteralSupport':
					{
						'codeActionKind':
						{
							//valueSet: []
						}
					}
				},
				'codeLens':
				{
					'dynamicRegistration': false
				},
				'documentLink':
				{
					'dynamicRegistration': false
				},
				'colorProvider':
				{
					'dynamicRegistration': false
				},
				'rename':
				{
					'dynamicRegistration': false
				},
				'publishDiagnostics':
				{
					'relatedInformation': false
				}
			}
		});
		Reflect.setField(params, 'workspaceFolders',
		[
		{
			'name': _project.name,
			'uri': _project.folderLocation.fileBridge.url
		}
	]);
		Reflect.setField(params, 'initializationOptions', _initializationOptions);
		_initializeID = sendRequest(METHOD_INITIALIZE, params);
	}

	private function sendInitialized():Void {
		if (_initializeID != -1) {
			throw new IllegalOperationError('Cannot send initialized notification until initialize request completes.');
		}
		if (_initialized) {
			throw new IllegalOperationError('Cannot send initialized notification multiple times.');
		}
		_initialized = true;

		var params:Dynamic = {};
		sendNotification(METHOD_INITIALIZED, params);

		this.dispatchEvent(new Event(Event.INIT));

		var editors:ArrayCollection = _model.editors;
		var count:Int = AS3.int(editors.length);
		for (i in 0...count) {
			var editor:IContentWindow = IContentWindow(editors.getItemAt(i));
			if (Std.is(editor, LanguageServerTextEditor)) {
				var lspEditor:LanguageServerTextEditor = LanguageServerTextEditor(editor);
				if (isEditorInProject(lspEditor)) {
					var uri:String = Std.string(lspEditor.currentFile.fileBridge.url);
					sendDidOpenNotification(uri, Std.string(lspEditor.text));
				}
			}
		}
	}

	private function sendExit():Void {
		_inputDispatcher.removeEventListener(_inputEvent, input_onData);
		sendNotification(METHOD_EXIT, null);
		_stopped = true;
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function sendDidOpenNotification(uri:String, text:String):Void {
		if (!_initialized) {
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);
		Reflect.setField(textDocument, 'languageId', _languageID);
		Reflect.setField(textDocument, 'version', _documentVersion);
		Reflect.setField(textDocument, 'text', text);
		_documentVersion++;

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);

		sendNotification(METHOD_TEXT_DOCUMENT__DID_OPEN, params);
	}

	private function sendDidCloseNotification(uri:String):Void {
		if (!_initialized) {
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);

		sendNotification(METHOD_TEXT_DOCUMENT__DID_CLOSE, params);
	}

	private function parseMessageBuffer():Void {
		var object:Dynamic = null;
		try {
			var needsHeaderPart:Bool = _contentLength == -1;
			if (needsHeaderPart && _socketBuffer.indexOf(PROTOCOL_END_OF_HEADER) == -1) {
				//not enough data for the header yet
				return;
			}
			while (needsHeaderPart) {
				var index:Int = _socketBuffer.indexOf(PROTOCOL_HEADER_DELIMITER);
				var headerField:String = _socketBuffer.substr(0, index);
				_socketBuffer = _socketBuffer.substr(index + PROTOCOL_HEADER_DELIMITER.length);
				if (index == 0) {
					//this is the end of the header
					needsHeaderPart = false;
				} else if (headerField.indexOf(PROTOCOL_HEADER_FIELD_CONTENT_LENGTH) == 0) {
					var contentLengthAsString:String = headerField.substr(PROTOCOL_HEADER_FIELD_CONTENT_LENGTH.length);
					_contentLength = as3hx.Compat.parseInt(contentLengthAsString, 10);
				}
			}
			if (_contentLength == -1) {
				trace('Language client failed to parse Content-Length header');
				return;
			}
			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(_socketBuffer);
			if (HELPER_BYTES.length < _contentLength) {
				HELPER_BYTES.clear();
				//we don't have the full content part of the message yet
				return;
			}
			HELPER_BYTES.position = 0;
			var message:String = HELPER_BYTES.readUTFBytes(_contentLength);
			HELPER_BYTES.clear();
			_contentLength = -1;
			_socketBuffer = _socketBuffer.substr(message.length);
			if (debugMode) {
				trace('<<<', message);
			}
			object = haxe.Json.parse(message);
		} catch (error:Error) {
			trace('invalid JSON');
			return;
		}
		parseMessage(object);

		//check if there's another message in the buffer
		parseMessageBuffer();
	}

	private function getMessageID(message:Dynamic):Int {
		var id:Int = -1;
		if (!(Reflect.hasField(message, FIELD_ID))) {
			return id;
		}
		var untypedID:Dynamic = Reflect.field(message, 'id');
		if (Std.is(untypedID, String)) {
			return as3hx.Compat.parseInt(Std.string(untypedID), 10);
		} else if (Std.is(untypedID, Float)) {
			return AS3.int(as3hx.Compat.parseFloat(untypedID));
		}
		return id;
	}

	private function isActiveEditorInProject():Bool {
		var editor:LanguageServerTextEditor = AS3.as(_model.activeEditor, LanguageServerTextEditor);
		if (editor == null) {
			return false;
		}
		return isEditorInProject(editor);
	}

	private function isEditorInProject(editor:LanguageServerTextEditor):Bool {
		if (!AS3.as(editor.currentFile, Bool)) {
			return false;
		}
		var nativePath:String = Std.string(editor.currentFile.fileBridge.nativePath);
		if (_previousActiveFilePath == nativePath) {
			//optimization: don't check this path multiple times when we
			//probably already know the result from last time.
			return _previousActiveResult;
		}
		_previousActiveFilePath = nativePath;
		_previousActiveResult = false;
		var activeFile:File = new File(nativePath);
		var projectFile:File = new File(_project.folderPath);
		//getRelativePath() will return null if activeFile is not in the
		//projectFile directory
		if (projectFile.getRelativePath(activeFile, false) != null) {
			_previousActiveResult = true;
			return _previousActiveResult;
		}
		if (Std.is(_project, AS3ProjectVO)) {
			var as3Project:AS3ProjectVO = AS3ProjectVO(_project);
			var sourcePaths:Array<FileLocation> = as3Project.classpaths;
			var sourcePathCount:Int = sourcePaths.length;
			for (i in 0...sourcePathCount) {
				var sourcePath:FileLocation = sourcePaths[i];
				var sourcePathFile:File = new File(sourcePath.fileBridge.nativePath);
				if (sourcePathFile.getRelativePath(activeFile, false) != null) {
					_previousActiveResult = true;
					return _previousActiveResult;
				}
			}
		}
		return _previousActiveResult;
	}

	private function parseMessage(object:Dynamic):Void {
		if (Reflect.hasField(object, FIELD_METHOD)) {
			this.parseMethod(object);
		} else if (Reflect.hasField(object, FIELD_ID)) {
			var result:Dynamic = Reflect.field(object, 'result');
			var requestID:Int = getMessageID(object);
			if (_initializeID != -1 && _initializeID == requestID) {
				_initializeID = -1;
				if (Reflect.hasField(object, FIELD_ERROR)) {
					trace('Error in language server. Initialize failed. Code: ' + Reflect.field(Reflect.field(object, 'error'), 'code') + ', Message: ' + Reflect.field(Reflect.field(object, 'error'), 'message'));
					cleanup();
					sendExit();
					return;
				}
				handleInitializeResponse(result);
				sendInitialized();
			} else if (_shutdownID != -1 && _shutdownID == requestID) {
				_shutdownID = -1;
				sendExit();
			} else if (Reflect.hasField(object, FIELD_ERROR)) {
				trace('Error in language server. Code: ' + Reflect.field(Reflect.field(object, 'error'), 'code') + ', Message: ' + Reflect.field(Reflect.field(object, 'error'), 'message'));
			} else if (_resolveCompletionLookup.exists(requestID)) {
				//resolve completion
				{
					var original:CompletionItem = CompletionItem(_resolveCompletionLookup.get(requestID));
					_resolveCompletionLookup.remove(requestID);
					handleCompletionResolveResponse(original, result);
				}
			} else if (AS3.as(result, Bool) && Reflect.hasField(result, FIELD_ITEMS)) {
				//completion (CompletionList)
				{
					_completionLookup.remove(requestID);
					handleCompletionResponse(result);
				}
			} else if (AS3.as(result, Bool) && Reflect.hasField(result, FIELD_SIGNATURES)) {
				//signature help
				{
					handleSignatureHelpResponse(result);
				}
			} else if (AS3.as(result, Bool) && Reflect.hasField(result, FIELD_CONTENTS)) {
				//hover
				{
					handleHoverResponse(result);
				}
			} else if (AS3.as(result, Bool) && Reflect.hasField(result, FIELD_DOCUMENT_CHANGES)) {
				//rename
				{
					handleRenameResponse(result);
				}
			} else if (AS3.as(result, Bool) && Reflect.hasField(result, FIELD_CHANGES)) {
				//rename
				{
					handleRenameResponse(result);
				}
			} else if (AS3.as(result, Bool) && Std.is(result, Array)) {
				if (_completionLookup.exists(requestID)) {
					//completion (CompletionItem[])
					{
						_completionLookup.remove(requestID);
						handleCompletionResponse(result);
					}
				} else if (_definitionLinkLookup.exists(requestID)) {
					var position:Position = AS3.as(_definitionLinkLookup.get(requestID), Position);
					_definitionLinkLookup.remove(requestID);
					handleDefinitionLinkResponse(result, position);
				} else if (_gotoDefinitionLookup.exists(requestID)) {
					position = AS3.as(_gotoDefinitionLookup.get(requestID), Position);
					_gotoDefinitionLookup.remove(requestID);
					handleGotoDefinitionResponse(result, position);
				} else if (_gotoTypeDefinitionLookup.exists(requestID)) {
					position = AS3.as(_gotoTypeDefinitionLookup.get(requestID), Position);
					_gotoTypeDefinitionLookup.remove(requestID);
					handleGotoTypeDefinitionResponse(result, position);
				} else if (_findReferencesLookup.exists(requestID)) {
					_findReferencesLookup.remove(requestID);
					handleReferencesResponse(result);
				} else if (_codeActionLookup.exists(requestID)) {
					_codeActionLookup.remove(requestID);
					handleCodeActionResponse(result);
				}//document or workspace symbols
				else {
					handleSymbolsResponse(result);
				}
			}
		}
	}

	private function parseMethod(object:Dynamic):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		var found:Bool = true;
		var method:String = AS3.string(Reflect.field(object, 'method'));
		switch (method) {
			case METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:
				textDocument__publishDiagnostics(object);
				//this is a notification and does not require a response
				break;
			case METHOD_WORKSPACE__APPLY_EDIT:
				workspace__applyEdit(object);
				sendResponse(Reflect.field(object, 'id'), {
							'applied': true
						});
			case METHOD_WINDOW__LOG_MESSAGE:
				window__logMessage(object);
			case METHOD_WINDOW__SHOW_MESSAGE:
				window__showMessage(object);
			case METHOD_CLIENT__REGISTER_CAPABILITY:
				//TODO: implement this
				sendResponse(Reflect.field(object, 'id'), {});
			case METHOD_TELEMETRY__EVENT:
				//just ignore this one
				break;
			case _:
				{
					found = false;
					break;
				}
		}
		if (!found) {
			found = this.handleNotification(object);
		}
		if (!found) {
			trace('Unknown language server method:', method);
		}
	}

	private function handleInitializeResponse(result:Dynamic):Void {
		var capabilities:Dynamic = Reflect.field(result, 'capabilities');
		this.supportsCompletion = AS3.as(capabilities, Bool) && (Reflect.field(capabilities, 'completionProvider') != null);
		this.resolveCompletion = this.supportsCompletion &&
				Reflect.hasField(Reflect.field(capabilities, 'completionProvider'), 'resolveProvider') &&
				AS3.as(Reflect.field(Reflect.field(capabilities, 'completionProvider'), 'resolveProvider'), Bool);
		this.supportsHover = AS3.as(capabilities, Bool) && (AS3.as(Reflect.field(capabilities, 'hoverProvider'), Bool));
		this.supportsSignatureHelp = AS3.as(capabilities, Bool) && (Reflect.field(capabilities, 'signatureHelpProvider') != null);
		this.supportsGotoDefinition = AS3.as(capabilities, Bool) && (AS3.as(Reflect.field(capabilities, 'definitionProvider'), Bool));
		this.supportsGotoTypeDefinition = AS3.as(capabilities, Bool) && Reflect.field(capabilities, 'typeDefinitionProvider') != false && Reflect.field(capabilities, 'typeDefinitionProvider') != null;
		this.supportsReferences = AS3.as(capabilities, Bool) && (AS3.as(Reflect.field(capabilities, 'referencesProvider'), Bool));
		this.supportsDocumentSymbols = AS3.as(capabilities, Bool) && (AS3.as(Reflect.field(capabilities, 'documentSymbolProvider'), Bool));
		this.supportsWorkspaceSymbols = AS3.as(capabilities, Bool) && (AS3.as(Reflect.field(capabilities, 'workspaceSymbolProvider'), Bool));
		this.supportsRename = AS3.as(capabilities, Bool) && Reflect.field(capabilities, 'renameProvider') != false && Reflect.field(capabilities, 'renameProvider') != null;
		this.supportsCodeAction = AS3.as(capabilities, Bool) && Reflect.field(capabilities, 'codeActionProvider') != false && Reflect.field(capabilities, 'codeActionProvider') != null;
		if (AS3.as(capabilities, Bool) && Reflect.field(capabilities, 'executeCommandProvider') != null) {
			this.supportedCommands = Reflect.field(Reflect.field(capabilities, 'executeCommandProvider'), 'commands');
		}
	}

	private function handleCompletionResponse(result:Dynamic):Void {
		var resultCompletionItems:Array<Dynamic> = null;
		if (Std.is(result, Array)) {
			resultCompletionItems = cast AS3.asArray(result);
		} else {
			resultCompletionItems = cast AS3.asArray(Reflect.field(result, 'items'));
		}
		if (resultCompletionItems == null) {
			return;
		}
		var eventCompletionItems:Array<Dynamic> = new Array<Dynamic>();
		var completionItemCount:Int = resultCompletionItems.length;
		for (i in 0...completionItemCount) {
			var resultItem:Dynamic = resultCompletionItems[i];
			eventCompletionItems[i] = CompletionItem.parse(resultItem);
		}
		_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, eventCompletionItems));
	}

	private function handleCompletionResolveResponse(original:CompletionItem, result:Dynamic):Void {
		CompletionItem.resolve(original, result);
		_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, [original]));
	}

	private function handleSignatureHelpResponse(result:Dynamic):Void {
		var resultSignatures:Array<Dynamic> = cast AS3.asArray(Reflect.field(result, 'signatures'));
		if (resultSignatures != null && resultSignatures.length > 0) {
			var eventSignatures:Array<SignatureInformation> = [];
			var resultSignaturesCount:Int = resultSignatures.length;
			for (i in 0...resultSignaturesCount) {
				var resultSignature:Dynamic = resultSignatures[i];
				eventSignatures[i] = SignatureInformation.parse(resultSignature);
			}
			var signatureHelp:SignatureHelp = new SignatureHelp();
			signatureHelp.signatures = eventSignatures;
			signatureHelp.activeSignature = Reflect.field(result, 'activeSignature');
			signatureHelp.activeParameter = Reflect.field(result, 'activeParameter');
			_globalDispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
		}
	}

	private function handleHoverResponse(result:Dynamic):Void {
		var resultContents:Dynamic = Reflect.field(result, 'contents');
		var eventContents:Array<String> = [];
		if (Std.is(resultContents, Array)) {
			var resultContentsArray:Array<Dynamic> = cast AS3.asArray(resultContents);
			var resultContentsCount:Int = resultContentsArray.length;
			for (i in 0...resultContentsCount) {
				var resultContentItem:Dynamic = resultContentsArray[i];
				eventContents[i] = parseHover(resultContentItem);
			}
		} else {
			eventContents[0] = parseHover(resultContents);
		}
		_globalDispatcher.dispatchEvent(new HoverEvent(HoverEvent.EVENT_SHOW_HOVER, eventContents));
	}

	private function handleRenameResponse(result:Dynamic):Void {
		var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(result);
		applyWorkspaceEdit(workspaceEdit);
	}

	private function handleLocationsResponse(result:Array<Dynamic>):Array<Location> {
		var eventLocations:Array<Location> = [];
		var resultLocationsCount:Int = result.length;
		for (i in 0...resultLocationsCount) {
			var resultLocation:Dynamic = result[i];
			var eventLocation:Location = Location.parse(resultLocation);
			var uri:String = Std.string(eventLocation.uri);
			var schemeEndIndex:Int = uri.indexOf(':');
			var scheme:String = null;
			if (schemeEndIndex != -1) {
				scheme = uri.substr(0, schemeEndIndex);
			}
			if (scheme != 'file' && Lambda.indexOf(this._schemes, scheme) == -1) {
				//we don't know how to handle this URI scheme
				continue;
			}
			eventLocations.push(eventLocation);
		}
		return eventLocations;
	}

	private function handleDefinitionLinkResponse(result:Dynamic, position:Position):Void {
		var eventLocations:Array<Location> = cast handleLocationsResponse(cast AS3.asArray(result));
		_globalDispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, eventLocations, position));
	}

	private function handleGotoDefinitionResponse(result:Dynamic, position:Position):Void {
		var eventLocations:Array<Location> = cast handleLocationsResponse(cast AS3.asArray(result));
		if (eventLocations.length > 0) {
			var location:Location = eventLocations[0];
			_globalDispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location)
			);
		}
	}

	private function handleGotoTypeDefinitionResponse(result:Dynamic, position:Position):Void {
		var eventLocations:Array<Location> = cast handleLocationsResponse(cast AS3.asArray(result));
		if (eventLocations.length > 0) {
			var location:Location = eventLocations[0];
			_globalDispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location)
			);
		}
	}

	private function handleReferencesResponse(result:Dynamic):Void {
		var resultReferences:Array<Dynamic> = cast AS3.asArray(result);
		var eventReferences:Array<Location> = [];
		var resultReferencesCount:Int = resultReferences.length;
		for (i in 0...resultReferencesCount) {
			var resultReference:Dynamic = resultReferences[i];
			eventReferences[i] = Location.parse(resultReference);
		}
		_globalDispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, eventReferences));
	}

	private function handleCodeActionResponse(result:Dynamic):Void {
		var resultCodeActions:Array<Dynamic> = cast AS3.asArray(result);
		var eventCodeActions:Array<CodeAction> = [];
		var resultCodeActionsCount:Int = resultCodeActions.length;
		for (i in 0...resultCodeActionsCount) {
			var resultCodeAction:Dynamic = resultCodeActions[i];
			if (Std.is(Reflect.field(resultCodeAction, 'command'), String)) {
				//this is a Command instead of a CodeAction
				var command:Command = Command.parse(resultCodeAction);
				var codeAction:CodeAction = new CodeAction();
				codeAction.title = command.title;
				codeAction.command = command;
				eventCodeActions[i] = codeAction;
			} else {
				codeAction = CodeAction.parse(resultCodeAction);
				eventCodeActions[i] = codeAction;
			}
		}
		var editor:LanguageServerTextEditor = AS3.as(_model.activeEditor, LanguageServerTextEditor);
		if (editor == null) {
			return;
		}
		var path:String = Std.string(editor.currentFile.fileBridge.nativePath);
		_globalDispatcher.dispatchEvent(new CodeActionsEvent(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, path, eventCodeActions));
	}

	private function handleSymbolsResponse(result:Dynamic):Void {
		var resultSymbolInfos:Array<Dynamic> = cast AS3.asArray(result);
		var eventSymbolInfos:Array<Dynamic> = [];
		var resultSymbolInfosCount:Int = resultSymbolInfos.length;
		for (i in 0...resultSymbolInfosCount) {
			var resultSymbolInfo:Dynamic = resultSymbolInfos[i];
			if (Reflect.hasField(resultSymbolInfo, FIELD_LOCATION)) {
				//if location is defined, it's a flat SymbolInformation
				eventSymbolInfos[i] = SymbolInformation.parse(resultSymbolInfo);
			}//otherwise, it's a hierarchical DocumentSymbol
			else {
				//otherwise, it's a hierarchical DocumentSymbol
				eventSymbolInfos[i] = DocumentSymbol.parse(resultSymbolInfo);
			}
		}
		_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, eventSymbolInfos));
	}

	private function handleNotification(object:Dynamic):Bool {
		var method:String = AS3.string(Reflect.field(object, 'method'));
		if (!(Reflect.hasField(this._notificationListeners, method))) {
			return false;
		}
		var listeners:Array<Function> = try cast(Reflect.field(this._notificationListeners, method), Vector) catch(e:Dynamic) null;
		var listenerCount:Int = listeners.length;
		if (listenerCount == 0) {
			return false;
		}
		for (i in 0...listenerCount) {
			var listener:Function = cast listeners[i];
			listener(object);
		}
		return true;
	}

	private function parseHover(original:Dynamic):String {
		if (original == null) {
			return null;
		}
		if (Std.is(original, String)) {
			return Std.string(original);
		}
		return AS3.string(Reflect.field(original, 'value'));
	}

	private function textDocument__publishDiagnostics(jsonObject:Dynamic):Void {
		var diagnosticsParams:Dynamic = Reflect.field(jsonObject, 'params');
		var uri:String = AS3.string(Reflect.field(diagnosticsParams, 'uri'));
		var path:String = Std.string((new File(uri)).nativePath);
		var resultDiagnostics:Array<Dynamic> = Reflect.field(diagnosticsParams, 'diagnostics');
		Reflect.setField(this._savedDiagnostics, uri, resultDiagnostics);
		var diagnostics:Array<Diagnostic> = [];
		var diagnosticsCount:Int = resultDiagnostics.length;
		for (i in 0...diagnosticsCount) {
			var resultDiagnostic:Dynamic = resultDiagnostics[i];
			diagnostics[i] = Diagnostic.parseWithPath(path, resultDiagnostic);
		}
		_globalDispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
	}

	private function workspace__applyEdit(jsonObject:Dynamic):Void {
		var applyEditParams:Dynamic = Reflect.field(jsonObject, 'params');
		var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(Reflect.field(applyEditParams, 'edit'));
		applyWorkspaceEdit(workspaceEdit);
	}

	private function window__logMessage(jsonObject:Dynamic):Void {
		var logMessageParams:Dynamic = Reflect.field(jsonObject, 'params');
		var message:String = AS3.string(Reflect.field(logMessageParams, 'message'));
		var type:Int = AS3.int(Reflect.field(logMessageParams, 'type'));
		var eventType:String = null;
		switch (Reflect.field(jsonObject, 'type')) {
			case 1:
				//error
				{
					eventType = Std.string(ConsoleOutputEvent.TYPE_ERROR);
					break;
				}
				eventType = Std.string(ConsoleOutputEvent.TYPE_INFO);
			case _:
				{
					eventType = Std.string(ConsoleOutputEvent.TYPE_INFO);
				}
		}
		_globalDispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, eventType)
		);
		trace(message);
	}

	private function window__showMessage(jsonObject:Dynamic):Void {
		var showMessageParams:Dynamic = Reflect.field(jsonObject, 'params');
		var message:String = AS3.string(Reflect.field(showMessageParams, 'message'));
		var type:Int = AS3.int(Reflect.field(showMessageParams, 'type'));
		var eventType:String = null;
		switch (Reflect.field(jsonObject, 'type')) {
			case 1:
				//error
				{
					eventType = Std.string(ConsoleOutputEvent.TYPE_ERROR);
					break;
				}
				eventType = Std.string(ConsoleOutputEvent.TYPE_INFO);
			case _:
				{
					eventType = Std.string(ConsoleOutputEvent.TYPE_INFO);
				}
		}

		Alert.show(message);
	}

	private function removeProjectHandler(event:ProjectEvent):Void {
		if (event.project != _project) {
			return;
		}
		this.stop();
	}

	private function applicationExitHandler(event:ApplicationEvent):Void {
		this.stop();
	}

	private function saveProjectSettingsHandler(event:ProjectEvent):Void {
		//this result may no longer be valid after project settings changes
		_previousActiveFilePath = null;
		_previousActiveResult = false;
	}

	private function didOpenCall(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();

		sendDidOpenNotification(Std.string(event.uri), Std.string(event.newText));
	}

	private function didCloseCall(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();

		sendDidCloseNotification(Std.string(event.uri));
	}

	private function didChangeCall(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'version', _documentVersion);
		Reflect.setField(textDocument, 'uri', event.uri);
		_documentVersion++;

		var range:Dynamic = {};
		var startposition:Dynamic = {};
		Reflect.setField(startposition, 'line', event.startLineNumber);
		Reflect.setField(startposition, 'character', event.startLinePos);
		Reflect.setField(range, 'start', startposition);

		var endposition:Dynamic = {};
		Reflect.setField(endposition, 'line', event.endLineNumber);
		Reflect.setField(endposition, 'character', event.endLinePos);
		Reflect.setField(range, 'end', endposition);

		var contentChangesArr:Array<Dynamic> = new Array<Dynamic>();
		var contentChanges:Dynamic = {};
		Reflect.setField(contentChanges, 'range', null);//range;
		Reflect.setField(contentChanges, 'rangeLength', 0);//evt.textlen;
		Reflect.setField(contentChanges, 'text', event.newText);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'contentChanges', contentChanges);

		sendNotification(METHOD_TEXT_DOCUMENT__DID_CHANGE, params);
	}

	private function willSaveCall(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();

		var uri:String = Std.string(event.uri);

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'reason', 1);

		sendNotification(METHOD_TEXT_DOCUMENT__WILL_SAVE, params);
	}

	private function didSaveCall(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();

		var uri:String = Std.string(event.uri);

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		//TODO: include text, if registered for that

		sendNotification(METHOD_TEXT_DOCUMENT__DID_SAVE, params);
	}

	private function input_onData(event:Event):Void {
		this._socketBuffer += _input.readUTFBytes(_input.bytesAvailable);
		this.parseMessageBuffer();
	}

	private function completionHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsCompletion) {
			_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, []));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__COMPLETION, params);
		_completionLookup.set(id, true);
	}

	private function resolveCompletionHandler(event:ResolveCompletionItemEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!resolveCompletion) {
			return;
		}

		var id:Int = this.sendRequest(METHOD_COMPLETION_ITEM__RESOLVE, event.item);
		_resolveCompletionLookup.set(id, event.item);
	}

	private function signatureHelpHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsSignatureHelp) {
			var signatureHelp:SignatureHelp = new SignatureHelp();
			signatureHelp.signatures = [];
			_globalDispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		this.sendRequest(METHOD_TEXT_DOCUMENT__SIGNATURE_HELP, params);
	}

	private function hoverHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsHover) {
			_globalDispatcher.dispatchEvent(new HoverEvent(HoverEvent.EVENT_SHOW_HOVER, []));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		this.sendRequest(METHOD_TEXT_DOCUMENT__HOVER, params);
	}

	private function definitionLinkHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		var positionVO:Position = new Position(event.endLineNumber, event.endLinePos);
		if (!supportsGotoDefinition) {
			_globalDispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, [], positionVO));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__DEFINITION, params);
		_definitionLinkLookup.set(id, positionVO);
	}

	private function gotoDefinitionHandler(event:MenuEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		if (!AS3.as(_model.activeEditor, Bool) || Std.is(!_model.activeEditor, LanguageServerTextEditor)) {
			//no valid editor is open
			return;
		}
		event.preventDefault();
		if (!supportsGotoDefinition) {
			//nothing that we can do
			return;
		}

		var activeEditor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor);
		var uri:String = Std.string(activeEditor.currentFile.fileBridge.url);
		var line:Int = AS3.int(activeEditor.editor.model.selectedLineIndex);
		var char:Int = AS3.int(activeEditor.editor.model.caretIndex);

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', line);
		Reflect.setField(position, 'character', char);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__DEFINITION, params);
		_gotoDefinitionLookup.set(id, new Position(line, char));
	}

	private function gotoTypeDefinitionHandler(event:MenuEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		if (!AS3.as(_model.activeEditor, Bool) || Std.is(!_model.activeEditor, LanguageServerTextEditor)) {
			//no valid editor is open
			return;
		}
		event.preventDefault();
		if (!supportsGotoTypeDefinition) {
			//nothing that we can do
			return;
		}

		var activeEditor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor);
		var uri:String = Std.string(activeEditor.currentFile.fileBridge.url);
		var line:Int = AS3.int(activeEditor.editor.model.selectedLineIndex);
		var char:Int = AS3.int(activeEditor.editor.model.caretIndex);

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', line);
		Reflect.setField(position, 'character', char);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__TYPE_DEFINITION, params);
		_gotoTypeDefinitionLookup.set(id, new Position(line, char));
	}

	private function workspaceSymbolsHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool)) {
			return;
		}
		//TODO: fix this to properly merge symbols from all projects
		if (!isActiveEditorInProject() && _model.projects.length != 1) {
			return;
		}
		event.preventDefault();
		if (!supportsWorkspaceSymbols) {
			_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, []));
			return;
		}

		var query:String = Std.string(event.newText);

		var params:Dynamic = {};
		Reflect.setField(params, 'query', query);

		this.sendRequest(METHOD_WORKSPACE__SYMBOL, params);
	}

	private function documentSymbolsHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsDocumentSymbols) {
			_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, []));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);

		this.sendRequest(METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL, params);
	}

	private function findReferencesHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsReferences) {
			_globalDispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, []));
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var context:Dynamic = {};
		Reflect.setField(context, 'includeDeclaration', true);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);
		Reflect.setField(params, 'context', context);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__REFERENCES, params);
		_findReferencesLookup.set(id, true);
	}

	private function codeActionHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		var editor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor);
		if (!supportsCodeAction) {
			var path:String = Std.string(editor.currentFile.fileBridge.nativePath);
			_globalDispatcher.dispatchEvent(new CodeActionsEvent(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, path, []));
			return;
		}

		var uri:String = Std.string(editor.currentFile.fileBridge.url);

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', uri);

		var range:Dynamic = {};
		var startposition:Dynamic = {};
		Reflect.setField(startposition, 'line', event.startLineNumber);
		Reflect.setField(startposition, 'character', event.startLinePos);
		Reflect.setField(range, 'start', startposition);

		var endposition:Dynamic = {};
		Reflect.setField(endposition, 'line', event.endLineNumber);
		Reflect.setField(endposition, 'character', event.endLinePos);
		Reflect.setField(range, 'end', endposition);

		var context:Dynamic = {};
		if (Reflect.hasField(this._savedDiagnostics, uri)) {
			//we need to filter out diagnostics that don't apply to the
			//current selection range
			var eventRange:Range = new Range(
			new Position(event.startLineNumber, event.startLinePos),
			new Position(event.endLineNumber, event.endLinePos));
			var diagnostics:Array<Dynamic> = cast AS3.asArray(Reflect.field(this._savedDiagnostics, uri));
			Reflect.setField(context, 'diagnostics', as3hx.Compat.filter(diagnostics, function(diagnostic:Dynamic, index:Int, original:Array<Dynamic>):Bool {
						var diagnosticRange:Range = new Range(
						new Position(Reflect.field(Reflect.field(Reflect.field(diagnostic, 'range'), 'start'), 'line'), Reflect.field(Reflect.field(Reflect.field(diagnostic, 'range'), 'start'), 'character')),
						new Position(Reflect.field(Reflect.field(Reflect.field(diagnostic, 'range'), 'end'), 'line'), Reflect.field(Reflect.field(Reflect.field(diagnostic, 'range'), 'end'), 'character')));
						return LSPUtil.rangesIntersect(eventRange, diagnosticRange);
					}));
		} else {
			Reflect.setField(context, 'diagnostics', []);
		}

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'range', range);
		Reflect.setField(params, 'context', context);

		var id:Int = this.sendRequest(METHOD_TEXT_DOCUMENT__CODE_ACTION, params);
		_codeActionLookup.set(id, true);
	}

	private function renameHandler(event:LanguageServerEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		event.preventDefault();
		if (!supportsRename) {
			return;
		}

		var textDocument:Dynamic = {};
		Reflect.setField(textDocument, 'uri', (AS3.as(_model.activeEditor, LanguageServerTextEditor)).currentFile.fileBridge.url);

		var position:Dynamic = {};
		Reflect.setField(position, 'line', event.endLineNumber);
		Reflect.setField(position, 'character', event.endLinePos);

		var params:Dynamic = {};
		Reflect.setField(params, 'textDocument', textDocument);
		Reflect.setField(params, 'position', position);
		Reflect.setField(params, 'newName', event.newText);

		this.sendRequest(METHOD_TEXT_DOCUMENT__RENAME, params);
	}

	private function executeCommandHandler(event:ExecuteLanguageServerCommandEvent):Void {
		if (!_initialized || _stopped || _shutdownID != -1) {
			return;
		}
		if (AS3.as(event.isDefaultPrevented(), Bool) || !isActiveEditorInProject()) {
			return;
		}
		var command:String = Std.string(event.command);
		if (Lambda.indexOf(supportedCommands, command) == -1) {
			return;
		}
		event.preventDefault();

		var params:Dynamic = {};
		Reflect.setField(params, 'command', command);
		Reflect.setField(params, 'arguments', event.arguments);

		this.sendRequest(METHOD_WORKSPACE__EXECUTE_COMMAND, params);
	}

}