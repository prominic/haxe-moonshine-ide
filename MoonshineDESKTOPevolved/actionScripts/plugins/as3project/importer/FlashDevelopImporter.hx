////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.importer;

import actionScripts.plugin.project.ProjectTemplateType;
import actionScripts.utils.SerializeUtil;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.MXMLCConfigVO;
import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.MobileDeviceVO;

class FlashDevelopImporter extends FlashDevelopImporterBase {

	public static function test(file:File):FileLocation {
		if (!AS3.as(file.exists, Bool)) {
			return null;
		}

		var listing:Array<Dynamic> = file.getDirectoryListing();
		for (i_ in listing) {
			var i:File = cast i_;
			if (Reflect.field(i, 'extension') == 'as3proj' || Reflect.field(i, 'extension') == 'veditorproj') {
				return (new FileLocation(Reflect.field(i, 'nativePath')));
			}
		}

		return null;
	}

	public static function parse(file:FileLocation, projectName:String = null, descriptorFile:File = null, shallUpdateChildren:Bool = true, projectTemplateType:String = null):AS3ProjectVO {
		var folder:File = (AS3.as(file.fileBridge.getFile, File)).parent;

		var project:AS3ProjectVO = new AS3ProjectVO(new FileLocation(folder.nativePath), projectName, shallUpdateChildren);
		project.isVisualEditorProject = file.fileBridge.name.indexOf('veditorproj') > -1;

		project.projectFile = file;

		project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf('.'));
		project.config = new MXMLCConfigVO(new FileLocation(folder.resolvePath('obj/' + project.projectName + 'Config.xml').nativePath));
		project.projectFolder.name = project.projectName;

		var stream:FileStream = new FileStream();
		stream.open(AS3.as(file.fileBridge.getFile, File), FileMode.READ);
		var data:FastXML = FastXML.parse(stream.readUTFBytes(file.fileBridge.getFile.size));
		stream.close();

		// Parse XML file
		project.classpaths.length = 0;
		project.resourcePaths.length = 0;
		project.targets.length = 0;

		parsePaths(data.nodes.includeLibraries.descendants('element'), project.includeLibraries, project, 'path');
		parsePaths(data.nodes.libraryPaths.descendants('element'), project.libraries, project, 'path');
		parsePaths(data.nodes.externalLibraryPaths.descendants('element'), project.externalLibraries, project, 'path');
		parsePaths(data.nodes.rslPaths.descendants('element'), project.runtimeSharedLibraries, project, 'path');

		project.assetLibrary = data.node.library;
		parsePathString(data.nodes.intrinsics.descendants('element'), project.intrinsicLibraries, project, 'path');
		parsePaths(data.nodes.compileTargets.descendants('compile'), project.targets, project, 'path');
		parsePaths(data.nodes.hiddenPaths.descendants('hidden'), project.hiddenPaths, project, 'path');

		parsePaths(data.nodes.classpaths.get('class'), project.classpaths, project, 'path');
		parsePaths(data.nodes.moonshineResourcePaths.get('class'), project.resourcePaths, project, 'path');
		parsePaths(data.nodes.moonshineNativeExtensionPaths.get('class'), project.nativeExtensions, project, 'path');
		if (!AS3.as(project.buildOptions.additional, Bool)) {
			project.buildOptions.additional = '';
		}

		if (project.hiddenPaths.length > 0 && AS3.as(project.projectFolder, Bool)) {
			project.projectFolder.updateChildren();
		}

		project.prebuildCommands = SerializeUtil.deserializeString(data.node.preBuildCommand);
		project.postbuildCommands = SerializeUtil.deserializeString(data.node.postBuildCommand);
		project.postbuildAlways = SerializeUtil.deserializeBoolean(data.node.postBuildCommand.att.alwaysRun);
		project.isTrustServerCertificateSVN = SerializeUtil.deserializeBoolean(data.node.trustSVNCertificate);

		project.showHiddenPaths = SerializeUtil.deserializeBoolean(data.nodes.options.descendants('option').att.showHiddenPaths);
		project.isPrimeFacesVisualEditorProject = SerializeUtil.deserializeBoolean(data.nodes.options.descendants('option').att.isPrimeFacesVisualEditor);
		project.isExportedToExistingSource = SerializeUtil.deserializeBoolean(data.nodes.options.descendants('option').att.isExportedToExistingSource);
		project.visualEditorExportPath = SerializeUtil.deserializeString(data.nodes.options.descendants('option').att.visualEditorExportPath);

		if (project.targets.length > 0) {
			var target:FileLocation = Reflect.getProperty(project.targets, Std.string(0));

			// determine source folder path
			var substrPath:String = Std.string(target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + File.separator, ''));
			var pathSplit:Array<String> = substrPath.split(Std.string(File.separator));
			// remove the last class file name
			pathSplit.pop();
			var finalPath:String = Std.string(project.folderLocation.fileBridge.nativePath);
			// loop through array if source folder level is
			// deeper more than 1 level
			for (j in 0...pathSplit.length) {
				finalPath += File.separator + pathSplit[j];
			}

