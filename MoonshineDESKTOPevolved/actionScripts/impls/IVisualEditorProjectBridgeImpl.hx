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

import actionScripts.interfaces.IVisualEditorBridge;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.visualEditor.VisualEditorProjectPlugin;
import actionScripts.plugins.core.ProjectBridgeImplBase;
import actionScripts.plugins.ui.editor.VisualEditorViewer;
import actionScripts.ui.editor.BasicTextEditor;

class IVisualEditorProjectBridgeImpl extends ProjectBridgeImplBase implements IVisualEditorBridge {

	public function new() {
		super();
	}

	public function getVisualEditor(visualEditorProject:AS3ProjectVO):BasicTextEditor {
		return new VisualEditorViewer(visualEditorProject);
	}

	public function getCorePlugins():Array<Dynamic> {
		return [];
	}

	public function getDefaultPlugins():Array<Dynamic> {
		return cast [
		VisualEditorProjectPlugin
	];
	}

	public function getPluginsNotToShowInSettings():Array<Dynamic> {
		return [];
	}

	public var runtimeVersion(get, never):String;
	private function get_runtimeVersion():String {
		return '';
	}

	public var version(get, never):String;
	private function get_version():String {
		return '';
	}

}