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
package actionScripts.ui.editor.text;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.SymbolsEvent;
import actionScripts.events.LanguageServerEvent;
import actionScripts.ui.codeCompletionList.CodeCompletionList;
import actionScripts.valueObjects.CompletionItem;
import actionScripts.valueObjects.CompletionItemKind;
import actionScripts.valueObjects.SymbolInformation;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import mx.collections.ArrayCollection;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import spark.components.TitleWindow;
import actionScripts.valueObjects.SymbolKind;
import actionScripts.valueObjects.DocumentSymbol;

@:meta(Event(name = 'itemSelected', type = 'flash.events.Event'))
class NewASFileCompletionManager {

	private static inline var CLASSES_LIST:String = 'classesList';
	private static inline var INTERFACES_LIST:String = 'interfacesList';
	private static inline var NO_PACKAGE:String = 'No Package';

	private var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

	private var view:TitleWindow;

	private var completionList:CodeCompletionList;
	private var menuCollection:ArrayCollection;

	private var completionListType:String;

	public function new(view:TitleWindow) {
		this.view = view;

		completionList = new CodeCompletionList();
		completionList.requireSelection = true;
		completionList.width = 574;
		menuCollection = new ArrayCollection();
		completionList.dataProvider = menuCollection;

		dispatcher.addEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
		view.addEventListener(MouseEvent.CLICK, onViewClick);
		view.addEventListener(CloseEvent.CLOSE, onViewClose);
		view.addEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
	}

	@:meta(Bindable())
	public var superClassName:String;

	@:meta(Bindable())
	public var interfaceName:String;

	private var _classesImports:Array<Dynamic> = [];

	public var classesImports(get, never):Array<Dynamic>;
	private function get_classesImports():Array<Dynamic> {
		return _classesImports;
	}

	private var _interfacesImports:Array<Dynamic> = [];

	public var interfacesImports(get, never):Array<Dynamic>;
	private function get_interfacesImports():Array<Dynamic> {
		return _interfacesImports;
	}

	public function showCompletionListClasses(text:String, position:Point):Void {
		this.completionListType = CLASSES_LIST;
		this.internalShowCompletionList(text, position);
	}

	public function showCompletionListInterfaces(text:String, position:Point):Void {
		this.completionListType = INTERFACES_LIST;
		this.internalShowCompletionList(text, position);
	}

	private function handleShowSymbols(event:SymbolsEvent):Void {
		menuCollection.source.splice(0, menuCollection.length);
		if (event.symbols.length == 0) {
			if (this.completionListType == CLASSES_LIST) {
				_classesImports.splice(0, _classesImports.length);
			} else {
				_interfacesImports.splice(0, _interfacesImports.length);
			}
			return;
		}

		var symbols:Array<Dynamic>;
		if (this.completionListType == CLASSES_LIST) {
			symbols = as3hx.Compat.filter(event.symbols, filterClasses);
		} else {
			symbols = as3hx.Compat.filter(event.symbols, filterInterfaces);
		}

		if (symbols.length == 0) {
			return;
		}

		var symbolsCount:Int = symbols.length;
		for (i in 0...symbolsCount) {
			var symbolInformation:SymbolInformation = AS3.as(symbols[i], SymbolInformation);
			if (symbolInformation == null) {
				continue;
			}
			var packageName:String = (symbolInformation.containerName != null) ? symbolInformation.containerName + '.' + symbolInformation.name : '';
			var completionItemKind:Int = getCompletionItemType(symbolInformation.kind);

			menuCollection.source.push(new CompletionItem(symbolInformation.name,
					'', completionItemKind, packageName));
		}

		menuCollection.refresh();

		this.showCompletionList();
	}

	private function onViewClose(event:Event):Void {
		dispatcher.removeEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
		view.removeEventListener(MouseEvent.CLICK, onViewClick);
		view.removeEventListener(CloseEvent.CLOSE, onViewClose);
		view.removeEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);

		this.closeCompletionList();
	}

	private function onViewClick(event:MouseEvent):Void {
		this.closeCompletionList();
	}

	private function onViewKeyDown(event:KeyboardEvent):Void {
		if (!AS3.as(completionList.isPopUp, Bool)) {
			return;
		}

		if (event.keyCode == Keyboard.ENTER) {
			this.completeItem(AS3.as(completionList.selectedItem, CompletionItem));
		}

		if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.UP) {
			this.completionList.setFocus();
		}
	}

	private function onCompletionListDoubleClick(event:MouseEvent):Void {
		this.completeItem(AS3.as(completionList.selectedItem, CompletionItem));
	}

	private function onCompletionListRemovedFromStage(event:Event):Void {
		menuCollection.removeAll();
	}

	private function completeItem(completionItem:CompletionItem):Void {
		var isDetailValid:Bool = completionItem.detail != null && completionItem.detail.indexOf('No Package') == -1;

		if (this.completionListType == CLASSES_LIST) {
			this.superClassName = completionItem.label;
			if (isDetailValid) {
				this._classesImports.push(completionItem.detail);
			}
		} else if (this.completionListType == INTERFACES_LIST) {
			this.interfaceName = completionItem.label;
			if (isDetailValid) {
				this._interfacesImports.push(completionItem.detail);
			}
		}

		dispatchEvent(new Event('itemSelected'));
		this.closeCompletionList();
	}

	private function internalShowCompletionList(text:String, position:Point):Void {
		var languageServerEvent:LanguageServerEvent = new LanguageServerEvent(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS);
		languageServerEvent.newText = text;
		dispatcher.dispatchEvent(languageServerEvent);

		completionList.x = position.x;
		completionList.y = position.y;
	}

	private function showCompletionList():Void {
		if (AS3.as(completionList.isPopUp, Bool)) {
			return;
		}

		PopUpManager.addPopUp(completionList, this.view, false);
		completionList.addEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
		completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);
		completionList.addEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
	}

	private function closeCompletionList():Void {
		if (!AS3.as(completionList.isPopUp, Bool)) {
			return;
		}

		PopUpManager.removePopUp(completionList);
		completionList.removeEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
		completionList.removeEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
		completionList.removeEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);

		completionList.closeDocumentation();
	}

	private function filterClasses(item:Dynamic, index:Int, vector:Array<Dynamic>):Bool {
		if (Std.is(item, SymbolInformation)) {
			var symbolInfo:SymbolInformation = SymbolInformation(item);
			return symbolInfo.kind == SymbolKind.CLASS;
		}
		if (Std.is(item, DocumentSymbol)) {
			var documentSymbol:DocumentSymbol = DocumentSymbol(item);
			return documentSymbol.kind == SymbolKind.CLASS;
		}
		return false;
	}

	private function filterInterfaces(item:Dynamic, index:Int, vector:Array<Dynamic>):Bool {
		if (Std.is(item, SymbolInformation)) {
			var symbolInfo:SymbolInformation = SymbolInformation(item);
			return symbolInfo.kind == SymbolKind.INTERFACE;
		}
		if (Std.is(item, DocumentSymbol)) {
			var documentSymbol:DocumentSymbol = DocumentSymbol(item);
			return documentSymbol.kind == SymbolKind.INTERFACE;
		}
		return false;
	}

	private function getCompletionItemType(symbolKind:Int):Int {
		if (SymbolKind.CLASS == symbolKind) {
			return CompletionItemKind.CLASS;
		}

		return CompletionItemKind.INTERFACE;
	}

}