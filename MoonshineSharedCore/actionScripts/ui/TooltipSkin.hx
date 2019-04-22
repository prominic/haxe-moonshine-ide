////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package actionScripts.ui;

import flash.display.GradientType;
import flash.display.Graphics;
import mx.core.EdgeMetrics;
import mx.core.FlexVersion;
import mx.core.IContainer;
import mx.core.IUIComponent;
import mx.core.Mx_internal;
import mx.skins.halo.HaloBorder;

/**
 *  The PanelSkin class defines the skin for the Panel, TitleWindow, and Alert components.
 */
class TooltipSkin extends HaloBorder {

	//    include "../../core/Version.as";

	/**
	 *  Constructor
	 */
	public function new() {
		super();
	}

	/**
	 *  @private
	 */
	private var oldHeaderHeight:Float;

	/**
	 *  @private
	 */
	private var oldControlBarHeight:Float;

	/**
	 *  @private
	 *  Internal object that contains the thickness of each edge
	 *  of the border
	 */
	private var _panelBorderMetrics:EdgeMetrics;

	/**
	 *  @private
	 *  Return the thickness of the border edges.
	 *
	 *  @return Object  top, bottom, left, right thickness in pixels
	 */
	@:access(parent) override private function get_borderMetrics():EdgeMetrics {
		if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0) {
			return super.borderMetrics;
		}

		var hasPanelParent:Bool = isPanel(parent);
		var controlBar:IUIComponent = (hasPanelParent) ? parent._controlBar : null;
		var hHeight:Float = (hasPanelParent) ? parent.getHeaderHeightProxy() : Math.NaN;

		var newControlBarHeight:Float;

		if (controlBar != null && AS3.as(controlBar.includeInLayout, Bool)) {
			newControlBarHeight = controlBar.getExplicitOrMeasuredHeight();
		}

		if (newControlBarHeight != oldControlBarHeight &&
			!(AS3.as(Math.isNaN(oldControlBarHeight), Bool) && AS3.as(Math.isNaN(newControlBarHeight), Bool))) {
			_panelBorderMetrics = null;
		}

		if ((hHeight != oldHeaderHeight) &&
			!(AS3.as(Math.isNaN(hHeight), Bool) && AS3.as(Math.isNaN(oldHeaderHeight), Bool))) {
			_panelBorderMetrics = null;
		}

		if (_panelBorderMetrics != null) {
			return _panelBorderMetrics;
		}

		var o:EdgeMetrics = super.borderMetrics;
		var vm:EdgeMetrics = new EdgeMetrics(0, 0, 0, 0);

		var bt:Float = getStyle('borderThickness');
		var btl:Float = getStyle('borderThicknessLeft');
		var btt:Float = getStyle('borderThicknessTop');
		var btr:Float = getStyle('borderThicknessRight');
		var btb:Float = getStyle('borderThicknessBottom');

		// Add extra space to edges (was margins).
		vm.left = o.left + ((AS3.as(Math.isNaN(btl), Bool)) ? bt : btl);
		vm.top = o.top + ((AS3.as(Math.isNaN(btt), Bool)) ? bt : btt);
		vm.right = o.bottom + ((AS3.as(Math.isNaN(btr), Bool)) ? bt : btr);

		// Bottom is a special case. If borderThicknessBottom is NaN,
		// use btl if we don't have a control bar or btt if we do.
		vm.bottom = o.bottom + ((AS3.as(Math.isNaN(btb), Bool)) ?
				((controlBar != null && !AS3.as(Math.isNaN(btt), Bool)) ? btt : (AS3.as(Math.isNaN(btl), Bool)) ? bt : btl) :
				btb);

		// Since the header covers the solid portion of the border,
		// we need to use the larger of borderThickness or headerHeight

		oldHeaderHeight = hHeight;
		if (!AS3.as(Math.isNaN(hHeight), Bool)) {
			vm.top += hHeight;
		}

		oldControlBarHeight = newControlBarHeight;
		if (!AS3.as(Math.isNaN(newControlBarHeight), Bool)) {
			vm.bottom += newControlBarHeight;
		}

		_panelBorderMetrics = vm;

