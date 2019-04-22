package elements.skins;

import mx.skins.ProgrammaticSkin;

@:meta(Style(name = 'thumbColorLeft', type = 'uint', format = 'color', inherit = 'yes'))
@:meta(Style(name = 'thumbColorRight', type = 'uint', format = 'color', inherit = 'yes'))
@:meta(Style(name = 'thumbLeftSideLine', type = 'uint', format = 'color', inherit = 'yes'))
@:meta(Style(name = 'thumbHline1', type = 'uint', format = 'color', inherit = 'yes'))
@:meta(Style(name = 'thumbHline2', type = 'uint', format = 'color', inherit = 'yes'))
class VScrollBarThumbSkin extends ProgrammaticSkin {

	public function new() {
		super();
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		// background
		graphics.clear();
		graphics.beginFill(getStyle('thumbColorLeft'));
		graphics.drawRect(-8, 0, 15, unscaledHeight);
		graphics.endFill();

		// hilight
		graphics.beginFill(getStyle('thumbColorRight'));
		graphics.drawRect(0, 0, 7, unscaledHeight);
		graphics.endFill();

		// left side line
		graphics.beginFill(getStyle('thumbLeftSideLine'));
		graphics.drawRect(-8, 0, 1, unscaledHeight);
		graphics.endFill();

		// middle drag-lines
		graphics.lineStyle(1, getStyle('thumbHline1'), 1, false);

		// Only draw one line if the scrubber is supersmall
		if (unscaledHeight > 15) {
			graphics.moveTo(-4, AS3.int(unscaledHeight / 2) - 4);
			graphics.lineTo(4, AS3.int(unscaledHeight / 2) - 4);

			graphics.moveTo(-4, AS3.int(unscaledHeight / 2) + 4);
			graphics.lineTo(4, AS3.int(unscaledHeight / 2) + 4);
		}

		graphics.moveTo(-4, AS3.int(unscaledHeight / 2));
		graphics.lineTo(4, AS3.int(unscaledHeight / 2));

		graphics.lineStyle(1, getStyle('thumbHline2'), 0.3, false);

		if (unscaledHeight > 15) {
			graphics.moveTo(-4, AS3.int(unscaledHeight / 2) - 3);
			graphics.lineTo(4, AS3.int(unscaledHeight / 2) - 3);

			graphics.moveTo(-4, AS3.int(unscaledHeight / 2) + 5);
			graphics.lineTo(4, AS3.int(unscaledHeight / 2) + 5);
		}

		graphics.moveTo(-4, AS3.int(unscaledHeight / 2) + 1);
		graphics.lineTo(4, AS3.int(unscaledHeight / 2) + 1);

	}

}