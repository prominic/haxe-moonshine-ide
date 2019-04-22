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
package actionScripts.ui.menu;

import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import mx.collections.ArrayList;
import mx.core.FlexGlobals;
import mx.events.MenuEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import actionScripts.events.PreviewPluginEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.events.ShortcutEvent;
import actionScripts.events.TemplatingEvent;
import actionScripts.factory.FileLocation;
import actionScripts.factory.NativeMenuItemLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.MultiOptionSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.templating.TemplatingPlugin;
import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.vo.CustomMenu;
import actionScripts.ui.menu.vo.CustomMenuItem;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.KeyboardShortcutManager;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.KeyboardShortcut;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Settings;

// This class is a singleton
class MenuPlugin extends PluginBase implements ISettingsProvider {

	// If you add menus, make sure to add a constant for the event + a binding for a command in IDEController
	public static inline var MENU_QUIT_EVENT:String = 'menuQuitEvent';
	public static inline var MENU_SAVE_EVENT:String = 'menuSaveEvent';
	public static inline var MENU_SAVE_AS_EVENT:String = 'menuSaveAsEvent';
	public static inline var EVENT_ABOUT:String = 'EVENT_ABOUT';
	public static inline var REFRESH_MENU_STATE:String = 'refreshMenuState';
	public static inline var CHANGE_MENU_MAC_DISABLE_STATE:String = 'CHANGE_MENU_MAC_DISABLE_STATE';// shows only Quit command with File menu
	public static inline var CHANGE_MENU_MAC_NO_MENU_STATE:String = 'CHANGE_MENU_MAC_NO_MENU_STATE';// shows absolutely no top menu
	public static inline var CHANGE_MENU_MAC_ENABLE_STATE:String = 'CHANGE_MENU_MAC_ENABLE_STATE';
	public static inline var CHANGE_GIT_CLONE_PERMISSION_LABEL:String = 'CHANGE_GIT_CLONE_PERMISSION_LABEL';
	public static inline var CHANGE_SVN_CHECKOUT_PERMISSION_LABEL:String = 'CHANGE_SVN_CHECKOUT_PERMISSION_LABEL';

	private var BUILD_NATIVE_MENU(default, never):Int = 1;
	private var BUILD_CUSTOM_MENU(default, never):Int = 2;
	private var BUILD_NATIVE_CUSTOM_MENU(default, never):Int = 3;

	// Menu Event to data mapping, used for passing extra information to
	// listeners
	private var eventToMenuMapping:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var noSDKOptionsToMenuMapping:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var noCodeCompletionOptionsToMenuMapping:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var isFileNewMenuIsEnabled:Bool = false;
	private var moonshineMenu:NativeMenuItem;

	private var projectMenu:ProjectMenu;

	override private function get_name():String {
		return 'Application Menu Plugin';
	}

	override private function get_author():String {
		return 'Keyston Clay & Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Adds Menu';
	}

	public function new() {
		super();
		this.activeMenus = (((Settings.os != 'win') && AS3.as(ConstantsCoreVO.IS_AIR, Bool))) ? this.BUILD_NATIVE_MENU : this.BUILD_CUSTOM_MENU;
		projectMenu = new ProjectMenu();
	}

	public function getSettingsList():Array<ISetting> {
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			return [];
		}

		var nvps:Array<NameValuePair> = [
				new NameValuePair('Native', BUILD_NATIVE_MENU),
				new NameValuePair('Custom', BUILD_CUSTOM_MENU)
		];

