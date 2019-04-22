package actionScripts.ui.resizableControls;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import mx.managers.CursorManager;
import spark.primitives.Rect;

/**
 * This is the style direction that can be set on the resize component.
 * Defaults to "both" which means the component can be resized horizontally and vertically.
 */
@:meta(Style(name = 'resizeDirection', type = 'String', enumeration = 'both,vertical,horizontal', inherit = 'no'))
/**
 * Utility class for allowing containers to be resized by a resize handle.
 * The resize handle will cause the UIComponent to be resized when the user drags the handle.
 * It also supports showing a custom cursor while the resizing is occurring.
 * The resize component can also be restricted to only allow resizing in the horizontal
 * or vertical direction.
 *
 * @author Chris Callendar
 * @date March 17th, 2009
 */
class ResizeManager extends EventDispatcher {

	public static inline var RESIZE_START:String = 'resizeStart';

	public static inline var RESIZE_END:String = 'resizeEnd';

	public static inline var RESIZING:String = 'resizing';

	public static inline var STYLE_RESIZE_DIRECTION:String = 'resizeDirection';

	public static inline var DIRECTION_BOTH:String = 'both';

	public static inline var DIRECTION_HORIZONTAL:String = 'horizontal';

	public static inline var DIRECTION_VERTICAL:String = 'vertical';

	private static var resizeDirections(default, never):haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var RESIZE_HANDLE_SIZE(default, never):Int = 16;

	private var resizeInitX:Float = 0;

	private var resizeInitY:Float = 0;

	private var _resizeHandle:UIComponent;

	private var _enabled:Bool = false;

	private var _bringToFrontOnResize:Bool = false;

	private var _resizeDirection:String;

	private var _resizeComponent:UIComponent;

	private var _constrainToParentBounds:Bool = false;

	private var isResizing:Bool = false;

	private var startWidth:Float;

	private var startHeight:Float;

	@:meta(Embed(source = '/elements/images/cursor_resize.gif'))
	public var resizeCursorIcon:Class<Dynamic>;

	private var resizeCursorID:Int = 0;

	public function new(resizeComponent:UIComponent = null, resizeHandle:UIComponent = null, resizeDirection:String = 'both') {
		super();
		this._enabled = true;
		this.resizeComponent = resizeComponent;
		this.resizeHandle = resizeHandle;
		this._bringToFrontOnResize = false;
		this._resizeDirection = resizeDirection;
		resizeCursorID = 0;
	}

	@:meta(Bindable(name = 'enabledChanged'))
	public var enabled(get, set):Bool;
	private function get_enabled():Bool {
		return _enabled && (resizeComponent != null) && AS3.as(resizeComponent.enabled, Bool);
	}

	private function set_enabled(en:Bool):Bool {
		if (en != _enabled) {
			_enabled = en;
			dispatchEvent(new Event('enabledChanged'));
		}
		return en;
	}

	@:meta(Bindable(name = 'resizeComponentChanged'))
	public var resizeComponent(get, set):UIComponent;
	private function get_resizeComponent():UIComponent {
		return _resizeComponent;
	}

	private function set_resizeComponent(value:UIComponent):UIComponent {
		if (value != _resizeComponent) {
			_resizeComponent = value;
			dispatchEvent(new Event('resizeComponentChanged'));
		}
		return value;
	}

	@:meta(Bindable(name = 'bringToFrontOnResizeChanged'))
	public var bringToFrontOnResize(get, set):Bool;
	private function get_bringToFrontOnResize():Bool {
		return _bringToFrontOnResize;
	}

	private function set_bringToFrontOnResize(value:Bool):Bool {
		if (value != _bringToFrontOnResize) {
			_bringToFrontOnResize = value;
			dispatchEvent(new Event('bringToFrontOnResizeChanged'));
		}
		return value;
	}

