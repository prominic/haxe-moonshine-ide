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
package actionScripts.plugin;

import flash.errors.Error;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.settings.SettingsPlugin;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.utils.Moonshine_internal;

class PluginManager {

	private var model:IDEModel = IDEModel.getInstance();

	// Core plugins
	private var corePlugins:Array<Dynamic>;

	// Plugins shipped with Moonshine
	private var defaultPlugins:Array<Dynamic>;
	private var registeredPlugins:Array<IPlugin> = new Array<IPlugin>();
	private var settingsPlugin:SettingsPlugin;
	private var pendingPlugMenuItems:Array<MenuItem> = new Array<MenuItem>();

	public function new() {
		this.corePlugins = this.model.flexCore.getCorePlugins();
		this.defaultPlugins = this.model.flexCore.getDefaultPlugins();
		model = IDEModel.getInstance();
	}

	public function setupPlugins():Void {
		function order(a:Dynamic, b:Dynamic):Float {
			if (Reflect.field(a, 'name') < Reflect.field(b, 'name')) {
				return -1;
			} else if (Reflect.field(a, 'name') > Reflect.field(b, 'name')) {
				return 1;
			}
			return 0;
		};
		//Need to copy asset folder into bin dir also.
		var allPlugins:Array<Dynamic> = corePlugins.concat(defaultPlugins,
				model.visualEditorCore.getDefaultPlugins(),
				model.javaCore.getDefaultPlugins()
		);

		var plug:Class<Dynamic>;
		for (plug_ in allPlugins) {
			var plug:Class<Dynamic> = cast plug_;
			var instance:IPlugin = AS3.as(Type.createInstance(plug, []), IPlugin);
			if (instance == null) {
				throw new Error('Can\'t add plugin that doesn\'t implement IPlugin.');
				break;
			}

			registerPlugin(instance);
		}

		var menuInstance:MenuPlugin = new MenuPlugin();
		for (menuItem in pendingPlugMenuItems) {
			menuInstance.addPluginMenu(menuItem);
		}
		settingsPlugin.initializePlugin(menuInstance);
		registeredPlugins.push(menuInstance); /*
		* @local
		*/
		registeredPlugins.sort(order);
	}

	private var index:Int = 0;

	public function registerPlugin(plug:IPlugin):Void {
		if (plug == null) {
			return;
		}

		index++;

		if (Lambda.indexOf(registeredPlugins, plug) != -1) {
			throw Error('Plugin ' + plug.name + ' has already been registered');
		}
		registeredPlugins.push(plug);

		if (settingsPlugin != null) {
			// nasty hack for now
			{
				settingsPlugin.initializePlugin(plug);
			}
		}

		if (Std.is(plug, IMenuPlugin)) {
			var menu:MenuItem = IMenuPlugin(plug).getMenu();
			if (menu != null) {
				pendingPlugMenuItems.push(menu);
			}
		}

		if (Std.is(plug, SettingsPlugin)) {
			SettingsPlugin(plug).pluginManager = this;
			settingsPlugin = SettingsPlugin(plug);
		}
	}

	private function getPluginByClassName(className:String):IPlugin {
		var plugins:Array<IPlugin> = cast getPlugins();
		var plug:IPlugin;
		for (plug in plugins) {
			if (Std.string(plug).indexOf(className) != -1) {
				return plug;
			}
		}
		return null;
	}

	private function getPlugins():Array<IPlugin> {
		return cast registeredPlugins;
	}

}