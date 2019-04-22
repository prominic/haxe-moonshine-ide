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
/**
 * [props..]
 * [enableTypes]
 * null = To avail option against any type of project
 * [ProjectMenuTypes.., ProjectMenuTypes..] = To avail option against specific type of project(s)
 * [] = (Not recommended) May disable option against all type of project(s)
 */
package actionScripts.ui.menu.vo;

class MenuItem extends Dynamic {

	public var label:String;
	public var items:Array<MenuItem>;
	public var event:String;
	public var mac_key:Dynamic;
	public var mac_mod:Array<Dynamic>;
	public var win_key:Dynamic;
	public var win_mod:Array<Dynamic>;
	public var lnx_key:Dynamic;
	public var lnx_mod:Array<Dynamic>;
	public var data:Dynamic;
	public var isSeparator:Bool = false;
	public var parents:Array<Dynamic>;
	public var enableTypes:Array<Dynamic>;
	public var dynamicItem:Bool = false;

	public function new(label:String, items:Array<Dynamic> = null, enableTypes:Array<Dynamic> = null,
			event:String = null,
			mac_key:Dynamic = null, mac_mod:Array<Dynamic> = null,
			win_key:Dynamic = null, win_mod:Array<Dynamic> = null,
			lnx_key:Dynamic = null, lnx_mod:Array<Dynamic> = null,
			parent:Array<Dynamic> = null, dynamicItem:Bool = false) {
		super();
		this.label = label;

		if (label == null) {
			isSeparator = true;
		}

		if (items != null) {
			this.items = items;
		}

		this.event = event;

		this.mac_key = mac_key;
		this.mac_mod = mac_mod;

		this.win_key = win_key;
		this.win_mod = win_mod;

		this.lnx_key = lnx_key;
		this.lnx_mod = lnx_mod;

		this.enableTypes = enableTypes;

		this.dynamicItem = dynamicItem;
	}

}