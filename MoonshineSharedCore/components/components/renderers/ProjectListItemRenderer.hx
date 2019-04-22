/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.renderers
 *  Class:      ProjectListItemRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/renderers/ProjectListItemRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package components.renderers;

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
import mx.controls.Image;
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
import spark.components.supportClasses.ItemRenderer;

//  begin class def
class ProjectListItemRenderer extends spark.components.supportClasses.ItemRenderer implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _ProjectListItemRenderer_Image1:mx.controls.Image;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ProjectListItemRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_renderers_ProjectListItemRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ProjectListItemRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.minHeight = 25;
		this.mxmlContent = [_ProjectListItemRenderer_HGroup1_c()];

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
	private function _ProjectListItemRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.paddingRight = 10;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_ProjectListItemRenderer_Label1_i(), _ProjectListItemRenderer_Image1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ProjectListItemRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.verticalCenter = 0;
		temp.setStyle('paddingLeft', 5);
		temp.setStyle('verticalAlign', 'middle');
		temp.setStyle('textAlign', 'justify');
		temp.id = 'labelDisplay';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		labelDisplay = temp;
		mx.binding.BindingManager.executeBindings(this, 'labelDisplay', labelDisplay);
		return temp;
	}

	private function _ProjectListItemRenderer_Image1_i():mx.controls.Image {
		var temp:mx.controls.Image = new mx.controls.Image();
		temp.source = _embed_mxml__elements_swf_loading_swf_1670933735;
		temp.verticalCenter = 0;
		temp.height = 10;
		temp.width = 10;
		temp.setStyle('verticalAlign', 'middle');
		temp.id = '_ProjectListItemRenderer_Image1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_ProjectListItemRenderer_Image1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ProjectListItemRenderer_Image1', _ProjectListItemRenderer_Image1);
		return temp;
	}

	//  binding mgmt
	private function _ProjectListItemRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(data.loading, Bool));
				},
				null,
				'_ProjectListItemRenderer_Image1.includeInLayout');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(data.loading, Bool));
				},
				null,
				'_ProjectListItemRenderer_Image1.visible');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ProjectListItemRenderer)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	@:meta(Embed(source = '/elements/swf/loading.swf'))
	private var _embed_mxml__elements_swf_loading_swf_1670933735:Class<Dynamic>;

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