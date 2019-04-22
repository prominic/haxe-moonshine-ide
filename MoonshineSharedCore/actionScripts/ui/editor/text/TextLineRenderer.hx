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

import flash.errors.Error;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.engine.ContentElement;
import flash.text.engine.ElementFormat;
import flash.text.engine.GroupElement;
import flash.text.engine.TabAlignment;
import flash.text.engine.TabStop;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.utils.Timer;
import actionScripts.valueObjects.Diagnostic;
import actionScripts.valueObjects.Settings;
import no.doomsday.utilities.math.MathUtils;
import org.apache.flex.collections.VectorCollection;
import mx.managers.PopUpManager;

class TextLineRenderer extends Sprite {

	// TODO: These need to derive from the font metrics
	public static var lineHeight:Int = 16;
	public static var charWidth:Float = 7.82666015625;

	private static var numTabstops:Int = 100;
	private static var tabStops:Array<TabStop>;

	// Do static init once & once only.
	private static function classInit():Void {
		tabStops = cast new Array<TabStop>();
		var charWidthWithTabWidth:Float = charWidth * Settings.font.tabWidth;
		for (i in 0...numTabstops) {
			tabStops[i] = new TabStop(TabAlignment.START, Math.round((i + 1) * charWidthWithTabWidth));
		}
	}

	public var styles:Dynamic;
	public var lineNumberWidth:Int = 0;

	private var textBlock:TextBlock;
	private var textLine:TextLine;

	private var lineNumberTextBlock:TextBlock;
	private var lineNumberTextElement:TextElement;
	private var lineNumberText:TextLine;
	private var lineNumberBackground:Sprite;

	private var marker:Sprite;
	private var markerBlinkTimer:Timer;
	private var lastMarkerPosition:Float;
	private var diagnosticsShape:Shape;
	private var codeActionView:CodeActionView;

	private var allInstancesSelection:Sprite;
	private var selection:Sprite;
	private var traceSelection:Sprite;
	private var lineSelection:Sprite;

	private var _dataIndex:Int = 0;

	public var dataIndex(get, set):Int;
	private function get_dataIndex():Int {
		return _dataIndex;
	}

	private function set_dataIndex(v:Int):Int {
		_dataIndex = v;

		drawLineNumber();
		return v;
	}

	private var _model:TextLineModel;

	public var model(get, set):TextLineModel;
	private function get_model():TextLineModel {
		return _model;
	}

	private function set_model(value:TextLineModel):TextLineModel {
		focus = false;

		_model = value;
		drawText();
		traceFocus = _model.debuggerLineSelection;
		return value;
	}

	private var _horizontalOffset:Int = 0;

	public var horizontalOffset(get, set):Int;
	private function get_horizontalOffset():Int {
		return _horizontalOffset;
	}

	private function set_horizontalOffset(value:Int):Int {
		_horizontalOffset = value;
		if (textLine != null) {
			textLine.x = lineNumberWidth + _horizontalOffset;
		}
		if (diagnosticsShape != null) {
			diagnosticsShape.x = lineNumberWidth + _horizontalOffset;
		}
		allInstancesSelection.x = selection.x = lineNumberWidth + _horizontalOffset;
		drawMarkerAtPosition(AS3.int(lastMarkerPosition), 0);
		return value;
	}

	private var _caretPosition:Int = 0;

	public var caretPosition(never, set):Int;
	private function set_caretPosition(value:Int):Int {
		_caretPosition = value;
		drawCaret(value);
		return value;
	}

	private var _caretTracePosition:Int = 0;

	public var caretTracePosition(never, set):Int;
	private function set_caretTracePosition(value:Int):Int {
		_caretTracePosition = value;
		drawCaret(value);
		return value;
	}

	private var _showTraceLines:Bool = false;

	public var showTraceLines(never, set):Bool;
	private function set_showTraceLines(value:Bool):Bool {
		_showTraceLines = value;
		_model.debuggerLineSelection = value;
		return value;
	}

	private var _focus:Bool = false;

	public var focus(get, set):Bool;
	private function get_focus():Bool {
		return _focus;
	}

	private function set_focus(value:Bool):Bool {
		_focus = value;
		var g:Graphics = lineSelection.graphics;
		g.clear();
		if (value) {
			markerBlinkTimer.start();
			marker.visible = true;
			g.beginFill(AS3.int(Reflect.field(styles, 'selectedLineColor')), Reflect.field(styles, 'selectedLineColorAlpha'));
			g.drawRect(lineNumberWidth, 0, 2000, lineHeight);
			g.endFill();
		} else {
			g.clear();
			markerBlinkTimer.reset();
			marker.visible = false;
		}
		return value;
	}

