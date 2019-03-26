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

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.mxmlblocks.api.IAttribute;
import org.as3commons.mxmlblocks.api.IBlockTag;
import org.as3commons.mxmlblocks.api.IMetadataTag;
import org.as3commons.mxmlblocks.api.IScriptTag;
import org.as3commons.mxmlblocks.api.ITag;
import org.as3commons.mxmlblocks.api.IXMLNamespace;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

/**
 * The <code>IBlockTag</code> implementation.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class TagList extends TagContainerDelegate implements IBlockTag {

	//--------------------------------------------------------------------------
	//
	//  IBlockTag API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  id
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_id():String {
		var ast:IParserNode = findAttList();
		if (ast == null) {
			return null;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			var current:AttributeNode = new AttributeNode(i.next());
			if (current.name == 'id') {
				return current.value;
			}
		}
		return null;
	}

	//----------------------------------
	//  binding
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_binding():String {
		var ast:IParserNode = findBinding();
		if (ast == null) {
			return null;
		}
		return ast.stringValue;
	}

	/**
	 * @private
	 */
	override private function set_binding(value:String):String {
		var ast:IParserNode = findBinding();
		if (value == null) {
			if (ast != null) {
				node.removeChild(ast);
				var s:LinkedListToken = ASTUtil.findTagStop(node);
				s.next.remove();
			}
			return value;
		}

		if (ast == null) {
			ast = ASTBuilder.newAST(MXMLNodeKind.BINDING, value);
			var colon:LinkedListToken = TokenBuilder.newColon();
			ast.appendToken(colon);
			//ast.startToken.beforeInsert(colon);
			//ast.startToken = colon;
			// TODO (mschmalle) 1 if as-doc
			node.addChildAt(ast, 0);
			var stop:LinkedListToken = ASTUtil.findTagStop(node);
			if (stop.text == '</') {
				var end:LinkedListToken = TokenBuilder.newToken('b-end', value + ':');
				stop.append(end);
			}
		} else {
			ast.stringValue = value;
			stop = ASTUtil.findTagStop(node);
			stop.next.text = value + ':';
		}
		return value;
	}

	//----------------------------------
	//  localName
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_localName():String {
		var ast:IParserNode = findLocalName();
		if (ast == null) {
			return null;
		}
		return ast.stringValue;
	}

	/**
	 * @private
	 */
	override private function set_localName(value:String):String {
		if (value == null || value == '') {
			throw new ASBlocksSyntaxError('tag localName connot be null');
		}

		var ast:IParserNode = findLocalName();
		ast.stringValue = value;
		// stop is </ or />
		var stop:LinkedListToken = ASTUtil.findTagStop(node);
		stop.next.text = value;
		return value;
	}

	//----------------------------------
	//  hasChildren
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_hasChildren():Bool {
		var ast:IParserNode = findBody();
		if (ast == null) {
			return false;
		}
		return ast.numChildren > 0;
	}

	//----------------------------------
	//  namespaces
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_namespaces():Array<IXMLNamespace> {
		var result:Array<IXMLNamespace> = new Array<IXMLNamespace>();
		var ast:IParserNode = findAttList();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			var current:IParserNode = i.next();
			if (current.isKind(MXMLNodeKind.XML_NS)) {
				result.push(new XMLNamespaceNode(current));
			}
		}

		return result;
	}

	//----------------------------------
	//  attributes
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_attributes():Array<IAttribute> {
		var result:Array<IAttribute> = new Array<IAttribute>();
		var ast:IParserNode = findAttList();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			var current:IParserNode = i.next();
			if (current.isKind(MXMLNodeKind.ATT)) {
				result.push(new AttributeNode(current));
			}
		}

		return result;
	}

	//----------------------------------
	//  children
	//----------------------------------

	/**
	 * @private
	 */
	override private function get_children():Array<ITag> {
		var result:Array<ITag> = new Array<ITag>();
		var ast:IParserNode = findBody();
		if (ast == null) {
			return result;
		}

		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext()) {
			result.push(TagBuilder.build(i.next()));
		}

		return result;
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
	 * @private
	 */
	override public function addComment(text:String):IToken {
		return ASTMXMLBuilder.newXMLComment(node, text);
	}

	/**
	 * @private
	 */
	override public function newXMLNS(localName:String, uri:String):IXMLNamespace {
		var list:IParserNode = findOrCreateAttList();
		var ast:IParserNode = ASTMXMLBuilder.newXMLNS(localName, uri);
		list.addChild(ast);
		return new XMLNamespaceNode(ast);
	}

	/**
	 * @private
	 */
	override public function newAttribute(name:String, value:String, state:String = null):IAttribute {
		var list:IParserNode = findOrCreateAttList();
		var ast:IParserNode = ASTMXMLBuilder.newAttribute(name, value, state);
		list.addChild(ast);
		return new AttributeNode(ast);
	}

	/**
	 * @private
	 */
	override public function newTag(name:String, binding:String = null):IBlockTag {
		var ast:IParserNode = ASTMXMLBuilder.newTag(name, binding);
		addTag(ast);
		return new TagList(ast);
	}

	/**
	 * @private
	 */
	override public function newScriptTag(code:String = null):IScriptTag {
		var ast:IParserNode = ASTMXMLBuilder.newScriptTag(code);
		addTag(ast);
		return new ScriptTagNode(ast);
	}

	/**
	 * @private
	 */
	override public function newMetadataTag(code:String = null):IMetadataTag {
		var ast:IParserNode = ASTMXMLBuilder.newMetadataTag(code);
		addTag(ast);
		return new MetadataTagNode(ast);
	}

	/**
	 * @private
	 */
	private function addTag(ast:IParserNode):Void {
		var body:IParserNode = node.getLastChild();
		ASTUtil.addChildWithIndentation(body, ast);
	}

	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function findAttListInsertion():Int {
		var index:Int = 0;
		if (findLocalName() != null) {
			index++;
		}
		if (findBinding() != null) {
			index++;
		}
		return index;
	}

	/**
	 * @private
	 */
	private function findBinding():IParserNode {
		return node.getKind(MXMLNodeKind.BINDING);
	}

	/**
	 * @private
	 */
	private function findLocalName():IParserNode {
		return node.getKind(MXMLNodeKind.LOCAL_NAME);
	}

	/**
	 * @private
	 */
	private function findAttList():IParserNode {
		return node.getKind(MXMLNodeKind.ATT_LIST);
	}

	/**
	 * @private
	 */
	private function findOrCreateAttList():IParserNode {
		var ast:IParserNode = findAttList();
		if (ast == null) {
			ast = ASTBuilder.newAST(MXMLNodeKind.ATT_LIST);
			node.addChildAt(ast, findAttListInsertion());
		}
		return ast;
	}

	/**
	 * @private
	 */
	private function findBody():IParserNode {
		return node.getKind(MXMLNodeKind.BODY);
	}

}