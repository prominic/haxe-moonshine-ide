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
package actionScripts.plugin.findreplace;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import flash.display.DisplayObject;
import flash.events.Event;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.ApplicationEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.findreplace.view.GoToLineView;
import actionScripts.plugin.findreplace.view.SearchView;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.vo.SearchResult;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.ConstantsCoreVO;

class FindReplacePlugin extends PluginBase {

	public static inline var EVENT_FIND_NEXT:String = 'findNextEvent';
	public static inline var EVENT_FIND_PREV:String = 'findPrevEvent';
	public static inline var EVENT_REPLACE_ONE:String = 'replaceOneEvent';
	public static inline var EVENT_REPLACE_ALL:String = 'replaceAllEvent';
	public static inline var EVENT_FIND_SHOW_ALL:String = 'findAndShowAllEvent';
	public static inline var EVENT_GO_TO_LINE:String = 'goToLine';

	private var searchView:SearchView;
	private var gotoLineView:GoToLineView;

	private var searchReplaceRe:as3hx.Compat.Regex = new as3hx.Compat.Regex('^(?:\\/)?((?:\\\\[^\\/]|\\\\\\/|\\[(?:\\\\[^\\]]|\\\\\\]|[^\\\\\\]])+\\]|[^\\[\\]\\\\\\/])+)\\/((?:\\\\[^\\/]|\\\\\\/|[^\\\\\\/])+)?(?:\\/([gismx]*))?$', '');
	private var tempObj:Dynamic;

	public function new() {
		super();
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides Find/Replace';
	}

	override private function get_name():String {
		return 'Find & Replace';
	}

	override public function activate():Void {
		super.activate();

		tempObj = {};
		Reflect.setField(tempObj, 'callback', search);
		Reflect.setField(tempObj, 'commandDesc', 'Run a case-sensitive search in the currently open file.  Syntax:  f keyword');
		registerCommand('f', tempObj);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', search);
		Reflect.setField(tempObj, 'commandDesc', 'Same as \'f\'.  Syntax:  s keyword');
		registerCommand('s', tempObj);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', searchRegexp);
		Reflect.setField(tempObj, 'commandDesc', 'Execute a regular expression in the currently open file.  See http://help.adobe.com/en_US/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b90204-7ea9.html .  Syntax:  sr /pattern/  -or-  sr /pattern/replacement/flags');
		registerCommand('sr', tempObj);

		dispatcher.addEventListener(EVENT_FIND_NEXT, searchHandler);
		dispatcher.addEventListener(EVENT_FIND_PREV, searchHandler);
		dispatcher.addEventListener(EVENT_FIND_SHOW_ALL, findAndShowAllHandler);
		dispatcher.addEventListener(EVENT_GO_TO_LINE, goToLineRequestHandler);
	}

	private function searchHandler(event:Event):Void {
		// No searching for other components than BasicTextEditor
		if (model.activeEditor == null || (AS3.as(model.activeEditor, BasicTextEditor)) == null) {
			return;
		}

		if (searchView != null) {
			dialogSearch(event);
		} else {
			searchView = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SearchView, false), SearchView);

			var as3Project:AS3ProjectVO = AS3.as(model.activeProject, AS3ProjectVO);
			if (as3Project != null) {
				if (as3Project.isVisualEditorProject) {
					searchView.currentState = 'findOnly';
				}
			}

			// Set initial selection
			var editor:BasicTextEditor = BasicTextEditor(model.activeEditor);
			var str:String = editor.getEditorComponent().getSelection();
			if (str.indexOf('\n') == -1) {
				searchView.initialSearchString = str;
			}

			searchView.addEventListener(Event.CLOSE, handleSearchViewClose);
			searchView.addEventListener(EVENT_FIND_NEXT, dialogSearch);
			searchView.addEventListener(EVENT_FIND_PREV, dialogSearch);
			searchView.addEventListener(EVENT_REPLACE_ALL, dialogSearch);
			searchView.addEventListener(EVENT_REPLACE_ONE, dialogSearch);

