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

class AS3LineParser extends LineParser {

	public static inline var AS_CODE:Int = 0x1;
	public static inline var AS_STRING1:Int = 0x2;
	public static inline var AS_STRING2:Int = 0x3;
	public static inline var AS_COMMENT:Int = 0x4;
	public static inline var AS_MULTILINE_COMMENT:Int = 0x5;
	public static inline var AS_REGULAR_EXPRESSION:Int = 0x6;
	public static inline var AS_KEYWORD:Int = 0xA;
	public static inline var AS_VAR_KEYWORD:Int = 0xB;
	public static inline var AS_FUNCTION_KEYWORD:Int = 0xC;
	public static inline var AS_PACKAGE_CLASS_KEYWORDS:Int = 0xD;
	public static inline var AS_METADATA:Int = 0xE;
	public static inline var AS_FIELD:Int = 0xF;
	public static inline var AS_FUNCTIONS:Int = 0x11;

	public function new() {
		context = AS_CODE;
		defaultContext = AS_CODE;

		wordBoundaries = new as3hx.Compat.Regex('([\\s,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+)', 'g');

		// TODO: Add patterns for multiline strings
		patterns = [
				[AS_STRING1, new as3hx.Compat.Regex('^\\"(?:\\\\\\\\|\\\\\\"|[^\\n])*?(?:\\"|\\\\\\n|(?=\\n))', '')], //"
				[AS_STRING2, new as3hx.Compat.Regex('^\\\'(?:\\\\\\\\|\\\\\\\'|[^\\n])*?(?:\\\'|\\\\\\n|(?=\\n))', '')],
				[AS_COMMENT, new as3hx.Compat.Regex('^\\/\\/.*', '')],
				[AS_MULTILINE_COMMENT, new as3hx.Compat.Regex('^\\/\\*.*?(?:\\*\\/|\\n)', '')],
				[AS_REGULAR_EXPRESSION, new as3hx.Compat.Regex('^\\/(?:\\\\\\\\|\\\\\\/|\\[(?:\\\\\\\\|\\\\\\]|.)+?\\]|[^*\\/])(?:\\\\\\\\|\\\\\\/|\\[(?:\\\\\\\\|\\\\\\]|.)+?\\]|.)*?\\/[gismx]*', '')],
				[AS_METADATA, new as3hx.Compat.Regex('^\\[(?:(Bindable|Event|Exclude|Style|ResourceBundle|IconFile|DefaultProperty|Inspectable|SkinState|Effect|SkinPart)(?:\\([^\\)]*\\))?)\\]', '')],
				[AS_FIELD, new as3hx.Compat.Regex('^\\s+\\w+(?=:\\w+(\\s*=\\s*[^;]+)?;)', '')],
				[AS_FUNCTIONS, new as3hx.Compat.Regex('^\\s+\\w+(?=\\((\\s*|.+)\\):([^:]+)$)', '')]
		];

		endPatterns = cast [
				[AS_STRING1, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\"|(?=\\n))', '')],
				[AS_STRING2, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\\'|(?=\\n))', '')],
				[AS_MULTILINE_COMMENT, new as3hx.Compat.Regex('\\*\\/', '')]
		];

		keywords = cast [
				[AS_KEYWORD,
				['is', 'if', 'in', 'as', 'new', 'for', 'use', 'set', 'get', 'try',
				'null', 'true', 'void', 'else', 'each', 'case', 'this', 'break', 'false',
				'const', 'catch', 'class', 'return', 'switch', 'static',
				'import', 'private', 'public', 'extends', 'override', 'inherits',
				'internal', 'implements', 'package', 'protected', 'namespace',
				'final', 'native', 'dynamic'
		]
		],
				[AS_VAR_KEYWORD, ['var']],
				[AS_FUNCTION_KEYWORD, ['function']],
				[AS_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface']]
		];

		super();
	}

}