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
		if (!file.exists) {
			return null;
		}

		var listing:Array<Dynamic> = file.getDirectoryListing();
		for (i in listing) {
			if (i.extension == 'as3proj' || i.extension == 'veditorproj') {
				return (new FileLocation(i.nativePath));
			}
		}

		return null;
	}

	public static function parse(file:FileLocation, projectName:String = null, descriptorFile:File = null, shallUpdateChildren:Bool = true):AS3ProjectVO {
		var folder:File = (try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null).parent;

		var project:AS3ProjectVO = new AS3ProjectVO(new FileLocation(folder.nativePath), projectName, shallUpdateChildren);
		project.isVisualEditorProject = file.fileBridge.name.indexOf('veditorproj') > -1;

		project.projectFile = file;

		project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf('.'));
		project.config = new MXMLCConfigVO(new FileLocation(folder.resolvePath('obj/' + project.projectName + 'Config.xml').nativePath));
		project.projectFolder.name = project.projectName;

		var stream:FileStream = new FileStream();
		stream.open(try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null, FileMode.READ);
		var data:FastXML = FastXML.parse(stream.readUTFBytes(file.fileBridge.getFile.size));
		stream.close();

		// Parse XML file
		project.classpaths.length = 0;
		project.resourcePaths.length = 0;
		project.targets.length = 0;

		parsePaths(data.node.includeLibraries.innerData.node.element.innerData, project.includeLibraries, project, 'path');
		parsePaths(data.node.libraryPaths.innerData.node.element.innerData, project.libraries, project, 'path');
		parsePaths(data.node.externalLibraryPaths.innerData.node.element.innerData, project.externalLibraries, project, 'path');
		parsePaths(data.node.rslPaths.innerData.node.element.innerData, project.runtimeSharedLibraries, project, 'path');

		project.assetLibrary = data.node.library.innerData;
		parsePathString(data.node.intrinsics.innerData.node.element.innerData, project.intrinsicLibraries, project, 'path');
		parsePaths(data.node.compileTargets.innerData.node.compile.innerData, project.targets, project, 'path');
		parsePaths(data.node.hiddenPaths.innerData.node.hidden.innerData, project.hiddenPaths, project, 'path');

		parsePaths(data.nodes.classpaths.get('class'), project.classpaths, project, 'path');
		parsePaths(data.nodes.moonshineResourcePaths.get('class'), project.resourcePaths, project, 'path');
		parsePaths(data.nodes.moonshineNativeExtensionPaths.get('class'), project.nativeExtensions, project, 'path');
		if (!project.buildOptions.additional) {
			project.buildOptions.additional = '';
		}

		if (project.hiddenPaths.length > 0 && project.projectFolder) {
			project.projectFolder.updateChildren();
		}

		project.prebuildCommands = SerializeUtil.deserializeString(data.node.preBuildCommand.innerData);
		project.postbuildCommands = SerializeUtil.deserializeString(data.node.postBuildCommand.innerData);
		project.postbuildAlways = SerializeUtil.deserializeBoolean(data.node.postBuildCommand.innerData.att.alwaysRun);
		project.isTrustServerCertificateSVN = SerializeUtil.deserializeBoolean(data.node.trustSVNCertificate.innerData);

		project.showHiddenPaths = SerializeUtil.deserializeBoolean(data.node.options.innerData.node.option.innerData.att.showHiddenPaths);
		project.isPrimeFacesVisualEditorProject = SerializeUtil.deserializeBoolean(data.node.options.innerData.node.option.innerData.att.isPrimeFacesVisualEditor);
		project.isExportedToExistingSource = SerializeUtil.deserializeBoolean(data.node.options.innerData.node.option.innerData.att.isExportedToExistingSource);
		project.visualEditorExportPath = SerializeUtil.deserializeString(data.node.options.innerData.node.option.innerData.att.visualEditorExportPath);

		if (project.targets.length > 0) {
			var target:FileLocation = project.targets[0];

			// determine source folder path
			var substrPath:String = target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + File.separator, '');
			var pathSplit:Array<Dynamic> = substrPath.split(File.separator);
			// remove the last class file name
			pathSplit.pop();
			var finalPath:String = project.folderLocation.fileBridge.nativePath;
			// loop through array if source folder level is
			// deeper more than 1 level
			var j:Int = 0;
			while (j < pathSplit.length) {
				finalPath += File.separator + pathSplit[j];
				j++;
			}

			// even before deciding, go for some more checks -
			// which needs in case user used 'set as default application'
			// to a file exists in different path
			for (i /* AS3HX WARNING could not determine type for var: i exp: EField(EIdent(project),classpaths) type: null */ in project.classpaths) {
				if ((finalPath + File.separator).indexOf(i.fileBridge.nativePath + File.separator) != -1) {
					project.sourceFolder = i;
				}
			}

			// if yet not decided from above approach
			if (!project.sourceFolder) {
				project.sourceFolder = new FileLocation(finalPath);
			}
		} else if (project.classpaths.length > 0)
		// its possible that a project do not have any default application (project.targets[0])
		{

			// i.e. library project where no default application maintains
			// we shall try to select the source folder based on its classpaths
			for (k /* AS3HX WARNING could not determine type for var: k exp: EField(EIdent(project),classpaths) type: null */ in project.classpaths) {
				if (k.fileBridge.nativePath.indexOf(project.folderLocation.fileBridge.nativePath + File.separator) != -1) {
					project.sourceFolder = k;
					break;
				}
			}
		}

		if (project.isVisualEditorProject) {
			project.visualEditorSourceFolder = new FileLocation(
					project.folderLocation.fileBridge.nativePath + File.separator + 'visualeditor-src/main/webapp');
		}

		project.defaultBuildTargets = data.node.options.innerData.node.option.innerData.att.defaultBuildTargets;
		project.testMovie = data.node.options.innerData.node.option.innerData.att.testMovie;

		project.buildOptions.parse(data.node.build.innerData);
		project.mavenBuildOptions.parse(data.node.mavenBuild.innerData);

		project.swfOutput.parse(data.node.output.innerData, project);
		if (project.swfOutput.path.fileBridge.extension && project.swfOutput.path.fileBridge.extension.toLowerCase() == 'swc') {
			project.isLibraryProject = true;
		}

		project.jsOutputPath = SerializeUtil.deserializeString(data.node.jsOutput.innerData.node.option.innerData.att.path);

		if (project.targets.length > 0 && project.targets[0].fileBridge.extension == 'as' && project.intrinsicLibraries.length == 0) {
			project.isActionScriptOnly = true;
		}
		if (project.targets.length > 0 && project.targets[0].fileBridge.extension == 'mxml') {
			project.isActionScriptOnly = false;
		} else if (project.intrinsicLibraries.length == 0) {
			project.isActionScriptOnly = true;
		}

		project.air = UtilsCore.isAIR(project);
		project.isMobile = UtilsCore.isMobile(project);

		if (project.swfOutput.platform == '') {
			if (project.isMobile) {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_MOBILE;
			} else if (project.air) {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_AIR;
			} else {
				project.swfOutput.platform = SWFOutputVO.PLATFORM_DEFAULT;
			}
		}

		if (project.air) {
			project.testMovie = AS3ProjectVO.TEST_MOVIE_AIR;
		}
		if (project.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT) {
			project.testMovieCommand = data.node.options.innerData.node.option.innerData.att.testMovieCommand;
		}

		var platform:Int = as3hx.Compat.parseInt(data.node.moonshineRunCustomization.innerData.node.option.innerData.att.targetPlatform);
		if (platform == AS3ProjectPlugin.AS3PROJ_AS_ANDROID) {
			project.buildOptions.targetPlatform = 'Android';
		} else if (platform == AS3ProjectPlugin.AS3PROJ_AS_IOS) {
			project.buildOptions.targetPlatform = 'iOS';
		}

		var html:String = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.option.innerData.att.urlToLaunch);
		if (html != null) {
			project.htmlPath = new FileLocation(html);
		}

		var customHtml:String = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.option.innerData.att.customUrlToLaunch);
		if (customHtml != null) {
			project.customHTMLPath = customHtml;
		}

		project.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.option.innerData.att.deviceSimulator));

		var simulator:String = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.option.innerData.att.launchMethod);
		project.buildOptions.isMobileRunOnSimulator = ((simulator != 'Device')) ? true : false;

		if (!project.air) {
			UtilsCore.checkIfRoyaleApplication(project);
		}

		project.buildOptions.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.deviceSimulator.innerData));
		project.buildOptions.certAndroid = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.certAndroid.innerData);
		project.buildOptions.certIos = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.certIos.innerData);
		project.buildOptions.certIosProvisioning = SerializeUtil.deserializeString(data.node.moonshineRunCustomization.innerData.node.certIosProvisioning.innerData);

		UtilsCore.setProjectMenuType(project);

		return project;
	}

	public function new() {
		super();
	}

}