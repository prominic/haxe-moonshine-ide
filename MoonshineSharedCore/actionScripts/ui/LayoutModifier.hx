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
package actionScripts.ui;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
import mx.core.FlexGlobals;
import actionScripts.events.GeneralEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.help.HelpPlugin;
import actionScripts.valueObjects.ConstantsCoreVO;
import components.views.project.TreeView;

class LayoutModifier {

	public static inline var SAVE_LAYOUT_CHANGE_EVENT:String = 'SAVE_LAYOUT_CHANGE_EVENT';
	public static inline var PROJECT_PANEL_COLLAPSED_FIELD:String = 'isProjectPanelCollapsed';
	public static inline var CONSOLE_HEIGHT:String = 'projectPanelHeight';
	public static inline var SIDEBAR_WIDTH:String = 'sidebarWidth';
	public static inline var IS_MAIN_WINDOW_MAXIMIZED:String = 'isMainWindowMaximized';
	public static inline var MAIN_WINDOW_WIDTH_HEIGHT:String = 'MAIN_WINDOW_WIDTH_HEIGHT';
	public static inline var SIDEBAR_CHILDREN:String = 'sidebarChildren';

	private static var dispatcher(default, never):GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private static var model(default, never):IDEModel = IDEModel.getInstance();

	public static var sidebarChildren:Array<Dynamic>;

	private static var sectionStatesDict:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private static var applicationSize:String;
	private static var isTourDeOnceOpened:Bool = false;
	private static var isAS3DocOnceOpened:Bool = false;
	private static var isSidebarCreated:Bool = false;

	public static function parseCookie(value:SharedObject):Void {
		if (Reflect.hasField(value.data, PROJECT_PANEL_COLLAPSED_FIELD)) {
			isProjectPanelCollapsed = Reflect.field(value.data, PROJECT_PANEL_COLLAPSED_FIELD) != null;
		}
		if (Reflect.hasField(value.data, CONSOLE_HEIGHT)) {
			projectPanelHeight = AS3.int(Reflect.field(value.data, CONSOLE_HEIGHT));
		}
		if (Reflect.hasField(value.data, IS_MAIN_WINDOW_MAXIMIZED)) {
			isAppMaximized = Reflect.field(value.data, IS_MAIN_WINDOW_MAXIMIZED) != null;
		}
		if (Reflect.hasField(value.data, MAIN_WINDOW_WIDTH_HEIGHT)) {
			applicationSize = AS3.string(Reflect.field(value.data, MAIN_WINDOW_WIDTH_HEIGHT));
		}
		if (Reflect.hasField(value.data, SIDEBAR_WIDTH)) {
			sidebarWidth = AS3.int(Reflect.field(value.data, SIDEBAR_WIDTH));
		}
		if (Reflect.hasField(value.data, SIDEBAR_CHILDREN)) {
			sidebarChildren = Reflect.field(value.data, SIDEBAR_CHILDREN);
		}

		if (isAppMaximized) {
			FlexGlobals.topLevelApplication.stage.nativeWindow.maximize();
		} else if (applicationSize != null) {
			var tmpStage:Dynamic = FlexGlobals.topLevelApplication.stage;
			var widthHeight:Array<String> = applicationSize.split(':');
			if (Reflect.field(Reflect.field(tmpStage, 'nativeWindow'), 'width') != widthHeight[0] || Reflect.field(Reflect.field(tmpStage, 'nativeWindow'), 'height') != widthHeight[1]) {
				model.flexCore.reAdjustApplicationSize(as3hx.Compat.parseFloat(widthHeight[0]), as3hx.Compat.parseFloat(widthHeight[1]));
			}
		}
		if (sidebarWidth != -1) {
			model.mainView.sidebar.width = ((sidebarWidth >= 0)) ? sidebarWidth : 0;
		}
	}