	private var _traceFocus:Bool = false;

	public var traceFocus(never, set):Bool;
	private function set_traceFocus(value:Bool):Bool {
		_traceFocus = value;
		var g:Graphics = traceSelection.graphics;
		g.clear();
		if (value) {
			g.beginFill(AS3.int(Reflect.field(styles, 'tracingLineColor')), Reflect.field(styles, 'selectedLineColorAlpha'));
			g.drawRect(lineNumberWidth, 0, 2000, lineHeight);
			g.endFill();
		}
		return value;
	}

	public function new() {
		super();
		init();
	}

	private function init():Void {
		textBlock = new TextBlock();
		textBlock.tabStops = tabStops;

		lineNumberTextBlock = new TextBlock();
		lineNumberTextElement = new TextElement();
		lineNumberTextBlock.content = lineNumberTextElement;

		lineSelection = Type.createInstance(Sprite, []);
		addChild(lineSelection);

		allInstancesSelection = Type.createInstance(Sprite, []);
		addChild(allInstancesSelection);

		selection = Type.createInstance(Sprite, []);
		addChild(selection);

		traceSelection = Type.createInstance(Sprite, []);
		addChild(traceSelection);

		marker = Type.createInstance(Sprite, []);
		marker.graphics.beginFill(0x0, 0.5);
		marker.graphics.drawRect(0, 0, 3, lineHeight);
		marker.graphics.endFill();
		addChild(marker);

		markerBlinkTimer = new Timer(600);
		markerBlinkTimer.addEventListener(TimerEvent.TIMER, markerBlink);

		diagnosticsShape = new Shape();
		addChild(diagnosticsShape);

		lineNumberBackground = Type.createInstance(Sprite, []);
		addChild(lineNumberBackground);
	}

	public function drawCaret(beforeCharAtIndex:Int):Void {
		var modelTextLength:Int = model.text.length;
		var bounds:Rectangle;
		var markerPos:Float = 0;
		var atom:Int;

		if (beforeCharAtIndex == 0 || textLine == null) {
			// Draw on empty line
		} else if (beforeCharAtIndex >= modelTextLength) {
			atom = (modelTextLength > textLine.atomCount) ?
					textLine.atomCount - 1 :
					modelTextLength - 1;

			bounds = textLine.getAtomBounds(atom);
			markerPos = bounds.x + bounds.width;
		} else {
			atom = (beforeCharAtIndex >= textLine.atomCount) ?
					textLine.atomCount - 1 :
					beforeCharAtIndex;

			bounds = textLine.getAtomBounds(atom);
			markerPos = bounds.x;
		}

		lastMarkerPosition = markerPos;
		drawMarkerAtPosition(AS3.int(markerPos), 0);
	}

	public function drawSelection(start:Int, end:Int):Void {
		if (start == end || start < 0) {
			removeSelection();
			return;
		}
		if (start > end) {
			var tmp:Int = start;
			start = end;
			end = tmp;
		}

		var selWidth:Int = 0;
		var selStart:Int = 0;
		if (textLine != null) {
			if (start > textLine.atomCount) {
				start = AS3.int(textLine.atomCount - 1);
			}

			if (end > textLine.atomCount) {
				end = textLine.atomCount;
			}

			var endBounds:Rectangle = textLine.getAtomBounds(end - 1);
			selStart = Math.floor(textLine.getAtomBounds(start).x);
			selWidth = AS3.int(MathUtils.ceil(endBounds.x + endBounds.width) - selStart);
		}

		drawSelectionRect(selStart, selWidth);
	}

	public function drawAllInstanceOfASearchStringSelection(drawAsAllInstancesOfASearchString:Array<Dynamic>):Void {
		function getSelectionRange(start:Int, end:Int):Void {
			if (start == end || start < 0) {
				removeAllInstancesSelection();
				return;
			}
			if (start > end) {
				var tmp:Int = start;
				start = end;
				end = tmp;
			}

			var selStart:Int = Math.floor(textLine.getAtomBounds(start).x);
			var endBounds:Rectangle = textLine.getAtomBounds(end - 1);
			var selWidth:Int = MathUtils.ceil(endBounds.x + endBounds.width) - selStart;

			g.drawRect(selStart, 0, selWidth, lineHeight);
		};
		var g:Graphics = allInstancesSelection.graphics;
		g.clear();
		g.beginFill(AS3.int(Reflect.field(styles, 'selectedAllInstancesOfASearchStringColorAlpha')), Reflect.field(styles, 'selectedLineColorAlpha'));

		if (drawAsAllInstancesOfASearchString.length == 1) {
			try {
				getSelectionRange(AS3.int(Reflect.field(drawAsAllInstancesOfASearchString[0], 'startCharIndex')), AS3.int(Reflect.field(drawAsAllInstancesOfASearchString[0], 'endCharIndex')));
			} catch (e:Error) {}
		} else {
			for (j in 0...drawAsAllInstancesOfASearchString.length) {
				try {
					getSelectionRange(AS3.int(Reflect.field(drawAsAllInstancesOfASearchString[j], 'startCharIndex')), AS3.int(Reflect.field(drawAsAllInstancesOfASearchString[j], 'endCharIndex')));
				} catch (e:Error) {}
			}
		} /*
		 * @local
		 */

		g.endFill();
	}

