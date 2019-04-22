////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.SharedObject;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.controls.Tree;
import mx.core.Mx_internal;
import mx.events.CollectionEventKind;
import mx.events.TreeEvent;

class CustomTree extends Tree {

	public var propertyNameKey:String;
	public var propertyNameKeyValue:String;
	public var keyNav:Bool = true;
	private var isItemOpening:Bool = false;

	public function new() {
		super();

		addEventListener(TreeEvent.ITEM_OPENING, onCustomTreeItemEventHandler);
		addEventListener(TreeEvent.ITEM_OPEN, onCustomTreeItemEventHandler);
		addEventListener(TreeEvent.ITEM_CLOSE, onCustomTreeItemEventHandler);
	}

	public function saveItemForOpen(item:Dynamic):Void {
		SharedObjectUtil.saveProjectTreeItemForOpen(item, propertyNameKey, propertyNameKeyValue);
	}

	public function removeFromOpenedItems(item:Dynamic):Void {
		SharedObjectUtil.removeProjectTreeItemFromOpenedItems(item, propertyNameKey, propertyNameKeyValue);
	}

	public function expandChildrenByName(itemPropertyName:String, childrenForOpen:Array<Dynamic>):Void {
		var childrenForOpenCount:Int = childrenForOpen.length;
		for (i in 0...childrenForOpenCount) {
			var item:Dynamic = childrenForOpen[i];
			for (childForOpen in dataProvider) {
				var folderLastSeparator:Int = AS3.int(Reflect.field(childForOpen, 'nativePath').lastIndexOf(Reflect.field(Reflect.field(Reflect.field(childForOpen, 'file'), 'fileBridge'), 'separator')));
				var folder:String = Std.string(Reflect.field(childForOpen, 'nativePath').substring(folderLastSeparator + 1));

				if ((Reflect.hasField(childForOpen, itemPropertyName) && Reflect.field(childForOpen, itemPropertyName) == item) || folder == Std.string(item)) {
					if (!AS3.as(isItemOpen(childForOpen), Bool)) {
						saveItemForOpen(childrenForOpen);
						expandItem(childForOpen, true);
					}

					childrenForOpen = childrenForOpen.slice(i + 1, childrenForOpenCount);
					expandChildrenOfByName(getChildren(childForOpen, iterator.view), itemPropertyName, childrenForOpen);
					break;
				}
			}
		}
	}

	private function expandChildrenOfByName(children:ICollectionView, itemPropertyName:String, childrenForOpen:Array<Dynamic>):Void {
		if (children != null) {
			var childrenForOpenCount:Int = childrenForOpen.length;
			for (i in 0...childrenForOpenCount) {
				var cursor:IViewCursor = children.createCursor();
				var currentItem:Dynamic;

				if (childrenForOpenCount == 1) {
					while (!AS3.as(cursor.afterLast, Bool)) {
						currentItem = cursor.current;
						if (Reflect.field(currentItem, itemPropertyName) == childrenForOpen[i]) {
							selectedItem = currentItem;
							scrollToIndex(getItemIndex(currentItem));
							break;
						}
						cursor.moveNext();
					}
				} else {
					var itemForOpenFound:Bool = false;
					while (!AS3.as(cursor.afterLast, Bool)) {
						currentItem = cursor.current;
						if (AS3.as(dataDescriptor.isBranch(currentItem), Bool) && Reflect.field(currentItem, itemPropertyName) == childrenForOpen[i]) {
							if (!AS3.as(isItemOpen(currentItem), Bool)) {
								saveItemForOpen(currentItem);
								expandItem(currentItem, true);
							}
							childrenForOpen = childrenForOpen.slice(i + 1, childrenForOpen.length);
							expandChildrenOfByName(getChildren(currentItem, iterator.view), itemPropertyName, childrenForOpen);
							itemForOpenFound = true;
							break;
						} else {
							cursor.moveNext();
						}
					}

					if (itemForOpenFound) {
						break;
					}
				}
			}
		}
	}

	override private function keyDownHandler(event:KeyboardEvent):Void {
		if (keyNav) {
			super.keyDownHandler(event);
		}
	}

	override private function collectionChangeHandler(event:Event):Void {
		super.collectionChangeHandler(event);

		reopenPreviouslyClosedItems(Std.string(Reflect.getProperty(event, 'kind')), Reflect.getProperty(event, 'items'));
	}

	private function onCustomTreeItemEventHandler(event:TreeEvent):Void {
		isItemOpening = event.type == TreeEvent.ITEM_OPENING;
	}

	private function reopenPreviouslyClosedItems(eventKind:String, items:Array<Dynamic>):Void {
		if (!AS3.as(this.dataProvider, Bool) || isItemOpening) {
			return;
		}

		var itemsCount:Int = AS3.int(this.dataProvider.length);
		if (itemsCount > 0) {
			if (eventKind == Std.string(CollectionEventKind.ADD) || eventKind == Std.string(CollectionEventKind.RESET)) {
				itemsCount = items.length;
				if (eventKind == Std.string(CollectionEventKind.RESET)) {
					if (itemsCount == 0) {
						items = this.dataProvider.source.slice();
						itemsCount = items.length;
					}
				}

				if (itemsCount > 0) {
					setItemsAsOpen(items);
				}
			}
		}
	}

	private function setItemsAsOpen(items:Array<Dynamic>):Void {
		function hasSomeItemForOpen(itemForOpen:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return Reflect.hasField(itemForOpen, Std.string(Reflect.field(item, propertyNameKey))) &&
			Reflect.field(itemForOpen, Std.string(Reflect.field(item, propertyNameKey))) == Reflect.field(item, propertyNameKeyValue);
		};
		var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO('projectTree');
		if (cookie == null) {
			return;
		}

		var projectTree:Array<Dynamic> = Reflect.field(cookie.data, 'projectTree');
		if (projectTree != null && items.length > 0) {
			var item:Dynamic = items.shift();
			if (!AS3.as(isItemOpen(item), Bool)) {
				var hasItemForOpen:Bool = AS3.as(projectTree.some(), Bool);

				if (hasItemForOpen) {
					expandItem(item, true);
				}
			}

			setItemsAsOpen(items);
		}
	}

}