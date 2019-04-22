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
package actionScripts.plugins.ant;

import flash.errors.Error;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.AddTabEvent;
import actionScripts.events.NewFileEvent;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.events.RunANTScriptEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugins.ant.events.AntBuildEvent;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.EnvironmentSetupUtils;
import actionScripts.utils.HtmlFormatter;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.Settings;
import components.popup.SelectAntFile;
import components.popup.SelectOpenedFlexProject;

class AntBuildPlugin extends PluginBase implements IPlugin implements ISettingsProvider {

	public static inline var EVENT_ANTBUILD:String = 'antbuildEvent';
	public static inline var SELECTED_PROJECT_ANTBUILD:String = 'selectedProjectAntBuild';

	override private function get_name():String {
		return 'Ant Build Setup';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Apache Ant® Build Plugin. Esc exits.';
	}

	private var cmdFile:File;
	private var shellInfo:NativeProcessStartupInfo;
	private var nativeProcess:NativeProcess;
	private var errors:String = '';
	private var exiting:Bool = false;
	private var antPath:String = 'ant';
	private var workingDir:FileLocation;
	private var selectProjectPopup:SelectOpenedFlexProject;
	private var selectAntPopup:SelectAntFile;
	private var antFiles:ArrayCollection = new ArrayCollection();
	private var currentSDK:FileLocation;
	private var antBuildScreen:IFlexDisplayObject;
	private var isASuccessBuild:Bool = false;
	private var selectedProject:AS3ProjectVO;

	private var _antHomePath:String;
	private var _buildWithAnt:Bool = false;

	public function new() {
		super();
		if (Settings.os == 'win') {
			// in windows
			antPath += '.bat';
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		}// in mac
		else {
			// in mac
			cmdFile = new File('/bin/bash');
		}
	}

	public var antHomePath(get, set):String;
	private function get_antHomePath():String {
		if ((_antHomePath == '' || _antHomePath == null) && AS3.as(ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT, Bool)) {
			antHomePath = Std.string(ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT.nativePath);
		}

		return _antHomePath;
	}

	private function set_antHomePath(value:String):String {
		_antHomePath = value;
		if (_antHomePath == '') {
			model.antHomePath = null;
		} else {
			model.antHomePath = new FileLocation(value);
			EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
		}
		return value;
	}

	override public function activate():Void {
		super.activate();

		dispatcher.addEventListener(RunANTScriptEvent.ANT_BUILD, runAntScriptHandler);
		dispatcher.addEventListener(NewFileEvent.EVENT_ANT_BIN_URL_SET, onAntURLSet);
		dispatcher.addEventListener(SELECTED_PROJECT_ANTBUILD, antBuildForSelectedProject);
		dispatcher.addEventListener(EVENT_ANTBUILD, antBuildFileHandler);

		reset();
	}

	public function getSettingsList():Array<ISetting> {
		return [
				new PathSetting(this, 'antHomePath', 'Ant Home', true, antHomePath)
		];
	}

	override public function deactivate():Void {
		super.deactivate();
		reset();
	}

	override public function resetSettings():Void {
		model.antScriptFile = null;
		antHomePath = '';
	}

	private function reset():Void {
		stopShell();
		shellInfo = null;
		isASuccessBuild = false;
		selectedProject = null;
		model.antScriptFile = null;
	}

	private function onAntURLSet(event:NewFileEvent):Void {
		antHomePath = Std.string(event.filePath);
	}

	// Call from Ant->Ant build Menu
	private function antBuildFileHandler(event:Event):Void {
		_buildWithAnt = false;
		antBuildHandler();
	}

	//Call from Project explorer
	private function runAntScriptHandler(event:Event):Void {
		if (!AS3.as(model.antScriptFile.fileBridge.checkFileExistenceAndReport(), Bool)) {
			return;
		}

		_buildWithAnt = true;
		selectedProject = AS3.as(model.activeProject, AS3ProjectVO);

		antBuildHandler();
	}

	private function antBuildHandler():Void {
		// To check if custom sdk is set or not
		if (_buildWithAnt) {
			if (selectedProject != null) {
				currentSDK = getCurrentSDK(selectedProject);
			}
		} else {
			currentSDK = model.defaultSDK;
		}
		//If Flex_HOME or ANT_HOME is missing
		if (currentSDK == null || !AS3.as(model.antHomePath, Bool)) {
			for (tab in as3hx.Compat.each(model.editors)) {
				if (Reflect.field(tab, 'className') == 'AntBuildScreen') {
					model.activeEditor = tab;
					if (currentSDK != null) {
						(AS3.as(antBuildScreen, AntBuildScreen)).customSDKAvailable = true;
					}
					(AS3.as(antBuildScreen, AntBuildScreen)).refreshValue();
					return;
				}
			}
			antBuildScreen = model.flexCore.getNewAntBuild();
			antBuildScreen.addEventListener(AntBuildEvent.ANT_BUILD, antBuildSelected);

			if (currentSDK != null) {
				(AS3.as(antBuildScreen, AntBuildScreen)).customSDKAvailable = true;
			}

			dispatcher.dispatchEvent(new AddTabEvent(AS3.as(antBuildScreen, IContentWindow)));
		} else {
			antBuildSelected(null);// Start Ant Process
		}
	}

