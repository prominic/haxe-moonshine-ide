/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.run.view
 *  Class:      RunMobileSettingRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/run/view/RunMobileSettingRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package actionScripts.plugin.run.view;

import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import spark.events.IndexChangeEvent;
import spark.primitives.Line;
import actionScripts.events.GeneralEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
import actionScripts.plugin.run.RunMobileSetting;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.MultiOptionSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.settings.vo.PathSetting;
import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.valueObjects.ConstantsCoreVO;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.MouseEvent;
import flash.external.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import mx.binding.*;
import mx.binding.IBindingClient;
import mx.collections.ArrayList;
import mx.controls.Spacer;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.IStateClient2;
import mx.core.Mx_internal;
import mx.events.FlexEvent;
import mx.filters.*;
import mx.graphics.SolidColorStroke;
import mx.states.AddItems;
import mx.states.State;
import mx.styles.*;
import spark.components.Button;
import spark.components.DropDownList;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.VGroup;

import spark.primitives.Rect;

@:meta(States(name = 'simulator', name = 'device'))
//  begin class def
class RunMobileSettingRenderer extends spark.components.VGroup implements mx.binding.IBindingClient implements mx.core.IStateClient2 {

	//  instance variables
	/**
	 * @private
	 **/
	public var _RunMobileSettingRenderer_Label1:spark.components.Label;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _RunMobileSettingRenderer_Rect1:spark.primitives.Rect;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _RunMobileSettingRenderer_VGroup2:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var cmbModelOption:spark.components.DropDownList;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var cmbOption:spark.components.DropDownList;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var deviceContent:spark.components.VGroup;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _RunMobileSettingRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_run_view_RunMobileSettingRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(RunMobileSettingRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.paddingTop = 15;
		this.paddingBottom = 15;
		this.paddingLeft = 15;
		this.paddingRight = 15;
		this.mxmlContent = [_RunMobileSettingRenderer_Label1_i(), _RunMobileSettingRenderer_DropDownList1_i(), _RunMobileSettingRenderer_Spacer1_c(), _RunMobileSettingRenderer_Rect1_i()];
		this.currentState = 'simulator';

		// events
		this.addEventListener('creationComplete', ___RunMobileSettingRenderer_VGroup1_creationComplete);

		var _RunMobileSettingRenderer_VGroup2_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_RunMobileSettingRenderer_VGroup2_i);
		var _RunMobileSettingRenderer_VGroup3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_RunMobileSettingRenderer_VGroup3_i);

		states = [
				new State({
					'name': 'simulator',
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _RunMobileSettingRenderer_VGroup2_factory,
								'destination': null,
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['_RunMobileSettingRenderer_Rect1']
							})
			]
				}),
				new State({
					'name': 'device',
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _RunMobileSettingRenderer_VGroup3_factory,
								'destination': null,
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['_RunMobileSettingRenderer_Rect1']
							})
			]
				})
		];

		for (i in 0...bindings.length) {
			AS3.as(bindings[i], Binding).execute();
		}

	}

	/**
	 * @private
	 **/
	private var __moduleFactoryInitialized:Bool = false;

	/**
	 * @private
	 * Override the module factory so we can defer setting style declarations
	 * until a module factory is set. Without the correct module factory set
	 * the style declaration will end up in the wrong style manager.
	 **/
	override private function set_moduleFactory(factory:IFlexModuleFactory):IFlexModuleFactory {
		super.moduleFactory = factory;

		if (__moduleFactoryInitialized) {
			return factory;
		}

		__moduleFactoryInitialized = true;

		// our style settings

		return factory;
	}

	//  initialize()
	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	//  scripts
	//  <Script>, line 32 - 193

	@:meta(Bindable())public var setting:RunMobileSetting;

	@:meta(Bindable())private var isAndroidDevice:Bool = false;

	private var deviceConfiguration:DeviceConfiguration;
	private var lastSelectedItem:Dynamic;
	private var deviceSettings:Array<ISetting>;

	private function init():Void {
		var buildOptions:BuildOptions = AS3.as(setting.provider, BuildOptions);
		cmbOption.selectedIndex = (buildOptions.isMobileRunOnSimulator) ? 0 : 1;
		updateDevices(buildOptions.targetPlatform);
		setting.stringValue = 'nil';

		cmbModelOption.callLater(function():Void {
					if (buildOptions.isMobileHasSimulatedDevice != null && buildOptions.isMobileHasSimulatedDevice.name != 'null') {
						for (i in 0...cmbModelOption.dataProvider.length) {
							if (BuildOptions(setting.provider).isMobileHasSimulatedDevice.name == Reflect.getProperty(cmbModelOption.dataProvider, Std.string(i)).name) {
								cmbModelOption.selectedIndex = i;
								lastSelectedItem = Reflect.getProperty(cmbModelOption.dataProvider, Std.string(i));
								break;
							}
						}
					}
				});
	}

	public function updateDevices(forPlatform:String):Void {
		currentState = ((cmbOption.selectedIndex == 0)) ? 'simulator' : 'device';

		cmbModelOption.dataProvider = ((forPlatform == null || forPlatform != 'iOS')) ? ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES : ConstantsCoreVO.TEMPLATES_IOS_DEVICES;
		isAndroidDevice = ((forPlatform == 'iOS')) ? false : true;
		cmbModelOption.callLater(function():Void {
					lastSelectedItem = cmbModelOption.selectedItem;
				});

		// generate content for device debugging
		if (deviceContent != null && currentState == 'device') {
			if (isAndroidDevice) {
				deviceSettings = [
								new PathSetting(setting.provider, 'certAndroid', 'Certificate', false, AS3.string(Reflect.field(setting.provider, 'certAndroid')), false),
								new StringSetting(setting.provider, 'certAndroidPassword', 'Certificate Password')
				];
			} else {
				deviceSettings = [
								new MultiOptionSetting(setting.provider, 'iosPackagingMode', 'Packaging Mode',
								[
										new NameValuePair('Standard', BuildOptions.IOS_PACKAGING_STANDARD),
										new NameValuePair('Fast', BuildOptions.IOS_PACKAGING_FAST)
					]),
								new PathSetting(setting.provider, 'certIos', 'Certificate', false, AS3.string(Reflect.field(setting.provider, 'certIos')), false),
								new StringSetting(setting.provider, 'certIosPassword', 'Certificate Password'),
								new PathSetting(setting.provider, 'certIosProvisioning', 'Provisioning Profile', false, AS3.string(Reflect.field(setting.provider, 'certIosProvisioning')), false)
				];
			}

			deviceContent.removeAllElements();

			var line:Line;
			var rdr:IVisualElement;
			var index:Int = 1;
			for (value in deviceSettings) {
				rdr = value.renderer;
				Reflect.setProperty(rdr, 'paddingLeft', Reflect.setProperty(rdr, 'paddingRight', 0));
				deviceContent.addElement(rdr);

				// don't add the line for last item
				if (index != deviceSettings.length) {
					index++;
					line = new Line();
					line.percentWidth = 100;
					line.height = 1;
					line.stroke = new SolidColorStroke(0xdadada);
					deviceContent.addElement(line);
				}
			}
		}
	}

	public function commitChanges():Void {
		if (deviceContent != null && currentState == 'device') {
			for (setting in deviceSettings) {
				if (setting.valueChanged()) {
					setting.commitChanges();
				}
			}
		}
	}

	private function cmbOption_changeHandler(event:IndexChangeEvent):Void {
		BuildOptions(setting.provider).isMobileRunOnSimulator = (cmbOption.selectedIndex == 0);
		BuildOptions(setting.provider).isMobileHasSimulatedDevice = cmbModelOption.selectedItem;

		lastSelectedItem = cmbModelOption.selectedItem;
		updateDevices((isAndroidDevice) ? 'Android' : 'iOS');
	}

	private function onConfigureDevices(event:MouseEvent):Void {
		if (deviceConfiguration == null) {
			deviceConfiguration = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), DeviceConfiguration, true), DeviceConfiguration);
			deviceConfiguration.addEventListener(Event.CHANGE, onDeviceUpdated);
			deviceConfiguration.addEventListener(CloseEvent.CLOSE, onConfigurationPopupClosed);
			PopUpManager.centerPopUp(deviceConfiguration);
		}
	}

	private function onConfigurationPopupClosed(event:CloseEvent):Void {
		deviceConfiguration.removeEventListener(CloseEvent.CLOSE, onConfigurationPopupClosed);
		deviceConfiguration.removeEventListener(Event.CHANGE, onDeviceUpdated);
		deviceConfiguration = null;
	}

	private function onDeviceUpdated(event:Event):Void {
		if (cmbModelOption.dataProvider.getItemIndex(lastSelectedItem) != -1) {
			cmbModelOption.selectedItem = lastSelectedItem;
		}

		GlobalEventDispatcher.getInstance().dispatchEvent(new GeneralEvent(GeneralEvent.DEVICE_UPDATED));
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _RunMobileSettingRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.id = '_RunMobileSettingRenderer_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_RunMobileSettingRenderer_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_RunMobileSettingRenderer_Label1', _RunMobileSettingRenderer_Label1);
		return temp;
	}

	private function _RunMobileSettingRenderer_DropDownList1_i():spark.components.DropDownList {
		var temp:spark.components.DropDownList = new spark.components.DropDownList();
		temp.percentWidth = 100.0;
		temp.height = 24;
		temp.requireSelection = true;
		temp.dataProvider = _RunMobileSettingRenderer_ArrayList1_c();
		temp.setStyle('contentBackgroundColor', 16777215);
		temp.addEventListener('change', __cmbOption_change);
		temp.id = 'cmbOption';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		cmbOption = temp;
		mx.binding.BindingManager.executeBindings(this, 'cmbOption', cmbOption);
		return temp;
	}

	private function _RunMobileSettingRenderer_ArrayList1_c():mx.collections.ArrayList {
		var temp:mx.collections.ArrayList = new mx.collections.ArrayList();
		temp.source = ['AIR Simulator'];
		return temp;
	}

	/**
	 * @private
	 **/
	public function __cmbOption_change(event:spark.events.IndexChangeEvent):Void {
		cmbOption_changeHandler(event);
	}

	private function _RunMobileSettingRenderer_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.height = 3;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _RunMobileSettingRenderer_Rect1_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.percentWidth = 100.0;
		temp.alpha = 1;
		temp.stroke = _RunMobileSettingRenderer_SolidColorStroke1_c();
		temp.initialized(this, '_RunMobileSettingRenderer_Rect1');
		_RunMobileSettingRenderer_Rect1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_RunMobileSettingRenderer_Rect1', _RunMobileSettingRenderer_Rect1);
		return temp;
	}

	private function _RunMobileSettingRenderer_SolidColorStroke1_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.weight = 1;
		temp.color = 14342874;
		return temp;
	}

	private function _RunMobileSettingRenderer_VGroup2_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_RunMobileSettingRenderer_Label2_c(), _RunMobileSettingRenderer_HGroup1_c(), _RunMobileSettingRenderer_Spacer2_c()];
		temp.id = '_RunMobileSettingRenderer_VGroup2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_RunMobileSettingRenderer_VGroup2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_RunMobileSettingRenderer_VGroup2', _RunMobileSettingRenderer_VGroup2);
		return temp;
	}

	private function _RunMobileSettingRenderer_Label2_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Device Model';
		temp.styleName = 'uiTextSettingsLabel';
		temp.setStyle('paddingTop', 13);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _RunMobileSettingRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_RunMobileSettingRenderer_DropDownList2_i(), _RunMobileSettingRenderer_Button1_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _RunMobileSettingRenderer_DropDownList2_i():spark.components.DropDownList {
		var temp:spark.components.DropDownList = new spark.components.DropDownList();
		temp.percentWidth = 100.0;
		temp.height = 24;
		temp.labelField = 'name';
		temp.requireSelection = true;
		temp.setStyle('contentBackgroundColor', 16777215);
		temp.addEventListener('change', __cmbModelOption_change);
		temp.id = 'cmbModelOption';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		cmbModelOption = temp;
		mx.binding.BindingManager.executeBindings(this, 'cmbModelOption', cmbModelOption);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __cmbModelOption_change(event:spark.events.IndexChangeEvent):Void {
		cmbOption_changeHandler(event);
	}

	private function _RunMobileSettingRenderer_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Configure';
		temp.height = 24;
		temp.addEventListener('click', ___RunMobileSettingRenderer_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___RunMobileSettingRenderer_Button1_click(event:flash.events.MouseEvent):Void {
		onConfigureDevices(event);
	}

	private function _RunMobileSettingRenderer_Spacer2_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.height = 3;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _RunMobileSettingRenderer_VGroup3_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.gap = 0;
		temp.id = 'deviceContent';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		deviceContent = temp;
		mx.binding.BindingManager.executeBindings(this, 'deviceContent', deviceContent);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___RunMobileSettingRenderer_VGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		init();
	}

	//  binding mgmt
	private function _RunMobileSettingRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_RunMobileSettingRenderer_Label1.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(RunMobileSettingRenderer)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	//  end embed carrier vars

	//  binding management vars
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindings:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _watchers:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsByDestination:Dynamic = {};
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsBeginWithWord:Dynamic = {};

}

//  end package def