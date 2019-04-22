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

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;
import mx.controls.HScrollBar;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import mx.events.ScrollEvent;
import mx.managers.IFocusManagerComponent;
import actionScripts.events.ChangeEvent;
import actionScripts.events.LayoutEvent;
import actionScripts.events.LineEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.ui.editor.text.vo.SearchResult;
import actionScripts.ui.parser.ILineParser;
import actionScripts.utils.TextUtil;
import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.Location;
import actionScripts.valueObjects.Position;
import actionScripts.valueObjects.SignatureHelp;
import actionScripts.valueObjects.Command;
import actionScripts.valueObjects.CodeAction;
import actionScripts.valueObjects.CompletionItem;

/**
 *	Line-based text editor. Text rendering with Flash Text Engine.
 *	DataProvider (String) is split up newline & each TextLineRenderer gets one line to render.
 *	Only what can be seen on screen is rendered & item-renderers are reused.
 *
 *	This class handles scrolling & rendering, MVC style.
 *	Different types of rendering can be triggered with various invalidateSomething() calls,
 *	upon which a flag will be set & when the frame exists rendering will happen (the Flex way).
 *
 *	Managers handle non-rendering actions and affect TextEditorModel, which is the base for rendering.
 *	See EditManager, UndoManager, SelectionManager & ColorManager.
 *
 *	WORK IN PROGRESS
 */
@:meta(Style(name = 'backgroundColor', type = 'uint', format = 'Color', inherit = 'no'))
@:meta(Style(name = 'backgroundAlpha', type = 'Number', format = 'Number', inherit = 'no'))
@:meta(Style(name = 'selectionColor', type = 'uint', format = 'Color', inherit = 'yes'))
@:meta(Style(name = 'selectedLineColor', type = 'uint', format = 'Color', inherit = 'no'))
@:meta(Style(name = 'selectedLineColorAlpha', type = 'Number', format = 'Number', inherit = 'no'))
@:meta(Style(name = 'selectedAllInstancesOfASearchStringColorAlpha', type = 'uint', format = 'Color', inherit = 'no'))
class TextEditor extends UIComponent implements IFocusManagerComponent {

	// Amount to look ahead when horiz-scrolling caret into view (8 characters)
	private static var HORIZONTAL_LOOKAHEAD(default, never):Int = AS3.int(TextLineRenderer.charWidth * 8);
	private static inline var WIDTH_UPDATE_DELAY:Int = 100;

	// Holds the text lines
	@:allow(actionScripts.ui.editor.text)
	private var itemContainer:UIComponent = new UIComponent();

	private var verticalScrollBar:ScrollBar;
	// The square connecting dual scrollbars
	private var scrollbarConnector:UIComponent;

	private var selectionManager:SelectionManager;
	private var editManager:EditManager;
	private var colorManager:ColorManager;
	private var undoManager:UndoManager;
	private var searchManager:SearchManager;
	private var completionManager:CompletionManager;
	private var signatureHelpManager:SignatureHelpManager;
	private var hoverManager:HoverManager;
	private var gotoDefinitionManager:GotoDefinitionManager;
	private var diagnosticsManager:DiagnosticsManager;
	private var codeActionsManager:CodeActionsManager;
	private var editorToolTipManager:EditorToolTipManager;

	public var model:TextEditorModel;

	private var widthUpdateTime:Int = 0;
	private var widthUpdateDelayer:Timer;

	// Style defaults
	private var _backgroundColor:Int = 0xfdfdfd;
	private var _backgroundAlpha:Int = 1;
	private var lineNumberBackgroundColor:Int = 0xf9f9f9;
	private var _selectionColor:Int = 0xd1e3f9;
	private var _selectedAllInstancesOfASearchStringColorAlpha:Int = 0xffb2ff;
	private var _selectedLineColor:Int = 0xedfbfb;
	private var _selectedLineColorAlpha:Float = 1;
	private var _tracingLineColor:Int = 0xc6dbae;
	// Invalidation flags
	private var INVALID_RESIZE(default, never):Int = 1 << 0;
	private var INVALID_SCROLL(default, never):Int = 1 << 1;
	private var INVALID_FULL(default, never):Int = 1 << 2;
	private var INVALID_SELECTION(default, never):Int = 1 << 3;
	private var INVALID_LAYOUT(default, never):Int = 1 << 4;
	private var INVALID_WIDTH(default, never):Int = 1 << 5;
	private var INVALID_TRACESELECTION(default, never):Int = 1 << 6;
	private var invalidFlags:Int = 0;
	public var horizontalScrollBar:HScrollBar;
	public var startPos:Float = 0;
	public var isNeedToBeTracedAfterOpening:Bool = false;

	// Getters/Setters
	public var dataProvider(get, set):String;
	private function get_dataProvider():String {
		return model.lines.join(lineDelim);
	}

