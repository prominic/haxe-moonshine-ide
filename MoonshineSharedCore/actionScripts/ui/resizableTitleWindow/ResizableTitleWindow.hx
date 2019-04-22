////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.resizableTitleWindow;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import spark.components.TitleWindow;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.LayoutEvent;

/**
 *  ResizableTitleWindow is a TitleWindow with
 *  a resize handle.
 */
class ResizableTitleWindow extends TitleWindow {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	// Event Handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function onAddedToStage(event:Event):Void {
		addEventListener(CloseEvent.CLOSE, closeByCrossSign);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onResizeKeyDownEvent);
		GlobalEventDispatcher.getInstance().addEventListener(LayoutEvent.WINDOW_MAXIMIZED, onNativeWindowResized, false, 0, true);
		GlobalEventDispatcher.getInstance().addEventListener(LayoutEvent.WINDOW_NORMAL, onNativeWindowResized, false, 0, true);
	}

	/**
	 *  @protected
	 */
	private function closeByCrossSign(event:Event):Void {
		if (stage != null) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onResizeKeyDownEvent);
		}
		removeEventListener(CloseEvent.CLOSE, closeByCrossSign);
		GlobalEventDispatcher.getInstance().removeEventListener(LayoutEvent.WINDOW_MAXIMIZED, onNativeWindowResized);
		GlobalEventDispatcher.getInstance().removeEventListener(LayoutEvent.WINDOW_NORMAL, onNativeWindowResized);
		PopUpManager.removePopUp(this);
	}

	/**
	 *  @protected
	 */
	private function onResizeKeyDownEvent(event:KeyboardEvent):Void {
		if (event.charCode == Keyboard.ESCAPE) {
			callLater(closeByCrossSign, [null]);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
	}

	/**
	 *  @protected
	 */
	private function closeThis():Void {
		callLater(closeByCrossSign, [null]);
		dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
	}

	private function onNativeWindowResized(event:Event):Void {
		PopUpManager.centerPopUp(this);
	}

}