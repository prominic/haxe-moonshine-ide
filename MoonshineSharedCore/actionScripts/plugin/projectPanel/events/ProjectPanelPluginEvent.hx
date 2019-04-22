package actionScripts.plugin.projectPanel.events;

import actionScripts.interfaces.IViewWithTitle;
import flash.events.Event;

class ProjectPanelPluginEvent extends Event {

	public static inline var ADD_VIEW_TO_PROJECT_PANEL:String = 'addViewToProjectPanel';
	public static inline var REMOVE_VIEW_TO_PROJECT_PANEL:String = 'removeViewToProjectPanel';

	private var _view:IViewWithTitle;

	public function new(type:String, view:IViewWithTitle) {
		super(type, false, false);

		this._view = view;
	}

	public var view(get, never):IViewWithTitle;
	private function get_view():IViewWithTitle {
		return _view;
	}

}