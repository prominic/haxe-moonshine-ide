package actionScripts.ui.tabNavigator;

import mx.core.UIComponent;

class CloseTabButton extends UIComponent {

	public function new() {
		super();

		this.graphics.lineStyle(1, 0xFFFFFF, 0.05);
		this.graphics.moveTo(0, 1);
		this.graphics.lineTo(0, 24);
		this.graphics.lineStyle(1, 0x0, 0.05);
		this.graphics.moveTo(1, 1);
		this.graphics.lineTo(1, 24);
		// Circle
		this.graphics.lineStyle(1, 0xFFFFFF, 0.8);
		this.graphics.beginFill(0x0, 0);
		this.graphics.drawCircle(14, 12, 6);
		this.graphics.endFill();
		// X (\)
		this.graphics.lineStyle(2, 0xFFFFFF, 0.8, true);
		this.graphics.moveTo(12, 10);
		this.graphics.lineTo(16, 14);
		// X (/)
		this.graphics.moveTo(16, 10);
		this.graphics.lineTo(12, 14);
		// Hit area
		this.graphics.lineStyle(0, 0x0, 0);
		this.graphics.beginFill(0x0, 0);
		this.graphics.drawRect(0, 0, 27, 25);
		this.graphics.endFill();

		this.buttonMode = true;
		this.depth = 1;
	}

	private var _itemIndex:Int = -1;

	public var itemIndex(get, set):Int;
	private function get_itemIndex():Int {
		return _itemIndex;
	}

	private function set_itemIndex(value:Int):Int {
		_itemIndex = value;
		return value;
	}

}