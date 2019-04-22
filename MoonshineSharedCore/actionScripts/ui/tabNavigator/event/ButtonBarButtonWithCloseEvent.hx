package actionScripts.ui.tabNavigator.event;

import flash.events.Event;

class ButtonBarButtonWithCloseEvent extends Event {

	public static inline var CLOSE_BUTTON_CLICK:String = 'closeButtonClick';

	public function new(type:String, itemIndex:Int = -1) {
		super(type);

		_itemIndex = itemIndex;
	}

	private var _itemIndex:Int = 0;

	public var itemIndex(get, never):Int;
	private function get_itemIndex():Int {
		return _itemIndex;
	}

}