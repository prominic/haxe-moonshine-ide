package actionScripts.ui.resizableControls;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import mx.controls.Button;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.UIComponent;
import mx.managers.CursorManager;

/**
 * Similar to the ResizeManager, this class adds support for moving a component by dragging it
 * with the mouse. It also supports showing a custom cursor while dragging.
 *
 * @author Chris Callendar
 * @date March 17th, 2009
 */
class MoveManager {

	public static inline var DRAG_START:String = 'dragStart';

	public static inline var DRAGGING:String = 'dragging';

	public static inline var DRAG_END:String = 'dragEnd';

	// the component that is being moved
	private var moveComponent:UIComponent;

	// the component that when dragged causes the above component to move
	private var dragComponent:UIComponent;

	private var dragging:Bool = false;

	private var _enabled:Bool = false;

	private var _bringToFrontOnMove:Bool = false;

	private var _constrainToParentBounds:Bool = false;

	private var _constrainToBounds:Rectangle;

	@:meta(Embed(source = '/elements/images/cursor_move.gif'))
	public var moveIcon:Class<Dynamic>;

	private var moveCursorID:Int = 0;

	public function new(moveComponent:UIComponent = null, dragComponent:UIComponent = null) {
		dragging = false;
		_enabled = true;
		_bringToFrontOnMove = false;
		_constrainToParentBounds = false;
		_constrainToBounds = null;
		moveCursorID = 0;
		addMoveSupport(moveComponent, dragComponent);
	}

	public var enabled(get, set):Bool;
	private function get_enabled():Bool {
		return _enabled;
	}

	private function set_enabled(en:Bool):Bool {
		if (en != _enabled) {
			_enabled = en;
		}
		return en;
	}

	public var bringToFrontOnMove(get, set):Bool;
	private function get_bringToFrontOnMove():Bool {
		return _bringToFrontOnMove;
	}

	private function set_bringToFrontOnMove(value:Bool):Bool {
		_bringToFrontOnMove = value;
		return value;
	}

	/**
	 * Returns true if the component's movement is constrained to within
	 * the parent's bounds.
	 */
	public var constrainToParentBounds(get, set):Bool;
	private function get_constrainToParentBounds():Bool {
		return _constrainToParentBounds;
	}

	/**
	 * Set to true if the component's movement is to be constrained to within
	 * the parent's bounds.
	 */
	private function set_constrainToParentBounds(value:Bool):Bool {
		_constrainToParentBounds = value;
		return value;
	}

	/**
	 * Returns the bounds used to constrain the component's movement.
	 */
	public var constrainToBounds(get, set):Rectangle;
	private function get_constrainToBounds():Rectangle {
		return _constrainToBounds;
	}

	/**
	 * Sets the bounds used to constrain the component's movement.
	 */
	private function set_constrainToBounds(value:Rectangle):Rectangle {
		_constrainToBounds = value;
		return value;
	}

	/**
	 * Adds support for moving a component.
	 * @param moveComponent the component that will have its x and y values changed
	 * @param dragComponent the component that will have a mouse_down listener added to listen
	 *  for when the user drags it.  If null then the moveComponent is used instead.
	 */
	public function addMoveSupport(moveComponent:UIComponent, dragComponent:UIComponent = null):Void {
		this.moveComponent = moveComponent;
		this.dragComponent = dragComponent;
		if (dragComponent != null) {
			dragComponent.addEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
		} else if (moveComponent != null) {
			moveComponent.addEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
		}
	}

	/**
	 * Removes move support, removes the mouse listener and the move handle.
	 */
	public function removeMoveSupport():Void {
		if (dragComponent != null) {
			dragComponent.removeEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
		} else if (moveComponent != null) {
			moveComponent.removeEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
		}
	}

	/**
	 * This function gets called when the user presses down the mouse button on the
	 * dragComponent (or if not specified then the moveComponent).
	 * It starts the drag process.
	 */
	private function dragComponentMouseDown(event:MouseEvent):Void {
		if (!enabled) {
			return;
		}

		// move above all others
		if (bringToFrontOnMove && AS3.as(moveComponent.parent, Bool)) {
			var index:Int = AS3.int(moveComponent.parent.getChildIndex(moveComponent));
			var last:Int = moveComponent.parent.numChildren - 1;
			if (index != last) {
				moveComponent.parent.setChildIndex(moveComponent, last);
			}
		}

		// Constain the movement by the parent's bounds?
		var bounds:Rectangle = null;
		if (constrainToBounds != null) {
			bounds = constrainToBounds;
		} else if (constrainToParentBounds && AS3.as(moveComponent.parent, Bool)) {
			bounds = new Rectangle(0, 0, moveComponent.parent.width, moveComponent.parent.height);
			// need to reduce the size by the component's width/height
			bounds.width = Math.max(0, bounds.width - moveComponent.width);
			bounds.height = Math.max(0, bounds.height - moveComponent.height);
		}
		moveComponent.startDrag(false, bounds);
		setMoveCursor();
		moveComponent.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, dragComponentMove);
		moveComponent.systemManager.addEventListener(MouseEvent.MOUSE_UP, dragComponentMouseUp);
		moveComponent.systemManager.stage.addEventListener(Event.MOUSE_LEAVE, dragComponentMouseUp);
	}

	private function dragComponentMove(event:MouseEvent):Void {
		if (!dragging) {
			dragging = true;
			moveComponent.clearStyle('top');
			moveComponent.clearStyle('right');
			moveComponent.clearStyle('bottom');
			moveComponent.clearStyle('left');
			moveComponent.dispatchEvent(new Event(DRAG_START));
		}
		moveComponent.dispatchEvent(new Event(DRAGGING));
	}

	private function dragComponentMouseUp(event:Event):Void {
		moveComponent.stopDrag();
		removeMoveCursor();
		if (dragging) {
			dragging = false;
			moveComponent.dispatchEvent(new Event(DRAG_END));
		}
		moveComponent.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, dragComponentMove);
		moveComponent.systemManager.removeEventListener(MouseEvent.MOUSE_UP, dragComponentMouseUp);
		moveComponent.systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, dragComponentMouseUp);
	}

	private function setMoveCursor():Void {
		if ((moveCursorID == 0) && (moveIcon != null)) {
			moveCursorID = AS3.int(CursorManager.setCursor(moveIcon, 2, -12, -10));
		}
	}

	private function removeMoveCursor():Void {
		if (moveCursorID != 0) {
			CursorManager.removeCursor(moveCursorID);
			moveCursorID = 0;
		}
	}

}