	public function drawTraceSelection(start:Int, end:Int):Void {
		if (start > end) {
			var tmp:Int = start;
			start = end;
			end = tmp;
			var selStart:Int = Math.floor(textLine.getAtomBounds(start).x);
			var endBounds:Rectangle = textLine.getAtomBounds(end - 1);
			var selWidth:Int = MathUtils.ceil(endBounds.x + endBounds.width) - selStart;
			drawTraceSelectionRect(selStart, selWidth);
		}

	}

	public function drawFullLineSelection(lineWidth:Int, startAtChar:Int = 0):Void {
		var start_x:Int = 0;
		if (startAtChar > 0) {
			start_x = AS3.int(textLine.getAtomBounds(AS3.int(Math.min(startAtChar, model.text.length) - 1)).right);
		}

		drawSelectionRect(start_x, lineWidth - start_x);
	}

	public function removeSelection():Void {
		selection.graphics.clear();
	}

	public function removeAllInstancesSelection():Void {
		allInstancesSelection.graphics.clear();
	}

	public function removeTraceSelection():Void {
		traceSelection.graphics.clear();
	}

	public function getCharIndexFromPoint(globalX:Int, returnNextAfterCenter:Bool = true):Int {
		var localPoint:Point = this.globalToLocal(new Point(globalX, 0));
		var localPointX:Float = localPoint.x;
		var modelTextLength:Int = model.text.length;

		if (modelTextLength == 0) {
			return (localPointX >= lineNumberWidth) ? 0 : -1;
		} else if (textLine != null && localPointX >= textLine.x + textLine.width) {
			// After text
			{
				return modelTextLength;
			}
		} else {
			// Get a line through the middle of the text field for y
			var mid:Point = this.localToGlobal(new Point(0, lineHeight / 2));
			var atomIndexAtPoint:Int = (textLine != null) ? textLine.getAtomIndexAtPoint(globalX, mid.y) : -1;

			if (atomIndexAtPoint > -1 && returnNextAfterCenter) {
				var bounds:Rectangle = textLine.getAtomBounds(atomIndexAtPoint);
				var center:Float = lineNumberWidth + bounds.x + bounds.width / 2;
				// If point falls after the center of the character, move to next one
				if (localPointX >= center) {
					atomIndexAtPoint++;
				}
			}

			return atomIndexAtPoint;
		}
	}

	// Will give you the char bounds, or if charIdx is out-of-bounds, the lines xy, or the last chars right-side xy
	// Uses the renderers height instead of the chars height
	public function getCharBounds(charIndex:Int):Rectangle {
		var addCharWidth:Bool;
		var modelTextLength:Int = model.text.length;

		// Sanity checks
		if (charIndex >= modelTextLength) {
			charIndex = AS3.int(modelTextLength - 1);
			addCharWidth = true;
		}
		if (charIndex < 0) {
			return new Rectangle(lineNumberWidth, 0, 0, lineHeight);
		}

		if (charIndex >= textLine.atomCount) {
			charIndex = AS3.int(textLine.atomCount - 1);
		}
		var bounds:Rectangle = textLine.getAtomBounds(charIndex);
		bounds.x += lineNumberWidth;

		if (addCharWidth) {
			bounds.x += bounds.width;
			bounds.width = 0;
		}

		// The renders size is what we want to use
		bounds.y = 0;
		bounds.height = lineHeight;

		return bounds;
	}

