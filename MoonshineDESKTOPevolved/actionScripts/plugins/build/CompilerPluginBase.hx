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
package actionScripts.plugins.build;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.valueObjects.ProjectVO;

class CompilerPluginBase extends PluginBase implements IPlugin {

	private var invalidPaths:Array<Dynamic>;

	private function checkProjectForInvalidPaths(project:ProjectVO):Void {
		if (Std.is(project, AS3ProjectVO)) {
			validateAS3VOPaths(AS3.as(project, AS3ProjectVO));
		} else if (Std.is(project, JavaProjectVO)) {
			validateJavaVOPaths(AS3.as(project, JavaProjectVO));
		}
	}

	private function onProjectPathsValidated(paths:Array<Dynamic>):Void {}

	private function validateAS3VOPaths(project:AS3ProjectVO):Void {
		var tmpLocation:FileLocation;
		invalidPaths = [];

		checkPathFileLocation(project.folderLocation, 'Location');
		if (AS3.as(project.sourceFolder, Bool)) {
			checkPathFileLocation(project.sourceFolder, 'Source Folder');
		}
		if (AS3.as(project.visualEditorSourceFolder, Bool)) {
			checkPathFileLocation(project.visualEditorSourceFolder, 'Source Folder');
		}

		if (AS3.as(project.buildOptions.customSDK, Bool)) {
			checkPathFileLocation(project.buildOptions.customSDK, 'Custom SDK');
		}

		for (tmpLocation in as3hx.Compat.each(project.classpaths)) {
			checkPathFileLocation(tmpLocation, 'Classpath');
		}
		for (tmpLocation in as3hx.Compat.each(project.resourcePaths)) {
			checkPathFileLocation(tmpLocation, 'Resource');
		}
		for (tmpLocation in as3hx.Compat.each(project.externalLibraries)) {
			checkPathFileLocation(tmpLocation, 'External Library');
		}
		for (tmpLocation in as3hx.Compat.each(project.libraries)) {
			checkPathFileLocation(tmpLocation, 'Library');
		}
		for (tmpLocation in as3hx.Compat.each(project.nativeExtensions)) {
			checkPathFileLocation(tmpLocation, 'Extension');
		}
		for (tmpLocation in as3hx.Compat.each(project.runtimeSharedLibraries)) {
			checkPathFileLocation(tmpLocation, 'Shared Library');
		}

		onProjectPathsValidated(((invalidPaths.length > 0)) ? invalidPaths : null);
	}

	private function validateJavaVOPaths(project:JavaProjectVO):Void {
		var tmpLocation:FileLocation;
		invalidPaths = [];

		checkPathFileLocation(project.folderLocation, 'Location');
		if (AS3.as(project.sourceFolder, Bool)) {
			checkPathFileLocation(project.sourceFolder, 'Source Folder');
		}

		for (tmpLocation in as3hx.Compat.each(project.classpaths)) {
			checkPathFileLocation(tmpLocation, 'Classpath');
		}

		onProjectPathsValidated(((invalidPaths.length > 0)) ? invalidPaths : null);
	}

	private function checkPathString(value:String, type:String):Void {
		if (!AS3.as(model.fileCore.isPathExists(value), Bool)) {
			invalidPaths.push(type + ': ' + value);
		}
	}

	private function checkPathFileLocation(value:FileLocation, type:String):Void {
		if (!AS3.as(value.fileBridge.exists, Bool)) {
			invalidPaths.push(type + ': ' + value.fileBridge.nativePath);
		}
	}

	public function new() {
		super();
	}

}