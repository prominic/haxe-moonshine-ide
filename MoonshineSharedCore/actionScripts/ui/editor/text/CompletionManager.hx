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

import actionScripts.events.ExecuteLanguageServerCommandEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.ui.codeCompletionList.CodeCompletionList;
import actionScripts.utils.CompletionListCodeTokens;
import actionScripts.valueObjects.Command;
import actionScripts.valueObjects.CompletionItem;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;
import spark.collections.Sort;
import spark.collections.SortField;
import actionScripts.valueObjects.CompletionItemKind;
import actionScripts.valueObjects.TextEdit;
import actionScripts.valueObjects.WorkspaceEdit;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.utils.ApplyWorkspaceEdit;
import actionScripts.events.ResolveCompletionItemEvent;

class CompletionManager {

	private static inline var MIN_CODECOMPLETION_LIST_HEIGHT:Int = 8;

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var completionList:CodeCompletionList;
	private var menuStr:String;
	private var menuRefY:Float;
	private var caret:Int = 0;
	private var menuCollection:ArrayCollection;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;

		completionList = new CodeCompletionList();
		menuCollection = new ArrayCollection();
		menuCollection.filterFunction = filterCodeCompletionMenu;
		menuCollection.sort = new Sort([new SortField('sortLabel')], sortCodeCompletionMenu);

