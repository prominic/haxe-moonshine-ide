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
package actionScripts.plugin.console;

class ConsoleStyle {

	// Styles guaranteed to be present for Console history.
	// Use ConsoleTextLineModel to create these.
	public static inline var NOTICE:Int = 10;
	public static inline var WARNING:Int = 11;
	public static inline var ERROR:Int = 12;
	public static inline var WEAK:Int = 13;
	public static inline var SUCCESS:Int = 14;

	// No touching, please.
	@:allow(actionScripts.plugin.console)
	private static var name2style:Dynamic = {};

	private static function init():Void {
		Reflect.setField(name2style, 'notice', NOTICE);
		Reflect.setField(name2style, 'warning', WARNING);
		Reflect.setField(name2style, 'error', ERROR);
		Reflect.setField(name2style, 'weak', WEAK);
		Reflect.setField(name2style, 'success', SUCCESS);
	}

	private static var ConsoleStyle_static_initializer = {
		init();
		true;
	}

}