			// even before deciding, go for some more checks -
			// which needs in case user used 'set as default application'
			// to a file exists in different path
			for (i in as3hx.Compat.each(project.classpaths)) {
				if ((finalPath + File.separator).indexOf(Std.string(Reflect.field(Reflect.field(i, 'fileBridge'), 'nativePath') + File.separator)) != -1) {
					project.sourceFolder = i;
				}
			}

			// if yet not decided from above approach
			if (!AS3.as(project.sourceFolder, Bool)) {
				project.sourceFolder = new FileLocation(finalPath);
			}
		} else if (project.classpaths.length > 0) {
			// its possible that a project do not have any default application (project.targets[0])
			// i.e. library project where no default application maintains
			// we shall try to select the source folder based on its classpaths
			for (k in as3hx.Compat.each(project.classpaths)) {
				if (Reflect.field(Reflect.field(k, 'fileBridge'), 'nativePath').indexOf(project.folderLocation.fileBridge.nativePath + File.separator) != -1) {
					project.sourceFolder = k;
					break;
				}
			}
		}

		if (AS3.as(project.isVisualEditorProject, Bool)) {
			project.visualEditorSourceFolder = new FileLocation(
					project.folderLocation.fileBridge.nativePath + File.separator + 'visualeditor-src/main/webapp');
		}

		project.defaultBuildTargets = data.nodes.options.descendants('option').att.defaultBuildTargets;
		project.testMovie = data.nodes.options.descendants('option').att.testMovie;

		project.buildOptions.parse(data.node.build);
		project.mavenBuildOptions.parse(data.node.mavenBuild);

		project.swfOutput.parse(data.node.output, project);
		if (AS3.as(project.swfOutput.path.fileBridge.extension, Bool) && project.swfOutput.path.fileBridge.extension.toLowerCase() == 'swc') {
			project.isLibraryProject = true;
		}

		project.jsOutputPath = SerializeUtil.deserializeString(data.nodes.jsOutput.descendants('option').att.path);

		if (project.targets.length > 0 && Reflect.getProperty(project.targets, Std.string(0)).fileBridge.extension == 'as' && project.intrinsicLibraries.length == 0) {
			project.isActionScriptOnly = true;
		}
		if (project.targets.length > 0 && Reflect.getProperty(project.targets, Std.string(0)).fileBridge.extension == 'mxml') {
			project.isActionScriptOnly = false;
		} else if (project.intrinsicLibraries.length == 0) {
			project.isActionScriptOnly = true;
		}

		project.air = UtilsCore.isAIR(project);
		project.isMobile = UtilsCore.isMobile(project);

		if (project.swfOutput.platform == '') {
			if (AS3.as(project.isMobile, Bool)) {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_MOBILE;
			} else if (AS3.as(project.air, Bool)) {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_AIR;
			} else {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_DEFAULT;
			}
		}

		if (AS3.as(project.air, Bool)) {
			project.testMovie = AS3ProjectVO.TEST_MOVIE_AIR;
		}
		if (project.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT) {
			project.testMovieCommand = data.nodes.options.descendants('option').att.testMovieCommand;
		}

		var platform:Int = AS3.int(data.nodes.moonshineRunCustomization.descendants('option').att.targetPlatform);
		if (platform == AS3.int(AS3ProjectPlugin.AS3PROJ_AS_ANDROID)) {
			project.buildOptions.targetPlatform = 'Android';
		} else if (platform == AS3.int(AS3ProjectPlugin.AS3PROJ_AS_IOS)) {
			project.buildOptions.targetPlatform = 'iOS';
		}

		var html:String = Std.string(SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('option').att.urlToLaunch));
		if (html != null) {
			project.htmlPath = new FileLocation(html);
		}

		var customHtml:String = Std.string(SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('option').att.customUrlToLaunch));
		if (customHtml != null) {
			project.customHTMLPath = customHtml;
		}

		project.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('option').att.deviceSimulator));

		var simulator:String = Std.string(SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('option').att.launchMethod));
		project.buildOptions.isMobileRunOnSimulator = ((simulator != 'Device')) ? true : false;

		if (!AS3.as(project.air, Bool)) {
			UtilsCore.checkIfRoyaleApplication(project);
			if (!AS3.as(project.isRoyale, Bool)) {
				if (projectTemplateType == Std.string(ProjectTemplateType.ROYALE_PROJECT)) {
					project.isRoyale = true;
				} else {
					project.isRoyale = SerializeUtil.deserializeBoolean(data.nodes.options.descendants('option').att.isRoyale);
				}
			}
		}

		project.buildOptions.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('deviceSimulator')));
		project.buildOptions.certAndroid = SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('certAndroid'));
		project.buildOptions.certIos = SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('certIos'));
		project.buildOptions.certIosProvisioning = SerializeUtil.deserializeString(data.nodes.moonshineRunCustomization.descendants('certIosProvisioning'));

		UtilsCore.setProjectMenuType(project);

		return project;
	}

}