	public function drawText():Void {
		var text:String = model.text;
		var meta:Array<Int> = model.meta;
		var groupElement:GroupElement = new GroupElement();
		var contentElements:Array<ContentElement> = new Array<ContentElement>();

		if (meta != null) {
			var style:Int;
			var start:Int;
			var end:Int;
			var metaCount:Int = meta.length;
			var textLength:Int = text.length;

			var i:Int = 0;

			while (i < metaCount) {
				start = meta[i];
				var plusTwoLine:Int = i + 2;
				end = ((plusTwoLine < metaCount)) ? meta[plusTwoLine] : textLength;
				style = meta[i + 1];
				var textElement:TextElement = new TextElement(text.substring(start, end), Reflect.field(styles, Std.string(style)));
				contentElements.push(textElement);
				i += 2;
			}
		} else {
			contentElements.push(new TextElement(text, Reflect.field(styles, Std.string(0))));
		}

		groupElement.setElements(cast contentElements);

		var contentElementsCount:Int = contentElements.length;
		if (contentElementsCount >= 2 && contentElements[contentElementsCount - 2].elementFormat.color == 0xca2323) {
			var textToElement:String = contentElements[contentElementsCount - 2].text;
			var textToElementLength:Int = textToElement.length;
			var startChar:String = Std.string(textToElement.charAt(0));
			model.isQuoteTextOpen = textToElementLength == 1 || textToElement.charAt(textToElementLength - 1) != startChar;
			model.lastQuoteText = startChar;
		} else {
			model.isQuoteTextOpen = false;
			model.lastQuoteText = null;
		}

		textBlock.content = groupElement;

		var newTextLine:TextLine = null;
		if (textLine != null) {
			//try to reuse the existing TextLine, if it exists already
			newTextLine = textBlock.recreateTextLine(textLine);
		} else {
			newTextLine = textBlock.createTextLine();
			if (newTextLine != null) {
				textLine = newTextLine;
				textLine.mouseEnabled = false;
				textLine.cacheAsBitmap = true;
				addChildAt(textLine, this.getChildIndex(selection) + 2);
			}

		}
		if (textLine != null && newTextLine == null) {
			removeChild(textLine);
			textLine = null;
		}

		if (textLine != null) {
			textLine.x = lineNumberWidth + horizontalOffset;
			textLine.y = 12;
		}
		drawDiagnostics();
		drawCodeActions();
	}

	private function drawDiagnostics():Void {
		diagnosticsShape.graphics.clear();
		if (textLine == null) {
			return;
		}
		var stepLength:Int = 2;
		diagnosticsShape.x = textLine.x;
		diagnosticsShape.y = textLine.y;
		var diagnostics:Array<Diagnostic> = cast model.diagnostics;
		var diagnosticsCount:Int = diagnostics.length;
		if (diagnostics != null && diagnosticsCount > 0) {
			for (i in 0...diagnosticsCount) {
				var diagnostic:Diagnostic = diagnostics[i];
				if (diagnostic.severity == Diagnostic.SEVERITY_HINT) {
					//skip hints because they are not meant to be displayed
					//to the user like regular problems. they're used
					//internally by the language server or the editor for
					//other types of things, such as code actions.
					continue;
				}
				var startChar:Int = diagnostic.range.start.character;
				var endChar:Int = diagnostic.range.end.character;
				var maxChar:Int = textLine.rawTextLength - 1;
				if (startChar > maxChar) {
					startChar = maxChar;
				}
				if (endChar > maxChar) {
					endChar = maxChar;
				}
				var startBounds:Rectangle = textLine.getAtomBounds(startChar);
				var endBounds:Rectangle = textLine.getAtomBounds(endChar);
				var lineColor:Int = 0xfa0707;//error
				switch (diagnostic.severity) {
					case Diagnostic.SEVERITY_WARNING:
						lineColor = 0x078a07;
					case Diagnostic.SEVERITY_HINT, Diagnostic.SEVERITY_INFORMATION:
						lineColor = 0x0707fa;
				}
				diagnosticsShape.graphics.lineStyle(1, lineColor, .65);
				diagnosticsShape.graphics.moveTo(startBounds.x, 0);
				var upDirection:Bool = false;
				var offset:Int = 0;
				var startBoundsOffset:Int = 0;
				var lineLength:Float = endBounds.x + endBounds.width - startBounds.x;
				while (offset <= AS3.int(lineLength)) {
					offset = AS3.int(offset + stepLength);
					startBoundsOffset = AS3.int(startBounds.x + offset);

					if (upDirection) {
						diagnosticsShape.graphics.lineTo(startBoundsOffset, 0);
					} else {
						diagnosticsShape.graphics.lineTo(startBoundsOffset, stepLength);
					}
					upDirection = !upDirection;
				}
			}
		}
	}

	override private function set_x(value:Float):Float {
		super.x = value;
		drawCodeActions();
		return value;
	}

	override private function set_y(value:Float):Float {
		super.y = value;
		drawCodeActions();
		return value;
	}

