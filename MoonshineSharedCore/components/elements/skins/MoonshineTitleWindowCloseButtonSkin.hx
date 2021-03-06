/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    elements.skins
 *  Class:      MoonshineTitleWindowCloseButtonSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/elements/skins/MoonshineTitleWindowCloseButtonSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package elements.skins;

import mx.core.UIComponent;
import mx.events.FlexEvent;

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
import mx.core.IStateClient2;
import mx.core.Mx_internal;

import mx.filters.*;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.skins.SparkSkin;

/**
* @copy spark.skins.spark.ApplicationSkin#hostComponent
*/
@:meta(HostComponent(name = 'spark.components.Button'))
@:meta(States(name = 'up', name = 'over', name = 'down', name = 'disabled'))
//  begin class def
class MoonshineTitleWindowCloseButtonSkin extends spark.skins.SparkSkin implements mx.core.IStateClient2 {

	//  instance variables

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
		this.currentState = 'up';

		// events
		this.addEventListener('creationComplete', ___MoonshineTitleWindowCloseButtonSkin_SparkSkin1_creationComplete);

		states = [
				new State({
					'name': 'up',
					'overrides': []
				}),
				new State({
					'name': 'over',
					'overrides': []
				}),
				new State({
					'name': 'down',
					'overrides': []
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
	//  <Script>, line 46 - 95

	private function onCreationCompletes(event:FlexEvent):Void {
		var closeButtonUIC:UIComponent = new UIComponent();
		closeButtonUIC.width = closeButtonUIC.height = 27;
		closeButtonUIC.right = 0;

		var closeButton:Sprite = new Sprite();
		// Circle
		closeButton.graphics.lineStyle(1, 0xFFFFFF, 0.8);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawCircle(14, 12, 6);
		closeButton.graphics.endFill();
		// X (\)
		closeButton.graphics.lineStyle(2, 0xFFFFFF, 0.8, true);
		closeButton.graphics.moveTo(12, 10);
		closeButton.graphics.lineTo(16, 14);
		// X (/)
		closeButton.graphics.moveTo(16, 10);
		closeButton.graphics.lineTo(12, 14);
		// Hit area
		closeButton.graphics.lineStyle(0, 0x0, 0);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawRect(0, 0, 27, 25);
		closeButton.graphics.endFill();

		closeButtonUIC.addChild(closeButton);
		addElement(closeButtonUIC);
	}

	/* Define the skin elements that should not be colorized.
	For closeButton, the graphics are colorized but the x is not. */
	private static var exclusions(default, never):Array<Dynamic> = [];

	/**
	 * @private
	 */
	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	/* Define the symbol fill items that should be colored by the "symbolColor" style. */
	private static var symbols(default, never):Array<Dynamic> = [];

	/**
	 * @private
	 */
	override private function get_symbolItems():Array<Dynamic> {
		return symbols;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	/**
	 * @private
	 **/
	public function ___MoonshineTitleWindowCloseButtonSkin_SparkSkin1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreationCompletes(event);
	}

}

//  end package def