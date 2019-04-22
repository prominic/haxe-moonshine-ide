/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.ui.tabNavigator.skin
 *  Class:      TabBarScrollerSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/ui/tabNavigator/skin/TabBarScrollerSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package actionScripts.ui.tabNavigator.skin;

import actionScripts.ui.tabNavigator.skin.TabBarScrollerSkinInnerClass0;
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
import spark.skins.SparkSkin;

/**
 * @copy spark.skins.spark.ApplicationSkin#hostComponent
 */
@:meta(HostComponent(name = 'spark.components.Scroller'))
//  begin class def
class TabBarScrollerSkin extends spark.skins.SparkSkin {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var horizontalScrollBarFactory:mx.core.ClassFactory;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		// layer initializers

		// properties
		_TabBarScrollerSkin_ClassFactory1_i();

		// events

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
	private function _TabBarScrollerSkin_ClassFactory1_i():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = actionScripts.ui.tabNavigator.skin.TabBarScrollerSkinInnerClass0;
		temp.properties = {
					'outerDocument': this
				};
		horizontalScrollBarFactory = temp;
		mx.binding.BindingManager.executeBindings(this, 'horizontalScrollBarFactory', horizontalScrollBarFactory);
		return temp;
	}

}

//  end package def