	@:meta(Bindable(name = 'resizeDirectionChanged'))
	/**
	 * Sets the resize direction.
	 * Defaults to both, meaning that the component can be resized in the horizontal
	 * and the vertical directions.
	 * If the direction is set to "horizontal", then the component can only be resized
	 * in the horizontal direction.
	 * Similarily when the direction is "vertical" only vertical resizing is allowed.
	 */
	public var resizeDirection(get, set):String;
	private function get_resizeDirection():String {
		var direction:String = DIRECTION_BOTH;
		if (_resizeDirection == DIRECTION_BOTH) {
			// first check if a style was set on the resize component
			var style:Dynamic = resizeComponent.getStyle(STYLE_RESIZE_DIRECTION);
			if (style != null) {
				direction = Std.string(style);
			} else {
				direction = AS3.string(resizeDirections.get(resizeComponent));
			}
			if ((direction != DIRECTION_HORIZONTAL) && (direction != DIRECTION_VERTICAL)) {
				direction = DIRECTION_BOTH;
			}
		}
		return direction;
	}

	private function set_resizeDirection(value:String):String {
		if (value != _resizeDirection) {
			_resizeDirection = value;
			dispatchEvent(new Event('resizeDirectionChanged'));
		}
		return value;
	}

	/**
	 * Returns the resizeHandle UIComponent.
	 */
	@:meta(Bindable(name = 'resizeHandleChanged'))
	public var resizeHandle(get, set):UIComponent;
	private function get_resizeHandle():UIComponent {
		return _resizeHandle;
	}