	private function set_dataProvider(value:String):String {
		// Detect line ending (for saves)
		// TODO: take first found line encoding
		if (value.indexOf('\r\n') > -1) {
			_lineDelim = '\r\n';
		} else if (value.indexOf('\r') > -1) {
			_lineDelim = '\r';
		} else {
			_lineDelim = '\n';
		}

		// Split lines regardless of line encoding
		var lines:Array<String> = value.split(Std.string(new as3hx.Compat.Regex('\\r?\\n|\\r', '')));
		var count:Int = lines.length;

		// Populate lines into model
		model.lines = cast new Array<TextLineModel>();

		var tagSelectionLineBeginIndex:Int = -1;
		var tagSelectionLineEndIndex:Int = -1;
		for (i in 0...count) {
			if (lines[i].indexOf('_moonshineSelected_') != -1) {
				if (tagSelectionLineBeginIndex == -1) {
					tagSelectionLineBeginIndex = i;
				} else {
					tagSelectionLineEndIndex = i;
				}
				lines[i] = StringTools.replace(lines[i], '_moonshineSelected_', '');
			}

			model.lines[i] = new TextLineModel(lines[i]);
		}

		if (tagSelectionLineBeginIndex != -1 && tagSelectionLineEndIndex == -1) {
			tagSelectionLineEndIndex = tagSelectionLineBeginIndex;
		}
		colorManager.reset();

		// Clear undo history (readOnly doesn't have it)
		if (undoManager != null) {
			undoManager.clear();
		}

		// Reset selection state
		model.setSelection(0, 0, 0, 0);
		// Reset scroll
		model.scrollPosition = 0;
		model.horizontalScrollPosition = 0;
		if (verticalScrollBar != null) {
			verticalScrollBar.scrollPosition = 0;
		}
		if (horizontalScrollBar != null) {
			horizontalScrollBar.scrollPosition = 0;
		}

		// If we got breakpoints set before we loaded text, re-set them.
		if (_breakpoints != null) {
			breakpoints = _breakpoints;
			_breakpoints = null;
		}

		// Set invalidation flags for render
		invalidateLines();

		if (isNeedToBeTracedAfterOpening) {
			this.callLater(function():Void {
						scrollTo(DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE, OpenFileEvent.TRACE_LINE);
						selectTraceLine(DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE);
					});
		}

		if (tagSelectionLineBeginIndex != -1) {
			searchManager.unHighlightTagSelection();
			callLater(function():Void {
						searchManager.highlightTagSelection(tagSelectionLineBeginIndex, tagSelectionLineEndIndex);
					});
		} else if (!isNeedToBeTracedAfterOpening && model.allInstancesOfASearchStringDict != null) {
			searchManager.unHighlightTagSelection();
		}
		return value;
	}

	private var _lineDelim:String = '\n';

	public var lineDelim(get, set):String;
	private function set_lineDelim(value:String):String {
		_lineDelim = value;
		return value;
	}

	private function get_lineDelim():String {
		return _lineDelim;
	}

	private var _lineNumberWidth:Int = 35;

	public var lineNumberWidth(get, set):Int;
	private function get_lineNumberWidth():Int {
		return _lineNumberWidth;
	}

	private function set_lineNumberWidth(value:Int):Int {
		if (value != _lineNumberWidth) {
			var textLineRenderer:TextLineRenderer;

			// Update all item renderers since this value can happen when editing (999->1000, etc)
			for (textLineRenderer in model.itemRenderersFree) {
				textLineRenderer.lineNumberWidth = value;
			}
			for (textLineRenderer in model.itemRenderersInUse) {
				textLineRenderer.lineNumberWidth = value;
			}

			_lineNumberWidth = value;
			invalidateLines();
		}
		return value;
	}

	private var _showScrollBars:Bool = true;

	public var showScrollBars(get, set):Bool;
	private function get_showScrollBars():Bool {
		return _showScrollBars;
	}

	private function set_showScrollBars(value:Bool):Bool {
		_showScrollBars = value;
		if (verticalScrollBar != null) {
			if (value) {
				verticalScrollBar.alpha = horizontalScrollBar.alpha = 0;
			} else {
				verticalScrollBar.alpha = horizontalScrollBar.alpha = 1;
			}
		}
		return value;
	}

	private var _showLineNumbers:Bool = true;

	public var showLineNumbers(get, set):Bool;
	private function get_showLineNumbers():Bool {
		return _showLineNumbers;
	}

	private function set_showLineNumbers(value:Bool):Bool {
		_showLineNumbers = value;
		{
			lineNumberWidth = 0;
		}
		return value;
	}

	private var _hasFocus:Bool = false;

	public var hasFocus(get, set):Bool;
	private function get_hasFocus():Bool {
		return _hasFocus;
	}

	private function set_hasFocus(value:Bool):Bool {
		_hasFocus = value;
		if (model.hasTraceSelection) {
			invalidateTraceSelection(true);
		} else {
			invalidateSelection(true);
		}
		return value;
	}

	public var hasChanged(get, never):Bool;
	private function get_hasChanged():Bool {
		if (undoManager == null) {
			return false;
		}

		return undoManager.hasChanged;
	}

	public function save():Void {
		if (undoManager == null) {
			return;
		}

		// Enables undoManager.hasChanged
		undoManager.save();
	}

	public var signatureHelpActive(get, never):Bool;
	private function get_signatureHelpActive():Bool {
		return signatureHelpManager != null && signatureHelpManager.isActive;
	}

	// Hook in syntax parser & it's styles
	public function setParserAndStyles(parser:ILineParser, styles:Dynamic):Void {
		colorManager.setParser(parser);
		if (AS3.as(styles, Bool)) {
			if (Reflect.field(styles, 'selectedLineColor') == null) {
				Reflect.setField(styles, 'selectedLineColor', _selectedLineColor);
			}
			if (Reflect.field(styles, 'selectionColor') == null) {
				Reflect.setField(styles, 'selectionColor', _selectionColor);
			}
			if (Reflect.field(styles, 'selectedAllInstancesOfASearchStringColorAlpha') == null) {
				Reflect.setField(styles, 'selectedAllInstancesOfASearchStringColorAlpha', _selectedAllInstancesOfASearchStringColorAlpha);
			}
			if (Reflect.field(styles, 'selectedLineColorAlpha') == null) {
				Reflect.setField(styles, 'selectedLineColorAlpha', _selectedLineColorAlpha);
			}

			colorManager.styles = styles;

			var textLineRenderer:TextLineRenderer;
			for (textLineRenderer in model.itemRenderersFree) {
				textLineRenderer.styles = styles;
			}
			for (textLineRenderer in model.itemRenderersInUse) {
				textLineRenderer.styles = styles;
			}

			invalidateLines();
		}
	}

