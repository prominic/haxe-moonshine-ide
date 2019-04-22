package actionScripts.ui.marker;

import flash.events.Event;
import mx.events.ResizeEvent;
import mx.graphics.SolidColor;
import spark.components.Group;
import spark.components.TextArea;
import spark.primitives.Rect;
import actionScripts.events.GeneralEvent;
import components.skins.TransparentTextAreaSkin;
import flashx.textLayout.compose.StandardFlowComposer;
import flashx.textLayout.compose.TextFlowLine;
import flashx.textLayout.formats.TextLayoutFormat;

@:meta(Event(name = 'VSCrollUpdate', type = 'actionScripts.events.GeneralEvent'))
@:meta(Event(name = 'HSCrollUpdate', type = 'actionScripts.events.GeneralEvent'))
class MarkerTextArea extends Group {

	private static var LINE_HEIGHT:Float;

	public var isMatchCase:Bool = false;
	public var isRegexp:Bool = false;
	public var isEscapeChars:Bool = false;
	public var isRefactoredView:Bool = false;
	public var searchRegExp:as3hx.Compat.Regex;

	//public var positions:Array;

	private var _text:String;

	public var text(get, set):String;
	private function get_text():String {
		return _text;
	}

	private function set_text(value:String):String {
		_text = value;
		if (textArea != null) {
			textArea.text = _text;
		}
		return value;
	}

	private var textArea:TextArea;
	private var lineHighlightContainer:Group;
	private var lastLinesIndex:Int = 0;
	private var highlightDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var contentInLineBreaks:Array<Dynamic>;
	private var isAllLinesRendered:Bool = false;

	public function new() {
		super();
		clipAndEnableScrolling = true;
	}

	override private function createChildren():Void {
		super.createChildren();

		var bg:Rect = new Rect();
		bg.fill = new SolidColor(0xf5f5f5);
		bg.left = bg.right = bg.top = bg.bottom = 0;
		addElement(bg);

		addElement(getHighlighterBase());

		textArea = new TextArea();
		textArea.editable = false;
		textArea.percentWidth = textArea.percentHeight = 100;
		textArea.setStyle('lineBreak', 'explicit');
		textArea.setStyle('skinClass', TransparentTextAreaSkin);
		addElement(textArea);
	}

	private var replaceValue:String;

	public function highlight(search:String):Void {
		replaceValue = search;

		highlightDict = new Dictionary();
		isAllLinesRendered = false;
		textArea.scroller.verticalScrollBar.value = 0;
		textArea.setFormatOfRange(new TextLayoutFormat());
		if (lineHighlightContainer != null) {
			var tmpIndex:Int = AS3.int(getElementIndex(lineHighlightContainer));
			removeElement(lineHighlightContainer);
			addElementAt(getHighlighterBase(), tmpIndex);
		}

		if (!AS3.as(textArea.scroller.verticalScrollBar.hasEventListener(Event.CHANGE), Bool)) {
			textArea.scroller.verticalScrollBar.addEventListener(Event.CHANGE, onVScrollUpdate);
			textArea.scroller.horizontalScrollBar.addEventListener(Event.CHANGE, onHScrollUpdate);
		}

		var positions:Array<Dynamic> = getPositions(Std.string(textArea.text));
		var len:Int = positions.length;

		for (i in 0...len) {
			var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
			textLayoutFormat.backgroundColor = 0xffb2ff;
			textArea.setFormatOfRange(textLayoutFormat, Reflect.field(positions[i], 'posStart'), Reflect.field(positions[i], 'posEnd'));
		}

		// adding necessary listeners
		this.addEventListener(ResizeEvent.RESIZE, onStageResized);
		this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}

