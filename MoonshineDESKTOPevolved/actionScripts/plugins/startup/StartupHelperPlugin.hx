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
package actionScripts.plugins.startup;

import flash.errors.Error;
import flash.events.Event;
import flash.events.InvokeEvent;
import mx.core.FlexGlobals;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.HelperEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SdkEvent;
import actionScripts.events.StartupHelperEvent;
import actionScripts.factory.FileLocation;
import actionScripts.impls.IHelperMoonshineBridgeImp;
import actionScripts.managers.InstallerItemsManager;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.plugins.git.GitHubPlugin;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.EnvironmentUtils;
import actionScripts.utils.HelperUtils;
import actionScripts.utils.PathSetupHelperUtil;
import actionScripts.utils.SDKInstallerPolling;
import actionScripts.valueObjects.ComponentTypes;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.HelperConstants;
import actionScripts.valueObjects.SDKReferenceVO;
import actionScripts.valueObjects.SDKTypes;
import components.popup.GettingStartedPopup;
import components.popup.JavaPathSetupPopup;
import components.popup.SDKUnzipConfirmPopup;

class StartupHelperPlugin extends PluginBase implements IPlugin {

	override private function get_name():String {
		return 'Startup Helper Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Startup Helper Plugin. Esc exits.';
	}

	public static inline var EVENT_GETTING_STARTED:String = 'gettingStarted';

	private var dependencyCheckUtil:IHelperMoonshineBridgeImp = new IHelperMoonshineBridgeImp();
	private var installerItemsManager:InstallerItemsManager = InstallerItemsManager.getInstance();
	private var sdkNotificationView:SDKUnzipConfirmPopup;
	private var ccNotificationView:JavaPathSetupPopup;
	private var gettingStartedPopup:GettingStartedPopup;
	private var environmentUtil:EnvironmentUtils;
	private var isSDKSetupShowing:Bool = false;

	private var javaSetupPathTimeout:Int = 0;
	private var startHelpingTimeout:Int = 0;
	private var didShowPreviouslyOpenedTabs:Bool = false;

	private var _isAllDependenciesPresent:Bool = true;

	private var isAllDependenciesPresent(get, set):Bool;
	private function set_isAllDependenciesPresent(value:Bool):Bool {
		_isAllDependenciesPresent = value;
		return value;
	}

	private function get_isAllDependenciesPresent():Bool {
		return _isAllDependenciesPresent;
	}

	/**
	 * INITIATOR
	 */
	override public function activate():Void {
		super.activate();

		// we want this to be work in desktop version only
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			return;
		}

		dispatcher.addEventListener(StartupHelperEvent.EVENT_RESTART_HELPING, onRestartRequest, false, 0, true);
		dispatcher.addEventListener(EVENT_GETTING_STARTED, onGettingStartedRequest, false, 0, true);
		dispatcher.addEventListener(HelperConstants.WARNING, onWarningUpdated, false, 0, true);
		dispatcher.addEventListener(InvokeEvent.INVOKE, onInvokeEventFired, false, 0, true);

