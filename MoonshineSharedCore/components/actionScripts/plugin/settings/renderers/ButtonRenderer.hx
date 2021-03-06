/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.settings.renderers
 *  Class:      ButtonRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/settings/renderers/ButtonRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package actionScripts.plugin.settings.renderers;

import actionScripts.plugin.settings.vo.ButtonSetting;

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
import mx.controls.Spacer;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;
import mx.events.FlexEvent;
import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.HGroup;
import spark.components.Label;

//  begin class def
class ButtonRenderer extends spark.components.HGroup implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _ButtonRenderer_Label1:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btn:spark.components.Button;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ButtonRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_settings_renderers_ButtonRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ButtonRenderer, propertyName);
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
		this.paddingRight = 15;
		this.paddingTop = 15;
		this.paddingBottom = 15;
		this.verticalAlign = 'middle';
		this.mxmlContent = [_ButtonRenderer_Label1_i(), _ButtonRenderer_Spacer1_c(), _ButtonRenderer_Button1_i()];

		// events
		this.addEventListener('creationComplete', ___ButtonRenderer_HGroup1_creationComplete);

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
	//  <Script>, line 31 - 48

	@:meta(Bindable())
	public var setting:ButtonSetting;

	private function init():Void {
		if (setting.style == ButtonSetting.STYLE_NORMAL) {
			btn.styleName = 'lightButton';
		} else if (setting.style == ButtonSetting.STYLE_DARK) {
			btn.styleName = 'darkButton';
		} else if (setting.style == ButtonSetting.STYLE_DANGER) {
			btn.styleName = 'redButton';
		}
	}

	private function onButtonClicked(event:MouseEvent):Void {
		Reflect.field(setting.provider, setting.handlerName)();
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _ButtonRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.id = '_ButtonRenderer_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_ButtonRenderer_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ButtonRenderer_Label1', _ButtonRenderer_Label1);
		return temp;
	}

	private function _ButtonRenderer_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ButtonRenderer_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.addEventListener('click', __btn_click);
		temp.id = 'btn';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btn = temp;
		mx.binding.BindingManager.executeBindings(this, 'btn', btn);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btn_click(event:flash.events.MouseEvent):Void {
		onButtonClicked(event);
	}

	/**
	 * @private
	 **/
	public function ___ButtonRenderer_HGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		init();
	}

	//  binding mgmt
	private function _ButtonRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_ButtonRenderer_Label1.text');

		result[1] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.stringValue);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'btn.label');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ButtonRenderer)._watcherSetupUtil = watcherSetupUtil;
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