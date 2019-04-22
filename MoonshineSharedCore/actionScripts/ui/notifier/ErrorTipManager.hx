package actionScripts.ui.notifier;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import mx.controls.ToolTip;
import mx.core.Container;
import mx.core.IChildList;
import mx.core.IInvalidating;
import mx.core.IToolTip;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.events.ScrollEvent;
import mx.events.ToolTipEvent;
import mx.events.ValidationResultEvent;
import mx.managers.SystemManager;
import mx.managers.ToolTipManager;
import mx.styles.IStyleClient;
import mx.validators.Validator;

/**
 * This class makes the error ToolTip shown up all the time instead of
 * just when the mouse is over the target component.
 * It is designed to work with a Validator control, but you can manually use this class
 * by calling the showErrorTip() and hideErrorTip() functions too.
 * <br>
 * When the showErrorTip(target:Object, error:String) function is called, if the error String is null and
 * the target is a UIComponent then the UIComponent.errorString property is used in the error tip.
 * <br>
 * Here are some more resources on the issue:<br>
 * <li><a href="http://bugs.adobe.com/jira/browse/SDK-11256">Adobe Bug Tracker</a></li>
 * <li><a href="http://aralbalkan.com/1125">Aral Balkan - Better form validation in Flex</a></li>
 * <li><a href="http://blog.flexmonkeypatches.com/2007/09/17/using-the-flex-tooltip-manager-to-create-error-tooltips-and-position-them/">Creating Error Tooltips</a></li>
 *
 * @author Chris Callendar
 * @date August 5th, 2009
 */
class ErrorTipManager {

	// maps the target components to the error IToolTip components
	private static var errorTips:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	// maps the validators to a boolean indicating whether the toolTipShown even listener has been
	// added to the validator source property.
	private static var validators:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	// maps the popUps to an Array of validators
	private static var popUps:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	// maps the parent containers to an Array of validator source components
	private static var containersToTargets:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	/**
	 * Adds "invalid" and "valid" event listeners which show and hide the error tooltips.
	 */
	public static function registerValidator(validator:Validator):Void {
		validator.addEventListener(ValidationResultEvent.VALID, validHandler, false, 0, true);
		validator.addEventListener(ValidationResultEvent.INVALID, invalidHandler, false, 0, true);
		validators.set(validator, false);

		// Also listen for when the real mouse over error tooltip is shown
		addValidatorSourceListeners(validator);
	}

	/**
	 * Removes the "invalid" and "valid" event listeners from the validator.
	 * Also removes the error tip.
	 */
	public static function unregisterValidator(validator:Validator):Void {
		validator.removeEventListener(ValidationResultEvent.VALID, validHandler);
		validator.removeEventListener(ValidationResultEvent.INVALID, invalidHandler);
		// make sure our error tooltip is hidden
		removeErrorTip(validator.source);
		// stop listening for events on the validator's source
		removeValidatorSourceListeners(validator);
	}

	/**
	 * Registers the validator (see registerValidator), and adds MOVE and RESIZE listeners
	 * on the popUp component to keep the error tip positioned properly.
	 * It can also hide all existing error tips which is a good idea when showing a popUp
	 * because the error tips will appear on top of the popUp window.
	 * @param validator the validator to register
	 * @param popUp the popUp component which will have move and resize listeners added to
	 * @param hideExistingErrorTips if true then all existing error tips will be hidden
	 */
	public static function registerValidatorOnPopUp(validator:Validator, popUp:UIComponent,
			hideExistingErrorTips:Bool = false):Void {
		// hide all existing error tips to prevent them from being on top of the popUp
		if (hideExistingErrorTips) {
			hideAllErrorTips();
		}
		registerValidator(validator);
		if (popUps.get(popUp) == null) {
			popUps.set(popUp, []);
			// add move/resize listeners on the popUp to keep the error tip positioned properly
			popUp.addEventListener(MoveEvent.MOVE, targetMoved, false, 0, true);
			popUp.addEventListener(ResizeEvent.RESIZE, targetMoved, false, 0, true);
		}
		var validators:Array<Dynamic> = cast (AS3.asArray(popUps.get(popUp)));
		if (Lambda.indexOf(validators, validator) == -1) {
			validators.push(validator);
		}
	}

