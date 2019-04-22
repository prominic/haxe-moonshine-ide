////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.browser;

import flash.events.Event;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.MultiOptionSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.ui.IContentWindow;
import actionScripts.utils.SharedObjectConst;
import actionScripts.valueObjects.ConstantsCoreVO;

class BrowserPlugin extends PluginBase implements ISettingsProvider {

	override private function get_name():String {
		return 'Browser';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Browser Preference Plugin.';
	}

	private static inline var TYPE_INTERNAL:String = 'typeInternal';
	private static inline var TYPE_EXTERNAL:String = 'typeExternal';

	public var browserPath:String = 'System Default';

	private var externalBrowserSettings:PathSetting;
	private var browserList:ArrayCollection;
	private var cookie:SharedObject;

	private var _activeType:String = TYPE_INTERNAL;

	public var activeType(get, set):String;
	private function get_activeType():String {
		return _activeType;
	}

	private function set_activeType(value:String):String {
		_activeType = value;
		externalBrowserSettings.isEditable = (value == TYPE_EXTERNAL);
		return value;
	}

	private var isInternalBrowser:Bool = false;

	override public function activate():Void {
		super.activate();

		/*dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);*/
	}

	override public function deactivate():Void {
		super.deactivate();

		/*dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
		dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
		dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);*/
	}

	override public function resetSettings():Void {}

	public function getSettingsList():Array<ISetting> {
		browserList = new ArrayCollection();
		browserList.addItemAt('System Default', 0);
		cookie = SharedObject.getLocal(Std.string(SharedObjectConst.MOONSHINE_IDE_LOCAL));
		if (Reflect.hasField(cookie.data, 'externalBrowsersPaths')) {
			browserList.source.concat(Reflect.field(cookie.data, 'externalBrowsersPaths'));
		}

		var nvps:Array<NameValuePair> = [
				new NameValuePair('Internal', TYPE_INTERNAL),
				new NameValuePair('External', TYPE_EXTERNAL)
		];
		var typeSettings:MultiOptionSetting = new MultiOptionSetting(this, 'activeType', 'Choose Browsing Type', nvps);
		typeSettings.isCommitOnChange = true;

		externalBrowserSettings = new PathSetting(this, 'browserPath', 'Select or Decleare an External Browser', false, null, false, true);
		externalBrowserSettings.dropdownListItems = browserList;
		externalBrowserSettings.isEditable = false;
		externalBrowserSettings.addEventListener(AbstractSetting.PATH_SELECTED, onExternalPathChanged, false, 0, true);

		return [
				typeSettings,
				externalBrowserSettings
		];
	}

	private function listenToSettingsSave():Void {
		for (tab in as3hx.Compat.each(model.editors)) {
			if (Std.is(tab, SettingsView)) {}
		}
	}

	private function onExternalPathChanged(event:Event, makeNull:Bool = true):Void {
		// add only if not exists
		if (browserList.getItemIndex(externalBrowserSettings.stringValue) == -1) {
			browserList.addItem(externalBrowserSettings.stringValue);
		}
	}

	private function save():Void {
		if (browserList.length > 1) {
			browserList.removeItemAt(0);
			Reflect.setField(cookie.data, 'externalBrowsersPaths', browserList.source);
			cookie.flush();
		}
	}

	public function new() {
		super();
	}

}