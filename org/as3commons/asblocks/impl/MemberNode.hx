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

package org.as3commons.asblocks.impl;

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IDocComment;
import org.as3commons.asblocks.api.IMember;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.Modifier;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;
import org.as3commons.asblocks.utils.MetaDataUtil;
import org.as3commons.asblocks.utils.ModifierUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IMember</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class MemberNode extends ScriptNode implements IMember {

	public var visibility(get, set):Visibility;
	public var name(get, set):String;
	public var qualifiedName(get, never):String;
	public var type(get, set):String;
	public var qualifiedType(get, never):String;
	public var isStatic(get, set):Bool;
	public var metaDatas(get, never):Array<IMetaData>;
	public var description(get, set):String;
	public var documentation(get, never):IDocComment;

	//--------------------------------------------------------------------------
	//
	//  IMember API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  visibility
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMember#visibility
	 */
	private function get_visibility():Visibility {
		return ModifierUtil.getVisibility(node);
	}

	/**
	 * @private
	 */
	private function set_visibility(value:Visibility):Visibility {
		return value;
		return value;
	}

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMember#name
	 */
	private function get_name():String {
		return NameTypeUtil.getName(node);
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		if (value.indexOf('.') != -1) {
			throw new ASBlocksSyntaxError('IMember names cannot contain a period');
		}
		NameTypeUtil.setName(node, value);
		return value;
	}

	//----------------------------------
	//  qualifiedName
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMember#qualifiedName
	 */
	private function get_qualifiedName():String {
		return NameTypeUtil.getQualfiedName(this);
	}

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMember#type
	 */
	private function get_type():String {
		return NameTypeUtil.getType(node);
	}

	/**
	 * @private
	 */
	private function set_type(value:String):String {
		NameTypeUtil.setType(node, value);
		return value;
	}

	//----------------------------------
	//  qualifiedType
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IFunction#qualifiedType
	 */
	private function get_qualifiedType():String {
		if (type == null) {
			return null;
		}

		return ASTUtil.qualifiedNameForTypeString(node, type);
	}

	//----------------------------------
	//  isStatic
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMember#isStatic
	 */
	private function get_isStatic():Bool {
		return ModifierUtil.hasModifierFlag(node, Modifier.STATIC);
	}

	/**
	 * @private
	 */
	private function set_isStatic(value:Bool):Bool {
		ModifierUtil.setModifierFlag(node, value, Modifier.STATIC);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  IMetaDataAware API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  metaDatas
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#metaDatas
	 */
	private function get_metaDatas():Array<IMetaData> {
		return MetaDataUtil.getMetaDatas(node);
	}

	//--------------------------------------------------------------------------
	//
	//  IDocCommentAware API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  description
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#description
	 */
	private function get_description():String {
		return null;
	}

	/**
	 * @private
	 */
	private function set_description(value:String):String {
		documentation.description = value;
		return value;
	}

	//----------------------------------
	//  documentation
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#documentation
	 */
	private function get_documentation():IDocComment {
		return DocCommentUtil.createDocComment(node);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(node:IParserNode) {
		super(node);
	}

	//--------------------------------------------------------------------------
	//
	//  IMetaDataAware API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#newMetaData()
	 */
	public function newMetaData(name:String):IMetaData {
		return MetaDataUtil.newMetaData(node, name);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getMetaData()
	 */
	public function getMetaData(name:String):IMetaData {
		return MetaDataUtil.getMetaData(node, name);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getAllMetaData()
	 */
	public function getAllMetaData(name:String):Array<IMetaData> {
		return MetaDataUtil.getAllMetaData(node, name);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#hasMetaData()
	 */
	public function hasMetaData(name:String):Bool {
		return MetaDataUtil.hasMetaData(node, name);
	}

	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#removeMetaData()
	 */
	public function removeMetaData(metaData:IMetaData):Bool {
		return MetaDataUtil.removeMetaData(node, metaData);
	}

}