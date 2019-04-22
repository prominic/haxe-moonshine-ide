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
import org.as3commons.asblocks.api.IExpression;
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
import org.as3commons.asblocks.api.IStatementContainer;
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
class ASBlocksWalker implements IASBlockVisitor {

	private var strategy:IScriptNodeStrategy;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(strategy:FilterStrategy) {
		this.strategy = strategy;
		strategy.filtered = new ScriptNodeSwitch(this);
	}

	public function visitArgument(element:IArgument):Void {}

	public function visitArrayAccessExpression(element:IArrayAccessExpression):Void {
		walk(element.target);
		walk(element.subscript);
	}

	public function visitArrayLiteral(element:IArrayLiteral):Void {
		walkElements(try cast(element.entries, Vector) catch(e:Dynamic) null);
	}

	private function walk(object:Dynamic):Void {
		if (Std.is(object, Vector)) {
			walkElements(try cast(object, Vector) catch(e:Dynamic) null);
		} else {
			walkElement(AS3.as(object, IScriptNode));
		}
	}

	public function walkStatementContainer(element:IStatementContainer):Void {
		walk(element.statements);
	}

	private function walkElements(list:Array<IScriptNode>):Void {
		var len:Int = list.length;
		for (i in 0...len) {
			var element:IExpression = AS3.as(list[i], IExpression);
			walk(element);
		}
	}

	public function walkElement(element:IScriptNode):Void {
		strategy.handle(element);
	}

	public function visitAssignmentExpression(element:IAssignmentExpression):Void {
		walk(element.leftExpression);
		walk(element.rightExpression);
	}

	public function visitBinaryExpression(element:IBinaryExpression):Void {
		walk(element.leftExpression);
		walk(element.rightExpression);
	}

	public function visitBlockStatement(element:IBlock):Void {
		walkStatementContainer(element);
	}

	public function visitBooleanLiteral(element:IBooleanLiteral):Void {}

	public function visitBreakStatement(element:IBreakStatement):Void {}

	public function visitCatchClause(element:ICatchClause):Void {
		walkStatementContainer(element);
	}

	public function visitClassType(element:IClassType):Void {
		walk(element.metaDatas);
		walk(element.fields);
		walk(element.methods);
	}

	public function visitCompilationUnit(element:ICompilationUnit):Void {
		walk(element.packageNode);
	}

	public function visitConditionalExpression(element:IConditionalExpression):Void {
		walk(element.condition);
		walk(element.thenExpression);
		walk(element.elseExpression);
	}

	public function visitContinueStatement(element:IContinueStatement):Void {}

	public function visitDeclarationStatement(element:IDeclarationStatement):Void {
		walk(element.declarations);
	}

	public function visitDefaultXMLNamespaceStatement(element:IDefaultXMLNamespaceStatement):Void {}

	public function visitDoWhileStatement(element:IDoWhileStatement):Void {
		walk(element.condition);
		walkStatementContainer(element);
	}

	public function visitExpressionStatement(element:IExpressionStatement):Void {
		walk(element.expression);
	}

	public function visitField(element:IField):Void {
		walk(element.metaDatas);
	}

	public function visitFieldAccessExpression(element:IFieldAccessExpression):Void {
		walk(element.target);
	}

	public function visitFinallyClause(element:IFinallyClause):Void {
		walkStatementContainer(element);
	}

	public function visitForEachInStatement(element:IForEachInStatement):Void {
		walk(element.initializer);
		walk(element.iterated);
		walkStatementContainer(element);
	}

	public function visitForInStatement(element:IForInStatement):Void {
		walk(element.initializer);
		walk(element.iterated);
		walkStatementContainer(element);
	}

	public function visitForStatement(element:IForStatement):Void {
		var init:IScriptNode = element.initializer;
		if (init != null) {
			walk(element.initializer);
		}
		var cond:IScriptNode = element.condition;
		if (cond != null) {
			walk(element.condition);
		}
		var iter:IScriptNode = element.iterator;
		if (iter != null) {
			walk(element.iterator);
		}
		walkStatementContainer(element);
	}

	public function visitFunctionLiteral(element:IFunctionLiteral):Void {
		walk(element.parameters);
		walkStatementContainer(element);
	}

	public function visitIfStatement(element:IIfStatement):Void {
		walk(element.condition);
		walk(element.thenBlock);
		var block:IScriptNode = element.elseBlock;
		if (block != null) {
			walk(element.elseBlock);
		}
	}

	public function visitNumberLiteral(element:INumberLiteral):Void {}

	public function visitInterfaceType(element:IInterfaceType):Void {
		walk(element.metaDatas);
		walk(element.methods);
	}

	public function visitInvocationExpression(element:IINvocationExpression):Void {
		walk(element.target);
		walk(element.arguments);
	}

	public function visitMetaData(element:IMetaData):Void {}

	public function visitMethod(element:IMethod):Void {
		walk(element.metaDatas);
		walk(element.parameters);
		walkStatementContainer(element);
	}

	public function visitNewExpression(element:INewExpression):Void {
		walk(element.target);
		walk(element.arguments);
	}

	public function visitNullLiteral(element:INullLiteral):Void {}

	public function visitObjectField(element:IPropertyField):Void {
		walk(element.value);
	}

	public function visitObjectLiteral(element:IObjectLiteral):Void {
		walk(element.fields);
	}

	public function visitPackage(element:IPackage):Void {
		walk(element.typeNode);
	}

	public function visitParameter(element:IParameter):Void {}

	public function visitPostfixExpression(element:IPostfixExpression):Void {
		walk(element.expression);
	}

	public function visitPrefixExpression(element:IPrefixExpression):Void {
		walk(element.expression);
	}

	public function visitReturnStatement(element:IReturnStatement):Void {
		var expression:IExpression = element.expression;
		if (expression != null) {
			walk(expression);
		}
	}

	public function visitSimpleNameExpression(element:ISimpleNameExpression):Void {}

	public function visitStringLiteral(element:IStringLiteral):Void {}

	public function visitSuperStatement(element:ISuperStatement):Void {
		walk(element.arguments);
	}

	public function visitSwitchCase(element:ISwitchCase):Void {
		walk(element.label);
		walkStatementContainer(element);
	}

	public function visitSwitchDefault(element:ISwitchDefault):Void {
		walkStatementContainer(element);
	}

	public function visitSwitchStatement(element:ISwitchStatement):Void {
		walk(element.condition);
		walk(element.labels);
	}

	public function visitThisStatement(element:IThisStatement):Void {}

	public function visitThrowStatement(element:IThrowStatement):Void {
		walk(element.expression);
	}

	public function visitTryStatement(element:ITryStatement):Void {
		walkStatementContainer(element);
		var catches:Array<ICatchClause> = cast element.catchClauses;
		if (catches.length > 0) {
			walk(catches);
		}
		var fclause:IFinallyClause = element.finallyClause;
		if (fclause != null) {
			walk(fclause);
		}
	}

	public function visitUndefinedLiteral(element:IUndefinedLiteral):Void {}

	public function visitVarDeclarationFragment(element:IDeclaration):Void {
		walk(element.initializer);
	}

	public function visitWhileStatement(element:IWhileStatement):Void {
		walk(element.condition);
		walk(element.body);
	}

	public function visitWithStatement(element:IWithStatement):Void {
		walk(element.scope);
		walk(element.body);
	}

}