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
package actionScripts.plugin.help;

import flash.events.Event;
import flash.net.URLRequest;
import mx.core.IFlexDisplayObject;
import mx.resources.ResourceManager;
import actionScripts.events.AddTabEvent;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.help.view.AS3DocsView;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.IPanelWindow;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.valueObjects.ConstantsCoreVO;

class HelpPlugin extends PluginBase implements IPlugin {

	public static inline var EVENT_TOURDEFLEX:String = 'EVENT_TOURDEFLEX';
	public static inline var EVENT_AS3DOCS:String = 'EVENT_AS3DOCS';
	public static inline var EVENT_ABOUT:String = 'EVENT_ABOUT';
	public static inline var EVENT_CHECK_MINIMUM_SDK_REQUIREMENT:String = 'EVENT_CHECK_MINIMUM_SDK_REQUIREMENT';
	public static inline var EVENT_APACHE_SDK_DOWNLOADER_REQUEST:String = 'EVENT_APACHE_SDK_DOWNLOADER_REQUEST';
	public static inline var EVENT_ENSURE_JAVA_PATH:String = 'EVENT_ENSURE_JAVA_PATH';
	public static inline var EVENT_PRIVACY_POLICY:String = 'EVENT_PRIVACY_POLICY';

	public static var ABOUT_SUBSCRIBE_ID_TO_WORKER:String;

	override private function get_name():String {
		return 'Help Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Help Plugin. Esc exits.';
	}

	private var tourdeContentView:IPanelWindow;

	override public function activate():Void {
		super.activate();

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			dispatcher.addEventListener(EVENT_TOURDEFLEX, handleTourDeFlexConfigure);
		}

		dispatcher.addEventListener(EVENT_ABOUT, abouthShowHandler);
		dispatcher.addEventListener(EVENT_AS3DOCS, as3DocHandler);
		dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, tabClosedHandler);
		dispatcher.addEventListener(EVENT_PRIVACY_POLICY, privacyPolicyHandler);
	}

	private function handleTourDeFlexConfigure(event:Event):Void {
		tourdeContentView = model.flexCore.getTourDeView();
		LayoutModifier.addToSidebar(tourdeContentView, event);
	}

	private function as3DocHandler(event:Event):Void {
		LayoutModifier.addToSidebar(new AS3DocsView(), event);
	}

	private function abouthShowHandler(event:Event):Void {
		// Show About Panel in Tab
		for (tab in model.editors) {
			if (Reflect.field(tab, 'className') == 'AboutScreen') {
				model.activeEditor = tab;
				return;
			}
		}

		var aboutScreen:IFlexDisplayObject = model.aboutCore.getNewAbout(null);
		dispatcher.dispatchEvent(new AddTabEvent(AS3.as(aboutScreen, IContentWindow)));
	}

	private function tabClosedHandler(event:Event):Void {
		if (Std.is(event, CloseTabEvent)) {
			var tmpEvent:CloseTabEvent = AS3.as(event, CloseTabEvent);
			if (tmpEvent.tab == null || (Std.is(tmpEvent.tab, IPanelWindow))) {
				tourdeContentView.refresh();
			}
		}
	}

	private function privacyPolicyHandler(event:Event):Void {
		var url:String = Std.string(ResourceManager.getInstance().getString('resources', 'PRIVACY_POLICY_URL'));
		flash.Lib.getURL(new URLRequest(url));
	}

	public function new() {
		super();
	}

}