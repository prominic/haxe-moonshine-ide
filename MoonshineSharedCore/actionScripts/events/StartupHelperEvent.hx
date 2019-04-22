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
package actionScripts.events;

import flash.events.Event;

class StartupHelperEvent extends Event {

	public static inline var EVENT_TYPEAHEAD_REQUIRES_SDK:String = 'EVENT_TYPEAHEAD_REQUIRES_SDK';
	public static inline var EVENT_SDK_SETUP_REQUEST:String = 'EVENT_SDK_SETUP_REQUEST';
	public static inline var EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST:String = 'EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST';
	public static inline var EVENT_SDK_UNZIP_REQUEST:String = 'EVENT_SDK_UNZIP_REQUEST';
	public static inline var EVENT_RESTART_HELPING:String = 'EVENT_RESTART_HELPING';
	public static inline var EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION:String = 'EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION';
	public static inline var EVENT_DNS_GETTING_STARTED:String = 'EVENT_DNS_GETTING_STARTED';

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, _bubble:Bool = false, _cancelable:Bool = true) {
		this.value = value;
		super(type, _bubble, _cancelable);
	}

}