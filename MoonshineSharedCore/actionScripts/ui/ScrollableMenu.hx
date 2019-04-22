////////////////////////////////////////////////////////////////////////////////
//
//  Code written by Doug McCune.
//  http://dougmccune.com/blog
//
//  You can use this code for whatever you want. Just don't go and try to sell
//  it as your own. If you use it to make something better and want to sell that
//  then go for it.
//
//  Let's all play nice and be happy.
//
////////////////////////////////////////////////////////////////////////////////

package actionScripts.ui;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import mx.controls.Menu;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.menuClasses.IMenuItemRenderer;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.FlexGlobals;
import mx.core.Mx_internal;
import mx.managers.PopUpManager;

class ScrollableMenu extends Menu {

	public function new() {
		super();
	}

	/**
	 * We have to override the static function createMenu so that we create a
	 * ScrollableMenu instead of a normal Menu.
	 */
	public static function createMenu(parent:DisplayObjectContainer, mdp:Dynamic, showRoot:Bool = true):ScrollableMenu {
		var menu:ScrollableMenu = new ScrollableMenu();
		menu.tabEnabled = false;
		menu.owner = DisplayObjectContainer(FlexGlobals.topLevelApplication);
		menu.showRoot = showRoot;
		popUpMenu(menu, parent, mdp);
		return menu;
	}

	/**
	 * The mx.controls.Menu class overrides setting and getting the verticalScrollPolicy
	 * Basically setting the verticalScrollPolicy did nothing, and getting it always
	 * returned ScrollPolicy.OFF. So that's not going to work if we want the menu to scroll.
	 * Here we reinstate the verticalScrollPolicy setter, and keep a local copy of the value
	 * in a private variable _verticalScrollPolicy.
	 *
	 * This setter is basically a copy of what ScrollControlBase and ListBase do.
	 * */
	override private function set_verticalScrollPolicy(value:String):String {
		var newPolicy:String = value.toLowerCase();

		itemsSizeChanged = true;

		if (_verticalScrollPolicy != newPolicy) {
			_verticalScrollPolicy = newPolicy;
			dispatchEvent(new Event('verticalScrollPolicyChanged'));
		}

		invalidateDisplayList();
		return value;
	}

	/** Again, the Menu class just returned ScrollPolicy.OFF every time.
	 * Now we actually return the value that we stored with the setter.
	 * */
	override private function get_verticalScrollPolicy():String {
		return Std.string(this._verticalScrollPolicy);
	}

	/**
	 * The Menu class overrode configureScrollBars() and made the function
	 * do nothing. That means the scrollbars don't know how to draw themselves,
	 * so here we reinstate configureScrollBars. This is basically a copy of the
	 * same method from the mx.controls.List class. It would have been nice if
	 * we could have called this method from down in a subclass of Menu, but AS
	 * doesn't let us do something like super.super, so instead we have to recreate
	 * the class here.
	 * */
	override private function configureScrollBars():Void {
		var rowCount:Int = AS3.int(listItems.length);
		if (rowCount == 0) {
			return;
		}

		// if there is more than one row and it is a partial row we dont count it
		if (rowCount > 1 && Reflect.getProperty(rowInfo, Std.string(rowCount - 1)).y + Reflect.getProperty(rowInfo, Std.string(rowCount - 1)).height > listContent.height) {
			rowCount--;
		}

		// offset, when added to rowCount, is the index of the dataProvider
		// item for that row.  IOW, row 10 in listItems is showing dataProvider
		// item 10 + verticalScrollPosition - lockedRowCount - 1;
		var offset:Int = verticalScrollPosition - lockedRowCount - 1;
		// don't count filler rows at the bottom either.
		var fillerRows:Int = 0;
		// don't count filler rows at the bottom either.
		while (rowCount != 0 && Reflect.getProperty(listItems, Std.string(rowCount - 1)).length == 0) {
			if (collection != null && rowCount + offset >= AS3.int(collection.length)) {
				rowCount--;
				++fillerRows;
			} else {
				break;
			}
		}

		/**
		 * This part needs further functions from mx.controls.List that we don't have
		 * access to. What to do? Whatever, I'll just comment it out and cross my fingers
		 * */
		// we have to scroll up.  We can't have filler rows unless the scrollPosition is 0
		/*
		if (verticalScrollPosition > 0 && fillerRows > 0)
		{
		if (adjustVerticalScrollPositionDownward(Math.max(rowCount, 1)))
		return;
		}*/

		var colCount:Int = AS3.int(Reflect.getProperty(listItems, Std.string(0)).length);
		var oldHorizontalScrollBar:Dynamic = horizontalScrollBar;
		var oldVerticalScrollBar:Dynamic = verticalScrollBar;
		var roundedWidth:Int = Math.round(unscaledWidth);
		var length:Int = (collection != null) ? collection.length - lockedRowCount : 0;
		var numRows:Int = rowCount - lockedRowCount;

		/* This call is slightly modified from mx.controls.List, but not by much */
		setScrollBarProperties(
				Math.round(listContent.width),
				roundedWidth, length, numRows
		);
		maxVerticalScrollPosition = Math.max(length - numRows, 0);

	}

	/**
	 * We need to override openSubMenu as well, so that any subMenus opened by this Menu controls
	 * will also be ScrollableMenus and will have the same maxHeight set
	 */
	override @:ns('mx_internal') private function openSubMenu(row:IListItemRenderer):Void {
		supposedToLoseFocus = true;

		var r:Menu = getRootMenu();
		var menu:Menu;

		// check to see if the menu exists, if not create it
		if (!AS3.as(IMenuItemRenderer(row).menu, Bool)) {
			/* The only differences between this method and the original method in mx.controls.Menu
			* are these two lines.
			*/
			menu = new ScrollableMenu();
			menu.maxHeight = this.maxHeight;

			menu.parentMenu = this;
			menu.owner = this;
			menu.showRoot = showRoot;
			menu.dataDescriptor = r.dataDescriptor;
			menu.styleName = r;
			menu.labelField = r.labelField;
			menu.labelFunction = r.labelFunction;
			menu.iconField = r.iconField;
			menu.iconFunction = r.iconFunction;
			menu.itemRenderer = r.itemRenderer;
			menu.rowHeight = r.rowHeight;
			menu.scaleY = r.scaleY;
			menu.scaleX = r.scaleX;

			// if there's data and it has children then add the items
			if (AS3.as(row.data, Bool) &&
				AS3.as(_dataDescriptor.isBranch(row.data), Bool) &&
				AS3.as(_dataDescriptor.hasChildren(row.data), Bool)) {
				menu.dataProvider = _dataDescriptor.getChildren(row.data);
			}
			menu.sourceMenuBar = sourceMenuBar;
			menu.sourceMenuBarItem = sourceMenuBarItem;

			IMenuItemRenderer(row).menu = menu;
			PopUpManager.addPopUp(menu, r, false);
		}

		super.openSubMenu(row);
	}

	override private function measure():Void {
		super.measure();

		if (measuredHeight > this.maxHeight) {
			measuredHeight = this.maxHeight;
			measuredMinWidth = measuredWidth = measuredWidth + ScrollBar.THICKNESS;
		}
	}

}