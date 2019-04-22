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
import org.as3commons.asblocks.api.IDeclaration;
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
import org.as3commons.asblocks.api.IWhileStatement;
import org.as3commons.asblocks.api.IWithStatement;

/**
 * A default null visitor implementation that can be subclassed.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class NullASBlockVisitor implements IASBlockVisitor {

	public function new() {}

	public function visitArgument(element:IArgument):Void {}

	public function visitArrayAccessExpression(element:IArrayAccessExpression):Void {}

	public function visitArrayLiteral(element:IArrayLiteral):Void {}

	public function visitAssignmentExpression(element:IAssignmentExpression):Void {}

	public function visitBinaryExpression(element:IBinaryExpression):Void {}

	public function visitBlockStatement(element:IBlock):Void {}

	public function visitBooleanLiteral(element:IBooleanLiteral):Void {}

	public function visitBreakStatement(element:IBreakStatement):Void {}

	public function visitCatchClause(element:ICatchClause):Void {}

	public function visitClassType(element:IClassType):Void {}

	public function visitCompilationUnit(element:ICompilationUnit):Void {}

	public function visitConditionalExpression(element:IConditionalExpression):Void {}

	public function visitContinueStatement(element:IContinueStatement):Void {}

	public function visitDeclarationStatement(element:IDeclarationStatement):Void {}

	public function visitDefaultXMLNamespaceStatement(element:IDefaultXMLNamespaceStatement):Void {}

	public function visitDoWhileStatement(element:IDoWhileStatement):Void {}

	public function visitExpressionStatement(element:IExpressionStatement):Void {}

	public function visitField(element:IField):Void {}

	public function visitFieldAccessExpression(element:IFieldAccessExpression):Void {}

	public function visitFinallyClause(element:IFinallyClause):Void {}

	public function visitForEachInStatement(element:IForEachInStatement):Void {}

	public function visitForInStatement(element:IForInStatement):Void {}

	public function visitForStatement(element:IForStatement):Void {}

	public function visitFunctionLiteral(element:IFunctionLiteral):Void {}

	public function visitIfStatement(element:IIfStatement):Void {}

	public function visitNumberLiteral(element:INumberLiteral):Void {}

	public function visitInterfaceType(element:IInterfaceType):Void {}

	public function visitInvocationExpression(element:IINvocationExpression):Void {}

	public function visitMetaData(element:IMetaData):Void {}

	public function visitMethod(element:IMethod):Void {}

	public function visitNewExpression(element:INewExpression):Void {}

	public function visitNullLiteral(element:INullLiteral):Void {}

	public function visitObjectField(element:IPropertyField):Void {}

	public function visitObjectLiteral(element:IObjectLiteral):Void {}

	public function visitPackage(element:IPackage):Void {}

	public function visitParameter(element:IParameter):Void {}

	public function visitPostfixExpression(element:IPostfixExpression):Void {}

	public function visitPrefixExpression(element:IPrefixExpression):Void {}

	public function visitReturnStatement(element:IReturnStatement):Void {}

	public function visitSimpleNameExpression(element:ISimpleNameExpression):Void {}

	public function visitStringLiteral(element:IStringLiteral):Void {}

	public function visitSuperStatement(element:ISuperStatement):Void {}

	public function visitSwitchCase(element:ISwitchCase):Void {}

	public function visitSwitchDefault(element:ISwitchDefault):Void {}

	public function visitSwitchStatement(element:ISwitchStatement):Void {}

	public function visitThisStatement(element:IThisStatement):Void {}

	public function visitThrowStatement(element:IThrowStatement):Void {}

	public function visitTryStatement(element:ITryStatement):Void {}

	public function visitUndefinedLiteral(element:IUndefinedLiteral):Void {}

	public function visitVarDeclarationFragment(element:IDeclaration):Void {}

	public function visitWhileStatement(element:IWhileStatement):Void {}

	public function visitWithStatement(element:IWithStatement):Void {}

}