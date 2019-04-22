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

import actionScripts.events.OpenFileEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.Timer;
import actionScripts.events.ChangeEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.LayoutEvent;
import actionScripts.ui.editor.text.change.TextChangeBase;
import actionScripts.ui.editor.text.change.TextChangeInsert;
import actionScripts.ui.editor.text.change.TextChangeMulti;
import actionScripts.ui.editor.text.change.TextChangeRemove;
import actionScripts.ui.editor.text.events.DebugLineEvent;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Settings;

class SelectionManager {

	private var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

	private static inline var SCROLL_THRESHOLD:Int = 10;
	private static inline var SCROLL_INTERVAL:Int = 60;

	private var editor:TextEditor;
	private var model:TextEditorModel;

	private var dragStartChar:Int = -1;
	private var dragEndChar:Int = -1;
	private var dragStartLine:Int = -1;
	private var dragStagePoint:Point;
	private var dragLocalPoint:Point;
	private var dragScrollTimer:Timer;
	private var dragScrollDelta:Int = 0;

	private var lastClickTime:Int = 0;
	private var lastClickPos:Point = new Point(0, 0);
	private var clickCount:Int = 0;

	public function new(editor:TextEditor, model:TextEditorModel) {
		this.editor = editor;
		this.model = model;

		editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
		editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		editor.addEventListener(Event.SELECT_ALL, handleSelectAll);

		editor.itemContainer.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		editor.itemContainer.addEventListener(MouseEvent.MOUSE_OVER, updateCursor);
		editor.itemContainer.addEventListener(MouseEvent.MOUSE_MOVE, updateCursor);
		editor.itemContainer.addEventListener(MouseEvent.MOUSE_OUT, resetCursor);
	}

	private function handleMouseDown(event:MouseEvent):Void {
		var stagePoint:Point = new Point(event.stageX, event.stageY);
		var localPoint:Point = editor.globalToLocal(stagePoint);

		// Double click?
		if (clickCount > 0 && flash.utils.getTimer() - lastClickTime < 300 && Point.distance(stagePoint, lastClickPos) < 10) {
			clickCount = AS3.int(clickCount % 3 + 1);
		} else {
			clickCount = 1;
		}

		var startLine:Int;
		var startChar:Int;
		var endLine:Int;
		var endChar:Int;

		var rdr:TextLineRenderer = getRendererAtPoint(stagePoint);
		if (rdr == null) {
			return;
		}

		var newCaretPosition:Int = rdr.getCharIndexFromPoint(AS3.int(stagePoint.x));
		if (newCaretPosition > -1) {
			if (clickCount == 1) {
				startLine = (event.shiftKey) ? (model.hasSelection) ? model.selectionStartLineIndex : model.selectedLineIndex : rdr.dataIndex;
				startChar = (event.shiftKey) ? (model.hasSelection) ? model.selectionStartCharIndex : model.caretIndex : newCaretPosition;

				endLine = rdr.dataIndex;
				endChar = newCaretPosition;
			} else if (clickCount == 2) {
				startLine = endLine = rdr.dataIndex;

				startChar = AS3.int(newCaretPosition - TextUtil.wordBoundaryBackward(model.lines[startLine].text.substring(0, newCaretPosition)));
				endChar = AS3.int(newCaretPosition + TextUtil.wordBoundaryForward(model.lines[endLine].text.substring(newCaretPosition)));
			} else if (clickCount == 3) {
				startLine = endLine = rdr.dataIndex;

				startChar = 0;
				endChar = model.lines[startLine].text.length;
			}
			if (localPoint.x <= 41) {
				toggleBreakpoint(rdr.dataIndex);
			}
		} else if (localPoint.x < editor.lineNumberWidth && localPoint.x > 16) {
			// set breakpoint when click on line number sprite
			if (localPoint.x <= 41) {
				toggleBreakpoint(rdr.dataIndex);
				return;
			}

			startLine = (event.shiftKey) ? (model.hasSelection) ? model.selectionStartLineIndex : model.selectedLineIndex : rdr.dataIndex;
			startChar = (event.shiftKey) ? (model.hasSelection) ? model.selectionStartCharIndex : model.caretIndex : 0;

			endLine = AS3.int(rdr.dataIndex + ((event.shiftKey && (startLine > rdr.dataIndex || startLine == rdr.dataIndex && startChar > 0)) ? 0 : 1));
			endChar = 0;

			if (endLine >= model.lines.length) {
				endLine = AS3.int(model.lines.length - 1);
				endChar = model.lines[endLine].text.length;
			}
		} else if (localPoint.x >= 0 && localPoint.x <= 16) {
			toggleBreakpoint(rdr.dataIndex);
			return;
		} else {
			return;
		}

		model.setSelection(startLine, startChar, endLine, endChar);
		editor.invalidateSelection();

		dragStartLine = startLine;
		dragStartChar = startChar;
		dragEndChar = endChar;
		dragStagePoint = stagePoint;
		dragLocalPoint = localPoint;
		editor.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		editor.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		editor.addEventListener(LayoutEvent.LAYOUT, handleEditorLayout);
		dispatcher.addEventListener(OpenFileEvent.OPEN_FILE, handleOpenFile);

		lastClickPos = stagePoint;
		lastClickTime = AS3.int(flash.utils.getTimer());
	}

