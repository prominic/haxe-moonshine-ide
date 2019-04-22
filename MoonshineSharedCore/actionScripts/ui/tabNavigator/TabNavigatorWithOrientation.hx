package actionScripts.ui.tabNavigator;

import actionScripts.ui.tabNavigator.event.ButtonBarButtonWithCloseEvent;
import actionScripts.ui.tabNavigator.event.TabNavigatorEvent;
import actionScripts.ui.tabNavigator.skin.TabNavigatorWithOrientationSkin;
import flash.events.Event;
import flash.events.MouseEvent;
import spark.components.ButtonBarButton;
import spark.components.NavigatorContent;
import spark.containers.Navigator;

@:meta(Event(name = 'tabClose', type = 'actionScripts.ui.tabNavigator.event.TabNavigatorEvent'))
class TabNavigatorWithOrientation extends Navigator {

	public function new() {
		super();

		this.setStyle('skinClass', TabNavigatorWithOrientationSkin);
	}

	@:meta(SkinPart(required = true))
	public var tabBar:TabBarWithScroller;

	private var _orientation:String = 'top';

	@:meta(Inspectable(enumeration = 'top,left,bottom,right', defaultValue = 'top'))
	@:meta(Bindable(name = 'orientationChanged'))
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

	@:meta(Bindable(name = 'scrollableChanged'))
	public var scrollable(get, set):Bool;
	private function get_scrollable():Bool {
		return _scrollable;
	}

	private function set_scrollable(value:Bool):Bool {
		if (_scrollable != value) {
			_scrollable = value;
			dispatchEvent(new Event('scrollableChanged'));
			this.invalidateSkinState();
		}
		return value;
	}

	override private function partAdded(partName:String, instance:Dynamic):Void {
		super.partAdded(partName, instance);

		if (instance == tabBar) {
			tabBar.setStyle('color', '0xEEEEEE');
			tabBar.setStyle('fontSize', 11);
			tabBar.setStyle('fontFamily', 'DejaVuSans');
			tabBar.addEventListener(ButtonBarButtonWithCloseEvent.CLOSE_BUTTON_CLICK, onTabBarWithScrollerCloseButtonClick);
		}
	}

	override private function partRemoved(partName:String, instance:Dynamic):Void {
		super.partRemoved(partName, instance);

		if (instance == tabBar) {
			tabBar.removeEventListener(ButtonBarButtonWithCloseEvent.CLOSE_BUTTON_CLICK, onTabBarWithScrollerCloseButtonClick);
		}
	}

	override private function getCurrentSkinState():String {
		var state:String = Std.string(super.getCurrentSkinState());

		if (state != 'disabled') {
			switch (this.orientation) {
				case 'top':
					state += 'WithTopTabBar';
				case 'left':
					state += (scrollable) ? 'WithTopTabBar' : 'WithLeftTabBar';
				case 'right':
					state += (scrollable) ? 'WithTopTabBar' : 'WithRightTabBar';
				case 'bottom':
					state += 'WithBottomTabBar';
			}
		}

		return state;
	}

	public function setSelectedTabLabel(label:String):Void {
		var selectedTab:NavigatorContent = (AS3.as(this.selectedItem, NavigatorContent));

		if (selectedTab.label != label) {
			var item:ButtonBarButton = AS3.as(tabBar.dataGroup.getElementAt(this.selectedIndex), ButtonBarButton);

			selectedTab.label = label;
			item.label = label;

			dispatchEvent(new Event('itemUpdated'));
		}
	}

	private function onTabBarWithScrollerCloseButtonClick(event:ButtonBarButtonWithCloseEvent):Void {
		this.dispatchEvent(new TabNavigatorEvent(TabNavigatorEvent.TAB_CLOSE, event.itemIndex));
	}

}