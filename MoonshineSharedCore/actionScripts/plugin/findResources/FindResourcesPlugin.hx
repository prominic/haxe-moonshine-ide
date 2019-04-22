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
package actionScripts.plugin.findResources;

import flash.display.DisplayObject;
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.plugin.PluginBase;
import actionScripts.valueObjects.ConstantsCoreVO;
import components.popup.FindResourcesPopup;

class FindResourcesPlugin extends PluginBase {

	public static inline var EVENT_FIND_RESOURCES:String = 'findResources';
	private var resourceSearchView:FindResourcesPopup;

	@:meta(Bindable())
	public static var previouslySelectedPatterns:ArrayCollection;

	public function new() {
		super();
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Find Resources';
	}

	override private function get_name():String {
		return 'Find Resources';
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(EVENT_FIND_RESOURCES, findResourcesHandler);
	}

	private function findResourcesHandler(event:Event):Void {
		if (resourceSearchView == null) {
			resourceSearchView = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), FindResourcesPopup, true), FindResourcesPopup);
			resourceSearchView.addEventListener(CloseEvent.CLOSE, findResourcesViewCloseHandler);

			PopUpManager.centerPopUp(resourceSearchView);
		}
	}

	private function findResourcesViewCloseHandler(event:CloseEvent):Void {
		if (resourceSearchView.filesExtensionFilterView.hasSelectedExtensions()) {
			previouslySelectedPatterns = resourceSearchView.filesExtensionFilterView.patterns;
		} else {
			previouslySelectedPatterns = null;
		}

		resourceSearchView.removeEventListener(CloseEvent.CLOSE, findResourcesViewCloseHandler);
		resourceSearchView = null;
	}

}