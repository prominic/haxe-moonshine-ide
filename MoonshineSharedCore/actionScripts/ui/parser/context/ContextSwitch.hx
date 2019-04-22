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
package actionScripts.ui.parser.context;

class ContextSwitch {

	public var from:Array<Int>;
	public var to:Int = 0;
	public var pattern:as3hx.Compat.Regex;
	public var post:Bool = false;

	private function new(from:Array<Int>, to:Int, pattern:as3hx.Compat.Regex = null, post:Bool = false) {
		this.from = from;
		this.to = to;
		this.pattern = pattern;
		this.post = post;
	}

}