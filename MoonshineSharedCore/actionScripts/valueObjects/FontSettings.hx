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
package actionScripts.valueObjects;

import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;

class FontSettings {

	public var defaultFontFamily:String = 'DejaVuMono';
	public var defaultFontSize:Float = 13;
	public var defaultFontDescription:FontDescription;
	public var uiFontDescription:FontDescription =
		new FontDescription('DejaVuSans', FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF);

	// Width of a tab-stop, in characters
	public var tabWidth:Int = 4;

	public function new() {
		this.defaultFontDescription =
				new FontDescription(this.defaultFontFamily, FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF);
	}

}