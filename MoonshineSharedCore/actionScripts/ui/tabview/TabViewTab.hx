////////////////////////////////////////////////////////////////////////////////
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.tabview;

import actionScripts.ui.tabNavigator.CloseTabButton;
import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import mx.core.UIComponent;
import spark.components.Label;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.valueObjects.ConstantsCoreVO;

class TabViewTab extends UIComponent {

	public static inline var EVENT_TAB_CLICK:String = 'tabClick';
	public static inline var EVENT_TAB_CLOSE:String = 'tabClose';
	public static inline var EVENT_TABP_CLOSE_ALL:String = 'tabCloseAll';

	private var closeButton:CloseTabButton;
	private var background:Sprite;
	private var labelView:Label;
	private var labelViewMask:Sprite;

	private var closeButtonWidth:Int = 27;
	private var isCloseButtonAvailable:Bool = true;
	private var needsRedrawing:Bool = false;
	private var closeButtonAlpha:Float = 0.8;

	public var backgroundColor:Int = 0x424242;//0x464d55;
	public var selectedBackgroundColor:Int = 0x812137;
	public var closeButtonColor:Int = 0xFFFFFF;
	public var textColor:Int = 0xEEEEEE;
	public var innerGlowColor:Int = 0xFFFFFF;

	public function new() {
		super();
		width = 200;
		height = 25;

		addEventListener(MouseEvent.MOUSE_OVER, onTabViewTabMouseOverOut);
		addEventListener(MouseEvent.MOUSE_OUT, onTabViewTabMouseOverOut);
	}

	private function createContextMenu():ContextMenu {
		var tabContextMenu:ContextMenu = new ContextMenu();
		var cutItem:ContextMenuItem = new ContextMenuItem('Close');
		cutItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemClose);
		tabContextMenu.customItems.push(cutItem);