	/**
	 * Unregisters all the validators that are associated with the given popup.
	 * Also removes the MOVE and RESIZE listeners on the popUp.
	 * It can also re-validate all existing validators which will show the error tips if necessary.
	 * @param popUp the popUp component which will have move and resize listeners added to
	 * @param validateExistingErrorTips if true then all other validators will be validated
	 */
	public static function unregisterPopUpValidators(popUp:UIComponent, validateExistingErrorTips:Bool = false):Void {
		if (popUps.get(popUp) != null) {
			var validators:Array<Dynamic> = cast (AS3.asArray(popUps.get(popUp)));
			for (validator_ in validators) {
				var validator:Validator = cast validator_;
				unregisterValidator(validator);
			}
			popUps.remove(popUp);
			// remove the move/resize listeners on the popUp
			popUp.removeEventListener(MoveEvent.MOVE, targetMoved);
			popUp.removeEventListener(ResizeEvent.RESIZE, targetMoved);
		}
		// show any error tips that were showing before the popUp was shown
		if (validateExistingErrorTips) {
			validateAll();
		}
	}

	/**
	 * Adds the ToolTipEvent.TOOL_TIP_SHOW event listener on the validator's source
	 * only if it hasn't already been added.
	 */
	private static function addValidatorSourceListeners(validator:Validator):Void {
		// make sure the listeners have been added
		if (validator != null) {
			var alreadyAdded:Bool = validators.get(validator) != null;
			if (!alreadyAdded && (Std.is(validator.source, IEventDispatcher))) {
				var ed:IEventDispatcher = (AS3.as(validator.source, IEventDispatcher));
				// need to listener for when the real tooltip gets shown
				// we'll hide it if is an error tooltip since we are already showing it
				ed.addEventListener(Std.string(ToolTipEvent.TOOL_TIP_SHOWN), toolTipShown, false, 0, true);
				// also need to listen for move and resize events to keep the error tip positioned correctly
				ed.addEventListener(Std.string(MoveEvent.MOVE), targetMoved, false, 0, true);
				ed.addEventListener(Std.string(ResizeEvent.RESIZE), targetMoved, false, 0, true);
				ed.addEventListener(Std.string(FlexEvent.HIDE), targetHidden, false, 0, true);
				ed.addEventListener(Std.string(FlexEvent.REMOVE), targetRemoved, false, 0, true);
				validators.set(validator, true);

				// listen for scroll events on the parent containers
				if (Std.is(validator.source, DisplayObject)) {
					var obj:DisplayObject = (AS3.as(validator.source, DisplayObject));
					var parent:DisplayObjectContainer = obj.parent;
					while (parent != null) {
						if (Std.is(parent, Container)) {
							parent.addEventListener(Std.string(ScrollEvent.SCROLL), parentContainerScrolled, false, 0, true);
							if (!(Std.is(containersToTargets.get(parent), Array))) {
								containersToTargets.set(parent, []);
							}
							var array:Array<Dynamic> = cast (AS3.asArray(containersToTargets.get(parent)));
							if (Lambda.indexOf(array, obj) == -1) {
								array.push(obj);
							}
						}
						parent = parent.parent;
					}
				}
			}
		}
	}

