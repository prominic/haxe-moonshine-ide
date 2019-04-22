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
package actionScripts.plugin.settings;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
import actionScripts.events.AddTabEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.events.StartupHelperEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.PluginEvent;
import actionScripts.plugin.PluginManager;
import actionScripts.plugin.fullscreen.FullscreenPlugin;
import actionScripts.plugin.settings.event.RequestSettingEvent;
import actionScripts.plugin.settings.event.SetSettingsEvent;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.PluginSetting;
import actionScripts.plugin.settings.vo.PluginSettingsWrapper;
import actionScripts.plugin.splashscreen.SplashScreenPlugin;
import actionScripts.plugin.syntax.AS3SyntaxPlugin;
import actionScripts.plugin.syntax.CSSSyntaxPlugin;
import actionScripts.plugin.syntax.GroovySyntaxPlugin;
import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
import actionScripts.plugin.syntax.JSSyntaxPlugin;
import actionScripts.plugin.syntax.JavaSyntaxPlugin;
import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
import actionScripts.plugin.syntax.XMLSyntaxPlugin;
import actionScripts.plugin.visualEditor.VisualEditorProjectPlugin;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.SharedObjectConst;
import actionScripts.utils.Moonshine_internal;
import actionScripts.valueObjects.ConstantsCoreVO;

/**
 *
 * Settings Plugin - Plugin to save plugin settings
 *
 * Flow
 * ---------
 *
 * Restoring
 *
 * 1)Plugins will be registered via PluginManager.registerPlugin(plug:IPlugin)
 * 2)SettingsPlugin.initializePlugin(plug:IPlugin) will be called which reads the xml file
 * (if any) and restores the plugin instance settings.
 * 		A 'Proxy' we be set by ISettingsProvider.getSettings(), where each ISetting will
 * 		either pass a string name of a public property/setter&getter
 * 		ex : public function getSettings():Vector<ISetting>{
 * 			return Vector.<ISetting>([
 * 						new BooleanSetting(this,"myBooleanProperty","My Desciption")
 * 			]);
 * 		}
 *
 * 	Each render will by default have ISetting.stringValue which can take any string value,
 * 	if the inner property value has an datatype other then String you may override this function
 * 	to typecast to the needed property, or in use with complex objects ie. FontDescription
 * 		ex . override public function get stringValue():String{
 * 				var fontDescription:FontDescription = getSetting() as FontDescription;
 * 				return [fontDescription.fontName,........,......,...].join(",");
 * 			}
 * 			override public function set stringValue(value:String):void{
 * 				// Construct new FontDescription
 * 				var args:Array = value.split(",");
 * 				var fontDescription:FontDescription = new FontDescription(args[0],args[1],args[2],args[3]);
 * 				applySetting(fontDescription);
 * 			}
 * 3) After SettingPlugin.readClassSettings(IPlugin) is called a Boolean value of true is returned
 * 		as if the plugin settings says to activate the plugin , by default (on first plugin run) all will be
 * 		activated.
 *
 *
 * Note: Plugin Settings will be stored in File.applicationStorageDirectory+/settings in the following format
 * 		CRC32(QualifiedClassName)_CLASSNAME.xml
 * 		This is done to ensure that no two settings ( even if CLASSNAME is the same) will
 * 		have the same settings file
 *
 * 4) IPlugin.activatedByDefault ensures if the plugin will be activated by default
 * 		when the plugin is loaded for the first time (without settings xml file written)
 *
 * */
class SettingsPlugin extends PluginBase implements ISettingsProvider {

	override private function get_name():String {
		return 'Project Settings Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Provides settings for all plugins.';
	}

	public function getSettingsList():Array<ISetting> {
		return new Array<ISetting>();
	}

	public var pluginManager:PluginManager;

	private var settingsDirectory:FileLocation;
	private var appSettings:SettingsView;

	// NOTE: Temporary solution for hiding some plugins from the settings view
	// If the syntax plugins are combined this might be removed
	private var excludeFromSettings:Array<Dynamic> = cast [MenuPlugin, MXMLSyntaxPlugin,
		AS3SyntaxPlugin, SplashScreenPlugin,
		XMLSyntaxPlugin, CSSSyntaxPlugin, JSSyntaxPlugin, HTMLSyntaxPlugin,
		GroovySyntaxPlugin, JavaSyntaxPlugin,
		FullscreenPlugin, VisualEditorProjectPlugin
	];

