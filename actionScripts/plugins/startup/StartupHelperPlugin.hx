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

import actionScripts.events.SdkEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import mx.core.FlexGlobals;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.HelperEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.StartupHelperEvent;
import actionScripts.factory.FileLocation;
import actionScripts.impls.IHelperMoonshineBridgeImp;
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
import actionScripts.valueObjects.SDKTypes;
import components.popup.GettingStartedPopup;
import components.popup.JavaPathSetupPopup;
import components.popup.SDKUnzipConfirmPopup;
class StartupHelperPlugin extends PluginBase implements IPlugin {

	private var isAllDependenciesPresent(get, set):Bool;

	override private function get_name():String {
		return 'Startup Helper Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Startup Helper Plugin. Esc exits.';
	}

	public static inline var EVENT_GETTING_STARTED:String = 'gettingStarted';

	private static inline var SDK_XTENDED:String = 'SDK_XTENDED';

	private static inline var CC_JAVA:String = 'CC_JAVA';

	private static inline var CC_SDK:String = 'CC_SDK';

	private static inline var CC_ANT:String = 'CC_ANT';

	private static inline var CC_MAVEN:String = 'CC_MAVEN';

	private static inline var CC_GIT:String = 'CC_GIT';

	private static inline var CC_SVN:String = 'CC_SVN';

	private var dependencyCheckUtil:IHelperMoonshineBridgeImp = new IHelperMoonshineBridgeImp();

	private var sdkNotificationView:SDKUnzipConfirmPopup;

	private var ccNotificationView:JavaPathSetupPopup;

	private var gettingStartedPopup:GettingStartedPopup;

	private var environmentUtil:EnvironmentUtils;

	private var sequences:Array<Dynamic>;

	private var isSDKSetupShowing:Bool;

	private var javaSetupPathTimeout:Int;

	private var startHelpingTimeout:Int;

	private var changeMenuSDKTimeout:Int;

	private var didShowPreviouslyOpenedTabs:Bool;

	private var _isAllDependenciesPresent:Bool = true;

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
		if (!ConstantsCoreVO.IS_AIR) {
			return;
		}

		dispatcher.addEventListener(StartupHelperEvent.EVENT_RESTART_HELPING, onRestartRequest, false, 0, true);
		dispatcher.addEventListener(EVENT_GETTING_STARTED, onGettingStartedRequest, false, 0, true);
		dispatcher.addEventListener(HelperConstants.WARNING, onWarningUpdated, false, 0, true);
		dispatcher.addEventListener(InvokeEvent.INVOKE, onInvokeEventFired, false, 0, true);