	// Only used to set breakpoints later on.
	private var _breakpoints:Array<Dynamic>;

	public var breakpoints(get, set):Array<Dynamic>;
	private function get_breakpoints():Array<Dynamic> {
		// Get breakpoints from line models
		var bps:Array<Dynamic> = [];
		var linesCount:Int = model.lines.length;

		for (i in 0...linesCount) {
			var line:TextLineModel = model.lines[i];
			if (line.breakPoint) {
				bps.push(i);
			}
		}
		return bps;
	}

	private function set_breakpoints(value:Array<Dynamic>):Array<Dynamic> {
		_breakpoints = value;// if it exists when set dataProvider is called we re-populate & remove it.
		var breakpointsCount:Int = value.length;
		for (i in 0...breakpointsCount) {
			var lineNumber:Int = AS3.int(value[i]);
			if (lineNumber >= model.lines.length) {
				return value;
			}
			var line:TextLineModel = model.lines[lineNumber];
			line.breakPoint = true;
		}
		return value;
	}

	public function setCompletionData(begin:Int, end:Int, s:String):Void {
		editManager.setCompletionData(begin, end, s);
	}

	public function new(readOnly:Bool = false) {
		super();
		model = new TextEditorModel();

		widthUpdateDelayer = new Timer(0, 0);
		widthUpdateDelayer.addEventListener(TimerEvent.TIMER_COMPLETE, calculateTextWidth);

		selectionManager = new SelectionManager(this, model);
		colorManager = new ColorManager(this, model);
		Reflect.setField(colorManager.styles, 'selectedLineColor', _selectedLineColor);
		Reflect.setField(colorManager.styles, 'selectionColor', _selectionColor);
		Reflect.setField(colorManager.styles, 'selectedAllInstancesOfASearchStringColorAlpha', _selectedAllInstancesOfASearchStringColorAlpha);
		Reflect.setField(colorManager.styles, 'selectedLineColorAlpha', _selectedLineColorAlpha);

		editManager = new EditManager(this, model, readOnly);

		if (!readOnly) {
			undoManager = new UndoManager(this, model);
			completionManager = new CompletionManager(this, model);
			signatureHelpManager = new SignatureHelpManager(this, model);
		}

		searchManager = new SearchManager(this, model);
		hoverManager = new HoverManager(this, model);
		gotoDefinitionManager = new GotoDefinitionManager(this, model);
		diagnosticsManager = new DiagnosticsManager(this, model);
		codeActionsManager = new CodeActionsManager(this, model);
		editorToolTipManager = new EditorToolTipManager(this, model);

		addEventListener(ChangeEvent.TEXT_CHANGE, handleChange, false, 1);
		addEventListener(LineEvent.COLOR_CHANGE, handleColorChange);
		addEventListener(LineEvent.WIDTH_CHANGE, handleWidthChange);

		addEventListener(ResizeEvent.RESIZE, handleResize);
	}

	override public function styleChanged(styleProp:String):Void {
		super.styleChanged(styleProp);

		var backgroundColor:Dynamic = getStyle('backgroundColor');
		var backgroundAlpha:Dynamic = getStyle('backgroundAlpha');
		var selectionColor:Dynamic = getStyle('selectionColor');
		var selectedAllInstancesOfASearchStringColorAlpha:Dynamic = getStyle('selectedAllInstancesOfASearchStringColorAlpha');
		var selectedLineColor:Dynamic = getStyle('selectedLineColor');
		var selectedLineColorAlpha:Dynamic = getStyle('selectedLineColorAlpha');
		var tracingLineColor:Dynamic = getStyle('tracingLineColor');

		if (AS3.as(backgroundColor, Bool)) {
			_backgroundColor = AS3.int(backgroundColor);
		}

		if (AS3.as(backgroundAlpha, Bool)) {
			_backgroundAlpha = AS3.int(backgroundAlpha);
		}

		if (AS3.as(backgroundColor, Bool) || AS3.as(backgroundAlpha, Bool)) {
			invalidateFlag(INVALID_RESIZE);
		}

		if (AS3.as(selectionColor, Bool)) {
			_selectionColor = AS3.int(selectionColor);
			Reflect.setField(colorManager.styles, 'selectionColor', _selectionColor);
		}
		if (AS3.as(selectedAllInstancesOfASearchStringColorAlpha, Bool)) {
			_selectedAllInstancesOfASearchStringColorAlpha = AS3.int(selectedAllInstancesOfASearchStringColorAlpha);
			Reflect.setField(colorManager.styles, 'selectedAllInstancesOfASearchStringColorAlpha', _selectedAllInstancesOfASearchStringColorAlpha);
		}
		if (AS3.as(selectedLineColor, Bool)) {
			_selectedLineColor = AS3.int(selectedLineColor);
			Reflect.setField(colorManager.styles, 'selectedLineColor', _selectedLineColor);
		}
		if (AS3.as(selectedLineColorAlpha, Bool)) {
			_selectedLineColorAlpha = selectedLineColorAlpha;
			Reflect.setField(colorManager.styles, 'selectedLineColorAlpha', _selectedLineColorAlpha);
		}

		if (AS3.as(selectionColor, Bool) || AS3.as(selectedLineColor, Bool) || AS3.as(selectedLineColorAlpha, Bool) || AS3.as(selectedAllInstancesOfASearchStringColorAlpha, Bool)) {
			invalidateSelection(true);
		}

		if (AS3.as(tracingLineColor, Bool)) {
			_tracingLineColor = AS3.int(tracingLineColor);
			Reflect.setField(colorManager.styles, 'tracingLineColor', _tracingLineColor);
			invalidateTraceSelection(true);
		}
	}

