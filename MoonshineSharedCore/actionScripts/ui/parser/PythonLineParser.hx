////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.parser;

class PythonLineParser extends LineParser {

	public static inline var PY_CODE:Int = 0x1;
	public static inline var PY_STRING1:Int = 0x2;
	public static inline var PY_STRING2:Int = 0x3;
	public static inline var PY_COMMENT:Int = 0x4;
	public static inline var PY_MULTILINE_COMMENT:Int = 0x5;
	public static inline var PY_KEYWORD:Int = 0x6;
	public static inline var PY_FUNCTION_KEYWORD:Int = 0xA;
	public static inline var PY_PACKAGE_CLASS_KEYWORDS:Int = 0xB;

	public function new() {
		context = PY_CODE;
		defaultContext = PY_CODE;

		wordBoundaries = new as3hx.Compat.Regex('([\\s,(){}\\[\\]\\-+*%\\/="\'~!&|<>?:;.]+)', 'g');

		patterns = cast [
				[PY_MULTILINE_COMMENT, new as3hx.Compat.Regex('^""".*?(?:"""|\\n)', '')],
				[PY_STRING1, new as3hx.Compat.Regex('^\\"(?:\\\\\\\\|\\\\\\"|[^\\n])*?(?:\\"|\\\\\\n|(?=\\n))', '')],
				[PY_STRING2, new as3hx.Compat.Regex('^\\\'(?:\\\\\\\\|\\\\\\\'|[^\\n])*?(?:\\\'|\\\\\\n|(?=\\n))', '')],
				[PY_COMMENT, new as3hx.Compat.Regex('^#.*', '')]
		];

		endPatterns = cast [
				[PY_STRING1, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\"|(?=\\n))', '')],
				[PY_STRING2, new as3hx.Compat.Regex('(?:^|[^\\\\])(\\\'|(?=\\n))', '')],
				[PY_MULTILINE_COMMENT, new as3hx.Compat.Regex('"""', '')]
		];

		keywords = cast [
				[PY_KEYWORD,
				['and', 'del', 'for', 'is', 'raise', 'assert', 'elif', 'from',
				'lambda', 'return', 'break', 'else', 'global', 'not', 'try',
				'except', 'if', 'or', 'while', 'continue', 'exec',
				'import', 'pass', 'yield', 'finally', 'in', 'print'
		]
		],
				[PY_FUNCTION_KEYWORD, ['def']],
				[PY_PACKAGE_CLASS_KEYWORDS, ['class']]
		];

		super();
	}

}