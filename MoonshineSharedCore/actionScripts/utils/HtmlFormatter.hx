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

class HtmlFormatter {

	/*
		HTML encode replacements. Use %s for substitution.
	*/
	public static function sprintf(str:String, replacements:Array<Dynamic> = null):String {
		// TODO: Use the sprintf lib that is on google code instead? (MIT)
		var repl:Int = 0;

		return
				new as3hx.Compat.Regex('%[%sxd]', 'g').replace(str,
				function():String {
					var token:String = Std.string(Reflect.getProperty(arguments, Std.string(0)));
					switch (token) {
						case '%x':
							return (repl < replacements.length) ? TextUtil.htmlEscape(Std.string(replacements[repl++])) : '';
						case '%s':
							return (repl < replacements.length) ? Std.string(replacements[repl++]) : '';
						case '%d':
							return (repl < replacements.length) ? Std.string(Std.string(as3hx.Compat.parseFloat(replacements[repl++]))) : '';
						case _:
							return '%';
					}
				}
		);
	}

	// sprintf shorthand to remove ... syntaxing
	public static function sprintfa(str:String, replacements:Array<Dynamic>):String {
		if (replacements == null) {
			return str;
		}

		replacements.unshift(str);
		return Std.string(Reflect.callMethod(HtmlFormatter, sprintf, replacements));
	}

}