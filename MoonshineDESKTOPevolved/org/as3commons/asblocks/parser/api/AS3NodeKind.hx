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
 * The <strong>AS3NodeKind</strong> enumeration of <strong>.as</strong>
 * node kinds.
 *
 * <p>Initial API; Adobe Systems, Incorporated</p>
 *
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
class AS3NodeKind {

	//--------------------------------------------------------------------------
	//
	//  TOKENS
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  Assignment
	//----------------------------------

	/**
	 * <code>=</code>
	 */
	public static inline var ASSIGN:String = 'assign';

	/**
	 * <code>*=</code>
	 */
	public static inline var STAR_ASSIGN:String = 'star-assign';

	/**
	 * <code>/=</code>
	 */
	public static inline var DIV_ASSIGN:String = 'div-assign';

	/**
	 * <code>%=</code>
	 */
	public static inline var MOD_ASSIGN:String = 'mod-assign';

	/**
	 * <code>+=</code>
	 */
	public static inline var PLUS_ASSIGN:String = 'plus-assign';

	/**
	 * <code>-=</code>
	 */
	public static inline var MINUS_ASSIGN:String = 'minus-assign';

	/**
	 * <code><<=</code>
	 */
	public static inline var SL_ASSIGN:String = 'sl-assign';

	/**
	 * <code>>>=</code>
	 */
	public static inline var SR_ASSIGN:String = 'sr-assign';

	/**
	 * <code>>>=</code>
	 */
	public static inline var BSR_ASSIGN:String = 'bsr-assign';

	/**
	 * <code>&=</code>
	 */
	public static inline var BAND_ASSIGN:String = 'band-assign';

	/**
	 * <code>^=</code>
	 */
	public static inline var BXOR_ASSIGN:String = 'bxor-assign';

	/**
	 * <code>|=</code>
	 */
	public static inline var BOR_ASSIGN:String = 'bor-assign';

	/**
	 * <code>&&=</code>
	 */
	public static inline var LAND_ASSIGN:String = 'land-assign';

	/**
	 * <code>||=</code>
	 */
	public static inline var LOR_ASSIGN:String = 'lor-assign';

	//----------------------------------
	//  Conditional
	//----------------------------------

	/**
	 * <code>?</code>
	 */
	public static inline var QUESTION:String = 'question';

	/**
	 * <code>:</code>
	 */
	public static inline var COLON:String = 'colon';

	//----------------------------------
	//  Or And
	//----------------------------------

	/**
	 * <code>||</code>
	 */
	public static inline var LOR:String = 'lor';

	/**
	 * <code>&&</code>
	 */
	public static inline var LAND:String = 'land';

	/**
	 * <code>|</code>
	 */
	public static inline var BOR:String = 'bor';

	/**
	 * <code>^</code>
	 */
	public static inline var BXOR:String = 'bxor';

	/**
	 * <code>&</code>
	 */
	public static inline var BAND:String = 'band';

	//----------------------------------
	//  Equality
	//----------------------------------

	/**
	 * <code>==</code>
	 */
	public static inline var EQUAL:String = 'equal';

	/**
	 * <code>!=</code>
	 */
	public static inline var NOT_EQUAL:String = 'not-equal';

	/**
	 * <code>===</code>
	 */
	public static inline var STRICT_EQUAL:String = 'strict-equal';

	/**
	 * <code>!==</code>
	 */
	public static inline var STRICT_NOT_EQUAL:String = 'strict-not-equal';

	//----------------------------------
	//  Relational
	//----------------------------------

	/**
	 * <code>in</code>
	 */
	public static inline var IN:String = 'in';

	/**
	 * <code><</code>
	 */
	public static inline var LT:String = 'lt';

	/**
	 * <code><=</code>
	 */
	public static inline var LE:String = 'le';

	/**
	 * <code>></code>
	 */
	public static inline var GT:String = 'gt';

	/**
	 * <code>>=</code>
	 */
	public static inline var GE:String = 'ge';

	/**
	 * <code>is</code>
	 */
	public static inline var IS:String = 'is';

	/**
	 * <code>as</code>
	 */
	public static inline var AS:String = 'as';

	/**
	 * <code>instanceof</code>
	 */
	public static inline var INSTANCE_OF:String = 'instance-of';

	//----------------------------------
	//  Shift
	//----------------------------------

	/**
	 * <code><<</code>
	 */
	public static inline var SL:String = 'sl';

	/**
	 * <code>>></code>
	 */
	public static inline var SR:String = 'sr';

