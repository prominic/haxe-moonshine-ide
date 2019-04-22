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

/**
 * The <strong>Operators</strong> enumeration of <strong>actionscript3</strong>
 * operators.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class Operators {

	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * The <code>?</code>
	 */
	public static inline var QUESTION:String = '?';

	/**
	 * The <code>(</code>
	 */
	public static inline var LPAREN:String = '(';

	/**
	 * The <code>)</code>
	 */
	public static inline var RPAREN:String = ')';

	/**
	 * The <code>[</code>
	 */
	public static inline var LBRACK:String = '[';

	/**
	 * The <code>]</code>
	 */
	public static inline var RBRACK:String = ']';

	/**
	 * The <code>{</code>
	 */
	public static inline var LCURLY:String = '{';

	/**
	 * The <code>}</code>
	 */
	public static inline var RCURLY:String = '}';

	/**
	 * The <code>:</code>
	 */
	public static inline var COLON:String = ':';

	/**
	 * The <code>::</code>
	 */
	public static inline var DBL_COLON:String = '::';

	/**
	 * The <code>,</code>
	 */
	public static inline var COMMA:String = ',';

	/**
	 * The <code>=</code>
	 */
	public static inline var ASSIGN:String = '=';

	/**
	 * The <code>==</code>
	 */
	public static inline var EQUAL:String = '==';

	/**
	 * The <code>===</code>
	 */
	public static inline var STRICT_EQUAL:String = '===';

	/**
	 * The <code>!</code>
	 */
	public static inline var LNOT:String = '!';

	/**
	 * The <code>~</code>
	 */
	public static inline var BNOT:String = '~';

	/**
	 * The <code>!=</code>
	 */
	public static inline var NOT_EQUAL:String = '!=';

	/**
	 * The <code>!==</code>
	 */
	public static inline var STRICT_NOT_EQUAL:String = '!==';

	/**
	 * The <code>/</code>
	 */
	public static inline var DIV:String = '/';

	/**
	 * The <code>/=</code>
	 */
	public static inline var DIV_ASSIGN:String = '/=';

	/**
	 * The <code>+</code>
	 */
	public static inline var PLUS:String = '+';

	/**
	 * The <code>+=</code>
	 */
	public static inline var PLUS_ASSIGN:String = '+=';

	/**
	 * The <code>++</code>
	 */
	public static inline var INC:String = '++';

	/**
	 * The <code>-</code>
	 */
	public static inline var MINUS:String = '-';

	/**
	 * The <code>-=</code>
	 */
	public static inline var MINUS_ASSIGN:String = '-=';

	/**
	 * The <code>--</code>
	 */
	public static inline var DEC:String = '--';

	/**
	 * The <code>*</code>
	 */
	public static inline var STAR:String = '*';

	/**
	 * The <code>*=</code>
	 */
	public static inline var STAR_ASSIGN:String = '*=';

	/**
	 * The <code>%</code>
	 */
	public static inline var MOD:String = '%';

	/**
	 * The <code>%=</code>
	 */
	public static inline var MOD_ASSIGN:String = '%=';

	/**
	 * The <code>>></code>
	 */
	public static inline var SR:String = '>>';

	/**
	 * The <code>>>=</code>
	 */
	public static inline var SR_ASSIGN:String = '>>=';

	/**
	 * The <code>>>></code>
	 */
	public static inline var BSR:String = '>>>';

	/**
	 * The <code>>>>=</code>
	 */
	public static inline var BSR_ASSIGN:String = '>>>=';

	/**
	 * The <code>>=</code>
	 */
	public static inline var GE:String = '>=';

	/**
	 * The <code>></code>
	 */
	public static inline var GT:String = '>';

	/**
	 * The <code><<</code>
	 */
	public static inline var SL:String = '<<';

	/**
	 * The <code><<=</code>
	 */
	public static inline var SL_ASSIGN:String = '<<=';

	/**
	 * The <code><<<</code>
	 */
	public static inline var SSL:String = '<<<';

	/**
	 * The <code><<<=</code>
	 */
	public static inline var SSL_ASSIGN:String = '<<<=';

	/**
	 * The <code><=</code>
	 */
	public static inline var LE:String = '<=';

	/**
	 * The <code><</code>
	 */
	public static inline var LT:String = '<';

	/**
	 * The <code>^</code>
	 */
	public static inline var BXOR:String = '^';

	/**
	 * The <code>^=</code>
	 */
	public static inline var BXOR_ASSIGN:String = '^=';

	/**
	 * The <code>|</code>
	 */
	public static inline var BOR:String = '|';

	/**
	 * The <code>|=</code>
	 */
	public static inline var BOR_ASSIGN:String = '|=';

	/**
	 * The <code>||</code>
	 */
	public static inline var LOR:String = '||';

	/**
	 * The <code>||=</code>
	 */
	public static inline var LOR_ASSIGN:String = '||=';

	/**
	 * The <code>&</code>
	 */
	public static inline var BAND:String = '&';

	/**
	 * The <code>&=</code>
	 */
	public static inline var BAND_ASSIGN:String = '&=';

	/**
	 * The <code>&&</code>
	 */
	public static inline var LAND:String = '&&';

	/**
	 * The <code>&&=</code>
	 */
	public static inline var LAND_ASSIGN:String = '&&=';

	/**
	 * The <code>at</code>
	 */
	public static inline var E4X_ATTRI:String = '@';

	/**
	 * The <code>;</code>
	 */
	public static inline var SEMI:String = ';';

	/**
	 * The <code>.</code>
	 */
	public static inline var DOT:String = '.';

	/**
	 * The <code>..</code>
	 */
	public static inline var E4X_DESC:String = '..';

	/**
	 * The <code>...</code>
	 */
	public static inline var REST:String = '...';

	/**
	 * The <code>"</code>
	 */
	public static inline var QUOTE:String = '"';

	/**
	 * The <code>'</code>
	 */
	public static inline var SQUOTE:String = '\'';

	/**
	 * The <code>.<</code>
	 */
	public static inline var VECTOR_START:String = '.<';

}