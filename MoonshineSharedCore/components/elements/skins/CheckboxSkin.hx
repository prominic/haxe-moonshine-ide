/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    elements.skins
 *  Class:      CheckboxSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/elements/skins/CheckboxSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package elements.skins;

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
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.IStateClient2;
import mx.core.Mx_internal;
import mx.filters.*;
import mx.graphics.SolidColor;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.components.Label;
import spark.filters.GlowFilter;
import spark.primitives.Rect;
import spark.skins.SparkSkin;

@:meta(HostComponent(name = 'spark.components.CheckBox'))
@:meta(States(name = 'up', name = 'over', name = 'down', name = 'disabled', name = 'selected', name = 'overAndSelected', name = 'upAndSelected', name = 'downAndSelected', name = 'disabledAndSelected'))
//  begin class def
class CheckboxSkin extends spark.skins.SparkSkin implements mx.binding.IBindingClient implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _CheckboxSkin_SolidColor2:mx.graphics.SolidColor;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var labelElement:spark.components.Label;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _CheckboxSkin_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_elements_skins_CheckboxSkinWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(CheckboxSkin, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.mxmlContent = [_CheckboxSkin_Rect1_c(), _CheckboxSkin_Rect2_c(), _CheckboxSkin_Label1_i()];
		this.currentState = 'up';

		// events

		states = [
				new State({
					'name': 'up',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 0
							})
			]
				}),
				new State({
					'name': 'over',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 0.2
							})
			]
				}),
				new State({
					'name': 'down',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 1
							})
			]
				}),
				new State({
					'name': 'disabled',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'name': 'alpha',
								'value': 0.5
							})
			]
				}),
				new State({
					'name': 'selected',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 1
							})
			]
				}),
				new State({
					'name': 'overAndSelected',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 1
							})
			]
				}),
				new State({
					'name': 'upAndSelected',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CheckboxSkin_SolidColor2',
								'name': 'alpha',
								'value': 1
							})
			]
				}),
				new State({
					'name': 'downAndSelected',
					'overrides': []
				}),
				new State({
					'name': 'disabledAndSelected',
					'overrides': []
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
	//  <Script>, line 26 - 32

	private static var exclusions(default, never):Array<Dynamic> = cast ['labelElement'];

	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _CheckboxSkin_Rect1_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.width = 13;
		temp.height = 13;
		temp.filters = [_CheckboxSkin_GlowFilter1_c()];
		temp.fill = _CheckboxSkin_SolidColor1_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _CheckboxSkin_GlowFilter1_c():spark.filters.GlowFilter {
		var temp:spark.filters.GlowFilter = new spark.filters.GlowFilter();
		temp.alpha = 0.4;
		temp.color = 0;
		temp.blurX = 4;
		temp.blurY = 4;
		temp.strength = 1;
		temp.inner = true;
		return temp;
	}

	private function _CheckboxSkin_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 3355443;
		temp.alpha = 1;
		return temp;
	}

	private function _CheckboxSkin_Rect2_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.top = 2;
		temp.left = 2;
		temp.width = 9;
		temp.height = 9;
		temp.fill = _CheckboxSkin_SolidColor2_i();
		temp.initialized(this, null);
		return temp;
	}

	private function _CheckboxSkin_SolidColor2_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 16119285;
		_CheckboxSkin_SolidColor2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_CheckboxSkin_SolidColor2', _CheckboxSkin_SolidColor2);
		return temp;
	}

	private function _CheckboxSkin_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.left = 17;
		temp.top = 2;
		temp.right = 2;
		temp.setStyle('fontFamily', 'DejaVuSans');
		temp.id = 'labelElement';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		labelElement = temp;
		mx.binding.BindingManager.executeBindings(this, 'labelElement', labelElement);
		return temp;
	}

	//  binding mgmt
	private function _CheckboxSkin_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (hostComponent.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'labelElement.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(CheckboxSkin)._watcherSetupUtil = watcherSetupUtil;
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