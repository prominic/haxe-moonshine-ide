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
package actionScripts.impls;

import haxe.Constraints.Function;

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.Screen;
import flash.display.Stage;
import flash.filesystem.File;
import flash.ui.Keyboard;
import mx.controls.HTML;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import actionScripts.events.ChangeLineEncodingEvent;
import actionScripts.events.LanguageServerMenuEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.RenameEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.events.StartupHelperEvent;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IFlexCoreBridge;
import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
import actionScripts.plugin.actionscript.as3project.clean.CleanProject;
import actionScripts.plugin.actionscript.as3project.files.HiddenFilesPlugin;
import actionScripts.plugin.actionscript.as3project.files.SaveFilesPlugin;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.console.ConsolePlugin;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.core.mouse.MouseManagerPlugin;
import actionScripts.plugin.errors.UncaughtErrorsPlugin;
import actionScripts.plugin.findResources.FindResourcesPlugin;
import actionScripts.plugin.findreplace.FindReplacePlugin;
import actionScripts.plugin.fullscreen.FullscreenPlugin;
import actionScripts.plugin.help.HelpPlugin;
import actionScripts.plugin.organizeImports.OrganizeImportsPlugin;
import actionScripts.plugin.project.ProjectPlugin;
import actionScripts.plugin.projectPanel.ProjectPanelPlugin;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.plugin.rename.RenamePlugin;
import actionScripts.plugin.search.SearchPlugin;
import actionScripts.plugin.settings.SettingsPlugin;
import actionScripts.plugin.splashscreen.SplashScreenPlugin;
import actionScripts.plugin.syntax.AS3SyntaxPlugin;
import actionScripts.plugin.syntax.CSSSyntaxPlugin;
import actionScripts.plugin.syntax.GroovySyntaxPlugin;
import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
import actionScripts.plugin.syntax.JSSyntaxPlugin;
import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
import actionScripts.plugin.syntax.XMLSyntaxPlugin;
import actionScripts.plugin.templating.TemplatingPlugin;
import actionScripts.plugins.ant.AntBuildPlugin;
import actionScripts.plugins.ant.AntBuildScreen;
import actionScripts.plugins.as3project.exporter.FlashBuilderExporter;
import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
import actionScripts.plugins.as3project.mxmlc.MXMLCJavaScriptPlugin;
import actionScripts.plugins.as3project.mxmlc.MXMLCPlugin;
import actionScripts.plugins.away3d.Away3DPlugin;
import actionScripts.plugins.core.ProjectBridgeImplBase;
import actionScripts.plugins.git.GitHubPlugin;
import actionScripts.plugins.help.view.TourDeFlexContentsView;
import actionScripts.plugins.help.view.events.VisualEditorEvent;
import actionScripts.plugins.maven.MavenBuildPlugin;
import actionScripts.plugins.nativeFiles.FileAssociationPlugin;
import actionScripts.plugins.nativeFiles.FilesCopyPlugin;
import actionScripts.plugins.problems.ProblemsPlugin;
import actionScripts.plugins.references.ReferencesPlugin;
import actionScripts.plugins.startup.StartupHelperPlugin;
import actionScripts.plugins.svn.SVNPlugin;
import actionScripts.plugins.swflauncher.SWFLauncherPlugin;
import actionScripts.plugins.symbols.SymbolsPlugin;
import actionScripts.plugins.ui.editor.TourDeTextEditor;
import actionScripts.plugins.visualEditor.PreviewPrimeFacesProjectPlugin;
import actionScripts.plugins.vscodeDebug.VSCodeDebugProtocolPlugin;
import actionScripts.ui.IPanelWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.EnvironmentSetupUtils;
import actionScripts.utils.SHClassTest;
import actionScripts.utils.SWFTrustPolicyModifier;
import actionScripts.utils.SoftwareVersionChecker;
import actionScripts.utils.Untar;
import actionScripts.valueObjects.ConstantsCoreVO;
import components.containers.DownloadNewFlexSDK;
import components.popup.DefineFolderAccessPopup;
import visualEditor.plugin.ExportToFlexPlugin;
import visualEditor.plugin.ExportToPrimeFacesPlugin;
import visualEditor.plugin.VisualEditorRefreshFilesPlugin;
class IFlexCoreBridgeImp extends ProjectBridgeImplBase implements IFlexCoreBridge {

	public var runtimeVersion(get, never):String;
	public var version(get, never):String;