		return _panelBorderMetrics;
	}

	/**
	 *  @private
	 *  If borderStyle may have changed, clear the cached border metrics.
	 */
	override public function styleChanged(styleProp:String):Void {
		super.styleChanged(styleProp);

		if (styleProp == null ||
			styleProp == 'styleName' ||
			styleProp == 'borderStyle' ||
			styleProp == 'borderThickness' ||
			styleProp == 'borderThicknessTop' ||
			styleProp == 'borderThicknessBottom' ||
			styleProp == 'borderThicknessLeft' ||
			styleProp == 'borderThicknessRight' ||
			styleProp == 'borderSides') {
			_panelBorderMetrics = null;
		}

		invalidateDisplayList();
	}

	/**
	 *  @private
	 */
	override @:ns('mx_internal') private function drawBorder(w:Float, h:Float):Void {
		super.drawBorder(w, h);
		if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0) {
			return;
		}

		var borderStyle:String = Std.string(getStyle('borderStyle'));

		if (borderStyle == 'default') {
			// For Panel/Alert, "borderAlpha" is the alpha for the
			// title/control/gutter area and "backgroundAlpha"
			// is the alpha for the content area.
			// We flip-flop the variables here so the "borderAlpha"
			// is applied by the background drawing code at the bottom.
			/* var contentAlpha:Number = getStyle("backgroundAlpha");
			var backgroundAlpha:Number = getStyle("borderAlpha");
			backgroundAlphaName = "borderAlpha";

			radiusObj = null;
			radius = getStyle("cornerRadius");
			bRoundedCorners =
			    getStyle("roundedBottomCorners").toString().toLowerCase() == "true";
			var br:Number = bRoundedCorners ? radius : 0;

			var g:Graphics = graphics; */

			//drawDropShadow(0, 0, w, h, radius, radius, br, br);

			// If we don't have rounded corners we need to initialize
			// the complex radius object so the background fill code
			// below works correctly.
			if (bRoundedCorners == null) {
				radiusObj = {};
			}

			var parentContainer:IContainer = AS3.as(parent, IContainer);

			if (parentContainer != null) {
				//var vm:EdgeMetrics = parentContainer.viewMetrics;

				// The backgroundHole is the content area
				/* backgroundHole = {x:vm.left, y:vm.top,
				  w: Math.max(0, w - vm.left - vm.right),
				  h: Math.max(0, h - vm.top - vm.bottom),
				  r:0}; */

				/* if (backgroundHole.w > 0 && backgroundHole.h > 0)
				            {
				                // Draw a shadow around the content
				                // if the content and panel alpha are different.
				                // This could be a style property if needed
				                if (contentAlpha != backgroundAlpha)
				                {
				                    drawDropShadow(backgroundHole.x, backgroundHole.y,
				                            backgroundHole.w, backgroundHole.h,
				                            0, 0, 0, 0);
				                }

				                // Fill in the content area
				                g.beginFill(Number(backgroundColor), contentAlpha);
				                g.drawRect(backgroundHole.x, backgroundHole.y,
				                        backgroundHole.w, backgroundHole.h);
				                g.endFill();
				            } */
			}

			// When the content and panel alpha are different, the border
			// of the panel is drawn using borderColor. We've already
			// drawn the content background so we set backgroundColor to
			// borderColor here so the drawing code below is done with the
			// border color.

		}
		// KyleQ: draw the tail at the top left side of the tooltip.
		/*var gr:Graphics = graphics;
		gr.beginFill(0xffffff, 1);
		gr.moveTo(x+18, y+height);
		gr.lineTo(x+18, y+height+14);
		gr.lineTo(x+38, y+height);
		gr.moveTo(x+18, y+height);
		gr.endFill();
		gr.beginFill(0xbd60b9, 1);
		gr.moveTo(x+19, y+height-1);
		gr.lineTo(x+19, y+height+12);
		gr.lineTo(x+36, y+height-1);
		gr.moveTo(x+19, y+height-1);
		gr.endFill();*/
	}

	/**
	 *  @private
	 */
	override @:ns('mx_internal') private function drawBackground(w:Float, h:Float):Void {
		super.drawBackground(w, h);

		if (getStyle('headerColors') == null && getStyle('borderStyle') == 'default') {
			var highlightAlphas:Array<Dynamic> = getStyle('highlightAlphas');
			var highlightAlpha:Float = (highlightAlphas != null) ? highlightAlphas[0] : 0.3;
			// edge
			drawRoundRect(
					0, 0, w, h,
					{
						'tl': radius,
						'tr': radius,
						'bl': 0,
						'br': 0
					},
					0xFFFFFF, highlightAlpha, null,
					GradientType.LINEAR, null,
					{
						'x': 0,
						'y': 1,
						'w': w,
						'h': h - 1,
						'r': {
							'tl': radius,
							'tr': radius,
							'bl': 0,
							'br': 0
						}
					}
			);
		}
	}

	/**
	 *  @private
	 */
	override @:ns('mx_internal') private function getBackgroundColorMetrics():EdgeMetrics {
		if (getStyle('borderStyle') == 'default') {
			return EdgeMetrics.EMPTY;
		} else {
			return super.borderMetrics;
		}
	}

	/**
	 *  We don't use 'is' to prevent dependency issues
	 */
	private static var panels:Dynamic = {};

	private static function isPanel(parent:Dynamic):Bool {
		var s:String = as3hx.Compat.getQualifiedClassName(parent);
		if (Reflect.field(panels, s) == 1) {
			return true;
		}

		if (Reflect.field(panels, s) == 0) {
			return false;
		}

		if (s == 'mx.containers::Panel') {
			Reflect.field(panels, s) == 1;
			return true;
		}

		var x:FastXML = DescribeType.describeType(parent);
		var xmllist:FastXMLList = FastXML.filterNodes(x.nodes.extendsClass, function(x:FastXML) {
			if(x.att.type == 'mx.containers::Panel')
				return true;
			return false;

		});
		if (xmllist.length() == 0) {
			Reflect.setField(panels, s, 0);
			return false;
		}

		Reflect.setField(panels, s, 1);
		return true;
	}

}