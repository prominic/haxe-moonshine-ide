package actionScripts.plugin.projectPanel;

import flash.events.MouseEvent;
import mx.containers.dividedBoxClasses.BoxDivider;
import mx.core.UIComponent;
import mx.events.DividerEvent;
import mx.events.FlexEvent;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import spark.components.NavigatorContent;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.divider.IDEVDividedBox;
import actionScripts.ui.tabNavigator.TabNavigatorWithOrientation;
import actionScripts.ui.tabNavigator.event.TabNavigatorEvent;
import actionScripts.valueObjects.ConstantsCoreVO;

class ProjectPanelPlugin extends PluginBase implements IPlugin {

	override private function get_name():String {
		return 'ProjectPanel';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	@:meta(Embed(name = '/elements/images/Divider_collapse.png'))
	private var customDividerSkinCollapse(default, null):Class<Dynamic>;
	@:meta(Embed(name = '/elements/images/Divider_expand.png'))
	private var customDividerSkinExpand(default, null):Class<Dynamic>;

	private var view:TabNavigatorWithOrientation;
	private var isOverTheExpandCollapseButton:Bool = false;
	private var cursorID:Int = AS3.int(CursorManager.NO_CURSOR);
	private var isProjectPanelHidden:Bool = false;

	private var views:Array<Dynamic>;

	public function new() {
		super();
	}

	override public function activate():Void {
		super.activate();

		views = [];

		view = new TabNavigatorWithOrientation();
		view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
		view.addEventListener(TabNavigatorEvent.TAB_CLOSE, onViewTabClose);

		view.percentWidth = 100;

		var tempObj:Dynamic = {};
		Reflect.setField(tempObj, 'callback', hideCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Minimize the console frame.  Click and drag to expand it againMinimize the console frame.  Click and drag to expand it again..');
		registerCommand('hide', tempObj);

		var parentView:IDEVDividedBox = model.mainView.bodyPanel;
		parentView.addElement(view);

		parentView.addEventListener(DividerEvent.DIVIDER_RELEASE, onProjectPanelDividerRelease);
		model.mainView.mainPanel.addEventListener(DividerEvent.DIVIDER_RELEASE, onSidebarDividerReleased);

		var divider:BoxDivider = parentView.getDividerAt(0);
		divider.addEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseOver);
		divider.addEventListener(MouseEvent.MOUSE_OUT, onDividerMouseOut);

		dispatcher.addEventListener(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, addViewToProjectPanelHandler);
		dispatcher.addEventListener(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, removeViewToProjectPanelHandler);
	}

	override public function deactivate():Void {
		super.deactivate();

		views = null;

		unregisterCommand('hide');

		model.mainView.bodyPanel.removeEventListener(DividerEvent.DIVIDER_RELEASE, onProjectPanelDividerRelease);
		model.mainView.mainPanel.removeEventListener(DividerEvent.DIVIDER_RELEASE, onSidebarDividerReleased);

		var divider:BoxDivider = model.mainView.bodyPanel.getDividerAt(0);
		divider.removeEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseOver);
		divider.removeEventListener(MouseEvent.MOUSE_OUT, onDividerMouseOut);

		dispatcher.removeEventListener(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, addViewToProjectPanelHandler);
		dispatcher.removeEventListener(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, removeViewToProjectPanelHandler);
	}

	private function addViewToProjectPanelHandler(event:ProjectPanelPluginEvent):Void {
		if (event.view != null && !AS3.as(views.some(function hasView(item:String, index:Int, arr:Array<Dynamic>):Bool {
								return item == event.view.title;
							}), Bool)) {
			var navContent:NavigatorContent = new NavigatorContent();
			navContent.label = event.view.title;

			navContent.addElement(AS3.as(event.view, UIComponent));

			view.addElement(navContent);

			views.push(event.view.title);

			view.selectedIndex = view.numElements - 1;
		}
	}