		var copyItem:ContextMenuItem = new ContextMenuItem('Close All');
		copyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemCloseAll);
		tabContextMenu.customItems.push(copyItem);

		return tabContextMenu;
	}

	public var showCloseButton:Bool = true;

	override private function set_width(value:Float):Float {
		super.width = value;

		needsRedrawing = true;
		invalidateDisplayList();
		return value;
	}

	private var _data:Dynamic;

	public var data(get, set):Dynamic;
	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (_data != value) {
			_data = value;
			if (Std.is(value, BasicTextEditor)) {
				var editor:BasicTextEditor = AS3.as(value, BasicTextEditor);
				if (editor.currentFile != null) {
					this.contextMenu = createContextMenu();
					SharedObjectUtil.saveLocationOfOpenedProjectFile(
							editor.currentFile.name,
							Std.string(editor.currentFile.fileBridge.nativePath),
							editor.projectPath
				);
				}
			}
		}
		return value;
	}

	private var _label:String;

	public var label(get, set):String;
	private function set_label(value:String):String {
		_label = value;
		if (labelView != null) {
			labelView.text = value;
		}
		return value;
	}

	private function get_label():String {
		return _label;
	}

	private var _selected:Bool = false;

	public var selected(get, set):Bool;
	private function get_selected():Bool {
		return _selected;
	}

	private function set_selected(value:Bool):Bool {
		if (value == _selected) {
			return value;
		}
		_selected = value;

		drawButtonState();
		return value;
	}

	override private function createChildren():Void {
		background = new Sprite();
		background.filters = cast [new GlowFilter(innerGlowColor, 0.25, 0, 24, 2, 2, true)];
		background.addEventListener(MouseEvent.CLICK, tabClicked);
		addChild(background);

		labelView = new Label();
		labelView.x = 8;
		labelView.y = 8;
		labelView.width = width - 36;
		labelView.height = height;
		labelView.maxDisplayedLines = 1;
		labelView.mouseEnabled = false;
		labelView.mouseChildren = false;
		labelView.setStyle('color', textColor);
		labelView.setStyle('fontFamily', 'DejaVuSans');
		labelView.setStyle('fontSize', 11);
		labelView.filters = [new DropShadowFilter(1, 90, 0, 0.1, 0, 0)];
		if (_label != null) {
			labelView.text = _label;
			if (_label.split('.').length > 1) {
				toolTip = _label;
			}
		}
		addChild(labelView);

		if (Math.isNaN(getStyle('textPaddingLeft')) == false) {
			labelView.x += AS3.int(getStyle('textPaddingLeft'));
		}

		labelViewMask = new Sprite();
		addChild(labelViewMask);
		labelView.cacheAsBitmap = true;
		labelViewMask.cacheAsBitmap = true;
		labelView.mask = labelViewMask;

		// lets not enable close button to tabs which
		// we not want to let close
		if (ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(label) != -1) {
			isCloseButtonAvailable = false;
			closeButtonAlpha = 0.2;
		}

		closeButton = new CloseTabButton();
		closeButton.visible = false;
		// Vertical line separators
		closeButton.graphics.clear();
		closeButton.graphics.lineStyle(1, 0xFFFFFF, 0.05);
		closeButton.graphics.moveTo(0, 1);
		closeButton.graphics.lineTo(0, 24);
		closeButton.graphics.lineStyle(1, 0x0, 0.05);
		closeButton.graphics.moveTo(1, 1);
		closeButton.graphics.lineTo(1, 24);
		// Circle
		closeButton.graphics.lineStyle(1, closeButtonColor, closeButtonAlpha);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawCircle(14, 12, 6);
		closeButton.graphics.endFill();
		// X (\)
		closeButton.graphics.lineStyle(2, closeButtonColor, closeButtonAlpha, true);
		closeButton.graphics.moveTo(12, 10);
		closeButton.graphics.lineTo(16, 14);
		// X (/)
		closeButton.graphics.moveTo(16, 10);
		closeButton.graphics.lineTo(12, 14);
		// Hit area
		closeButton.graphics.lineStyle(0, 0x0, 0);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawRect(0, 0, closeButtonWidth, 25);
		closeButton.graphics.endFill();
		if (isCloseButtonAvailable) {
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
		}

		addChild(closeButton);

		drawButtonState();
	}

	private function drawButtonState():Void {
		if (background == null) {
			return;
		}

		closeButton.x = width - closeButtonWidth;

		background.graphics.clear();

		background.graphics.lineStyle(1, 0x0, 0.5);
		background.graphics.moveTo(0, -1);
		background.graphics.lineTo(width, -1);
		background.graphics.lineStyle(0, 0, 0);

		var gradWidth:Int = 8;
		var labelMaskWidth:Int = AS3.int(width - gradWidth);

		if (Math.isNaN(getStyle('textPaddingLeft')) == false) {
			labelMaskWidth += AS3.int(getStyle('textPaddingLeft'));
		}

		if (_selected) {
			if (showCloseButton) {
				closeButton.visible = true;
			}

			labelMaskWidth -= closeButtonWidth;

			background.graphics.beginFill(selectedBackgroundColor);
			background.graphics.drawRect(0, 0, width - 1, height);
			background.graphics.endFill();

			background.graphics.lineStyle(1, 0xFFFFFF, 0.3, false);
			background.graphics.moveTo(1, height);
			background.graphics.lineTo(1, 0);
			background.graphics.lineTo(width - 2, 0);
			background.graphics.lineTo(width - 2, height);
		} else {
			closeButton.visible = false;

			labelMaskWidth -= 5;

			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(0, 0, width, height);
			background.graphics.endFill();

			background.graphics.lineStyle(1, 0x0, 0.3, false);
			background.graphics.moveTo(0, height);
			background.graphics.lineTo(0, 0);
			background.graphics.moveTo(width - 1, 0);
			background.graphics.lineTo(width - 1, height);
		}

		labelViewMask.graphics.clear();
		labelViewMask.graphics.beginFill(0x0, 1);
		labelViewMask.graphics.drawRect(0, 0, labelMaskWidth, height);
		labelViewMask.graphics.endFill();

		var mtr:Matrix = new Matrix();
		mtr.createGradientBox(gradWidth, height, 0, labelMaskWidth, 0);
		labelViewMask.graphics.beginGradientFill('linear', cast [0x0, 0x0], cast [1, 0], cast [0, 255], mtr);
		labelViewMask.graphics.drawRect(labelMaskWidth, 0, gradWidth, height);
		labelViewMask.graphics.endFill();
	}

	private function closeButtonClicked(event:Event):Void {
		closeThisTab();
	}

	private function tabClicked(event:Event):Void {
		dispatchEvent(new Event(EVENT_TAB_CLICK));
	}

	private function onTabViewTabMouseOverOut(event:MouseEvent):Void {
		if (!showCloseButton) {
			return;
		}
		if (selected) {
			return;
		}

		closeButton.visible = event.type == MouseEvent.MOUSE_OVER;
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		if (needsRedrawing) {
			drawButtonState();
		}
	}

	private function onMenuItemCloseAll(event:ContextMenuEvent):Void {
		dispatchEvent(new Event(EVENT_TABP_CLOSE_ALL));
	}

	private function onMenuItemClose(event:ContextMenuEvent):Void {
		closeThisTab();
	}

	private function closeThisTab():Void {
		dispatchEvent(new Event(EVENT_TAB_CLOSE));

		if (Std.is(data, BasicTextEditor)) {
			var editor:BasicTextEditor = AS3.as(data, BasicTextEditor);

			if (editor.currentFile != null) {
				SharedObjectUtil.removeLocationOfClosingProjectFile(
						editor.currentFile.name,
						Std.string(editor.currentFile.fileBridge.nativePath),
						editor.projectPath
			);
			}
		}
	}

}