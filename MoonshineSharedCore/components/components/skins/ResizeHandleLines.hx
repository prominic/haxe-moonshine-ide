/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.skins
 *  Class:      ResizeHandleLines
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/skins/ResizeHandleLines.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package components.skins;

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
import mx.core.Mx_internal;
import mx.filters.*;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.styles.*;
import spark.components.Group;
import spark.primitives.Line;
import spark.primitives.Path;

//  begin class def
class ResizeHandleLines extends spark.components.Group implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _ResizeHandleLines_Path1:spark.primitives.Path;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ResizeHandleLines_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_skins_ResizeHandleLinesWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ResizeHandleLines, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.height = 13;
		this.width = 13;
		this.mxmlContent = [_ResizeHandleLines_Path1_i(), _ResizeHandleLines_Line1_c(), _ResizeHandleLines_Line2_c(), _ResizeHandleLines_Line3_c(), _ResizeHandleLines_Line4_c(), _ResizeHandleLines_Line5_c(), _ResizeHandleLines_Line6_c()];

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
	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _ResizeHandleLines_Path1_i():spark.primitives.Path {
		var temp:spark.primitives.Path = new spark.primitives.Path();
		temp.fill = _ResizeHandleLines_SolidColor1_c();
		temp.initialized(this, '_ResizeHandleLines_Path1');
		_ResizeHandleLines_Path1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ResizeHandleLines_Path1', _ResizeHandleLines_Path1);
		return temp;
	}

	private function _ResizeHandleLines_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 16777215;
		temp.alpha = 0.2;
		return temp;
	}

	private function _ResizeHandleLines_Line1_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 1;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 1;
		temp.stroke = _ResizeHandleLines_SolidColorStroke1_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke1_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 9145227;
		return temp;
	}

	private function _ResizeHandleLines_Line2_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 2;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 2;
		temp.stroke = _ResizeHandleLines_SolidColorStroke2_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke2_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 14342874;
		return temp;
	}

	private function _ResizeHandleLines_Line3_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 5;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 5;
		temp.stroke = _ResizeHandleLines_SolidColorStroke3_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke3_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 9145227;
		return temp;
	}

	private function _ResizeHandleLines_Line4_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 6;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 6;
		temp.stroke = _ResizeHandleLines_SolidColorStroke4_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke4_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 14342874;
		return temp;
	}

	private function _ResizeHandleLines_Line5_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 9;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 9;
		temp.stroke = _ResizeHandleLines_SolidColorStroke5_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke5_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 9145227;
		return temp;
	}

	private function _ResizeHandleLines_Line6_c():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.xFrom = 10;
		temp.xTo = 12;
		temp.yFrom = 12;
		temp.yTo = 10;
		temp.stroke = _ResizeHandleLines_SolidColorStroke6_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizeHandleLines_SolidColorStroke6_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.color = 14342874;
		return temp;
	}

	//  binding mgmt
	private function _ResizeHandleLines_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = 'M 0 ' + (height) + ' L ' + (width) + ' 0 V ' + (height) + ' H ' + (0) + ' Z';
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_ResizeHandleLines_Path1.data');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ResizeHandleLines)._watcherSetupUtil = watcherSetupUtil;
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