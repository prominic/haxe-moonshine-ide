/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.settings.renderers
 *  Class:      BooleanRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/settings/renderers/BooleanRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package actionScripts.plugin.settings.renderers;

import actionScripts.plugin.settings.vo.BooleanSetting;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.Event;
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
import mx.controls.Spacer;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;
import mx.filters.*;
import mx.styles.*;
import spark.components.CheckBox;
import spark.components.HGroup;
import spark.components.Label;

//  begin class def
class BooleanRenderer extends spark.components.HGroup implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _BooleanRenderer_Label1:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var uiCheckBox:spark.components.CheckBox;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _BooleanRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_settings_renderers_BooleanRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(BooleanRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.paddingLeft = 15;
		this.paddingTop = 15;
		this.paddingRight = 15;
		this.paddingBottom = 15;
		this.mxmlContent = [_BooleanRenderer_Label1_i(), _BooleanRenderer_Spacer1_c(), _BooleanRenderer_CheckBox1_i()];

		// events

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
	//  <Script>, line 34 - 53

	@:meta(Bindable())
	public var setting:BooleanSetting;

	private function onBooleanChange(event:Event):Void {
		setting.value = AS3.as(uiCheckBox.selected, Bool);
		setting.dispatchEvent(new Event(BooleanSetting.VALUE_UPDATED));
	}

	private function onTextLabelMouseDown(event:MouseEvent):Void {
		uiCheckBox.selected = !uiCheckBox.selected;
		setting.value = AS3.as(uiCheckBox.selected, Bool);
		setting.dispatchEvent(new Event(BooleanSetting.VALUE_UPDATED));
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _BooleanRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.addEventListener('mouseDown', ___BooleanRenderer_Label1_mouseDown);
		temp.id = '_BooleanRenderer_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_BooleanRenderer_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_BooleanRenderer_Label1', _BooleanRenderer_Label1);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___BooleanRenderer_Label1_mouseDown(event:flash.events.MouseEvent):Void {
		onTextLabelMouseDown(event);
	}

	private function _BooleanRenderer_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _BooleanRenderer_CheckBox1_i():spark.components.CheckBox {
		var temp:spark.components.CheckBox = new spark.components.CheckBox();
		temp.addEventListener('change', __uiCheckBox_change);
		temp.id = 'uiCheckBox';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		uiCheckBox = temp;
		mx.binding.BindingManager.executeBindings(this, 'uiCheckBox', uiCheckBox);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __uiCheckBox_change(event:flash.events.Event):Void {
		onBooleanChange(event);
	}

	//  binding mgmt
	private function _BooleanRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_BooleanRenderer_Label1.text');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (setting.value);
				},
				null,
				'uiCheckBox.selected');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(BooleanRenderer)._watcherSetupUtil = watcherSetupUtil;
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