		// event listner to open up #sdk-extended from File in OSX
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_SETUP_REQUEST, onSDKSetupRequest, false, 0, true);
			dispatcher.addEventListener(StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST, onMoonshineHelperDownloadRequest, false, 0, true);
		}

		preInitHelping();
	}

	override public function resetSettings():Void {
		if (gettingStartedPopup != null) {
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, gettingStartedPopup));
		}
	}

	/**
	 * Pre-initialization helping process
	 */
	private function preInitHelping():Void {
		as3hx.Compat.clearTimeout(startHelpingTimeout);
		sequences = [SDK_XTENDED, CC_JAVA, CC_SDK, CC_ANT, CC_MAVEN, CC_GIT, CC_SVN];

		// env.variable parsing only available for Windows
		if (!ConstantsCoreVO.IS_MACOS) {
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

		if (sequences.length == 0)
		// if we have a reason to open Getting Started tab
		{

			if (!isAllDependenciesPresent) {
				openOrFocusGettingStarted();
			}
			return;
		}

		var tmpSequence:String = sequences.shift();
		switch (tmpSequence) {
			case SDK_XTENDED:
			{
				checkDefaultSDK();
			}
			case CC_JAVA:
			{
				checkJavaPathPresenceForTypeahead();
			}
			case CC_SDK:
			{
				checkSDKPrsenceForTypeahead();
			}
			case CC_ANT:
			{
				checkAntPathPresence();
			}
			case CC_MAVEN:
			{
				checkMavenPathPresence();
			}
			case CC_GIT:
			{
				checkGitPathPresence();
			}
			case CC_SVN:
			{
				checkSVNPathPresence();
			}
		}

		if (!didShowPreviouslyOpenedTabs) {
			didShowPreviouslyOpenedTabs = true;
			var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
						as3hx.Compat.clearTimeout(timeoutValue);
						dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS));
					}, 2000);
		}
	}

	/**
	 * Checks default SDK to Moonshine
	 */
	private function checkDefaultSDK(forceShow:Bool = false):Void {
		var isPresent:Bool = dependencyCheckUtil.isDefaultSDKPresent();
		if (!isPresent && (!ConstantsCoreVO.IS_MACOS || (ConstantsCoreVO.IS_MACOS && (!ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS || forceShow))))
		//triggerSDKNotificationView(false, false);
		{

			// check if env.variable has any FLEX_HOME found or not
			if (environmentUtil != null && environmentUtil.environments.FLEX_HOME)
			// set as default SDK
			{

				PathSetupHelperUtil.updateFieldPath(SDKTypes.FLEX, environmentUtil.environments.FLEX_HOME.path.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		} else if (!isPresent)
		// lets show up the default sdk requirement strip at bottom
		{

			changeMenuSDKTimeout = as3hx.Compat.setTimeout(function():Void {
								as3hx.Compat.clearTimeout(changeMenuSDKTimeout);
								changeMenuSDKTimeout = 0;

								dispatcher.dispatchEvent(new Event(SdkEvent.CHANGE_SDK));
							}, 1000);
		}

		startHelping();
	}

	/**
	 * Checks code-completion Java presence
	 */
	private function checkJavaPathPresenceForTypeahead():Void {
		var isPresent:Bool = dependencyCheckUtil.isJavaPresent();
		if (!isPresent && ccNotificationView == null)
		// check if env.variable has JAVA_HOME with JDK setup
		{

			if (environmentUtil != null && environmentUtil.environments.JAVA_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.OPENJAVA, environmentUtil.environments.JAVA_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
				model.javaPathForTypeAhead = null;
			}
		}

		startHelping();
	}

	/**
	 * Checks code-completion sdk requisites
	 */
	private function checkSDKPrsenceForTypeahead():Void {
		var isPresent:Bool = dependencyCheckUtil.isDefaultSDKPresent();
		//var path:String = UtilsCore.checkCodeCompletionFlexJSSDK();
		if (!isPresent && ccNotificationView == null && !isSDKSetupShowing) {
			if (environmentUtil != null && environmentUtil.environments.JAVA_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.OPENJAVA, environmentUtil.environments.JAVA_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		} else if (!isPresent && isSDKSetupShowing) {
			isAllDependenciesPresent = false;
			showNoSDKStripAndListenForDefaultSDK();
		} else if (isPresent && dependencyCheckUtil.isJavaPresent())
		// starting server
		{

			dispatcher.addEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK, onTypeaheadFailedDueToSDK);
		}

		startHelping();
	}

	/**
	 * Checks internal Ant path
	 */
	private function checkAntPathPresence():Void {
		if (!dependencyCheckUtil.isAntPresent()) {
			if (environmentUtil != null && environmentUtil.environments.ANT_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.ANT, environmentUtil.environments.ANT_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		}

		startHelping();
	}

	/**
	 * Checks internal Maven path
	 */
	private function checkMavenPathPresence():Void {
		if (!dependencyCheckUtil.isMavenPresent()) {
			if (environmentUtil != null && environmentUtil.environments.MAVEN_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.MAVEN, environmentUtil.environments.MAVEN_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		}

		startHelping();
	}

	/**
	 * Checks internal Git path
	 */
	private function checkGitPathPresence():Void {
		if (!dependencyCheckUtil.isGitPresent()) {
			if (environmentUtil != null && environmentUtil.environments.GIT_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.GIT, environmentUtil.environments.GIT_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		}

		startHelping();
	}

	/**
	 * Checks internal SVN path
	 */
	private function checkSVNPathPresence():Void {
		if (!dependencyCheckUtil.isSVNPresent()) {
			if (environmentUtil != null && environmentUtil.environments.SVN_HOME) {
				PathSetupHelperUtil.updateFieldPath(SDKTypes.SVN, environmentUtil.environments.SVN_HOME.nativePath);
			} else {
				isAllDependenciesPresent = false;
			}
		}

		startHelping();
	}

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
	private function showNoSDKStripAndListenForDefaultSDK():Void
	// lets show up the default sdk requirement strip at bottom
	 {

		// at very end of startup prompt being shown
		dispatcher.dispatchEvent(new Event(SdkEvent.CHANGE_SDK));
		// in case of Windows, we open-up MXMLC Plugin section and shall
		// wait for the user to add/download a default SDK
		//sequenceIndex --;
		dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
	}

	private function continueOnHelping():Void
	// just a little delay to see things visually right
	 {

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

	//--------------------------------------------------------------------------
	//
	//  LISTENERS API
	//
	//--------------------------------------------------------------------------
	private function onEnvironmentVariableReadError(event:HelperEvent):Void {
		error('Unable to read environment variable: ' + (Std.string(event.value)));
		continueOnHelping();
	}

	private function onEnvironmentVariableReadCompleted(event:Event):Void {
		continueOnHelping();
	}

	/**
	 * To restart helping process
	 */
	private function onRestartRequest(event:StartupHelperEvent):Void {
		sdkNotificationView = null;
		ccNotificationView = null;
		sequences = null;
		isSDKSetupShowing = false;
		ConstantsCoreVO.IS_OSX_CODECOMPLETION_PROMPT = false;

		preInitHelping();
	}

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
					new AddTabEvent(try cast(gettingStartedPopup, IContentWindow) catch (e:Dynamic) null)
			);
		} else {
			model.activeEditor = gettingStartedPopup;
		}
	}

	/**
	 * On getting started closed
	 */
	private function onGettingStartedClosed(event:Event):Void
	// polling only in case of Windows
	 {

		togglePolling(false);

		gettingStartedPopup.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed);
		gettingStartedPopup = null;
	}

	/**
	 * Start/remove Windows polling
	 */
	private function togglePolling(start:Bool):Void {
		if (!ConstantsCoreVO.IS_MACOS) {
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

	/**
	 * On SDK notification prompt close
	 */
	private function onSDKNotificationClosed(event:Event):Void {
		var wasShowingAsHelperDownloaderOnly:Bool = sdkNotificationView.showAsHelperDownloader;

		sdkNotificationView.removeEventListener(Event.CLOSE, onSDKNotificationClosed);
		FlexGlobals.topLevelApplication.removeElement(sdkNotificationView);

		var isSDKSetupSectionOpened:Bool = sdkNotificationView.isSDKSetupSectionOpened;
		sdkNotificationView = null;

		if (wasShowingAsHelperDownloaderOnly) {
			return;
		}

		// restart rest of the checkings
		if (!isSDKSetupSectionOpened) {
			startHelping();
		}
		// in case of Windows, we open-up MXMLC Plugin section and shall
		else {

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

		var isDiscardedCodeCompletionProcedure:Bool = ccNotificationView.isDiscarded;
		var showAsRequiresSDKNotif:Bool = ccNotificationView.showAsRequiresSDKNotification;
		isSDKSetupShowing = ccNotificationView.isSDKSetupShowing;
		ccNotificationView = null;

		// restart rest of the checkings
		if (!isDiscardedCodeCompletionProcedure) {
			startHelping();
		} else if (!model.defaultSDK && (isDiscardedCodeCompletionProcedure || showAsRequiresSDKNotif)) {
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
			var tmpEvent:CloseTabEvent = try cast(event, CloseTabEvent) catch (e:Dynamic) null;
			if ((Std.is(tmpEvent.tab, SettingsView)) && (cast((tmpEvent.tab), SettingsView).longLabel == 'Settings') && cast((tmpEvent.tab), SettingsView).isSaved) {
				dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
				startHelping();
			}
		}
	}

	/**
	 * On helper application download requrest from File menu
	 * in OSX
	 */
	private function onSDKSetupRequest(event:StartupHelperEvent):Void
	//sequenceIndex = -1;
	 {

		checkDefaultSDK(true);
	}

	/**
	 * On Moonshine App Store Helper request from top menu
	 */
	private function onMoonshineHelperDownloadRequest(event:Event):Void {
		triggerSDKNotificationView(true, false);
	}

	private function copyToLocalStoragePayaraEmbededLauncher():Void {
		var payaraLocation:String = 'elements'.concat(model.fileCore.separator, 'projects', model.fileCore.separator, 'PayaraEmbeddedLauncher');
		var payaraAppPath:FileLocation = model.fileCore.resolveApplicationDirectoryPath(payaraLocation);
		model.payaraServerLocation = model.fileCore.resolveApplicationStorageDirectoryPath('projects'.concat(model.fileCore.separator, 'PayaraEmbeddedLauncher'));
		try {
			payaraAppPath.fileBridge.copyTo(model.payaraServerLocation, true);
		} catch (e:Error) {
			warning('Problem with updating PayaraEmbeddedLauncher %s', e.message);
		}
	}

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
		if (updateNotifierFile.fileBridge.exists) {
			var type:String;
			var path:String;
			var pathValidation:String;
			var notifierValue:FastXML = new FastXML(Std.string(updateNotifierFile.fileBridge.read()));
			for (item /* AS3HX WARNING could not determine type for var: item exp: EField(EField(EIdent(notifierValue),items),item) type: null */ in notifierValue.nodes.items.node.item.innerData) {
				type = Std.string(item.att.type);
				path = Std.string(item.path);
				pathValidation = Std.string(item.pathValidation);

				// validate before set
				if (type == ComponentTypes.TYPE_GIT || type == ComponentTypes.TYPE_SVN) {
					pathValidation = null;
				}
				if (!HelperUtils.isValidSDKDirectoryBy(type, path, pathValidation)) {
					continue;
				}

				if ((type == ComponentTypes.TYPE_GIT || type == ComponentTypes.TYPE_SVN) && ConstantsCoreVO.IS_MACOS) {
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
		if (gettingStartedPopup == null) {
			dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
		} else {
			gettingStartedPopup.onWarningUpdate(event);
		}
	}

	/**
	 * Multiple component update requirement
	 */
	private function updateGitAndSVN(path:String):Void {
		var gitComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
		var svnComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
		if (gettingStartedPopup == null) {
			PathSetupHelperUtil.updateFieldPath(ComponentTypes.TYPE_GIT, path);
			PathSetupHelperUtil.updateFieldPath(ComponentTypes.TYPE_SVN, path);
		} else {
			gettingStartedPopup.onInvokeEvent(ComponentTypes.TYPE_GIT, path);
			gettingStartedPopup.onInvokeEvent(ComponentTypes.TYPE_SVN, path);
		}
	}

	public function new() {
		super();
	}

}