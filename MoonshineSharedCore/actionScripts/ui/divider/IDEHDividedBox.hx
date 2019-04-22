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
package actionScripts.ui.divider;

import mx.containers.HDividedBox;
import mx.core.IUIComponent;
import actionScripts.ui.IPanelWindow;

class IDEHDividedBox extends HDividedBox {

	public function new() {
		super();
		this.dividerClass = IDEHDivider;
	}

	// Normalize all percent-width children to fixed width
	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var panels:Array<IPanelWindow> = new Array<IPanelWindow>();
		var sizes:Array<Float> = new Array<Float>();
		var totalPercent:Int = 0;
		var child:IUIComponent;
		var i:Int;

		// First run to get the percent totals
		i = AS3.int(numChildren);

		while (i-- != 0) {
			child = IUIComponent(getChildAt(i));

			if (!AS3.as(Math.isNaN(child.percentWidth), Bool)) {
				// Accumulate total percentage
				totalPercent += AS3.int(child.percentWidth);
				// Collect for fixing if its an IPanelWindow
				if (Std.is(child, IPanelWindow)) {
					panels.push(child);
					sizes.push(child.percentWidth);
				}
			}
		}
		// Second run to apply the normalization
		i = panels.length;

		while (i-- != 0) {
			child = panels[i];

			child.explicitWidth = unscaledWidth * sizes[i] / totalPercent;
		}
	}

}