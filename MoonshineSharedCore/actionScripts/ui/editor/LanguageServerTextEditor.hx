package actionScripts.ui.editor;

import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.events.LanguageServerEvent;
import actionScripts.events.CompletionItemsEvent;
import actionScripts.events.SignatureHelpEvent;
import actionScripts.events.HoverEvent;
import actionScripts.events.GotoDefinitionEvent;
import actionScripts.events.DiagnosticsEvent;
import flash.events.Event;
import flash.geom.Point;
import actionScripts.events.ChangeEvent;
import flash.events.MouseEvent;
import actionScripts.valueObjects.Location;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.events.SaveFileEvent;
import actionScripts.events.CodeActionsEvent;

class LanguageServerTextEditor extends BasicTextEditor {

	public function new(languageID:String, readOnly:Bool = false) {
		super(readOnly);

		this._languageID = languageID;

		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);

		editor.addEventListener(ChangeEvent.TEXT_CHANGE, onTextChange);
		editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		editor.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		editor.model.addEventListener(Event.CHANGE, editorModel_onChange);
	}

	private var _languageID:String;

	public var languageID(get, never):String;
	private function get_languageID():String {
		return this._languageID;
	}

	private var _codeActionTimeoutID:Int = -1;

	private function addGlobalListeners():Void {
		dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
		dispatcher.addEventListener(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, showCodeActionsHandler);
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
		dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
		dispatcher.addEventListener(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, updateResolvedCompletionItemHandler);
	}

	private function removeGlobalListeners():Void {
		dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
		dispatcher.removeEventListener(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, showCodeActionsHandler);
		dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
		dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
		dispatcher.removeEventListener(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, updateResolvedCompletionItemHandler);
	}

	private function dispatchCompletionEvent():Void {
		dispatcher.addEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);

		var document:String = getTextDocument();
		var len:Float = editor.model.caretIndex - editor.startPos;
		var startLine:Int = editor.model.selectedLineIndex;
		var startChar:Int = AS3.int(editor.startPos);
		var endLine:Int = editor.model.selectedLineIndex;
		var endChar:Int = editor.model.caretIndex;
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_COMPLETION,
				startChar, startLine, endChar, endLine,
				document, len, 1));
	}

	private function dispatchSignatureHelpEvent():Void {
		dispatcher.addEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);

		var document:String = getTextDocument();
		var len:Float = editor.model.caretIndex - editor.startPos;
		var startLine:Int = editor.model.selectedLineIndex;
		var startChar:Int = AS3.int(editor.startPos);
		var endLine:Int = editor.model.selectedLineIndex;
		var endChar:Int = editor.model.caretIndex;
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_SIGNATURE_HELP,
				startChar, startLine, endChar, endLine,
				document, len, 1));
	}

	private function dispatchHoverEvent(charAndLine:Point):Void {
		dispatcher.addEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);

		var document:String = getTextDocument();
		var line:Int = AS3.int(charAndLine.y);
		var char:Int = AS3.int(charAndLine.x);
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_HOVER,
				char, line, char, line,
				document, 0, 1));
	}

	private function dispatchGotoDefinitionEvent(charAndLine:Point):Void {
		dispatcher.addEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);

		var document:String = getTextDocument();
		var line:Int = AS3.int(charAndLine.y);
		var char:Int = AS3.int(charAndLine.x);
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_DEFINITION_LINK,
				char, line, char, line,
				document, 0, 1));
	}

	private function getTextDocument():String {
		var document:String;
		var lines:Array<TextLineModel> = cast editor.model.lines;
		var textLinesCount:Int = lines.length;
		if (textLinesCount > 1) {
			textLinesCount -= 1;
			for (i in 0...textLinesCount) {
				var textLine:TextLineModel = lines[i];
				document += textLine.text + '\n';
			}
		}

		return document;
	}

	override private function openFileAsStringHandler(data:String):Void {
		super.openFileAsStringHandler(data);
		if (currentFile == null) {
			return;
		}
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
				0, 0, 0, 0, editor.dataProvider, 0, 0, Std.string(currentFile.fileBridge.url)));
	}

	override private function openHandler(event:Event):Void {
		super.openHandler(event);
		if (currentFile == null) {
			return;
		}
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
				0, 0, 0, 0, editor.dataProvider, 0, 0, Std.string(currentFile.fileBridge.url)));
	}

	private function onMouseMove(event:MouseEvent):Void {
		var globalXY:Point = new Point(event.stageX, event.stageY);
		var charAndLine:Point = editor.getCharAndLineForXY(globalXY, true);
		if (charAndLine != null) {
			if (event.ctrlKey) {
				dispatchGotoDefinitionEvent(charAndLine);
			} else {
				editor.showDefinitionLink([], null);
				dispatchHoverEvent(charAndLine);
			}
		} else {
			editor.showDefinitionLink([], null);
			editor.showHover([]);
		}
	}

	private function onRollOut(event:MouseEvent):Void {
		dispatcher.removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
	}

	private function onTextChange(event:ChangeEvent):Void {
		if (currentFile == null) {
			return;
		}
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_DIDCHANGE, 0, 0, 0, 0, editor.dataProvider, 0, 0, Std.string(currentFile.fileBridge.url)));
	}

	private function editorModel_onChange(event:Event):Void {
		if (_codeActionTimeoutID != -1) {
			//we want to "debounce" this event, so reset the timer
			as3hx.Compat.clearTimeout(_codeActionTimeoutID);
			_codeActionTimeoutID = -1;
		}
		_codeActionTimeoutID = as3hx.Compat.setTimeout(dispatchCodeActionEvent, 250);
	}

	private function dispatchCodeActionEvent():Void {
		_codeActionTimeoutID = -1;
		var document:String = getTextDocument();
		var startLine:Int = editor.model.getSelectionLineStart();
		var startChar:Int = editor.model.getSelectionCharStart();
		if (startChar == -1) {
			startChar = editor.model.caretIndex;
		}
		var endLine:Int = editor.model.getSelectionLineEnd();
		var endChar:Int = editor.model.getSelectionCharEnd();
		dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_CODE_ACTION,
				startChar, startLine, endChar, endLine));
	}

	private function showCompletionListHandler(event:CompletionItemsEvent):Void {
		dispatcher.removeEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);
		if (event.items.length == 0) {
			return;
		}

		editor.showCompletionList(event.items);
	}

	private function updateResolvedCompletionItemHandler(event:CompletionItemsEvent):Void {
		if (event.items.length == 0) {
			return;
		}

		editor.resolveCompletionItem(event.items[0]);
	}

	private function showSignatureHelpHandler(event:SignatureHelpEvent):Void {
		dispatcher.removeEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
		editor.showSignatureHelp(event.signatureHelp);
	}

	private function showHoverHandler(event:HoverEvent):Void {
		dispatcher.removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
		editor.showHover(event.contents);
	}

	private function showDefinitionLinkHandler(event:GotoDefinitionEvent):Void {
		dispatcher.removeEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
		editor.showDefinitionLink(event.locations, event.position);
	}

	private function showDiagnosticsHandler(event:DiagnosticsEvent):Void {
		if (currentFile == null || event.path != currentFile.fileBridge.nativePath) {
			return;
		}
		editor.showDiagnostics(event.diagnostics);
	}

	private function showCodeActionsHandler(event:CodeActionsEvent):Void {
		if (currentFile == null || event.path != currentFile.fileBridge.nativePath) {
			return;
		}
		editor.showCodeActions(event.codeActions);
	}

	private function closeTabHandler(event:CloseTabEvent):Void {
		var closedTab:LanguageServerTextEditor = AS3.as(event.tab, LanguageServerTextEditor);
		if (closedTab == null || closedTab != this) {
			return;
		}
		if (currentFile == null) {
			return;
		}
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDCLOSE,
				0, 0, 0, 0, null, 0, 0, Std.string(currentFile.fileBridge.url)));
	}

	private function fileSavedHandler(event:SaveFileEvent):Void {
		var savedTab:LanguageServerTextEditor = AS3.as(event.editor, LanguageServerTextEditor);
		if (savedTab == null || savedTab != this) {
			return;
		}
		if (currentFile == null) {
			return;
		}
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_WILLSAVE,
				0, 0, 0, 0, null, 0, 0, Std.string(currentFile.fileBridge.url)));

		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDSAVE,
				0, 0, 0, 0, null, 0, 0, Std.string(currentFile.fileBridge.url)));
	}

	private function addedToStageHandler(event:Event):Void {
		this.addGlobalListeners();
	}

	private function removedFromStageHandler(event:Event):Void {
		this.removeGlobalListeners();
	}

}