	private function removeViewToProjectPanelHandler(event:ProjectPanelPluginEvent):Void {
		if (event.view != null && AS3.as(views.some(function hasView(item:String, index:Int, arr:Array<Dynamic>):Bool {
								return item == event.view.title;
							}), Bool)) {
			var tabsCount:Int = AS3.int(view.numElements);
			for (i in 0...tabsCount) {
				var tab:NavigatorContent = AS3.as(view.getItemAt(i), NavigatorContent);
				if (tab.label == event.view.title) {
					view.removeElement(tab);
					views.splice(i, 1)[0];
					break;
				}
			}
		}
	}

	private function onViewTabClose(event:TabNavigatorEvent):Void {
		view.removeElementAt(event.tabIndex);
		views.splice(event.tabIndex, 1)[0];
	}

	private function onViewCreationComplete(event:FlexEvent):Void {
		view.removeEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);

		setProjectPanelVisibility(LayoutModifier.isProjectPanelCollapsed);
		if (!LayoutModifier.isProjectPanelCollapsed) {
			setProjectPanelHeight(LayoutModifier.projectPanelHeight);
		} else {
			setProjectPanelHeight(-1);
		}
	}

	private function onProjectPanelDividerRelease(event:DividerEvent):Void {
		// consider an expand/collapse click
		if (isOverTheExpandCollapseButton) {
			setProjectPanelVisibility(!isProjectPanelHidden);
			if (!isProjectPanelHidden && LayoutModifier.projectPanelHeight != -1) {
				this.setProjectPanelHeight(LayoutModifier.projectPanelHeight);
			} else {
				this.setProjectPanelHeight(-1);
			}

			return;
		}

		var tmpHeight:Int = view.parent.height - view.parent.mouseY - view.minHeight;
		if (tmpHeight <= 4) {
			setProjectPanelVisibility(true);
		} else {
			setProjectPanelVisibility(false);
			LayoutModifier.projectPanelHeight = tmpHeight;
		}
	}

	private function onSidebarDividerReleased(event:DividerEvent):Void {
		LayoutModifier.sidebarWidth = AS3.int(event.target.mouseX);
	}

	private function onDividerMouseOut(event:MouseEvent):Void {
		model.mainView.bodyPanel.cursorManager.removeCursor(cursorID);
		model.mainView.bodyPanel.cursorManager.removeCursor(model.mainView.bodyPanel.cursorManager.currentCursorID);
	}

	private function onDividerMouseOver(event:MouseEvent):Void {
		onDividerMouseOut(null);

		var dividerWidth:Float = Reflect.field(event.target, 'width');
		// divider skin width is 67
		var parts:Float = (dividerWidth - 67) / 2;
		if (event.localX < parts || event.localX > parts + 67) {
			var cursorClass:Class<Dynamic> = as3hx.Compat.castClass(event.target.getStyle('verticalDividerCursor'));
			cursorID = AS3.int(model.mainView.bodyPanel.cursorManager.setCursor(cursorClass, CursorManagerPriority.HIGH, 0, 0));
			isOverTheExpandCollapseButton = false;
		} else {
			isOverTheExpandCollapseButton = true;
		}
	}

	public function hideCommand(args:Array<Dynamic>):Void {
		setProjectPanelVisibility(true);
	}

	private function setProjectPanelVisibility(value:Bool):Void {
		LayoutModifier.isProjectPanelCollapsed = value;
		isProjectPanelHidden = value;
		model.mainView.bodyPanel.setStyle('dividerSkin', (isProjectPanelHidden) ? customDividerSkinExpand : customDividerSkinCollapse);
	}

	public function setProjectPanelHeight(newTargetHeight:Int):Void {
		// no fullscreening console, it's confusing
		newTargetHeight = AS3.int(Math.min(newTargetHeight, view.parent.height - 100));
		newTargetHeight = AS3.int(Math.max(newTargetHeight, 0));

		newTargetHeight += AS3.int(view.minHeight);
		view.height = ((newTargetHeight < view.minHeight)) ? view.minHeight : newTargetHeight;
	}

}