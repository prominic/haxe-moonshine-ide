/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.views.project
 *  Class:      ListItemRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/views/project/ListItemRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.views.project;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filters.*;
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
import mx.containers.HBox;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponentDescriptor;
import mx.core.Mx_internal;
import mx.styles.*;
import spark.components.Label;

//  begin class def
class ListItemRenderer extends mx.containers.HBox implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _ListItemRenderer_Label1:spark.components.Label;

	//  type-import dummies

	//  Container document descriptor
	private var _documentDescriptor_:mx.core.UIComponentDescriptor;

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		this._documentDescriptor_ =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.HBox,
					'propertiesFactory': function():Dynamic {
						return {
							'height': 18,
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': spark.components.Label,
								'id': '_ListItemRenderer_Label1',
								'stylesFactory': function():Void {
									this.paddingLeft = 3;
									this.fontFamily = 'DejaVuSans';
									this.fontSize = 12;
									this.color = 14737632;
								}
							})
				]
						};
					}
				});
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ListItemRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_views_project_ListItemRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ListItemRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.height = 18;

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
		// mx_internal::setDocumentDescriptor(_documentDescriptor_);

		super.initialize();
	}

	//  scripts
	//  end scripts

	//  supporting function definitions for properties, events, styles, effects

	//  binding mgmt
	private function _ListItemRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (data.name);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_ListItemRenderer_Label1.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ListItemRenderer)._watcherSetupUtil = watcherSetupUtil;
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