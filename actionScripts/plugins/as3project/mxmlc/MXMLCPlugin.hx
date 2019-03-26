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

import actionScripts.events.SdkEvent;
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
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
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
class MXMLCPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public var defaultFlexSDK(get, set):String;

	override private function get_name():String {
		return 'Default SDK';
	}

	override private function get_author():String {
		return 'Miha Lunar & Moonshine Project Team';
	}

	override private function get_description():String {
		return ResourceManager.getInstance().getString('resources', 'plugin.desc.mxmlc');
	}

	public var incrementalCompile:Bool = true;

	private var runAfterBuild:Bool;

	private var debugAfterBuild:Bool;

	private var release:Bool;

	private var fcshPath:String = 'bin/fcsh';

	private var mxmlcPath:String = 'bin/mxmlc';

	private var cmdFile:File;

	private var _defaultFlexSDK:String;

	private var fcsh:NativeProcess;

	private var exiting:Bool = false;

	private var shellInfo:NativeProcessStartupInfo;

	private var isLibraryProject:Bool;

	private var lastTarget:File;

	private var targets:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	private var currentSDK:File;

	/** Project currently under compilation */
	private var currentProject:ProjectVO;

	private var queue:Array<String> = new Array<String>();

	private var tempObj:Dynamic;

	private var fschstr:String;

	private var SDKstr:String;

	private var selectProjectPopup:SelectOpenedFlexProject;

	private function get_defaultFlexSDK():String {
		return _defaultFlexSDK;
	}

	private function set_defaultFlexSDK(value:String):String {
		_defaultFlexSDK = value;
		if (_defaultFlexSDK == '')
		// check if any bundled SDK present or not
		{

			// if present, make one default
			if (model.userSavedSDKs.length > 0 && model.userSavedSDKs[0].status == SDKUtils.BUNDLED) {
				_defaultFlexSDK = model.userSavedSDKs[0].path;
				SDKUtils.setDefaultSDKByBundledSDK();
			} else {
				model.defaultSDK = null;
			}
		} else {
			for (i /* AS3HX WARNING could not determine type for var: i exp: EField(ECall(EField(EIdent(IDEModel),getInstance),[]),userSavedSDKs) type: null */ in IDEModel.getInstance().userSavedSDKs) {
				if (i.path == value) {
					model.defaultSDK = new FileLocation(i.path);
					model.noSDKNotifier.dispatchEvent(new Event(NoSDKNotifier.SDK_SAVED));
					break;
				}
			}

			// even if above condition do not made
			// check one more condition - this is particularly valid
			// if we have bundled SDKs and an old bundled SDK
			// references not found in newer bundled SDKs
			if (!model.defaultSDK) {
				for (i /* AS3HX WARNING could not determine type for var: i exp: EField(ECall(EField(EIdent(IDEModel),getInstance),[]),userSavedSDKs) type: null */ in IDEModel.getInstance().userSavedSDKs) {
					if (i.path == value) {
						model.defaultSDK = new FileLocation(i.path);
						model.noSDKNotifier.dispatchEvent(new Event(NoSDKNotifier.SDK_SAVED));
						break;
					}
				}
			}

			// update project-to-sdk references once again
			for (project /* AS3HX WARNING could not determine type for var: project exp: EField(EIdent(model),projects) type: null */ in model.projects) {
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project));
			}
		}

		if (model.defaultSDK) {
			EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
		}
		// state change of menus based upon default SDK presence
		dispatcher.dispatchEvent(new Event(SdkEvent.CHANGE_SDK));
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
		if (activated) {
			return;
		}

		super.activate();

		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, buildAndRun);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD, build);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_RELEASE, buildRelease);
		dispatcher.addEventListener(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, onDefaultSDKUpdatedOutside);

		tempObj = {};
		tempObj.callback = buildCommand;
		tempObj.commandDesc = 'Build the currently selected Flex project.';
		registerCommand('build', tempObj);

		tempObj = {};
		tempObj.callback = runCommand;
		tempObj.commandDesc = 'Build and run the currently selected Flex project.';
		registerCommand('run', tempObj);

		tempObj = {};
		tempObj.callback = releaseCommand;
		tempObj.commandDesc = 'Build the currently selected project in release mode.';
		tempObj.style = 'red';
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
			if (model.userSavedSDKs[i].status != SDKUtils.BUNDLED) {
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
		targets = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	}

	private function onDefaultSDKUpdatedOutside(event:ProjectEvent):Void
	// @note
	 {

		// basically requires to listen to update in
		// Flex SDKs window
		var tmpRef:SDKReferenceVO = try cast(event.anObject, SDKReferenceVO) catch (e:Dynamic) null;
		if (tmpRef == null) {
			return;
		}
		defaultFlexSDK = tmpRef.path;

		var thisSettings:Array<ISetting> = getSettingsList();
		var pathSettingToDefaultSDK:PathSetting = try cast(thisSettings[0], PathSetting) catch (e:Dynamic) null;
		pathSettingToDefaultSDK.stringValue = defaultFlexSDK;
		dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, 'actionScripts.plugins.as3project.mxmlc::MXMLCPlugin', thisSettings));
	}

	private function buildAndRun(e:Event):Void
	// re-check in case of debug call and its already running
	 {

		if (e.type == ActionScriptBuildEvent.BUILD_AND_DEBUG && DebugHighlightManager.IS_DEBUGGER_CONNECTED) {
			Alert.show('You are already debugging an application. Do you wish to terminate the existing debugging session and start a new session?', 'Debug Warning', Alert.YES | Alert.CANCEL, try cast(FlexGlobals.topLevelApplication, Sprite) catch (e:Dynamic) null, reDebugConfirmClickHandler);
		} else {
			build(e, true);
		}

		/*
		 * @local
		 */
		function reDebugConfirmClickHandler(event:CloseEvent):Void {
			if (event.detail == Alert.YES) {
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.TERMINATE_EXECUTION));
				as3hx.Compat.setTimeout(function():Void {
							dispatcher.dispatchEvent(e);
						}, 500);
			}
		};
	}

	private function buildRelease(e:Event):Void {
		SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
		build(e, false, true);
	}

	private function sdkSelected(event:Event):Void {
		sdkSelectionCancelled(null);
		// update swf version if a newer SDK now saved than previously saved one
		cast((currentProject), AS3ProjectVO).swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
		// continue with waiting build process again
		proceedWithBuild(currentProject);
	}

	private function sdkSelectionCancelled(event:Event):Void {
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
	}

	private function build(e:Event, runAfterBuild:Bool = false, release:Bool = false):Void {
		if (e != null && e.type == ActionScriptBuildEvent.BUILD_AND_DEBUG) {
			this.debugAfterBuild = true;
			SWFLauncherPlugin.RUN_AS_DEBUGGER = true;
		} else {
			this.debugAfterBuild = false;
			SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
		}

		this.runAfterBuild = runAfterBuild;
		this.release = release;
		buildStart();
	}

	private function buildStart():Void
	// check if there is multiple projects were opened in tree view
	 {

		if (model.projects.length > 1)
		// check if user has selection/select any particular project or not
		{

			if (model.mainView.isProjectViewAdded) {
				var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
				var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
				if (projectReference != null) {
					checkForUnsavedEdior(projectReference);
					return;
				}
			}
			// if above is false
			selectProjectPopup = new SelectOpenedFlexProject();
			PopUpManager.addPopUp(selectProjectPopup, try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, false);
			PopUpManager.centerPopUp(selectProjectPopup);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		} else if (model.projects.length != 0) {
			checkForUnsavedEdior(try cast(model.projects[0], ProjectVO) catch (e:Dynamic) null);
		}

		/*
		* @local
		*/
		function onProjectSelected(event:Event):Void {
			checkForUnsavedEdior(selectProjectPopup.selectedProject);
			onProjectSelectionCancelled(null);
		};

		function onProjectSelectionCancelled(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		} /*
		* check for unsaved File
		*/ ;

		var checkForUnsavedEdior:ProjectVO->Void = function(activeProject:ProjectVO):Void {
			model.activeProject = activeProject;
			UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
		}
	}

	private function proceedWithBuild(activeProject:ProjectVO = null):Void
	// Don't compile if there is no project. Don't warn since other compilers might take the job.
	 {

		if (activeProject == null) {
			activeProject = model.activeProject;
		}
		if (activeProject == null || !(Std.is(activeProject, AS3ProjectVO))) {
			return;
		}

		reset();

		var as3Pvo:AS3ProjectVO = try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null;
		isLibraryProject = as3Pvo.isLibraryProject;
		if (as3Pvo.targets.length == 0 && !as3Pvo.isLibraryProject) {
			error('No targets found for compilation.');
			return;
		}

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			// before proceed, check file access dependencies
			if (!OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([as3Pvo]), 'Access Manager - Build Halt!')) {
				Alert.show('Please fix the dependencies before build.', 'Error!');
				return;
			}
		}

		UtilsCore.checkIfRoyaleApplication(as3Pvo);

		// Read file content to indentify the project type regular flex application or flexjs applicatino
		if (as3Pvo.isFlexJS) {
			if (as3Pvo.isRoyale) {
				var tmpSDKLocation:FileLocation = UtilsCore.getCurrentSDK(try cast(as3Pvo, AS3ProjectVO) catch (e:Dynamic) null);
				var sdkVO:SDKReferenceVO = SDKUtils.getSDKReference(tmpSDKLocation);
				if (sdkVO != null && sdkVO.isJSOnlySdk) {
					error('This SDK only supports JavaScript Builds.');
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
		}
		//Regular application
		else {

			compileRegularFlexApplication(activeProject, release);
		}
	}

	/**
	 * @return True if the current SDK matches the project SDK, false otherwise
	 */
	private function usingInvalidSDK(pvo:AS3ProjectVO):Bool {
		var customSDK:File = try cast(pvo.buildOptions.customSDK.fileBridge.getFile, File) catch (e:Dynamic) null;
		if (customSDK != null && (currentSDK.nativePath != customSDK.nativePath)) {
			return true;
		}
		return false;
	}

	private function compileFlexJSApplication(pvo:ProjectVO, release:Bool = false):Void {
		var compileStr:String;
		if (fcsh == null || pvo.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null)) {
			currentProject = pvo;
			var tempCurrentSdk:FileLocation = UtilsCore.getCurrentSDK(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null);
			currentSDK = null;
			if (tempCurrentSdk == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Flex SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = try cast(tempCurrentSdk.fileBridge.getFile, File) catch (e:Dynamic) null;
			// determine if the sdk version is lower than 0.8.0 or not
			var isFlexJSAfter7:Bool = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);

			var compilerExtension:String = (ConstantsCoreVO.IS_MACOS) ? '' : '.bat';
			var mxmlcFile:File = currentSDK.resolvePath('js/bin/mxmlc' + compilerExtension);
			if (!mxmlcFile.exists) {
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
			var fcshFile:File = (ConstantsCoreVO.IS_MACOS) ?
			currentSDK.resolvePath(fcshPath) :
			currentSDK.resolvePath('bin/fcsh.bat');
			if (fcshFile.exists) {
				Alert.show('Invalid SDK - Please configure a Apache Royale® SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Apache Royale® SDK instead');
				return;
			}
			fschstr = mxmlcFile.nativePath;
			fschstr = UtilsCore.convertString(fschstr);

			SDKstr = currentSDK.nativePath;
			SDKstr = UtilsCore.convertString(SDKstr);

			// update build config file
			cast((pvo), AS3ProjectVO).updateConfig();
			compileStr = getFlexJSBuildArgs(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null);
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compileStr]);
		}

		/*
		* @local
		*/
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
			shellInfo.workingDirectory = try cast(pvo.folderLocation.fileBridge.getFile, File) catch (e:Dynamic) null;

			initShell();

			if (ConstantsCoreVO.IS_MACOS) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
	}

	private function getFlexJSBuildArgs(project:AS3ProjectVO):String {
		var compileStr:String = '';

		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);

		var sdkPathHomeArg:String;
		var enLanguageArg:String = 'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"';
		var compilerPathHomeArg:String = 'FALCON_HOME=' + SDKstr;
		var compilerArg:String = '&& "' + fschstr + '"';

		var configArg:String = compile(try cast(project, AS3ProjectVO) catch (e:Dynamic) null, release);
		configArg = configArg.substring(configArg.indexOf(' -load-config'), configArg.length);
		var jsCompilationArg:String = '';

		if (isFlexJSAfter7) {
			jsCompilationArg = ' -compiler.targets=SWF';
			if (project.isRoyale) {
				sdkPathHomeArg = 'ROYALE_HOME=' + SDKstr;
				compilerPathHomeArg = 'ROYALE_SWF_COMPILER_HOME=' + SDKstr;
			}
		}

		if (Settings.os == 'win') {
			compileStr = compileStr.concat(
							(sdkPathHomeArg != null) ? ('set ' + sdkPathHomeArg) + '&& ' : '', 'set ', compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
				);
		} else {
			compileStr = compileStr.concat(
							(sdkPathHomeArg != null) ? ('export ' + sdkPathHomeArg) + ';' : '', 'export ', enLanguageArg, '; export ', compilerPathHomeArg, compilerArg, configArg, jsCompilationArg
				);
		}

		return compileStr;
	}

	private function compileRegularFlexApplication(pvo:ProjectVO, release:Bool = false):Void {
		var compileStr:String;
		if (fcsh == null || pvo.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null)) {
			currentProject = pvo;
			var tempCurrentSdk:FileLocation = UtilsCore.getCurrentSDK(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null);
			currentSDK = null;
			if (tempCurrentSdk == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Flex SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = try cast(tempCurrentSdk.fileBridge.getFile, File) catch (e:Dynamic) null;

			// check if it is a library application
			if ((try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null).isLibraryProject) {
				compileFlexLibrary(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null);
				return;
			}

			var fschFile:File = (ConstantsCoreVO.IS_MACOS) ? currentSDK.resolvePath(fcshPath) : File.applicationDirectory.resolvePath('elements/' + fcshPath);
			if (!fschFile.exists) {
				Alert.show('Invalid SDK - Please configure a Flex SDK instead.', 'Error!');
				error('Invalid SDK - Please configure a Flex SDK instead.');
				return;
			}

			fschstr = fschFile.nativePath;
			fschstr = UtilsCore.convertString(fschstr);

			SDKstr = currentSDK.nativePath;
			SDKstr = UtilsCore.convertString(SDKstr);

			// update build config file
			cast((pvo), AS3ProjectVO).updateConfig();
			compileStr = compile(try cast(pvo, AS3ProjectVO) catch (e:Dynamic) null, release);

			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compileStr]);
		}

		/*
		 * @local
		 */
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
			shellInfo.workingDirectory = try cast(pvo.folderLocation.fileBridge.getFile, File) catch (e:Dynamic) null;

			initShell();

			if (ConstantsCoreVO.IS_MACOS) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
	}

	private function compileFlexLibrary(pvo:AS3ProjectVO):Void {
		var compcFile:File = ((Settings.os == 'win')) ? currentSDK.resolvePath('bin/compc.bat') : currentSDK.resolvePath('bin/compc');
		if (!compcFile.exists) {
			Alert.show('Invalid SDK - Please configure a Flex SDK instead.', 'Error!');
			error('Invalid SDK - Please configure a Flex SDK instead.');
			return;
		}

		fschstr = compcFile.nativePath;
		fschstr = UtilsCore.convertString(fschstr);

		SDKstr = currentSDK.nativePath;
		SDKstr = UtilsCore.convertString(SDKstr);

		// update build config file
		pvo.updateConfig();

		var compilerArg:String = '"' + fschstr + '" -load-config+=' + pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file);
		if (ConstantsCoreVO.IS_MACOS) {
			compilerArg = 'export '.concat(
							'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"', ';', compilerArg
				);
		}

		EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compilerArg]);

		/*
		* @local
		*/
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
			shellInfo.workingDirectory = try cast(pvo.folderLocation.fileBridge.getFile, File) catch (e:Dynamic) null;

			initShell();

			if (ConstantsCoreVO.IS_MACOS) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compilerArg);
			}
		};
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
		var file:FileLocation = pvo.targets[0];
		if (targets.get(file) == null) {
			lastTarget = try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null;

			// Turn on optimize flag for release builds
			var optFlag:Bool = pvo.buildOptions.optimize;
			if (release) {
				pvo.buildOptions.optimize = true;
			}
			var buildArgs:String = pvo.buildOptions.getArguments();

			if (pvo.air)
			// option for manipulating swf launch through additional arg
			{

				// in case of project user wants to run it in a mobile simulator by adding certain
				// commands in Additional Compiler Arguments, we need to make the swf launching
				// behaves as a mobile or air
				if (buildArgs.indexOf('+configname=air') == -1) {
					pvo.isMobile = UtilsCore.isMobile(pvo);
				} else {
					pvo.isMobile = ((buildArgs.indexOf('+configname=airmobile') != -1)) ? true : false;
				}
				if (pvo.isMobile && buildArgs.indexOf('+configname=air') == -1) {
					buildArgs += ' +configname=airmobile';
				} else if (!pvo.isMobile && buildArgs.indexOf('+configname=air') == -1) {
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
			if (release && pvo.swfOutput.path) {
				outputFile = try cast(pvo.folderLocation.resolvePath('bin-release/' + pvo.swfOutput.path.fileBridge.name).fileBridge.getFile, File) catch (e:Dynamic) null;
			} else if (pvo.swfOutput.path) {
				outputFile = try cast(pvo.swfOutput.path.fileBridge.getFile, File) catch (e:Dynamic) null;
			}

			var output:String;
			if (outputFile != null) {
				output = ' -o ' + pvo.folderLocation.fileBridge.getRelativePath(new FileLocation(outputFile.nativePath));
				if (outputFile.exists == false) {
					FileUtil.createFile(outputFile);
				}
			}

			if (pvo.nativeExtensions && pvo.nativeExtensions.length > 0) {
				var extensionArgs:String = '';
				var relativeExtensionFolderPath:String = pvo.folderLocation.fileBridge.getRelativePath(pvo.nativeExtensions[0], true);
				var tmpExtensionFiles:Array<Dynamic> = pvo.nativeExtensions[0].fileBridge.getDirectoryListing();
				var i:Int = 0;
				while (i < tmpExtensionFiles.length) {
					if (tmpExtensionFiles[i].extension == 'ane' && !tmpExtensionFiles[i].isDirectory) {
						var extensionArg:String = ' -external-library-path+=' + relativeExtensionFolderPath + '/' + tmpExtensionFiles[i].name;
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
					if (pvo.air && pvo.buildOptions.isMobileRunOnSimulator) {
						new NativeExtensionExpander(tmpExtensionFiles);
					}
				}
			}

			var mxmlcStr:String = '"' + currentSDK.resolvePath(mxmlcPath).nativePath + '"' + ' -load-config+=' + pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file) + buildArgs + dbg + output;

			trace('mxmlc command: %s' + mxmlcStr);
			return mxmlcStr;
		} else {
			var target:Int = targets.get(file);
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
			var i:Int = 0;
			while (i < queue.length) {
				send(queue[i]);
				i++;
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

	private function startShell():Void
	// stop running debug process for run/build if debug process in running
	 {

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
		if (fcsh.running) {
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
		if (fcsh != null && fcsh.running) {
			fcsh.exit(true);
		}
	}

	private function shellData(e:ProgressEvent):Void {
		if (fcsh != null) {
			var output:IDataInput = fcsh.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array<Dynamic>;
			var isSuccessBuild:Bool;

			match = data.match(new as3hx.Compat.Regex('fcsh: Target \\d not found', ''));
			if (match != null) {
				error('Target not found. Try again.');
				targets = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
			}

			match = data.match(new as3hx.Compat.Regex('fcsh: Assigned (\\d) as the compile target id', ''));
			if (match != null && lastTarget != null) {
				var target:Int = as3hx.Compat.parseInt(match[1]);
				targets.set(lastTarget, target);

				debug('FSCH target: %s', target);

				lastTarget = null;
			}

			match = data.match(new as3hx.Compat.Regex('.* bytes.*', ''));
			if (match != null) {
				isSuccessBuild = true;
			} else {
				match = data.match(new as3hx.Compat.Regex('.*successfully compiled and optimized.*', ''));
				if (match != null) {
					isSuccessBuild = true;
				}
			}

			if (isSuccessBuild) {
				var currentSuccessfullProject:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;

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
					} else if (cast((currentProject), AS3ProjectVO).resourcePaths.length != 0) {
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
		var currentSuccessfullProject:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		success('Project Build Successfully.');
		if (!currentSuccessfullProject.isFlexJS && !currentSuccessfullProject.isRoyale) {
			reset();
		}
	}

	private function launchDebuggingAfterBuild():Void {
		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;

		if (pvo.isMobile && !pvo.buildOptions.isMobileRunOnSimulator) {
			dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, currentProject));
			//install and launch on device
			testMovie();
		} else {
			projectBuildSuccessfully();
			dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, currentProject));
		}
	}

	private function testMovie():Void {
		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		var swfFile:File = try cast((try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null).swfOutput.path.fileBridge.getFile, File) catch (e:Dynamic) null;

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
			var customArgs:String = customSplit.slice(1).join(' ').replace('$(ProjectName)', pvo.projectName).replace('$(CompilerPath)', currentSDK.nativePath);

			print(customFile + ' ' + customArgs, pvo.folderLocation.fileBridge.nativePath);
		} else if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher deal with playin' the swf
			dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, pvo, currentSDK)
			);
		} else {
			var htmlWrapperFile:File = swfFile.parent.resolvePath(swfFile.name.split('.')[0] + '.html');
			getHTMLTemplatesCopied(pvo, htmlWrapperFile);

			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher runs SWF file
			var tmpLaunchEvent:SWFLaunchEvent = new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, (htmlWrapperFile.exists) ? htmlWrapperFile : swfFile, pvo);
			tmpLaunchEvent.url = ((pvo.customHTMLPath && (StringTools.trim(pvo.customHTMLPath).length != 0))) ? pvo.customHTMLPath : null;
			dispatcher.dispatchEvent(tmpLaunchEvent);
		}

		currentProject = null;
	}

	private var resourceCopiedIndex:Int;

	private function copyingResources():Void {
		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		if (pvo.resourcePaths.length == 0) {
			projectBuildSuccessfully();
			return;
		}

		var destination:File = try cast(pvo.swfOutput.path.fileBridge.parent.fileBridge.getFile, File) catch (e:Dynamic) null;
		var fl:FileLocation = pvo.resourcePaths[resourceCopiedIndex];
		warning('Copying resource: %s', fl.name);

		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).copyToAsync(destination.resolvePath(fl.fileBridge.name), true);
	}

	private function onResourcesCopyingComplete(event:Event):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		resourceCopiedIndex++;

		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		print('Copying %s complete', event.currentTarget.nativePath);

		if (resourceCopiedIndex < pvo.resourcePaths.length) {
			copyingResources();
		} else if (debugAfterBuild) {
			launchDebuggingAfterBuild();
		} else if (runAfterBuild) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.swfOutput.path.fileBridge.parent));
			testMovie();
		} else {
			projectBuildSuccessfully();
			dispatcher.dispatchEvent(new RefreshTreeEvent((try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null).swfOutput.path.fileBridge.parent));
		}
	}

	private function onResourcesCopyingFailed(event:IOErrorEvent):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		error('Copying resources failed %s\n', event.text);
		error('Project Build failed.');
	}

	private function getHTMLTemplatesCopied(pvo:AS3ProjectVO, htmlFile:File):Void {
		if (!htmlFile.exists) {
			var htmlTemplateFolder:FileLocation = pvo.folderLocation.resolvePath('html-template');
			var fileName:String = htmlFile.name.split('.')[0];
			if (htmlTemplateFolder.fileBridge.exists) {
				var th:TemplatingHelper = new TemplatingHelper();
				th.templatingData['$Wrapper'] = fileName;
				th.projectTemplate(htmlTemplateFolder, pvo.folderLocation.resolvePath('bin-debug'));
				dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.folderLocation.resolvePath('bin-debug')));
			} else {
				Alert.show('Missing "html-template" folder.\nMoonshine is trying to open the ' + fileName + '.swf file.\n(Note: This may not work in MacOS Sandbox.)', 'Note!');
			}
		}
	}

	private function shellError(e:ProgressEvent):Void {
		if (fcsh != null) {
			var currentAs3Project:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
			var timeoutValue:Int;
			var output:IDataInput = fcsh.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var syntaxMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) (Error:|Syntax error:) (.+).+', ''));
			if (syntaxMatch != null) {
				error('%s\n', data);

				//Royale compiler sends exit code, we don't have to reset anything here, Flex compiler not.
				if (currentAs3Project != null && !currentAs3Project.isRoyale && !currentAs3Project.isFlexJS)
				//Let's wait with the reset because compiler may still have something to report
				{

					timeoutValue = as3hx.Compat.setTimeout(function():Void {
										reset();
										as3hx.Compat.clearTimeout(timeoutValue);
									}, 100);
				}
				return;
			}

			var generalMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('[^:]*:?\\s*Error:\\s(.*)', ''));
			if (syntaxMatch == null && generalMatch != null) {
				error('%s\n', data);

				if (currentAs3Project != null && !currentAs3Project.isRoyale && !currentAs3Project.isFlexJS) {
					timeoutValue = as3hx.Compat.setTimeout(function():Void {
										reset();
										as3hx.Compat.clearTimeout(timeoutValue);
									}, 100);
				}
				return;
			}

			//Build should be continued with there are only warnings
			var warningMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('Warning:', 'i'));
			if (warningMatch != null) {
				warning(data);
				return;
			}

			var javaToolsOptionsMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('JAVA_TOOL_OPTIONS', 'i'));
			if (javaToolsOptionsMatch != null) {
				print(data);
				return;
			}

			print(data);
			if (currentAs3Project != null && !currentAs3Project.isRoyale && !currentAs3Project.isFlexJS) {
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