	// For projec Menu
	private function antBuildForSelectedProject(event:Event):Void {
		_buildWithAnt = true;

		if (AS3.as(model.mainView.isProjectViewAdded, Bool)) {
			selectedProject = AS3.as(model.activeProject, AS3ProjectVO);
			//If any project from treeview is selected
			if (selectedProject != null) {
				checkForAntFile(selectedProject);
			} else {
				//Popup of project list if there is not any selected project in Project explorer
				selectProjectPopup = new SelectOpenedFlexProject();
				PopUpManager.addPopUp(selectProjectPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			}
		}
	}

	private function onProjectSelected(event:Event):Void {
		this.selectedProject = Reflect.field(event.currentTarget, 'selectedProject');

		checkForAntFile(AS3.as(selectProjectPopup.selectedProject, AS3ProjectVO));
		onProjectSelectionCancelled(null);
	}

	private function onProjectSelectionCancelled(event:Event):Void {
		selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
		selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
		selectProjectPopup = null;
	}

	private function onAntFileSelected(event:Event):Void {
		//Start build which is selected from Popup
		model.antScriptFile = selectAntPopup.selectedAntFile;
		antBuildHandler();
	}

	private function onAntFileSelectionCancelled(event:Event):Void {
		selectAntPopup.removeEventListener(SelectAntFile.ANTFILE_SELECTED, onAntFileSelected);
		selectAntPopup.removeEventListener(SelectAntFile.ANTFILE_SELECTION_CANCELLED, onAntFileSelectionCancelled);
		selectAntPopup = null;
	}

	private function checkForAntFile(selectedAntProject:AS3ProjectVO):Void {
		function alertListener(eventObj:CloseEvent):Void {
			// Check to see if the OK button was pressed.
			if (eventObj.detail == Alert.YES) {
				model.antScriptFile = null;
				antBuildHandler();
			} else {
				return;
			}
		};
		// Check if Ant file is set for project or not
		var buildFlag:Bool = false;
		var AntFlag:Bool = false;
		antFiles = new ArrayCollection();
		if (!AS3.as(selectedAntProject.antBuildPath, Bool)) {
			// Find build folder within the selected folder
			//find for build.xml file with <project> tag
			for (i in 0...selectedAntProject.projectFolder.children.length) {
				if (Reflect.getProperty(selectedAntProject.projectFolder.children, Std.string(i)).name == 'build') {
					buildFlag = true;
					for (j in 0...Reflect.getProperty(selectedAntProject.projectFolder.children, Std.string(i)).children.length) {
						if (Reflect.getProperty(Reflect.getProperty(selectedAntProject.projectFolder.children, Std.string(i)).children, Std.string(j)).file.fileBridge.extension == 'xml') {
							var str:String = Std.string(Std.string(Reflect.getProperty(Reflect.getProperty(selectedAntProject.projectFolder.children, Std.string(i)).children, Std.string(j)).file.fileBridge.read()));
							if ((str.indexOf('<project ') != -1) || (str.indexOf('<project>') != -1)) {
								// Add xml files in AC.
								AntFlag = true;
								antFiles.addItem(Reflect.getProperty(Reflect.getProperty(selectedAntProject.projectFolder.children, Std.string(i)).children, Std.string(j)).file);
							}
						}
					}
				}
			}
		} else {
			var antFile:FileLocation = selectedAntProject.folderLocation.resolvePath(selectedAntProject.antBuildPath);
			if (AS3.as(antFile.fileBridge.exists, Bool)) {
				model.antScriptFile = selectedAntProject.folderLocation.resolvePath(selectedAntProject.antBuildPath);
				antBuildHandler();
				return;
			} else {
				var buildDir:FileLocation = antFile.fileBridge.parent;
				if (AS3.as(buildDir.fileBridge.exists, Bool)) {
					buildFlag = true;
				}
				AntFlag = false;
			}
		}

		if (buildFlag) {
			if (!AntFlag) {
				Alert.yesLabel = 'Choose Ant File';
				Alert.buttonWidth = 150;
				Alert.show('There is no Ant file found in the selected Project', 'Ant File', Alert.YES | Alert.CANCEL, null, alertListener, null, Alert.CANCEL);
			} else if (antFiles.length > 1) {
				//Open a popup for select Ant file
				selectAntPopup = new SelectAntFile();
				PopUpManager.addPopUp(selectAntPopup, AS3.as(FlexGlobals.topLevelApplication, DisplayObject), false);
				PopUpManager.centerPopUp(selectAntPopup);
				selectAntPopup.antFiles = antFiles;
				selectAntPopup.addEventListener(SelectAntFile.ANTFILE_SELECTED, onAntFileSelected);
				selectAntPopup.addEventListener(SelectAntFile.ANTFILE_SELECTION_CANCELLED, onAntFileSelectionCancelled);
			} else {
				//Start Ant build if there is only one ant file
				// Set Ant file in ModelLocatior
				model.antScriptFile = AS3.as(antFiles.getItemAt(0), FileLocation);
				antBuildHandler();
			}
		}// build flag flase
		else {
			Alert.buttonWidth = 65;
			Alert.show('There is no Build folder in selected Project');
		}

	}

	private function antBuildSelected(event:AntBuildEvent):Void {
		if (event != null) {
			if (event.selectSDK != null) {
				currentSDK = event.selectSDK;
			}

			if (event.antHome != null) {
				antHomePath = Std.string(event.antHome.fileBridge.nativePath);
			}

			if (antBuildScreen != null) {
				dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(antBuildScreen, DisplayObject))
			);
			}
		}

