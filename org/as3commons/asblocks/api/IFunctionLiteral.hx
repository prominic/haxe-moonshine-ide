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

package org.as3commons.asblocks.api;

/**
 * A Function literal; <code>var f:Function = function():void{trace'hello')};</code>.
 *
 * <pre>
 * var fl:IFunctionLiteral = factory.newFunctionLiteral()
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * function():void {
 * }
 * </pre>
 *
 * <pre>
 * var fl:IFunctionLiteral = factory.newFunctionLiteral()
 * fl.returnType = "int";
 * fl.addParameter("arg0", "String");
 * fl.addStatement("trace('Hello World')");
 * </pre>
 *
 * <p>Will produce;</p>
 * <pre>
 * function(arg0:String):int {
 * 	trace('Hello World');
 * }
 * </pre>
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 *
 * @see org.as3commons.asblocks.ASFactory#newFunctionLiteral()
 */
interface IFunctionLiteral extends IExpression extends IFunction extends IScriptNode extends IStatementContainer {

}