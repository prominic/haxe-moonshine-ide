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
package actionScripts.plugins.symbols;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.managers.PopUpManager;
import actionScripts.events.LanguageServerEvent;
import actionScripts.events.SymbolsEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugins.symbols.view.SymbolsView;
import actionScripts.ui.editor.ActionScriptTextEditor;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.DocumentSymbol;
import actionScripts.valueObjects.SymbolInformation;

class SymbolsPlugin extends PluginBase {

	public static inline var EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW:String = 'openDocumentSymbolsView';
	public static inline var EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW:String = 'openWorkspaceSymbolsView';

	private static inline var TITLE_DOCUMENT:String = 'Document Symbols';
	private static inline var TITLE_WORKSPACE:String = 'Workspace Symbols';

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Symbols Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Displays symbols in current document or entire workspace.';
	}

	private var symbolsView:SymbolsView = new SymbolsView();
	private var isWorkspace:Bool = false;

	override public function activate():Void {
		super.activate();
		symbolsView.addEventListener(SymbolsView.EVENT_QUERY_CHANGE, handleQueryChange);
		dispatcher.addEventListener(EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW, handleOpenDocumentSymbolsView);
		dispatcher.addEventListener(EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW, handleOpenWorkspaceSymbolsView);
		dispatcher.addEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW, handleOpenDocumentSymbolsView);
		dispatcher.removeEventListener(EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW, handleOpenWorkspaceSymbolsView);
		dispatcher.removeEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
	}

	private function handleQueryChange(event:Event):Void {
		var query:String = this.symbolsView.query;
		if (this.isWorkspace) {
			if (query == null) {
				//no point in calling the language server here
				//an empty query is supposed to have zero results
				this.symbolsView.symbols.removeAll();
				return;
			}
			var languageServerEvent:LanguageServerEvent = new LanguageServerEvent(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS);
			//using newText instead of a dedicated field is kind of hacky...
			languageServerEvent.newText = query;
			dispatcher.dispatchEvent(languageServerEvent);
		} else {
			var collection:ArrayCollection = this.symbolsView.symbols;
			collection.filterFunction = function(item:Dynamic):Bool {
						if (Std.is(item, SymbolInformation)) {
							var symbolInfo:SymbolInformation = SymbolInformation(item);
							return symbolInfo.name.indexOf(query) >= 0;
						} else if (Std.is(item, DocumentSymbol)) {
							var documentSymbol:DocumentSymbol = DocumentSymbol(item);
							return documentSymbol.name.indexOf(query) >= 0;
						}
						return false;
					};
			collection.refresh();
		}
	}

	private function handleOpenDocumentSymbolsView(event:Event):Void {
		var editor:LanguageServerTextEditor = AS3.as(model.activeEditor, LanguageServerTextEditor);
		if (editor == null) {
			return;
		}
		isWorkspace = false;
		symbolsView.title = TITLE_DOCUMENT;
		var parentApp:Dynamic = UIComponent(model.activeEditor).parentApplication;
		PopUpManager.addPopUp(symbolsView, DisplayObject(parentApp), true);
		PopUpManager.centerPopUp(symbolsView);
		dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS));
		symbolsView.focusManager.setFocus(symbolsView.txt_query);
	}

	private function handleOpenWorkspaceSymbolsView(event:Event):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}
		isWorkspace = true;
		symbolsView.title = TITLE_WORKSPACE;
		var parentApp:Dynamic = UIComponent(model.activeEditor).parentApplication;
		PopUpManager.addPopUp(symbolsView, DisplayObject(parentApp), true);
		PopUpManager.centerPopUp(symbolsView);
		symbolsView.focusManager.setFocus(symbolsView.txt_query);
	}

	private function handleShowSymbols(event:SymbolsEvent):Void {
		var collection:ArrayCollection = symbolsView.symbols;
		collection.removeAll();
		var symbols:Array<Dynamic> = event.symbols;
		var itemCount:Int = symbols.length;
		for (i in 0...itemCount) {
			var symbol:Dynamic = symbols[i];
			if (Std.is(symbol, SymbolInformation)) {
				var symbolInfo:SymbolInformation = AS3.as(symbol, SymbolInformation);
				collection.addItem(symbolInfo);
			} else if (Std.is(symbol, DocumentSymbol)) {
				var documentSymbol:DocumentSymbol = AS3.as(symbol, DocumentSymbol);
				collection.addItem(documentSymbol);
				this.addDocumentSymbolChildren(documentSymbol, collection);
			}
		}
		collection.filterFunction = null;
		collection.refresh();
	}

	private function addDocumentSymbolChildren(documentSymbol:DocumentSymbol, collection:ArrayCollection):Void {
		if (!AS3.as(documentSymbol.children, Bool)) {
			return;
		}
		var children:Array<DocumentSymbol> = documentSymbol.children;
		var childCount:Int = children.length;
		for (j in 0...childCount) {
			var child:DocumentSymbol = children[j];
			collection.addItem(child);
			this.addDocumentSymbolChildren(child, collection);
		}
	}

}