		if (Settings.os != 'win') {
			nvps.push(new NameValuePair('Native & Custom', BUILD_NATIVE_CUSTOM_MENU));
		}
		return [
				new MultiOptionSetting(this, 'activeMenus', 'Select your menu', nvps)
		];
	}

	// Data structure for Application window on Mac, Window menu on Windows and to-be-figured-out on Lunix.
	private var macMenu:MenuItem = new MenuItem((AS3.as(ConstantsCoreVO.IS_DEVELOPMENT_MODE, Bool)) ? 'MoonshineDevelopment' : 'Moonshine');
	private var macMenuForDisableStateMac:MenuItem = new MenuItem((AS3.as(ConstantsCoreVO.IS_DEVELOPMENT_MODE, Bool)) ? 'MoonshineDevelopment' : 'Moonshine');
	private var quitMenuItem:MenuItem = IDEModel.getInstance().flexCore.getQuitMenuItem();
	private var quitMenuItemForDisableStateMac:MenuItem = IDEModel.getInstance().flexCore.getQuitMenuItem();
	private var settingsMenuItem:MenuItem = IDEModel.getInstance().flexCore.getSettingsMenuItem();
	private var aboutMenuItem:MenuItem = IDEModel.getInstance().flexCore.getAboutMenuItem();
	private var windowMenus:Array<MenuItem> = cast IDEModel.getInstance().flexCore.getWindowsMenu();
	private var windowMenusForDisableStateMac:Array<MenuItem> = new Array<MenuItem>();

	private var topNativeMenuItemsForFileNew:Dynamic;

	public var activeMenus:Int = 0;
	//public var activeMenus:uint = ( (Settings.os != "mac") && ConstantsCoreVO.IS_AIR) ? BUILD_NATIVE_MENU : BUILD_CUSTOM_MENU;

	private static var shortcutManager:KeyboardShortcutManager = KeyboardShortcutManager.getInstance();
	private var buildingNativeMenu:Bool = false;
	private var lastSelectedProjectBeforeMacDisableStateChange:ProjectVO;

	override public function activate():Void {
		super.activate();
		init();
	}

	override public function deactivate():Void {}

	public function addPluginMenu(menu:MenuItem):Void {
		if (menu == null) {
			return;
		}
		// If we have an assigned parent, loop down & place the menu there.

		if (menu.parents != null) {
			recurseAssignMenu(menu, windowMenus);
		}
	}

	private function init():Void {
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			if (Settings.os == 'mac') {
				windowMenus.insert(0, macMenu);
				macMenu.items = cast new Array<MenuItem>();
				macMenu.items.push(aboutMenuItem);
				macMenu.items.push(settingsMenuItem);

				windowMenusForDisableStateMac.insert(0, macMenuForDisableStateMac);
				macMenuForDisableStateMac.items = cast new Array<MenuItem>();

				windowMenusForDisableStateMac[0].items.push(quitMenuItemForDisableStateMac);
			} else {
				windowMenus[0].items.push(new MenuItem(null));
				windowMenus[0].items.push(settingsMenuItem);
			}

			windowMenus[0].items.push(new MenuItem(null));
			windowMenus[0].items.push(quitMenuItem);
		} else {
			windowMenus[0].items.push(new MenuItem(null));
			windowMenus[0].items.push(settingsMenuItem);

			// this will populate template items inside File -> New
			var parentArray:Array<String> = ['File', 'New'];
			addSUBMenu(cast parentArray, windowMenus);
		}

		if (!activated) {
			return;
		}

		if (activeMenus == BUILD_NATIVE_MENU || activeMenus == BUILD_NATIVE_CUSTOM_MENU) {
			buildingNativeMenu = true;
			createMenu();
		}

		if (activeMenus == BUILD_CUSTOM_MENU || activeMenus == BUILD_NATIVE_CUSTOM_MENU) {
			buildingNativeMenu = false;
			createMenu();
		}

		dispatcher.addEventListener(MenuPlugin.REFRESH_MENU_STATE, refreshMenuStateHandler);
		dispatcher.addEventListener(ShortcutEvent.SHORTCUT_PRE_FIRED, shortcutPreFiredHandler);
		dispatcher.addEventListener(TemplatingEvent.ADDED_NEW_TEMPLATE, addedNewTemplateHandler, false, 0, true);
		dispatcher.addEventListener(TemplatingEvent.REMOVE_TEMPLATE, removeTemplateHandler, false, 0, true);
		dispatcher.addEventListener(TemplatingEvent.RENAME_TEMPLATE, renameTemplateHandler, false, 0, true);
		dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED, recentProjectListUpdatedHandler, false, 0, true);
		dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED, recentFilesListUpdatedHandler, false, 0, true);

		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			dispatcher.addEventListener(CHANGE_MENU_MAC_DISABLE_STATE, onMacDisableStateChange);
			dispatcher.addEventListener(CHANGE_MENU_MAC_NO_MENU_STATE, onMacNoMenuStateChange);
			dispatcher.addEventListener(CHANGE_MENU_MAC_ENABLE_STATE, onMacEnableStateChange);
			dispatcher.addEventListener(CHANGE_GIT_CLONE_PERMISSION_LABEL, onGitClonePermissionChange);
			dispatcher.addEventListener(CHANGE_SVN_CHECKOUT_PERMISSION_LABEL, onSVNCheckoutPermissionChange);
		}

		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
		dispatcher.addEventListener(ProjectEvent.ACTIVE_PROJECT_CHANGED, activeProjectChangedHandler);

		// disable File-New menu as default
		isFileNewMenuIsEnabled = false;
		disableMenuOptions();
		disableNewFileMenuOptions();
	}

	private function refreshMenuStateHandler(event:Event):Void {
		disableNewFileMenuOptions();
		disableMenuOptions();
		refreshMenuItems();
	}

	private function addProjectHandler(event:ProjectEvent):Void {
		disableNewFileMenuOptions();
		disableMenuOptions();
	}

	private function activeProjectChangedHandler(event:ProjectEvent):Void {
		disableNewFileMenuOptions();
		updateMenuOptionsInMenuProject(event.project);
		disableMenuOptions();
	}

	private function disableNewFileMenuOptions():Void {
		if (!AS3.as(topNativeMenuItemsForFileNew, Bool)) {
			// os == mac
			var menu:Dynamic = getMenuObject();
			if (buildingNativeMenu) {
				var itemsInTopMenu:Array<Dynamic> = Reflect.field(menu, 'items');// top-level menus, i.e. Moonshine, File etc.
				var subItemsInItemOfTopMenu:Array<Dynamic> = Reflect.field(Reflect.field(itemsInTopMenu[1], 'submenu'), 'items');// i.e. File
				topNativeMenuItemsForFileNew = Reflect.field(Reflect.field(subItemsInItemOfTopMenu[0], 'submenu'), 'items');// i.e. File -> New
			} else {
				topNativeMenuItemsForFileNew = Reflect.field(Reflect.field(Reflect.field(Reflect.field((AS3.as(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), CustomMenuItem)).data, 'items'), Std.string(0)), 'data'), 'items');
			}
		}

		isFileNewMenuIsEnabled = false;
		for (j in 0...TemplatingPlugin.fileTemplates.length) {
			Reflect.setField(Reflect.field(topNativeMenuItemsForFileNew, Std.string(j)), 'enabled', false);
		}
	}

	private function disableMenuOptions(lastSelectedProject:ProjectVO = null):Void {
		var activeProject:ProjectVO = (lastSelectedProject != null) ? lastSelectedProject : model.activeProject;

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			var menu:Dynamic = getMenuObject();

			if (AS3.as(menu, Bool)) {
				var countMenuItems:Int = AS3.int(Reflect.field(menu, 'items').length);
				var menuItem:Dynamic;
				for (i in 0...countMenuItems) {
					menuItem = Reflect.field(Reflect.field(menu, 'items'), Std.string(i));
					if (AS3.as(Reflect.field(menuItem, 'submenu'), Bool)) {
						recursiveDisableMenuOptionsByProject(Reflect.field(Reflect.field(menuItem, 'submenu'), 'items'), activeProject);
					}
				}
			}
		}
	}

	private function refreshMenuItems():Void {
		if (model.activeProject == null) {
			return;
		}

		var as3Project:AS3ProjectVO = AS3.as(model.activeProject, AS3ProjectVO);
		if (as3Project != null) {
			if (as3Project.isPrimeFacesVisualEditorProject) {
				var resourceManager:IResourceManager = ResourceManager.getInstance();
				var projectMenus:Array<MenuItem> = cast projectMenu.getProjectMenuItems(model.activeProject);

				var previewItem:MenuItem = projectMenus[projectMenus.length - 1];
				if (as3Project.isPreviewRunning) {
					previewItem.label = Std.string(resourceManager.getString('resources', 'STOP_PREVIEW'));
					previewItem.event = PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW;
				} else {
					previewItem.label = Std.string(resourceManager.getString('resources', 'START_PREVIEW'));
					previewItem.event = PreviewPluginEvent.START_VISUALEDITOR_PREVIEW;
				}

				updateMenuOptionsInMenuProject(model.activeProject);
			}
		}
	}

	private function updateMenuOptionsInMenuProject(project:ProjectVO):Void {
		var resourceManager:IResourceManager = ResourceManager.getInstance();
		var projectMenuItemName:String = Std.string(resourceManager.getString('resources', 'PROJECT'));
		var menu:Dynamic = getMenuObject();
		var countMenuItems:Int = AS3.int(Reflect.field(menu, 'items').length);
		var menuItem:Dynamic;
		for (i in 0...countMenuItems) {
			menuItem = Reflect.field(Reflect.field(menu, 'items'), Std.string(i));
			if (Reflect.field(menuItem, 'label') == projectMenuItemName) {
				var projectMenus:Array<MenuItem> = cast projectMenu.getProjectMenuItems(project);
				var j:Int = AS3.int(Reflect.field(Reflect.field(menuItem, 'submenu'), 'numItems') - 1);
				while (j > 0) {
					var removeItem:Bool = false;
					var item:Dynamic = Reflect.field(menuItem, 'submenu').getItemAt(j);

					if (Reflect.hasField(item, 'dynamicItem') && AS3.as(Reflect.field(item, 'dynamicItem'), Bool)) {
						removeItem = true;
					} else if (AS3.as(Reflect.field(item, 'data'), Bool) && Reflect.field(Reflect.field(item, 'data'), 'dynamicItem') != null) {
						removeItem = true;
					}

					if (removeItem) {
						Reflect.field(menuItem, 'submenu').removeItemAt(j);
					}
					j--;
				}

				if (projectMenus != null) {
					addMenus(cast projectMenus, Reflect.field(menuItem, 'submenu'));
				}
				break;
			}
		}
	}

	private function recursiveDisableMenuOptionsByProject(menuItems:Dynamic, currentProject:ProjectVO):Void {
		var countMenuItems:Int = AS3.int(menuItems.length);
		var enable:Bool;
		var isEnableTypePresent:Bool = true;
		for (i in 0...countMenuItems) {
			var menuItem:Dynamic = Reflect.field(menuItems, Std.string(i));

			// in macOS few items extracted from adl, i.e.
			// hide adl, show all etc. are pure NativeMenuItem
			// and they won't have 'enableTypes'
			if (buildingNativeMenu) {
				isEnableTypePresent = ((Reflect.hasField(menuItem, 'enableTypes'))) ? true : false;
			}

			if (!buildingNativeMenu || isEnableTypePresent) {
				if (currentProject == null && AS3.as(Reflect.field(menuItem, 'enableTypes'), Bool) && Reflect.field(menuItem, 'enableTypes').length != 0) {
					Reflect.setField(menuItem, 'enabled', false);
				} else if (!AS3.as(Reflect.field(menuItem, 'enableTypes'), Bool)) {
					Reflect.setField(menuItem, 'enabled', true);
				} else if (currentProject != null && AS3.as(Reflect.field(menuItem, 'enableTypes'), Bool)) {
					Reflect.setField(menuItem, 'enabled', false);
					if (Std.is(currentProject, JavaProjectVO)) {
						enable = AS3.as(Reflect.field(menuItem, 'enableTypes').some(function hasView(item:String, index:Int, arr:Array<Dynamic>):Bool {
													return item == ProjectMenuTypes.JAVA;
												}), Bool);
					} else if (Std.is(currentProject, AS3ProjectVO)) {
						var as3Project:AS3ProjectVO = AS3ProjectVO(currentProject);
						enable = AS3.as(Reflect.field(menuItem, 'enableTypes').some(function hasView(item:String, index:Int, arr:Array<Dynamic>):Bool {
													return as3Project.menuType.indexOf(item) != -1;
												}), Bool);
					}
					Reflect.setField(menuItem, 'enabled', enable);
				}
			}

			if (AS3.as(Reflect.field(menuItem, 'submenu'), Bool)) {
				recursiveDisableMenuOptionsByProject(Reflect.field(Reflect.field(menuItem, 'submenu'), 'items'), currentProject);
			}
		}
	}

	// Add submenu under parent
	private function addSUBMenu(parentItem:Array<Dynamic>, windowmenu:Array<MenuItem>):Void {
		var file:FileLocation;
		var menuitem:MenuItem;
		for (parent_ in parentItem) {
			var parent:String = cast parent_;
			for (m in windowmenu) {
				if (m.label == Std.string(parent)) {
					parentItem.splice(0, 1);
					if (parentItem.length == 0) {
						// add submenu
						m.items = cast new Array<MenuItem>();
						for (file in as3hx.Compat.each(TemplatingPlugin.fileTemplates)) {
							var fileName:String = Std.string(file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf('.')));
							menuitem = new MenuItem(fileName, null, null, fileName);
							m.items.push(menuitem);
						}
						menuitem = new MenuItem(null);
						m.items.push(menuitem);
						for (file in as3hx.Compat.each(TemplatingPlugin.projectTemplates)) {
							menuitem = new MenuItem(Std.string(file.fileBridge.name), null, null, Std.string(file.fileBridge.name));
							m.items.push(menuitem);
						}
						break;
					} else {
						addSUBMenu(parentItem, m.items);
					}
				}
			}
		}
	}

	// Adds menu to internal menu representation at a given point. MenuItem.parents decide where it goes.
	private function recurseAssignMenu(menuItem:MenuItem, children:Array<MenuItem>):Void {
		var target:String = ((menuItem.parents.length != 0)) ? Std.string(menuItem.parents[0]) : menuItem.label;

		for (m in children) {
			if (m != null && m.label == target) {
				if (m.items == null) {
					m.items = cast new Array<MenuItem>();
				}
				menuItem.parents.splice(0, 1);
				recurseAssignMenu(menuItem, m.items);
				return;
			}
		}

		if (menuItem.parents.length == 0) {
			// Target menu found, just add children.
			for (submenuItem in menuItem.items) {
				children.push(submenuItem);
			}
		}// Menu not found, add it.
		else {
			// Menu not found, add it.
			children.push(menuItem);
		}
	}

	private function createMenu():Void {
		var currentMenu:Dynamic = applyNewNativeMenu(windowMenus);
		var noSDKOptionsRootIndex:Int;
		if (Std.is(currentMenu, NativeMenu)) {
			noSDKOptionsRootIndex = 1;
		} else {
			var menuBar:MenuBar = new MenuBar();
			menuBar.menu = AS3.as(currentMenu, ICustomMenu);
			model.mainView.addChildAt(menuBar, 0);
		}

		// in case of OSX, top menu append with a new system level menu (i.e. Moonshine) at 0th index
		// thus, menu index for Windows what could be 0, shall be 1 in OSX
		noCodeCompletionOptionsToMenuMapping.set(2 + noSDKOptionsRootIndex, [6, 7, 8]);
		noSDKOptionsToMenuMapping.set(3 + noSDKOptionsRootIndex, [3, 4, 5, 6, 7, 9]);
		noSDKOptionsToMenuMapping.set(4 + noSDKOptionsRootIndex, [0, 2, 3, 4]);
		noSDKOptionsToMenuMapping.set(5 + noSDKOptionsRootIndex, [0]);
	}

	private function addedNewTemplateHandler(event:TemplatingEvent):Void {
		var tmpMI:MenuItem = new MenuItem(event.label, null, null, event.listener);
		var menuItem:Dynamic = createNewMenuItem(tmpMI);
		var itemToAddAt:Int = (event.isProject) ? TemplatingPlugin.projectTemplates.length + TemplatingPlugin.fileTemplates.length : TemplatingPlugin.fileTemplates.length - 1;
		var menuObject:Dynamic = ((Std.is(menuItem, NativeMenuItemLocation))) ? NativeMenuItemLocation(menuItem).item.getNativeMenuItem : menuItem;
		if (!isFileNewMenuIsEnabled) {
			Reflect.setField(menuObject, 'enabled', false);
		}

		if (AS3.as(menuItem, Bool)) {
			var menu:Dynamic = getMenuObject();
			if (buildingNativeMenu) {
				var itemsInTopMenu:Array<Dynamic> = Reflect.field(menu, 'items');// top-level menus, i.e. Moonshine, File etc.
				var subItemsInItemOfTopMenu:Array<Dynamic> = Reflect.field(Reflect.field(itemsInTopMenu[1], 'submenu'), 'items');// i.e. File
				Reflect.field(Reflect.field(Reflect.field(Reflect.field(subItemsInItemOfTopMenu[0], 'submenu'), 'items'), Std.string(0)), 'menu').addItemAt(menuObject, itemToAddAt);

				windowMenus[1].items[0].items.insert(itemToAddAt, new MenuItem(event.label, null, null, event.listener));
			} else {
				CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(0))).data.items.insertAt(itemToAddAt, menuObject);
			}
		}
	}

	private function removeTemplateHandler(event:TemplatingEvent):Void {
		var menu:Dynamic = getMenuObject();
		var subItemsInItemOfTopMenu:Dynamic;
		if (buildingNativeMenu) {
			var itemsInTopMenu:Array<Dynamic> = Reflect.field(menu, 'items');// top-level menus, i.e. Moonshine, File etc.
			subItemsInItemOfTopMenu = Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(itemsInTopMenu[1], 'submenu'), 'items'), Std.string(0)), 'submenu'), 'items');
		} else {
			subItemsInItemOfTopMenu = CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(0))).data.items;
		}

		for (i in 0...subItemsInItemOfTopMenu.length) {
			if (Reflect.field(Reflect.field(subItemsInItemOfTopMenu, Std.string(i)), 'label') == event.label) {
				if (buildingNativeMenu) {
					Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(itemsInTopMenu[1], 'submenu'), 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(0)), 'menu').removeItemAt(i);
					windowMenus[1].items[0].items.splice(i, 1)[0];
				} else {
					CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(0))).data.items.removeAt(i);
				}
				return;
			}
		}
	}

	private function recentProjectListUpdatedHandler(event:Event):Void {
		var menu:Dynamic = getMenuObject();
		var subItemsLength:Int = -1;
		if (buildingNativeMenu) {
			subItemsLength = AS3.int(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(2)), 'submenu'), 'items').length);// top-level menus, i.e. Moonshine, File etc.
		} else {
			subItemsLength = AS3.int(CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(2))).data.items.length);
		}

		if (subItemsLength != -1) {
			for (i in ...subItemsLength) {
				if (buildingNativeMenu) {
					Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(2)), 'submenu'), 'items'), Std.string(0)), 'menu').removeItemAt(0);
				} else {
					CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(2))).data.items.removeAt(0);
				}
			}

			var tmpMI:MenuItem = UtilsCore.getRecentProjectsMenu();
			addMenus(tmpMI.items, (buildingNativeMenu) ? Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(2)), 'submenu') : CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(2))).submenu);
		}
	}

	private function recentFilesListUpdatedHandler(event:Event):Void {
		var menu:Dynamic = getMenuObject();
		var subItemsLength:Int = -1;
		if (buildingNativeMenu) {
			subItemsLength = AS3.int(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(3)), 'submenu'), 'items').length);// top-level menus, i.e. Moonshine, File etc.
		} else {
			subItemsLength = AS3.int(CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(3))).data.items.length);
		}

		if (subItemsLength != -1) {
			for (i in ...subItemsLength) {
				if (buildingNativeMenu) {
					Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(3)), 'submenu'), 'items'), Std.string(0)), 'menu').removeItemAt(0);
				} else {
					CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(3))).data.items.removeAt(0);
				}
			}

			var tmpMI:MenuItem = UtilsCore.getRecentFilesMenu();
			addMenus(tmpMI.items, (buildingNativeMenu) ? Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(3)), 'submenu') : CustomMenuItem(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(0)), 'submenu'), 'items'), Std.string(3))).submenu);
		}
	}

	private function renameTemplateHandler(event:TemplatingEvent):Void {
		var menu:Dynamic = getMenuObject();
		var subItemsInItemOfTopMenu:Dynamic;
		if (buildingNativeMenu) {
			subItemsInItemOfTopMenu = Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(Reflect.field(menu, 'items'), Std.string(1)), 'submenu'), 'items'), Std.string(0)), 'submenu'), 'items');
		} else {
			var menuBarMenu:CustomMenu = AS3.as(menu, CustomMenu);
			subItemsInItemOfTopMenu = CustomMenuItem(menuBarMenu.items[0].submenu.items[0]).data.items;
		}

		for (i in 0...subItemsInItemOfTopMenu.length) {
			if (Reflect.field(Reflect.field(subItemsInItemOfTopMenu, Std.string(i)), 'label') == event.label) {
				Reflect.setField(Reflect.field(subItemsInItemOfTopMenu, Std.string(i)), 'label', event.newLabel);
				Reflect.setField(Reflect.field(Reflect.field(subItemsInItemOfTopMenu, Std.string(i)), 'data'), 'event', ((event.isProject) ? 'eventNewProjectFromTemplate' : 'eventNewFileFromTemplate') + event.newLabel);
				Reflect.setField(Reflect.field(Reflect.field(subItemsInItemOfTopMenu, Std.string(i)), 'data'), 'eventData', event.newFileTemplate);

				// in case of mac we need to update windowMenus for latter use
				if (buildingNativeMenu) {
					windowMenus[1].items[0].items[i].label = event.newLabel;
					windowMenus[1].items[0].items[i].event = ((event.isProject) ? 'eventNewProjectFromTemplate' : 'eventNewFileFromTemplate') + event.newLabel;
					windowMenus[1].items[0].items[i].data = event.newFileTemplate;
				}
				return;
			}
		}
	}

	private function onMacDisableStateChange(event:Event):Void {
		applyNewNativeMenu(windowMenusForDisableStateMac);

		lastSelectedProjectBeforeMacDisableStateChange = model.activeProject;
	}

	private function onMacNoMenuStateChange(event:Event):Void {
		// keep this to repopulate later
		var menu:Dynamic = getMenuObject();
		if (!AS3.as(menu, Bool)) {
			return;
		}

		moonshineMenu = Reflect.field(Reflect.field(menu, 'items'), Std.string(0));
		applyNewNativeMenu(cast new Array<MenuItem>());

		lastSelectedProjectBeforeMacDisableStateChange = model.activeProject;
	}

	private function onMacEnableStateChange(event:Event):Void {
		applyNewNativeMenu(windowMenus);
		updateMenuOptionsInMenuProject(lastSelectedProjectBeforeMacDisableStateChange);

		// update menus for VE project
		disableMenuOptions(lastSelectedProjectBeforeMacDisableStateChange);
	}

	private function onGitClonePermissionChange(event:Event):Void {
		var menu:Dynamic = getMenuObject();
		if (!AS3.as(menu, Bool)) {
			return;
		}

		var itemsInTopMenu:Dynamic = Reflect.field(menu, 'items');// top-level menus, i.e. Moonshine, File etc.
		var subItemsInItemOfTopMenu:Dynamic = Reflect.field(Reflect.field(Reflect.field(Reflect.field(itemsInTopMenu, Std.string(7)), 'submenu'), 'items'), Std.string(0));
		Reflect.setField(subItemsInItemOfTopMenu, 'label', (UtilsCore.isGitPresent()) ? 'Clone' : 'Grant Permission');
	}

	private function onSVNCheckoutPermissionChange(event:Event):Void {
		var menu:Dynamic = getMenuObject();
		if (!AS3.as(menu, Bool)) {
			return;
		}

		var itemsInTopMenu:Dynamic = Reflect.field(menu, 'items');// top-level menus, i.e. Moonshine, File etc.
		var subItemsInItemOfTopMenu:Dynamic = Reflect.field(Reflect.field(Reflect.field(Reflect.field(itemsInTopMenu, Std.string(6)), 'submenu'), 'items'), Std.string(0));
		Reflect.setField(subItemsInItemOfTopMenu, 'label', (UtilsCore.isSVNPresent()) ? 'Manage Repositories' : 'Grant Permission');
	}

	private function createNewMenu():Dynamic {
		return (buildingNativeMenu) ? new CustomNativeMenu() : new CustomMenu();
	}

	private function createNewMenuItem(item:MenuItem):Dynamic {
		var nativeMenuItem:NativeMenuItemLocation;
		var menuItem:CustomMenuItem;
		var shortcut:KeyboardShortcut = buildShortcut(item);
		if (buildingNativeMenu) {
			// in case of AIR
			nativeMenuItem = new NativeMenuItemLocation(item.label, item.isSeparator, null, item.enableTypes);
			if (Reflect.getProperty(item, Settings.os + '_key') != null) {
				nativeMenuItem.item.keyEquivalent = Std.string(Reflect.getProperty(item, Settings.os + '_key'));
			}
			if (Reflect.getProperty(item, Settings.os + '_mod') != null) {
				nativeMenuItem.item.keyEquivalentModifiers = Reflect.getProperty(item, Settings.os + '_mod');
			}
			if (item.event != null) {
				// TODO : don't like this
				nativeMenuItem.item.data = {
							'eventData': item.data,
							'event': item.event
						};
				eventToMenuMapping.set(item.event, nativeMenuItem);
				nativeMenuItem.item.listener = redispatch;

			}
		} else {
			menuItem = new CustomMenuItem(item.label, item.isSeparator, {
						'enableTypes': item.enableTypes
					});
			if (shortcut != null) {
				menuItem.shortcut = shortcut;
			} else if (item.event != null) {
				// TODO : dont like this either :/
				menuItem.data = {
							'eventData': item.data,
							'event': item.event
						};
				eventToMenuMapping.set(item.event, menuItem);
			}

		}
		if (shortcut != null) {
			registerShortcut(shortcut, item.enableTypes);
		}

		return (buildingNativeMenu) ? nativeMenuItem : menuItem;

	}

	private function buildShortcut(item:MenuItem):KeyboardShortcut {
		var key:String;
		var mod:Array<Dynamic>;
		var event:String;

		if (Reflect.getProperty(item, Settings.os + '_key') != null) {
			key = Std.string(Reflect.getProperty(item, Settings.os + '_key'));
		}
		if (Reflect.getProperty(item, Settings.os + '_mod') != null) {
			mod = Reflect.getProperty(item, Settings.os + '_mod');
		}
		if (item.event != null) {
			event = item.event;
		}
		if (event != null && key != null) {
			return new KeyboardShortcut(event, key, mod);
		}
		return null;
	}

	private function registerShortcut(shortcut:KeyboardShortcut, enableTypes:Array<Dynamic>):Void {
		shortcutManager.activate(shortcut, enableTypes);
	}

	// Loop through menu structure and add menus through handler
	private function addMenus(items:Array<MenuItem>, parentMenu:Dynamic):Void {
		for (i in 0...items.length) {
			var item:MenuItem = items[i];

			if (item != null && item.items != null) {
				var newMenu:Dynamic = createNewMenu();
				if (!AS3.as(newMenu, Bool)) {
					continue;
				}

				addMenus(item.items, newMenu);
				newMenu = parentMenu.addSubmenu(newMenu, item.label);

				if (AS3.hasOwnProperty(item, 'dynamicItem')) {
					if (Reflect.hasField(newMenu, 'dynamicItem')) {
						Reflect.setField(newMenu, 'dynamicItem', item.dynamicItem);
					} else {
						Reflect.setField(newMenu, 'data', {
							'dynamicItem': item.dynamicItem
						});
					}
				}
			} else if (item != null) {
				var menuItem:Dynamic = createNewMenuItem(item);
				if (AS3.as(menuItem, Bool)) {
					var nativeMenuItem:Dynamic = null;
					if (Std.is(menuItem, NativeMenuItemLocation)) {
						nativeMenuItem = NativeMenuItemLocation(menuItem).item.getNativeMenuItem;
					} else {
						nativeMenuItem = menuItem;
					}

					if (Reflect.hasField(nativeMenuItem, 'dynamicItem')) {
						Reflect.setField(nativeMenuItem, 'dynamicItem', item.dynamicItem);
					}

					parentMenu.addItem(nativeMenuItem);
				}
			}
		}
	}

	private function applyNewNativeMenu(menuItems:Array<MenuItem>):Dynamic {
		var mainMenu:Dynamic = createNewMenu();
		addMenus(cast menuItems, mainMenu);

		// for mac only
		if (buildingNativeMenu) {
			// for #162 feature request
			// introduce hide/unhide/show-all in macOS menu
			ensureHideUnhideMenuOption(mainMenu);

			FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
			FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
		}

		return mainMenu;
	}

	private function ensureHideUnhideMenuOption(nativeMenu:Dynamic):Void {
		if (Reflect.field(nativeMenu, 'items').length == 0) {
			return;
		}

		var topLevel:Dynamic = getMenuObject();
		if (Reflect.field(topLevel, 'items').length == 0) {
			topLevel = new ArrayList([moonshineMenu]);
			moonshineMenu = null;
		}

		// the receipe is get-remove-add to make it work correctly
		var itemsToExtract:Array<String> = ['hide adl', 'hide moonshine', 'hide others', 'show all'];

		// we want the above options to come before Quit option
		var quitOptionIndex:Int = AS3.int(Reflect.field(Reflect.field(Reflect.field(Reflect.field(nativeMenu, 'items'), Std.string(0)), 'submenu'), 'items').length - 2);

		// search against each items we needs
		for (i in itemsToExtract) {
			var itemsToExtractFrom:Array<Dynamic> = topLevel.getItemAt(0).submenu.items;
			for (j in 0...itemsToExtractFrom.length) {
				if (Reflect.field(itemsToExtractFrom[j], 'label').toLowerCase() == i) {
					var tmpOption:Dynamic = itemsToExtractFrom[j];
					topLevel.getItemAt(0).submenu.removeItemAt(j);
					Reflect.field(Reflect.field(Reflect.field(nativeMenu, 'items'), Std.string(0)), 'submenu').addItemAt(tmpOption, ++quitOptionIndex);
					break;
				}
			}
		}

		// we also wants to add a separator!
		var separatorItem:Dynamic = createNewMenuItem(new MenuItem(null));
		Reflect.field(Reflect.field(Reflect.field(nativeMenu, 'items'), Std.string(0)), 'submenu').addItemAt(NativeMenuItemLocation(separatorItem).item.getNativeMenuItem, ++quitOptionIndex);
	}

	// Take events and redispatch them through GED.
	private function redispatch(event:Event):Void {
		if (AS3.as(event.target, Bool) && AS3.as(Reflect.field(event.target, 'data'), Bool)) {
			var eventType:String = Std.string(Reflect.field(Reflect.field(event.target, 'data'), 'event'));
			if (eventType != null) {
				shortcutManager.stopEvent(eventType, Reflect.field(Reflect.field(event.target, 'data'), 'eventData'));// use to stop pending event from shortcut
			}
		}
	}

	private function shortcutPreFiredHandler(e:ShortcutEvent):Void {
		if (eventToMenuMapping.get(e.event) == null) {
			return;
		}
		var data:Dynamic = eventToMenuMapping.get(e.event).data;
		e.preventDefault();
		dispatcher.dispatchEvent(new MenuEvent(
				Reflect.field(data, 'event'), false, false,
				Reflect.field(data, 'eventData')));
	}

	private function getMenuObject():Dynamic {
		if (Settings.os == 'win') {
			return (AS3.as(model.mainView.getChildAt(0), MenuBar)).menu;
		} else if (Settings.os == 'mac') {
			return FlexGlobals.topLevelApplication.nativeApplication.menu;
		}

		return null;
	}

}