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
package actionScripts.ui.notifier;

import flash.events.TimerEvent;
import flash.utils.Timer;
import mx.containers.Canvas;
import mx.events.EffectEvent;
import components.views.notifier.ActionNotifyItem;

class ActionNotifier extends Canvas {

	private static var instance:ActionNotifier;

	public static function getInstance():ActionNotifier {
		if (instance == null) {
			instance = new ActionNotifier();
		}

		return instance;
	}

	private var showTimer:Timer;

	private var notifyQueue:Array<Dynamic> = [];

	private var isShowing:ActionNotifyItem;

	public function notify(about:String):Void {
		notifyQueue.push(about);
		checkQueue();
	}

	private function checkQueue(e:Dynamic = null):Void {
		if (isShowing != null) {
			return;
		}

		if (notifyQueue.length > 0) {
			showNew();
		}
	}

	private function showNew():Void {
		var item:ActionNotifyItem = new ActionNotifyItem();
		item.notifyText = Std.string(notifyQueue.pop());
		addChild(item);

		isShowing = item;

		showTimer = new Timer(500, 1);
		showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showDone);
		showTimer.start();
	}

	private function showDone(e:Dynamic = null):Void {
		if (isShowing.alpha == 1) {
			isShowing.removeEffect.addEventListener(EffectEvent.EFFECT_END, showDone);
			isShowing.removeEffect.play([isShowing]);
		} else {
			removeChild(isShowing);
			isShowing = null;
			checkQueue();
		}
	}

	public function new() {
		super();
	}

}