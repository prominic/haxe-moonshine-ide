////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.parser.api;

class ASDocNodeKind {

	public static inline var ML_START:String = 'ml-start';

	public static inline var ML_END:String = 'ml-end';

	public static inline var BODY:String = 'body';

	public static inline var COMPILATION_UNIT:String = 'compilation-unit';

	public static inline var DESCRIPTION:String = 'description';

	public static inline var INLINE_DOCTAG:String = 'inline-doctag';

	public static inline var DOCTAG:String = 'doctag';

	public static inline var DOCTAG_LIST:String = 'doctag-list';

	public static inline var LINK:String = 'link';

	public static inline var NAME:String = 'name';

	public static inline var TEXT:String = 'text';

	public static inline var TEXT_BLOCK:String = 'text-block';

	public static inline var WS:String = 'ws';

	public static inline var NL:String = 'nl';

	public static inline var ASTRIX:String = 'astrix';

	// token
	public static inline var AT:String = 'at';

	public function new() {}

}