			// Close window when app is closed
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, closeSearchView);
			PopUpManager.centerPopUp(searchView);
		}
	}

	private function findAndShowAllHandler(event:GeneralEvent):Void {
		// No searching for other components than BasicTextEditor
		if (model.activeEditor == null || (AS3.as(model.activeEditor, BasicTextEditor)) == null) {
			return;
		}

		var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
		editor.searchAndShowAll(Reflect.field(event.value, 'search'));
		if (AS3.as(Reflect.field(event.value, 'range'), Bool)) {
			editor.selectRangeAtLine(Reflect.field(event.value, 'search'), Reflect.field(event.value, 'range'));
		}
	}

	private function goToLineRequestHandler(event:Event):Void {
		// probable termination
		if (!(Std.is(model.activeEditor, BasicTextEditor))) {
			return;
		}

		if (gotoLineView == null) {
			var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);

			gotoLineView = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), GoToLineView, true), GoToLineView);
			gotoLineView.totalLinesCount = editor.getEditorComponent().model.lines.length;
			gotoLineView.addEventListener(CloseEvent.CLOSE, onGotoLineClosed);
			PopUpManager.centerPopUp(gotoLineView);
		}
	}

	private function onGotoLineClosed(event:CloseEvent):Void {
		if (gotoLineView.lineNumber != -1) {
			var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
			var tmpLineIndex:Int = (--gotoLineView.lineNumber != -1) ? gotoLineView.lineNumber : 0;

			var textEditor:TextEditor = editor.getEditorComponent();
			textEditor.model.setSelection(tmpLineIndex, 0, tmpLineIndex, 0);
			textEditor.scrollViewIfNeeded();
			textEditor.invalidateLines();
		}

		gotoLineView.removeEventListener(CloseEvent.CLOSE, onGotoLineClosed);
		gotoLineView = null;
	}

	private function closeSearchView(event:Event):Void {
		PopUpManager.removePopUp(searchView);
	}

	private function handleSearchViewClose(event:Event):Void {
		searchView.removeEventListener(Event.CLOSE, handleSearchViewClose);
		searchView.removeEventListener(EVENT_FIND_NEXT, dialogSearch);
		searchView.removeEventListener(EVENT_FIND_PREV, dialogSearch);
		searchView.removeEventListener(EVENT_REPLACE_ALL, dialogSearch);
		searchView.removeEventListener(EVENT_REPLACE_ONE, dialogSearch);

		dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, closeSearchView);

		searchView = null;
	}

	private function search(args:Array<Dynamic>):Void {
		var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
		if (editor != null && args.length != 0) {
			var search:String = Std.string(args[0]);
			if (search == '' || search == null) {
				return;
			}
			var res:SearchResult = editor.search(search, false);

			if (res.totalMatches == 0) {
				print('No matches for \'%s\'', search);
			} else {
				print('%s matches for \'%s\'', res.totalMatches, search);
			}
		}
	}

	private function searchRegexp(args:Array<Dynamic>):Void {
		var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);
		if (editor != null && args.length != 0) {
			var str:String = Std.string(args[0]);
			if (str == '' || str == null) {
				return;
			}

			//var match:Array = editor.text.match(str);
			var match:Array<Dynamic> = as3hx.Compat.match(str, searchReplaceRe);
			if (match != null) {
				var search:String = Std.string(match[1]);
				if (search == '' || search == null) {
					return;
				}
				// it convert regexp string to normal string so always fail at serach for regexp string for eg. [sS]cript
				//search = TextUtil.escapeRegex(search);
				var replace:String = Std.string(match[2]);
				var flags:String = Std.string(match[3]);

				var hadGlobalFlag:Bool = (flags != null && flags.indexOf('g') != -1);

				// Need global flag for searching
				if (flags == null) {
					flags = 'g';
				}
				if (flags.indexOf('g') == -1) {
					flags += 'g';
				}

				var re:as3hx.Compat.Regex = new as3hx.Compat.Regex(search, flags);
				var res:SearchResult;

				if (replace != null) {
					res = editor.searchReplace(re, replace, hadGlobalFlag);

					if (res.totalReplaces > 0) {
						print('Replaced %s occurances of \'%s\'', res.totalReplaces, search);
					} else {
						print('No matches for \'%s\'', search);
					}
				} else {
					res = editor.search(re);
					if (res.totalMatches == 0) {
						print('No matches for \'%s\'', search);
					} else {
						print('%s matches for \'%s\'', res.totalMatches, search);
					}
				}
			}// Bad input.
			else {
				// Bad input.
				print('Unknown format. Usage: sr /search/ or /search/replace/flags');
			}
		}
	}

	private function dialogSearch(event:Event):Void {
		var editor:BasicTextEditor = AS3.as(model.activeEditor, BasicTextEditor);

		var searchText:String = searchView.findInput.text;
		var replaceText:String = searchView.replaceInput.text;
		var searchRegExp:as3hx.Compat.Regex;

		if (searchText == '') {
			return;
		}

		if (AS3.as(searchView.optionRegExp.selected, Bool)) {
			var flags:String = 'g';
			if (!AS3.as(searchView.optionMatchCase.selected, Bool)) {
				flags += 'i';
			}
			if (AS3.as(searchView.optionEscapeChars.selected, Bool)) {
				searchText = TextUtil.escapeRegex(searchText);
			}
			searchRegExp = new as3hx.Compat.Regex(searchText, flags);
		} else if (searchView.optionMatchCase.selected == false) {
			// We need to use regexp for case non-matching,
			//  but we hide that from the user. (always escape chars)
			flags = 'gi';
			searchText = TextUtil.escapeRegex(searchText);
			searchRegExp = new as3hx.Compat.Regex(searchText, flags);
		}

		var result:SearchResult;

		// Perform search of type
		if (event.type == EVENT_FIND_NEXT) {
			result = editor.search((searchRegExp != null) ? searchRegExp : searchText);
		} else if (event.type == EVENT_FIND_PREV) {
			result = editor.search((searchRegExp != null) ? searchRegExp : searchText, true);
		} else if (event.type == EVENT_REPLACE_ALL) {
			result = editor.searchReplace((searchRegExp != null) ? searchRegExp : searchText, replaceText, true);
		} else if (event.type == EVENT_REPLACE_ONE) {
			result = editor.searchReplace((searchRegExp != null) ? searchRegExp : searchText, replaceText, false);
		}

		// Display # of matches & position if any
		if (result.totalMatches > 0) {
			searchView.findInput.resultText = (result.selectedIndex + 1) + '/' + result.totalMatches;
		} else {
			searchView.findInput.resultText = Std.string(Std.string(result.totalMatches));
		}

		var as3Project:AS3ProjectVO = AS3.as(model.activeProject, AS3ProjectVO);
		if (as3Project != null) {
			if (as3Project.isVisualEditorProject) {
				dispatcher.dispatchEvent(new Event('switchTabToCode'));
			}
		}
	}

}