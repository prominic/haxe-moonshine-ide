package actionScripts.ui.menu;

import actionScripts.events.ExportVisualEditorProjectEvent;
import actionScripts.events.MavenBuildEvent;
import actionScripts.events.PreviewPluginEvent;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
import actionScripts.plugin.core.compiler.JavaBuildEvent;
import actionScripts.plugin.core.compiler.ProjectActionEvent;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.valueObjects.ProjectVO;
import flash.ui.Keyboard;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

class ProjectMenu {

	private var actionScriptMenu:Array<MenuItem>;
	private var libraryMenu:Array<MenuItem>;
	private var royaleMenu:Array<MenuItem>;
	private var vePrimeFaces:Array<MenuItem>;
	private var veFlex:Array<MenuItem>;
	private var javaMenu:Array<MenuItem>;

	private var currentProject:ProjectVO;

	public function getProjectMenuItems(project:ProjectVO):Array<MenuItem> {
		currentProject = project;

		var as3Project:AS3ProjectVO = AS3.as(project, AS3ProjectVO);
		if (as3Project != null) {
			if (as3Project.isLibraryProject) {
				return cast getASLibraryMenuItems();
			} else if (as3Project.isRoyale) {
				return cast getRoyaleMenuItems();
			} else if (as3Project.isVisualEditorProject) {
				if (as3Project.isPrimeFacesVisualEditorProject) {
					return cast getVisualEditorMenuPrimeFacesItems();
				}

				return cast getVisualEditorMenuFlexItems();
			} else {
				return cast getASProjectMenuItems();
			}
		}

		var javaProject:JavaProjectVO = AS3.as(project, JavaProjectVO);
		if (javaProject != null) {
			return cast getJavaMenuItems();
		}

		return null;
	}

	private function getASProjectMenuItems():Array<MenuItem> {
		if (actionScriptMenu == null) {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			actionScriptMenu = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
							'b', cast [Keyboard.COMMAND],
							'b', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_AND_RUN')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN,
							'\n', cast [Keyboard.COMMAND],
							'\n', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_RELEASE')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
							new MenuItem(Std.string(resourceManager.getString('resources', 'CLEAN_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], 'selectedProjectAntBuild'),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
				];
			actionScriptMenu.forEach(makeDynamic);
		}

		return cast actionScriptMenu;
	}

	private function getASLibraryMenuItems():Array<MenuItem> {
		if (libraryMenu == null) {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			libraryMenu = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
							'b', cast [Keyboard.COMMAND],
							'b', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_RELEASE')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
							new MenuItem(Std.string(resourceManager.getString('resources', 'CLEAN_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], 'selectedProjectAntBuild'),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
				];
			libraryMenu.forEach(makeDynamic);
		}

		return cast libraryMenu;
	}

	private function getRoyaleMenuItems():Array<MenuItem> {
		if (royaleMenu == null) {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			royaleMenu = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
							'b', cast [Keyboard.COMMAND],
							'b', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_AND_RUN')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN,
							'\n', cast [Keyboard.COMMAND],
							'\n', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_AS_JS')), null, cast [ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AS_JAVASCRIPT,
							'j', cast [Keyboard.COMMAND],
							'j', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_AND_RUN_AS_JS')), null, cast [ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN_JAVASCRIPT),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_RELEASE')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], 'selectedProjectAntBuild'),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
							new MenuItem(Std.string(resourceManager.getString('resources', 'CLEAN_PROJECT')), null, cast [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT)
				];
			royaleMenu.forEach(makeDynamic);
		}

		return cast royaleMenu;
	}

	private function getVisualEditorMenuFlexItems():Array<MenuItem> {
		if (veFlex == null) {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			veFlex = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT')), cast [
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX')), null, cast [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
							null, null, null, null, null, null, null, true),
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES')), null, cast [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
							null, null, null, null, null, null, null, true)
				])
				];

			veFlex.forEach(makeDynamic);
		}

		return cast veFlex;
	}

	private function getVisualEditorMenuPrimeFacesItems():Array<MenuItem> {
		if (vePrimeFaces == null) {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			vePrimeFaces = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT')), cast [
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX')), null, cast [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
							null, null, null, null, null, null, null, true),
							new MenuItem(Std.string(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES')), null, cast [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
							null, null, null, null, null, null, null, true)
				]),
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'START_PREVIEW')), null, cast [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], PreviewPluginEvent.START_VISUALEDITOR_PREVIEW)
				];

			var as3Project:AS3ProjectVO = AS3.as(currentProject, AS3ProjectVO);
			var veMenuItem:MenuItem = vePrimeFaces[vePrimeFaces.length - 1];
			if (as3Project.isPreviewRunning) {
				veMenuItem.label = Std.string(resourceManager.getString('resources', 'STOP_PREVIEW'));
				veMenuItem.event = PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW;
			} else {
				veMenuItem.label = Std.string(resourceManager.getString('resources', 'START_PREVIEW'));
				veMenuItem.event = PreviewPluginEvent.START_VISUALEDITOR_PREVIEW;
			}

			vePrimeFaces.forEach(makeDynamic);
		}

		return cast vePrimeFaces;
	}

	private function getJavaMenuItems():Array<MenuItem> {
		if (javaMenu == null) {
			var enabledTypes:Array<Dynamic> = ((AS3.as(currentProject, JavaProjectVO)).hasGradleBuild()) ? [] : cast [ProjectMenuTypes.JAVA];
			var resourceManager:IResourceManager = ResourceManager.getInstance();

			javaMenu = [
							new MenuItem(null),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_PROJECT')), null, enabledTypes, JavaBuildEvent.JAVA_BUILD,
							'b', cast [Keyboard.COMMAND],
							'b', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'BUILD_AND_RUN')), null, enabledTypes, JavaBuildEvent.BUILD_AND_RUN,
							'\n', cast [Keyboard.COMMAND],
							'\n', cast [Keyboard.CONTROL]),
							new MenuItem(Std.string(resourceManager.getString('resources', 'CLEAN_PROJECT')), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT)
				];
			javaMenu.forEach(makeDynamic);
		}

		return cast javaMenu;
	}

	private function makeDynamic(item:MenuItem, index:Int, vector:Array<MenuItem>):Void {
		item.dynamicItem = true;
	}

	public function new() {}

}