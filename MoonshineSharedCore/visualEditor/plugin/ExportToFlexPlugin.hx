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
package visualEditor.plugin;

import flash.events.Event;
import actionScripts.events.ExportVisualEditorProjectEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;

class ExportToFlexPlugin extends PluginBase {

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Export Visual Editor Project to Flex Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Exports Visual Editor project to Flex (Adobe Air Desktop).';
	}

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(
				ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
				initExportVisualEditorProjectToFlexHandler
		);
	}

	override public function deactivate():Void {
		super.deactivate();
	}

	private function initExportVisualEditorProjectToFlexHandler(event:Event):Void {
		var currentActiveProject:AS3ProjectVO = AS3.as(model.activeProject, AS3ProjectVO);
		if (currentActiveProject == null || currentActiveProject.isPrimeFacesVisualEditorProject) {
			error('This is not Visual Editor Flex project');
			return;
		}

		UtilsCore.closeAllRelativeEditors(model.activeProject, false,
				function():Void {
					dispatcher.dispatchEvent(
							new ExportVisualEditorProjectEvent(
							ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
							currentActiveProject)
				);
				}, false
		);
	}

}