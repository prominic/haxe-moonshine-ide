package actionScripts.ui.editor.text;

import org.aswing.Component;
import org.aswing.plaf.basic.BasicListUI;
import org.aswing.geom.IntRectangle;

class PopupUI extends BasicListUI {

	public function new() {
		super();
	}

	/*
	override protected function paintCellFocus(cellComponent:Component):void
	{

	}
	*/
	public function resetIndex():Void {
		paintFocusedIndex = -1;
	}

}