	/**
	 * <code><<<</code>
	 */
	public static inline var SSL:String = 'ssl';

	/**
	 * <code>>>></code>
	 */
	public static inline var BSR:String = 'bsr';

	//----------------------------------
	//  Additive
	//----------------------------------

	/**
	 * <code>+</code>
	 */
	public static inline var PLUS:String = 'plus';

	/**
	 * <code>-</code>
	 */
	public static inline var MINUS:String = 'minus';

	//----------------------------------
	//  Multiplicative
	//----------------------------------

	/**
	 * <code>*</code>
	 */
	public static inline var STAR:String = 'star';

	/**
	 * <code>/</code>
	 */
	public static inline var DIV:String = 'div';

	/**
	 * <code>%</code>
	 */
	public static inline var MOD:String = 'mod';

	//----------------------------------
	//  Unary
	//----------------------------------

	/**
	 * <code>--</code>
	 */
	public static inline var POST_DEC:String = 'post-dec';

	/**
	 * <code>++</code>
	 */
	public static inline var POST_INC:String = 'post-inc';

	/**
	 * <code>--</code>
	 */
	public static inline var PRE_DEC:String = 'pre-dec';

	/**
	 * <code>++</code>
	 */
	public static inline var PRE_INC:String = 'pre-inc';

	/**
	 * <code>delete</code>
	 */
	public static inline var DELETE:String = 'delete';

	/**
	 * <code>void</code>
	 */
	public static inline var VOID:String = 'void';

	/**
	 * <code>typeof</code>
	 */
	public static inline var TYPEOF:String = 'typeof';

	/**
	 * <code>!</code>
	 */
	public static inline var NOT:String = 'not';

	/**
	 * <code>~</code>
	 */
	public static inline var B_NOT:String = 'b-not';

	//----------------------------------
	//  Boundaries
	//----------------------------------

	public static inline var COMMA:String = 'comma';

	public static inline var CONFIG:String = 'config';

	public static inline var NAMESPACE:String = 'namespace';

	public static inline var SEMI:String = 'semi';

	public static inline var LBRACKET:String = 'lbracket';

	public static inline var LCURLY:String = 'lcurly';

	public static inline var RBRACKET:String = 'rbracket';

	public static inline var RCURLY:String = 'rcurly';

	public static inline var RPAREN:String = 'rparen';

	public static inline var LPAREN:String = 'lparen';

	public static inline var HIDDEN:String = 'hidden';

	public static inline var WS:String = 'ws';

	public static inline var NL:String = 'nl';

	public static inline var SPACE:String = 'space';

	public static inline var TAB:String = 'tab';

	public static inline var REST_PARM:String = 'rest-param';

	public static inline var ELSE:String = 'else';

	public static inline var ML_COMMENT:String = 'ml-comment';

	public static inline var SL_COMMENT:String = 'sl-comment';

	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------

	public static inline var COMMENT:String = 'comment';

	public static inline var AS_DOC:String = 'as-doc';

	public static inline var BLOCK_DOC:String = 'block-doc';

	public static inline var COMPILATION_UNIT:String = 'compilation-unit';

	public static inline var PACKAGE:String = 'package';

	public static inline var CONTENT:String = 'content';

	public static inline var INTERNAL_CONTENT:String = 'internal-content';

	public static inline var CLASS:String = 'class';

	public static inline var INTERFACE:String = 'interface';

	public static inline var EXTENDS:String = 'extends';

	public static inline var IMPLEMENTS:String = 'implements';

	public static inline var IMPORT:String = 'import';

	public static inline var INCLUDE:String = 'include';

	public static inline var USE:String = 'use';

	public static inline var META:String = 'meta';

	public static inline var META_LIST:String = 'meta-list';

	//----------------------------------
	//  Expression
	//----------------------------------

	public static inline var ASSIGNMENT:String = 'assignment';

	public static inline var CONDITIONAL:String = 'conditional';

	public static inline var OR:String = 'or';

	public static inline var AND:String = 'and';

	public static inline var EQUALITY:String = 'equality';

	public static inline var RELATIONAL:String = 'relational';

	public static inline var SHIFT:String = 'shift';

	public static inline var ADDITIVE:String = 'additive';

	public static inline var MULTIPLICATIVE:String = 'multiplicative';

	public static inline var B_AND:String = 'b-and';

	public static inline var B_OR:String = 'b-or';

	public static inline var B_XOR:String = 'b-xor';

	public static inline var EXPR_LIST:String = 'expr-list';

