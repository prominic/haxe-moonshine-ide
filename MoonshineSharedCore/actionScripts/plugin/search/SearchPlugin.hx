////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.search;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.managers.PopUpManager;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.tabview.TabEvent;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import components.popup.SearchInProjectPopup;
import components.views.other.SearchInProjectView;

class SearchPlugin extends PluginBase {

	public static inline var SEARCH_IN_PROJECTS:String = 'SEARCH_IN_PROJECTS';
	public static inline var WORKSPACE:String = 'WORKSPACE';
	public static inline var PROJECT:String = 'PROJECT';
	public static inline var LINKED_PROJECTS:String = 'LINKED_PROJECTS';

	@:meta(Bindable())public static var IS_REPLACE_APPLIED:Bool = false;

	public static var LAST_SCOPE_INDEX:Int = 1;
	public static var LAST_SELECTED_SCOPE_ENCLOSING_PROJECTS:Bool = false;
	public static var LAST_SELECTED_PATTERNS:ArrayCollection;
	public static var LAST_SEARCH:String;
	public static var LAST_SELECTED_PROJECT:ProjectVO;

	private var searchPopup:SearchInProjectPopup;
	private var searchResultView:SearchInProjectView;
	private var isCollectionChangeListenerAdded:Bool = false;

	override private function get_name():String {
		return 'Search in Projects';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Search string in one or multiple project files.';
	}

	public function new() {
		super();
	}

	override public function activate():Void {
		dispatcher.addEventListener(SEARCH_IN_PROJECTS, onSearchRequested, false, 0, true);
		super.activate();
	}

	override public function deactivate():Void {
		dispatcher.removeEventListener(SEARCH_IN_PROJECTS, onSearchRequested);
		super.deactivate();
	}

	private function onSearchRequested(event:Event):Void {
		// probable termination
		if (model.projects.length == 0) {
			return;
		}

		if (searchPopup == null) {
			searchPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SearchInProjectPopup, false), SearchInProjectPopup);
			searchPopup.addEventListener(CloseEvent.CLOSE, onSearchPopupClosed);
			PopUpManager.centerPopUp(searchPopup);

			if (!isCollectionChangeListenerAdded) {
				model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged, false, 0, true);
				isCollectionChangeListenerAdded = true;
			}
		} else {
			PopUpManager.bringToFront(searchPopup);
		}
	}

	private function onProjectsCollectionChanged(event:CollectionEvent):Void {
		if (event.kind == CollectionEventKind.REMOVE && Reflect.getProperty(event.items, Std.string(0)) == LAST_SELECTED_PROJECT) {
			LAST_SELECTED_PROJECT = null;
		}
	}

	private function onSearchPopupClosed(event:CloseEvent):Void {
		function updateProperties():Void {
			searchResultView.valueToSearch = searchPopup.txtSearch.text;
			searchResultView.patterns = searchPopup.txtPatterns.text;
			searchResultView.scope = Std.string(searchPopup.rbgScope.selectedValue);
			searchResultView.isEnclosingProjects = AS3.as(searchPopup.cbEnclosingProjects.selected, Bool);
			searchResultView.isMatchCase = AS3.as(searchPopup.optionMatchCase.selected, Bool);
			searchResultView.isRegexp = AS3.as(searchPopup.optionRegExp.selected, Bool);
			searchResultView.isEscapeChars = AS3.as(searchPopup.optionEscapeChars.selected, Bool);
			searchResultView.isShowReplaceWhenDone = searchPopup.isShowReplaceWhenDone;
			searchResultView.selectedProjectToSearch = (LAST_SELECTED_PROJECT != null) ? LAST_SELECTED_PROJECT : null;
		};
		event.target.removeEventListener(CloseEvent.CLOSE, onSearchPopupClosed);

		// probable termination
		if (!searchPopup.isClosedAsSubmit || !AS3.as(searchPopup.ddlProjects.selectedItem, Bool)) {
			searchPopup = null;
			return;
		}

		LAST_SCOPE_INDEX = AS3.int(searchPopup.rbgScope.selectedIndex);
		LAST_SEARCH = searchPopup.txtSearch.text;
		IS_REPLACE_APPLIED = false;
		LAST_SELECTED_SCOPE_ENCLOSING_PROJECTS = AS3.as(searchPopup.cbEnclosingProjects.selected, Bool);
		LAST_SELECTED_PROJECT = (AS3.as(searchPopup.ddlProjects.selectedItem, Bool)) ? AS3.as(searchPopup.ddlProjects.selectedItem, ProjectVO) : null;

		if (searchResultView == null) {
			searchResultView = new SearchInProjectView();
			searchResultView.addEventListener(TabEvent.EVENT_TAB_CLOSE, onSearchResultsClosed);
			updateProperties();

			// adding as a tab
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(AS3.as(searchResultView, IContentWindow))
			);
		} else {
			// another new search initiated
			// while existing search tab already opens
			updateProperties();
			model.activeEditor = searchResultView;
			searchResultView.resetSearch();
		} /*
		 * @local
		 */

		searchPopup = null;
	}

	private function onSearchResultsClosed(event:TabEvent):Void {
		event.target.removeEventListener(TabEvent.EVENT_TAB_CLOSE, onSearchResultsClosed);
		searchResultView = null;
	}

}