		completionList.dataProvider = menuCollection;
	}

	public var isActive(get, never):Bool;
	private function get_isActive():Bool {
		return AS3.as(completionList.isPopUp, Bool);
	}

	public function isMouseOverList():Bool {
		if (completionList == null || !AS3.as(completionList.visible, Bool)) {
			return false;
		}

		return AS3.as(completionList.hitTestPoint(editor.mouseX, editor.mouseY), Bool);
	}

	public function showCompletionList(items:Array<Dynamic>):Void {
		var selectedText:String = model.lines[model.selectedLineIndex].text;
		var pos:Int = model.caretIndex;
		//look back for last trigger
		var tmpStr:String = Std.string(selectedText.substring(AS3.int(Math.max(0, pos - 100)), pos).split('').reverse().join(''));
		var word:Array<Dynamic> = as3hx.Compat.match(tmpStr, new as3hx.Compat.Regex('^(\\w*?)\\s*(\\:|\\.|\\(|\\bsa\\b|\\bwen\\b)', ''));
		var trigger:String = (word != null) ? Std.string(word[2]) : '';

		if (editor.signatureHelpActive && trigger == '(') {
			menuStr = Std.string(word[1]);
		} else {
			word = as3hx.Compat.match(tmpStr, new as3hx.Compat.Regex('^(\\w*)\\b', ''));
			menuStr = (word != null) ? Std.string(word[1]) : '';
		}

		menuStr = Std.string(menuStr.split('').reverse().join(''));
		pos -= AS3.int(menuStr.length + 1);

		//make sure this value is lower case for filtering
		menuStr = menuStr.toLowerCase();

		menuCollection.source = items;

		var position:Point = editor.getPointForIndex(pos + 1);
		position.x -= editor.horizontalScrollBar.scrollPosition;

		menuRefY = position.y;

		PopUpManager.addPopUp(completionList, editor, false);
		completionList.x = position.x;
		completionList.y = position.y;
		completionList.setFocus();
		completionList.selectedIndex = 0;
		completionList.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
		completionList.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
		completionList.addEventListener(FocusEvent.FOCUS_OUT, onMenuFocusOut);
		completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
		completionList.addEventListener(Event.CHANGE, onMenuChange);
		rePositionMenu();

		filterMenu();

		if (items.length > 0) {
			var resolveEvent:ResolveCompletionItemEvent = new ResolveCompletionItemEvent(
			ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM, items[0]);
			GlobalEventDispatcher.getInstance().dispatchEvent(resolveEvent);
		}
	}

	public function resolveCompletionItem(resolvedItem:CompletionItem):Void {
		menuCollection.itemUpdated(resolvedItem);
	}

	public function closeCompletionList():Void {
		if (!this.isActive) {
			return;
		}
		PopUpManager.removePopUp(completionList);
		completionList.removeEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
		completionList.removeEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
		completionList.removeEventListener(FocusEvent.FOCUS_OUT, onMenuFocusOut);
		completionList.removeEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
		completionList.removeEventListener(Event.CHANGE, onMenuChange);
		completionList.closeDocumentation();
	}

	private function filterMenu():Bool {
		menuCollection.refresh();

		if (menuCollection.length == 0) {
			return false;
		}

		//validate so that the list's layout updates with the new
		//filtered items
		completionList.validateNow();
		completionList.selectedIndex = 0;
		//for some reason, we need to validate again, or the
		//verticalScrollPosition will not change
		completionList.validateNow();
		completionList.dataGroup.verticalScrollPosition = 0;

		rePositionMenu();

		return true;
	}

	private function completeItem(item:CompletionItem):Void {
		var startIndex:Int = caret - menuStr.length;
		var endIndex:Int = caret;
		var text:String = item.insertText;
		if (text == null) {
			text = item.label;
		}

		var hasSelectedLineAutoCloseAttr:Bool = false;
		if (item.kind != CompletionItemKind.CLASS && item.kind != CompletionItemKind.VALUE && isPlaceInLineAllowedToAutoCloseAttr(startIndex, endIndex)) {
			var itemWithNamespaceRegExp:as3hx.Compat.Regex = new as3hx.Compat.Regex('\\w+(?=:)', '');
			if (!AS3.as(itemWithNamespaceRegExp.test(item.insertText), Bool)) {
				hasSelectedLineAutoCloseAttr = checkSelectedLineIfItIsForAutoCloseAttr(startIndex, endIndex);
				if (item.kind == CompletionItemKind.VARIABLE && item.insertText != null) {
					hasSelectedLineAutoCloseAttr = false;
				}

				if (hasSelectedLineAutoCloseAttr) {
					text = item.label + '=""';
				}
			}
		}

		if (!hasSelectedLineAutoCloseAttr && item.kind == CompletionItemKind.METHOD) {
			text = item.label + '()';
		}

		editor.setCompletionData(startIndex, endIndex, text);

		if ((item.kind == CompletionItemKind.METHOD || hasSelectedLineAutoCloseAttr)
			&& item.kind != CompletionItemKind.CLASS
			&& item.kind != CompletionItemKind.VALUE) {
			var lineIndex:Int = model.selectedLineIndex;
			var cursorIndex:Int = startIndex + text.length - 1;
			model.setSelection(lineIndex, cursorIndex, lineIndex, cursorIndex);
		}

		var additionalTextEdits:Array<TextEdit> = cast item.additionalTextEdits;
		if (additionalTextEdits != null) {
			var activeEditor:BasicTextEditor = BasicTextEditor(IDEModel.getInstance().activeEditor);
			var uri:String = Std.string(activeEditor.currentFile.fileBridge.url);
			var workspaceEdit:WorkspaceEdit = new WorkspaceEdit();
			var changes:Dynamic = {};
			Reflect.setField(changes, uri, additionalTextEdits);
			workspaceEdit.changes = changes;
			ApplyWorkspaceEdit.applyWorkspaceEdit(workspaceEdit);
		}

		var command:Command = item.command;
		if (command != null) {
			var commandEvent:ExecuteLanguageServerCommandEvent = new ExecuteLanguageServerCommandEvent(
			ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, command.command, command.arguments);
			GlobalEventDispatcher.getInstance().dispatchEvent(commandEvent);
		}
	}

	private function onMenuFocusOut(event:FocusEvent):Void {
		this.closeCompletionList();
	}

	private function onMenuChange(event:Event):Void {
		if (!isActive) {
			return;
		}
		var item:CompletionItem = AS3.as(completionList.selectedItem, CompletionItem);
		if (item == null) {
			return;
		}
		var resolveEvent:ResolveCompletionItemEvent = new ResolveCompletionItemEvent(
		ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM, item);
		GlobalEventDispatcher.getInstance().dispatchEvent(resolveEvent);
	}

	private function onMenuKey(e:KeyboardEvent):Void {
		if (e.charCode != 0) {
			caret = model.caretIndex;
			if (e.keyCode == Keyboard.BACKSPACE) {
				editor.setCompletionData(caret - 1, caret, '');
				if (menuStr.length > 0) {
					menuStr = menuStr.substr(0, -1);
					if (filterMenu()) {
						return;
					}
				}
			} else if (e.keyCode == Keyboard.DELETE) {
				editor.setCompletionData(caret, caret + 1, '');
			} else if (e.charCode > 31 && e.charCode < 127) {
				var ch:String = String.fromCharCode(e.charCode);
				//we rely on the fact that menuStr is lower case when we
				//filter the collection elsewhere
				menuStr += ch.toLowerCase();
				editor.setCompletionData(caret, caret, ch);
				if (filterMenu()) {
					return;
				}
				//stop the character from appearing twice
				e.preventDefault();
			} else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB) {
				var selectedValue:CompletionItem = CompletionItem(completionList.selectedItem);
				if (selectedValue != null) {
					completeItem(selectedValue);
				}
			}
			this.closeCompletionList();
		}
	}

	private function onMenuDoubleClick(event:MouseEvent):Void {
		caret = model.caretIndex;
		var selectedValue:CompletionItem = CompletionItem(completionList.selectedItem);
		if (selectedValue != null) {
			completeItem(selectedValue);
		}
		this.closeCompletionList();
	}

	private function onMenuRemoved(event:Event):Void {
		var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
					editor.setFocus();
					as3hx.Compat.clearTimeout(timeoutValue);
				}, 1);
		menuCollection.removeAll();
	}

	private function rePositionMenu():Void {
		if (completionList.x + completionList.width > completionList.stage.stageWidth) {
			completionList.x = completionList.stage.stageWidth - completionList.width;
		}

		var completionListHeight:Float = completionList.height;
		var smallestMenuHeight:Float =
		(MIN_CODECOMPLETION_LIST_HEIGHT < completionListHeight) ? MIN_CODECOMPLETION_LIST_HEIGHT : completionListHeight;

		var menuH:Int = AS3.int(smallestMenuHeight * 17);
		if (menuRefY + 15 + menuH > completionList.stage.stageHeight) {
			completionList.y = (menuRefY - menuH - 2);
		} else {
			completionList.y = (menuRefY + 15);
		}
	}

	private function checkSelectedLineIfItIsForAutoCloseAttr(startIndex:Int, endIndex:Int):Bool {
		var line:TextLineModel = editor.model.selectedLine;
		var selectedLineText:String = line.text;
		var isLineForAutoCloseAttr:Bool = false;
		if (line != null && selectedLineText != null) {
			isLineForAutoCloseAttr = selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1 &&
					selectedLineText.lastIndexOf(CompletionListCodeTokens.XML_CLOSE_TAG) != -1 &&
					selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1 &&
					selectedLineText.indexOf(CompletionListCodeTokens.CDATA_OPEN) == -1 &&
					selectedLineText.indexOf(CompletionListCodeTokens.CDATA_CLOSE) == -1;

			var linesCount:Int = editor.model.lines.length;
			var isNonXMLFile:Bool;
			var lineIndex:Int;
			for (lineIndex in 0...linesCount) {
				line = editor.model.lines[lineIndex];
				if (line.text != null && line.text.indexOf(CompletionListCodeTokens.PACKAGE) > -1) {
					isNonXMLFile = true;
					break;
				}
			}

			if (!isLineForAutoCloseAttr && !isNonXMLFile) {
				var searchedLinesCount:Int = editor.model.selectedLineIndex - 250;
				if (searchedLinesCount < 0) {
					searchedLinesCount = 0;
				}

				lineIndex = editor.model.selectedLineIndex;

				while (lineIndex > searchedLinesCount) {
					line = editor.model.lines[lineIndex];
					selectedLineText = line.text;

					var hasCdataOpen:Bool = selectedLineText.indexOf(CompletionListCodeTokens.CDATA_OPEN) != -1;
					var hasCdataClose:Bool = false;
					if (hasCdataOpen) {
						var cdataOpenIndex:Int = lineIndex;
						searchedLinesCount = AS3.int(editor.model.selectedLineIndex + 250);
						if (searchedLinesCount > editor.model.lines.length) {
							searchedLinesCount = editor.model.lines.length;
						}

						lineIndex = editor.model.selectedLineIndex;

						while (lineIndex < searchedLinesCount) {
							line = editor.model.lines[lineIndex];
							selectedLineText = line.text;
							hasCdataClose = selectedLineText.indexOf(CompletionListCodeTokens.CDATA_CLOSE) != -1;
							if (hasCdataClose) {
								break;
							}
							lineIndex++;
						}

						if (hasCdataClose) {
							if (lineIndex > editor.model.selectedLineIndex && cdataOpenIndex < editor.model.selectedLineIndex) {
								return false;
							}
						}
					}
					lineIndex--;
				}

				searchedLinesCount = AS3.int(editor.model.selectedLineIndex - 250);
				if (searchedLinesCount < 0) {
					searchedLinesCount = 0;
				}

				lineIndex = editor.model.selectedLineIndex;

				while (lineIndex > searchedLinesCount) {
					line = editor.model.lines[lineIndex];
					selectedLineText = line.text;
					if (selectedLineText != null) {
						if (selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) != -1 &&
							selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1) {
							break;
						}

						if (selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1 &&
							selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1) {
							isLineForAutoCloseAttr = true;
							break;
						}
					}
					lineIndex--;
				}

				if (isLineForAutoCloseAttr) {
					searchedLinesCount = AS3.int(editor.model.selectedLineIndex + 250);
					if (searchedLinesCount > linesCount) {
						searchedLinesCount = linesCount;
					}

					isLineForAutoCloseAttr = false;
					for (lineIndex in editor.model.selectedLineIndex...searchedLinesCount) {
						line = editor.model.lines[lineIndex];
						selectedLineText = line.text;
						if (selectedLineText.indexOf(CompletionListCodeTokens.XML_CLOSE_TAG) != -1 &&
							selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1) {
							if (selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) == -1) {
								isLineForAutoCloseAttr = true;
								break;
							}
						}
					}
				}
			}
		}

		return isLineForAutoCloseAttr;
	}

	private function isPlaceInLineAllowedToAutoCloseAttr(startIndex:Int, endIndex:Int):Bool {
		var line:TextLineModel = editor.model.selectedLine;

		if (line == null) {
			return false;
		}

		var partOfSelectedLine:String = line.text.substring(startIndex - 1, endIndex + 1);
		var hasQuotations:Bool = AS3.as(new as3hx.Compat.Regex(new as3hx.Compat.Regex('^\\".+.\\"', '')).test(partOfSelectedLine), Bool);

		return !hasQuotations;
	}

	private function filterCodeCompletionMenu(item:CompletionItem):Bool {
		if (menuStr.length == 0) {
			//all items are visible
			return true;
		}
		//we don't need to call toLowerCase() on sortLabel and menuStr here
		//because they are already lower case
		return item.sortLabel.indexOf(menuStr) > -1;
	}

	private function sortCodeCompletionMenu(itemA:CompletionItem, itemB:CompletionItem, fields:Array<Dynamic>):Int {
		if (menuStr.length == 0) {
			//sortLabel is already lowercase, so telling stringCompare() to
			//compare case-sensitive can be faster by avoiding a call to
			//toLowerCase()
			return AS3.int(ObjectUtil.stringCompare(itemA.sortLabel, itemB.sortLabel, false));
		}

		//we don't need to call toLowerCase() on sortLabel and menuStr here
		//because they are already lower case
		var indexOfLabelItemA:Int = itemA.sortLabel.indexOf(menuStr);
		var indexOfLabelItemB:Int = itemB.sortLabel.indexOf(menuStr);

		return AS3.int(ObjectUtil.numericCompare(indexOfLabelItemA, indexOfLabelItemB));
	}

}