/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.settings.renderers
 *  Class:      PluginRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/settings/renderers/PluginRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package actionScripts.plugin.settings.renderers;

import mx.events.ResizeEvent;
import actionScripts.plugin.settings.vo.PluginSetting;

import elements.skins.SparkTextAreaTransparentBG;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
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
import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextArea;
import spark.components.VGroup;

//  begin class def
class PluginRenderer extends spark.components.VGroup implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _PluginRenderer_Label1:spark.components.Label;

	/**
	 * @private
	 **/
	public var _PluginRenderer_Label2:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtTextMess:spark.components.TextArea;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _PluginRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_settings_renderers_PluginRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(PluginRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.paddingTop = 10;
		this.paddingLeft = 10;
		this.paddingRight = 10;
		this.paddingBottom = 20;
		this.mxmlContent = [_PluginRenderer_HGroup1_c(), _PluginRenderer_Spacer1_c(), _PluginRenderer_TextArea1_i()];

		// events
		this.addEventListener('resize', ___PluginRenderer_VGroup1_resize);

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
	//  <Script>, line 36 - 54

	@:meta(Bindable())
	public var setting:PluginSetting;

	private function onWindowResize(event:ResizeEvent):Void {
		txtTextMess.setStyle('borderVisible', false);
		txtTextMess.callLater(function():Void {
					txtTextMess.height = txtTextMess.scroller.viewport.contentHeight + 2;
				});
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _PluginRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_PluginRenderer_VGroup2_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _PluginRenderer_VGroup2_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.gap = 2;
		temp.mxmlContent = [_PluginRenderer_Label1_i(), _PluginRenderer_Label2_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _PluginRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiText';
		temp.setStyle('fontSize', 24);
		temp.setStyle('kerning', 'on');
		temp.setStyle('color', 14832339);
		temp.id = '_PluginRenderer_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_PluginRenderer_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_PluginRenderer_Label1', _PluginRenderer_Label1);
		return temp;
	}

	private function _PluginRenderer_Label2_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiText';
		temp.setStyle('fontSize', 12);
		temp.setStyle('fontStyle', 'italic');
		temp.setStyle('kerning', 'on');
		temp.setStyle('color', 3552822);
		temp.setStyle('paddingLeft', 2);
		temp.id = '_PluginRenderer_Label2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_PluginRenderer_Label2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_PluginRenderer_Label2', _PluginRenderer_Label2);
		return temp;
	}

	private function _PluginRenderer_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.height = 10;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _PluginRenderer_TextArea1_i():spark.components.TextArea {
		var temp:spark.components.TextArea = new spark.components.TextArea();
		temp.percentWidth = 100.0;
		temp.focusEnabled = false;
		temp.editable = false;
		temp.setStyle('paddingLeft', 5);
		temp.setStyle('skinClass', elements.skins.SparkTextAreaTransparentBG);
		temp.id = 'txtTextMess';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtTextMess = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtTextMess', txtTextMess);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___PluginRenderer_VGroup1_resize(event:mx.events.ResizeEvent):Void {
		onWindowResize(event);
	}

	//  binding mgmt
	private function _PluginRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.name);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_PluginRenderer_Label1.text');

		result[1] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = ('by ' + setting.author);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_PluginRenderer_Label2.text');

		result[2] = new mx.binding.Binding(this,
				function():Bool {
					return (setting.author != '');
				},
				null,
				'_PluginRenderer_Label2.includeInLayout');

		result[3] = new mx.binding.Binding(this,
				function():Bool {
					return (setting.author != '');
				},
				null,
				'_PluginRenderer_Label2.visible');

		result[4] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.description);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'txtTextMess.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(PluginRenderer)._watcherSetupUtil = watcherSetupUtil;
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