		if (!AS3.as(model.antScriptFile, Bool)) {
			// Open a file chooser for select Ant script file Ant->Configue
			model.fileCore.browseForOpen('Select Build File', selectBuildFile, null, ['*.xml']);
		} else {
			//If Ant file is already selected from AntScreen
			workingDir = new FileLocation(model.antScriptFile.fileBridge.nativePath);
			startAntProcess(workingDir);
		}

		if (antBuildScreen != null) {
			antBuildScreen.removeEventListener(AntBuildEvent.ANT_BUILD, antBuildSelected);
		}
	}

	private function selectBuildFile(fileSelected:Dynamic):Void {
		// If file is open already, just focus that editor.
		startAntProcess(new FileLocation(Reflect.field(fileSelected, 'nativePath')));
	}

	private function getCurrentSDK(pvo:AS3ProjectVO):FileLocation {
		return (AS3.as(pvo.buildOptions.customSDK, Bool)) ? new FileLocation(pvo.buildOptions.customSDK.fileBridge.getFile.nativePath) : ((AS3.as(model.defaultSDK, Bool)) ? new FileLocation(model.defaultSDK.fileBridge.getFile.nativePath) : null);
	}

	private function startAntProcess(buildDir:FileLocation):Void {
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
			shellInfo.workingDirectory = AS3.as(buildDir.fileBridge.parent.fileBridge.getFile, File);

			initShell();

			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				debug('SDK path: %s', currentSDK.fileBridge.nativePath);
				print(compileStr);
			}
		};
		var antBatPath:String = getAntBatPath();
		var sdkPath:String = Std.string(UtilsCore.convertString(currentSDK.fileBridge.nativePath));
		var buildDirPath:String = Std.string(buildDir.fileBridge.nativePath);
		var compileStr:String = '';

		var isFlexJSProject:Bool = AS3.as(currentSDK.resolvePath('js/bin/mxmlc').fileBridge.exists, Bool);
		var isApacheRoyaleSDK:Bool = AS3.as(currentSDK.resolvePath('frameworks/royale-config.xml').fileBridge.exists, Bool);
		var isFlexJSAfter7Arg:String = '';
		var isApacheRoyaleArg:String = '';

		if (!isApacheRoyaleSDK && isFlexJSProject) {
			if (AS3.as(UtilsCore.isNewerVersionSDKThan(7, currentSDK.fileBridge.nativePath), Bool)) {
				isFlexJSAfter7Arg = ' -DIS_FLEXJS_AFTER_7=true';
			}
		}

		if (isApacheRoyaleSDK) {
			isApacheRoyaleArg = ' -DIS_APACHE_ROYALE=true';
			isFlexJSAfter7Arg = ' -DIS_FLEXJS_AFTER_7=true';
		}

		if (Settings.os == 'win') {
			//Create file with following content:
			var antBuildRunnerPath:String = prepareAntBuildRunnerFile(buildDirPath);

			//Created file is being run
			compileStr = Std.string(compileStr.concat(
									antBuildRunnerPath + isFlexJSAfter7Arg + isApacheRoyaleArg
					));
		} else {
			compileStr = Std.string(compileStr.concat(
									antBatPath + ' -file ' + UtilsCore.convertString(buildDirPath) + isFlexJSAfter7Arg + isApacheRoyaleArg
					));
		} /*
		* @local
		*/

		EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, sdkPath, cast [compileStr]);
	}

	private function prepareAntBuildRunnerFile(buildDirPath:String):String {
		var antBatPath:String = getAntBatPath();
		var buildRunnerFileName:String = 'AntBuildRunner.bat';

		if (buildDirPath.indexOf(' ') > -1) {
			try {
				var fileContent:String = antBatPath + ' -f "' + buildDirPath + '"';
				var antBuildRunnerFile:File = new File(File.cacheDirectory.nativePath).resolvePath(buildRunnerFileName);
				var fileContentArray:ByteArray = as3hx.Compat.newByteArray();
				fileContentArray.writeUTFBytes(fileContent);
				var fileRef:FileStream = new FileStream();
				fileRef.open(antBuildRunnerFile, FileMode.WRITE);
				fileRef.writeBytes(fileContentArray);
				fileRef.close();

				return Std.string(antBuildRunnerFile.nativePath);
			} catch (e:Error) {}
		}

		return antBatPath + ' -f ' + buildDirPath;
	}

	private function initShell():Void {
		if (nativeProcess != null) {
			exiting = true;
			reset();
		} else {
			startShell();
		}
	}

	private function startShell():Void {
		if (AS3.as(ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE, Bool)) {
			clearOutput();
		}
		ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE = true;

		nativeProcess = new NativeProcess();
		nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		nativeProcess.start(shellInfo);
		print('Ant build Running');
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		var match:Array<Dynamic> = as3hx.Compat.match(data, new as3hx.Compat.Regex('nativeProcess: Target \\d not found', ''));
		if (match != null) {
			error('Target not found. Try again.');
		}

		match = as3hx.Compat.match(data, new as3hx.Compat.Regex('nativeProcess: Assigned (\\d) as the compile target id', ''));
		if (data != null) {
			match = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*) \\(\\d+? bytes\\)', ''));
			if (match != null) {
				// Successful Build
				print('Done');

			}
		}
		if (data == '(nativeProcess) ') {
			if (errors != '') {
				compilerError(errors);
				errors = '';
			}
		}

		match = as3hx.Compat.match(data, new as3hx.Compat.Regex('BUILD SUCCESSFUL', ''));
		if (match != null) {
			isASuccessBuild = true;
		}

		if (data.charAt(data.length - 1) == '\n') {
			data = data.substr(0, data.length - 1);
		}

		debug('%s', data);
	}

	private function shellError(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		var syntaxMatch:Array<Dynamic>;
		var generalMatch:Array<Dynamic>;
		print(data);
		syntaxMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
		if (syntaxMatch != null) {
			var pathStr:String = Std.string(syntaxMatch[1]);
			var lineNum:Int = AS3.int(syntaxMatch[2]);
			var errorStr:String = Std.string(syntaxMatch[4]);
			pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);
			errors += Std.string(HtmlFormatter.sprintf('%s<weak>:</weak>%s \t %s\n',
							pathStr, lineNum, errorStr
				));
		}

		generalMatch = as3hx.Compat.match(data, new as3hx.Compat.Regex('(.*?): Error: (.*).*', ''));
		if (syntaxMatch == null && generalMatch != null) {
			pathStr = Std.string(generalMatch[1]);
			errorStr = Std.string(generalMatch[2]);
			pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);

			errors += Std.string(HtmlFormatter.sprintf('%s: %s', pathStr, errorStr));
		}

		debug('%s', data);
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		debug('FSCH exit code: %s', e.exitCode);
		if (exiting) {
			exiting = false;
			startShell();
		}

		if (isASuccessBuild && selectedProject != null) {
			print('Files produced under DEPLOY folder.');
			// refresh the build folder
			dispatcher.dispatchEvent(new RefreshTreeEvent(selectedProject.folderLocation.resolvePath('build')));
		}

		reset();
	}

	private function stopShell():Void {
		if (nativeProcess == null) {
			return;
		}
		if (AS3.as(nativeProcess.running, Bool)) {
			nativeProcess.exit();
		}

		nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
		nativeProcess = null;
	}

	private function compilerError(msg:Array<Dynamic> = null):Void {
		var text:String = msg.join(' ');
		var textLines:Array<String> = text.split('\n');
		var lines:Array<TextLineModel> = [];
		for (i in 0...textLines.length) {
			if (textLines[i] == '') {
				continue;
			}
			text = '<error> ⚡  </error>' + textLines[i];
			var lineModel:TextLineModel = new TextLineModel(text);
			lines.push(lineModel);
		}
		outputMsg(lines);
	}

	private function getAntBatPath():String {
		var antFile:FileLocation = model.antHomePath.resolvePath(antPath);
		if (!AS3.as(antFile.fileBridge.exists, Bool)) {
			antFile = model.antHomePath.resolvePath('bin/' + antPath);
		}

		return Std.string(UtilsCore.convertString(antFile.fileBridge.nativePath));
	}

}