	public static function attachSidebarSections(treeView:TreeView):Void {
		model.mainView.addPanel(treeView);

		// if restarted for next time
		if (sidebarChildren != null) {
			var isTreeViewAttempted:Bool;
			var i:Int;

			for (i in 0...sidebarChildren.length) {
				switch (Reflect.field(sidebarChildren[i], 'className')) {
					case 'TreeView':
						isTreeViewAttempted = true;
						treeView.percentHeight = Reflect.field(sidebarChildren[i], 'height');
					case 'VSCodeDebugProtocolView':
						dispatcher.dispatchEvent(new GeneralEvent(Std.string(ConstantsCoreVO.EVENT_SHOW_DEBUG_VIEW), Reflect.field(sidebarChildren[i], 'height')));
					case 'AS3DocsView':
						dispatcher.dispatchEvent(new GeneralEvent(HelpPlugin.EVENT_AS3DOCS, Reflect.field(sidebarChildren[i], 'height')));
						isAS3DocOnceOpened = true;
					case 'TourDeFlexContentsView':
						dispatcher.dispatchEvent(new GeneralEvent(HelpPlugin.EVENT_TOURDEFLEX, Reflect.field(sidebarChildren[i], 'height')));
						isTourDeOnceOpened = true;
					case 'ProblemsView':
						dispatcher.dispatchEvent(new GeneralEvent(Std.string(ConstantsCoreVO.EVENT_PROBLEMS), Reflect.field(sidebarChildren[i], 'height')));
				}
			}

			// in case user closed the project treeview component previously,
			// we'll force to set the treeview acquire an height in next Moonshine start
			// reducing the largest component in the row
			if (!isTreeViewAttempted && model.mainView.sidebar.numChildren > 1) {
				var childWithLargestHeight:IPanelWindow;
				for (i in 0...model.mainView.sidebar.numChildren) {
					var tmpSection:IPanelWindow = AS3.as(model.mainView.sidebar.getChildAt(i), IPanelWindow);
					if (childWithLargestHeight == null) {
						childWithLargestHeight = tmpSection;
					} else if (tmpSection.percentHeight > childWithLargestHeight.percentHeight) {
						childWithLargestHeight = tmpSection;
					}
				}

				if (childWithLargestHeight != null) {
					childWithLargestHeight.percentHeight = childWithLargestHeight.percentHeight / 2;
					treeView.percentHeight = childWithLargestHeight.percentHeight;
				}
			} else if (!isTreeViewAttempted && model.mainView.sidebar.numChildren == 1) {
				treeView.percentHeight = 100;
			}

			isSidebarCreated = true;
			return;
		}

		// if starts for the first time
		if (!isAS3DocOnceOpened) {
			dispatcher.dispatchEvent(new Event(HelpPlugin.EVENT_AS3DOCS));
			isAS3DocOnceOpened = true;
		}
		if (!isTourDeOnceOpened) {
			dispatcher.dispatchEvent(new GeneralEvent(HelpPlugin.EVENT_TOURDEFLEX));
			isTourDeOnceOpened = true;
		}

		isSidebarCreated = true;
	}

