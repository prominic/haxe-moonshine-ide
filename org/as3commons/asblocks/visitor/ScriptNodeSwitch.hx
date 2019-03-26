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
			visitor.visitArgument(cast((element), IArgument));
		} else if (Std.is(element, IArrayAccessExpression)) {
			visitor.visitArrayAccessExpression(cast((element), IArrayAccessExpression));
		} else if (Std.is(element, IArrayLiteral)) {
			visitor.visitArrayLiteral(cast((element), IArrayLiteral));
		} else if (Std.is(element, IAssignmentExpression)) {
			visitor.visitAssignmentExpression(cast((element), IAssignmentExpression));
		} else if (Std.is(element, IBinaryExpression)) {
			visitor.visitBinaryExpression(cast((element), IBinaryExpression));
		} else if (Std.is(element, IBlock)) {
			visitor.visitBlockStatement(cast((element), IBlock));
		} else if (Std.is(element, IBooleanLiteral)) {
			visitor.visitBooleanLiteral(cast((element), IBooleanLiteral));
		} else if (Std.is(element, IBreakStatement)) {
			visitor.visitBreakStatement(cast((element), IBreakStatement));
		} else if (Std.is(element, ICatchClause)) {
			visitor.visitCatchClause(cast((element), ICatchClause));
		} else if (Std.is(element, IClassType)) {
			visitor.visitClassType(cast((element), IClassType));
		} else if (Std.is(element, ICompilationUnit)) {
			visitor.visitCompilationUnit(cast((element), ICompilationUnit));
		} else if (Std.is(element, IConditionalExpression)) {
			visitor.visitConditionalExpression(cast((element), IConditionalExpression));
		} else if (Std.is(element, IContinueStatement)) {
			visitor.visitContinueStatement(cast((element), IContinueStatement));
		} else if (Std.is(element, IDeclarationStatement)) {
			visitor.visitDeclarationStatement(cast((element), IDeclarationStatement));
		} else if (Std.is(element, IDefaultXMLNamespaceStatement)) {
			visitor.visitDefaultXMLNamespaceStatement(cast((element), IDefaultXMLNamespaceStatement));
		} else if (Std.is(element, IDoWhileStatement)) {
			visitor.visitDoWhileStatement(cast((element), IDoWhileStatement));
		} else if (Std.is(element, IExpressionStatement)) {
			visitor.visitExpressionStatement(cast((element), IExpressionStatement));
		} else if (Std.is(element, IField)) {
			visitor.visitField(cast((element), IField));
		} else if (Std.is(element, IFieldAccessExpression)) {
			visitor.visitFieldAccessExpression(cast((element), IFieldAccessExpression));
		} else if (Std.is(element, IFinallyClause)) {
			visitor.visitFinallyClause(cast((element), IFinallyClause));
		} else if (Std.is(element, IForEachInStatement)) {
			visitor.visitForEachInStatement(cast((element), IForEachInStatement));
		} else if (Std.is(element, IForInStatement)) {
			visitor.visitForInStatement(cast((element), IForInStatement));
		} else if (Std.is(element, IForStatement)) {
			visitor.visitForStatement(cast((element), IForStatement));
		} else if (Std.is(element, IFunctionLiteral)) {
			visitor.visitFunctionLiteral(cast((element), IFunctionLiteral));
		} else if (Std.is(element, IIfStatement)) {
			visitor.visitIfStatement(cast((element), IIfStatement));
		} else if (Std.is(element, INumberLiteral)) {
			visitor.visitNumberLiteral(cast((element), INumberLiteral));
		} else if (Std.is(element, IInterfaceType)) {
			visitor.visitInterfaceType(cast((element), IInterfaceType));
		} else if (Std.is(element, IINvocationExpression)) {
			visitor.visitInvocationExpression(cast((element), IINvocationExpression));
		} else if (Std.is(element, IMetaData)) {
			visitor.visitMetaData(cast((element), IMetaData));
		} else if (Std.is(element, IMethod)) {
			visitor.visitMethod(cast((element), IMethod));
		} else if (Std.is(element, INewExpression)) {
			visitor.visitNewExpression(cast((element), INewExpression));
		} else if (Std.is(element, INullLiteral)) {
			visitor.visitNullLiteral(cast((element), INullLiteral));
		} else if (Std.is(element, IPropertyField)) {
			visitor.visitObjectField(cast((element), IPropertyField));
		} else if (Std.is(element, IObjectLiteral)) {
			visitor.visitObjectLiteral(cast((element), IObjectLiteral));
		} else if (Std.is(element, IPackage)) {
			visitor.visitPackage(cast((element), IPackage));
		} else if (Std.is(element, IParameter)) {
			visitor.visitParameter(cast((element), IParameter));
		} else if (Std.is(element, IPostfixExpression)) {
			visitor.visitPostfixExpression(cast((element), IPostfixExpression));
		} else if (Std.is(element, IPrefixExpression)) {
			visitor.visitPrefixExpression(cast((element), IPrefixExpression));
		} else if (Std.is(element, IReturnStatement)) {
			visitor.visitReturnStatement(cast((element), IReturnStatement));
		} else if (Std.is(element, ISimpleNameExpression)) {
			visitor.visitSimpleNameExpression(cast((element), ISimpleNameExpression));
		} else if (Std.is(element, IStringLiteral)) {
			visitor.visitStringLiteral(cast((element), IStringLiteral));
		} else if (Std.is(element, ISuperStatement)) {
			visitor.visitSuperStatement(cast((element), ISuperStatement));
		} else if (Std.is(element, ISwitchCase)) {
			visitor.visitSwitchCase(cast((element), ISwitchCase));
		} else if (Std.is(element, ISwitchDefault)) {
			visitor.visitSwitchDefault(cast((element), ISwitchDefault));
		} else if (Std.is(element, ISwitchStatement)) {
			visitor.visitSwitchStatement(cast((element), ISwitchStatement));
		} else if (Std.is(element, IThisStatement)) {
			visitor.visitThisStatement(cast((element), IThisStatement));
		} else if (Std.is(element, IThrowStatement)) {
			visitor.visitThrowStatement(cast((element), IThrowStatement));
		} else if (Std.is(element, ITryStatement)) {
			visitor.visitTryStatement(cast((element), ITryStatement));
		} else if (Std.is(element, IUndefinedLiteral)) {
			visitor.visitUndefinedLiteral(cast((element), IUndefinedLiteral));
		} else if (Std.is(element, IDeclaration)) {
			visitor.visitVarDeclarationFragment(cast((element), IDeclaration));
		} else if (Std.is(element, IWhileStatement)) {
			visitor.visitWhileStatement(cast((element), IWhileStatement));
		} else if (Std.is(element, IWithStatement)) {
			visitor.visitWithStatement(cast((element), IWithStatement));
		} else {
			var className:String = Type.getClassName(element);
			throw new IllegalOperationError('unhandled ScriptNode ' + className);
		}
	}

}