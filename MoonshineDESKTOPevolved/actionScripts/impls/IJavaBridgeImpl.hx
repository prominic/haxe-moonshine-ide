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
package actionScripts.impls;

import actionScripts.interfaces.IJavaBridge;
import actionScripts.plugin.java.javaproject.JavaProjectPlugin;
import actionScripts.plugins.core.ProjectBridgeImplBase;
import actionScripts.plugin.syntax.JavaSyntaxPlugin;
import actionScripts.events.NewProjectEvent;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.java.javaproject.CreateJavaProject;
import actionScripts.factory.FileLocation;
import flash.filesystem.File;
import actionScripts.plugin.java.javaproject.importer.JavaImporter;

class IJavaBridgeImpl extends ProjectBridgeImplBase implements IJavaBridge {

	public function new() {
		super();
	}

	public function getCorePlugins():Array<Dynamic> {
		return [];
	}

	public function getDefaultPlugins():Array<Dynamic> {
		return cast [
		JavaSyntaxPlugin,
		JavaProjectPlugin
	];
	}

	public function getPluginsNotToShowInSettings():Array<Dynamic> {
		return cast [
		JavaProjectPlugin
	];
	}

	public var runtimeVersion(get, never):String;
	private function get_runtimeVersion():String {
		return '';
	}

	public var version(get, never):String;
	private function get_version():String {
		return '';
	}

	private var executeCreateJavaProject:CreateJavaProject;

	override public function createProject(event:NewProjectEvent):Void {
		executeCreateJavaProject = new CreateJavaProject(event);
	}

	public function testJava(file:Dynamic):FileLocation {
		return JavaImporter.test(AS3.as(file, File));
	}

	public function parseJava(file:FileLocation):JavaProjectVO {
		return JavaImporter.parse(file);
	}

}