	public function new() {
		super();
		excludeFromSettings = excludeFromSettings.concat(
						model.flexCore.getPluginsNotToShowInSettings(),
						model.javaCore.getPluginsNotToShowInSettings()
			);

		dispatcher.addEventListener(SettingsEvent.EVENT_OPEN_SETTINGS, openAppSettings);
		dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleTabClose);
		dispatcher.addEventListener(SetSettingsEvent.SET_SETTING, handleSetSettings);
		dispatcher.addEventListener(RequestSettingEvent.REQUEST_SETTING, handleRequestSetting);
		dispatcher.addEventListener(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, handleSpecificPluginSave);
		dispatcher.addEventListener(GeneralEvent.RESET_ALL_SETTINGS, onResetApplicationSettings, false, 0, true);

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			settingsDirectory = model.fileCore.resolveApplicationStorageDirectoryPath('settings');
			if (!AS3.as(settingsDirectory.fileBridge.exists, Bool)) {
				settingsDirectory.fileBridge.createDirectory();
			}
		} else {
			settingsDirectory = new FileLocation();
		}

		var tempObj:Dynamic = {};
		Reflect.setField(tempObj, 'callback', clearAllSettings);
		Reflect.setField(tempObj, 'commandDesc', 'Clear application settings.');
		registerCommand('debug-clear-app-settings', tempObj);
	}

	@:access(actionScripts.plugin.PluginManager) private function onResetApplicationSettings(event:GeneralEvent):Void {
		// removing plugin-storage values
		clearAllSettings();

		// removing plugin-local values
		var plugins:Array<IPlugin> = pluginManager.getPlugins();
		for (plug in plugins) {
			plug.resetSettings();
		}

		// @devsena
		// do not remove opened projects' history
		//SharedObjectUtil.resetMoonshineIdeProjectSO();

		var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
		Reflect.deleteField(cookie.data, 'javaPathForTypeahead');
		Reflect.deleteField(cookie.data, 'userSDKs');
		Reflect.deleteField(cookie.data, 'moonshineWorkspace');
		Reflect.deleteField(cookie.data, 'isWorkspaceAcknowledged');
		Reflect.deleteField(cookie.data, 'isBundledSDKpromptDNS');
		Reflect.deleteField(cookie.data, 'isSDKhelperPromptDNS');
		Reflect.deleteField(cookie.data, 'devicesAndroid');
		Reflect.deleteField(cookie.data, 'devicesIOS');

		model.javaPathForTypeAhead = null;
		model.isCodeCompletionJavaPresent = false;
		ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS = false;
		ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS = false;
		ConstantsCoreVO.generateDevices();

		cookie.flush();

		// restarting all startup process again
		dispatcher.dispatchEvent(new StartupHelperEvent(StartupHelperEvent.EVENT_RESTART_HELPING));
	}

	private function getClassName(instance:Dynamic):String {
		return Std.string(as3hx.Compat.getQualifiedClassName(instance).split('::').pop());
	}

	private function handleRequestSetting(e:RequestSettingEvent):Void {
		var className:String = getClassName(e.provider);
		var plug:IPlugin = pluginManager.getPluginByClassName(className);
		if (plug != null && (Type.getInstanceFields(Type.getClass(plug)).indexOf(e.name) != -1)) {
			e.value = Reflect.getProperty(plug, e.name);
		}

	}

	private function handleSetSettings(e:SetSettingsEvent):Void {
		var className:String = getClassName(e.provider);
		var plug:IPlugin = pluginManager.getPluginByClassName(className);
		if (plug == null || !((Type.getInstanceFields(Type.getClass(plug)).indexOf(e.name) != -1))) {
			return;
		}
		Reflect.setProperty(plug, e.name, e.value);
		var saveData:FastXML = getXMLSettingsForSave(plug);// retrive settings or default stub
		appendOrUpdateXML(saveData, e.name, Std.string(e.value));//update settings with new value
		commitClassSettings(plug, saveData, generateSettingsPath(plug));// save value

		//var settingsObject:IHasSettings = new PluginSettingsWrapper(plug.name, setList, qualifiedClassName);
	}

	public function initializePlugin(plug:IPlugin):Bool {
		if (plug == null) {
			return false;
		}

		var activated:Bool = readClassSettings(plug);
		pluginStateChanged(plug, activated);
		//if (activated)
		//	plug.activate();

		//dispatcher.dispatchEvent(new
		return activated;
	}

	@:access(actionScripts.plugin.PluginManager) private function openAppSettings(event:Event):Void {
		var jumpToSettingQualifiedClassName:String;
		if (Std.is(event, SettingsEvent) && AS3.as(SettingsEvent(event).openSettingsByQualifiedClassName, Bool)) {
			jumpToSettingQualifiedClassName = Std.string(SettingsEvent(event).openSettingsByQualifiedClassName);
		}

		if (appSettings != null) {
			model.activeEditor = appSettings;
			appSettings.forceSelectItem(jumpToSettingQualifiedClassName);
			return;
		}

		var settings:SettingsView = new SettingsView();
		settings.Width = 230;
		// Save it so we don't open multiple instances of app settings
		appSettings = settings;

		var catPlugins:String = 'Plugins';
		settings.addCategory(catPlugins);

		var plugins:Array<IPlugin> = pluginManager.getPlugins();

		var qualifiedClassName:String;
		var provider:ISettingsProvider;
		for (plug in plugins) {
			if (plug == this) {
				continue;
			}// omit Settings Plugin from showing up

			// Omit plugins defined in excludeFromSettings
			//  questionable flow control
			var skip:Bool = false;
			for (omit_ in excludeFromSettings) {
				var omit:Class<Dynamic> = cast omit_;
				if (Std.is(plug, omit)) {
					skip = true;
					break;
				}
			}

			if (skip) {
				continue;
			}

			provider = AS3.as(plug, ISettingsProvider);

			qualifiedClassName = Type.getClassName(Type.getClass(plug));

			var setList:Array<ISetting> = (provider != null) ? cast provider.getSettingsList() : new Array<ISetting>();

			setList.unshift(new PluginSetting(plug.name, plug.author, plug.description, plug.activated));

			var settingsObject:IHasSettings = new PluginSettingsWrapper(plug.name, setList, qualifiedClassName);
			if (settingsObject != null) {
				settings.addSetting(settingsObject, catPlugins);
			}

			if (jumpToSettingQualifiedClassName != null && (jumpToSettingQualifiedClassName == qualifiedClassName)) {
				settings.currentRequestedSelectedItem = AS3.as(settingsObject, PluginSettingsWrapper);
			}
		}

		dispatcher.dispatchEvent(
				new AddTabEvent(settings)
		);

		settings.addEventListener(SettingsView.EVENT_SAVE, handleAppSettingsSave, false, 0, true);
		settings.addEventListener(SettingsView.EVENT_CLOSE, handleAppSettingsClose, false, 0, true);
	}

	// Save clicked in the view
	//  or save() called by trying to close unsaved tab & saving from the popup
	private function handleAppSettingsSave(e:Event):Void {
		var catPlugins:String = 'Plugins';
		var allSettings:Array<Dynamic> = appSettings.getSettings(catPlugins);

		for (settingObject_ in allSettings) {
			var settingObject:IHasSettings = cast settingObject_;
			saveClassSettings(settingObject);
		}
	}

	// Close clicked in the view
	private function handleAppSettingsClose(e:Event):Void {
		dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(appSettings, DisplayObject))
		);
	}

	// Did the app settings view close?
	private function handleTabClose(event:Event):Void {
		if (Std.is(event, CloseTabEvent)) {
			if (CloseTabEvent(event).tab == appSettings) {
				appSettings.removeEventListener(SettingsView.EVENT_SAVE, handleAppSettingsSave);
				appSettings.removeEventListener(SettingsView.EVENT_CLOSE, handleAppSettingsClose);
				appSettings = null;
			}
		}
	}

	private function getXMLSettingsForSave(content:Dynamic):FastXML {
		var saveData:FastXML;
		if (AS3.as(content, Bool)) {
			saveData = retriveXMLSettings(content);
		}

		if (saveData == null) {
			saveData = FastXML.parse('<settings>
								<properties></properties>
						   </settings>');
		}
		return saveData;
	}

	private function appendOrUpdateXML(xml:FastXML, name:String, value:String):Void {
		if (AS3.as(AS3.hasOwnProperty(xml.node.properties, name), Bool)) {
			xml.nodes.properties.get(name) = value;
		} else {
			xml.nodes.properties.descendants('appendChild')(FastXML.parse('<{name}>{value}</{name}>'));
		}
	}

	private function mergeSaveDataFromList(settingsList:Array<ISetting>, content:Dynamic = null):FastXML {
		var saveData:FastXML = getXMLSettingsForSave(content);

		var propName:String;
		var propValue:String;
		for (setting in settingsList) {
			propName = ((Std.is(setting, PluginSetting))) ? 'activated' : setting.name;
			propValue = setting.stringValue;
			appendOrUpdateXML(saveData, propName, propValue);

		}

		return saveData;
	}

	private function retriveXMLSettings(content:Dynamic):FastXML {
		var settingsFile:FileLocation = generateSettingsPath(content);
		if (!AS3.as(settingsFile.fileBridge.exists, Bool)) {
			return null;
		}

		var saveData:FastXML;
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			saveData = new FastXML(settingsFile.fileBridge.read());
		} else {
			saveData = new FastXML();
		}

		return saveData;
	}

	public function readClassSettings(plug:IPlugin):Bool {
		var provider:ISettingsProvider = AS3.as(plug, ISettingsProvider);
		var saveData:FastXML = retriveXMLSettings(plug);
		if (saveData == null) {
			// file not found so check plugin to see if we should activate by default
			return plug.activatedByDefault;
		}

		var settingsList:Array<ISetting> = (provider != null) ? cast provider.getSettingsList() : new Array<ISetting>();
		var propName:String;

		for (setting in settingsList) {
			propName = setting.name;
			if (!AS3.as(AS3.hasOwnProperty(saveData.node.properties, propName), Bool)) {
				continue;
			}

			setting.stringValue = Std.string(saveData.nodes.properties.get(propName).descendants('text')());
			setting.commitChanges();
		}

		return ((AS3.as(AS3.hasOwnProperty(saveData.node.properties, 'activated'), Bool) &&
		Std.string(saveData.nodes.properties.get('activated').descendants('text')()) == 'false')) ? false : true;
	}

	public function saveClassSettings(wrapper:IHasSettings):Bool {
		if (wrapper == null) {
			return true;
		}

		var settingsList:Array<ISetting> = cast wrapper.getSettingsList();

		var qualifiedClassName:String = (AS3.as(wrapper, PluginSettingsWrapper)).qualifiedClassName;
		var saveData:FastXML = mergeSaveDataFromList(cast settingsList,
				retriveXMLSettings(qualifiedClassName)
		);
		if (!AS3.as(saveData.node.length(), Bool)) {
			return true;
		}

		var settingsFile:FileLocation = generateSettingsPath(qualifiedClassName);
		var className:String = Std.string(qualifiedClassName.split('::').pop());
		var plug:IPlugin = pluginManager.getPluginByClassName(className);
		return commitClassSettings(plug, saveData, settingsFile);
	}

	private function handleSpecificPluginSave(event:SetSettingsEvent):Void {
		var settingsList:Array<ISetting> = try cast(event.value, Vector) catch(e:Dynamic) null;

		var saveData:FastXML = mergeSaveDataFromList(cast settingsList,
				retriveXMLSettings(event.name)
		);
		if (!AS3.as(saveData.node.length(), Bool)) {
			return;
		}

		var settingsFile:FileLocation = generateSettingsPath(event.name);
		var className:String = Std.string(event.name.split('::').pop());
		var plug:IPlugin = pluginManager.getPluginByClassName(className);
		commitClassSettings(null, saveData, settingsFile);
		saveToCurrentPlugin(plug, cast settingsList);
	}

	private function saveToCurrentPlugin(plug:IPlugin, settingsList:Array<ISetting>):Void {
		for (setting in settingsList) {
			if (Reflect.hasField(AS3.as(plug, Object), setting.name)) {
				// this is suppose to hold one field only
				for (i in as3hx.Compat.each(setting.provider)) {
					Reflect.setField((AS3.as(plug, Object)), setting.name, i);
				}
			}
		}
	}

	private function commitClassSettings(plug:IPlugin, saveData:FastXML, settingsFile:FileLocation):Bool {
		if (plug != null) {
			// Check to see what the current state of the plugin is
			var activated:Bool = Std.string(saveData.nodes.properties.descendants('activated').descendants('text')()) == 'true';

			pluginStateChanged(plug, activated);
		}

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			settingsFile.fileBridge.save(saveData.node.toXMLString());
			return settingsFile.fileBridge.getFile.size > 0;
		}

		return false;
	}

	private function pluginStateChanged(plug:IPlugin, activated:Bool):Void {
		if (plug.activated && !activated) {
			plug.deactivate();

		} else if (!plug.activated && activated) {
			plug.activate();
		}

		var type:String = (activated) ? PluginEvent.PLUGIN_ACTIVATED : PluginEvent.PLUGIN_DEACTIVATED;
		dispatcher.dispatchEvent(
				new PluginEvent(type, plug)
		);

	}

	/**
	 * Generates a file instance pointing to the correct settings file
	 * @param content Content can be of a class instance, class or String
	 * @return
	 *
	 */
	private function generateSettingsPath(content:Dynamic):FileLocation {
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			return settingsDirectory;
		}

		var qualifiedClassName:String = (Std.is(content, String)) ? Std.string(content) : as3hx.Compat.getQualifiedClassName(content);
		//var uniqueID:uint = generateUniqueID(qualifiedClassName);
		var realClassName:String = Std.string(qualifiedClassName.split('::').pop());
		return settingsDirectory.resolvePath(realClassName + '.xml');
	}

	// Remove all settings (in case of emergency while developing)
	private function clearAllSettings(args:Array<Dynamic> = null):Void {
		if (settingsDirectory == null || !AS3.as(settingsDirectory.fileBridge.exists, Bool)) {
			return;
		}

		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			settingsDirectory.fileBridge.deleteDirectory(true);
			settingsDirectory.fileBridge.createDirectory();
		}
	}

}