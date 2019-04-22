////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.interfaces;

import haxe.Constraints.Function;
import actionScripts.events.NewProjectEvent;
import actionScripts.valueObjects.FileWrapper;

interface IProject {

	function createProject(event:NewProjectEvent):Void;

	/**
	 *
	 * @param projectWrapper
	 * @param finishHandler - handler must return FileWrapper object
	 */
	function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Bool = false):Void;

	function getCorePlugins():Array<Dynamic>;

	function getDefaultPlugins():Array<Dynamic>;

	function getPluginsNotToShowInSettings():Array<Dynamic>;

	var runtimeVersion(get, never):String;
	var version(get, never):String;

}