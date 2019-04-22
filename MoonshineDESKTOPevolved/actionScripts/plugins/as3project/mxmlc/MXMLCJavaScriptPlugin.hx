////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.mxmlc;

import actionScripts.locator.HelperModel;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.utils.SDKUtils;
import actionScripts.valueObjects.SDKReferenceVO;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.OutputProgressEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.formats.TextDecoration;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.project.ProjectType;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugins.build.CompilerPluginBase;
import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
import actionScripts.utils.EnvironmentSetupUtils;
import actionScripts.utils.NoSDKNotifier;
import actionScripts.utils.OSXBookmarkerNotifiers;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;
import components.popup.SelectOpenedFlexProject;
import components.views.project.TreeView;

class MXMLCJavaScriptPlugin extends CompilerPluginBase implements ISettingsProvider {

	override private function get_name():String {
		return 'MXMLC Java Script Compiler Plugin';
	}

	override private function get_author():String {
		return 'Miha Lunar & Moonshine Project Team';
	}

	override private function get_description():String {
		return Std.string(ResourceManager.getInstance().getString('resources', 'plugin.desc.mxmlcjs'));
	}

	public var incrementalCompile:Bool = true;

	private var fcshPath:String = 'js/bin/mxmlc';
	private var cmdFile:File;
	private var _defaultFlexSDK:String;

	public var defaultFlexSDK(get, set):String;
	private function get_defaultFlexSDK():String {
		return _defaultFlexSDK;
	}

	private function set_defaultFlexSDK(value:String):String {
		_defaultFlexSDK = value;
		model.defaultSDK = (_defaultFlexSDK != null) ? new FileLocation(_defaultFlexSDK) : null;
		if (AS3.as(model.defaultSDK, Bool)) {
			model.noSDKNotifier.dispatchEvent(new Event(Std.string(NoSDKNotifier.SDK_SAVED)));
		}
		return value;
	}

	private var fcsh:NativeProcess;
	private var exiting:Bool = false;
	private var shellInfo:NativeProcessStartupInfo;

	private var currentSDK:File;

	/** Project currently under compilation */
	private var currentProject:ProjectVO;
	private var queue:Array<String> = new Array<String>();

	private var fschstr:String;
	private var SDKstr:String;
	private var selectProjectPopup:SelectOpenedFlexProject;
	private var runAfterBuild:Bool = false;

	private var successMessage:String;
	private var isProjectHasInvalidPaths:Bool = false;

	public function new() {
		super();
		if (Settings.os == 'win') {
			fcshPath += '.bat';
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		}//For MacOS
		else {
			//For MacOS
			cmdFile = new File('/bin/bash');
		}

	}