	/**
	 * Removes the event listeners that were added to the validator's source.
	 */
	private static function removeValidatorSourceListeners(validator:Validator):Void {
		if (validator != null && (validators.get(validator) == true)) {
			if (Std.is(validator.source, IEventDispatcher)) {
				var ed:IEventDispatcher = (AS3.as(validator.source, IEventDispatcher));
				ed.removeEventListener(Std.string(ToolTipEvent.TOOL_TIP_SHOWN), toolTipShown);
				ed.removeEventListener(Std.string(MoveEvent.MOVE), targetMoved);
				ed.removeEventListener(Std.string(ResizeEvent.RESIZE), targetMoved);
				ed.removeEventListener(Std.string(FlexEvent.HIDE), targetHidden);
				ed.removeEventListener(Std.string(FlexEvent.REMOVE), targetRemoved);

				if (Std.is(validator.source, DisplayObject)) {
					var obj:DisplayObject = (AS3.as(validator.source, DisplayObject));
					var parent:DisplayObjectContainer = obj.parent;
					while (parent != null) {
						if (Std.is(parent, Container)) {
							parent.removeEventListener(Std.string(ScrollEvent.SCROLL), parentContainerScrolled);
							if (Std.is(containersToTargets.get(parent), Array)) {
								var array:Array<Dynamic> = cast (AS3.asArray(containersToTargets.get(parent)));
								var index:Int = AS3.int(Lambda.indexOf(array, obj));
								if (index != -1) {
									array.splice(index, 1);
									containersToTargets.set(parent, array);
								}
							}
						}
						parent = parent.parent;
					}
				}
			}
			validators.remove(validator);
		}
	}

	/**
	 * Called when the validator fires the valid event.
	 * Hides the error tooltip if it is visible.
	 */
	public static function validHandler(event:ValidationResultEvent):Void {
		// the target component is valid, so hide the error tooltip
		var validator:Validator = Validator(event.target);
		hideErrorTip(validator.source);
		// ensure that the source listeners were added
		addValidatorSourceListeners(validator);
	}

	/**
	 * Called when the validator fires an invalid event.
	 * Shows the error tooltip with the ValidatorResultEvent.message as the error String.
	 */
	public static function invalidHandler(event:ValidationResultEvent):Void {
		// the target component is invalid, so show the error tooltip
		var validator:Validator = Validator(event.target);
		showErrorTip(validator.source, Std.string(event.message));
		// ensure that the source listeners were added
		addValidatorSourceListeners(validator);
	}

	private static function parentContainerScrolled(event:ScrollEvent):Void {
		var parent:DisplayObjectContainer = (AS3.as(event.target, DisplayObjectContainer));
		if (parent != null && (Std.is(containersToTargets.get(parent), Array))) {
			var targets:Array<Dynamic> = cast (AS3.asArray(containersToTargets.get(parent)));
			if (targets != null && (targets.length > 0)) {
				// need to wait a fraction of a second for the scroll event to be finished
				// and the each targets position to be updated
				var id:Int = as3hx.Compat.setTimeout(function():Void {
							as3hx.Compat.clearTimeout(id);
							for (target_ in targets) {
								var target:DisplayObject = cast target_;
								// make sure the source target is actually visible (not scrolled out of the view)
								var pt:Point = target.localToGlobal(new Point());
								pt = parent.globalToLocal(pt);
								if ((pt.x < 0) || (pt.y < 0) ||
									((pt.x + Reflect.field(target, 'width')) > parent.width) ||
									((pt.y + Reflect.field(target, 'height')) > parent.height)) {
									// the source component isn't fully visible, so hide the error tip
									hideErrorTip(target);
								}// re-position the error tip, also will make it visible if it was hidden
								else {
									// re-position the error tip, also will make it visible if it was hidden
									updateErrorTipPosition(target, true);
								}
							}
						}, 50);
			}
		}
	}

	/**
	 * When a target is hidden, then make sure the error tip is hidden too.
	 */
	private static function targetHidden(event:FlexEvent):Void {
		var target:DisplayObject = (AS3.as(event.target, DisplayObject));
		hideErrorTip(target, true);
	}

	/**
	 * When a target is removed, then make sure the error tip is hidden too.
	 */
	private static function targetRemoved(event:FlexEvent):Void {
		var target:DisplayObject = (AS3.as(event.target, DisplayObject));
		removeErrorTip(target, true);
	}

