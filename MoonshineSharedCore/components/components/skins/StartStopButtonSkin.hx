/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.skins
 *  Class:      StartStopButtonSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/skins/StartStopButtonSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
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
import mx.graphics.GradientEntry;
import mx.graphics.LinearGradientStroke;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.components.Label;
import spark.primitives.Line;
import spark.primitives.Path;
import spark.primitives.Rect;
import spark.skins.SparkButtonSkin;

/**
 * @copy spark.skins.spark.ApplicationSkin#hostComponent
 */
@:meta(HostComponent(name = 'spark.components.ButtonBarButton'))
@:meta(States(name = 'up', name = 'over', name = 'down', name = 'disabled', name = 'upAndSelected', name = 'overAndSelected', name = 'downAndSelected', name = 'disabledAndSelected'))
//  begin class def
class StartStopButtonSkin extends spark.skins.SparkButtonSkin implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _StartStopButtonSkin_GradientEntry1:mx.graphics.GradientEntry;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _StartStopButtonSkin_GradientEntry2:mx.graphics.GradientEntry;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _StartStopButtonSkin_SolidColor1:mx.graphics.SolidColor;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _StartStopButtonSkin_SolidColorStroke1:mx.graphics.SolidColorStroke;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var borderBottom:spark.primitives.Line;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var borderTop:spark.primitives.Path;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var fill:spark.primitives.Rect;

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
		this.minWidth = 21;
		this.minHeight = 21;
		this.mxmlContent = [_StartStopButtonSkin_Rect1_i(), _StartStopButtonSkin_Line1_i(), _StartStopButtonSkin_Path1_i(), _StartStopButtonSkin_Label1_i()];
		this.currentState = 'up';

		// events

		states = [
				new State({
					'name': 'up',
					'overrides': []
				}),
				new State({
					'name': 'over',
					'stateGroups': ['overStates'],
					'overrides': []
				}),
				new State({
					'name': 'down',
					'stateGroups': ['downStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'alpha',
								'value': 0.85
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry1',
								'name': 'alpha',
								'value': 0.6375
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry2',
								'name': 'alpha',
								'value': 0.85
							})
			]
				}),
				new State({
					'name': 'disabled',
					'stateGroups': ['disabledStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'name': 'alpha',
								'value': 0.5
							})
			]
				}),
				new State({
					'name': 'upAndSelected',
					'stateGroups': ['selectedUpStates', 'selectedStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColor1',
								'name': 'color',
								'value': 4342338
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'color',
								'value': 13619151
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'alpha',
								'value': 0.5
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry1',
								'name': 'alpha',
								'value': 0.6375
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry2',
								'name': 'alpha',
								'value': 0.85
							})
			]
				}),
				new State({
					'name': 'overAndSelected',
					'stateGroups': ['overStates', 'selectedStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColor1',
								'name': 'color',
								'value': 4342338
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'color',
								'value': 13619151
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'alpha',
								'value': 0.5
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry1',
								'name': 'alpha',
								'value': 0.6375
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry2',
								'name': 'alpha',
								'value': 0.85
							})
			]
				}),
				new State({
					'name': 'downAndSelected',
					'stateGroups': ['downStates', 'selectedStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColor1',
								'name': 'color',
								'value': 4342338
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'color',
								'value': 13619151
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'alpha',
								'value': 0.5
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry1',
								'name': 'alpha',
								'value': 0.6375
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry2',
								'name': 'alpha',
								'value': 0.85
							})
			]
				}),
				new State({
					'name': 'disabledAndSelected',
					'stateGroups': ['disabledStates', 'selectedUpStates', 'selectedStates'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColor1',
								'name': 'color',
								'value': 4342338
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'color',
								'value': 13619151
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_SolidColorStroke1',
								'name': 'alpha',
								'value': 0.5
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry1',
								'name': 'alpha',
								'value': 0.6375
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_StartStopButtonSkin_GradientEntry2',
								'name': 'alpha',
								'value': 0.85
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
	//  <Script>, line 18 - 128

	private static var exclusions(default, never):Array<Dynamic> = cast ['labelDisplay'];

	/**
	 * @private
	 */
	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	/**
	 * @private
	 */
	override private function initializationComplete():Void {
		useChromeColor = true;
		super.initializationComplete();
	}

	private var cornerRadius:Float = 1;

	/**
	 *  @private
	 *  The borderTop s:Path is just a s:Rect with the bottom edge left out.
	 *  Given the rounded corners per the cornerRadius style, the result is
	 *  roughly an inverted U with the specified width, height, and cornerRadius.
	 *
	 *  Circular arcs are drawn with two curves per flash.display.Graphics.GraphicsUtil.
	 */
	private function updateBorderTop(width:Float, height:Float):Void {
		// Generate path data and lay it out. The path is not being layout by the default BasicLayout of this skin
		// since we excluded it from the layout.
		var path:String = createPathData(true);
		borderTop.data = path;
		borderTop.setLayoutBoundsSize(width, height, false);
		borderTop.setLayoutBoundsPosition(0, 0, false);
	}

	/**
	 *  @private
	 *  This function creates the path data used by borderTop and selectedHighlight.
	 */
	private function createPathData(isBorder:Bool):String {
		var left:Float = 0;
		var right:Float = width;
		var top:Float = 0.5;
		var bottom:Float = height;

		var a:Float = cornerRadius * 0.292893218813453;
		var s:Float = cornerRadius * 0.585786437626905;

		// If the path is for the highlight,
		// Draw the vertical part of the selected tab highlight that's rendered
		// with alpha=0.07.  The s:Path is configured to include only the left and
		// right edges of an s:Rect, along with the top left,right rounded corners.
		// Otherwise, we draw a full path.
		var path:String = '';
		path += 'M ' + left + ' ' + bottom;
		path += ' L ' + left + ' ' + (top + cornerRadius);
		path += ' Q ' + left + ' ' + (top + s) + ' ' + (left + a) + ' ' + (top + a);
		path += ' Q ' + (left + s) + ' ' + top + ' ' + (left + cornerRadius) + ' ' + top;

		if (isBorder) {
			path += ' L ' + (right - cornerRadius) + ' ' + top;
		} else {
			path += ' M ' + (right - cornerRadius) + ' ' + top;
		}

		path += ' Q ' + (right - s) + ' ' + top + ' ' + (right - a) + ' ' + (top + a);
		path += ' Q ' + right + ' ' + (top + s) + ' ' + right + ' ' + (top + cornerRadius);
		path += ' L ' + right + ' ' + bottom;

		return path;
	}

	/**
	 *  @private
	 *  The cornerRadius style is specified by the TabBar, not the button itself.
	 *
	 *  Rather than bind the corner radius properties of the s:Rect's in the markup
	 *  below to hostComponent.owner.getStyle("cornerRadius"), we reset them here,
	 *  each time a change in the value of the style is detected.  Note that each
	 *  corner radius property is explicitly initialized to the default value of
	 *  the style; the initial value of the private cornerRadius property.
	 */
	private function updateCornerRadius():Void {
		var cr:Float = getStyle('cornerRadius');
		if (cornerRadius != cr) {
			cornerRadius = cr;
			fill.topLeftRadiusX = cornerRadius;
			fill.topRightRadiusX = cornerRadius;
		}
	}

	/**
	 *  @private
	 */
	override private function updateDisplayList(unscaledWidth:Float, unscaleHeight:Float):Void {
		updateCornerRadius();
		updateBorderTop(unscaledWidth, unscaledHeight);

		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _StartStopButtonSkin_Rect1_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.bottom = 1;
		temp.topLeftRadiusX = 4;
		temp.topRightRadiusX = 4;
		temp.width = 70;
		temp.height = 22;
		temp.fill = _StartStopButtonSkin_SolidColor1_i();
		temp.initialized(this, 'fill');
		fill = temp;
		mx.binding.BindingManager.executeBindings(this, 'fill', fill);
		return temp;
	}

	private function _StartStopButtonSkin_SolidColor1_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 8462647;
		_StartStopButtonSkin_SolidColor1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_StartStopButtonSkin_SolidColor1', _StartStopButtonSkin_SolidColor1);
		return temp;
	}

	private function _StartStopButtonSkin_Line1_i():spark.primitives.Line {
		var temp:spark.primitives.Line = new spark.primitives.Line();
		temp.left = 0;
		temp.right = 0;
		temp.bottom = 0;
		temp.stroke = _StartStopButtonSkin_SolidColorStroke1_i();
		temp.initialized(this, 'borderBottom');
		borderBottom = temp;
		mx.binding.BindingManager.executeBindings(this, 'borderBottom', borderBottom);
		return temp;
	}

	private function _StartStopButtonSkin_SolidColorStroke1_i():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.weight = 1;
		temp.color = 13619151;
		temp.alpha = 0.75;
		_StartStopButtonSkin_SolidColorStroke1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_StartStopButtonSkin_SolidColorStroke1', _StartStopButtonSkin_SolidColorStroke1);
		return temp;
	}

	private function _StartStopButtonSkin_Path1_i():spark.primitives.Path {
		var temp:spark.primitives.Path = new spark.primitives.Path();
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.bottom = 0;
		temp.includeInLayout = false;
		temp.stroke = _StartStopButtonSkin_LinearGradientStroke1_c();
		temp.initialized(this, 'borderTop');
		borderTop = temp;
		mx.binding.BindingManager.executeBindings(this, 'borderTop', borderTop);
		return temp;
	}

	private function _StartStopButtonSkin_LinearGradientStroke1_c():mx.graphics.LinearGradientStroke {
		var temp:mx.graphics.LinearGradientStroke = new mx.graphics.LinearGradientStroke();
		temp.rotation = 90;
		temp.weight = 1;
		temp.entries = [_StartStopButtonSkin_GradientEntry1_i(), _StartStopButtonSkin_GradientEntry2_i()];
		return temp;
	}

	private function _StartStopButtonSkin_GradientEntry1_i():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 13619151;
		temp.alpha = 0.5625;
		_StartStopButtonSkin_GradientEntry1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_StartStopButtonSkin_GradientEntry1', _StartStopButtonSkin_GradientEntry1);
		return temp;
	}

	private function _StartStopButtonSkin_GradientEntry2_i():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 13619151;
		temp.alpha = 0.75;
		_StartStopButtonSkin_GradientEntry2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_StartStopButtonSkin_GradientEntry2', _StartStopButtonSkin_GradientEntry2);
		return temp;
	}

	private function _StartStopButtonSkin_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.showTruncationTip = true;
		temp.maxDisplayedLines = 1;
		temp.left = 10;
		temp.top = 2;
		temp.right = 10;
		temp.verticalCenter = 0;
		temp.setStyle('textAlign', 'center');
		temp.setStyle('color', 16777215);
		temp.id = 'labelDisplay';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		labelDisplay = temp;
		mx.binding.BindingManager.executeBindings(this, 'labelDisplay', labelDisplay);
		return temp;
	}

}

//  end package def