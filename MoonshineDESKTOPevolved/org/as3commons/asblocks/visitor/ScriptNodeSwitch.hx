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

package org.as3commons.asblocks.visitor;

import flash.errors.IllegalOperationError;
import org.as3commons.asblocks.IASBlockVisitor;
import org.as3commons.asblocks.api.IArgument;
import org.as3commons.asblocks.api.IArrayAccessExpression;
import org.as3commons.asblocks.api.IArrayLiteral;
import org.as3commons.asblocks.api.IAssignmentExpression;
import org.as3commons.asblocks.api.IBinaryExpression;
import org.as3commons.asblocks.api.IBlock;
import org.as3commons.asblocks.api.IBooleanLiteral;
import org.as3commons.asblocks.api.IBreakStatement;
import org.as3commons.asblocks.api.ICatchClause;
import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IConditionalExpression;
import org.as3commons.asblocks.api.IContinueStatement;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IDefaultXMLNamespaceStatement;
import org.as3commons.asblocks.api.IDoWhileStatement;
import org.as3commons.asblocks.api.IExpressionStatement;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IFieldAccessExpression;
import org.as3commons.asblocks.api.IFinallyClause;
import org.as3commons.asblocks.api.IForEachInStatement;
import org.as3commons.asblocks.api.IForInStatement;
import org.as3commons.asblocks.api.IForStatement;
import org.as3commons.asblocks.api.IFunctionLiteral;
import org.as3commons.asblocks.api.IINvocationExpression;
import org.as3commons.asblocks.api.IIfStatement;
import org.as3commons.asblocks.api.IInterfaceType;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.INewExpression;
import org.as3commons.asblocks.api.INullLiteral;
import org.as3commons.asblocks.api.INumberLiteral;
import org.as3commons.asblocks.api.IObjectLiteral;
import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IParameter;
import org.as3commons.asblocks.api.IPostfixExpression;
import org.as3commons.asblocks.api.IPrefixExpression;
import org.as3commons.asblocks.api.IPropertyField;
import org.as3commons.asblocks.api.IReturnStatement;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.api.ISimpleNameExpression;
import org.as3commons.asblocks.api.IStringLiteral;
import org.as3commons.asblocks.api.ISuperStatement;
import org.as3commons.asblocks.api.ISwitchCase;
import org.as3commons.asblocks.api.ISwitchDefault;
import org.as3commons.asblocks.api.ISwitchStatement;
import org.as3commons.asblocks.api.IThisStatement;
import org.as3commons.asblocks.api.IThrowStatement;
import org.as3commons.asblocks.api.ITryStatement;
import org.as3commons.asblocks.api.IUndefinedLiteral;
import org.as3commons.asblocks.api.IDeclaration;
import org.as3commons.asblocks.api.IWhileStatement;
import org.as3commons.asblocks.api.IWithStatement;

/**
 * A <code>ScriptNode</code> switch handler that calls
 * <code>IASBlockVisitor</code> methods.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.IASBlockVisitor
 */
class ScriptNodeSwitch implements IScriptNodeStrategy {

	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var visitor:IASBlockVisitor;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(visitor:IASBlockVisitor) {
		this.visitor = visitor;
	}

