////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects;

/**
 * Implementation of SymbolKind enum from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new values to this class that are specific
 * to Moonshine IDE or to a particular language.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
 * @see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
 */
class SymbolKind {

	public static inline var FILE:Int = 1;
	public static inline var MODULE:Int = 2;
	public static inline var NAMESPACE:Int = 3;
	public static inline var PACKAGE:Int = 4;
	public static inline var CLASS:Int = 5;
	public static inline var METHOD:Int = 6;
	public static inline var PROPERTY:Int = 7;
	public static inline var FIELD:Int = 8;
	public static inline var CONSTRUCTOR:Int = 9;
	public static inline var ENUM:Int = 10;
	public static inline var INTERFACE:Int = 11;
	public static inline var FUNCTION:Int = 12;
	public static inline var VARIABLE:Int = 13;
	public static inline var CONSTANT:Int = 14;
	public static inline var STRING:Int = 15;
	public static inline var NUMBER:Int = 16;
	public static inline var BOOLEAN:Int = 17;
	public static inline var ARRAY:Int = 18;
	public static inline var OBJECT:Int = 19;
	public static inline var KEY:Int = 20;
	public static inline var NULL:Int = 21;
	public static inline var ENUM_MEMBER:Int = 22;
	public static inline var STRUCT:Int = 23;
	public static inline var EVENT:Int = 24;
	public static inline var OPERATOR:Int = 25;
	public static inline var TYPE_PARAMETER:Int = 26;

}