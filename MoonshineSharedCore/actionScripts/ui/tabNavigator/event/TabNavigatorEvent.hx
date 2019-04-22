package actionScripts.ui.tabNavigator.event;

import flash.events.Event;

class TabNavigatorEvent extends Event {

	public static inline var TAB_CLOSE:String = 'tabClose';

	public function new(type:String, tabIndex:Int = -1) {
		super(type, false, false);

		_tabIndex = tabIndex;
	}

	private var _tabIndex:Int = 0;

	public var tabIndex(get, never):Int;
	private function get_tabIndex():Int {
		return _tabIndex;
	}

}