	private function handleOpenFile(event:OpenFileEvent):Void {
		//if a new file is opened or the editor scrolls goto definition,
		//cancel the drag
		handleMouseUp(null);
	}

	private function handleMouseUp(event:MouseEvent):Void {
		stopDragScroll();
		if (AS3.as(editor.stage, Bool)) {
			editor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			editor.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		editor.removeEventListener(LayoutEvent.LAYOUT, handleEditorLayout);
		dispatcher.removeEventListener(OpenFileEvent.OPEN_FILE, handleOpenFile);

		dragStartLine = -1;
		dragEndChar = -1;
		dragStartChar = -1;
	}

	private function handleMouseMove(event:MouseEvent):Void {
		var stagePoint:Point = new Point(event.stageX, event.stageY);
		var localPoint:Point = editor.globalToLocal(stagePoint);

		dragStagePoint = stagePoint;
		dragLocalPoint = localPoint;
		dragScrollDelta = 0;

		if (localPoint.y <= SCROLL_THRESHOLD) {
			dragScrollDelta = Math.ceil((localPoint.y - SCROLL_THRESHOLD) / SCROLL_THRESHOLD);
		} else if (localPoint.y >= model.viewHeight - SCROLL_THRESHOLD) {
			dragScrollDelta = Math.ceil((localPoint.y - (model.viewHeight - SCROLL_THRESHOLD)) / SCROLL_THRESHOLD);
		}
		if (dragScrollDelta == 0) {
			stopDragScroll();
			updateDragSelect();
		} else if (dragScrollTimer == null) {
			startDragScroll();
		}
	}

	private function handleEditorLayout(event:LayoutEvent):Void {
		updateDragSelect();
	}

	private function updateDragSelect():Void {
		var stagePoint:Point = dragStagePoint;
		var localPoint:Point = dragLocalPoint;

		var startLine:Int = dragStartLine;
		var startChar:Int = dragEndChar;
		var endLine:Int;
		var endChar:Int;

		var rdr:TextLineRenderer = getRendererAtPoint(stagePoint);
		if (rdr == null) {
			return;
		}

		var newCaretPosition:Int = rdr.getCharIndexFromPoint(AS3.int(stagePoint.x));

		if (newCaretPosition < dragStartChar && rdr.dataIndex <= dragStartLine) {
			startChar = dragEndChar;
		} else if (newCaretPosition > dragEndChar && rdr.dataIndex >= dragStartLine) {
			startChar = dragStartChar;
		} else if (rdr.dataIndex < dragStartLine) {
			startChar = dragEndChar;
		} else if (rdr.dataIndex > dragStartLine) {
			startChar = dragStartChar;
		}

		if (newCaretPosition > -1) {
			if (clickCount == 1) {
				endLine = rdr.dataIndex;
				endChar = newCaretPosition;
			} else if (clickCount == 2) {
				endLine = rdr.dataIndex;
				endChar = AS3.int(newCaretPosition + TextUtil.wordBoundaryForward(model.lines[endLine].text.substring(newCaretPosition)));
			} else if (clickCount == 3) {
				endLine = rdr.dataIndex;
				endChar = model.lines[endLine].text.length;
			}
		} else if (localPoint.x < editor.lineNumberWidth) {
			endLine = AS3.int(rdr.dataIndex + ((startLine > rdr.dataIndex || startLine == rdr.dataIndex && startChar > 0) ? 0 : 1));
			endChar = 0;

			if (endLine >= model.lines.length) {
				endLine = AS3.int(model.lines.length - 1);
				endChar = model.lines[endLine].text.length;
			}
		} else {
			return;
		}

		if (startChar != endChar) {
			model.setSelection(startLine, startChar, endLine, endChar);
			editor.invalidateSelection();
		}

	}

	private function startDragScroll():Void {
		dragScrollTimer = new Timer(SCROLL_INTERVAL);
		dragScrollTimer.addEventListener(TimerEvent.TIMER, handleDragScroll);
		dragScrollTimer.start();
	}

	private function stopDragScroll():Void {
		if (dragScrollTimer != null) {
			dragScrollTimer.stop();
			dragScrollTimer = null;
		}
	}

	private function handleDragScroll(event:TimerEvent):Void {
		editor.scrollTo(model.scrollPosition + dragScrollDelta);
	}

	private function updateCursor(event:MouseEvent):Void {
		var stagePoint:Point = new Point(event.stageX, event.stageY);
		var localPoint:Point = editor.globalToLocal(stagePoint);

		// This should actually be a mirrored arrow over the line-numbers
		Mouse.cursor = (localPoint.x < editor.lineNumberWidth) ? MouseCursor.ARROW : MouseCursor.IBEAM;
	}

	private function resetCursor(event:MouseEvent):Void {
		Mouse.cursor = MouseCursor.AUTO;
	}

	private function handleKeyDown(event:KeyboardEvent):Void {
		var processed:Bool = true;
		var chars:Int = 1;
		var word:Bool = Reflect.getProperty(event, Settings.keyboard.wordModifierKey) != null;
		var tabIndex:Int = -1;

		switch (event.keyCode) {
			case Keyboard.A:
				if (Reflect.getProperty(event, Settings.keyboard.copyModifierKey) != null && !event.altKey) {
					model.selectedLineIndex = AS3.int(model.lines.length - 1);
					model.selectionStartLineIndex = 0;
					model.selectionStartCharIndex = 0;
					model.caretIndex = model.selectedLine.text.length;
				}
			case Keyboard.LEFT:
				if ((Type.getInstanceFields(Type.getClass(event)).indexOf('commandKey') != -1) && Reflect.getProperty(event, 'commandKey') != null) {
					// CHECK COMMAND KEY VALUE // Mac specific text editing functionality
					{
						if (!event.shiftKey && model.hasSelection) {
							removeSelection();
						}
						startSelectionIfNeeded(event.shiftKey);

						tabIndex = TextUtil.indentAmount(model.selectedLine.text);

						if (model.caretIndex == tabIndex) {
							model.caretIndex = 0;
						} else {
							model.caretIndex = tabIndex;
						}
					}
				} else if (model.hasSelection && !event.shiftKey) {
					if (model.selectedLineIndex > model.selectionStartLineIndex || model.caretIndex > model.selectionStartCharIndex) {
						focusSelectionStart();
					}

					removeSelection();
				} else if (model.caretIndex > 0) {
					if (word) {
						chars = TextUtil.wordBoundaryBackward(model.selectedLine.text.substring(0, model.caretIndex));
					}
					startSelectionIfNeeded(event.shiftKey);
					model.caretIndex -= chars;
				} else {
					if (model.selectedLineIndex == 0) {
						return;
					}
					startSelectionIfNeeded(event.shiftKey);

					model.selectedLineIndex--;
					model.caretIndex = model.selectedLine.text.length;
				}
			case Keyboard.RIGHT:
				if ((Type.getInstanceFields(Type.getClass(event)).indexOf('commandKey') != -1) && Reflect.getProperty(event, 'commandKey') != null) {
					// CHECK COMMAND KEY VALUE // Mac specific text editing functionality
					{
						if (!event.shiftKey && model.hasSelection) {
							removeSelection();
						}
						startSelectionIfNeeded(event.shiftKey);
						model.caretIndex = model.selectedLine.text.length;
					}
				} else if (model.hasSelection && !event.shiftKey) {
					if (model.selectedLineIndex < model.selectionStartLineIndex || model.caretIndex < model.selectionStartCharIndex) {
						focusSelectionStart();
					}
					removeSelection();
				} else if (model.caretIndex < model.selectedLine.text.length) {
					if (word) {
						chars = TextUtil.wordBoundaryForward(model.selectedLine.text.substring(model.caretIndex));
					}

					startSelectionIfNeeded(event.shiftKey);
					model.caretIndex += chars;
				} else if (model.selectedLineIndex < model.lines.length - 1) {
					startSelectionIfNeeded(event.shiftKey);

					model.selectedLineIndex++;
					model.caretIndex = 0;
				}
			case Keyboard.UP:
				if (event.ctrlKey) {
					if (model.scrollPosition > 0) {
						// Ensure the caret stays in view (unless there's active selection)
						if (!model.hasSelection && model.selectedLineIndex > model.scrollPosition + model.renderersNeeded - 3) {
							model.selectedLineIndex = AS3.int(model.scrollPosition + model.renderersNeeded - 3);
						}
						editor.scrollTo(model.scrollPosition - 1);
					}
				} else {
					if (model.hasSelection && !event.shiftKey) {
						removeSelection();
					}
					if (model.selectedLineIndex > 0) {
						startSelectionIfNeeded(event.shiftKey);

						model.selectedLineIndex--;
					}
				}
			case Keyboard.DOWN:
				if (event.ctrlKey) {
					if (model.scrollPosition < model.lines.length - model.renderersNeeded + 1) {
						// Ensure the caret stays in view (unless there's active selection)
						if (!model.hasSelection && model.selectedLineIndex < model.scrollPosition + 1) {
							model.selectedLineIndex = AS3.int(model.scrollPosition + 1);
						}
						editor.scrollTo(model.scrollPosition + 1);
					}
				} else {
					if (model.hasSelection && !event.shiftKey) {
						removeSelection();
					}
					if (model.selectedLineIndex < model.lines.length - 1) {
						startSelectionIfNeeded(event.shiftKey);

						model.selectedLineIndex++;
					}
				}
			case Keyboard.PAGE_DOWN:
				if (model.hasSelection && !event.shiftKey) {
					removeSelection();
				}
				startSelectionIfNeeded(event.shiftKey);

				if (event.ctrlKey) {
					model.selectedLineIndex = AS3.int(model.scrollPosition + model.renderersNeeded - 2);
				} else {
					model.selectedLineIndex = AS3.int(Math.min(model.selectedLineIndex + model.renderersNeeded, model.lines.length - 1));

					editor.scrollTo(model.scrollPosition + model.renderersNeeded);
				}
			case Keyboard.PAGE_UP:
				if (model.hasSelection && !event.shiftKey) {
					removeSelection();
				}
				startSelectionIfNeeded(event.shiftKey);

				if (event.ctrlKey) {
					model.selectedLineIndex = model.scrollPosition;
				} else {
					model.selectedLineIndex = AS3.int(Math.max(model.selectedLineIndex - model.renderersNeeded, 0));

					editor.scrollTo(model.scrollPosition - model.renderersNeeded);
				}
			case Keyboard.HOME:
				if (model.hasSelection && !event.shiftKey) {
					removeSelection();
				}
				startSelectionIfNeeded(event.shiftKey);

				if (event.ctrlKey) {
					model.selectedLineIndex = 0;
					model.caretIndex = 0;
				} else {
					tabIndex = TextUtil.indentAmount(model.selectedLine.text);

					if (model.caretIndex == tabIndex) {
						model.caretIndex = 0;
					} else {
						model.caretIndex = tabIndex;
					}
				}
			case Keyboard.END:
				if (model.hasSelection && !event.shiftKey) {
					removeSelection();
				}
				startSelectionIfNeeded(event.shiftKey);

				if (event.ctrlKey) {
					model.selectedLineIndex = AS3.int(model.lines.length - 1);
					model.caretIndex = model.selectedLine.text.length;
				} else if (model.caretIndex < model.selectedLine.text.length) {
					model.caretIndex = model.selectedLine.text.length;
				}
			case _:
				{
					// Unflag as processed if nothing matched
					processed = false;
				}
		}
		if (processed) {
			editor.invalidateSelection();
		}
	}

	private function handleSelectAll(event:Event):Void {
		model.setSelection(0, 0, model.lines.length - 1, model.lines[model.lines.length - 1].text.length);
		editor.invalidateSelection();
	}

	private function handleChange(event:ChangeEvent):Void {
		if (event.origin != ChangeEvent.ORIGIN_REMOTE) {
			model.removeSelection();

			applyChange(event.change);

			editor.invalidateSelection();
		}
	}

	private function applyChange(change:TextChangeBase):Void {
		if (Std.is(change, TextChangeInsert)) {
			applyChangeInsert(TextChangeInsert(change));
		}
		if (Std.is(change, TextChangeRemove)) {
			applyChangeRemove(TextChangeRemove(change));
		}
		if (Std.is(change, TextChangeMulti)) {
			applyChangeMulti(TextChangeMulti(change));
		}
	}

	private function applyChangeInsert(change:TextChangeInsert):Void {
		var textLines:Array<String> = change.textLines;

		if (textLines != null && textLines.length != 0) {
			// Set caret to the end of the text change
			model.selectedLineIndex = AS3.int(change.startLine + textLines.length - 1);
			model.caretIndex = AS3.int(((textLines.length == 1) ? change.startChar : 0) + textLines[textLines.length - 1].length);
		}
	}

	private function applyChangeRemove(change:TextChangeRemove):Void {
		model.selectedLineIndex = change.startLine;
		model.caretIndex = change.startChar;
	}

	private function applyChangeMulti(change:TextChangeMulti):Void {
		for (subchange in change.changes) {
			applyChange(subchange);
		}
	}

	private function removeSelection():Void {
		model.removeSelection();
	}

	private function focusSelectionStart():Void {
		var selLine:Float = model.selectionStartLineIndex;
		var caretIndex:Float = model.selectionStartCharIndex;

		model.selectedLineIndex = AS3.int(selLine);
		model.caretIndex = AS3.int(caretIndex);
	}

	private function startSelectionIfNeeded(shiftKey:Bool):Void {
		if (!model.hasSelection && shiftKey) {
			model.selectionStartLineIndex = model.selectedLineIndex;
			model.selectionStartCharIndex = model.caretIndex;
		}
	}

	private function toggleBreakpoint(lineIndex:Int):Void {
		/*var model:TextLineModel = model.lines[lineIndex]; ????
		model.breakPoint = !model.breakPoint;
		editor.invalidateLines();*/

		var txtLinemodel:TextLineModel = model.lines[lineIndex];
		txtLinemodel.breakPoint = !txtLinemodel.breakPoint;
		// Send event for breakpoint

		//trace((editor.parent  as BasicTextEditor).currentFile.nativePath+"");
		dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_LINE, lineIndex, txtLinemodel.breakPoint));
		txtLinemodel.traceLine = !txtLinemodel.traceLine;
		editor.invalidateLines();
	}

	private function getRendererAtPoint(stagePoint:Point):TextLineRenderer {
		var count:Int = model.itemRenderersInUse.length;

		var i:Int = 0;

		while (i < count) {
			var rdr:TextLineRenderer = model.itemRenderersInUse[i];
			var rect:Rectangle = rdr.getRect(editor.stage);

			if ((stagePoint.y >= rect.top || i == 0) && (stagePoint.y <= rect.bottom || i == count - 1)) {
				return rdr;
			}
			i++;
		}

		return null;
	}

}