	//--------------------------------------------------------------------------
	//
	//  IScriptNodeStrategy API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @throws IllegalOperationError unhandled ScriptNode
	 */
	public function handle(element:IScriptNode):Void {
		if (Std.is(element, IArgument)) {
			visitor.visitArgument(IArgument(element));
		} else if (Std.is(element, IArrayAccessExpression)) {
			visitor.visitArrayAccessExpression(IArrayAccessExpression(element));
		} else if (Std.is(element, IArrayLiteral)) {
			visitor.visitArrayLiteral(IArrayLiteral(element));
		} else if (Std.is(element, IAssignmentExpression)) {
			visitor.visitAssignmentExpression(IAssignmentExpression(element));
		} else if (Std.is(element, IBinaryExpression)) {
			visitor.visitBinaryExpression(IBinaryExpression(element));
		} else if (Std.is(element, IBlock)) {
			visitor.visitBlockStatement(IBlock(element));
		} else if (Std.is(element, IBooleanLiteral)) {
			visitor.visitBooleanLiteral(IBooleanLiteral(element));
		} else if (Std.is(element, IBreakStatement)) {
			visitor.visitBreakStatement(IBreakStatement(element));
		} else if (Std.is(element, ICatchClause)) {
			visitor.visitCatchClause(ICatchClause(element));
		} else if (Std.is(element, IClassType)) {
			visitor.visitClassType(IClassType(element));
		} else if (Std.is(element, ICompilationUnit)) {
			visitor.visitCompilationUnit(ICompilationUnit(element));
		} else if (Std.is(element, IConditionalExpression)) {
			visitor.visitConditionalExpression(IConditionalExpression(element));
		} else if (Std.is(element, IContinueStatement)) {
			visitor.visitContinueStatement(IContinueStatement(element));
		} else if (Std.is(element, IDeclarationStatement)) {
			visitor.visitDeclarationStatement(IDeclarationStatement(element));
		} else if (Std.is(element, IDefaultXMLNamespaceStatement)) {
			visitor.visitDefaultXMLNamespaceStatement(IDefaultXMLNamespaceStatement(element));
		} else if (Std.is(element, IDoWhileStatement)) {
			visitor.visitDoWhileStatement(IDoWhileStatement(element));
		} else if (Std.is(element, IExpressionStatement)) {
			visitor.visitExpressionStatement(IExpressionStatement(element));
		} else if (Std.is(element, IField)) {
			visitor.visitField(IField(element));
		} else if (Std.is(element, IFieldAccessExpression)) {
			visitor.visitFieldAccessExpression(IFieldAccessExpression(element));
		} else if (Std.is(element, IFinallyClause)) {
			visitor.visitFinallyClause(IFinallyClause(element));
		} else if (Std.is(element, IForEachInStatement)) {
			visitor.visitForEachInStatement(IForEachInStatement(element));
		} else if (Std.is(element, IForInStatement)) {
			visitor.visitForInStatement(IForInStatement(element));
		} else if (Std.is(element, IForStatement)) {
			visitor.visitForStatement(IForStatement(element));
		} else if (Std.is(element, IFunctionLiteral)) {
			visitor.visitFunctionLiteral(IFunctionLiteral(element));
		} else if (Std.is(element, IIfStatement)) {
			visitor.visitIfStatement(IIfStatement(element));
		} else if (Std.is(element, INumberLiteral)) {
			visitor.visitNumberLiteral(INumberLiteral(element));
		} else if (Std.is(element, IInterfaceType)) {
			visitor.visitInterfaceType(IInterfaceType(element));
		} else if (Std.is(element, IINvocationExpression)) {
			visitor.visitInvocationExpression(IINvocationExpression(element));
		} else if (Std.is(element, IMetaData)) {
			visitor.visitMetaData(IMetaData(element));
		} else if (Std.is(element, IMethod)) {
			visitor.visitMethod(IMethod(element));
		} else if (Std.is(element, INewExpression)) {
			visitor.visitNewExpression(INewExpression(element));
		} else if (Std.is(element, INullLiteral)) {
			visitor.visitNullLiteral(INullLiteral(element));
		} else if (Std.is(element, IPropertyField)) {
			visitor.visitObjectField(IPropertyField(element));
		} else if (Std.is(element, IObjectLiteral)) {
			visitor.visitObjectLiteral(IObjectLiteral(element));
		} else if (Std.is(element, IPackage)) {
			visitor.visitPackage(IPackage(element));
		} else if (Std.is(element, IParameter)) {
			visitor.visitParameter(IParameter(element));
		} else if (Std.is(element, IPostfixExpression)) {
			visitor.visitPostfixExpression(IPostfixExpression(element));
		} else if (Std.is(element, IPrefixExpression)) {
			visitor.visitPrefixExpression(IPrefixExpression(element));
		} else if (Std.is(element, IReturnStatement)) {
			visitor.visitReturnStatement(IReturnStatement(element));
		} else if (Std.is(element, ISimpleNameExpression)) {
			visitor.visitSimpleNameExpression(ISimpleNameExpression(element));
		} else if (Std.is(element, IStringLiteral)) {
			visitor.visitStringLiteral(IStringLiteral(element));
		} else if (Std.is(element, ISuperStatement)) {
			visitor.visitSuperStatement(ISuperStatement(element));
		} else if (Std.is(element, ISwitchCase)) {
			visitor.visitSwitchCase(ISwitchCase(element));
		} else if (Std.is(element, ISwitchDefault)) {
			visitor.visitSwitchDefault(ISwitchDefault(element));
		} else if (Std.is(element, ISwitchStatement)) {
			visitor.visitSwitchStatement(ISwitchStatement(element));
		} else if (Std.is(element, IThisStatement)) {
			visitor.visitThisStatement(IThisStatement(element));
		} else if (Std.is(element, IThrowStatement)) {
			visitor.visitThrowStatement(IThrowStatement(element));
		} else if (Std.is(element, ITryStatement)) {
			visitor.visitTryStatement(ITryStatement(element));
		} else if (Std.is(element, IUndefinedLiteral)) {
			visitor.visitUndefinedLiteral(IUndefinedLiteral(element));
		} else if (Std.is(element, IDeclaration)) {
			visitor.visitVarDeclarationFragment(IDeclaration(element));
		} else if (Std.is(element, IWhileStatement)) {
			visitor.visitWhileStatement(IWhileStatement(element));
		} else if (Std.is(element, IWithStatement)) {
			visitor.visitWithStatement(IWithStatement(element));
		} else {
			var className:String = Type.getClassName(Type.getClass(element));
			throw new IllegalOperationError('unhandled ScriptNode ' + className);
		}
	}

}