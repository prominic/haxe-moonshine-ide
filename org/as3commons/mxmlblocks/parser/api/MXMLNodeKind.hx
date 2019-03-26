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

package org.as3commons.mxmlblocks.parser.api;

/**
 * The <strong>MXMLNodeKind</strong> enumeration of <strong>.mxml</strong>
 * node kinds.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class MXMLNodeKind {

	public static inline var ATT:String = 'att';

	public static inline var BODY:String = 'body';

	public static inline var AS_DOC:String = 'as-doc';

	public static inline var BINDING:String = 'binding';

	public static inline var CDATA:String = 'cdata';

	public static inline var COMPILATION_UNIT:String = 'compilation-unit';

	public static inline var LOCAL_NAME:String = 'local-name';

	public static inline var NAME:String = 'name';

	public static inline var PROC_INST:String = 'proc-inst';

	public static inline var STATE:String = 'state';

	public static inline var TAG_LIST:String = 'tag-list';

	public static inline var ATT_LIST:String = 'att-list';

	public static inline var URI:String = 'uri';

	public static inline var VALUE:String = 'value';

	public static inline var XML_NS:String = 'xml-ns';

	public function new() {}

}