	private function set_resizeHandle(value:UIComponent):UIComponent {
		if (value != _resizeHandle) {
			if (_resizeHandle != null) {
				_resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
				_resizeHandle.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverResizeHandler);
				_resizeHandle.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler);
			}
			this._resizeHandle = value;
			if (_resizeHandle != null) {
				_resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeHandler, false, 0, true);
				_resizeHandle.addEventListener(MouseEvent.MOUSE_OVER, mouseOverResizeHandler, false, 0, true);
				_resizeHandle.addEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, false, 0, true);
				if (!AS3.as(_resizeHandle.toolTip, Bool)) {
					_resizeHandle.toolTip = 'Drag this handle to resize the component';
				}
			}
			dispatchEvent(new Event('resizeHandleChanged'));
		}
		return value;
	}

	/**
	 * Returns true if the resizing should be constrained to keep the resizeComponent from going outside the parent bounds.
	 */
	public var constrainToParentBounds(get, set):Bool;
	private function get_constrainToParentBounds():Bool {
		return _constrainToParentBounds;
	}

	/**
	 * Set to true to constrain the resizing to keep the resize component inside the parent bounds.
	 */
	private function set_constrainToParentBounds(value:Bool):Bool {
		_constrainToParentBounds = value;
		return value;
	}

	// Resize event handler
	private function resizeHandler(event:MouseEvent):Void {
		if (enabled) {
			event.stopImmediatePropagation();
			startResize(event.stageX, event.stageY);
		}
	}

	private function startResize(globalX:Float, globalY:Float):Void {
		// dispatch a resizeStart event - can be cancelled!
		var event:ResizeEvent = new ResizeEvent(RESIZE_START, false, true, resizeComponent.width, resizeComponent.height);
		var okay:Bool = AS3.as(resizeComponent.dispatchEvent(event), Bool);
		if (okay) {
			isResizing = true;

			// move above all others
			if (bringToFrontOnResize && AS3.as(resizeComponent.parent, Bool)) {
				var index:Int = AS3.int(resizeComponent.parent.getChildIndex(resizeComponent));
				var last:Int = resizeComponent.parent.numChildren - 1;
				if (index != last) {
					resizeComponent.parent.setChildIndex(resizeComponent, last);
				}
			}

			resizeInitX = globalX;
			resizeInitY = globalY;
			startWidth = resizeComponent.width;
			startHeight = resizeComponent.height;
			// Add event handlers so that the SystemManager handles the mouseMove and mouseUp events.
			// Set useCapure flag to true to handle these events
			// during the capture phase so no other component tries to handle them.
			resizeComponent.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true, 0, true);
			resizeComponent.systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true, 0, true);
		}
	}

	/**
	 * Resizes this panel as the user moves the mouse with the mouse button down.
	 * Also restricts the width and height based on the resizeComponent's minWidth, maxWidth, minHeight, and
	 * maxHeight properties.
	 */
	private function resizeMouseMoveHandler(event:MouseEvent):Void {
		event.stopImmediatePropagation();

		var oldWidth:Float = resizeComponent.width;
		var oldHeight:Float = resizeComponent.height;
		var newWidth:Float = oldWidth + event.stageX - resizeInitX;
		var newHeight:Float = oldHeight + event.stageY - resizeInitY;
		//trace("Changing size from " + oldWidth + "x" + oldHeight + " to " + newWidth + "x" + newHeight);

		var resizeH:Bool = (resizeDirection != DIRECTION_VERTICAL);
		var resizeV:Bool = (resizeDirection != DIRECTION_HORIZONTAL);

		// constrain the size to keep the resize component inside the parent bounds
		if (constrainToParentBounds && AS3.as(resizeComponent.parent, Bool)) {
			var parentWidth:Float = resizeComponent.parent.width;
			var parentHeight:Float = resizeComponent.parent.height;
			if ((resizeComponent.x + newWidth) > parentWidth) {
				newWidth = parentWidth - resizeComponent.x;
			}
			if ((resizeComponent.y + newHeight) > parentHeight) {
				newHeight = parentHeight - resizeComponent.y;
			}
		}
		// restrict the width/height
		if ((newWidth >= resizeComponent.minWidth) && (newWidth <= resizeComponent.maxWidth) && resizeH) {
			resizeComponent.width = newWidth;
		}
		if ((newHeight >= resizeComponent.minHeight) && (newHeight <= resizeComponent.maxHeight) && resizeV) {
			resizeComponent.height = newHeight;
		}

		resizeInitX = event.stageX;
		resizeInitY = event.stageY;

		// Update the scrollRect property (this is used by the PopUpManager)
		// will usually be null
		if (AS3.as(resizeComponent.scrollRect, Bool)) {
			var rect:Rectangle = resizeComponent.scrollRect;
			rect.width = resizeComponent.width;
			rect.height = resizeComponent.height;
			resizeComponent.scrollRect = rect;
		}

		resizeComponent.dispatchEvent(new ResizeEvent(RESIZING, false, false, oldWidth, oldHeight));
	}

	/**
	 * Removes the event handlers from the SystemManager.
	 */
	private function resizeMouseUpHandler(event:MouseEvent):Void {
		event.stopImmediatePropagation();
		resizeComponent.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true);
		resizeComponent.systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true);
		if (isResizing) {
			isResizing = false;
			resizeComponent.dispatchEvent(new ResizeEvent(RESIZE_END, false, false, startWidth, startHeight));
		}

		// check if the mouse is outside the resize handle
		var pt:Point = resizeHandle.globalToLocal(new Point(event.stageX, event.stageY));
		var bounds:Rectangle = new Rectangle(0, 0, resizeHandle.width, resizeHandle.height);
		var isOver:Bool = bounds.containsPoint(pt);
		if (!isOver) {
			removeResizeCursor();
		}
	}

	private function mouseOverResizeHandler(event:MouseEvent):Void {
		setResizeCursor();
		FlexGlobals.topLevelApplication.systemManager.addEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, true, 0, true);
	}

	private function mouseOutResizeHandler(event:MouseEvent):Void {
		if (!isResizing) {
			removeResizeCursor();
			FlexGlobals.topLevelApplication.systemManager.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, true);
		}
	}

	private function setResizeCursor():Void {
		if ((resizeCursorID == 0) && (resizeCursorIcon != null)) {
			resizeCursorID = AS3.int(CursorManager.setCursor(resizeCursorIcon));
		}
	}

	private function removeResizeCursor():Void {
		if (resizeCursorID != 0) {
			CursorManager.removeCursor(resizeCursorID);
			resizeCursorID = 0;
		}
	}

	/**
	 * Sets which direction the component can be resized - "horizontal", "vertical", or "both" (default).
	 */
	public static function setResizeDirection(resizeComponent:UIComponent, direction:String = 'both'):Void {
		if (resizeComponent != null) {
			if ((direction == DIRECTION_HORIZONTAL) || (direction == DIRECTION_VERTICAL)) {
				resizeDirections.set(resizeComponent, direction);
			} else if (resizeDirections.get(resizeComponent) != null) {
				resizeDirections.remove(resizeComponent);
			}
		}
	}

}