	public static inline var DOT:String = 'dot';

	public static inline var DOUBLE_COLUMN:String = 'double-column';

	public static inline var ARRAY_ACCESSOR:String = 'arr-acc';

	//----------------------------------
	//  Statement
	//----------------------------------

	public static inline var EXPR_STMNT:String = 'expr-stmnt';

	public static inline var LABEL:String = 'label';

	public static inline var FOR:String = 'for';

	public static inline var INIT:String = 'init';

	public static inline var COND:String = 'cond';

	public static inline var ITER:String = 'iter';

	public static inline var EACH:String = 'each';

	public static inline var FOREACH:String = 'foreach';

	public static inline var FORIN:String = 'forin';

	public static inline var CONTINUE:String = 'continue';

	public static inline var IF:String = 'if';

	public static inline var CONDITION:String = 'condition';

	public static inline var SWITCH:String = 'switch';

	public static inline var SWITCH_BLOCK:String = 'switch-block';

	public static inline var CASE:String = 'case';

	public static inline var CASES:String = 'cases';

	public static inline var DEFAULT:String = 'default';

	public static inline var DO:String = 'do';

	public static inline var WHILE:String = 'while';

	public static inline var WITH:String = 'with';

	public static inline var TRY:String = 'try';

	public static inline var TRY_STMNT:String = 'try-stmnt';

	public static inline var FINALLY:String = 'finally';

	public static inline var CATCH:String = 'catch';

	public static inline var BLOCK:String = 'block';

	public static inline var VAR:String = 'var';

	public static inline var CONST:String = 'const';

	public static inline var RETURN:String = 'return';

	public static inline var BREAK:String = 'break';

	public static inline var STMT_EMPTY:String = 'stmt-empty';// SEMI

	//----------------------------------
	//  Primary
	//----------------------------------

	public static inline var ARRAY:String = 'array';

	public static inline var OBJECT:String = 'object';

	public static inline var PROP:String = 'prop';

	public static inline var LAMBDA:String = 'lambda';

	public static inline var SUPER:String = 'super';

	public static inline var THIS:String = 'this';

	public static inline var THROW:String = 'throw';

	public static inline var NEW:String = 'new';

	public static inline var ENCAPSULATED:String = 'encapsulated';

	public static inline var STRING:String = 'string';

	public static inline var NUMBER:String = 'number';

	public static inline var REG_EXP:String = 'reg-exp';

	public static inline var FastXML:String = 'xml';

	public static inline var TRUE:String = 'true';

	public static inline var FALSE:String = 'false';

	public static inline var NULL:String = 'null';

	public static inline var UNDEFINED:String = 'undefined';

	public static inline var PRIMARY:String = 'primary';

	public static inline var DF_XML_NS:String = 'df-xml-ns';

	//----------------------------------
	//  Invocation
	//----------------------------------

	public static inline var CALL:String = 'call';

	public static inline var ARGUMENTS:String = 'arguments';

	//----------------------------------
	//  var, const Declaration
	//----------------------------------

	public static inline var DEC_LIST:String = 'dec-list';

	public static inline var DEC_ROLE:String = 'dec-role';

	public static inline var VECTOR:String = 'vector';

	public static inline var NAME:String = 'name';

	public static inline var TYPE:String = 'type';

	public static inline var VALUE:String = 'value';

	public static inline var NAME_TYPE_INIT:String = 'name-type-init';

	//----------------------------------
	//  Field
	//----------------------------------

	public static inline var FIELD_LIST:String = 'field-list';

	public static inline var FIELD_ROLE:String = 'field-role';

	public static inline var MOD_LIST:String = 'mod-list';

	public static inline var MODIFIER:String = 'mod';

	//----------------------------------
	//  Function
	//----------------------------------

	public static inline var FUNCTION:String = 'function';

	public static inline var ACCESSOR_ROLE:String = 'accessor-role';

	public static inline var GET:String = 'get';

	public static inline var SET:String = 'set';

	public static inline var PARAMETER:String = 'parameter';

	public static inline var PARAMETER_LIST:String = 'parameter-list';

	public static inline var REST:String = 'rest';

	//----------------------------------
	//  XML
	//----------------------------------

	public static inline var XML_NAMESPACE:String = 'xml-namespace';

	public static inline var E4X_ATTR:String = 'e4x-attr';

	public static inline var E4X_DESCENDENT:String = 'e4x-descendent';

	public static inline var E4X_FILTER:String = 'e4x-filter';

	public static inline var E4X_STAR:String = 'e4x-star';

}