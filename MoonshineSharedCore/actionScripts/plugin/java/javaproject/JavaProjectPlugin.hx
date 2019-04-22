////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.java.javaproject;

import flash.events.Event;
import actionScripts.events.MavenBuildEvent;
import actionScripts.events.NewProjectEvent;
import actionScripts.events.RunJavaProjectEvent;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.build.MavenBuildStatus;
import actionScripts.plugin.core.compiler.JavaBuildEvent;
import actionScripts.plugin.core.compiler.ProjectActionEvent;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.project.ProjectTemplateType;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;

class JavaProjectPlugin extends PluginBase {

	override private function get_name():String {
		return 'Java Project Plugin';
	}

	override private function get_author():String {
		return ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team';
	}

	override private function get_description():String {
		return 'Java project importing, exporting & scaffolding.';
	}

	override public function activate():Void {
		dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
		dispatcher.addEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
		dispatcher.addEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
		dispatcher.addEventListener(ProjectActionEvent.SET_DEFAULT_APPLICATION, setDefaultApplicationHandler);
		dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);

		super.activate();
	}

	override public function deactivate():Void {
		dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
		dispatcher.removeEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
		dispatcher.removeEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
		dispatcher.removeEventListener(ProjectActionEvent.SET_DEFAULT_APPLICATION, setDefaultApplicationHandler);
		dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);

		super.deactivate();
	}

	private function createNewProjectHandler(event:NewProjectEvent):Void {
		if (!canCreateProject(event)) {
			return;
		}

		model.javaCore.createProject(event);
	}

	private function javaBuildHandler(event:Event):Void {
		var javaProject:JavaProjectVO = AS3.as(model.activeProject, JavaProjectVO);
		if (javaProject != null && javaProject.hasGradleBuild()) {
			warning('Project build is currently managed by build.gradle only.');
			return;
		}

		dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
	}

	private function buildAndRunHandler(event:Event):Void {
		var javaProject:JavaProjectVO = AS3.as(model.activeProject, JavaProjectVO);
		if (javaProject != null) {
			if (javaProject.hasGradleBuild()) {
				warning('Project build is currently managed by build.gradle only.');
				return;
			}

			if (javaProject.mainClassName == null) {
				warning('Select main application class');
			} else {
				dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD, model.activeProject.projectName,
						MavenBuildStatus.STARTED, Std.string(javaProject.folderLocation.fileBridge.nativePath), null, javaProject.mavenBuildOptions.getCommandLine()));
			}
		}
	}

	private function mavenBuildCompleteHandler(event:MavenBuildEvent):Void {
		var project:JavaProjectVO = AS3.as(UtilsCore.getProjectByName(event.buildId), JavaProjectVO);
		if (project != null && project.projectName == event.buildId) {
			dispatcher.dispatchEvent(new RunJavaProjectEvent(RunJavaProjectEvent.RUN_JAVA_PROJECT, project));
		}
	}

	private function setDefaultApplicationHandler(event:ProjectActionEvent):Void {
		var javaProject:JavaProjectVO = AS3.as(model.activeProject, JavaProjectVO);
		if (javaProject != null) {
			var nameWithoutExtension:String = Std.string(event.defaultApplicationFile.fileBridge.nameWithoutExtension);
			if (javaProject.mainClassName != nameWithoutExtension) {
				javaProject.mainClassName = nameWithoutExtension;
				javaProject.saveSettings();
			}
		}
	}

	private function canCreateProject(event:NewProjectEvent):Bool {
		var projectTemplateName:String = Std.string(event.templateDir.fileBridge.name);
		return projectTemplateName.indexOf(ProjectTemplateType.JAVA) != -1;
	}

	public function new() {
		super();
	}

}