	private function drawCodeActions():Void {
		if (model.codeActions != null && model.codeActions.length > 0) {
			if (codeActionView == null) {
				codeActionView = new CodeActionView();
				this.addChild(codeActionView);
				PopUpManager.addPopUp(codeActionView, this);
			}
			codeActionView.codeActions = new VectorCollection(model.codeActions);
			codeActionView.validateNow();

			if (textLine != null) {
				var bounds:Rectangle = textLine.getAtomBounds(0);
				var point:Point = new Point(textLine.x + bounds.x, bounds.height - codeActionView.height);

				var firstNonWhitespace:Dynamic = new as3hx.Compat.Regex('\\S', '').exec(model.text);
				if (AS3.as(firstNonWhitespace, Bool) && Reflect.field(firstNonWhitespace, 'index') < textLine.atomCount) {
					var firstNonWhitespaceBounds:Rectangle = textLine.getAtomBounds(AS3.int(Reflect.field(firstNonWhitespace, 'index')));
					if ((firstNonWhitespaceBounds.x - bounds.x) < codeActionView.width) {
						//don't cover any text that appears at the beginning of
						//the line. if it overlaps, move to previous line.
						point.y -= textLine.height;
					}
				}

				point = localToGlobal(point);
				codeActionView.x = point.x;
				codeActionView.y = point.y;
			}
		} else if (codeActionView != null) {
			PopUpManager.removePopUp(codeActionView);
			codeActionView = null;
		}
	}

	private function drawLineNumber():Void {
		if (lineNumberWidth > 0) {
			lineNumberBackground.graphics.clear();

			if (model.breakPoint) {
				lineNumberBackground.graphics.beginFill(AS3.int(Reflect.field(styles, 'breakPointBackground')));
				lineNumberBackground.graphics.drawRect(0, 0, lineNumberWidth, lineHeight);
				lineNumberBackground.graphics.endFill();
			} else {
				lineNumberBackground.graphics.beginFill(0xf9f9f9);
				lineNumberBackground.graphics.drawRect(0, 0, lineNumberWidth, lineHeight);
				lineNumberBackground.graphics.endFill();
			}

			var style:ElementFormat = ((model.breakPoint)) ? Reflect.field(styles, 'breakPointLineNumber') : Reflect.field(styles, 'lineNumber');
			//style = (model.traceLine) ? styles['tracingLineColor'] : styles['lineNumber'];
			lineNumberTextElement.elementFormat = style;
			lineNumberTextElement.text = Std.string(Std.string(_dataIndex + 1));
			var newLineNumberText:TextLine = null;
			if (lineNumberText != null) {
				//try to reuse the existing TextLine, if it exists already
				newLineNumberText = lineNumberTextBlock.recreateTextLine(lineNumberText, null, lineNumberWidth);
			} else {
				newLineNumberText = lineNumberTextBlock.createTextLine(null, lineNumberWidth);
				if (newLineNumberText != null) {
					lineNumberText = newLineNumberText;
					lineNumberText.mouseEnabled = false;
					lineNumberText.mouseChildren = false;
					addChild(lineNumberText);
				}
			}
			if (lineNumberText != null && newLineNumberText == null) {
				removeChild(lineNumberText);
				lineNumberText = null;
			}

			if (lineNumberText != null) {
				lineNumberText.y = 12;
				lineNumberText.x = lineNumberWidth - lineNumberText.width - 3;
			}
		} else if (lineNumberText != null) {
			removeChild(lineNumberText);
			lineNumberText = null;
		}
	}

	private function drawSelectionRect(x:Int, w:Int):Void {
		var g:Graphics = selection.graphics;
		g.clear();
		g.beginFill(AS3.int(Reflect.field(styles, 'selectionColor')), Reflect.field(styles, 'selectedLineColorAlpha'));
		g.drawRect(x, 0, w, lineHeight);
		g.endFill();
	}

	private function drawTraceSelectionRect(x:Int, w:Int):Void {
		var g:Graphics = traceSelection.graphics;
		g.clear();
		g.beginFill(AS3.int(Reflect.field(styles, 'tracingLineColor')), Reflect.field(styles, 'selectedLineColorAlpha'));
		g.drawRect(x, 0, w, lineHeight);
		g.endFill();

	}

	private function drawMarkerAtPosition(x:Int, y:Int):Void {
		x += AS3.int(lineNumberWidth + _horizontalOffset);
		marker.x = x;
		marker.y = y;

		if (focus) {
			markerBlinkTimer.reset();
			markerBlinkTimer.start();
			marker.visible = true;
		}
	}

	private function markerBlink(event:TimerEvent):Void {
		marker.visible = !marker.visible;
	}

	private static var TextLineRenderer_static_initializer = {
		classInit();
		true;
	}

}