	public function getPositions(original:String):Array<Dynamic> {
		// @note
		// we can do the highlight generation in two ways -
		// looping through contentInLineBreaks or adding highlights on-demand
		// upon scroll event updates. If a line has 1000 lines it may would be
		// overkill to generate all the lines in one go looping through the
		// contentsInLineBreaks array. Many a time an user may do not checks
		// till bottom, thus it shoud be more efficient to add the
		// lines based on available TextFlowLine array on scroll event
		contentInLineBreaks = cast original.split('\n');

		var updateLastIndex:Bool = true;
		var composer:StandardFlowComposer = AS3.as(textArea.textFlow.flowComposer, StandardFlowComposer);

		lineHighlightContainer.graphics.beginFill(0xffff00, .35);
		lineHighlightContainer.graphics.lineStyle(1, 0xffff00, .65, true);

		composer.lines.forEach(function(element:TextFlowLine, index:Int, arr:Array<Dynamic>):Void {
					if (index == 1) {
						LINE_HEIGHT = element.y - Reflect.getProperty(composer.lines, Std.string(0)).y;
					}
					if (AS3.as(element.paragraph, Bool) && AS3.as(searchRegExp.exec(Reflect.getProperty(element.paragraph.mxmlChildren, Std.string(0)).text), Bool)) {
						lineHighlightContainer.graphics.drawRect(0, element.y - 1, width, element.height);
						highlightDict.set(index, true);
						searchRegExp.lastIndex = 0;
					}

					if (!AS3.as(element.paragraph, Bool) && updateLastIndex) {
						lastLinesIndex = index;
						updateLastIndex = false;
					} else if (updateLastIndex) {
						lastLinesIndex = index;
					}
				});

		lineHighlightContainer.graphics.endFill();

		var tmpPositions:Array<Dynamic> = [];
		var results:Array<Dynamic>;
		if (!isRefactoredView) {
			results = searchRegExp.exec(original);
			while (results != null) {
				tmpPositions.push({
							'posStart': results.index,
							'posEnd': searchRegExp.lastIndex
						});
				results = searchRegExp.exec(original);
			}
		} else {
			var replaceValueLength:Int = replaceValue.length;
			var t1:String = '';
			var t2:String;
			results = searchRegExp.exec(original);
			while (results != null) {
				tmpPositions.push({
							'posStart': results.index,
							'posEnd': results.index + replaceValueLength
						});
				t2 = ((t1 != '')) ? t1.substring(0, AS3.int(results.index)) : original.substring(0, AS3.int(results.index));
				t2 += replaceValue;
				t1 = t2 + (((t1 != '')) ? t1.substr(AS3.int(searchRegExp.lastIndex), t1.length) : original.substr(AS3.int(searchRegExp.lastIndex), original.length));
				results = searchRegExp.exec(t1);
			}

			this.text = t1;
		}

		return tmpPositions;
	}

	public function updateVScrollByNeighbour(event:GeneralEvent):Void {
		textArea.scroller.viewport.verticalScrollPosition = as3hx.Compat.parseFloat(event.value);
		onVScrollUpdate(null, false);
	}

	public function updateHScrollByNeighbour(event:GeneralEvent):Void {
		textArea.scroller.viewport.horizontalScrollPosition = as3hx.Compat.parseFloat(event.value);
	}

	private function getHighlighterBase():Group {
		lineHighlightContainer = new Group();
		lineHighlightContainer.percentWidth = lineHighlightContainer.percentHeight = 100;

		return lineHighlightContainer;
	}

	private function onVScrollUpdate(event:Event, isDispatchEvent:Bool = true):Void {
		if (!isAllLinesRendered) {
			var composer:StandardFlowComposer = AS3.as(textArea.textFlow.flowComposer, StandardFlowComposer);
			if (composer.lines.length == contentInLineBreaks.length - 1) {
				isAllLinesRendered = true;
			}

			if (composer.lines.length > lastLinesIndex) {
				var updateLastIndex:Bool = true;
				lineHighlightContainer.graphics.beginFill(0xffff00, .35);
				lineHighlightContainer.graphics.lineStyle(1, 0xffff00, .65, true);
				for (i in lastLinesIndex...composer.lines.length) {
					var tfl:TextFlowLine = Reflect.getProperty(composer.lines, Std.string(i));
					if (highlightDict.get(i) == null && AS3.as(searchRegExp.exec(contentInLineBreaks[i]), Bool)) {
						lineHighlightContainer.graphics.drawRect(0, (i * LINE_HEIGHT) + 4, width, LINE_HEIGHT);
						highlightDict.set(i, true);
						searchRegExp.lastIndex = 0;
					}

					if (!AS3.as(tfl.paragraph, Bool) && updateLastIndex) {
						lastLinesIndex = i;
						updateLastIndex = false;
					} else if (updateLastIndex) {
						lastLinesIndex = i;
					}
				}

				lineHighlightContainer.graphics.endFill();
			}
		}

		lineHighlightContainer.y = -textArea.scroller.viewport.verticalScrollPosition;
		if (isDispatchEvent) {
			dispatchEvent(new GeneralEvent('VSCrollUpdate', textArea.scroller.viewport.verticalScrollPosition));
		}
	}

	private function onHScrollUpdate(event:Event):Void {
		dispatchEvent(new GeneralEvent('HSCrollUpdate', textArea.scroller.viewport.horizontalScrollPosition));
	}

	private function onRemovedFromStage(event:Event):Void {
		textArea.scroller.verticalScrollBar.removeEventListener(Event.CHANGE, onVScrollUpdate);
		textArea.scroller.horizontalScrollBar.removeEventListener(Event.CHANGE, onHScrollUpdate);
		this.removeEventListener(ResizeEvent.RESIZE, onStageResized);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}

	private function onStageResized(event:ResizeEvent):Void {
		trace('Resized');
	}

}