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
package actionScripts.plugin.actionscript.as3project.vo;

import flash.events.Event;
import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.controls.LinkButton;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.ICloneable;
import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
import actionScripts.plugin.run.RunMobileSetting;
import actionScripts.plugin.settings.vo.BooleanSetting;
import actionScripts.plugin.settings.vo.BuildActionsListSettings;
import actionScripts.plugin.settings.vo.ColorSetting;
import actionScripts.plugin.settings.vo.DropDownListSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.IntSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.MobileDeviceVO;
import actionScripts.valueObjects.ProjectVO;

class AS3ProjectVO extends ProjectVO implements ICloneable {

	public static inline var CHANGE_CUSTOM_SDK:String = 'CHANGE_CUSTOM_SDK';
	public static inline var NATIVE_EXTENSION_MESSAGE:String = 'NATIVE_EXTENSION_MESSAGE';

	public static inline var TEST_MOVIE_EXTERNAL_PLAYER:String = 'ExternalPlayer';
	public static inline var TEST_MOVIE_CUSTOM:String = 'Custom';
	public static inline var TEST_MOVIE_OPEN_DOCUMENT:String = 'OpenDocument';
	public static inline var TEST_MOVIE_AIR:String = 'AIR';

	@:meta(Bindable())public var isLibraryProject:Bool = false;

	public var fromTemplate:FileLocation;
	public var sourceFolder:FileLocation;
	public var visualEditorSourceFolder:FileLocation;

	public var swfOutput:SWFOutputVO;
	public var buildOptions:BuildOptions;
	public var mavenBuildOptions:MavenBuildOptions;
	public var htmlPath:FileLocation;
	public var customHTMLPath:String;

	public var classpaths:Array<FileLocation> = new Array<FileLocation>();
	public var resourcePaths:Array<FileLocation> = new Array<FileLocation>();
	public var includeLibraries:Array<FileLocation> = new Array<FileLocation>();
	public var libraries:Array<FileLocation> = new Array<FileLocation>();
	public var externalLibraries:Array<FileLocation> = new Array<FileLocation>();
	public var nativeExtensions:Array<FileLocation> = new Array<FileLocation>();
	public var runtimeSharedLibraries:Array<FileLocation> = new Array<FileLocation>();
	public var intrinsicLibraries:Array<String> = new Array<String>();
	public var assetLibrary:FastXMLList;// TODO Unknown if it works in FD, there just for compatibility purposes (<library/> tag)
	public var targets:Array<FileLocation> = new Array<FileLocation>();
	public var hiddenPaths:Array<FileLocation> = new Array<FileLocation>();
	public var projectWithExistingSourcePaths:Array<FileLocation>;
	public var showHiddenPaths:Bool = false;
	public var filesList:ArrayCollection;// all acceptable files list those can be opened in Moonshine editor (mainly generates for VisualEditor project)

	public var prebuildCommands:String;
	public var postbuildCommands:String;
	public var postbuildAlways:Bool = false;
	public var isFlexJS:Bool = false;
	public var isMDLFlexJS:Bool = false;
	public var isRoyale:Bool = false;

	public var testMovie:String = TEST_MOVIE_EXTERNAL_PLAYER;
	public var testMovieCommand:String;
	public var defaultBuildTargets:String;

	public var config:MXMLCConfigVO;

	public var flashBuilderProperties:FastXML;
	public var flashDevelopObjConfig:FastXML;
	public var isFlashBuilderProject:Bool = false;
	public var flashBuilderDOCUMENTSPath:String;

	public var isMobile:Bool = false;
	public var isProjectFromExistingSource:Bool = false;
	public var isVisualEditorProject:Bool = false;
	public var isActionScriptOnly:Bool = false;
	public var isPrimeFacesVisualEditorProject:Bool = false;
	public var isPreviewRunning:Bool = false;
	public var isExportedToExistingSource:Bool = false;
	public var isTrustServerCertificateSVN:Bool = false;
	public var visualEditorExportPath:String;

	private var additional:StringSetting;
	private var htmlFilePath:PathSetting;
	private var customHTMLFilePath:StringSetting;
	private var outputPathSetting:PathSetting;
	private var jsOutputPathSetting:PathSetting;
	private var nativeExtensionPath:PathListSetting;
	private var mobileRunSettings:RunMobileSetting;
	private var targetPlatformSettings:DropDownListSetting;

