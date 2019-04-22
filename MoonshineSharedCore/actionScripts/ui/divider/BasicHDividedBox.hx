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
import mx.containers.dividedBoxClasses.BoxDivider;

class BasicHDividedBox extends HDividedBox {

	public function new() {
		super();
		this.dividerClass = BasicHDivider;
	}

}

class BasicHDivider extends BoxDivider {

	public function new() {
		super();
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		/*
		This would have been easier if the knob-skin could draw as it wanted.
		Currently it's /removed/ if the divider is thinner than 6 pixels.
		So we override & draw like this.
		*/

		graphics.beginFill(0xa0a0a0, 1);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();
	}

}