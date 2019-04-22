package actionScripts.ui.tabNavigator;

import actionScripts.ui.tabNavigator.skin.TabBarWithScrollerSkin;
import actionScripts.ui.tabview.TabEvent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import spark.components.ButtonBarButton;
import spark.components.TabBar;
import flash.events.Event;

@:meta(Style(name = 'closeButtonVisible', type = 'Boolean', inherit = 'no', theme = 'spark'))
@:meta(Event(name = 'closeButtonClick', type = 'flash.events.MouseEvent'))
class TabBarWithScroller extends TabBar {

	private var _maxElementCountWithoutScroller:Int = 0;

	public function new() {
		super();

		this.setStyle('cornerRadius', 1);
		this.setStyle('closeButtonVisible', true);
		this.setStyle('skinClass', TabBarWithScrollerSkin);
	}

	private var _orientation:String = 'top';

	@:meta(Inspectable(enumeration = 'top,left,bottom,right', defaultValue = 'top'))
	@:meta(Bindable(event = 'orientationChanged'))
	public var orientation(get, set):String;
	private function get_orientation():String {
		return _orientation;
	}

	private function set_orientation(value:String):String {
		if (_orientation != value) {
			_orientation = value;
			dispatchEvent(new Event('orientationChanged'));
			this.invalidateSkinState();
		}
		return value;
	}

	private var _scrollable:Bool = false;

	@:meta(Bindable(event = 'scrollableChanged'))
	public var scrollable(get, set):Bool;
	private function get_scrollable():Bool {
		return _scrollable;
	}

	private function set_scrollable(value:Bool):Bool {
		if (_scrollable != value) {
			_scrollable = value;
			dispatchEvent(new Event('scrollableChanged'));
			this.refreshMaxElementCountWithoutScroller();
			this.invalidateSkinState();
		}
		return value;
	}

	override private function getCurrentSkinState():String {
		var state:String = Std.string(super.getCurrentSkinState());

		if (this.scrollable) {
			if (AS3.as(this.dataGroup, Bool) && _maxElementCountWithoutScroller < this.dataGroup.numElements) {
				if (this.orientation == 'top' ||
					this.orientation == 'left' ||
					this.orientation == 'right') {
					state += 'WithTopScroller';
				} else if (this.orientation == 'bottom') {
					state += 'WithBottomScroller';
				}
			} else {
				state = 'normal';
			}
		} else if (this.orientation == 'left' || this.orientation == 'right') {
			state = 'normalWithLeftRightNoScroller';
		}

		return state;
	}

	override private function measure():Void {
		super.measure();

		this.refreshMaxElementCountWithoutScroller();
	}

	override private function dataProvider_collectionChangeHandler(event:Event):Void {
		super.dataProvider_collectionChangeHandler(event);

		var collectionEvent:CollectionEvent = AS3.as(event, CollectionEvent);
		if (collectionEvent.kind == CollectionEventKind.ADD || collectionEvent.kind == CollectionEventKind.REMOVE) {
			this.invalidateSkinState();
		}
	}

	private function refreshMaxElementCountWithoutScroller():Void {
		if (AS3.as(this.dataGroup, Bool) && this.scrollable) {
			var typicalItem:ButtonBarButton = AS3.as(this.dataGroup.getElementAt(0), ButtonBarButton);
			if (typicalItem != null && _maxElementCountWithoutScroller == 0) {
				_maxElementCountWithoutScroller = AS3.int(this.measuredWidth / typicalItem.measuredWidth);
				this.invalidateSkinState();
			}
		}
	}

}