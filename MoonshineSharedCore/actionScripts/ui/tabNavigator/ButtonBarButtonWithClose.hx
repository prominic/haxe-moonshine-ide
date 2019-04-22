package actionScripts.ui.tabNavigator;

import spark.components.ButtonBarButton;

class ButtonBarButtonWithClose extends ButtonBarButton {

	public function new() {
		super();

		mouseChildren = true;
	}

	@:meta(SkinPart(required = true))
	public var closeTabButton:CloseTabButton;

	override private function set_itemIndex(value:Int):Int {
		super.itemIndex = value;
		if (closeTabButton != null) {
			closeTabButton.itemIndex = value;
		}
		return value;
	}

}