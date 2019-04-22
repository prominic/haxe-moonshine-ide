/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    elements.skins
 *  Class:      DarkButtonSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/elements/skins/DarkButtonSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
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
import mx.graphics.SolidColorStroke;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.components.Label;
import spark.filters.DropShadowFilter;
import spark.filters.GlowFilter;
import spark.primitives.Rect;
import spark.skins.SparkSkin;

@:meta(HostComponent(name = 'spark.components.Button'))
@:meta(States(name = 'up', name = 'over', name = 'down', name = 'disabled'))
//  begin class def
class DarkButtonSkin extends spark.skins.SparkSkin implements mx.binding.IBindingClient implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _DarkButtonSkin_DropShadowFilter1:spark.filters.DropShadowFilter;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _DarkButtonSkin_GlowFilter2:spark.filters.GlowFilter;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _DarkButtonSkin_SolidColor2:mx.graphics.SolidColor;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _DarkButtonSkin_SolidColorStroke1:mx.graphics.SolidColorStroke;

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

		var bindings:Array<Dynamic> = _DarkButtonSkin_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_elements_skins_DarkButtonSkinWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(DarkButtonSkin, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.mxmlContent = [_DarkButtonSkin_Rect1_c(), _DarkButtonSkin_Rect2_c(), _DarkButtonSkin_Label1_i()];
		this.currentState = 'up';

		// events

		states = [
				new State({
					'name': 'up',
					'overrides': []
				}),
				new State({
					'name': 'over',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_DropShadowFilter1',
								'name': 'alpha',
								'value': 0.08
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_GlowFilter2',
								'name': 'alpha',
								'value': 1
							})
			]
				}),
				new State({
					'name': 'down',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_SolidColorStroke1',
								'name': 'color',
								'value': 4210752
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_DropShadowFilter1',
								'name': 'alpha',
								'value': 0.05
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_GlowFilter2',
								'name': 'alpha',
								'value': 0.05
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_GlowFilter2',
								'name': 'inner',
								'value': true
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_DarkButtonSkin_SolidColor2',
								'name': 'color',
								'value': 4144959
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
	//  <Script>, line 19 - 25

	private static var exclusions(default, never):Array<Dynamic> = cast ['labelElement'];

	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _DarkButtonSkin_Rect1_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.radiusX = 7;
		temp.radiusY = 7;
		temp.filters = [_DarkButtonSkin_GlowFilter1_c()];
		temp.fill = _DarkButtonSkin_SolidColor1_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _DarkButtonSkin_GlowFilter1_c():spark.filters.GlowFilter {
		var temp:spark.filters.GlowFilter = new spark.filters.GlowFilter();
		temp.alpha = 1;
		temp.color = 4868682;
		temp.blurX = 2;
		temp.blurY = 2;
		temp.strength = 3;
		return temp;
	}

	private function _DarkButtonSkin_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 2697513;
		temp.alpha = 1;
		return temp;
	}

	private function _DarkButtonSkin_Rect2_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.top = 3;
		temp.bottom = 3;
		temp.left = 3;
		temp.right = 3;
		temp.verticalCenter = 0;
		temp.horizontalCenter = 0;
		temp.radiusX = 3;
		temp.radiusY = 3;
		temp.stroke = _DarkButtonSkin_SolidColorStroke1_i();
		temp.filters = [_DarkButtonSkin_DropShadowFilter1_i(), _DarkButtonSkin_DropShadowFilter2_c(), _DarkButtonSkin_DropShadowFilter3_c(), _DarkButtonSkin_GlowFilter2_i()];
		temp.fill = _DarkButtonSkin_SolidColor2_i();
		temp.initialized(this, null);
		return temp;
	}

	private function _DarkButtonSkin_SolidColorStroke1_i():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.pixelHinting = true;
		temp.color = 4868682;
		temp.weight = 1;
		_DarkButtonSkin_SolidColorStroke1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_DarkButtonSkin_SolidColorStroke1', _DarkButtonSkin_SolidColorStroke1);
		return temp;
	}

	private function _DarkButtonSkin_DropShadowFilter1_i():spark.filters.DropShadowFilter {
		var temp:spark.filters.DropShadowFilter = new spark.filters.DropShadowFilter();
		temp.angle = -90;
		temp.blurX = 0;
		temp.blurY = 0;
		temp.inner = true;
		temp.color = 0;
		temp.alpha = 0.05;
		_DarkButtonSkin_DropShadowFilter1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_DarkButtonSkin_DropShadowFilter1', _DarkButtonSkin_DropShadowFilter1);
		return temp;
	}

	private function _DarkButtonSkin_DropShadowFilter2_c():spark.filters.DropShadowFilter {
		var temp:spark.filters.DropShadowFilter = new spark.filters.DropShadowFilter();
		temp.angle = -90;
		temp.blurX = 0;
		temp.blurY = 2;
		temp.inner = true;
		temp.distance = 2;
		temp.color = 1118481;
		temp.alpha = 0.1;
		return temp;
	}

	private function _DarkButtonSkin_DropShadowFilter3_c():spark.filters.DropShadowFilter {
		var temp:spark.filters.DropShadowFilter = new spark.filters.DropShadowFilter();
		temp.angle = 90;
		temp.blurX = 0;
		temp.blurY = 1;
		temp.inner = true;
		temp.distance = 2;
		temp.color = 16777215;
		temp.alpha = 0.05;
		return temp;
	}

	private function _DarkButtonSkin_GlowFilter2_i():spark.filters.GlowFilter {
		var temp:spark.filters.GlowFilter = new spark.filters.GlowFilter();
		temp.color = 2236962;
		temp.alpha = 0;
		temp.blurX = 4;
		temp.blurY = 4;
		_DarkButtonSkin_GlowFilter2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_DarkButtonSkin_GlowFilter2', _DarkButtonSkin_GlowFilter2);
		return temp;
	}

	private function _DarkButtonSkin_SolidColor2_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 4473924;
		temp.alpha = 1;
		_DarkButtonSkin_SolidColor2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_DarkButtonSkin_SolidColor2', _DarkButtonSkin_SolidColor2);
		return temp;
	}

	private function _DarkButtonSkin_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.useHandCursor = true;
		temp.setStyle('paddingLeft', 20);
		temp.setStyle('paddingRight', 20);
		temp.setStyle('paddingTop', 10);
		temp.setStyle('paddingBottom', 9);
		temp.setStyle('color', 12303291);
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
	private function _DarkButtonSkin_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Float {
					return ((height / 2) - 4);
				},
				null,
				'_DarkButtonSkin_DropShadowFilter1.distance');

		result[1] = new mx.binding.Binding(this,
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
		(DarkButtonSkin)._watcherSetupUtil = watcherSetupUtil;
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