	public static function saveLastSidebarState():Void {
		var numChildren:Int = AS3.int(model.mainView.sidebar.numChildren);

		var ordering:Array<Dynamic> = [];
		for (i in 0...numChildren) {
			var tmpSection:Dynamic = model.mainView.sidebar.getChildAt(i);
			ordering.push({
						'className': Reflect.field(tmpSection, 'className'),
						'height': Reflect.field(tmpSection, 'percentHeight')
					});
		}

		// saving sidebar last state
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': SIDEBAR_CHILDREN,
					'value': ordering
				}));

		// saving application window width height
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': MAIN_WINDOW_WIDTH_HEIGHT,
					'value': FlexGlobals.topLevelApplication.stage.nativeWindow.width + ':' + FlexGlobals.topLevelApplication.stage.nativeWindow.height
				}));
	}

	public static function addToSidebar(section:IPanelWindow, event:Event = null):Void {
		model.mainView.addPanel(section);
		if (Std.is(event, GeneralEvent) && AS3.as(GeneralEvent(event).value, Bool)) {
			section.percentHeight = AS3.int(GeneralEvent(event).value);
		} else {
			LayoutModifier.justifyHeights(section);
		}
	}

	public static function removeFromSidebar(section:IPanelWindow):Void {
		var sectionIndex:Int = AS3.int(model.mainView.sidebar.getChildIndex(AS3.as(section, DisplayObject)));
		var sectionPercentageHeight:Int = section.percentHeight + 1;
		var sectionGoingToAcquireNewHeight:IPanelWindow;
		if (model.mainView.sidebar.numChildren > 1) {
			sectionGoingToAcquireNewHeight = ((sectionIndex == 0)) ? AS3.as(model.mainView.sidebar.getChildAt(1), IPanelWindow) : AS3.as(model.mainView.sidebar.getChildAt(sectionIndex - 1), IPanelWindow);
		}

		if (model.mainView.sidebar != null) {
			model.mainView.sidebar.removeChild(AS3.as(section, DisplayObject));
		}
		if (model.mainView.sidebar.numChildren == 0) {
			model.mainView.mainPanel.removeChild(model.mainView.sidebar);
		}

		if (sectionGoingToAcquireNewHeight != null) {
			sectionGoingToAcquireNewHeight.percentHeight += sectionPercentageHeight;
		}
	}

	public static function justifyHeights(section:IPanelWindow):Void {
		if (!isSidebarCreated) {
			return;
		}

		var numChildren:Int = AS3.int(model.mainView.sidebar.numChildren);
		if (numChildren == 0) {
			return;
		}

		var childWithLargestHeight:IPanelWindow;
		for (i in 0...numChildren) {
			var tmpSection:IPanelWindow = AS3.as(model.mainView.sidebar.getChildAt(i), IPanelWindow);
			if (childWithLargestHeight == null) {
				childWithLargestHeight = tmpSection;
			} else if (section != tmpSection && tmpSection.height > childWithLargestHeight.height) {
				childWithLargestHeight = tmpSection;
			}
		}

		if (childWithLargestHeight != null) {
			childWithLargestHeight.percentHeight = childWithLargestHeight.percentHeight / 2;
			section.percentHeight = childWithLargestHeight.percentHeight;
		}
	}

	private static var _isProjectPanelCollapsed:Bool = false;

	public static var isProjectPanelCollapsed(get, set):Bool;
	private static function get_isProjectPanelCollapsed():Bool {
		return _isProjectPanelCollapsed;
	}

	private static function set_isProjectPanelCollapsed(value:Bool):Bool {
		_isProjectPanelCollapsed = value;
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': PROJECT_PANEL_COLLAPSED_FIELD,
					'value': value
				}));
		return value;
	}

	private static var _projectPanelHeight:Int = 165;

	public static var projectPanelHeight(get, set):Int;
	private static function get_projectPanelHeight():Int {
		return _projectPanelHeight;
	}

	private static function set_projectPanelHeight(value:Int):Int {
		_projectPanelHeight = value;
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': CONSOLE_HEIGHT,
					'value': value
				}));
		return value;
	}

	private static var _sidebarWidth:Int = -1;

	public static var sidebarWidth(get, set):Int;
	private static function get_sidebarWidth():Int {
		return _sidebarWidth;
	}

	private static function set_sidebarWidth(value:Int):Int {
		_sidebarWidth = value;
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': SIDEBAR_WIDTH,
					'value': value
				}));
		return value;
	}

	private static var _isAppMaximized:Bool = false;

	public static var isAppMaximized(get, set):Bool;
	private static function get_isAppMaximized():Bool {
		return _isAppMaximized;
	}

	private static function set_isAppMaximized(value:Bool):Bool {
		_isAppMaximized = value;
		dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {
					'label': IS_MAIN_WINDOW_MAXIMIZED,
					'value': value
				}));
		return value;
	}

}