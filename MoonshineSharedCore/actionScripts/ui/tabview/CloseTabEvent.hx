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

import flash.display.DisplayObject;
import flash.events.Event;

class CloseTabEvent extends Event {

	public static inline var EVENT_CLOSE_TAB:String = 'closeTabEvent';
	public static inline var EVENT_CLOSE_ALL_TABS:String = 'closeAllTabsEvent';
	public static inline var EVENT_TAB_CLOSED:String = 'tabClosedEvent';
	public static inline var EVENT_ALL_TABS_CLOSED:String = 'allTabsClosed';
	public static inline var EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT:String = 'EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT';

	public var tab:DisplayObject;
	public var forceClose:Bool = false;

	public function new(type:String, targetEditor:DisplayObject, forceClose:Bool = false) {
		this.tab = targetEditor;
		this.forceClose = forceClose;

		super(type, false, false);
	}

}