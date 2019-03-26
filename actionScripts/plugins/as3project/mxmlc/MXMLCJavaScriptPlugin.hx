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

import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
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
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
import actionScripts.plugin.project.ProjectType;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
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
class MXMLCJavaScriptPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public var defaultFlexSDK(get, set):String;

	override private function get_name():String {
		return 'MXMLC Java Script Compiler Plugin';
	}

	override private function get_author():String {
		return 'Miha Lunar & Moonshine Project Team';
	}

	override private function get_description():String {
		return ResourceManager.getInstance().getString('resources', 'plugin.desc.mxmlcjs');
	}

	public var incrementalCompile:Bool = true;

	private var fcshPath:String = 'js/bin/mxmlc';

	private var cmdFile:File;

	private var _defaultFlexSDK:String;

	private function get_defaultFlexSDK():String {
		return _defaultFlexSDK;
	}

	private function set_defaultFlexSDK(value:String):String {
		_defaultFlexSDK = value;
		model.defaultSDK = (_defaultFlexSDK != null) ? new FileLocation(_defaultFlexSDK) : null;
		if (model.defaultSDK) {
			model.noSDKNotifier.dispatchEvent(new Event(NoSDKNotifier.SDK_SAVED));
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

	private var runAfterBuild:Bool;

	private var successMessage:String;

	public function new() {
		super();
		if (Settings.os == 'win') {
			fcshPath += '.bat';
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		}
		//For MacOS
		else {

			cmdFile = new File('/bin/bash');
		}
	}

	override public function activate():Void {
		super.activate();

		var tempObj:Dynamic = {};
		tempObj.callback = runCommand;
		tempObj.commandDesc = 'Build and run the currently selected Apache Royale® project.';
		registerCommand('runjs', tempObj);

		tempObj = {};
		tempObj.callback = buildCommand;
		tempObj.commandDesc = 'Build the currently selected Apache Royale® project.';
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
			selectProjectPopup.projectType = ProjectType.AS3PROJ_AS_AIR;
			PopUpManager.addPopUp(selectProjectPopup, try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null, false);
			PopUpManager.centerPopUp(selectProjectPopup);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		} else {
			checkForUnsavedEdior(try cast(model.projects[0], ProjectVO) catch (e:Dynamic) null);
		}

		/*
		* @local
		*/
		function onProjectSelected(event:Event):Void {
			checkForUnsavedEdior(selectProjectPopup.selectedProject);
			onProjectSelectionCancelled(null);
		};

		var onProjectSelectionCancelled:Event->Void = function(event:Event):Void {
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
			selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			selectProjectPopup = null;
		}
	}

	private function checkForUnsavedEdior(activeProject:ProjectVO):Void {
		model.activeProject = activeProject;
		UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
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
		if (cast((activeProject), AS3ProjectVO).isLibraryProject) {
			Alert.show('Use \Build\ instead to build library project.', 'Error!');
			return;
		}

		reset();

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			// before proceed, check file access dependencies
			if (!OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null]), 'Access Manager - Build Halt!')) {
				Alert.show('Please fix the dependencies before build.', 'Error!');
				return;
			}
		}

		var compileStr:String;

		if (fcsh == null || activeProject.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath || usingInvalidSDK(try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null)) {
			currentProject = activeProject;
			var tempCurrentSDK:FileLocation = UtilsCore.getCurrentSDK(try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null);
			currentSDK = null;
			if (tempCurrentSDK == null) {
				model.noSDKNotifier.notifyNoFlexSDK(false);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
				model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
				error('No Apache Royale® SDK found. Setup one in Settings menu.');
				return;
			}

			currentSDK = try cast(tempCurrentSDK.fileBridge.getFile, File) catch (e:Dynamic) null;
			var fschFile:File = currentSDK.resolvePath(fcshPath);
			if (!fschFile.exists) {
				Alert.show('Invalid SDK - Please configure a Apache Royale® SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Apache Royale® SDK instead');
				return;
			}

			var targetFile:FileLocation = compile(try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null);
			if (targetFile == null) {
				return;
			}
			if (!targetFile.fileBridge.exists) {
				error('Couldn\t find target file');
				return;
			}

			var as3Pvo:AS3ProjectVO = try cast(activeProject, AS3ProjectVO) catch (e:Dynamic) null;

			UtilsCore.checkIfRoyaleApplication(as3Pvo);
			if (as3Pvo.isFlexJS)
			// FlexJS Application
			{

				shellInfo = new NativeProcessStartupInfo();
				fschstr = fschFile.nativePath;
				fschstr = UtilsCore.convertString(fschstr);
				SDKstr = currentSDK.nativePath;
				SDKstr = UtilsCore.convertString(SDKstr);

				// update build config file
				as3Pvo.updateConfig();

				compileStr = getBuildArgs(as3Pvo);
				EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compileStr]);
			}
			//Regular application need proper message
			else {

				Alert.show('Invalid SDK - Please configure a Flex SDK instead', 'Error!');
				error('Invalid SDK - Please configure a Flex SDK instead');
				return;
			}
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
			shellInfo.workingDirectory = try cast(activeProject.folderLocation.fileBridge.getFile, File) catch (e:Dynamic) null;

			initShell();

			if (ConstantsCoreVO.IS_MACOS) {
				debug('SDK path: %s', currentSDK.nativePath);
				send(compileStr);
			}
		};
	}

	private function getBuildArgs(project:AS3ProjectVO):String {
		var compileStr:String = '';

		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);

		var sdkPathHomeArg:String;
		var enLanguageArg:String = 'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"';
		var compilerPathHomeArg:String = 'FALCON_HOME="' + SDKstr + '"';
		var compilerArg:String = '&& "' + fschstr + '"';
		var configArg:String = ' -load-config+=' + project.folderLocation.fileBridge.getRelativePath(project.config.file);
		var additionalBuildArgs:String = project.buildOptions.getArguments();
		additionalBuildArgs = ' ' + StringTools.replace(additionalBuildArgs, '-optimize=false', '');

		var jsCompilationArg:String = '';
		if (isFlexJSAfter7) {
			jsCompilationArg = ' -compiler.targets=JSFlex';

			if (project.isRoyale) {
				jsCompilationArg = ' -compiler.targets=JSRoyale';
				sdkPathHomeArg = 'ROYALE_HOME="' + SDKstr + '"';
				compilerPathHomeArg = 'ROYALE_COMPILER_HOME="' + SDKstr + '"';
			}

			jsCompilationArg += ' -js-output='.concat(project.jsOutputPath);
		}

		if (Settings.os == 'win') {
			compileStr = compileStr.concat(
							(sdkPathHomeArg != null) ? ('set ' + sdkPathHomeArg) + '&& ' : '', 'set ', compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
				);
		} else {
			compileStr = compileStr.concat(
							(sdkPathHomeArg != null) ? ('export ' + sdkPathHomeArg) + ' && ' : '', 'export ', enLanguageArg, ' && export ', compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
				);
		}

		return compileStr;
	}

	private function clearConsoleBeforeRun():Void {
		if (ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE) {
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
	private function onGBAWriteFileCompleted(event:OutputProgressEvent):Void
	// only when writing completes
	 {

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
		var customSDK:File = try cast(pvo.buildOptions.customSDK.fileBridge.getFile, File) catch (e:Dynamic) null;
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
		var file:FileLocation = pvo.targets[0];
		if (file.fileBridge.exists) {
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
			fcsh.exit();
			exiting = true;
			reset();
		} else {
			startShell();
		}
	}

	private function startShell():Void
	// stop running debug process for run/build if debug process in running
	 {

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
		if (fcsh != null && fcsh.running) {
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

		dispatcher.dispatchEvent(new RefreshTreeEvent((try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null).folderLocation.resolvePath('bin')));
		if (runAfterBuild) {
			launchApplication();
		} else {
			copyingResources();
		}
	}

	private function launchApplication():Void {
		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		var swfFile:File = try cast(currentProject.folderLocation.resolvePath(pvo.swfOutput.path.fileBridge.nativePath).fileBridge.getFile, File) catch (e:Dynamic) null;

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
			var customArgs:String = customSplit.slice(1).join(' ').replace('$(ProjectName)', pvo.projectName).replace('$(CompilerPath)', currentSDK.nativePath);

			print(customFile + ' ' + customArgs, pvo.folderLocation.fileBridge.nativePath);
		} else if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher deal with playin' the swf
			dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, pvo, currentSDK)
			);
		} else {
			var urlToLaunch:FileLocation = pvo.htmlPath;
			if (!pvo.htmlPath) {
				urlToLaunch = new FileLocation(pvo.urlToLaunch);
			}

			warning('Launching application ' + pvo.name + '.');
			// Let SWFLauncher deal with playin' the swf
			dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, try cast(urlToLaunch.fileBridge.getFile, File) catch (e:Dynamic) null, pvo)
			);
		}
		currentProject = null;
	}

	private var resourceCopiedIndex:Int;

	private function copyingResources():Void {
		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;

		if (pvo.resourcePaths.length == 0) {
			success('Project Build Successfully.');
			return;
		}

		var buildResultFile:File = try cast(currentProject.folderLocation.resolvePath(pvo.getRoyaleDebugPath()).fileBridge.getFile, File) catch (e:Dynamic) null;
		var debugDestination:File = buildResultFile.parent;
		var fl:FileLocation = pvo.resourcePaths[resourceCopiedIndex];

		warning('Copying resource: %s', fl.name);

		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
		// copying to bin/bin-debug
		(try cast(fl.fileBridge.getFile, File) catch (e:Dynamic) null).copyToAsync(debugDestination.resolvePath(fl.fileBridge.name), true);
	}

	private function onResourcesCopyingComplete(event:Event):Void {
		event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
		event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

		var pvo:AS3ProjectVO = try cast(currentProject, AS3ProjectVO) catch (e:Dynamic) null;
		print('Copying %s complete', event.currentTarget.nativePath);

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
		var syntaxMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) (Error:|Syntax error:) (.+).+', ''));
		if (syntaxMatch != null) {
			error('%s\n', data);
			return;
		}

		var generalMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('[^:]*:?\s*Error:\s(.*)', 'i'));
		if (syntaxMatch == null && generalMatch != null) {
			error('%s\n', data);
			return;
		}

		var warningMatch:Array<Dynamic> = data.match(new as3hx.Compat.Regex('WARNING:', 'i'));
		if (warningMatch != null && generalMatch == null && syntaxMatch == null) {
			warning(data);
			return;
		}

		var match:Array<Dynamic> = data.match(new as3hx.Compat.Regex('successfully compiled and optimized|has been successfully compiled', ''));
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

}