	/**
	 * When the target component moves or is resized we need to keep the
	 * error tip in the correct position.
	 */
	private static function targetMoved(event:Event):Void {
		var target:DisplayObject = (AS3.as(event.target, DisplayObject));
		// check if the target is actually a popUp, in which case we get the real
		// target from the validator source
		if (popUps.get(target) != null) {
			var validators:Array<Dynamic> = cast (AS3.asArray(popUps.get(target)));
			for (validator_ in validators) {
				var validator:Validator = cast validator_;
				var source:DisplayObject = (AS3.as(Reflect.field(validator, 'source'), DisplayObject));
				handleTargetMoved(source);
			}
		} else {
			handleTargetMoved(target);
		}
	}

	private static function handleTargetMoved(target:DisplayObject):Void {
		if (Std.is(target, UIComponent)) {
			// need to wait for move/resize to finish
			UIComponent(target).callLater(updateErrorTipPosition, [target]);
		} else {
			updateErrorTipPosition(target);
		}
	}

	/**
	 * Moves the error tip for the given target.
	 * It can also make it visible if the error tip exists but is hidden.
	 */
	public static function updateErrorTipPosition(target:Dynamic, makeVisible:Bool = false):Void {
		var errorTip:IToolTip = getErrorTip(target);
		if (errorTip != null) {
			if (makeVisible && !AS3.as(errorTip.visible, Bool)) {
				errorTip.visible = true;
			}
			positionErrorTip(errorTip, AS3.as(target, DisplayObject));
		}
	}

	/**
	 * This gets called when the mouse hovers over the target component
	 * and a tooltip is shown - either a normal tooltip or an error tooltip.
	 * If the tooltip is an error tooltip and our error tooltip is already showing
	 * then we hide this new tooltip immediately.
	 */
	private static function toolTipShown(event:ToolTipEvent):Void {
		// hide our error tip until this tooltip is hidden
		var style:Dynamic = ToolTip(event.toolTip).styleName;
		if ((style == 'errorTip') && (getErrorTip(event.target) != null)) {
			// hide this tooltip, ours is already displaying (or is about to display)
			event.toolTip.visible = false;
			event.toolTip.width = 0;
			event.toolTip.height = 0;
			event.currentTarget.dispatchEvent(new ToolTipEvent(ToolTipEvent.TOOL_TIP_HIDE, false, false, event.toolTip));
		}
	}

	/**
	 * Gets the cached IToolTip object for the given target.
	 */
	public static function getErrorTip(target:Dynamic):IToolTip {
		return ((AS3.as(target, Bool)) ? AS3.as(errorTips.get(target), IToolTip) : null);
	}

	/**
	 * Determines if the error tooltip exists and if it is visible.
	 */
	public static function isErrorTipVisible(target:Dynamic):Bool {
		var errorTip:IToolTip = getErrorTip(target);
		return (errorTip != null && AS3.as(errorTip.visible, Bool));
	}

	/**
	 * Creates the error IToolTip object if one doesn't already exist for the given target.
	 * If the error tooltip already exists then the error string is updated on the existing tooltip.
	 * The tooltip will not be shown if the error (or errorString) is blank.
	 * @param target the target component (usually a UIComponent)
	 * @param error the optional error String, if null and the target is a UIComponent then
	 *  the target.errorString property is used.
	 */
	public static function createErrorTip(target:Dynamic, error:String = null):IToolTip {
		var errorTip:IToolTip = null;
		var position:Point;
		if (AS3.as(target, Bool)) {
			// use the errorString property on the target
			if ((error == null) && (Std.is(target, UIComponent))) {
				error = Std.string((AS3.as(target, UIComponent)).errorString);
			}
			errorTip = getErrorTip(target);
			if (errorTip == null) {
				if ((error != null) && (error.length > 0)) {
					position = getErrorTipPosition(AS3.as(target, DisplayObject));
					errorTip = ToolTipManager.createToolTip(error, position.x, position.y);
					errorTips.set(target, errorTip);

					sizeErrorTip(errorTip);
					// update the position (handles the tooltip going offscreen)
					positionErrorTip(errorTip, AS3.as(target, DisplayObject));

					// set the styles to match the real error tooltip
					var tt:ToolTip = ToolTip(errorTip);
					tt.styleName = 'errorTip';
				}
			} else if ((error != null) && (error != errorTip.text)) {
				// update the error tooltip text
				errorTip.text = error;
				// update the position too
				//position = getErrorTipPosition(target as DisplayObject);
				//errorTip.move(position.x, position.y);
				positionErrorTip(errorTip, AS3.as(target, DisplayObject));
			}
		}
		return errorTip;
	}

