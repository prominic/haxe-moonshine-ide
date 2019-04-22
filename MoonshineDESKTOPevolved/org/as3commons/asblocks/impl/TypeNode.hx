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
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;
import org.as3commons.asblocks.utils.MetaDataUtil;
import org.as3commons.asblocks.utils.ModifierUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IType</code> implementation and abstract base class for the
 * <code>ClassTypeNode</code>, <code>InterfaceTypeNode</code> and
 * <code>FunctionTypeNode</code>.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TypeNode extends ContentBlockNode implements IType {

	//--------------------------------------------------------------------------
	//
	//  IType API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  visibility
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IType#visibility
	 */
	public var visibility(get, set):Visibility;
	private function get_visibility():Visibility {
		return ModifierUtil.getVisibility(node);
	}

	/**
	 * @private
	 */
	private function set_visibility(value:Visibility):Visibility {
		if (!value.equals(Visibility.PUBLIC)) {
			throw new ASBlocksSyntaxError('IType visibility must be public');
		}
		ModifierUtil.setVisibility(node, value);
		return value;
	}

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IType#name
	 */
	public var name(get, set):String;
	private function get_name():String {
		return NameTypeUtil.getName(node);
	}

	/**
	 * @private
	 */
	private function set_name(value:String):String {
		NameTypeUtil.setName(node, value);
		return value;
	}

	//----------------------------------
	//  packageName
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IType#packageName
	 */
	public var packageName(get, never):String;
	private function get_packageName():String {
		return ASTUtil.packageNameForType(this);
	}

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IType#qualifiedName
	 */
	public var qualifiedName(get, never):String;
	private function get_qualifiedName():String {
		return ASTUtil.qualifiedNameForType(this);
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
	public var metaDatas(get, never):Array<IMetaData>;
	private function get_metaDatas():Array<IMetaData> {
		return cast MetaDataUtil.getMetaDatas(node);
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
	public var description(get, set):String;
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
	public var documentation(get, never):IDocComment;
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
		return cast MetaDataUtil.getAllMetaData(node, name);
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