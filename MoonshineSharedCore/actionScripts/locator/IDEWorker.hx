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
package actionScripts.locator;

import flash.errors.Error;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import actionScripts.events.GeneralEvent;
import actionScripts.interfaces.IWorkerSubscriber;

class IDEWorker extends EventDispatcher {

	public static inline var WORKER_VALUE_INCOMING:String = 'WORKER_VALUE_INCOMING';

	@:meta(Embed(source = '/elements/swf/MoonshineWorker.swf', mimeType = 'application/octet-stream'))
	private static var WORKER_SWF:Class<Dynamic>;
	private static var instance:IDEWorker;

	private var mainToWorker:MessageChannel;
	private var workerToMain:MessageChannel;
	private var worker:Worker;
	private var individualSubscriptions:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var incomingData:Dynamic;

	public static function getInstance():IDEWorker {
		if (instance == null) {
			instance = new IDEWorker();
			instance.initWorker();
		}

		return instance;
	}

	public function initWorker():Void {
		var workerBytes:ByteArray = (try cast(Type.createInstance(WORKER_SWF, []), ByteArray) catch(e:Dynamic) null);
		worker = WorkerDomain.current.createWorker(workerBytes, true);

		// send to worker
		mainToWorker = Worker.current.createMessageChannel(worker);
		worker.setSharedProperty('mainToWorker', mainToWorker);

		// receive from worker
		workerToMain = worker.createMessageChannel(Worker.current);
		workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
		worker.setSharedProperty('workerToMain', workerToMain);
		worker.start();
	}

	public function subscribeAsIndividualComponent(udid:String, anyClass:Dynamic):Void {
		individualSubscriptions.set(udid, anyClass);
	}

	public function unSubscribeComponent(udid:String):Void {
		if (individualSubscriptions.get(udid) != null) {
			individualSubscriptions.remove(udid);
		}
	}

	public function sendToWorker(type:String, value:Dynamic, subscriberUdid:String = null):Void {
		mainToWorker.send({
					'event': type,
					'value': value,
					'subscriberUdid': subscriberUdid
				});
	}

	private function onWorkerToMain(event:Event):Void {
		incomingData = workerToMain.receive();
		if (Reflect.hasField(incomingData, 'subscriberUdid') &&
			individualSubscriptions.get(Reflect.field(incomingData, 'subscriberUdid')) != null) {
			try {
				(AS3.as(individualSubscriptions.get(Reflect.field(incomingData, 'subscriberUdid')), IWorkerSubscriber)).onWorkerValueIncoming(incomingData);
			} catch (e:Error) {}
		} else {
			dispatchEvent(new GeneralEvent(WORKER_VALUE_INCOMING, incomingData));
		}
	}

	public function new() {
		super();
	}

}