	//--------------------------------------------------------------------------
	//
	//  INTERFACE METHODS
	//
	//--------------------------------------------------------------------------
	public function parseFlashDevelop(project:AS3ProjectVO = null, file:FileLocation = null, projectName:String = null):AS3ProjectVO {
		return FlashDevelopImporter.parse(file, projectName);
	}

	public function parseFlashBuilder(file:FileLocation):AS3ProjectVO {
		return FlashBuilderImporter.parse(file);
	}

	public function testFlashDevelop(file:Dynamic):FileLocation {
		return FlashDevelopImporter.test(try cast(file, File) catch (e:Dynamic) null);
	}

	public function testFlashBuilder(file:Dynamic):FileLocation {
		return FlashBuilderImporter.test(try cast(file, File) catch (e:Dynamic) null);
	}

	public function updateFlashPlayerTrustContent(value:FileLocation):Void {
		SWFTrustPolicyModifier.updatePolicyFile(value.fileBridge.nativePath);
	}

	public function swap(fromIndex:Int, toIndex:Int, myArray:Array<Dynamic>):Void {
		var temp:Dynamic = myArray[toIndex];
		myArray[toIndex] = myArray[fromIndex];
		myArray[fromIndex] = temp;
	}

	public function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):Void {
		FlashDevelopExporter.export(project, file);
	}

	public function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):Void {
		FlashBuilderExporter.export(project, try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null);
	}

	public function getTourDeView():IPanelWindow {
		return (new TourDeFlexContentsView());
	}

	public function getTourDeEditor(swfSource:String):BasicTextEditor {
		return (new TourDeTextEditor(swfSource));
	}

	public function getCorePlugins():Array<Dynamic> {
		return [
		SettingsPlugin,
		ProjectPlugin,
		ProjectPanelPlugin,
		TemplatingPlugin,
		HelpPlugin,
		FindReplacePlugin,
		FindResourcesPlugin,
		RecentlyOpenedPlugin,
		ConsolePlugin,
		FullscreenPlugin,
		AntBuildPlugin,
		MavenBuildPlugin,
		PreviewPrimeFacesProjectPlugin,
		SearchPlugin,
		MouseManagerPlugin,
		ExportToFlexPlugin,
		ExportToPrimeFacesPlugin,
		VisualEditorRefreshFilesPlugin,
		FileAssociationPlugin,
		FilesCopyPlugin,
		UncaughtErrorsPlugin
	];
	}

	public function getDefaultPlugins():Array<Dynamic> {
		return [
		MXMLCPlugin,
		MXMLCJavaScriptPlugin,
		SWFLauncherPlugin,
		AS3ProjectPlugin,
		AS3SyntaxPlugin,
		CSSSyntaxPlugin,
		GroovySyntaxPlugin,
		JSSyntaxPlugin,
		HTMLSyntaxPlugin,
		MXMLSyntaxPlugin,
		XMLSyntaxPlugin,
		OrganizeImportsPlugin,
		SplashScreenPlugin,
		CleanProject,
		SVNPlugin,
		VSCodeDebugProtocolPlugin,
		SaveFilesPlugin,
		ProblemsPlugin,
		SymbolsPlugin,
		ReferencesPlugin,
		StartupHelperPlugin,
		RenamePlugin,
		Away3DPlugin,
		GitHubPlugin,
		HiddenFilesPlugin
	];
	}

	public function getPluginsNotToShowInSettings():Array<Dynamic> {
		return [FileAssociationPlugin, FilesCopyPlugin, ProjectPanelPlugin, ProjectPlugin, HelpPlugin, FindReplacePlugin, FindResourcesPlugin, RecentlyOpenedPlugin, SWFLauncherPlugin, AS3ProjectPlugin, CleanProject, VSCodeDebugProtocolPlugin,
		MXMLCJavaScriptPlugin, ProblemsPlugin, SymbolsPlugin, ReferencesPlugin, StartupHelperPlugin, RenamePlugin, SearchPlugin, OrganizeImportsPlugin, Away3DPlugin, MouseManagerPlugin, ExportToFlexPlugin, ExportToPrimeFacesPlugin,
		UncaughtErrorsPlugin, HiddenFilesPlugin, VisualEditorRefreshFilesPlugin, PreviewPrimeFacesProjectPlugin
	];
	}

	public function getQuitMenuItem():MenuItem {
		return (new MenuItem(ResourceManager.getInstance().getString('resources', 'QUIT'), null, null, MenuPlugin.MENU_QUIT_EVENT, 'q', [Keyboard.COMMAND], 'f4', [Keyboard.ALTERNATE]));
	}

	public function getSettingsMenuItem():MenuItem {
		return (new MenuItem(ResourceManager.getInstance().getString('resources', 'SETTINGS'), null, null, SettingsEvent.EVENT_OPEN_SETTINGS, ',', [Keyboard.COMMAND]));
	}

	public function getAboutMenuItem():MenuItem {
		return (new MenuItem(ResourceManager.getInstance().getString('resources', 'ABOUT'), null, null, MenuPlugin.EVENT_ABOUT));
	}

	public function getWindowsMenu():Array<MenuItem> {
		var resourceManager:IResourceManager = ResourceManager.getInstance();

		var wmn:Array<MenuItem> = [
				new MenuItem(resourceManager.getString('resources', 'FILE'), [
				new MenuItem(resourceManager.getString('resources', 'NEW'), []),
				new MenuItem(resourceManager.getString('resources', 'OPEN'), null, null, OpenFileEvent.OPEN_FILE,
				'o', [Keyboard.COMMAND],
				'o', [Keyboard.CONTROL]),
				new MenuItem(resourceManager.getString('resources', 'OPEN_RECENT_PROJECTS'), []),
				new MenuItem(resourceManager.getString('resources', 'OPEN_RECENT_FILES'), []),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'SAVE'), null, null, MenuPlugin.MENU_SAVE_EVENT,
				's', [Keyboard.COMMAND],
				's', [Keyboard.CONTROL]),
				new MenuItem(resourceManager.getString('resources', 'SAVE_AS'), null, null, MenuPlugin.MENU_SAVE_AS_EVENT,
				's', [Keyboard.COMMAND, Keyboard.SHIFT],
				's', [Keyboard.CONTROL, Keyboard.SHIFT]),
				new MenuItem(resourceManager.getString('resources', 'CLOSE'), null, null, CloseTabEvent.EVENT_CLOSE_TAB,
				'w', [Keyboard.COMMAND],
				'w', [Keyboard.CONTROL]),
				new MenuItem('Close All', null, null, CloseTabEvent.EVENT_CLOSE_ALL_TABS),
				/*new MenuItem("Define Workspace", null, ProjectEvent.SET_WORKSPACE),*/
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'LINE_ENDINGS'), [
				new MenuItem(resourceManager.getString('resources', 'WINDOWS_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN),
				new MenuItem(resourceManager.getString('resources', 'UNIX_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX),
				new MenuItem(resourceManager.getString('resources', 'OS9_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
		])
		]),
				new MenuItem(resourceManager.getString('resources', 'EDIT'), [
				new MenuItem(resourceManager.getString('resources', 'FIND'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], FindReplacePlugin.EVENT_FIND_NEXT,
				'f', [Keyboard.COMMAND],
				'f', [Keyboard.CONTROL]),
				/*new MenuItem(resourceManager.getString('resources','FINDE_PREV'), null, null, FindReplacePlugin.EVENT_FIND_PREV,
				'f', [Keyboard.COMMAND, Keyboard.SHIFT],
				'f', [Keyboard.CONTROL, Keyboard.SHIFT]),*/
				new MenuItem(resourceManager.getString('resources', 'FIND_RESOURCES'), null, null, FindResourcesPlugin.EVENT_FIND_RESOURCES,
				'r', [Keyboard.COMMAND, Keyboard.SHIFT],
				'r', [Keyboard.CONTROL, Keyboard.SHIFT]),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'GO_TO_LINE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], FindReplacePlugin.EVENT_GO_TO_LINE,
				'l', [Keyboard.COMMAND],
				'l', [Keyboard.CONTROL]),
				new MenuItem(resourceManager.getString('resources', 'GO_TO_DEFINITION'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION),
				new MenuItem(resourceManager.getString('resources', 'GO_TO_TYPE_DEFINITION'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'RENAME_SYMBOL'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW),
				new MenuItem(resourceManager.getString('resources', 'ORGANIZE_IMPORTS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS,
				'o', [Keyboard.COMMAND, Keyboard.SHIFT],
				'o', [Keyboard.CONTROL, Keyboard.SHIFT]),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'DUPLICATE'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.VISUAL_EDITOR_FLEX], VisualEditorEvent.DUPLICATE_ELEMENT,
				'u', [Keyboard.COMMAND], 'u', [Keyboard.CONTROL])
		]),
				new MenuItem(resourceManager.getString('resources', 'VIEW'), [
				new MenuItem(resourceManager.getString('resources', 'PROJECT_VIEW'), null, null, ProjectEvent.SHOW_PROJECT_VIEW),
				new MenuItem(resourceManager.getString('resources', 'FULLSCREEN'), null, null, FullscreenPlugin.EVENT_FULLSCREEN),
				new MenuItem(resourceManager.getString('resources', 'PROBLEMS_VIEW'), null, null, ProblemsPlugin.EVENT_PROBLEMS),
				new MenuItem(resourceManager.getString('resources', 'DEBUG_VIEW'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], VSCodeDebugProtocolPlugin.EVENT_SHOW_HIDE_DEBUG_VIEW),
				new MenuItem(resourceManager.getString('resources', 'HOME'), null, null, SplashScreenPlugin.EVENT_SHOW_SPLASH),
				new MenuItem(null),  //separator
				new MenuItem(resourceManager.getString('resources', 'DOCUMENT_SYMBOLS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], SymbolsPlugin.EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW),
				new MenuItem(resourceManager.getString('resources', 'WORKSPACE_SYMBOLS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], SymbolsPlugin.EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW),
				new MenuItem(resourceManager.getString('resources', 'FIND_REFERENCES'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA], ReferencesPlugin.EVENT_OPEN_FIND_REFERENCES_VIEW, 'f7', [Keyboard.COMMAND], 'f7', [Keyboard.ALTERNATE])
		]),
				new MenuItem(resourceManager.getString('resources', 'PROJECT'), [
				new MenuItem(resourceManager.getString('resources', 'OPEN_IMPORT_PROJECT'), null, null, ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT),
				new MenuItem(resourceManager.getString('resources', 'IMPORT_ARCHIVE_PROJECT'), null, null, ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE)
		]),
				new MenuItem(resourceManager.getString('resources', 'DEBUG'), [
				new MenuItem(resourceManager.getString('resources', 'BUILD_AND_DEBUG'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_AND_DEBUG,
				'd', [Keyboard.COMMAND],
				'd', [Keyboard.CONTROL]),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'STEP_OVER'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.DEBUG_STEPOVER,
				'e', [Keyboard.COMMAND],
				'f6', []),
				new MenuItem(resourceManager.getString('resources', 'RESUME'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CONTINUE_EXECUTION,
				'r', [Keyboard.COMMAND],
				'f8', []),
				new MenuItem(resourceManager.getString('resources', 'STOP'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.TERMINATE_EXECUTION,
				't', [Keyboard.COMMAND],
				't', [Keyboard.CONTROL])
		]),
				new MenuItem(resourceManager.getString('resources', 'SUBVERSION'), [
				new MenuItem(((ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_SVN_OSX_AVAILABLE)) ? 'Grant Permission' : resourceManager.getString('resources', 'CHECKOUT'), null, null, SVNPlugin.CHECKOUT_REQUEST),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'COMMIT'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.COMMIT_REQUEST),
				new MenuItem(resourceManager.getString('resources', 'UPDATE'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.UPDATE_REQUEST)
		]),
				new MenuItem(resourceManager.getString('resources', 'GITHUB'), [
				new MenuItem(((ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_GIT_OSX_AVAILABLE)) ? 'Grant Permission' : resourceManager.getString('resources', 'CLONE'), null, null, GitHubPlugin.CLONE_REQUEST),
				/*new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','CHECKOUT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHECKOUT_REQUEST),*/
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'COMMIT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.COMMIT_REQUEST),
				new MenuItem(resourceManager.getString('resources', 'PUSH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PUSH_REQUEST),
				new MenuItem(resourceManager.getString('resources', 'PULL'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PULL_REQUEST),
				new MenuItem(resourceManager.getString('resources', 'REVERT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.REVERT_REQUEST),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources', 'NEW_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.NEW_BRANCH_REQUEST),
				new MenuItem(resourceManager.getString('resources', 'SWITCH_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHANGE_BRANCH_REQUEST)
		]),
				new MenuItem('Others', [
				new MenuItem(resourceManager.getString('resources', 'BUILD_AWAY3D_MODEL'), null, null, Away3DPlugin.OPEN_AWAY3D_BUILDER),
				new MenuItem(resourceManager.getString('resources', 'BUILD_APACHE_ANT'), null, null, AntBuildPlugin.EVENT_ANTBUILD)
		]),
				new MenuItem(resourceManager.getString('resources', 'HELP'), [
				new MenuItem(resourceManager.getString('resources', 'ABOUT'), null, null, MenuPlugin.EVENT_ABOUT),
				new MenuItem('Getting Started', null, null, StartupHelperPlugin.EVENT_GETTING_STARTED),
				new MenuItem(resourceManager.getString('resources', 'USEFUL_LINKS'), null, null, HelpPlugin.EVENT_AS3DOCS),
				new MenuItem(resourceManager.getString('resources', 'TOUR_DE_FLEX'), null, null, HelpPlugin.EVENT_TOURDEFLEX),
				new MenuItem(resourceManager.getString('resources', 'PRIVACY_POLICY'), null, null, HelpPlugin.EVENT_PRIVACY_POLICY)
		])
		];

		// adding in-projet search for desktop only
		if (ConstantsCoreVO.IS_AIR) {
			var projectMenuItems:Array<MenuItem> = wmn[3].items;
			as3hx.Compat.arraySplice(projectMenuItems, 0, 0, [new MenuItem(resourceManager.getString('resources', 'SEARCH_IN_PROJECTS'), null, null, SearchPlugin.SEARCH_IN_PROJECTS,
					'f', [Keyboard.COMMAND, Keyboard.SHIFT],
					'f', [Keyboard.CONTROL, Keyboard.SHIFT])]);
		}

		// add a new menuitem after Access Manager
		// in case of osx and if bundled with sdks
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			var firstMenuItems:Array<MenuItem> = wmn[0].items;
			var i:Int;
			while (i < firstMenuItems.length) {
				if (firstMenuItems[i].label == 'Close All') {
					as3hx.Compat.arraySplice(firstMenuItems, i + 1, 0, [(new MenuItem(null))]);
					as3hx.Compat.arraySplice(firstMenuItems, i + 2, 0, [(new MenuItem('Access Manager', null, null, ProjectEvent.ACCESS_MANAGER))]);
					as3hx.Compat.arraySplice(firstMenuItems, i + 3, 0, [(new MenuItem((ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT) ? 'Extract Bundled SDK' : 'Moonshine Helper Application', null, null, (ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT) ? StartupHelperEvent.EVENT_SDK_UNZIP_REQUEST : StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST))]);
					break;
				}
				i++;
			}
		}

		return wmn;
	}

	public function getHTMLView(url:String):DisplayObject {
		var tmpHTML:HTML = new HTML();
		tmpHTML.location = url;
		return tmpHTML;
	}

	public function getAccessManagerPopup():IFlexDisplayObject {
		return (new DefineFolderAccessPopup());
	}

	public function getSDKInstallerView():IFlexDisplayObject {
		return (new DownloadNewFlexSDK());
	}

	public function getJavaPath(completionHandler:Function):Void {
		var versionChecker:SoftwareVersionChecker = new SoftwareVersionChecker();
		versionChecker.getJavaPath(completionHandler);
	}

	public function reAdjustApplicationSize(width:Float, height:Float):Void {
		var tmpStage:Stage = try cast(FlexGlobals.topLevelApplication.stage, Stage) catch (e:Dynamic) null;
		tmpStage.nativeWindow.width = width;
		tmpStage.nativeWindow.height = height;

		tmpStage.nativeWindow.x = (Screen.mainScreen.visibleBounds.width - width) / 2;
		tmpStage.nativeWindow.y = (Screen.mainScreen.visibleBounds.height - height) / 2;
	}

	public function getNewAntBuild():IFlexDisplayObject {
		return (new AntBuildScreen());
	}

	public function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):Void {
		var tmpUnzip:Untar = new Untar(fileToUnzip, unzipTo, unzipCompleteFunction, unzipErrorFunction);
	}

	public function removeExAttributesTo(path:String):Void {
		var tmp:SHClassTest = new SHClassTest();
		tmp.removeExAttributesTo(path);
	}

	private function get_runtimeVersion():String {
		return NativeApplication.nativeApplication.runtimeVersion;
	}

	private function get_version():String {
		var appDescriptor:FastXML = NativeApplication.nativeApplication.applicationDescriptor;
		var ns:Namespace = new Namespace(appDescriptor.node.namespace.innerData());
		var appVersion:String = appDescriptor.node.ns::versionNumber.innerData;

		return appVersion;
	}

	public function updateToCurrentEnvironmentVariable():Void {
		EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
	}

	public function new() {
		super();
	}

}