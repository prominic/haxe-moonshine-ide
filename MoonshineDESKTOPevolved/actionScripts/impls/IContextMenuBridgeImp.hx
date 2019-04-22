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
package actionScripts.impls;

import haxe.Constraints.Function;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.net.registerClassAlias;
import flash.ui.ContextMenu;
import mx.utils.ObjectUtil;
import actionScripts.interfaces.IContextMenuBridge;

class IContextMenuBridgeImp implements IContextMenuBridge {

	public function getContextMenu():ContextMenu {
		return (new ContextMenu());
	}

	public function getContextMenuItem(title:String, listener:Function = null, forState:String = null, hasSeparatorBefore:Bool = false):Dynamic {
		var tmpCMI:NativeMenuItem = (title != null) ? new NativeMenuItem(title, hasSeparatorBefore) : new NativeMenuItem(null, true);
		if (listener != null) {
			tmpCMI.addEventListener(forState, cast listener, false, 0, true);
		}
		return tmpCMI;
	}

	public function subMenu(menuOf:Dynamic, menuItem:Dynamic = null, extendedListner:Function = null):Void {
		if (!AS3.as(NativeMenuItem(menuOf).submenu, Bool)) {
			NativeMenuItem(menuOf).submenu = new NativeMenu();
		}

		if (AS3.as(menuItem, Bool) && (Std.is(menuItem, Array))) {
			for (i in as3hx.Compat.each(menuItem)) {
				registerClassAlias('flash.display.NativeMenuItem', NativeMenuItem);
				var tmpCMI:NativeMenuItem = AS3.as(ObjectUtil.copy(i), NativeMenuItem);

				// object copying removes it's listeners thus adding it again
				if (extendedListner != null) {
					tmpCMI.addEventListener(Event.SELECT, cast extendedListner, false, 0, true);
				}

				NativeMenuItem(menuOf).submenu.addItem(tmpCMI);
			}
		} else if (AS3.as(menuItem, Bool)) {
			NativeMenuItem(menuOf).submenu.addItem(AS3.as(menuItem, NativeMenuItem));
		}
	}

	public function removeAll(menuOf:Dynamic):Void {
		if (AS3.as(NativeMenuItem(menuOf).submenu, Bool)) {
			NativeMenuItem(menuOf).submenu.removeAllItems();
		}
	}

	public function addItem(menuOf:Dynamic, menuItem:Dynamic):Void {
		ContextMenu(menuOf).addItem(AS3.as(menuItem, NativeMenuItem));
	}

	public function new() {}

}