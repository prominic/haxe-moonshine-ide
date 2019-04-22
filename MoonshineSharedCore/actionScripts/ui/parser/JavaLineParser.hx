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
package actionScripts.ui.parser;

class JavaLineParser extends LineParser {

	public static inline var JAVA_CODE:Int = 0x1;
	public static inline var JAVA_STRING1:Int = 0x2;
	public static inline var JAVA_STRING2:Int = 0x3;
	public static inline var JAVA_COMMENT:Int = 0x4;
	public static inline var JAVA_MULTILINE_COMMENT:Int = 0x5;
	public static inline var JAVA_KEYWORD:Int = 0xA;
	public static inline var JAVA_PACKAGE_CLASS_KEYWORDS:Int = 0xD;
	public static inline var JAVA_ANNOTATION:Int = 0xE;

	public function new() {
		context = JAVA_CODE;
		defaultContext = JAVA_CODE;

		wordBoundaries = new as3hx.Compat.Regex('([\\s,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+)', 'g');

		patterns = [
				[JAVA_STRING1, new as3hx.Compat.Regex('^\\"(?:\\\\\\\\|\\\\\\"|[^\\n])*?(?:\\"|\\\\\\n|(?=\\n))', '')], // "
				[JAVA_STRING2, new as3hx.Compat.Regex('^\\\'(?:\\\\\\\\|\\\\\\\'|[^\\n])*?(?:\\\'|\\\\\\n|(?=\\n))', '')], // '
				[JAVA_COMMENT, new as3hx.Compat.Regex('^\\/\\/.*', '')], // //
				[JAVA_MULTILINE_COMMENT, new as3hx.Compat.Regex('^\\/\\*.*?(?:\\*\\/|\\n)', '')], // /*
				[JAVA_ANNOTATION, new as3hx.Compat.Regex('^@\\w+(\\(((["\']\\w+["\'])|({(["\']\\w+["\'])(,\\s+(["\']\\w+["\']))+}))\\))?', '')]
		];

		endPatterns = [
				[JAVA_STRING1, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\"|(?=\\n))', '')], // "
				[JAVA_STRING2, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\\'|(?=\\n))', '')], // '
				[JAVA_MULTILINE_COMMENT, new as3hx.Compat.Regex('\\*\\/', '')]
		];

		keywords = cast [
				[JAVA_KEYWORD,
				[
				'abstract',
				'continue',
				'for',
				'new',
				'switch',
				'assert',
				'default',
				'goto',
				'synchronized',
				'boolean',
				'do',
				'if',
				'private',
				'this',
				'break',
				'double',
				'implements',
				'protected',
				'throw',
				'byte',
				'else',
				'import',
				'public',
				'throws',
				'case',
				'enum',
				'instanceof',
				'return',
				'transient',
				'catch',
				'extends',
				'int',
				'short',
				'try',
				'char',
				'final',
				'static',
				'void',
				'finally',
				'long',
				'strictfp',
				'volatile',
				'const',
				'float',
				'native',
				'super',
				'while'
		]
		],
				[JAVA_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface']]
		];

		super();
	}

}