		// event listner to open up #sdk-extended from File in OSX
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			//dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_SETUP_REQUEST, onSDKSetupRequest, false, 0, true);
			dispatcher.addEventListener(StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST, onMoonshineHelperDownloadRequest, false, 0, true);
		}

		preInitHelping();
	}

	override public function resetSettings():Void {
		if (gettingStartedPopup != null) {
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, gettingStartedPopup));
		}
	}

	//--------------------------------------------------------------------------
	//
	//  SDKs DETECTION AND RELATED
	//
	//--------------------------------------------------------------------------

	/**
	 * Pre-initialization helping process
	 */
	private function preInitHelping():Void {
		as3hx.Compat.clearTimeout(startHelpingTimeout);

		// env.variable parsing only available for Windows
		if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			environmentUtil = new EnvironmentUtils();
			addEventListenersToEnvironmentUtil();
			environmentUtil.readValues();
		} else {
			continueOnHelping();
		}
	}

	/**
	 * Starts the checks and starup sequences
	 * to setup SDK, Java etc.
	 */
	private function startHelping():Void {
		as3hx.Compat.clearTimeout(startHelpingTimeout);
		startHelpingTimeout = 0;

		toggleListenersInstallerItemsManager(true);

		HelperConstants.IS_MACOS = ConstantsCoreVO.IS_MACOS;
		installerItemsManager.dependencyCheckUtil = dependencyCheckUtil;
		installerItemsManager.environmentUtil = environmentUtil;
		installerItemsManager.loadItemsAndDetect();

		if (!didShowPreviouslyOpenedTabs) {
			didShowPreviouslyOpenedTabs = true;
			var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
						as3hx.Compat.clearTimeout(timeoutValue);
						dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS));
					}, 2000);
		}
	}

	/**
	 * On any items found not installed by the installer
	 */
	private function onComponentNotDownloadedEvent(event:HelperEvent):Void {
		isAllDependenciesPresent = false;
		onPostDetectionEvent(AS3.as(event.value, ComponentVO));
	}

	private function onAnyComponentDownloaded(event:HelperEvent):Void {
		// autoset moonshine internal fields as appropriate
		var component:ComponentVO = AS3.as(event.value, ComponentVO);
		PathSetupHelperUtil.updateFieldPath(Std.string(component.type), Std.string(component.installToPath));
		onPostDetectionEvent(component);
	}

	/**
	 * When all the items complete testing by the installer
	 */
	private function onAllComponentTestedEvent(event:HelperEvent):Void {
		toggleListenersInstallerItemsManager(false);
		checkDefaultSDK();

		if (!isAllDependenciesPresent && !AS3.as(ConstantsCoreVO.IS_GETTING_STARTED_DNS, Bool)) {
			openOrFocusGettingStarted();
		}
	}

	/**
	 * Post-detection event against individual
	 * component tested by sdk installer
	 */
	private function onPostDetectionEvent(item:ComponentVO):Void {
		var isPresent:Bool;
		switch (item.type) {
			case ComponentTypes.TYPE_FLEX, ComponentTypes.TYPE_FEATHERS, ComponentTypes.TYPE_FLEXJS, ComponentTypes.TYPE_ROYALE:
				isPresent = dependencyCheckUtil.isDefaultSDKPresent();
				if (!isPresent) {
					isAllDependenciesPresent = false;
					showNoSDKStripAndListenForDefaultSDK();
				}
			case ComponentTypes.TYPE_OPENJAVA:
				isPresent = dependencyCheckUtil.isJavaPresent();
				if (isPresent && !AS3.as(dispatcher.hasEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK), Bool)) {
					// starting server
					dispatcher.addEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK, onTypeaheadFailedDueToSDK);
				}
		}
	}

	/**
	 * Checks default SDK to Moonshine
	 */
	private function checkDefaultSDK():Void {
		function checkAndSetDefaultSDKObject(value:Dynamic, type:String):Bool {
			if (AS3.as(value, Bool)) {
				PathSetupHelperUtil.updateFieldPath(type, Std.string((AS3.as(value, SDKReferenceVO)).path));
				return true;
			}
			return false;
		};
		var isPresent:Bool = dependencyCheckUtil.isDefaultSDKPresent(); /*
		* @local
		*/
		if (!isPresent) {
			// in case of no default sdk set by
			// sdk installer default location or system
			// environment variable, and if a relevant sdk
			// exists in sdk-list, set it
			if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFlexSDKAvailable(), Std.string(SDKTypes.FLEX))) {
				return;
			}
			if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFlexJSSDKAvailable(), Std.string(SDKTypes.FLEXJS))) {
				return;
			}
			if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isRoyaleSDKAvailable(), Std.string(SDKTypes.ROYALE))) {
				return;
			}
			if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFeathersSDKAvailable(), Std.string(SDKTypes.FEATHERS))) {
				return;
			}
		}
	}

	/**
	 * Add or remove listeners from itemsManager
	 */
	private function toggleListenersInstallerItemsManager(toggle:Bool):Void {
		if (toggle) {
			installerItemsManager.addEventListener(HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded);
			installerItemsManager.addEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
			installerItemsManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
		} else {
			installerItemsManager.removeEventListener(HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded);
			installerItemsManager.removeEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
			installerItemsManager.removeEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
		}
	}

	private function continueOnHelping():Void {
		// just a little delay to see things visually right
		removeEventListenersFromEnvironmentUtil();
		startHelpingTimeout = as3hx.Compat.setTimeout(startHelping, 1000);
		copyToLocalStoragePayaraEmbededLauncher();
	}

	private function addEventListenersToEnvironmentUtil():Void {
		environmentUtil.addEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvironmentVariableReadCompleted);
		environmentUtil.addEventListener(EnvironmentUtils.ENV_READ_ERROR, onEnvironmentVariableReadError);
	}

	private function removeEventListenersFromEnvironmentUtil():Void {
		if (environmentUtil == null) {
			return;
		}

		environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvironmentVariableReadCompleted);
		environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_ERROR, onEnvironmentVariableReadError);
	}

	private function onEnvironmentVariableReadError(event:HelperEvent):Void {
		error('Unable to read environment variable: ' + (Std.string(event.value)));
		continueOnHelping();
	}

	private function onEnvironmentVariableReadCompleted(event:Event):Void {
		continueOnHelping();
	}

	//--------------------------------------------------------------------------
	//
	//  GETTING-STARTED TAB
	//
	//--------------------------------------------------------------------------

	/**
	 * On getting started menu item
	 */
	private function onGettingStartedRequest(event:Event):Void {
		openOrFocusGettingStarted();
		startHelpingTimeout = as3hx.Compat.setTimeout(preInitHelping, 300);
	}

	/**
	 * Opens or focus Getting Started tab
	 */
	private function openOrFocusGettingStarted():Void {
		if (gettingStartedPopup == null) {
			gettingStartedPopup = new GettingStartedPopup();
			gettingStartedPopup.dependencyCheckUtil = dependencyCheckUtil;
			gettingStartedPopup.environmentUtil = environmentUtil;
			gettingStartedPopup.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed, false, 0, true);

			// start polling only in case of Windows
			togglePolling(true);
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(AS3.as(gettingStartedPopup, IContentWindow))
			);
		} else {
			model.activeEditor = gettingStartedPopup;
		}
	}

	/**
	 * On getting started closed
	 */
	private function onGettingStartedClosed(event:Event):Void {
		// polling only in case of Windows
		togglePolling(false);

		gettingStartedPopup.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed);
		gettingStartedPopup = null;
	}

	/**
	 * Start/remove Windows polling
	 */
	private function togglePolling(start:Bool):Void {
		if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			if (start) {
				dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION, onInstallerFileNotifierFound, false, 0, true);
				SDKInstallerPolling.getInstance().startPolling();
			} else {
				dispatcher.removeEventListener(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION, onInstallerFileNotifierFound);
				SDKInstallerPolling.getInstance().stopPolling();

				gettingStartedPopup.dispose();
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//  GETTING-STARTED UPDATE API
	//
	//--------------------------------------------------------------------------

	/**
	 * In case of polling only on Windows
	 */
	private function onInstallerFileNotifierFound(event:StartupHelperEvent):Void {
		onInvokeEventFired(null);
	}

	/**
	 * To listen updates from SDK Installer
	 */
	private function onInvokeEventFired(event:InvokeEvent):Void {
		var updateNotifierFile:FileLocation = model.fileCore.resolveApplicationStorageDirectoryPath('MoonshineHelperNewUpdate.xml');
		if (AS3.as(updateNotifierFile.fileBridge.exists, Bool)) {
			var type:String;
			var path:String;
			var pathValidation:String;
			var notifierValue:FastXML = new FastXML(Std.string(updateNotifierFile.fileBridge.read()));
			for (item in notifierValue.nodes.items.descendants('item')) {
				type = Std.string(item.att.type);
				path = Std.string(item.descendants('path'));
				pathValidation = Std.string(item.descendants('pathValidation'));

				// validate before set
				if (type == Std.string(ComponentTypes.TYPE_GIT) || type == Std.string(ComponentTypes.TYPE_SVN)) {
					pathValidation = null;
				}
				if (!AS3.as(HelperUtils.isValidSDKDirectoryBy(type, path, pathValidation), Bool)) {
					continue;
				}

				if ((type == Std.string(ComponentTypes.TYPE_GIT) || type == Std.string(ComponentTypes.TYPE_SVN)) && AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
					updateGitAndSVN(path);
				} else if (gettingStartedPopup == null) {
					PathSetupHelperUtil.updateFieldPath(type, path);
				} else {
					gettingStartedPopup.onInvokeEvent(type, path);
				}
			}
		}
	}

	/**
	 * When getting warning updates
	 */
	private function onWarningUpdated(event:HelperEvent):Void {
		var tmpComponent:ComponentVO = HelperUtils.getComponentByType(event.value.type);
		tmpComponent.hasWarning = event.value.message;
	}

	/**
	 * Multiple component update requirement
	 */
	private function updateGitAndSVN(path:String):Void {
		var gitComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
		var svnComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
		if (gettingStartedPopup == null) {
			PathSetupHelperUtil.updateFieldPath(Std.string(ComponentTypes.TYPE_GIT), path);
			PathSetupHelperUtil.updateFieldPath(Std.string(ComponentTypes.TYPE_SVN), path);
		} else {
			gettingStartedPopup.onInvokeEvent(Std.string(ComponentTypes.TYPE_GIT), path);
			gettingStartedPopup.onInvokeEvent(Std.string(ComponentTypes.TYPE_SVN), path);
		}
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE API
	//
	//--------------------------------------------------------------------------

	/**
	 * Opening SDK notification prompt
	 */
	private function triggerSDKNotificationView(showAsDownloader:Bool, showAsRequiresSDKNotif:Bool):Void {
		sdkNotificationView = new SDKUnzipConfirmPopup();
		sdkNotificationView.showAsHelperDownloader = showAsDownloader;
		sdkNotificationView.horizontalCenter = sdkNotificationView.verticalCenter = 0;
		sdkNotificationView.addEventListener(Event.CLOSE, onSDKNotificationClosed, false, 0, true);
		FlexGlobals.topLevelApplication.addElement(sdkNotificationView);
	}

	/**
	 * Opens Java detection etc. for code-completion prompt
	 */
	private function triggerJavaSetupViewWithParam(showAsRequiresSDKNotif:Bool):Void {
		as3hx.Compat.clearTimeout(javaSetupPathTimeout);
		javaSetupPathTimeout = 0;

		ccNotificationView = new JavaPathSetupPopup();
		ccNotificationView.showAsRequiresSDKNotification = showAsRequiresSDKNotif;
		ccNotificationView.horizontalCenter = ccNotificationView.verticalCenter = 0;
		ccNotificationView.addEventListener(Event.CLOSE, onJavaPromptClosed, false, 0, true);
		FlexGlobals.topLevelApplication.addElement(ccNotificationView);
	}

	/**
	 * Showing no sdk strip at bottom and also listens for
	 * default SDK setup event
	 */
	private function showNoSDKStripAndListenForDefaultSDK():Void {
		// lets show up the default sdk requirement strip at bottom
		// at very end of startup prompt being shown
		dispatcher.dispatchEvent(new Event(Std.string(SdkEvent.CHANGE_SDK)));
		// in case of Windows, we open-up MXMLC Plugin section and shall
		// wait for the user to add/download a default SDK
		//sequenceIndex --;
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
	}

	/**
	 * To restart helping process
	 */
	private function onRestartRequest(event:StartupHelperEvent):Void {
		sdkNotificationView = null;
		ccNotificationView = null;
		isSDKSetupShowing = false;
		ConstantsCoreVO.IS_OSX_CODECOMPLETION_PROMPT = false;

		preInitHelping();
	}

	/**
	 * On SDK notification prompt close
	 */
	private function onSDKNotificationClosed(event:Event):Void {
		var wasShowingAsHelperDownloaderOnly:Bool = AS3.as(sdkNotificationView.showAsHelperDownloader, Bool);

		sdkNotificationView.removeEventListener(Event.CLOSE, onSDKNotificationClosed);
		FlexGlobals.topLevelApplication.removeElement(sdkNotificationView);

		var isSDKSetupSectionOpened:Bool = AS3.as(sdkNotificationView.isSDKSetupSectionOpened, Bool);
		sdkNotificationView = null;

		if (wasShowingAsHelperDownloaderOnly) {
			return;
		}

		// restart rest of the checkings
		if (!isSDKSetupSectionOpened) {
			startHelping();
		} else {
			// in case of Windows, we open-up MXMLC Plugin section and shall
			// wait for the user to add/download a default SDK
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
		}
	}

	/**
	 * On code-completion Java prompt close
	 */
	private function onJavaPromptClosed(event:Event):Void {
		ccNotificationView.removeEventListener(Event.CLOSE, onJavaPromptClosed);
		FlexGlobals.topLevelApplication.removeElement(ccNotificationView);

		var isDiscardedCodeCompletionProcedure:Bool = AS3.as(ccNotificationView.isDiscarded, Bool);
		var showAsRequiresSDKNotif:Bool = AS3.as(ccNotificationView.showAsRequiresSDKNotification, Bool);
		isSDKSetupShowing = AS3.as(ccNotificationView.isSDKSetupShowing, Bool);
		ccNotificationView = null;

		// restart rest of the checkings
		if (!isDiscardedCodeCompletionProcedure) {
			startHelping();
		} else if (!AS3.as(model.defaultSDK, Bool) && (isDiscardedCodeCompletionProcedure || showAsRequiresSDKNotif)) {
			showNoSDKStripAndListenForDefaultSDK();
		}
	}

	/**
	 * During code-completion server started and
	 * required SDK removed from SDK list
	 */
	private function onTypeaheadFailedDueToSDK(event:StartupHelperEvent):Void {
		triggerJavaSetupViewWithParam(true);
	}

	/**
	 * When settings tab closed after default SDK setup
	 * done in Windows process
	 */
	private function onSettingsTabClosed(event:Event):Void {
		if (Std.is(event, CloseTabEvent)) {
			var tmpEvent:CloseTabEvent = AS3.as(event, CloseTabEvent);
			if ((Std.is(tmpEvent.tab, SettingsView)) && (SettingsView(tmpEvent.tab).longLabel == 'Settings') && AS3.as(SettingsView(tmpEvent.tab).isSaved, Bool)) {
				dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
			}
		}
	}

	/**
	 * On helper application download requrest from File menu
	 * in OSX
	 */
	private function onSDKSetupRequest(event:StartupHelperEvent):Void {
		//sequenceIndex = -1;
		checkDefaultSDK();
	}

	/**
	 * On Moonshine App Store Helper request from top menu
	 */
	private function onMoonshineHelperDownloadRequest(event:Event):Void {
		triggerSDKNotificationView(true, false);
	}

	private function copyToLocalStoragePayaraEmbededLauncher():Void {
		var payaraLocation:String = Std.string('elements'.concat(model.fileCore.separator, 'projects', model.fileCore.separator, 'PayaraEmbeddedLauncher'));
		var payaraAppPath:FileLocation = model.fileCore.resolveApplicationDirectoryPath(payaraLocation);
		model.payaraServerLocation = model.fileCore.resolveApplicationStorageDirectoryPath('projects'.concat(model.fileCore.separator, 'PayaraEmbeddedLauncher'));
		try {
			payaraAppPath.fileBridge.copyTo(model.payaraServerLocation, true);
		} catch (e:Error) {
			warning('Problem with updating PayaraEmbeddedLauncher %s', e.message);
		}
	}

	public function new() {
		super();
	}

}