	public function invalidateLines():Void {
		invalidateFlag(INVALID_FULL);
		invalidateFlag(INVALID_RESIZE);
	}

	public function invalidateSelection(noScroll:Bool = false):Void {
		invalidateFlag(INVALID_SELECTION);

		if (!noScroll) {
			scrollViewIfNeeded();
		}
	}

	public function invalidateTraceSelection(noScroll:Bool = false):Void {
		invalidateFlag(INVALID_TRACESELECTION);

		//if (!noScroll) scrollViewIfNeeded();
	}

	public function scrollViewIfNeeded():Void {
		// Scroll view if needed
		if (model.renderersNeeded > 0) {
			var caretPos:Int = AS3.int(colorManager.calculateWidth(Std.string(model.selectedLine.text.substring(0, model.caretIndex))));
			var scrollPos:Float;

			if (model.selectedLineIndex < verticalScrollBar.scrollPosition || model.renderersNeeded <= 2 && model.selectedLineIndex > verticalScrollBar.scrollPosition) {
				verticalScrollBar.scrollPosition = model.selectedLineIndex;
				invalidateFlag(INVALID_SCROLL);
			} else if (model.renderersNeeded > 2 && model.selectedLineIndex + 2 > verticalScrollBar.scrollPosition + model.renderersNeeded) {
				scrollPos = model.selectedLineIndex - model.renderersNeeded + 2;
				if (scrollPos < 0) {
					scrollPos = 0;
				}

				verticalScrollBar.scrollPosition = scrollPos;
				invalidateFlag(INVALID_SCROLL);
			}
			if (caretPos < model.horizontalScrollPosition) {
				scrollPos = caretPos - HORIZONTAL_LOOKAHEAD;
				if (scrollPos < 0) {
					scrollPos = 0;
				}

				model.horizontalScrollPosition = AS3.int(horizontalScrollBar.scrollPosition = scrollPos);
				invalidateFlag(INVALID_SCROLL);
			} else if (caretPos > model.horizontalScrollPosition + model.viewWidth) {
				model.horizontalScrollPosition = AS3.int(horizontalScrollBar.scrollPosition = caretPos - model.viewWidth + HORIZONTAL_LOOKAHEAD);
				invalidateFlag(INVALID_SCROLL);
			}
		}
	}

	public function getSelection():String {
		if (model.hasMultilineSelection) {
			var startLine:Int = model.selectionStartLineIndex;
			var endLine:Int = model.selectedLineIndex;

			var start:Int = model.selectionStartCharIndex;
			var end:Int = model.caretIndex;

			if (startLine > endLine) {
				startLine = endLine;
				endLine = model.selectionStartLineIndex;

				start = end;
				end = model.selectionStartCharIndex;
			}

			var selText:String = model.lines[startLine].text.substr(start);
			for (i in startLine + 1...endLine) {
				selText += lineDelim + model.lines[i].text;
			}
			selText += lineDelim + model.lines[endLine].text.substr(0, end);

			return selText;

		} else if (model.hasSelection) {
			start = model.selectionStartCharIndex;
			end = model.caretIndex;
			if (model.selectionStartCharIndex > model.caretIndex) {
				start = end;
				end = model.selectionStartCharIndex;
			}

			return model.selectedLine.text.substring(start, end);
		}

		return '';
	}

	private function handleChange(event:ChangeEvent):Void {
		// Any text change requires line invalidation
		invalidateLines();
	}

	private function handleColorChange(event:LineEvent):Void {
		// Line invalidation is required if the changed line is on-screen
		if (event.line >= model.scrollPosition && event.line <= model.scrollPosition + model.renderersNeeded + 1) {
			invalidateLines();
		}
	}

	private function handleWidthChange(event:LineEvent):Void {
		var line:TextLineModel = model.lines[event.line];
		if (line.width > model.textWidth) {
			model.textWidth = line.width;
			invalidateFlag(INVALID_WIDTH);
		} else {
			var timeDiff:Int = Math.round(haxe.Timer.stamp() * 1000) - widthUpdateTime;
			if (timeDiff < WIDTH_UPDATE_DELAY) {
				if (!widthUpdateDelayer.running) {
					widthUpdateDelayer.delay = WIDTH_UPDATE_DELAY - timeDiff;
					widthUpdateDelayer.reset();
					widthUpdateDelayer.start();
				}
			} else {
				calculateTextWidth();
			}
		}
	}

	private function calculateTextWidth(event:TimerEvent = null):Void {
		var linesCount:Int = model.lines.length;
		var max:Float = 0;
		for (i in 0...linesCount) {
			var line:TextLineModel = model.lines[i];
			if (line.width > max) {
				max = line.width;
			}
		}

		if (model.textWidth != max) {
			invalidateFlag(INVALID_WIDTH);
		}

		model.textWidth = max;
		widthUpdateTime = Math.round(haxe.Timer.stamp() * 1000);
	}

	public function selectLine(lineIndex:Int):Void {
		lineIndex = AS3.int(Math.max(0, Math.min(model.lines.length - 1, lineIndex)));
		model.removeSelection();
		model.selectedLineIndex = lineIndex;

		invalidateSelection();
	}

