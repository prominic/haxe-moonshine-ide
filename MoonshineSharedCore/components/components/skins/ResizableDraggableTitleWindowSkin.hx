/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.skins
 *  Class:      ResizableDraggableTitleWindowSkin
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/skins/ResizableDraggableTitleWindowSkin.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.skins;

import actionScripts.ui.resizableControls.MoveManager;
import actionScripts.ui.resizableControls.ResizeManager;
import mx.events.FlexEvent;

import components.skins.DragHandle;
import components.skins.ResizeHandleLines;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.display.DisplayObject;
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
import mx.graphics.GradientEntry;
import mx.graphics.LinearGradient;
import mx.graphics.LinearGradientStroke;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.states.AddItems;
import mx.states.SetProperty;
import mx.states.State;
import mx.styles.*;
import spark.components.Button;
import spark.components.Group;
import spark.components.Label;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalLayout;
import spark.primitives.Rect;
import spark.primitives.RectangularDropShadow;
import spark.skins.SparkSkin;
import spark.skins.spark.TitleWindowCloseButtonSkin;

/** @copy spark.skins.spark.ApplicationSkin#hostComponent */
@:meta(HostComponent(name = 'spark.components.TitleWindow'))
@:meta(States(name = 'normal', name = 'inactive', name = 'disabled', name = 'normalWithControlBar', name = 'inactiveWithControlBar', name = 'disabledWithControlBar'))
//  begin class def
class ResizableDraggableTitleWindowSkin extends spark.skins.SparkSkin implements mx.binding.IBindingClient implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _ResizableDraggableTitleWindowSkin_GradientEntry1:mx.graphics.GradientEntry;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _ResizableDraggableTitleWindowSkin_GradientEntry2:mx.graphics.GradientEntry;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _ResizableDraggableTitleWindowSkin_Group1:spark.components.Group;

	/**
	 * @private
	 **/
	public var _ResizableDraggableTitleWindowSkin_Group9:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var background:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var backgroundFill:mx.graphics.SolidColor;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var border:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var borderStroke:mx.graphics.SolidColorStroke;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var bottomGroup:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var bottomGroupMask:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var bottomMaskRect:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var closeButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var contentGroup:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var contents:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var controlBarGroup:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var dropShadow:spark.primitives.RectangularDropShadow;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var moveArea:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var resizeHandle:components.skins.ResizeHandleLines;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var tbDiv:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var tbFill:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var tbHilite:spark.primitives.Rect;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var titleDisplay:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var topGroup:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var topGroupMask:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var topMaskRect:spark.primitives.Rect;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ResizableDraggableTitleWindowSkin_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_skins_ResizableDraggableTitleWindowSkinWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ResizableDraggableTitleWindowSkin, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.minHeight = 76;
		this.minWidth = 76;
		this.blendMode = 'normal';
		this.mouseEnabled = false;
		this.mxmlContent = [_ResizableDraggableTitleWindowSkin_RectangularDropShadow1_i(), _ResizableDraggableTitleWindowSkin_Group1_i(), _ResizableDraggableTitleWindowSkin_ResizeHandleLines1_i()];
		this.currentState = 'normal';

		// events
		this.addEventListener('creationComplete', ___ResizableDraggableTitleWindowSkin_SparkSkin1_creationComplete);

		var _ResizableDraggableTitleWindowSkin_Group3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_ResizableDraggableTitleWindowSkin_Group3_i);
		var _ResizableDraggableTitleWindowSkin_Group8_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_ResizableDraggableTitleWindowSkin_Group8_i);

		states = [
				new State({
					'name': 'normal',
					'overrides': []
				}),
				new State({
					'name': 'inactive',
					'stateGroups': ['inactiveGroup'],
					'overrides': [
					new mx.states.SetProperty().initializeFromObject({
								'target': 'dropShadow',
								'name': 'alpha',
								'value': 0.22
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': 'dropShadow',
								'name': 'distance',
								'value': 7
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_ResizableDraggableTitleWindowSkin_GradientEntry1',
								'name': 'color',
								'value': 15395562
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_ResizableDraggableTitleWindowSkin_GradientEntry2',
								'name': 'color',
								'value': 13553358
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
					'name': 'normalWithControlBar',
					'stateGroups': ['withControls'],
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group8_factory,
								'destination': 'contents',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['contentGroup']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group3_factory,
								'destination': '_ResizableDraggableTitleWindowSkin_Group1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['topGroupMask']
							})
			]
				}),
				new State({
					'name': 'inactiveWithControlBar',
					'stateGroups': ['inactiveGroup', 'withControls'],
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group8_factory,
								'destination': 'contents',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['contentGroup']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group3_factory,
								'destination': '_ResizableDraggableTitleWindowSkin_Group1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['topGroupMask']
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': 'dropShadow',
								'name': 'alpha',
								'value': 0.22
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': 'dropShadow',
								'name': 'distance',
								'value': 7
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_ResizableDraggableTitleWindowSkin_GradientEntry1',
								'name': 'color',
								'value': 15395562
							}),
					new mx.states.SetProperty().initializeFromObject({
								'target': '_ResizableDraggableTitleWindowSkin_GradientEntry2',
								'name': 'color',
								'value': 13553358
							})
			]
				}),
				new State({
					'name': 'disabledWithControlBar',
					'stateGroups': ['withControls'],
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group8_factory,
								'destination': 'contents',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['contentGroup']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _ResizableDraggableTitleWindowSkin_Group3_factory,
								'destination': '_ResizableDraggableTitleWindowSkin_Group1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['topGroupMask']
							}),
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
	//  <Script>, line 45 - 110

	/* Define the skin elements that should not be colorized.
	 For panel, border and title background are skinned, but the content area and title text are not. */
	private static var exclusions(default, never):Array<Dynamic> = cast ['background', 'titleDisplay', 'contentGroup'];

	private var cornerRadius:Float;

	override private function get_colorizeExclusions():Array<Dynamic> {
		return exclusions;
	}

	override private function initializationComplete():Void {
		useChromeColor = true;
		super.initializationComplete();
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		if (getStyle('borderVisible') == true) {
			border.visible = true;
			background.left = background.top = background.right = background.bottom = 1;
			contents.left = contents.top = contents.right = contents.bottom = 1;
		} else {
			border.visible = false;
			background.left = background.top = background.right = background.bottom = 0;
			contents.left = contents.top = contents.right = contents.bottom = 0;
		}

		dropShadow.visible = getStyle('dropShadowVisible');

		var cr:Float = getStyle('cornerRadius');
		var withControls:Bool =
		(currentState == 'disabledWithControlBar' ||
		currentState == 'normalWithControlBar' ||
		currentState == 'inactiveWithControlBar');

		if (cornerRadius != cr) {
			cornerRadius = cr;

			dropShadow.tlRadius = cornerRadius;
			dropShadow.trRadius = cornerRadius;
			dropShadow.blRadius = (withControls) ? cornerRadius : 0;
			dropShadow.brRadius = (withControls) ? cornerRadius : 0;

			setPartCornerRadii(topMaskRect, withControls);
			setPartCornerRadii(border, withControls);
			setPartCornerRadii(background, withControls);
		}

		if (bottomMaskRect != null) {
			setPartCornerRadii(bottomMaskRect, withControls);
		}
		borderStroke.color = getStyle('borderColor');
		borderStroke.alpha = getStyle('borderAlpha');
		backgroundFill.color = getStyle('backgroundColor');
		backgroundFill.alpha = getStyle('backgroundAlpha');

		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}

	private function setPartCornerRadii(target:Rect, includeBottom:Bool):Void {
		target.topLeftRadiusX = cornerRadius;
		target.topRightRadiusX = cornerRadius;
		target.bottomLeftRadiusX = (includeBottom) ? cornerRadius : 0;
		target.bottomRightRadiusX = (includeBottom) ? cornerRadius : 0;
	}

	//  <Script>, line 112 - 133

	@:meta(Bindable())
	public var resizeManager:ResizeManager;

	@:meta(Bindable())
	public var moveManager:MoveManager;

	private function created(event:FlexEvent):Void {
		if (hostComponent.minWidth == 0) {
			hostComponent.minWidth = minWidth;
		}
		if (hostComponent.minHeight == 0) {
			hostComponent.minHeight = minHeight;
		}
		resizeManager = new ResizeManager(hostComponent, resizeHandle);
		moveManager = new MoveManager(hostComponent, moveArea);
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _ResizableDraggableTitleWindowSkin_RectangularDropShadow1_i():spark.primitives.RectangularDropShadow {
		var temp:spark.primitives.RectangularDropShadow = new spark.primitives.RectangularDropShadow();
		temp.bottom = 0;
		temp.color = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.alpha = 0.32;
		temp.angle = 90;
		temp.blurX = 20;
		temp.blurY = 20;
		temp.distance = 11;
		temp.id = 'dropShadow';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		dropShadow = temp;
		mx.binding.BindingManager.executeBindings(this, 'dropShadow', dropShadow);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group1_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Group2_i(), _ResizableDraggableTitleWindowSkin_Rect3_i(), _ResizableDraggableTitleWindowSkin_Rect4_i(), _ResizableDraggableTitleWindowSkin_Group4_i()];
		temp.id = '_ResizableDraggableTitleWindowSkin_Group1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_ResizableDraggableTitleWindowSkin_Group1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ResizableDraggableTitleWindowSkin_Group1', _ResizableDraggableTitleWindowSkin_Group1);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group2_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 1;
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Rect1_i()];
		temp.id = 'topGroupMask';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		topGroupMask = temp;
		mx.binding.BindingManager.executeBindings(this, 'topGroupMask', topGroupMask);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect1_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.fill = _ResizableDraggableTitleWindowSkin_SolidColor1_c();
		temp.initialized(this, 'topMaskRect');
		topMaskRect = temp;
		mx.binding.BindingManager.executeBindings(this, 'topMaskRect', topMaskRect);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.alpha = 0;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group3_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 1;
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Rect2_i()];
		temp.id = 'bottomGroupMask';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		bottomGroupMask = temp;
		mx.binding.BindingManager.executeBindings(this, 'bottomGroupMask', bottomGroupMask);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect2_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.fill = _ResizableDraggableTitleWindowSkin_SolidColor2_c();
		temp.initialized(this, 'bottomMaskRect');
		bottomMaskRect = temp;
		mx.binding.BindingManager.executeBindings(this, 'bottomMaskRect', bottomMaskRect);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColor2_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.alpha = 0;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect3_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.stroke = _ResizableDraggableTitleWindowSkin_SolidColorStroke1_i();
		temp.initialized(this, 'border');
		border = temp;
		mx.binding.BindingManager.executeBindings(this, 'border', border);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColorStroke1_i():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.weight = 1;
		borderStroke = temp;
		mx.binding.BindingManager.executeBindings(this, 'borderStroke', borderStroke);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect4_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 1;
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.fill = _ResizableDraggableTitleWindowSkin_SolidColor3_i();
		temp.initialized(this, 'background');
		background = temp;
		mx.binding.BindingManager.executeBindings(this, 'background', background);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColor3_i():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 16777215;
		backgroundFill = temp;
		mx.binding.BindingManager.executeBindings(this, 'backgroundFill', backgroundFill);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group4_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 1;
		temp.left = 1;
		temp.right = 1;
		temp.top = 1;
		temp.layout = _ResizableDraggableTitleWindowSkin_VerticalLayout1_c();
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Group5_i(), _ResizableDraggableTitleWindowSkin_Group7_i()];
		temp.id = 'contents';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		contents = temp;
		mx.binding.BindingManager.executeBindings(this, 'contents', contents);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_VerticalLayout1_c():spark.layouts.VerticalLayout {
		var temp:spark.layouts.VerticalLayout = new spark.layouts.VerticalLayout();
		temp.horizontalAlign = 'justify';
		temp.gap = 0;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group5_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Rect5_i(), _ResizableDraggableTitleWindowSkin_Rect6_i(), _ResizableDraggableTitleWindowSkin_Rect7_i(), _ResizableDraggableTitleWindowSkin_Label1_i(), _ResizableDraggableTitleWindowSkin_Group6_i(), _ResizableDraggableTitleWindowSkin_Button1_i()];
		temp.id = 'topGroup';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		topGroup = temp;
		mx.binding.BindingManager.executeBindings(this, 'topGroup', topGroup);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect5_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 1;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.fill = _ResizableDraggableTitleWindowSkin_LinearGradient1_c();
		temp.initialized(this, 'tbFill');
		tbFill = temp;
		mx.binding.BindingManager.executeBindings(this, 'tbFill', tbFill);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_LinearGradient1_c():mx.graphics.LinearGradient {
		var temp:mx.graphics.LinearGradient = new mx.graphics.LinearGradient();
		temp.rotation = 90;
		temp.entries = [_ResizableDraggableTitleWindowSkin_GradientEntry1_i(), _ResizableDraggableTitleWindowSkin_GradientEntry2_i()];
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry1_i():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 13816530;
		_ResizableDraggableTitleWindowSkin_GradientEntry1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ResizableDraggableTitleWindowSkin_GradientEntry1', _ResizableDraggableTitleWindowSkin_GradientEntry1);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry2_i():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 10132122;
		_ResizableDraggableTitleWindowSkin_GradientEntry2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ResizableDraggableTitleWindowSkin_GradientEntry2', _ResizableDraggableTitleWindowSkin_GradientEntry2);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect6_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.stroke = _ResizableDraggableTitleWindowSkin_LinearGradientStroke1_c();
		temp.fill = _ResizableDraggableTitleWindowSkin_LinearGradient2_c();
		temp.initialized(this, 'tbHilite');
		tbHilite = temp;
		mx.binding.BindingManager.executeBindings(this, 'tbHilite', tbHilite);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_LinearGradientStroke1_c():mx.graphics.LinearGradientStroke {
		var temp:mx.graphics.LinearGradientStroke = new mx.graphics.LinearGradientStroke();
		temp.rotation = 90;
		temp.weight = 1;
		temp.entries = [_ResizableDraggableTitleWindowSkin_GradientEntry3_c(), _ResizableDraggableTitleWindowSkin_GradientEntry4_c()];
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry3_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 15132390;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry4_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 16777215;
		temp.alpha = 0.22;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_LinearGradient2_c():mx.graphics.LinearGradient {
		var temp:mx.graphics.LinearGradient = new mx.graphics.LinearGradient();
		temp.rotation = 90;
		temp.entries = [_ResizableDraggableTitleWindowSkin_GradientEntry5_c(), _ResizableDraggableTitleWindowSkin_GradientEntry6_c(), _ResizableDraggableTitleWindowSkin_GradientEntry7_c()];
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry5_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 16777215;
		temp.alpha = 0.15;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry6_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 16777215;
		temp.alpha = 0.15;
		temp.ratio = 0.44;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry7_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 16777215;
		temp.alpha = 0;
		temp.ratio = 0.4401;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect7_i():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.height = 1;
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.fill = _ResizableDraggableTitleWindowSkin_SolidColor4_c();
		temp.initialized(this, 'tbDiv');
		tbDiv = temp;
		mx.binding.BindingManager.executeBindings(this, 'tbDiv', tbDiv);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColor4_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 0;
		temp.alpha = 0.75;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.minHeight = 30;
		temp.bottom = 0;
		temp.left = 19;
		temp.right = 36;
		temp.top = 1;
		temp.maxDisplayedLines = 1;
		temp.setStyle('fontWeight', 'bold');
		temp.setStyle('verticalAlign', 'middle');
		temp.id = 'titleDisplay';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		titleDisplay = temp;
		mx.binding.BindingManager.executeBindings(this, 'titleDisplay', titleDisplay);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group6_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_DragHandle1_c()];
		temp.id = 'moveArea';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		moveArea = temp;
		mx.binding.BindingManager.executeBindings(this, 'moveArea', moveArea);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_DragHandle1_c():components.skins.DragHandle {
		var temp:components.skins.DragHandle = new components.skins.DragHandle();
		temp.left = 4;
		temp.verticalCenter = 0;
		temp.dotColor = 9145227;
		temp.fillAlpha = 0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.height = 15;
		temp.width = 15;
		temp.right = 7;
		temp.top = 7;
		temp.setStyle('skinClass', spark.skins.spark.TitleWindowCloseButtonSkin);
		temp.id = 'closeButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		closeButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'closeButton', closeButton);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group7_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.percentHeight = 100.0;
		temp.minHeight = 0;
		temp.minWidth = 0;
		temp.percentWidth = 100.0;
		temp.id = 'contentGroup';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		contentGroup = temp;
		mx.binding.BindingManager.executeBindings(this, 'contentGroup', contentGroup);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group8_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.minHeight = 0;
		temp.minWidth = 0;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Group9_i(), _ResizableDraggableTitleWindowSkin_Group10_i()];
		temp.id = 'bottomGroup';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		bottomGroup = temp;
		mx.binding.BindingManager.executeBindings(this, 'bottomGroup', bottomGroup);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group9_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.mxmlContent = [_ResizableDraggableTitleWindowSkin_Rect8_c(), _ResizableDraggableTitleWindowSkin_Rect9_c(), _ResizableDraggableTitleWindowSkin_Rect10_c()];
		temp.id = '_ResizableDraggableTitleWindowSkin_Group9';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_ResizableDraggableTitleWindowSkin_Group9 = temp;
		mx.binding.BindingManager.executeBindings(this, '_ResizableDraggableTitleWindowSkin_Group9', _ResizableDraggableTitleWindowSkin_Group9);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect8_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.height = 1;
		temp.left = 0;
		temp.right = 0;
		temp.top = 0;
		temp.alpha = 0.22;
		temp.fill = _ResizableDraggableTitleWindowSkin_SolidColor5_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_SolidColor5_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 0;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect9_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 0;
		temp.left = 0;
		temp.right = 0;
		temp.top = 1;
		temp.stroke = _ResizableDraggableTitleWindowSkin_LinearGradientStroke2_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_LinearGradientStroke2_c():mx.graphics.LinearGradientStroke {
		var temp:mx.graphics.LinearGradientStroke = new mx.graphics.LinearGradientStroke();
		temp.rotation = 90;
		temp.weight = 1;
		temp.entries = [_ResizableDraggableTitleWindowSkin_GradientEntry8_c(), _ResizableDraggableTitleWindowSkin_GradientEntry9_c()];
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry8_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 16777215;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry9_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 14211288;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Rect10_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.bottom = 1;
		temp.left = 1;
		temp.right = 1;
		temp.top = 2;
		temp.fill = _ResizableDraggableTitleWindowSkin_LinearGradient3_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_LinearGradient3_c():mx.graphics.LinearGradient {
		var temp:mx.graphics.LinearGradient = new mx.graphics.LinearGradient();
		temp.rotation = 90;
		temp.entries = [_ResizableDraggableTitleWindowSkin_GradientEntry10_c(), _ResizableDraggableTitleWindowSkin_GradientEntry11_c()];
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry10_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 15592941;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_GradientEntry11_c():mx.graphics.GradientEntry {
		var temp:mx.graphics.GradientEntry = new mx.graphics.GradientEntry();
		temp.color = 13487565;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_Group10_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.minHeight = 0;
		temp.minWidth = 0;
		temp.bottom = 1;
		temp.left = 0;
		temp.right = 0;
		temp.top = 1;
		temp.layout = _ResizableDraggableTitleWindowSkin_HorizontalLayout1_c();
		temp.id = 'controlBarGroup';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		controlBarGroup = temp;
		mx.binding.BindingManager.executeBindings(this, 'controlBarGroup', controlBarGroup);
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_HorizontalLayout1_c():spark.layouts.HorizontalLayout {
		var temp:spark.layouts.HorizontalLayout = new spark.layouts.HorizontalLayout();
		temp.paddingBottom = 7;
		temp.paddingLeft = 10;
		temp.paddingRight = 10;
		temp.paddingTop = 7;
		temp.gap = 10;
		return temp;
	}

	private function _ResizableDraggableTitleWindowSkin_ResizeHandleLines1_i():components.skins.ResizeHandleLines {
		var temp:components.skins.ResizeHandleLines = new components.skins.ResizeHandleLines();
		temp.bottom = 1;
		temp.right = 1;
		temp.id = 'resizeHandle';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		resizeHandle = temp;
		mx.binding.BindingManager.executeBindings(this, 'resizeHandle', resizeHandle);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___ResizableDraggableTitleWindowSkin_SparkSkin1_creationComplete(event:mx.events.FlexEvent):Void {
		created(event);
	}

	//  binding mgmt
	private function _ResizableDraggableTitleWindowSkin_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'topGroup.mask', 'topGroupMask');

		result[1] = new mx.binding.Binding(this,
				null,
				null,
				'_ResizableDraggableTitleWindowSkin_Group9.mask', 'bottomGroupMask');

		result[2] = new mx.binding.Binding(this,
				function():Bool {
					return (resizeManager.enabled);
				},
				null,
				'resizeHandle.enabled');

		result[3] = new mx.binding.Binding(this,
				function():Bool {
					return (resizeManager.enabled);
				},
				null,
				'resizeHandle.visible');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ResizableDraggableTitleWindowSkin)._watcherSetupUtil = watcherSetupUtil;
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