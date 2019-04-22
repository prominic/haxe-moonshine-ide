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
package actionScripts.plugins.as3project.mxmlc;

import actionScripts.locator.HelperModel;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.utils.EnvironmentUtils;
import com.adobe.utils.StringUtil;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.formats.TextDecoration;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.SdkEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.event.SetSettingsEvent;
import actionScripts.plugin.settings.providers.JavaSettingsProvider;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.plugins.build.CompilerPluginBase;
import actionScripts.plugins.swflauncher.SWFLauncherPlugin;
import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
import actionScripts.plugins.swflauncher.launchers.NativeExtensionExpander;
import actionScripts.ui.editor.text.DebugHighlightManager;
import actionScripts.utils.EnvironmentSetupUtils;
import actionScripts.utils.NoSDKNotifier;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.SDKReferenceVO;
import actionScripts.valueObjects.Settings;
import components.popup.SelectOpenedFlexProject;
import components.views.project.TreeView;
import org.as3commons.asblocks.utils.FileUtil;

class MXMLCPlugin extends CompilerPluginBase implements ISettingsProvider {

	override private function get_name():String {
		return 'Default SDK';
	}

	override private function get_author():String {
		return 'Miha Lunar & Moonshine Project Team';
	}

	override private function get_description():String {
		return Std.string(ResourceManager.getInstance().getString('resources', 'plugin.desc.mxmlc'));
	}

	public var incrementalCompile:Bool = true;
	private var runAfterBuild:Bool = false;
	private var debugAfterBuild:Bool = false;
	private var release:Bool = false;
	private var fcshPath:String = 'bin/fcsh';
	private var mxmlcPath:String = 'bin/mxmlc';
	private var cmdFile:File;
	private var _defaultFlexSDK:String;
	private var fcsh:NativeProcess;
	private var exiting:Bool = false;
	private var shellInfo:NativeProcessStartupInfo;
	private var isLibraryProject:Bool = false;

	private var lastTarget:File;
	private var targets:haxe.ds.ObjectMap<Dynamic, Dynamic>;
	private var isProjectHasInvalidPaths:Bool = false;

	private var currentSDK:File;

	/** Project currently under compilation */
	private var currentProject:ProjectVO;
	private var queue:Array<String> = new Array<String>();

	private var tempObj:Dynamic;
	private var fschstr:String;
	private var SDKstr:String;
	private var selectProjectPopup:SelectOpenedFlexProject;

	public var defaultFlexSDK(get, set):String;
	private function get_defaultFlexSDK():String {
		return _defaultFlexSDK;
	}

