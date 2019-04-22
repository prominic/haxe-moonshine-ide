/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.ui.codeCompletionList
 *  Class:      CodeDocumentationCloseButtonSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/ui/codeCompletionList/CodeDocumentationCloseButtonSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package actionScripts.ui.codeCompletionList;

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
import mx.graphics.SolidColor;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.components.Group;
import spark.primitives.Path;
import spark.primitives.Rect;
import spark.skins.SparkSkin;

/**
 * @copy spark.skins.spark.ApplicationSkin#hostComponent
 */
@:meta(HostComponent(name = 'spark.components.Button'))
@:meta(States(name = 'up', name = 'over', name = 'down', name = 'disabled'))
//  begin class def
class CodeDocumentationCloseButtonSkin extends spark.skins.SparkSkin implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _CodeDocumentationCloseButtonSkin_SolidColor1:mx.graphics.SolidColor;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var cbshad:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var xFill1:mx.graphics.SolidColor;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var xFill2:mx.graphics.SolidColor;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var xSymbol:spark.components.Group;

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
		this.mxmlContent = [_CodeDocumentationCloseButtonSkin_Rect1_i(), _CodeDocumentationCloseButtonSkin_Group1_i()];
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
								'target': '_CodeDocumentationCloseButtonSkin_SolidColor1',
								'name': 'color',
								'value': 16777215
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CodeDocumentationCloseButtonSkin_SolidColor1',
								'name': 'alpha',
								'value': 0.85
							})
			]
				}),
				new State({
					'name': 'down',
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_CodeDocumentationCloseButtonSkin_SolidColor1',
								'name': 'alpha',
								'value': 0.22
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
	//  <Script>, line 14 - 31

	/* Define the skin elements that should not be colorized.
	For closeButton, the graphics are colorized but the x is not. */
	private static var exclusions(default, never):Array<Dynamic> = cast ['xSymbol'];

	/**
	 * @private
	 */
	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	/* Define the symbol fill items that should be colored by the "symbolColor" style. */
	private static var symbols(default, never):Array<Dynamic> = cast ['xFill1', 'xFill2'];

	/**
	 * @private
	 */
	override private function get_symbolItems():Array<Dynamic> {
		return symbols;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _CodeDocumentationCloseButtonSkin_Rect1_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.height = 1;
		temp.fill = _CodeDocumentationCloseButtonSkin_SolidColor1_i();
		temp.initialized(this, 'cbshad');
		cbshad = temp;
		mx.binding.BindingManager.executeBindings(this, 'cbshad', cbshad);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_SolidColor1_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 0;
		temp.alpha = 0;
		_CodeDocumentationCloseButtonSkin_SolidColor1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_CodeDocumentationCloseButtonSkin_SolidColor1', _CodeDocumentationCloseButtonSkin_SolidColor1);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_Group1_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.top = 1;
		temp.left = 1;
		temp.mxmlContent = [_CodeDocumentationCloseButtonSkin_Path1_c(), _CodeDocumentationCloseButtonSkin_Path2_c(), _CodeDocumentationCloseButtonSkin_Path3_c()];
		temp.id = 'xSymbol';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		xSymbol = temp;
		mx.binding.BindingManager.executeBindings(this, 'xSymbol', xSymbol);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_Path1_c():spark.primitives.Path {
		var temp:spark.primitives.Path = new spark.primitives.Path();
		temp.blendMode = 'normal';
		temp.alpha = 0.85;
		temp.data = 'M 3 5 L 4 5 L 4 6 L 5 6 L 5 7 L 4 7 L 4 8 L 3 8 L 3 9 L 4 9 L 4 10 L 5 10 L 5 9 L 6 9 L 6 8 L 7 8 L 7 9 L 8 9 L 8 10 L 9 10 L 9 9 L 10 9 L 10 8 L 9 8 L 9 7 L 8 7 L 8 6 L 9 6 L 9 5 L 10 5 L 10 4 L 9 4 L 9 3 L 8 3 L 8 4 L 7 4 L 7 5 L 6 5 L 6 4 L 5 4 L 5 3 L 4 3 L 4 4 L 3 4 L 3 5 Z';
		temp.fill = _CodeDocumentationCloseButtonSkin_SolidColor2_i();
		temp.initialized(this, null);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_SolidColor2_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 0;
		xFill1 = temp;
		mx.binding.BindingManager.executeBindings(this, 'xFill1', xFill1);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_Path2_c():spark.primitives.Path {
		var temp:spark.primitives.Path = new spark.primitives.Path();
		temp.blendMode = 'normal';
		temp.alpha = 0.75;
		temp.data = 'M 3 3 L 4 3 L 4 4 L 3 4 L 3 3 M 3 9 L 4 9 L 4 10 L 3 10 L 3 9 M 9 3 L 10 3 L 10 4 L 9 4 L 9 3 M 9 9 L 10 9 L 10 10 L 9 10 L 9 9 Z';
		temp.fill = _CodeDocumentationCloseButtonSkin_SolidColor3_i();
		temp.initialized(this, null);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_SolidColor3_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 0;
		xFill2 = temp;
		mx.binding.BindingManager.executeBindings(this, 'xFill2', xFill2);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_Path3_c():spark.primitives.Path {
		var temp:spark.primitives.Path = new spark.primitives.Path();
		temp.blendMode = 'normal';
		temp.alpha = 0.85;
		temp.data = 'M 3 5 L 3 6 L 4 6 L 4 7 L 5 7 L 5 6 L 4 6 L 4 5 L 3 5 M 8 6 L 8 7 L 9 7 L 9 6 L 10 6 L 10 5 L 9 5 L 9 6 L 8 6 M 3 10 L 3 11 L 5 11 5 10 L 6 10 L 6 9 L 7 9 L 7 10 L 8 10 L 8 11 L 10 11 L 10 10 L 8 10 L 8 9 L 7 9 L 7 8 L 6 8 L 6 9 L 5 9 L 5 10 L 3 10 Z';
		temp.fill = _CodeDocumentationCloseButtonSkin_SolidColor4_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _CodeDocumentationCloseButtonSkin_SolidColor4_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 16777215;
		return temp;
	}

}

//  end package def