	private var _jsOutputPath:String;
	private var _urlToLaunch:String;

	public var air(get, set):Bool;
	private function get_air():Bool {
		return UtilsCore.isAIR(this);
	}

	private function set_air(v:Bool):Bool {
		this.testMovie = (v) ? TEST_MOVIE_AIR : '';
		return v;
	}

	public var customSDKPath(get, set):String;
	private function get_customSDKPath():String {
		return buildOptions.customSDKPath;
	}

	private function set_customSDKPath(value:String):String {
		if (buildOptions.customSDKPath == value) {
			return value;
		}
		buildOptions.customSDKPath = value;
		swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(value);
		this.dispatchEvent(new Event(CHANGE_CUSTOM_SDK));
		return value;
	}

	public var antBuildPath(get, set):String;
	private function get_antBuildPath():String {
		return buildOptions.antBuildPath;
	}

	private function set_antBuildPath(value:String):String {
		buildOptions.antBuildPath = value;
		return value;
	}

	public var isSVN(get, never):Bool;
	private function get_isSVN():Bool {
		if (menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) != -1) {
			return true;
		}
		return false;
	}

	override private function get_name():String {
		return projectName;
	}

	private var configInvalid:Bool = true;

	private var _targetPlatform:String;

	public var targetPlatform(get, set):String;
	private function set_targetPlatform(value:String):String {
		_targetPlatform = value;
		return value;
	}

	private function get_targetPlatform():String {
		return _targetPlatform;
	}

	private var _isMobileRunOnSimulator:Bool = true;

	public var isMobileRunOnSimulator(get, set):Bool;
	private function set_isMobileRunOnSimulator(value:Bool):Bool {
		_isMobileRunOnSimulator = value;
		return value;
	}

	private function get_isMobileRunOnSimulator():Bool {
		return _isMobileRunOnSimulator;
	}

	private var _isMobileHasSimulatedDevice:MobileDeviceVO;

	public var isMobileHasSimulatedDevice(get, set):MobileDeviceVO;
	private function set_isMobileHasSimulatedDevice(value:MobileDeviceVO):MobileDeviceVO {
		_isMobileHasSimulatedDevice = value;
		return value;
	}

	private function get_isMobileHasSimulatedDevice():MobileDeviceVO {
		return _isMobileHasSimulatedDevice;
	}

	public var platformTypes(get, never):ArrayCollection;
	private function get_platformTypes():ArrayCollection {
		var tmpCollection:ArrayCollection;
		//additional.isEditable = air;
		htmlFilePath.isEditable = !air && !isLibraryProject;
		customHTMLFilePath.isEditable = !air && !isLibraryProject;
		nativeExtensionPath.isEditable = air;
		mobileRunSettings.visible = isMobile;

		if (!air) {
			tmpCollection = new ArrayCollection([
					new NameValuePair('Web', AS3ProjectPlugin.AS3PROJ_AS_WEB)
			]);
		} else if (isMobile) {
			tmpCollection = new ArrayCollection([
					new NameValuePair('Android', AS3ProjectPlugin.AS3PROJ_AS_ANDROID),
					new NameValuePair('iOS', AS3ProjectPlugin.AS3PROJ_AS_IOS)
			]);
		} else {
			tmpCollection = new ArrayCollection([
					new NameValuePair('AIR', AS3ProjectPlugin.AS3PROJ_AS_AIR)
			]);
		}

		return tmpCollection;
	}

	public var urlToLaunch(get, set):String;
	private function get_urlToLaunch():String {
		if (_urlToLaunch == null) {
			if (!air && !isLibraryProject) {
				var html:FileLocation = (!isRoyale) ?
				folderLocation.fileBridge.resolvePath(folderLocation.fileBridge.separator
						+ 'bin-debug'
						+ folderLocation.fileBridge.separator
						+
						Reflect.getProperty(swfOutput.path.fileBridge.name.split('.'), Std.string(0)) + '.html') : new FileLocation(getRoyaleDebugPath());
				htmlPath = html;

				return Std.string(html.fileBridge.nativePath);
			}
		}

		return _urlToLaunch;
	}

	private function set_urlToLaunch(value:String):String {
		if (value != null) {
			_urlToLaunch = value;
		} else {}
		return value;
	}

	public var outputPath(get, set):String;
	private function get_outputPath():String {
		var tmpPath:String = Std.string(this.folderLocation.fileBridge.getRelativePath(swfOutput.path.fileBridge.parent));
		if (tmpPath == null) {
			tmpPath = Std.string(swfOutput.path.fileBridge.parent.fileBridge.nativePath);
		}
		return tmpPath;
	}

	private function set_outputPath(value:String):String {
		if (value == null || value == '') {
			return value;
		}

		var fileNameSplit:Array<Dynamic> = swfOutput.path.fileBridge.nativePath.split(folderLocation.fileBridge.separator);
		swfOutput.path = new FileLocation(value + folderLocation.fileBridge.separator + fileNameSplit[fileNameSplit.length - 1]);
		return value;
	}

	public var jsOutputPath(get, set):String;
	private function get_jsOutputPath():String {
		var tmpPath:String = Std.string(this.folderLocation.fileBridge.getRelativePath(new FileLocation(_jsOutputPath)));
		if (tmpPath != null) {
			return tmpPath;
		}

		return _jsOutputPath;
	}

	private function set_jsOutputPath(value:String):String {
		if (value == null) {
			return value;
		}

		_jsOutputPath = value;
		return value;
	}

	public function getRoyaleDebugPath():String {
		var indexHtmlPath:String = Std.string(folderLocation.fileBridge.separator.concat('bin',
						folderLocation.fileBridge.separator, 'js-debug',
						folderLocation.fileBridge.separator, 'index.html'
			));
		return Std.string(jsOutputPath.concat(indexHtmlPath));
	}

	private function onTargetPlatformChanged(event:Event):Void {
		if (mobileRunSettings != null) {
			mobileRunSettings.updateDevices(targetPlatformSettings.stringValue);
			buildOptions.isMobileHasSimulatedDevice = ((targetPlatformSettings.stringValue == null || targetPlatformSettings.stringValue == 'Android')) ? Reflect.getProperty(ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES, Std.string(0)) : Reflect.getProperty(ConstantsCoreVO.TEMPLATES_IOS_DEVICES, Std.string(0));
		}
	}

	public function new(folder:FileLocation, projectName:String = null, updateToTreeView:Bool = true) {
		super(folder, projectName, updateToTreeView);

		swfOutput = new SWFOutputVO();
		buildOptions = new BuildOptions();
		mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);

		config = new MXMLCConfigVO();

		projectReference.hiddenPaths = this.hiddenPaths;
		projectReference.showHiddenPaths = this.showHiddenPaths = model.showHiddenPaths;
		jsOutputPath = projectFolder.nativePath;
	}

	override public function getSettings():Array<SettingsWrapper> {
		function order(a:Dynamic, b:Dynamic):Float {
			if (Reflect.field(a, 'name') < Reflect.field(b, 'name')) {
				return -1;
			} else if (Reflect.field(a, 'name') > Reflect.field(b, 'name')) {
				return 1;
			}
			return 0;
		};
		// TODO more categories / better setting UI
		var settings:Array<SettingsWrapper>;

		if (additional != null) {
			additional = null;
		}
		if (htmlFilePath != null) {
			htmlFilePath = null;
		}
		if (outputPathSetting != null) {
			outputPathSetting = null;
		}
		if (jsOutputPathSetting != null) {
			jsOutputPathSetting = null;
		}
		if (nativeExtensionPath != null) {
			nativeExtensionPath = null;
		}
		if (mobileRunSettings != null) {
			mobileRunSettings = null;
		}
		if (targetPlatformSettings != null) {
			targetPlatformSettings = null;
		}

		additional = new StringSetting(buildOptions, 'additional', 'Additional compiler options');
		htmlFilePath = new PathSetting(this, 'urlToLaunch', 'URL to Launch', false, urlToLaunch);
		customHTMLFilePath = new StringSetting(this, 'customHTMLPath', 'Custom URL to Launch');
		customHTMLFilePath.setMessage('Leave this blank if you don\'t override \'URL to Launch\'\nIf calling a server, prefix the URL with http:// or https://');

		outputPathSetting = new PathSetting(this, 'outputPath', 'Output Path', true, outputPath);
		nativeExtensionPath = getExtensionsSettings();
		mobileRunSettings = new RunMobileSetting(buildOptions, 'Launch Method');
		targetPlatformSettings = new DropDownListSetting(buildOptions, 'targetPlatform', 'Platform', platformTypes, 'name');

		if (isRoyale) {
			jsOutputPathSetting = new PathSetting(this, 'jsOutputPath', 'JavaScript Output Path', true, jsOutputPath);
		}

		if (isLibraryProject) {
			targetPlatformSettings.isEditable = false;
		} else {
			targetPlatformSettings.addEventListener(Event.CHANGE, onTargetPlatformChanged, false, 0, true);
		}

		if (isVisualEditorProject) {
			settings = cast getSettingsForVisualEditorTypeOfProjects();
		} else if (!isFlashBuilderProject) {
			settings = cast getSettingsForNonFlashBuilderProject();
		} else {
			settings = cast getSettingsForOtherTypeOfProjects();
		}

		generateSettingsForSVNProject(cast settings);
		settings.sort(order); /*
		* @local
		*/
		return settings;
	}

	override public function saveSettings():Void {
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			// @devsena
			// 02/08/2017 (mm/dd/yyyy)
			// since .actionScriptProperties file do not accept any
			// unrelated or unknown tags to be include in it's file
			// and taken as a corrupt file when try to open in Flash Builder,
			// we have no choice to include any extra tags/properties
			// to the file.
			// but we do need to save many fields/properties those we
			// have in project's settings screen and .actionScriptProperties
			// file do not have any placeholder for them.
			// thus from today we shall save project settings only to .as3proj
			// file where we can include custom fields; irrespective of the
			// project type - flash builder or flash develop.
			// also we shall take .as3proj file if exists to project opening,
			// even there's an .actionScriptProperties file exists

			var projectFileName:String = (this.isVisualEditorProject) ? projectName + '.veditorproj' : projectName + '.as3proj';
			var settingsFile:FileLocation = folderLocation.resolvePath(projectFileName);
			// Write settings
			model.flexCore.exportFlashDevelop(this, settingsFile);
			//}
		}

		if (targetPlatformSettings != null) {
			targetPlatformSettings.removeEventListener(Event.CHANGE, onTargetPlatformChanged);
		}
	}

	public function updateConfig():Void {
		/*if (configInvalid)
		{*/
		config.write(this);
		configInvalid = false;
		//}
	}

	private function dispatchNativeExtensionMessageRequest(event:MouseEvent):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new Event(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE));
	}

	private function getSettingsForNonFlashBuilderProject():Array<SettingsWrapper> {
		var settings:Array<SettingsWrapper> = [

				new SettingsWrapper('Build options',
				[
						new PathSetting(this, 'customSDKPath', 'Custom SDK', true, buildOptions.customSDKPath, true),
						additional,

						new StringSetting(buildOptions, 'compilerConstants', 'Compiler constants'),

						new BooleanSetting(buildOptions, 'accessible', 'Accessible SWF generation'),
						new BooleanSetting(buildOptions, 'allowSourcePathOverlap', 'Allow source path overlap'),
						new BooleanSetting(buildOptions, 'benchmark', 'Benchmark'),
						new BooleanSetting(buildOptions, 'es', 'ECMAScript edition 3 prototype based object model (es)'),
						new BooleanSetting(buildOptions, 'optimize', 'Optimize'),

						new BooleanSetting(buildOptions, 'useNetwork', 'Enable network access'),
						new BooleanSetting(buildOptions, 'useResourceBundleMetadata', 'Use resource bundle metadata'),
						new BooleanSetting(buildOptions, 'verboseStackTraces', 'Verbose stacktraces'),
						new BooleanSetting(buildOptions, 'staticLinkRSL', 'Static link runtime shared libraries'),

						new StringSetting(buildOptions, 'linkReport', 'Link report XML file'),
						new StringSetting(buildOptions, 'loadConfig', 'Load config')
			]),
				new SettingsWrapper('Ant Build', [
						new PathSetting(this, 'antBuildPath', 'Ant Build File', false, this.antBuildPath, false)
			]),
				new SettingsWrapper('Maven Build', [
						new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, 'mavenBuildPath', 'Maven Build File', this.mavenBuildOptions.mavenBuildPath),
						new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, 'commandLine', 'Build Actions'),
						new PathSetting(this.mavenBuildOptions, 'settingsFilePath', 'Maven Settings File', false, this.mavenBuildOptions.settingsFilePath, false)
			]),
				new SettingsWrapper('Paths',
				[
						new PathListSetting(this, 'classpaths', 'Class paths', folderLocation, false, true, true, true),
						new PathListSetting(this, 'resourcePaths', 'Resource folders', folderLocation, false),
						new PathListSetting(this, 'externalLibraries', 'External libraries', folderLocation, true, false),
						new PathListSetting(this, 'libraries', 'Libraries', folderLocation),
						nativeExtensionPath
			]),
				new SettingsWrapper('Warnings & Errors',
				[
						new BooleanSetting(buildOptions, 'showActionScriptWarnings', 'Show actionscript warnings'),
						new BooleanSetting(buildOptions, 'showBindingWarnings', 'Show binding warnings'),
						new BooleanSetting(buildOptions, 'showDeprecationWarnings', 'Show deprecation warnings'),
						new BooleanSetting(buildOptions, 'showUnusedTypeSelectorWarnings', 'Show unused type selector warnings'),
						new BooleanSetting(buildOptions, 'warnings', 'Show all warnings'),
						new BooleanSetting(buildOptions, 'strict', 'Strict error checking')
			])
		];

		var runSettingsContent:Array<ISetting> = [
				targetPlatformSettings,
				htmlFilePath,
				customHTMLFilePath,
				outputPathSetting
		];

		var runSettings:SettingsWrapper = new SettingsWrapper('Run', runSettingsContent);
		if (this.isRoyale) {
			runSettingsContent.insert(4, jsOutputPathSetting);
		} else {
			runSettingsContent.push(mobileRunSettings);
		}

		settings.push(runSettings);

		if (!isMDLFlexJS) {
			settings.unshift(new SettingsWrapper('Output',
					[
							new IntSetting(swfOutput, 'frameRate', 'Framerate (FPS)'),
							new IntSetting(swfOutput, 'width', 'Width'),
							new IntSetting(swfOutput, 'height', 'Height'),
							new ColorSetting(swfOutput, 'background', 'Background color'),
							new IntSetting(swfOutput, 'swfVersion', 'Minimum player version')
				]));
		}

		return settings;
	}

	private function getSettingsForOtherTypeOfProjects():Array<SettingsWrapper> {
		return [
				new SettingsWrapper('Build options',
				[
						new PathSetting(this, 'customSDKPath', 'Custom SDK', true, buildOptions.customSDKPath, true),
						additional,

						new StringSetting(buildOptions, 'compilerConstants', 'Compiler constants'),

						new BooleanSetting(buildOptions, 'accessible', 'Accessible SWF generation'),
						new BooleanSetting(buildOptions, 'allowSourcePathOverlap', 'Allow source path overlap'),
						new BooleanSetting(buildOptions, 'benchmark', 'Benchmark'),
						new BooleanSetting(buildOptions, 'es', 'ECMAScript edition 3 prototype based object model (es)'),
						new BooleanSetting(buildOptions, 'optimize', 'Optimize'),

						new BooleanSetting(buildOptions, 'useNetwork', 'Enable network access'),
						new BooleanSetting(buildOptions, 'useResourceBundleMetadata', 'Use resource bundle metadata'),
						new BooleanSetting(buildOptions, 'verboseStackTraces', 'Verbose stacktraces'),
						new BooleanSetting(buildOptions, 'staticLinkRSL', 'Static link runtime shared libraries'),

						new StringSetting(buildOptions, 'linkReport', 'Link report XML file'),
						new StringSetting(buildOptions, 'loadConfig', 'Load config')
			]),
				new SettingsWrapper('Ant Build', [
						new PathSetting(this, 'antBuildPath', 'Ant Build File', false, this.antBuildPath, false)
			]),
				new SettingsWrapper('Maven Build', [
						new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, 'mavenBuildPath', 'Maven Build File', this.mavenBuildOptions.mavenBuildPath),
						new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, 'commandLine', 'Build Actions'),
						new PathSetting(this.mavenBuildOptions, 'settingsFilePath', 'Maven Settings File', false, this.mavenBuildOptions.settingsFilePath, false)
			]),
				new SettingsWrapper('Paths',
				[
						new PathListSetting(this, 'classpaths', 'Class paths', folderLocation, false, true, true, true),
						new PathListSetting(this, 'resourcePaths', 'Resource folders', folderLocation, false),
						new PathListSetting(this, 'externalLibraries', 'External libraries', folderLocation, true, false),
						new PathListSetting(this, 'libraries', 'Libraries', folderLocation),
						nativeExtensionPath
			]),
				new SettingsWrapper('Warnings & Errors',
				[
						new BooleanSetting(buildOptions, 'warnings', 'Show all warnings'),
						new BooleanSetting(buildOptions, 'strict', 'Strict error checking')
			]),
				new SettingsWrapper('Run',
				[
						new DropDownListSetting(this, 'targetPlatform', 'Platform', platformTypes, 'name'),
						htmlFilePath,
						customHTMLFilePath,
						outputPathSetting,
						mobileRunSettings
			])
		];
	}

	private function getSettingsForVisualEditorTypeOfProjects():Array<SettingsWrapper> {
		return [
				new SettingsWrapper('Paths',
				[
						new PathListSetting(this, 'classpaths', 'Class paths', folderLocation, false, true, true, true),
						new PathSetting(this, 'visualEditorExportPath', 'Export Path', true, visualEditorExportPath)
			]),
				new SettingsWrapper('Maven Build', [
						new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, 'mavenBuildPath', 'Maven Build File', this.mavenBuildOptions.mavenBuildPath),
						new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, 'commandLine', 'Build Actions'),
						new PathSetting(this.mavenBuildOptions, 'settingsFilePath', 'Maven Settings File', false, this.mavenBuildOptions.settingsFilePath, false)
			])
		];
	}

	private function generateSettingsForSVNProject(value:Array<SettingsWrapper>):Void {
		if (isSVN) {
			value.insert(value.length - 2, new SettingsWrapper('Subversion',
					[
							new BooleanSetting(this, 'isTrustServerCertificateSVN', 'Trust server certificate')
				]));
		}
	}

	private function getExtensionsSettings():PathListSetting {
		var nativeExtensionSettings:PathListSetting = new PathListSetting(this, 'nativeExtensions', 'Native extensions folder', folderLocation, false, true);
		var tmpLinkLabel:LinkButton = new LinkButton();
		tmpLinkLabel.label = '(See how Moonshine supports native extensions)';
		tmpLinkLabel.setStyle('color', 0x8e3b4e);
		tmpLinkLabel.addEventListener(MouseEvent.CLICK, dispatchNativeExtensionMessageRequest, false, 0, true);
		nativeExtensionSettings.customMessage = tmpLinkLabel;

		return nativeExtensionSettings;
	}

	public function clone():Dynamic {
		var as3Project:AS3ProjectVO = new AS3ProjectVO(this.folderLocation, this.projectName, true);

		as3Project.fromTemplate = this.fromTemplate;
		as3Project.sourceFolder = new FileLocation(Std.string(this.sourceFolder.fileBridge.nativePath));

		if (this.visualEditorSourceFolder != null) {
			as3Project.visualEditorSourceFolder = new FileLocation(Std.string(this.visualEditorSourceFolder.fileBridge.nativePath));
		}

		as3Project.swfOutput = this.swfOutput;
		as3Project.buildOptions = this.buildOptions;

		if (this.htmlPath != null) {
			as3Project.htmlPath = new FileLocation(Std.string(this.htmlPath.fileBridge.nativePath));
		}

		as3Project.customHTMLPath = this.customHTMLPath;
		as3Project.classpaths = this.classpaths.slice(0, this.classpaths.length);
		as3Project.resourcePaths = this.resourcePaths.slice(0, this.resourcePaths.length);
		as3Project.includeLibraries = this.includeLibraries.slice(0, this.includeLibraries.length);
		as3Project.libraries = this.libraries.slice(0, this.libraries.length);
		as3Project.externalLibraries = this.externalLibraries.slice(0, this.externalLibraries.length);
		as3Project.nativeExtensions = this.nativeExtensions.slice(0, this.nativeExtensions.length);
		as3Project.runtimeSharedLibraries = cast this.runtimeSharedLibraries.splice(0, this.runtimeSharedLibraries.length);
		as3Project.intrinsicLibraries = this.intrinsicLibraries.slice(0, this.intrinsicLibraries.length);
		as3Project.node.assetLibrary = this.node.assetLibrary.copy();
		as3Project.targets = this.targets.slice(0, this.targets.length);
		as3Project.hiddenPaths = this.hiddenPaths.slice(0, this.hiddenPaths.length);

		if (this.projectWithExistingSourcePaths != null) {
			as3Project.projectWithExistingSourcePaths = this.projectWithExistingSourcePaths.slice(0, this.projectWithExistingSourcePaths.length);
		}

		as3Project.showHiddenPaths = this.showHiddenPaths;

		as3Project.prebuildCommands = this.prebuildCommands;
		as3Project.postbuildCommands = this.postbuildCommands;
		as3Project.postbuildAlways = this.postbuildAlways;
		as3Project.isFlexJS = this.isFlexJS;
		as3Project.isMDLFlexJS = this.isMDLFlexJS;
		as3Project.isRoyale = this.isRoyale;

		as3Project.testMovie = this.testMovie;
		as3Project.testMovieCommand = this.testMovieCommand;
		as3Project.defaultBuildTargets = this.defaultBuildTargets;

		as3Project.config = new MXMLCConfigVO(new FileLocation(Std.string(this.config.file.fileBridge.nativePath)));

		as3Project.flashBuilderProperties = (this.flashBuilderProperties != null) ? this.flashBuilderProperties.copy() : null;
		as3Project.flashDevelopObjConfig = (this.flashDevelopObjConfig != null) ? this.flashDevelopObjConfig.copy() : null;
		as3Project.isFlashBuilderProject = this.isFlashBuilderProject;
		as3Project.flashBuilderDOCUMENTSPath = this.flashBuilderDOCUMENTSPath;

		as3Project.isMobile = this.isMobile;
		as3Project.isProjectFromExistingSource = this.isProjectFromExistingSource;
		as3Project.isVisualEditorProject = this.isVisualEditorProject;
		as3Project.isLibraryProject = this.isLibraryProject;
		as3Project.isActionScriptOnly = this.isActionScriptOnly;
		as3Project.isPrimeFacesVisualEditorProject = this.isPrimeFacesVisualEditorProject;
		as3Project.isExportedToExistingSource = this.isExportedToExistingSource;
		as3Project.visualEditorExportPath = this.visualEditorExportPath;

		as3Project.additional = this.additional;

		if (this.htmlFilePath != null) {
			as3Project.htmlFilePath = new PathSetting(this.htmlFilePath.provider,
					this.htmlFilePath.name, this.htmlFilePath.label,
					this.htmlFilePath.directory, this.htmlFilePath.path);
		}

		if (this.outputPathSetting != null) {
			as3Project.outputPathSetting = new PathSetting(this.outputPathSetting.provider,
					this.outputPathSetting.name, this.outputPathSetting.label,
					this.outputPathSetting.directory, this.outputPathSetting.path);
		}

		if (this.nativeExtensionPath != null) {
			as3Project.nativeExtensionPath = new PathListSetting(this.nativeExtensionPath.provider,
					this.nativeExtensionPath.name, this.nativeExtensionPath.label, this.nativeExtensionPath.relativeRoot,
					this.nativeExtensionPath.allowFiles, this.nativeExtensionPath.allowFolders, this.nativeExtensionPath.fileMustExist,
					this.nativeExtensionPath.displaySourceFolder);
		}

		if (this.mobileRunSettings != null && !this.isVisualEditorProject) {
			as3Project.mobileRunSettings = new RunMobileSetting(this.mobileRunSettings.provider,
					this.mobileRunSettings.label, new FileLocation(Std.string(this.mobileRunSettings.relativeRoot.fileBridge.nativePath)));
			as3Project.mobileRunSettings.project = as3Project;
		}

		if (this.targetPlatformSettings != null) {
			as3Project.targetPlatformSettings = new DropDownListSetting(this.targetPlatformSettings.provider,
					this.targetPlatformSettings.name, this.targetPlatformSettings.label,
					this.targetPlatformSettings.dataProvider, this.targetPlatformSettings.labelField);
		}

		return as3Project;
	}

}