	/**
	 * Gets the position for the tooltip in global coordinates.
	 */
	private static function getErrorTipPosition(target:DisplayObject):Point {
		// position the error tip to be in the exact same position as the real error tooltip
		var pt:Point = new Point();
		if (target != null) {
			// need to get the position of the target in global coordinates
			var global:Point = target.localToGlobal(new Point(0, 0));
			// position on the right side of the target
			pt.x = global.x + target.width + 4;
			pt.y = global.y - 1;
		}
		return pt;
	}

	/**
	 * Gets the position for the error tip.
	 * Copied from ToolTipManagerImpl.positionTip()
	 */
	private static function positionErrorTip(errorTip:IToolTip, target:DisplayObject, bringInFront:Bool = true):Void {
		if (errorTip == null || target == null) {
			return;
		}
		var x:Float;
		var y:Float;

		var screenWidth:Float = errorTip.screen.width;
		var screenHeight:Float = errorTip.screen.height;
		var upperLeft:Point = new Point(0, 0);
		upperLeft = target.localToGlobal(upperLeft);
		upperLeft = errorTip.root.globalToLocal(upperLeft);
		var targetGlobalBounds:Rectangle = new Rectangle(upperLeft.x, upperLeft.y, target.width, target.height);
		x = targetGlobalBounds.right + 4;
		y = targetGlobalBounds.top - 1;
		var above:Bool = false;

		// If there's no room to the right of the control, put it above or below,
		// with the left edge of the error tip aligned with the left edge of the target.
		if (x + errorTip.width > screenWidth) {
			var newWidth:Float = Math.NaN;
			var oldWidth:Float = Math.NaN;
			x = targetGlobalBounds.left - 2;

			// If the error tip would be too wide for the stage, reduce the maximum width to fit onstage.
			// Note that we have to reassign the text in order to get the tip to relayout after changing
			// the border style and maxWidth.
			if (x + errorTip.width + 4 > screenWidth) {
				newWidth = screenWidth - x - 4;
				oldWidth = errorTip.maxWidth;
				setMaxWidth(errorTip, newWidth);
				if (Std.is(errorTip, IStyleClient)) {
					IStyleClient(errorTip).setStyle('borderStyle', 'errorTipAbove');
				}
				Reflect.setProperty(errorTip, 'text', Reflect.getProperty(errorTip, 'text'));
				setMaxWidth(errorTip, oldWidth);
			} else {
				// Even if the error tip will fit onstage, we still need to change the border style
				// and get the error tip to relayout.
				if (Std.is(errorTip, IStyleClient)) {
					IStyleClient(errorTip).setStyle('borderStyle', 'errorTipAbove');
				}
				Reflect.setProperty(errorTip, 'text', Reflect.getProperty(errorTip, 'text'));
			}

			if (errorTip.height + 2 < targetGlobalBounds.top) {
				// There's room to put it above the control.
				above = true;// wait for the errorTip to be sized before setting y
			} else {
				// No room above, put it below the control.
				y = targetGlobalBounds.bottom + 2;
				setMaxWidth(errorTip, newWidth);
				if (Std.is(errorTip, IStyleClient)) {
					IStyleClient(errorTip).setStyle('borderStyle', 'errorTipBelow');
				}
				Reflect.setProperty(errorTip, 'text', Reflect.getProperty(errorTip, 'text'));
				setMaxWidth(errorTip, oldWidth);
			}
		} else if (Std.is(errorTip, IStyleClient)) {
			IStyleClient(errorTip).clearStyle('borderStyle');
		}

		// Since the border style of the error tip may have changed, we have to force a remeasurement and change
		// its size. This is because objects in the toolTips layer don't undergo normal measurement and layout.
		sizeErrorTip(errorTip);

		// need to do this after the error tip has been sized since the height might have changed
		if (above) {
			y = targetGlobalBounds.top - (errorTip.height + 2);
		}

		errorTip.move(x, y);

		// move this error tip on top of other error tips
		if (bringInFront) {
			bringToFront(errorTip);
		}
	}

