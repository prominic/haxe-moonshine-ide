/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.

Author: Victor Dramba
2009
*/

package actionScripts.ui.editor.text;

import haxe.Constraints.Function;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ShowDropDownForTypeAhead;
import actionScripts.events.LanguageServerEvent;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.ui.editor.text.TextEditorModel;
import actionScripts.utils.VectorToArray;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import mx.controls.Alert;
import org.aswing.Component;
import org.aswing.FocusManager;
import org.aswing.JToolTip;
import org.aswing.event.ListItemEvent;
import org.aswing.geom.IntPoint;

class CodeCompletionMenu {

	private var menuData:Array<String>;
	private var scriptAreaComponent:TextEditor;
	private var menu:ScrollablePopupMenu;
	private var onComplete:Function;
	private var stage:Stage;
	private var menuStr:String;
	private var tooltip:JToolTip;
	private var tooltipCaret:Int = 0;
	private var menuRefY:Int = 0;
	private var position:Int = 0;
	private var selectedIndex:Int = 0;
	private var selectedText:String;
	private var result:Array<Dynamic> = new Array<Dynamic>();
	private var caret:Int = 0;

	public function new(field:TextEditor, stage:Stage, onComplete:Function) {
		scriptAreaComponent = field;
		this.onComplete = cast onComplete;
		this.stage = stage;

		menu = new ScrollablePopupMenu(this.stage);
		menu.doubleClickEnabled = true;
		//restore the focus to the textfield, delayed
		menu.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
		//menu in action
		menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);

		menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):Void {
					caret = scriptAreaComponent.model.caretIndex;
					scriptAreaComponentReplaceText(caret - menuStr.length, caret, Std.string(menu.getSelectedValue()));
					menu.dispose();
				});
		tooltip = new JToolTip();
		//used to close the tooltip
		scriptAreaComponent.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

	}

	private function filterMenu():Bool {
		var item:Array<Dynamic> = [];
		for (str in menuData) {
			if (str.toLowerCase().indexOf(menuStr.toLowerCase()) == 0) {
				item.push(str);
			}
		}
		/*for each (var str:int in menuData)
		if (menuData[str].label.toString().toLowerCase().indexOf(menuStr.toLowerCase())==0) item.push(menuData[str].label);*/

		if (item.length == 0) {
			return false;
		}
		menu.setListData(item);
		menu.setSelectedIndex(0);

		rePositionMenu();
		return true;
	}

	private function onKeyDown(e:KeyboardEvent):Void {
		if (AS3.as(tooltip.isShowing(), Bool)) {
			if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN ||
				String.fromCharCode(e.charCode) == ')' || scriptAreaComponent.model.caretIndex < tooltipCaret) {
				tooltip.disposeToolTip();
			}

		}

		if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey || e.charCode == 46 || e.charCode == 58 && e.shiftKey) {
			var documnet:String = '';
			if (scriptAreaComponent.model.lines.length > 1) {
				for (i in 0...scriptAreaComponent.model.lines.length - 1) {
					var m:TextLineModel = scriptAreaComponent.model.lines[i];
					documnet += m.text + '\n';
				}
			}
			var len:Float = scriptAreaComponent.model.caretIndex - scriptAreaComponent.startPos;
			/*position = scriptAreaComponent.model.caretIndex;
			selectedIndex = scriptAreaComponent.model.selectedLineIndex;
			selectedText = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text;*/
			GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_COMPLETION, scriptAreaComponent.startPos, scriptAreaComponent.model.selectedLineIndex, scriptAreaComponent.model.caretIndex, scriptAreaComponent.model.selectedLineIndex, documnet, len, 1));
			GlobalEventDispatcher.getInstance().addEventListener(ShowDropDownForTypeAhead.EVENT_SHOWDROPDOWN, showDropDownhander);
		}
	}

	private function showDropDownhander(evt:ShowDropDownForTypeAhead):Void {
		GlobalEventDispatcher.getInstance().removeEventListener(ShowDropDownForTypeAhead.EVENT_SHOWDROPDOWN, showDropDownhander);
		result = evt.result;
		triggerTypeAhead();
	}

	private function onMenuKey(e:KeyboardEvent):Void {
		if (e.charCode != 0) {
			caret = scriptAreaComponent.model.caretIndex;
			if (e.keyCode == Keyboard.BACKSPACE) {
				scriptAreaComponentReplaceText(caret - 1, caret, '');
				if (menuStr.length > 0) {
					menuStr = menuStr.substr(0, -1);
					if (filterMenu()) {
						return;
					}
				}
			} else if (e.keyCode == Keyboard.DELETE) {
				scriptAreaComponentReplaceText(caret, caret + 1, '');
			} else if (e.charCode > 31 && e.charCode < 127) {
				var ch:String = String.fromCharCode(e.charCode);
				menuStr += ch.toLowerCase();
				scriptAreaComponentReplaceText(caret, caret, ch);
				if (filterMenu()) {
					return;
				}
			} else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB) {
				//var len:Number = scriptAreaComponent.model.caretIndex - scriptAreaComponent.startPos;
				scriptAreaComponentReplaceText(caret - menuStr.length, caret, Std.string(menu.getSelectedValue()));
				//checkAddImports(menu.getSelectedValue());
				//	if(onComplete)onComplete();
			}
			menu.dispose();
		}
	}

	private function checkAddImports(name:String):Void {
		caret = scriptAreaComponent.model.caretIndex;
		/*if (!ctrl.isInScope(name, caret-name.length))
		{
			var missing:Vector.<String> = ctrl.getMissingImports(name, caret-name.length);
			if (missing)
			{
				var sumChars:int = 0;
				for (var i:int=0; i<missing.length; i++)
				{
					//TODO make a better regexp
					var pos:int = scriptAreaComponent.text.lastIndexOf('package ', scriptAreaComponent.caretIndex);
					pos = scriptAreaComponent.text.indexOf('{', pos) + 1;
					var importStr:String = '\n\t'+(i>0?'//':'')+'import '+missing[i] + '.' + name + ';';
					sumChars += importStr.length;
					scriptAreaComponent.replaceText(pos, pos, irmportStr);
				}
				scriptAreaComponent.setSelection(caret+sumChars, caret+sumChars);
			}
		}*/
	}

	private function scriptAreaComponentReplaceText(begin:Int, end:Int, text:String):Void {
		/*var str:String = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.substring(scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.length,scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.length-1);
		if(str == "." || str == ":")
		{
		  scriptAreaComponent.setTypeAheadData(begin,end,text);
		}
		else
		{
			scriptAreaComponent.replaceText(begin,end,text);
		}*/
		scriptAreaComponent.setCompletionData(begin, end, text);
	}

	private function onMenuRemoved(e:Event):Void {
		as3hx.Compat.setTimeout(function():Void {
					stage.focus = scriptAreaComponent;
					FocusManager.getManager(stage).setFocusOwner(AS3.as(scriptAreaComponent, Component));
				}, 1);
	}

	public function triggerTypeAhead():Void {
		var activeEdiotr:BasicTextEditor = AS3.as(IDEModel.getInstance().activeEditor, BasicTextEditor);
		scriptAreaComponent = activeEdiotr.editor;
		selectedText = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text;
		selectedIndex = scriptAreaComponent.model.selectedLineIndex;
		var pos:Int = scriptAreaComponent.model.caretIndex;
		//look back for last trigger
		var tmpStr:String = Std.string(selectedText.substring(AS3.int(Math.max(0, pos - 100)), pos).split('').reverse().join(''));
		var word:Array<Dynamic> = as3hx.Compat.match(tmpStr, new as3hx.Compat.Regex('^(\\w*?)\\s*(\\:|\\.|\\(|\\bsa\\b|\\bwen\\b)', ''));
		var trigger:String = (word != null) ? Std.string(word[2]) : '';

		if (AS3.as(tooltip.isShowing(), Bool) && trigger == '(') {
			trigger = '';
			menuStr = Std.string(word[1]);
		} else {
			word = as3hx.Compat.match(tmpStr, new as3hx.Compat.Regex('^(\\w*)\\b', ''));
			menuStr = (word != null) ? Std.string(word[1]) : '';
		}

		menuStr = Std.string(menuStr.split('').reverse().join(''));
		pos -= AS3.int(menuStr.length + 1);
		//Replace menudata with java result
		menuData = null;
		menuData = getAllTypes();
		//	var keyword:String = trigger.split('').reverse().join('');

		/*if (keyword == 'new' || keyword == 'as' || keyword == 'is' || keyword == ':' || keyword == 'extends' || keyword == 'implements')
			menuData = ctrl.getTypeOptions();
		else if (trigger == '.')
			menuData = ctrl.getMemberList(pos);
		else if (trigger == '')
			menuData = ctrl.getAllOptions(pos);
		else if (trigger == '(')
		{
			var funDetail:String = ctrl.getFunctionDetails(pos);
			if (funDetail)
			{
				tooltip.setTipText(funDetail);
				var position:Point = scriptAreaComponent.getPointForIndex(model.caretIndex-1);
				position = scriptAreaComponent.localToGlobal(position);
				tooltip.showToolTip();
				tooltip.moveLocationRelatedTo(new IntPoint(position.x, position.y));
				tooltipCaret = model.caretIndex;
				return;
			}
		}*/

		if (menuData == null || menuData.length == 0) {
			return;
		}

		showMenu(pos + 1);
		if (menuStr.length != 0) {
			filterMenu();
		}
	}

	public function getAllTypes():Array<String> {
		var dataVector:Array<String> = new Array<String>();
		for (i in 0...result.length) {
			dataVector.push(Reflect.field(result[i], 'label'));
		}
		return dataVector;
	}

	private function showMenu(index:Int):Void {
		var position:Point;
		menu.setListData(VectorToArray.vectorToArray(menuData));
		menu.setSelectedIndex(0);

		position = scriptAreaComponent.getPointForIndex(index);
		position.x += scriptAreaComponent.horizontalScrollBar.scrollPosition;

		menuRefY = AS3.int(position.y);

		//menu.show(stage, position.x, 0);
		menu.show(stage, AS3.int(position.x), AS3.int(position.y));
		//menu.show(stage, 100, 200);
		stage.focus = menu;
		FocusManager.getManager(stage).setFocusOwner(menu);

		rePositionMenu();
	}

	private function rePositionMenu():Void {
		var menuH:Int = AS3.int(Math.min(8, menu.getModel().getSize()) * 17);
		if (menuRefY + 15 + menuH > stage.stageHeight) {
			menu.setY(menuRefY - menuH - 2);
		} else {
			menu.setY(menuRefY + 15);
		}
	}

}