	override public function activate():Void {
		super.activate();

		var tempObj:Dynamic = {};
		Reflect.setField(tempObj, 'callback', runCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Build and run the currently selected Apache Royale® project.');
		registerCommand('runjs', tempObj);

		tempObj = {};
		Reflect.setField(tempObj, 'callback', buildCommand);
		Reflect.setField(tempObj, 'commandDesc', 'Build the currently selected Apache Royale® project.');
		registerCommand('buildjs', tempObj);

		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN_JAVASCRIPT, buildAndRun);
		dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AS_JAVASCRIPT, build);
		reset();
	}

	override public function deactivate():Void {
		super.deactivate();
		reset();
		shellInfo = null;
	}

	override private function onProjectPathsValidated(paths:Array<Dynamic>):Void {
		if (paths != null) {
			isProjectHasInvalidPaths = true;
			error('Following path(s) are invalid or does not exists:\n' + paths.join('\n'));
		}
	}

	public function getSettingsList():Array<ISetting> {
		return [
				new PathSetting(this, 'defaultFlexSDK', 'Default Apache Flex®, Apache Royale® or Feathers SDK', true, null, true),
				new BooleanSetting(this, 'incrementalCompile', 'Incremental Compilation')
		];
	}

	private function runCommand(args:Array<Dynamic>):Void {
		build(null, true);
	}

	private function buildCommand(args:Array<Dynamic>):Void {
		build(null, false);
	}

	private function reset():Void {
		stopShell();
		successMessage = null;
		resourceCopiedIndex = 0;
	}

	private function buildAndRun(e:Event):Void {
		build(e, true);
	}

	private function build(e:Event, runAfterBuild:Bool = false):Void {
		this.isProjectHasInvalidPaths = false;
		this.runAfterBuild = runAfterBuild;
		checkProjectCount();
	}

	private function sdkSelected(event:Event):Void {
		sdkSelectionCancelled(null);
		proceedWithBuild(currentProject);
	}

	private function sdkSelectionCancelled(event:Event):Void {
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
		model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
	}

	private function checkProjectCount():Void {
		function onProjectSelected(event:Event):Void {
			checkForUnsavedEdior(selectProjectPopup.selectedProject);
			onProjectSelectionCancelled(null);
		}; /*
		* @local
		*/
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
			selectProjectPopup.projectType = ProjectType.AS3PROJ_AS_AIR;
			PopUpManager.addPopUp(selectProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
			PopUpManager.centerPopUp(selectProjectPopup);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		} else {
			checkForUnsavedEdior(AS3.as(Reflect.getProperty(model.projects, Std.string(0)), ProjectVO));
		}

		var onProjectSelectionCancelled:Event->Void = function(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		}
	}

	private function checkForUnsavedEdior(activeProject:ProjectVO):Void {
		model.activeProject = activeProject;
		UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
		//UtilsCore.checkForUnsavedEdior(activeProject,proceedWithBuild);
	}

	private function proceedWithBuild(activeProject:ProjectVO = null):Void {
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
			shellInfo.workingDirectory = AS3.as(activeProject.folderLocation.fileBridge.getFile, File);

			initShell();

			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
		// Don't compile if there is no project. Don't warn since other compilers might take the job.
		if (activeProject == null) {
			activeProject = model.activeProject;
		}
		if (activeProject == null || !(Std.is(activeProject, AS3ProjectVO))) {
			return;
		}
		if (AS3.as(AS3ProjectVO(activeProject).isLibraryProject, Bool)) {
			Alert.show('Use \'Build\' instead to build library project.', 'Error!');
			return;
		}

		checkProjectForInvalidPaths(activeProject);
		if (isProjectHasInvalidPaths) {
			return;
		}

		reset();

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			// before proceed, check file access dependencies
			if (!AS3.as(OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([AS3.as(activeProject, AS3ProjectVO)]), 'Access Manager - Build Halt!'), Bool)) {
				Alert.show('Please fix the dependencies before build.', 'Error!');
				return;
			}
		}

		var compileStr:String; /*
		* @local
		*/

		if (fcsh == null || activeProject.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(AS3.as(activeProject, AS3ProjectVO))) {
			currentProject = activeProject;
			var tempCurrentSDK:FileLocation = UtilsCore.getCurrentSDK(AS3.as(activeProject, AS3ProjectVO));
			var sdkReference:SDKReferenceVO = SDKUtils.getSDKReference(tempCurrentSDK);

			currentSDK = null;
			if (tempCurrentSDK == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Apache Royale® SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = AS3.as(tempCurrentSDK.fileBridge.getFile, File);
			var fschFile:File = currentSDK.resolvePath(fcshPath);
			if (!AS3.as(fschFile.exists, Bool)) {
				Alert.show('Invalid SDK - Please configure a Apache Royale® SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Apache Royale® SDK instead');
				return;
			}

			if (!AS3.as(sdkReference.hasPlayerglobal, Bool) && !AS3.as(HelperModel.getInstance().moonshineBridge.playerglobalExists, Bool) && !AS3.as(sdkReference.isJSOnlySdk, Bool)) {
				displayPlayerGlobalError(sdkReference);
				return;
			}

			var targetFile:FileLocation = compile(AS3.as(activeProject, AS3ProjectVO));
			if (targetFile == null) {
				return;
			}
			if (!AS3.as(targetFile.fileBridge.exists, Bool)) {
				error('Couldn\'t find target file');
				return;
			}

			var as3Pvo:AS3ProjectVO = AS3.as(activeProject, AS3ProjectVO);

			UtilsCore.checkIfRoyaleApplication(as3Pvo);
			if (AS3.as(as3Pvo.isFlexJS, Bool) || AS3.as(as3Pvo.isRoyale, Bool)) {
				// FlexJS Application
				shellInfo = new NativeProcessStartupInfo();
				fschstr = Std.string(fschFile.nativePath);
				fschstr = Std.string(UtilsCore.convertString(fschstr));
				SDKstr = Std.string(currentSDK.nativePath);
				SDKstr = Std.string(UtilsCore.convertString(SDKstr));

				// update build config file
				as3Pvo.updateConfig();

				compileStr = getBuildArgs(as3Pvo);
				EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, cast [compileStr]);
			} else {
				//Regular application need proper message
				Alert.show('Invalid SDK - Please configure a Flex SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Flex SDK instead');
				return;
			}
		}
	}

	private function getBuildArgs(project:AS3ProjectVO):String {
		var compileStr:String = '';

		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = AS3.as(UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath), Bool);

		var sdkPathHomeArg:String;
		var enLanguageArg:String = 'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"';
		var compilerPathHomeArg:String = 'FALCON_HOME="' + SDKstr + '"';
		var compilerArg:String = '&& "' + fschstr + '"';
		var configArg:String = ' -load-config+=' + project.folderLocation.fileBridge.getRelativePath(project.config.file);
		var additionalBuildArgs:String = Std.string(project.buildOptions.getArguments());
		additionalBuildArgs = ' ' + StringTools.replace(additionalBuildArgs, '-optimize=false', '');

		var jsCompilationArg:String = '';
		if (isFlexJSAfter7) {
			jsCompilationArg = ' -compiler.targets=JSFlex';

			if (AS3.as(project.isRoyale, Bool)) {
				jsCompilationArg = ' -compiler.targets=JSRoyale';
				sdkPathHomeArg = 'ROYALE_HOME="' + SDKstr + '"';
				compilerPathHomeArg = 'ROYALE_COMPILER_HOME="' + SDKstr + '"';
			}

			jsCompilationArg += Std.string(' -js-output='.concat(project.jsOutputPath));
		}

		if (Settings.os == 'win') {
			compileStr = Std.string(compileStr.concat(
									(sdkPathHomeArg != null) ? ('set ' + sdkPathHomeArg) + '&& ' : '', 'set ', compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
					));
		} else {
			compileStr = Std.string(compileStr.concat(
									(sdkPathHomeArg != null) ? ('export ' + sdkPathHomeArg) + ' && ' : '', 'export ', enLanguageArg, ' && export ', compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
					));
		}

		return compileStr;
	}

	private function clearConsoleBeforeRun():Void {
		if (AS3.as(ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE, Bool)) {
			clearOutput();
		}
		ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE = true;
	}

	private var file:File;
	private var fs:FileStream;

	/**
	 * In the process of copying GBAuth file systems
	 * from AIR 2.0 old location to AIR 16.0
	 * new location, starts the NativeProcess
	 */
	private function onGBAWriteFileCompleted(event:OutputProgressEvent):Void {
		// only when writing completes
		if (event == null || event.bytesPending == 0) {
			if (event != null) {
				event.target.close();
				onFileStreamCompletes(null);
			}

			// declare necessary arguments
			file = File.applicationDirectory.resolvePath('macOScripts/TestMXMLCall.scpt');
			shellInfo = new NativeProcessStartupInfo();
			var arg:Array<String>;

			shellInfo.executable = File.documentsDirectory.resolvePath('/usr/bin/osascript');
			arg = new Array<String>();
			arg.push(file.nativePath);

			// triggers the process
			shellInfo.arguments = arg;

			initShell();
			//setTimeout(proceedWithBuild, 2000, holdProject);
		}
	}

	/**
	 * On file stream error
	 */
	private function handleFSError(event:IOErrorEvent):Void {
		Alert.show(event.text);
		fs.removeEventListener(IOErrorEvent.IO_ERROR, handleFSError);
		fs.removeEventListener(Event.CLOSE, onFileStreamCompletes);
		fs.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onGBAWriteFileCompleted);
	}

	/**
	 * When stream closed/completes
	 */
	private function onFileStreamCompletes(event:Event):Void {
		fs.removeEventListener(IOErrorEvent.IO_ERROR, handleFSError);
		fs.removeEventListener(Event.CLOSE, onFileStreamCompletes);
		fs.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onGBAWriteFileCompleted);
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

	private function compile(pvo:AS3ProjectVO):FileLocation {
		clearConsoleBeforeRun();
		dispatcher.dispatchEvent(new MXMLCPluginEvent(ActionScriptBuildEvent.PREBUILD, new FileLocation(currentSDK.nativePath)));
		print('Compiling ' + pvo.projectName);

		currentProject = pvo;
		if (pvo.targets.length == 0) {
			error('No targets found for compilation.');
			return null;
		}
		var file:FileLocation = Reflect.getProperty(pvo.targets, Std.string(0));
		if (AS3.as(file.fileBridge.exists, Bool)) {
			return file;
		}
		return null;
	}

	private function send(msg:String):Void {
		debug('Sending to mxmlx: %s', msg);
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
			fcsh.exit();
			exiting = true;
			reset();
		} else {
			startShell();
		}
	}

	private function startShell():Void {
		// stop running debug process for run/build if debug process in running
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
			fcsh.exit(true);
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

			printBuildProgress(data);
		}
	}

	private function onSuccesfullBuildCompleted(event:Event):Void {
		if (event != null) {
			event.target.removeEventListener(Event.COMPLETE, onSuccesfullBuildCompleted);
		}

		dispatcher.dispatchEvent(new RefreshTreeEvent((AS3.as(currentProject, AS3ProjectVO)).folderLocation.resolvePath('bin')));
		if (runAfterBuild) {
			launchApplication();
		} else {
			copyingResources();
		}
	}

	private function launchApplication():Void {
		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		var swfFile:File = AS3.as(currentProject.folderLocation.resolvePath(pvo.swfOutput.path.fileBridge.nativePath).fileBridge.getFile, File);

		// before test movie lets copy the resource folder(s)
		// to debug folder if any
		if (pvo.resourcePaths.length != 0 && resourceCopiedIndex == 0) {
			copyingResources();
			return;
		}

		success('Project Build Successfully.');

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
			var urlToLaunch:FileLocation = pvo.htmlPath;
			if (!AS3.as(pvo.htmlPath, Bool)) {
				urlToLaunch = new FileLocation(pvo.urlToLaunch);
			}

			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher deal with playin' the swf
			dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, AS3.as(urlToLaunch.fileBridge.getFile, File), pvo)
			);
		}
		currentProject = null;
		//deactivate();
	}

	private var resourceCopiedIndex:Int = 0;

	private function copyingResources():Void {
		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);

		if (pvo.resourcePaths.length == 0) {
			success('Project Build Successfully.');
			return;
		}

		var buildResultFile:File = AS3.as(currentProject.folderLocation.resolvePath(pvo.getRoyaleDebugPath()).fileBridge.getFile, File);
		var debugDestination:File = buildResultFile.parent;
		var fl:FileLocation = Reflect.getProperty(pvo.resourcePaths, Std.string(resourceCopiedIndex));

		warning('Copying resource: %s', fl.name);

		(AS3.as(fl.fileBridge.getFile, File)).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		(AS3.as(fl.fileBridge.getFile, File)).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
		// copying to bin/bin-debug
		(AS3.as(fl.fileBridge.getFile, File)).copyToAsync(debugDestination.resolvePath(fl.fileBridge.name), true);
	}

	private function onResourcesCopyingComplete(event:Event):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		var pvo:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
		print('Copying %s complete', Reflect.field(event.currentTarget, 'nativePath'));

		resourceCopiedIndex++;
		if (resourceCopiedIndex < pvo.resourcePaths.length) {
			copyingResources();
		} else if (runAfterBuild) {
			dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath('bin')));
			launchApplication();
		} else {
			success('Project Build Successfully.');
			dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath('bin')));
		}
	}

	private function onResourcesCopyingFailed(event:IOErrorEvent):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		error('Copying resources failed %s\n', event.text);
		error('Project Build failed.');
	}

	private function shellError(e:ProgressEvent):Void {
		if (fcsh != null) {
			successMessage = null;
			var output:IDataInput = fcsh.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			printBuildProgress(data);
		}
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		reset();
		if (exiting) {
			exiting = false;
			startShell();
		}
	}

	private function printBuildProgress(data:String):Void {
		var syntaxMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) (Error:|Syntax error:) (.+).+', ''));
		if (syntaxMatch != null) {
			error('%s\n', data);
			return;
		}

		var generalMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('[^:]*:?\s*Error:\s(.*)', 'i'));
		if (syntaxMatch == null && generalMatch != null) {
			error('%s\n', data);
			return;
		}

		var warningMatch:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('WARNING:', 'i'));
		if (warningMatch != null && generalMatch == null && syntaxMatch == null) {
			warning(data);
			return;
		}

		var match:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('successfully compiled and optimized|has been successfully compiled', ''));
		if (match != null) {
			print('%s', data);
			as3hx.Compat.setTimeout(function():Void {
						onSuccesfullBuildCompleted(null);
					}, 100);
			return;
		}

		if (data.charAt(data.length - 1) == '\n') {
			data = data.substr(0, data.length - 1);
		}

		print('%s', data);
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

}