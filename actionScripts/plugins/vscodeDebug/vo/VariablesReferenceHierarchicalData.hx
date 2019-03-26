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
package actionScripts.plugins.vscodeDebug.vo;

import flash.events.EventDispatcher;
import mx.collections.ArrayCollection;
import mx.collections.IHierarchicalData;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
class VariablesReferenceHierarchicalData extends EventDispatcher implements IHierarchicalData {

	public function new() {
		super();
	}

	private var _scopes:ArrayCollection = new ArrayCollection();

	private var _variablesReferenceToVariables:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	public function removeAll():Void {
		this._variablesReferenceToVariables = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
		this._scopes.removeAll();
	}

	public function setScopes(scopes:Array<Dynamic>):Void {
		this._variablesReferenceToVariables = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
		this.populateCollectionsForParentReferences(scopes);
		this._scopes.source = scopes;
	}

	public function setVariablesForScopeOrVar(variables:Array<Dynamic>, parentScopeOrVar:BaseVariablesReference):Void {
		this.populateCollectionsForParentReferences(variables);
		var collection:ArrayCollection = cast((this._variablesReferenceToVariables[parentScopeOrVar]), ArrayCollection);
		collection.source = variables;

		//for some reason, this is necessary or the tree won't update. -JT
		collection.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REFRESH));
	}

	private function populateCollectionsForParentReferences(references:Array<Dynamic>):Void {
		var count:Int = references.length;
		for (i in 0...count) {
			var scopeOrVar:BaseVariablesReference = cast((references[i]), BaseVariablesReference);
			var variablesReference:Float = scopeOrVar.variablesReference;
			if (variablesReference != -1) {
				var collection:ArrayCollection = try cast(this._variablesReferenceToVariables[scopeOrVar], ArrayCollection) catch (e:Dynamic) null;
				if (collection == null)
				//everything starts out empty, but will be populated later
				{

					this._variablesReferenceToVariables[scopeOrVar] = new ArrayCollection();
				}
			}
		}
	}

	public function canHaveChildren(node:Dynamic):Bool {
		return Std.is(node, BaseVariablesReference) && cast((node), BaseVariablesReference).variablesReference != -1;
	}

	public function hasChildren(node:Dynamic):Bool {
		return this.canHaveChildren(node);
	}

	public function getChildren(node:Dynamic):Dynamic {
		var branch:BaseVariablesReference = try cast(node, BaseVariablesReference) catch (e:Dynamic) null;
		if (branch == null) {
			return null;
		}
		return this._variablesReferenceToVariables[branch];
	}

	public function getData(node:Dynamic):Dynamic {
		return node;
	}

	public function getRoot():Dynamic {
		return this._scopes;
	}

}