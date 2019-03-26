package actionScripts.utils;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.StartupHelperEvent;
import actionScripts.valueObjects.HelperConstants;
class SDKInstallerPolling extends EventDispatcher {

	public var notifierFileLocation(get, never):File;

	private static var instance:SDKInstallerPolling;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var pollingTimer:Timer;

	private var _notifierFileLocation:File = File.applicationStorageDirectory.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);

	private function get_notifierFileLocation():File {
		return _notifierFileLocation;
	}

	public static function getInstance():SDKInstallerPolling {
		if (instance == null) {
			instance = new SDKInstallerPolling();
		}
		return instance;
	}

	public function startPolling():Void {
		stopPolling();

		pollingTimer = new Timer(10000);
		pollingTimer.addEventListener(TimerEvent.TIMER, onPollTimerTick);
		pollingTimer.start();
		onPollTimerTick(null);
	}

	public function stopPolling():Void {
		if (pollingTimer != null && pollingTimer.running) {
			pollingTimer.stop();
			pollingTimer.removeEventListener(TimerEvent.TIMER, onPollTimerTick);
			pollingTimer = null;
		}
	}

	private function onPollTimerTick(event:TimerEvent):Void {
		if (notifierFileLocation.exists) {
			dispatcher.dispatchEvent(new StartupHelperEvent(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION));
		}
	}

	public function new() {
		super();
	}

}