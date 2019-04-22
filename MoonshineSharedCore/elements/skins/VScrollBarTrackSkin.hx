package elements.skins;

import flash.filters.DropShadowFilter;
import mx.skins.ProgrammaticSkin;

class VScrollBarTrackSkin extends ProgrammaticSkin {

	public function new() {
		super();

		filters = [
				new DropShadowFilter(2, 0, 0x0, .2, 8, 8, 1, 1, true)
		];
	}

	override private function get_measuredWidth():Float {
		return 15;
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		// background
		graphics.clear();
		graphics.beginFill(0x444444);
		graphics.drawRect(0, 0, 15, unscaledHeight);
		graphics.endFill();
	}

}