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
package actionScripts.plugin.visualEditor;

import actionScripts.events.NewProjectEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.project.ProjectTemplateType;
import actionScripts.valueObjects.ConstantsCoreVO;

class VisualEditorProjectPlugin extends PluginBase {

	override private function get_name():String {
		return 'Visual Editor Project';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Visual Editor project is aim to start create your application visually.';
	}

	public function new() {
		super();
	}

	override public function activate():Void {
		dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, visualEditorCreateNewProjectHandler);
		super.activate();
	}

	override public function deactivate():Void {
		dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, visualEditorCreateNewProjectHandler);
		super.deactivate();
	}

	private function visualEditorCreateNewProjectHandler(event:NewProjectEvent):Void {
		if (!canCreateProject(event)) {
			return;
		}

		model.visualEditorCore.createProject(event);
	}

	private function canCreateProject(event:NewProjectEvent):Bool {
		var projectTemplateName:String = Std.string(event.templateDir.fileBridge.name);
		return projectTemplateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) > -1;
	}

}