	public function selectRangeAtLine(search:Dynamic, range:Dynamic = null):Void {
		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			if (i + model.scrollPosition == AS3.int(Reflect.field(range, 'startLineIndex'))) {
				var results:Array<Dynamic> = RegExp(search).exec(rdr.model.text);
				if (results != null) {
					var lc:Point = TextUtil.charIdx2LineCharIdx(rdr.model.text, AS3.int(results.index), lineDelim);

					model.selectedLineIndex = AS3.int(Reflect.field(range, 'startLineIndex'));
					rdr.focus = hasFocus;
					rdr.caretPosition = model.caretIndex = AS3.int(lc.y + results[0].length);
					model.selectionStartCharIndex = AS3.int(lc.y);
					rdr.drawSelection(model.selectionStartCharIndex, model.caretIndex);
				}
			} else {
				rdr.focus = false;
				rdr.removeSelection();
			}
		}
	}

	public function selectTraceLine(lineIndex:Int):Void {
		lineIndex = AS3.int(Math.max(0, Math.min(model.lines.length - 1, lineIndex)));
		model.removeTraceSelection();
		model.selectedTraceLineIndex = lineIndex;
		model.hasTraceSelection = true;
		DebugHighlightManager.verifyNewFileOpen(model);

		invalidateTraceSelection();
	}

	public function getPointForIndex(index:Int):Point {
		return getXYForCharAndLine(index, model.selectedLineIndex);
	}

	public function getXYForCharAndLine(character:Int, line:Int):Point {
		var rdrIdx:Int = line - model.scrollPosition;
		var rdr:TextLineRenderer = model.itemRenderersInUse[rdrIdx];

		var charBounds:Rectangle = rdr.getCharBounds(character);
		// .x is manually adjusted, so we can't use .topLeft:Point, instead we create a new Point.
		return rdr.localToGlobal(new Point(charBounds.x, charBounds.y));
	}

	public function getCharAndLineForXY(globalXY:Point, returnNextAfterCenter:Bool = true):Point {
		var localXY:Point = this.globalToLocal(globalXY);
		var itemRenderer:TextLineRenderer = null;
		var itemRenderers:Array<TextLineRenderer> = cast model.itemRenderersInUse;
		var itemRendererCount:Int = itemRenderers.length;
		for (i in 0...itemRendererCount) {
			var currentItemRenderer:TextLineRenderer = itemRenderers[i];
			if (localXY.y >= currentItemRenderer.y &&
				localXY.y < (currentItemRenderer.y + currentItemRenderer.height)) {
				itemRenderer = currentItemRenderer;
				break;
			}
		}
		if (itemRenderer == null) {
			return null;
		}
		var charIndex:Int = itemRenderer.getCharIndexFromPoint(AS3.int(globalXY.x), returnNextAfterCenter);
		if (charIndex == -1) {
			return null;
		}
		var bounds:Rectangle = itemRenderer.getCharBounds(itemRenderer.model.text.length - 1);
		localXY = itemRenderer.globalToLocal(globalXY);
		if (localXY.x > (bounds.x + bounds.width)) {
			//after the final character, so we don't care
			return null;
		}
		return new Point(charIndex, itemRenderer.dataIndex);
	}

	public function scrollTo(lineIndex:Int, eventType:String = null):Void {
		if (!canScroll(lineIndex, eventType)) {
			return;
		}

		// in case (when editor first opens)
		// requisite values not initialized yet
		if (verticalScrollBar.minScrollPosition == 0 && verticalScrollBar.maxScrollPosition == 0) {
			verticalScrollBar.callLater(scrollTo, [lineIndex, eventType]);
			return;
		}

		var verticalOffsetLineIndex:Int = lineIndex;
		if (eventType == OpenFileEvent.TRACE_LINE || eventType == OpenFileEvent.JUMP_TO_SEARCH_LINE) {
			verticalOffsetLineIndex = AS3.int(lineIndex - verticalScrollBar.pageSize / 2);
		}

		var scrollPos:Float = verticalOffsetLineIndex;
		if (scrollPos < verticalScrollBar.minScrollPosition) {
			scrollPos = verticalScrollBar.minScrollPosition;
		}

		if (verticalScrollBar.maxScrollPosition < scrollPos) {
			scrollPos = verticalScrollBar.maxScrollPosition;
		}

		verticalScrollBar.scrollPosition = scrollPos;
		if (AS3.as(horizontalScrollBar.visible, Bool)) {
			scrollPos = x;
			if (x < horizontalScrollBar.minScrollPosition) {
				scrollPos = horizontalScrollBar.minScrollPosition;
			}

			if (horizontalScrollBar.maxScrollPosition < scrollPos) {
				scrollPos = horizontalScrollBar.maxScrollPosition;
			}

			horizontalScrollBar.scrollPosition = scrollPos;
		}
		invalidateFlag(INVALID_SCROLL);
	}

	// Search may be RegExp or String
	public function search(search:Dynamic, backwards:Bool):SearchResult {
		return searchManager.search(search, null, false, backwards);
	}

	// Search all instances and highlight
	// Preferably used in 'search in project' sequence
	public function searchAndShowAll(search:Dynamic):Void {
		searchManager.searchAndShowAll(search);
	}

	// Search may be RegExp or String
	public function searchReplace(search:Dynamic, replace:String = null, all:Bool = false):SearchResult {
		return searchManager.search(search, replace, all);
	}

	public function showCompletionList(items:Array<Dynamic>):Void {
		completionManager.showCompletionList(items);
	}

	public function resolveCompletionItem(item:CompletionItem):Void {
		completionManager.resolveCompletionItem(item);
	}

	public function showSignatureHelp(data:SignatureHelp):Void {
		signatureHelpManager.showSignatureHelp(data);
	}

	public function showHover(contents:Array<String>):Void {
		hoverManager.showHover(contents);
	}

	public function showDefinitionLink(locations:Array<Location>, position:Position):Void {
		gotoDefinitionManager.showDefinitionLink(cast locations, position);
	}

	public function showDiagnostics(diagnostics:Array<Diagnostic>):Void {
		diagnosticsManager.showDiagnostics(cast diagnostics);
	}

	public function showCodeActions(codeActions:Array<CodeAction>):Void {
		codeActionsManager.showCodeActions(cast codeActions);
	}

	public function setTooltip(id:String, text:String):Void {
		editorToolTipManager.setTooltip(id, text);
	}

	private function handleResize(event:ResizeEvent):Void {
		invalidateFlag(INVALID_RESIZE);
		invalidateFlag(INVALID_FULL);
	}

	override private function createChildren():Void {
		super.createChildren();

		addChild(itemContainer);
		updateScrollRect();

		verticalScrollBar = new ScrollBar();
		verticalScrollBar.minScrollPosition = 0;
		verticalScrollBar.lineScrollSize = 1;
		verticalScrollBar.addEventListener(ScrollEvent.SCROLL, handleScroll);
		addChild(verticalScrollBar);

		horizontalScrollBar = new HScrollBar();
		horizontalScrollBar.minScrollPosition = 0;
		horizontalScrollBar.lineScrollSize = 1;
		horizontalScrollBar.addEventListener(ScrollEvent.SCROLL, handleScroll);
		addChild(horizontalScrollBar);

		scrollbarConnector = new UIComponent();
		scrollbarConnector.graphics.beginFill(0x323232, 1);
		scrollbarConnector.graphics.drawRect(0, 0, 15, 15);
		scrollbarConnector.graphics.endFill();
		addChild(scrollbarConnector);

		if (!showScrollBars) {
			verticalScrollBar.alpha = 0;
			horizontalScrollBar.alpha = 0;
		}

		addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
	}

	private function updateScrollRect():Void {
		itemContainer.scrollRect = new Rectangle(0, 0, this.width, this.height);
	}

	private function handleMouseWheel(event:MouseEvent):Void {
		if (completionManager == null || completionManager.isMouseOverList() == false) {
			scrollTo(verticalScrollBar.scrollPosition - event.delta);
		}
	}

	private function handleScroll(event:ScrollEvent):Void {
		invalidateFlag(INVALID_SCROLL);
	}

	private function getItemRenderers(howMany:Int, beginningAtLine:Int):Array<TextLineRenderer> {
		var ret:Array<TextLineRenderer> = new Array<TextLineRenderer>();
		for (i in 0...howMany) {
			var rdr:TextLineRenderer;
			if (model.itemRenderersFree.length > 0) {
				rdr = model.itemRenderersFree.pop();
			} else {
				rdr = new TextLineRenderer();
				rdr.lineNumberWidth = _lineNumberWidth;
				rdr.styles = colorManager.styles;
				rdr.cacheAsBitmap = true;

				//For masking Right panel
				/*var masker:Sprite = new Sprite();
				masker.graphics.beginFill(0XFFFFFF);
				masker.graphics.drawRect(0 , 0 , this.parentApplication.width+1000 , this.parent.height+1000);
				masker.graphics.endFill();
				masker.cacheAsBitmap = true;
				rdr.mask = masker;
				itemContainer.addChild(masker);*/
				itemContainer.addChild(rdr);
			}

			var beginningAtLinePlusIndex:Int = beginningAtLine + i;
			rdr.model = model.lines[beginningAtLinePlusIndex];
			rdr.dataIndex = beginningAtLinePlusIndex;
			ret.push(rdr);
		}

		return ret;
	}

	private function freeItemRenderers(startIndex:Int, howMany:Int):Void {
		var toRemove:Array<TextLineRenderer> = cast model.itemRenderersInUse.splice(startIndex, howMany);
		for (rdr in toRemove) {
			rdr.x = -2000;
			rdr.y = -2000;
		}

		model.itemRenderersFree = model.itemRenderersFree.concat(toRemove);
	}

	private function freeRenderersAtTop(howMany:Int):Void {
		freeItemRenderers(0, howMany);
	}

	private function freeRenderersAtBottom(howMany:Int):Void {
		freeItemRenderers(model.itemRenderersInUse.length - howMany, howMany);
	}

	private function clearAllRenderers():Void {
		freeItemRenderers(0, model.itemRenderersInUse.length);
	}

	private function updateDataProvider():Void {
		clearAllRenderers();
		var needed:Int = model.lines.length - model.scrollPosition;
		if (model.renderersNeeded < needed) {
			needed = model.renderersNeeded;
		}

		model.itemRenderersInUse = getItemRenderers(needed, model.scrollPosition);

		invalidateFlag(INVALID_LAYOUT);
		invalidateSelection(true);
		if (model.hasTraceSelection) {
			invalidateTraceSelection();
		}
	}

	private function updateSize():Void {
		// TODO: Fix this to better consider the dependency of scrollbars
		// as showing/hiding one scrollbar can change the need for the other
		model.viewWidth = width - lineNumberWidth;
		model.viewHeight = height - ((AS3.as(horizontalScrollBar.visible, Bool)) ? 15 : 0);
		model.renderersNeeded = Math.ceil(model.viewHeight / TextLineRenderer.lineHeight);

		if (model.renderersNeeded < model.itemRenderersInUse.length) {
			// Remove no-longer needed renderers
			var removed:Array<TextLineRenderer> = cast model.itemRenderersInUse.splice(model.renderersNeeded, model.itemRenderersInUse.length - model.renderersNeeded);

			for (rdr in removed) {
				rdr.focus = false;
				rdr.parent.removeChild(rdr);
			}

			as3hx.Compat.setArrayLength(removed, 0);
			removed = null;
		}

		updateVerticalScrollbar();

		if (AS3.as(verticalScrollBar.visible, Bool)) {
			model.viewWidth -= 15;
		}
		updateHorizontalScrollbar();

		updateScrollbarVisibility();

		itemContainer.graphics.clear();
		itemContainer.graphics.beginFill(_backgroundColor, _backgroundAlpha);
		itemContainer.graphics.drawRect(0, 0, width, height);
		itemContainer.graphics.endFill();

		if (showLineNumbers) {
			// Calculate line-number gutter width according to line count
			lineNumberWidth = AS3.int(TextLineRenderer.charWidth * TextUtil.digitCount(model.lines.length) + 8 + 10);

			itemContainer.graphics.beginFill(lineNumberBackgroundColor);
			itemContainer.graphics.drawRect(0, 0, _lineNumberWidth, height);
			itemContainer.graphics.endFill();
		}
	}

	private function updateVerticalScrollbar():Void {
		var maxScroll:Int = model.lines.length - model.renderersNeeded + 1;
		if (maxScroll < 0) {
			maxScroll = 0;
		}

		verticalScrollBar.maxScrollPosition = maxScroll;
		verticalScrollBar.pageSize = model.renderersNeeded;
		verticalScrollBar.visible = maxScroll > 0;

		if (verticalScrollBar.scrollPosition > maxScroll) {
			verticalScrollBar.scrollPosition = maxScroll;
			invalidateFlag(INVALID_SCROLL);
		}
	}

	private function updateHorizontalScrollbar():Void {
		var maxScroll:Int = AS3.int(model.textWidth - model.viewWidth + HORIZONTAL_LOOKAHEAD);
		if (maxScroll < 0) {
			maxScroll = 0;
		}

		horizontalScrollBar.maxScrollPosition = maxScroll;
		horizontalScrollBar.pageSize = model.viewWidth;
		horizontalScrollBar.visible = maxScroll > 0;

		if (horizontalScrollBar.scrollPosition > maxScroll) {
			horizontalScrollBar.scrollPosition = maxScroll;
			invalidateFlag(INVALID_SCROLL);
		}
	}

	private function updateScrollbarVisibility():Void {
		// Scrollbar is centered on it's x (& 15px wide)
		verticalScrollBar.x = width - 7;
		verticalScrollBar.height = height;

		horizontalScrollBar.y = height - 7;
		horizontalScrollBar.width = width;

		if (AS3.as(horizontalScrollBar.visible, Bool) && AS3.as(verticalScrollBar.visible, Bool)) {
			verticalScrollBar.height -= 15;
			horizontalScrollBar.width -= 15;
			scrollbarConnector.x = width - 15;
			scrollbarConnector.y = height - 15;
			scrollbarConnector.visible = true;
		} else {
			scrollbarConnector.visible = false;
		}
	}

	private function updateHorizontalScroll():Void {
		if (model.horizontalScrollPosition != horizontalScrollBar.scrollPosition) {
			model.horizontalScrollPosition = AS3.int(horizontalScrollBar.scrollPosition);

			invalidateFlag(INVALID_LAYOUT);
			invalidateSelection(true);
		}
	}

	private function updateVerticalScroll():Void {
		var scrollDelta:Int = verticalScrollBar.scrollPosition - model.scrollPosition;

		if (scrollDelta == 0) {
			return;
		}

		if (Math.abs(scrollDelta) >= model.renderersNeeded) {
			model.scrollPosition = AS3.int(verticalScrollBar.scrollPosition);

			invalidateFlag(INVALID_FULL);
			return;
		}

		var bottomLine:Int;
		var linesRemaining:Int;
		var affectedLines:Int;
		var newRenderers:Array<TextLineRenderer>;

		if (scrollDelta > 0) {
			// Scroll down
			{
				bottomLine = AS3.int(model.scrollPosition + model.renderersNeeded);
				linesRemaining = AS3.int(model.lines.length - bottomLine);
				affectedLines = scrollDelta;
				if (linesRemaining < scrollDelta) {
					affectedLines = linesRemaining;
				}

				freeRenderersAtTop(scrollDelta);
				newRenderers = cast getItemRenderers(affectedLines, bottomLine);
				model.itemRenderersInUse = model.itemRenderersInUse.concat(newRenderers);
			}
		}// Scroll up
		else {
			linesRemaining = model.scrollPosition;
			affectedLines = -scrollDelta;
			if (linesRemaining < affectedLines) {
				affectedLines = linesRemaining;
			}

			freeRenderersAtBottom(affectedLines);
			newRenderers = cast getItemRenderers(affectedLines, model.scrollPosition - affectedLines);
			model.itemRenderersInUse = newRenderers.concat(model.itemRenderersInUse);

			// Restore any unused lines to the bottom
			bottomLine = AS3.int(model.scrollPosition - affectedLines + model.itemRenderersInUse.length);
			linesRemaining = AS3.int(model.lines.length - bottomLine);

			affectedLines = AS3.int(model.renderersNeeded - model.itemRenderersInUse.length);
			if (linesRemaining < affectedLines) {
				affectedLines = linesRemaining;
			}

			if (affectedLines > 0) {
				newRenderers = cast getItemRenderers(affectedLines, bottomLine);
				model.itemRenderersInUse = model.itemRenderersInUse.concat(newRenderers);
			}
		}

		model.scrollPosition = AS3.int(verticalScrollBar.scrollPosition);

		invalidateFlag(INVALID_LAYOUT);
		invalidateSelection(true);
	}

	private function updateLayout():Void {
		var yStart:Int = 0;
		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			rdr.y = yStart;
			rdr.x = 0;
			rdr.horizontalOffset = -model.horizontalScrollPosition;
			yStart += TextLineRenderer.lineHeight;
		}

		dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT));
	}

	public function updateSelection():Void {
		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			if (i + model.scrollPosition == model.selectedLineIndex) {
				rdr.focus = hasFocus;
				rdr.caretPosition = model.caretIndex;
				rdr.drawSelection(model.selectionStartCharIndex, model.caretIndex);
			} else {
				rdr.focus = false;
				rdr.removeSelection();
			}
		}
	}

	public function updateAllInstancesOfASearchStringSelection():Void {
		if (model.allInstancesOfASearchStringDict == null) {
			return;
		}

		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			if (model.allInstancesOfASearchStringDict.get(i + model.scrollPosition) != null) {
				rdr.drawAllInstanceOfASearchStringSelection(model.allInstancesOfASearchStringDict.get(i + model.scrollPosition));
			} else {
				rdr.removeAllInstancesSelection();
			}
		}
	}

	public function updateTraceSelection():Void {
		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			if (i + model.scrollPosition == model.selectedTraceLineIndex) {
				if (DebugHighlightManager.LAST_DEBUG_LINE_OBJECT != null) {
					DebugHighlightManager.LAST_DEBUG_LINE_OBJECT.debuggerLineSelection = false;
				}
				DebugHighlightManager.LAST_DEBUG_LINE_OBJECT = rdr.model;
				DebugHighlightManager.LAST_DEBUG_LINE_RENDERER = rdr;

				//rdr.focus = hasFocus;
				rdr.caretTracePosition = model.caretTraceIndex;
				rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = true;
				//rdr.drawTraceSelection(model.selectionStartTraceCharIndex, model.caretTraceIndex);
			} else {
				//rdr.focus = false;
				rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = false;
				//rdr.removeTraceSelection();
			}
		}
	}

	public function removeTraceSelection():Void {
		var rdr:TextLineRenderer;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;

		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = false;
			//rdr.focus = false;
			rdr.removeTraceSelection();
		}
	}

	private function updateMultilineSelection():Void {
		var rdr:TextLineRenderer;

		// If we are horiz-scrolling the selection might be wider than window width.
		// Makes sure selection is drawn all the way to the right edge when scrolling.
		var lineWidth:Int = width + model.horizontalScrollPosition;
		var itemRenderersInUseCount:Int = model.itemRenderersInUse.length;
		var scrollPosition:Int = 0;
		for (i in 0...itemRenderersInUseCount) {
			rdr = model.itemRenderersInUse[i];
			scrollPosition = AS3.int(i + model.scrollPosition);

			if (scrollPosition == model.selectionStartLineIndex) {
				// Beginning of selection (may be below or above current point)
				if (model.selectionStartLineIndex > model.selectedLineIndex) {
					rdr.drawSelection(0, model.selectionStartCharIndex);
				} else {
					rdr.drawFullLineSelection(lineWidth, model.selectionStartCharIndex);
				}
				rdr.focus = false;
			} else if (scrollPosition == model.selectedLineIndex) {
				// Selected line
				if (model.selectedLineIndex > model.selectionStartLineIndex) {
					rdr.drawSelection(0, model.caretIndex);
				} else {
					rdr.drawFullLineSelection(lineWidth, model.caretIndex);
				}
				rdr.caretPosition = model.caretIndex;
				rdr.focus = hasFocus;
			} else if (model.selectionStartLineIndex < scrollPosition && model.selectedLineIndex > scrollPosition) {
				// Start of selection is above current line
				rdr.drawFullLineSelection(lineWidth);
				rdr.focus = false;
			} else if (model.selectionStartLineIndex > scrollPosition && model.selectedLineIndex < scrollPosition) {
				// Start of selection is below current line
				rdr.drawFullLineSelection(lineWidth);
				rdr.focus = false;
			} else {
				// No selection
				rdr.focus = false;
				rdr.removeSelection();
			}
		}
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		// Keep processing until no flags are on
		while (invalidFlags != 0) {
			// Get current invalid flags
			var curInvalidFlags:Int = invalidFlags;
			// Reset all invalidation flags
			invalidFlags = 0;
			if (checkFlag(INVALID_RESIZE, curInvalidFlags)) {
				updateSize();
				updateScrollRect();
			}
			if (checkFlag(INVALID_WIDTH, curInvalidFlags)) {
				var old:Bool = AS3.as(horizontalScrollBar.visible, Bool);
				updateHorizontalScrollbar();

				if (old != horizontalScrollBar.visible) {
					invalidateFlag(INVALID_RESIZE);
				} else {
					updateScrollRect();
				}
			}
			if (checkFlag(INVALID_SCROLL, curInvalidFlags)) {
				updateVerticalScroll();
				updateHorizontalScroll();
			}
			if (checkFlag(INVALID_FULL, curInvalidFlags)) {
				updateDataProvider();
			}
			if (checkFlag(INVALID_SELECTION, curInvalidFlags)) {
				if (model.hasMultilineSelection) {
					updateMultilineSelection();
				} else {
					updateSelection();
					updateAllInstancesOfASearchStringSelection();
				}
			}
			if (checkFlag(INVALID_TRACESELECTION, curInvalidFlags)) {
				/*if(model.hasTraceSelection)
				{*/
				updateTraceSelection();
				//}
			}
			if (checkFlag(INVALID_LAYOUT, curInvalidFlags)) {
				updateLayout();
			}
		}
	}

	private function invalidateFlag(flag:Int):Void {
		if (invalidFlags == 0) {
			// Invalidate display list on the first flag invalidated, to get updateDisplayList to execute
			invalidateDisplayList();
		}
		invalidFlags = invalidFlags | flag;
	}

	private function canScroll(lineIndex:Int, eventType:String):Bool {
		if (eventType == null) {
			return true;
		}

		var hasTracedItem:Bool = true;
		if (eventType == OpenFileEvent.TRACE_LINE) {
			hasTracedItem = isDebuggerLineVisible(lineIndex);
		}

		return hasTracedItem;
	}

	private function isDebuggerLineVisible(lineIndex:Int):Bool {
		return AS3.as(model.itemRenderersInUse.every(
						function(item:TextLineRenderer, index:Int, vector:Array<TextLineRenderer>):Bool {
							return item.dataIndex != lineIndex || !item.model.traceLine;
						}
			), Bool);
	}

	private static function checkFlag(flag:Int, flags:Int):Bool {
		return (flags & flag) > 0;
	}

}