	private function set_defaultFlexSDK(value:String):String {
		_defaultFlexSDK = value;
		if (_defaultFlexSDK == '') {
			// check if any bundled SDK present or not
			// if present, make one default
			if (model.userSavedSDKs.length > 0 && Reflect.getProperty(model.userSavedSDKs, Std.string(0)).status == SDKUtils.BUNDLED) {
				_defaultFlexSDK = Std.string(Reflect.getProperty(model.userSavedSDKs, Std.string(0)).path);
				SDKUtils.setDefaultSDKByBundledSDK();
			} else {
				model.defaultSDK = null;
			}
		} else {
			for (i in as3hx.Compat.each(IDEModel.getInstance().userSavedSDKs)) {
				if (Reflect.field(i, 'path') == value) {
					model.defaultSDK = new FileLocation(Reflect.field(i, 'path'));
					model.noSDKNotifier.dispatchEvent(new Event(Std.string(NoSDKNotifier.SDK_SAVED)));
					break;
				}
			}

			// even if above condition do not made
			// check one more condition - this is particularly valid
			// if we have bundled SDKs and an old bundled SDK
			// references not found in newer bundled SDKs
			if (!AS3.as(model.defaultSDK, Bool)) {
				for (i in as3hx.Compat.each(IDEModel.getInstance().userSavedSDKs)) {
					if (Reflect.field(i, 'path') == value) {
						model.defaultSDK = new FileLocation(Reflect.field(i, 'path'));
						model.noSDKNotifier.dispatchEvent(new Event(Std.string(NoSDKNotifier.SDK_SAVED)));
						break;
					}
				}
			}

			// update project-to-sdk references once again
			for (project in as3hx.Compat.each(model.projects)) {
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project));
			}
		}

		if (AS3.as(model.defaultSDK, Bool)) {
			EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
		}
		// state change of menus based upon default SDK presence
		dispatcher.dispatchEvent(new Event(Std.string(SdkEvent.CHANGE_SDK)));
		return value;
	}

	public function new() {
		super();
		if (Settings.os == 'win') {
			fcshPath = 'fcsh_moonshine.bat';
			mxmlcPath += '.bat';
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		} else {
			cmdFile = new File('/bin/bash');
		}

		// @devsena
		// for some unknown reason activate() for this plugin
		// fail to run when 'revoke all access' in PKG run.
		// for now, I'm directing the access from here rather than
		// automated process, I shall need to check this later.
		activate();

		SDKUtils.initBundledSDKs();
	}

	override public function activate():Void {
		if (activated != null) {
			return;
		}

		super.activate();

		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, buildAndRun);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD, build);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_RELEASE, buildRelease);
		dispatcher.addEventListener(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, onDefaultSDKUpdatedOutside);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', buildCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Build the currently selected Flex project.');
		registerCommand('build', tempObj);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', runCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Build and run the currently selected Flex project.');
		registerCommand('run', tempObj);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', releaseCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Build the currently selected project in release mode.');
		Reflect.setField(tempObj, 'style', 'red');
		registerCommand('release', tempObj);

		reset();
	}

	override public function deactivate():Void {
		super.deactivate();

		reset();
		shellInfo = null;
	}

	override public function resetSettings():Void {
		var i:Int = 0;
		while (i < model.userSavedSDKs.length) {
			if (Reflect.getProperty(model.userSavedSDKs, Std.string(i)).status != SDKUtils.BUNDLED) {
				model.userSavedSDKs.removeItemAt(i);
				i--;
			}
			i++;
		}

		defaultFlexSDK = '';
		currentSDK = null;
		dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED));

		// reset java path
		model.javaPathForTypeAhead = null;
		new JavaSettingsProvider();
	}

	override private function onProjectPathsValidated(paths:Array<Dynamic>):Void {
		if (paths != null) {
			isProjectHasInvalidPaths = true;
			error('Following path(s) are invalid or does not exists:\n' + paths.join('\n'));
		}
	}

	public function getSettingsList():Array<ISetting> {
		return [
				new PathSetting(this, 'defaultFlexSDK', 'Default Apache Flex®, Apache Royale® or Feathers SDK', true, defaultFlexSDK, true),
				new BooleanSetting(this, 'incrementalCompile', 'Incremental Compilation'),
				new PathSetting(new JavaSettingsProvider(),
				'currentJavaPath',
				'Java Development Kit Path', true)
		];
	}

	private function buildCommand(args:Array<Dynamic>):Void {
		build(null, false);
	}

	private function runCommand(args:Array<Dynamic>):Void {
		build(null, true);
	}

	private function releaseCommand(args:Array<Dynamic>):Void {
		build(null, false, true);
	}

	private function reset():Void {
		stopShell();
		resourceCopiedIndex = 0;
		targets = new Dictionary();
	}

	private function onDefaultSDKUpdatedOutside(event:ProjectEvent):Void {
		// @note
		// basically requires to listen to update in
		// Flex SDKs window
		var tmpRef:SDKReferenceVO = AS3.as(event.anObject, SDKReferenceVO);
		if (tmpRef == null) {
			return;
		}
		defaultFlexSDK = Std.string(tmpRef.path);

		var thisSettings:Array<ISetting> = cast getSettingsList();
		var pathSettingToDefaultSDK:PathSetting = AS3.as(thisSettings[0], PathSetting);
		pathSettingToDefaultSDK.stringValue = defaultFlexSDK;
		dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, 'actionScripts.plugins.as3project.mxmlc::MXMLCPlugin', thisSettings));
	}

	private function buildAndRun(e:Event):Void {
		function reDebugConfirmClickHandler(event:CloseEvent):Void {
			if (event.detail == Alert.YES) {
				dispatcher.dispatchEvent(new Event(Std.string(ActionScriptBuildEvent.TERMINATE_EXECUTION)));
				as3hx.Compat.setTimeout(function():Void {
							dispatcher.dispatchEvent(e);
						}, 500);
			}
		}; /*
		 * @local
		 */
		// re-check in case of debug call and its already running
		if (e.type == Std.string(ActionScriptBuildEvent.BUILD_AND_DEBUG) && AS3.as(DebugHighlightManager.IS_DEBUGGER_CONNECTED, Bool)) {
			Alert.show('You are already debugging an application. Do you wish to terminate the existing debugging session and start a new session?', 'Debug Warning', Alert.YES | Alert.CANCEL, AS3.as(FlexGlobals.topLevelApplication, Sprite), reDebugConfirmClickHandler);
		} else {
			build(e, true);
		}
	}

	private function buildRelease(e:Event):Void {
		SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
		build(e, false, true);
	}

	private function sdkSelected(event:Event):Void {
		sdkSelectionCancelled(null);
		// update swf version if a newer SDK now saved than previously saved one
		AS3ProjectVO(currentProject).swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
		// continue with waiting build process again
		proceedWithBuild(currentProject);
	}

	private function sdkSelectionCancelled(event:Event):Void {
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
	}

	private function build(e:Event, runAfterBuild:Bool = false, release:Bool = false):Void {
		if (e != null && e.type == Std.string(ActionScriptBuildEvent.BUILD_AND_DEBUG)) {
			this.debugAfterBuild = true;
			SWFLauncherPlugin.RUN_AS_DEBUGGER = true;
		} else {
			this.debugAfterBuild = false;
			SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
		}

		this.isProjectHasInvalidPaths = false;
		this.runAfterBuild = runAfterBuild;
		this.release = release;
		buildStart();
	}

	private function buildStart():Void {
		function onProjectSelected(event:Event):Void {
			checkForUnsavedEdior(selectProjectPopup.selectedProject);
			onProjectSelectionCancelled(null);
		};
		function checkForUnsavedEdior(activeProject:ProjectVO):Void {
			model.activeProject = activeProject;
			UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
		}; /*
		* @local
		*/
		// check if there is multiple projects were opened in tree view
		if (model.projects.length > 1) {
			// check if user has selection/select any particular project or not
			if (AS3.as(model.mainView.isProjectViewAdded, Bool)) {
				var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
				var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
				if (projectReference != null) {
					checkForUnsavedEdior(projectReference);
					return;
				}
			}
			// if above is false
			selectProjectPopup = new SelectOpenedFlexProject();
			PopUpManager.addPopUp(selectProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
			PopUpManager.centerPopUp(selectProjectPopup);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		} else if (model.projects.length != 0) {
			checkForUnsavedEdior(AS3.as(Reflect.getProperty(model.projects, Std.string(0)), ProjectVO));
		} /*
		* check for unsaved File
		*/

		var onProjectSelectionCancelled:Event->Void = function(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		}
	}

	private function proceedWithBuild(activeProject:ProjectVO = null):Void {
		// Don't compile if there is no project. Don't warn since other compilers might take the job.
		if (activeProject == null) {
			activeProject = model.activeProject;
		}
		if (activeProject == null || !(Std.is(activeProject, AS3ProjectVO))) {
			return;
		}

		reset();

		var as3Pvo:AS3ProjectVO = AS3.as(activeProject, AS3ProjectVO);
		isLibraryProject = AS3.as(as3Pvo.isLibraryProject, Bool);
		if (as3Pvo.targets.length == 0 && !AS3.as(as3Pvo.isLibraryProject, Bool)) {
			error('No targets found for compilation.');
			return;
		}

		checkProjectForInvalidPaths(as3Pvo);
		if (isProjectHasInvalidPaths) {
			return;
		}

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			// before proceed, check file access dependencies
			if (!AS3.as(OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([as3Pvo]), 'Access Manager - Build Halt!'), Bool)) {
				Alert.show('Please fix the dependencies before build.', 'Error!');
				return;
			}
		}

		UtilsCore.checkIfRoyaleApplication(as3Pvo);

		// Read file content to indentify the project type regular flex application or flexjs applicatino
		if (AS3.as(as3Pvo.isFlexJS, Bool)) {
			if (AS3.as(as3Pvo.isRoyale, Bool)) {
				var tmpSDKLocation:FileLocation = UtilsCore.getCurrentSDK(AS3.as(as3Pvo, AS3ProjectVO));
				var sdkReference:SDKReferenceVO = SDKUtils.getSDKReference(tmpSDKLocation);
				if (sdkReference != null && AS3.as(sdkReference.isJSOnlySdk, Bool)) {
					error('This SDK only supports JavaScript Builds.');
					return;
				}

				if (!AS3.as(sdkReference.hasPlayerglobal, Bool) && !AS3.as(HelperModel.getInstance().moonshineBridge.playerglobalExists, Bool)) {
					displayPlayerGlobalError(sdkReference);
					return;
				}
			}

			// terminate if it's a debug call against FlexJS
			if (debugAfterBuild) {
				Alert.show('Moonshine does not currently support Apache Royale® project debugging.', 'Note!');
				return;
			}

			// FlexJS Application
			compileFlexJSApplication(activeProject, release);
		}//Regular application
		else {
			//Regular application
			compileRegularFlexApplication(activeProject, release);
		}
	}

	private function displayPlayerGlobalError(sdkReference:SDKReferenceVO):Void {
		var separator:String = Std.string(model.fileCore.separator);
		var playerVersion:String = Std.string(sdkReference.getPlayerGlobalVersion());
		var p:ParagraphElement = new ParagraphElement();
		var spanText:SpanElement = new SpanElement();
		var link:LinkElement = new LinkElement();

		if (playerVersion == null) {
			playerVersion = '{version}';
		}

		p.color = 0xFA8072;
		spanText.text = ':\n: This SDK does not contains playerglobal.swc in frameworks'.concat(
						separator, 'libs', separator, 'player', separator, playerVersion, separator, 'playerglobal.swc', '.',
						' Download playerglobal '
			);
		link.href = 'https://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html';
		link.linkNormalFormat = {
					'color': 0xc165b8,
					'textDecoration': TextDecoration.UNDERLINE
				};

		var spanLink:SpanElement = new SpanElement();
		spanLink.text = 'here';
		link.addChild(spanLink);

		p.addChild(spanText);
		p.addChild(link);

		dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, p));
	}

	/**
	 * @return True if the current SDK matches the project SDK, false otherwise
	 */
	private function usingInvalidSDK(pvo:AS3ProjectVO):Bool {
		var customSDK:File = AS3.as(pvo.buildOptions.customSDK.fileBridge.getFile, File);
		if (customSDK != null && (currentSDK.nativePath != customSDK.nativePath)) {
			return true;
		}
		return false;
	}

	private function compileFlexJSApplication(pvo:ProjectVO, release:Bool = false):Void {
		function onEnvironmentPrepared(value:String):Void {
			var processArgs:Array<String> = new Array<String>();
			shellInfo = new NativeProcessStartupInfo();
			if (Settings.os == 'win') {
				processArgs.push('/c');
				processArgs.push(value);
			} else {
				processArgs.push('-c');
				processArgs.push(value);
			}

			//var workingDirectory:File = currentSDK.resolvePath("bin/");
			shellInfo.arguments = processArgs;
			shellInfo.executable = cmdFile;
			shellInfo.workingDirectory = AS3.as(pvo.folderLocation.fileBridge.getFile, File);

			initShell();

			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
		var compileStr:String; /*
		* @local
		*/
		if (fcsh == null || pvo.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(AS3.as(pvo, AS3ProjectVO))) {
			currentProject = pvo;
			var tempCurrentSdk:FileLocation = UtilsCore.getCurrentSDK(AS3.as(pvo, AS3ProjectVO));
			currentSDK = null;
			if (tempCurrentSdk == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Flex SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = AS3.as(tempCurrentSdk.fileBridge.getFile, File);
			// determine if the sdk version is lower than 0.8.0 or not
			var isFlexJSAfter7:Bool = AS3.as(UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath), Bool);

			var compilerExtension:String = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '' : '.bat';
			var mxmlcFile:File = currentSDK.resolvePath('js/bin/mxmlc' + compilerExtension);
			if (!AS3.as(mxmlcFile.exists, Bool)) {
				Alert.show('Invalid SDK - Please configure a Apache Royale® SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Apache Royale® SDK instead');
				return;
			}

			// @fix
			// https://github.com/prominic/Moonshine-IDE/issues/26
			// We've found js/bin/mxmlc compiletion do not produce
			// valid swf with prior 0.8 version; we shall need following
			// executable for version less than 0.8
			if (!isFlexJSAfter7) {
				mxmlcFile = currentSDK.resolvePath('bin/mxmlc' + compilerExtension);
			}

			//If application is flexJS and sdk is flex sdk then error popup alert
			var fcshFile:File = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ?
			currentSDK.resolvePath(fcshPath) :
			currentSDK.resolvePath('bin/fcsh.bat');
			if (AS3.as(fcshFile.exists, Bool)) {
				Alert.show('Invalid SDK - Please configure a Apache Royale® SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Apache Royale® SDK instead');
				return;
			}
			fschstr = Std.string(mxmlcFile.nativePath);
			fschstr = Std.string(UtilsCore.convertString(fschstr));

			SDKstr = Std.string(currentSDK.nativePath);
			SDKstr = Std.string(UtilsCore.convertString(SDKstr));

			// update build config file
			AS3ProjectVO(pvo).updateConfig();
			compileStr = getFlexJSBuildArgs(AS3.as(pvo, AS3ProjectVO));
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, cast [compileStr]);
		}
	}

	private function getFlexJSBuildArgs(project:AS3ProjectVO):String {
		var compileStr:String = '';

		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = AS3.as(UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath), Bool);

		var sdkPathHomeArg:String;
		var enLanguageArg:String = 'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"';
		var compilerPathHomeArg:String = 'FALCON_HOME=' + SDKstr;
		var compilerArg:String = '&& "' + fschstr + '"';

		var configArg:String = compile(AS3.as(project, AS3ProjectVO), release);
		configArg = configArg.substring(configArg.indexOf(' -load-config'), configArg.length);
		var jsCompilationArg:String = '';

		if (isFlexJSAfter7) {
			jsCompilationArg = ' -compiler.targets=SWF';
			if (AS3.as(project.isRoyale, Bool)) {
				sdkPathHomeArg = 'ROYALE_HOME=' + SDKstr;
				compilerPathHomeArg = 'ROYALE_SWF_COMPILER_HOME=' + SDKstr;
			}
		}

		if (Settings.os == 'win') {
			compileStr = Std.string(compileStr.concat(
									(sdkPathHomeArg != null) ? ('set ' + sdkPathHomeArg) + '&& ' : '', 'set ', compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
					));

			/*processArgs.push("set ".concat(
			        sdkPathHomeArg, "&& set ", compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
			));*/
		} else {
			compileStr = Std.string(compileStr.concat(
									(sdkPathHomeArg != null) ? ('export ' + sdkPathHomeArg) + ';' : '', 'export ', enLanguageArg, '; export ', compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
					));

			/*processArgs.push("export ".concat(
			        sdkPathHomeArg, " && export ", enLanguageArg, " && export ", compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
			));*/
		}

		return compileStr;
	}

	private function compileRegularFlexApplication(pvo:ProjectVO, release:Bool = false):Void {
		function onEnvironmentPrepared(value:String):Void {
			var processArgs:Array<String> = new Array<String>();
			shellInfo = new NativeProcessStartupInfo();
			if (Settings.os == 'win') {
				processArgs.push('/c');
				processArgs.push(value);
			} else {
				processArgs.push('-c');
				processArgs.push(value);
			}

			//var workingDirectory:File = currentSDK.resolvePath("bin/");
			shellInfo.arguments = processArgs;
			shellInfo.executable = cmdFile;
			shellInfo.workingDirectory = AS3.as(pvo.folderLocation.fileBridge.getFile, File);

			initShell();

			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
		var compileStr:String; /*
		 * @local
		 */
		if (fcsh == null || pvo.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(AS3.as(pvo, AS3ProjectVO))) {
			currentProject = pvo;
			var tempCurrentSdk:FileLocation = UtilsCore.getCurrentSDK(AS3.as(pvo, AS3ProjectVO));
			currentSDK = null;
			if (tempCurrentSdk == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Flex SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = AS3.as(tempCurrentSdk.fileBridge.getFile, File);

			// check if it is a library application
			if (AS3.as((AS3.as(pvo, AS3ProjectVO)).isLibraryProject, Bool)) {
				compileFlexLibrary(AS3.as(pvo, AS3ProjectVO));
				return;
			}

			var fschFile:File = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? currentSDK.resolvePath(fcshPath) : File.applicationDirectory.resolvePath('elements/' + fcshPath);
			if (!AS3.as(fschFile.exists, Bool)) {
				Alert.show('Invalid SDK - Please configure a Flex SDK instead.', 'Error!');
				error('Invalid SDK - Please configure a Flex SDK instead.');
				return;
			}

			fschstr = Std.string(fschFile.nativePath);
			fschstr = Std.string(UtilsCore.convertString(fschstr));

			SDKstr = Std.string(currentSDK.nativePath);
			SDKstr = Std.string(UtilsCore.convertString(SDKstr));

			// update build config file
			AS3ProjectVO(pvo).updateConfig();
			compileStr = compile(AS3.as(pvo, AS3ProjectVO), release);

			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, cast [compileStr]);
		}
	}

	private function compileFlexLibrary(pvo:AS3ProjectVO):Void {
		function onEnvironmentPrepared(value:String):Void {
			var processArgs:Array<String> = new Array<String>();
			shellInfo = new NativeProcessStartupInfo();
			if (Settings.os == 'win') {
				processArgs.push('/c');
				processArgs.push(value);
			} else {
				processArgs.push('-c');
				processArgs.push(value);
			}

			//var workingDirectory:File = currentSDK.resolvePath("bin/");
			shellInfo.arguments = processArgs;
			shellInfo.executable = cmdFile;
			shellInfo.workingDirectory = AS3.as(pvo.folderLocation.fileBridge.getFile, File);

			initShell();

			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compilerArg);
			}
		};
		var compcFile:File = ((Settings.os == 'win')) ? currentSDK.resolvePath('bin/compc.bat') : currentSDK.resolvePath('bin/compc');
		if (!AS3.as(compcFile.exists, Bool)) {
			Alert.show('Invalid SDK - Please configure a Flex SDK instead.', 'Error!');
			error('Invalid SDK - Please configure a Flex SDK instead.');
			return;
		}

		fschstr = Std.string(compcFile.nativePath);
		fschstr = Std.string(UtilsCore.convertString(fschstr));

		SDKstr = Std.string(currentSDK.nativePath);
		SDKstr = Std.string(UtilsCore.convertString(SDKstr));

		// update build config file
		pvo.updateConfig();

		var compilerArg:String = '"' + fschstr + '" -load-config+=' + pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file);
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			compilerArg = Std.string('export '.concat(
									'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"', ';', compilerArg
					));
		} /*
		* @local
		*/

		EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, cast [compilerArg]);
	}

	private function compile(pvo:AS3ProjectVO, release:Bool = false):String {
		clearOutput();
		dispatcher.dispatchEvent(new MXMLCPluginEvent(ActionScriptBuildEvent.PREBUILD, new FileLocation(currentSDK.nativePath)));
		print('Compiling ' + pvo.projectName);

		currentProject = pvo;
		if (pvo.targets.length == 0) {
			error('No targets found for compilation.');
			return '';
		}
		var file:FileLocation = Reflect.getProperty(pvo.targets, Std.string(0));
		if (targets.get(file) == null) {
			lastTarget = AS3.as(file.fileBridge.getFile, File);

			// Turn on optimize flag for release builds
			var optFlag:Bool = AS3.as(pvo.buildOptions.optimize, Bool);
			if (release) {
				pvo.buildOptions.optimize = true;
			}
			var buildArgs:String = Std.string(pvo.buildOptions.getArguments());

			if (AS3.as(pvo.air, Bool)) {
				// option for manipulating swf launch through additional arg
				// in case of project user wants to run it in a mobile simulator by adding certain
				// commands in Additional Compiler Arguments, we need to make the swf launching
				// behaves as a mobile or air
				if (buildArgs.indexOf('+configname=air') == -1) {
					pvo.isMobile = UtilsCore.isMobile(pvo);
				} else {
					pvo.isMobile = ((buildArgs.indexOf('+configname=airmobile') != -1)) ? true : false;
				}
				if (AS3.as(pvo.isMobile, Bool) && buildArgs.indexOf('+configname=air') == -1) {
					buildArgs += ' +configname=airmobile';
				} else if (!AS3.as(pvo.isMobile, Bool) && buildArgs.indexOf('+configname=air') == -1) {
					buildArgs += ' +configname=air';
				}
			}

			pvo.buildOptions.optimize = optFlag;

			var dbg:String;
			if (release) {
				dbg = ' -debug=false';
			} else {
				dbg = ' -debug=true';
			}

			if (buildArgs.indexOf(' -debug=') > -1) {
				dbg = '';
			}

			var outputFile:File;
			if (release && AS3.as(pvo.swfOutput.path, Bool)) {
				outputFile = AS3.as(pvo.folderLocation.resolvePath('bin-release/' + pvo.swfOutput.path.fileBridge.name).fileBridge.getFile, File);
			} else if (AS3.as(pvo.swfOutput.path, Bool)) {
				outputFile = AS3.as(pvo.swfOutput.path.fileBridge.getFile, File);
			}

			var output:String;
			if (outputFile != null) {
				output = ' -o ' + pvo.folderLocation.fileBridge.getRelativePath(new FileLocation(outputFile.nativePath));
				if (outputFile.exists == false) {
					FileUtil.createFile(outputFile);
				}
			}

			if (AS3.as(pvo.nativeExtensions, Bool) && pvo.nativeExtensions.length > 0) {
				var extensionArgs:String = '';
				var relativeExtensionFolderPath:String = Std.string(pvo.folderLocation.fileBridge.getRelativePath(Reflect.getProperty(pvo.nativeExtensions, Std.string(0)), true));
				var tmpExtensionFiles:Array<Dynamic> = Reflect.getProperty(pvo.nativeExtensions, Std.string(0)).fileBridge.getDirectoryListing();
				var i:Int = 0;
				while (i < tmpExtensionFiles.length) {
					if (Reflect.field(tmpExtensionFiles[i], 'extension') == 'ane' && !AS3.as(Reflect.field(tmpExtensionFiles[i], 'isDirectory'), Bool)) {
						var extensionArg:String = ' -external-library-path+=' + relativeExtensionFolderPath + '/' + Reflect.field(tmpExtensionFiles[i], 'name');
						if (pvo.buildOptions.additional.indexOf(extensionArg) == -1) {
							extensionArgs += extensionArg;
						}
					} else {
						tmpExtensionFiles.splice(i, 1);
						i--;
					}
					i++;
				}

				if (extensionArgs != '') {
					buildArgs += extensionArgs;
					if (AS3.as(pvo.air, Bool) && AS3.as(pvo.buildOptions.isMobileRunOnSimulator, Bool)) {
						new NativeExtensionExpander(tmpExtensionFiles);
					}
				}
			}

			var mxmlcStr:String = '"' + currentSDK.resolvePath(mxmlcPath).nativePath + '"' + ' -load-config+=' + pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file) + buildArgs + dbg + output;

			trace('mxmlc command: %s' + mxmlcStr);
			return mxmlcStr;
		} else {
			var target:Int = AS3.int(targets.get(file));
			return 'compile ' + target;
		}
	}

	private function send(msg:String):Void {
		debug('Sending to mxmlc: %s', msg);
		if (fcsh == null) {
			queue.push(msg);
		} else {
			var input:IDataOutput = fcsh.standardInput;
			input.writeUTFBytes(msg + '\n');
		}
	}

	private function flush():Void {
		if (queue.length == 0) {
			return;
		}
		if (fcsh != null) {
			for (i in 0...queue.length) {
				send(queue[i]);
			}
			as3hx.Compat.setArrayLength(queue, 0);
		}
	}

	private function initShell():Void {
		if (fcsh != null) {
			stopShell();
			exiting = true;
			reset();
		} else {
			startShell();
		}
	}

	private function startShell():Void {
		// stop running debug process for run/build if debug process in running
		if (!debugAfterBuild) {
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.STOP_DEBUG, false));
		}

		fcsh = new NativeProcess();
		fcsh.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		fcsh.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		fcsh.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
		fcsh.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
		fcsh.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		fcsh.start(shellInfo);

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
				currentProject.projectName,
				(runAfterBuild) ? 'Launching ' : 'Building '));
		dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
		flush();
	}

	private function stopShell():Void {
		if (fcsh == null) {
			return;
		}
		if (AS3.as(fcsh.running, Bool)) {
			fcsh.exit();
		}
		fcsh.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		fcsh.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		fcsh.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
		fcsh.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
		fcsh.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
		fcsh = null;

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
	}

	private function onTerminateBuildRequest(event:StatusBarEvent):Void {
		if (fcsh != null && AS3.as(fcsh.running, Bool)) {
			fcsh.exit(true);
		}
	}

	private function shellData(e:ProgressEvent):Void {
		if (fcsh != null) {
			var output:IDataInput = fcsh.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array<Dynamic>;
			var isSuccessBuild:Bool;

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('fcsh: Target \\d not found', ''));
			if (match != null) {
				error('Target not found. Try again.');
				targets = new Dictionary();
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('fcsh: Assigned (\\d) as the compile target id', ''));
			if (match != null && lastTarget != null) {
				var target:Int = AS3.int(match[1]);
				targets.set(lastTarget, target);

				debug('FSCH target: %s', target);

				lastTarget = null;
			}

			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('.* bytes.*', ''));
			if (match != null) {
				isSuccessBuild = true;
			} else {
				match = as3hx.Compat.match(data, new as3hx.Compat.Regex('.*successfully compiled and optimized.*', ''));
				if (match != null) {
					isSuccessBuild = true;
				}
			}

			if (isSuccessBuild) {
				var currentSuccessfullProject:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);

				dispatcher.dispatchEvent(new RefreshTreeEvent(currentSuccessfullProject.swfOutput.path.fileBridge.parent));

				print('%s', data);

				if (!isLibraryProject) {
					if (this.runAfterBuild && !this.debugAfterBuild) {
						testMovie();
					} else if (debugAfterBuild) {
						dispatcher.dispatchEvent(new SWFLaunchEvent(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, null));
						if (currentSuccessfullProject.resourcePaths.length == 0) {
							launchDebuggingAfterBuild();
						} else {
							copyingResources();
						}
					} else if (AS3ProjectVO(currentProject).resourcePaths.length != 0) {
						copyingResources();
					} else {
						projectBuildSuccessfully();
					}
				} else {
					projectBuildSuccessfully();
				}

				return;
			}

			if (data.charAt(data.length - 1) == '\n') {
				data = data.substr(0, data.length - 1);
			}
			print('%s', data);
		}

	}

	private function projectBuildSuccessfully():Void {
		var currentSuccessfullProject:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		success('Project Build Successfully.');
		if (!AS3.as(currentSuccessfullProject.isFlexJS, Bool) && !AS3.as(currentSuccessfullProject.isRoyale, Bool)) {
			reset();
		}
	}

	private function launchDebuggingAfterBuild():Void {
		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);

		if (AS3.as(pvo.isMobile, Bool) && !AS3.as(pvo.buildOptions.isMobileRunOnSimulator, Bool)) {
			dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, currentProject));
			//install and launch on device
			testMovie();
		} else {
			projectBuildSuccessfully();
			dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, currentProject));
		}
	}

	private function testMovie():Void {
		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		var swfFile:File = AS3.as((AS3.as(currentProject, AS3ProjectVO)).swfOutput.path.fileBridge.getFile, File);

		// before test movie lets copy the resource folder(s)
		// to debug folder if any
		if (pvo.resourcePaths.length != 0 && resourceCopiedIndex == 0) {
			copyingResources();
			return;
		}

		projectBuildSuccessfully();

		if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM) {
			var customSplit:Array<String> = pvo.testMovieCommand.split(';');
			var customFile:String = customSplit[0];
			var customArgs:String = Std.string(customSplit.slice(1).join(' ').replace('$(ProjectName)', pvo.projectName).replace('$(CompilerPath)', currentSDK.nativePath));

			print(customFile + ' ' + customArgs, pvo.folderLocation.fileBridge.nativePath);
		} else if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher deal with playin' the swf
			dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, pvo, currentSDK)
			);
		} else {
			var htmlWrapperFile:File = swfFile.parent.resolvePath(Reflect.getProperty(swfFile.name.split('.'), Std.string(0)) + '.html');
			getHTMLTemplatesCopied(pvo, htmlWrapperFile);

			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher runs SWF file
			var tmpLaunchEvent:SWFLaunchEvent = new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, (AS3.as(htmlWrapperFile.exists, Bool)) ? htmlWrapperFile : swfFile, pvo);
			tmpLaunchEvent.url = ((AS3.as(pvo.customHTMLPath, Bool) && (StringTools.trim(pvo.customHTMLPath).length != 0))) ? Std.string(pvo.customHTMLPath) : null;
			dispatcher.dispatchEvent(tmpLaunchEvent);
		}

		currentProject = null;
	}

	private var resourceCopiedIndex:Int = 0;

	private function copyingResources():Void {
		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		if (pvo.resourcePaths.length == 0) {
			projectBuildSuccessfully();
			return;
		}

		var destination:File = AS3.as(pvo.swfOutput.path.fileBridge.parent.fileBridge.getFile, File);
		var fl:FileLocation = Reflect.getProperty(pvo.resourcePaths, Std.string(resourceCopiedIndex));
		warning('Copying resource: %s', fl.name);

		(AS3.as(fl.fileBridge.getFile, File)).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		(AS3.as(fl.fileBridge.getFile, File)).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
		(AS3.as(fl.fileBridge.getFile, File)).copyToAsync(destination.resolvePath(fl.fileBridge.name), true);
	}

	private function onResourcesCopyingComplete(event:Event):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		resourceCopiedIndex++;

		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		print('Copying %s complete', Reflect.field(event.currentTarget, 'nativePath'));

		if (resourceCopiedIndex < pvo.resourcePaths.length) {
			copyingResources();
		} else if (debugAfterBuild) {
			launchDebuggingAfterBuild();
		} else if (runAfterBuild) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.swfOutput.path.fileBridge.parent));
			testMovie();
		} else {
			projectBuildSuccessfully();
			dispatcher.dispatchEvent(new RefreshTreeEvent((AS3.as(currentProject, AS3ProjectVO)).swfOutput.path.fileBridge.parent));
		}
	}

	private function onResourcesCopyingFailed(event:IOErrorEvent):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		error('Copying resources failed %s\n', event.text);
		error('Project Build failed.');
	}

	private function getHTMLTemplatesCopied(pvo:AS3ProjectVO, htmlFile:File):Void {
		if (!AS3.as(htmlFile.exists, Bool)) {
			var htmlTemplateFolder:FileLocation = pvo.folderLocation.resolvePath('html-template');
			var fileName:String = Std.string(Reflect.getProperty(htmlFile.name.split('.'), Std.string(0)));
			if (AS3.as(htmlTemplateFolder.fileBridge.exists, Bool)) {
				var th:TemplatingHelper = new TemplatingHelper();
				Reflect.setProperty(th.templatingData, '$Wrapper', fileName);
				th.projectTemplate(htmlTemplateFolder, pvo.folderLocation.resolvePath('bin-debug'));
				dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.folderLocation.resolvePath('bin-debug')));
			} else {
				Alert.show('Missing "html-template" folder.\nMoonshine is trying to open the ' + fileName + '.swf file.\n(Note: This may not work in MacOS Sandbox.)', 'Note!');
			}
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (fcsh != null) {
			var currentAs3Project:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
			var timeoutValue:Int;
			var output:IDataInput = fcsh.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var syntaxMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) (Error:|Syntax error:) (.+).+', ''));
			if (syntaxMatch != null) {
				error('%s\n', data);

				//Royale compiler sends exit code, we don't have to reset anything here, Flex compiler not.
				if (currentAs3Project != null && !AS3.as(currentAs3Project.isRoyale, Bool) && !AS3.as(currentAs3Project.isFlexJS, Bool)) {
					//Let's wait with the reset because compiler may still have something to report
					timeoutValue = as3hx.Compat.setTimeout(function():Void {
										reset();
										as3hx.Compat.clearTimeout(timeoutValue);
									}, 100);
				}
				return;
			}

			var generalMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('[^:]*:?\\s*Error:\\s(.*)', ''));
			if (syntaxMatch == null && generalMatch != null) {
				error('%s\n', data);

				if (currentAs3Project != null && !AS3.as(currentAs3Project.isRoyale, Bool) && !AS3.as(currentAs3Project.isFlexJS, Bool)) {
					timeoutValue = as3hx.Compat.setTimeout(function():Void {
										reset();
										as3hx.Compat.clearTimeout(timeoutValue);
									}, 100);
				}
				return;
			}

			//Build should be continued with there are only warnings
			var warningMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('Warning:', 'i'));
			if (warningMatch != null) {
				warning(data);
				return;
			}

			var javaToolsOptionsMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('JAVA_TOOL_OPTIONS', 'i'));
			if (javaToolsOptionsMatch != null) {
				print(data);
				return;
			}

			print(data);
			if (currentAs3Project != null && !AS3.as(currentAs3Project.isRoyale, Bool) && !AS3.as(currentAs3Project.isFlexJS, Bool)) {
				timeoutValue = as3hx.Compat.setTimeout(function():Void {
									reset();
									as3hx.Compat.clearTimeout(timeoutValue);
								}, 100);
			}
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		reset();
		if (exiting) {
			exiting = false;
			startShell();
		}
	}

}