	private static function setMaxWidth(errorTip:IToolTip, width:Float):Void {
		if (!AS3.as(Math.isNaN(width), Bool) && (Std.is(errorTip, UIComponent))) {
			(AS3.as(errorTip, UIComponent)).maxWidth = width;
		}
	}

	/**
	 * Moves the given error tip in front of any other error tips.
	 */
	public static function bringToFront(errorTip:IToolTip):Void {
		var parent:IChildList = (AS3.as(errorTip.parent, IChildList));
		if (Std.is(parent, SystemManager)) {
			parent = (AS3.as(parent, SystemManager)).rawChildren;
		}
		var index:Int = AS3.int(parent.getChildIndex(AS3.as(errorTip, DisplayObject)));
		var children:Int = AS3.int(parent.numChildren);
		if (index < (children - 1)) {
			parent.setChildIndex(AS3.as(errorTip, DisplayObject), children - 1);
		}
	}

	/**
	 * Copied from ToolTipManagerImpl.sizeTip()
	 * Objects added to the SystemManager's ToolTip layer don't get automatically measured or sized,
	 * so ToolTipManager has to measure it and set its size.
	 */
	private static function sizeErrorTip(errorTip:IToolTip):Void {
		// Force measure() to be called on the tooltip.  Otherwise, its measured size will be 0.
		if (Std.is(errorTip, IInvalidating)) {
			IInvalidating(errorTip).validateNow();
		}
		errorTip.setActualSize(errorTip.getExplicitOrMeasuredWidth() + 6,
				errorTip.getExplicitOrMeasuredHeight()
		);
	}

	/**
	 * Creates the error tooltip if it doesn't already exist, and makes it visible.
	 */
	public static function showErrorTip(target:Dynamic, error:String = null):Void {
		var errorTip:IToolTip = createErrorTip(target, error);
		if (errorTip != null) {
			errorTip.visible = true;
		}
	}

	/**
	 * Hides the existing error tooltip for the target if one exists.
	 */
	public static function hideErrorTip(target:Dynamic, clearErrorString:Bool = false):Void {
		var errorTip:IToolTip = getErrorTip(target);
		if (errorTip != null) {
			errorTip.visible = false;
		}
		// clear the errorString property to remove the red border around the target control
		if (clearErrorString && AS3.as(target, Bool) && Reflect.hasField(target, 'errorString')) {
			Reflect.setField(target, 'errorString', '');
		}
	}

	/**
	 * Hides the error tooltip for the target AND removes it from the
	 * ToolTipManager (by calling ToolTipManager.destroyToolTip).
	 */
	public static function removeErrorTip(target:Dynamic, clearErrorString:Bool = false):Void {
		var errorTip:IToolTip = getErrorTip(target);
		if (errorTip != null) {
			errorTip.visible = false;
			ToolTipManager.destroyToolTip(errorTip);
			errorTips.remove(target);
		}
		// clear the errorString property to remove the red border around the target control
		if (clearErrorString && AS3.as(target, Bool) && Reflect.hasField(target, 'errorString')) {
			Reflect.setField(target, 'errorString', '');
		}
	}

	/**
	 * Hides all the error tips.
	 */
	public static function hideAllErrorTips():Void {
		for (target in errorTips.keys()) {
			hideErrorTip(target, false);
		}
	}

	/**
	 * Shows all the error tips - doesn't check to see if an error string is set!
	 */
	public static function showAllErrorTips():Void {
		for (target in errorTips.keys()) {
			showErrorTip(target);
		}
	}

	/**
	 * Calls validate() on all the validators.
	 */
	public static function validateAll():Void {
		// need to validator to figure out which error tips should be shown
		for (validator in validators.keys()) {
			validator.validate();
		}
	}

}