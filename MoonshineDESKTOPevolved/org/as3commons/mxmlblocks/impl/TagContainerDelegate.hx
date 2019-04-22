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

package org.as3commons.mxmlblocks.impl;

import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.mxmlblocks.api.IAttribute;
import org.as3commons.mxmlblocks.api.IBlockTag;
import org.as3commons.mxmlblocks.api.IMetadataTag;
import org.as3commons.mxmlblocks.api.IScriptTag;
import org.as3commons.mxmlblocks.api.ITag;
import org.as3commons.mxmlblocks.api.ITagContainer;
import org.as3commons.mxmlblocks.api.IXMLNamespace;

/**
 * The <code>ITagContainer</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TagContainerDelegate extends ScriptNode implements ITagContainer {

	//--------------------------------------------------------------------------
	//
	//  Protected :: Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var container(get, never):ITagContainer;
	private function get_container():ITagContainer {
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//  ITagContainer API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  id
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#id
	 */
	public var id(get, never):String;
	private function get_id():String {
		return container.id;
	}

	//----------------------------------
	//  binding
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#binding
	 */
	public var binding(get, set):String;
	private function get_binding():String {
		return container.binding;
	}

	/**
	 * @private
	 */
	private function set_binding(value:String):String {
		container.binding = value;
		return value;
	}

	//----------------------------------
	//  localName
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#localName
	 */
	public var localName(get, set):String;
	private function get_localName():String {
		return container.localName;
	}

	/**
	 * @private
	 */
	private function set_localName(value:String):String {
		container.localName = value;
		return value;
	}

	//----------------------------------
	//  hasChildren
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#hasChildren
	 */
	public var hasChildren(get, never):Bool;
	private function get_hasChildren():Bool {
		return container.hasChildren;
	}

	//----------------------------------
	//  namespaces
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#namespaces
	 */
	public var namespaces(get, never):Array<IXMLNamespace>;
	private function get_namespaces():Array<IXMLNamespace> {
		return cast container.namespaces;
	}

	//----------------------------------
	//  attributes
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#attributes
	 */
	public var attributes(get, never):Array<IAttribute>;
	private function get_attributes():Array<IAttribute> {
		return cast container.attributes;
	}

	//----------------------------------
	//  children
	//----------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#children
	 */
	public var children(get, never):Array<ITag>;
	private function get_children():Array<ITag> {
		return cast container.children;
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
	//  IBlockTag API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#addComment()
	 */
	public function addComment(text:String):IToken {
		return container.addComment(text);
	}

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newXMLNS()
	 */
	public function newXMLNS(localName:String, uri:String):IXMLNamespace {
		return container.newXMLNS(localName, uri);
	}

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newAttribute()
	 */
	public function newAttribute(name:String, value:String, state:String = null):IAttribute {
		return container.newAttribute(name, value, state);
	}

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newTag()
	 */
	public function newTag(name:String, binding:String = null):IBlockTag {
		return container.newTag(name, binding);
	}

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newScriptTag()
	 */
	public function newScriptTag(code:String = null):IScriptTag {
		return container.newScriptTag(code);
	}

	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newMetadataTag()
	 */
	public function newMetadataTag(code:String = null):IMetadataTag {
		return container.newMetadataTag(code);
	}

}