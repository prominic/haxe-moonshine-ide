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
package actionScripts.plugins.as3project.exporter;

import actionScripts.utils.SerializeUtil;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
class FlashDevelopExporter {

	public static function export(p:AS3ProjectVO, file:FileLocation):Void {
		if (!file.fileBridge.exists) {
			file.fileBridge.createFile();
		}

		var output:FastXML = toXML(p);

		var fw:FileStream = new FileStream();

		fw.open(try cast(file.fileBridge.getFile, File) catch (e:Dynamic) null, FileMode.WRITE);
		// Does not prefix with a 16-bit length word like writeUTF() does
		fw.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>\n' + output.node.toXMLString.innerData());
		fw.close();
	}

	/*
	Serialize to FlashDevelop compatible XML project file.
	*/
	private static function toXML(p:AS3ProjectVO):FastXML {
		var project:FastXML = FastXML.parse('<project></project>');
		var tmpXML:FastXML;

		// Get output node with relative paths
		var outputXML:FastXML = p.swfOutput.toXML(p.folderLocation);
		project.node.appendChild.innerData(outputXML);

		var jsOutput:FastXML = FastXML.parse('<jsOutput></jsOutput>');
		var jsOutputPath:Dynamic = {
			path: SerializeUtil.serializeString(p.jsOutputPath)
		};
		jsOutput.node.appendChild.innerData(SerializeUtil.serializePairs(jsOutputPath, FastXML.parse('<option />')));
		project.node.appendChild.innerData(jsOutput);

		project.node.insertChildAfter.innerData(outputXML, '<!-- Other classes to be compiled into your SWF -->');

		project.node.appendChild.innerData(exportPaths(p.classpaths, FastXML.parse('<classpaths />'), FastXML.parse('<class />'), p));
		project.node.appendChild.innerData(exportPaths(p.resourcePaths, FastXML.parse('<moonshineResourcePaths />'), FastXML.parse('<class />'), p));
		project.node.appendChild.innerData(exportPaths(p.nativeExtensions, FastXML.parse('<moonshineNativeExtensionPaths />'), FastXML.parse('<class />'), p));

		project.node.appendChild.innerData(p.buildOptions.toXML());
		project.node.appendChild.innerData(p.mavenBuildOptions.toXML());

		project.node.appendChild.innerData(exportPaths(p.includeLibraries, FastXML.parse('<includeLibraries />'), FastXML.parse('<element />'), p));
		project.node.appendChild.innerData(exportPaths(p.libraries, FastXML.parse('<libraryPaths />'), FastXML.parse('<element />'), p));
		project.node.appendChild.innerData(exportPaths(p.externalLibraries, FastXML.parse('<externalLibraryPaths />'), FastXML.parse('<element />'), p));
		project.node.appendChild.innerData(exportPaths(p.runtimeSharedLibraries, FastXML.parse('<rslPaths></rslPaths>'), FastXML.parse('<element />'), p));
		project.node.appendChild.innerData(exportPathString(p.intrinsicLibraries, FastXML.parse('<intrinsics />'), FastXML.parse('<element />'), p));
		if (p.assetLibrary && p.assetLibrary.children().length() == 0) {
			var libXML:FastXMLList = p.assetLibrary;
			libXML.node.child.innerData[0] = null; //new XML(<!-- <empty/> -->);
			project.node.appendChild.innerData(libXML);
		} else if (p.assetLibrary) {
			project.node.appendChild.innerData(p.assetLibrary);
		} else {
			var tmpBlankXML:FastXML = FastXML.parse('<library/>');
			project.node.appendChild.innerData(tmpBlankXML);
		}

		project.node.appendChild.innerData(exportPaths(p.targets, FastXML.parse('<compileTargets />'), FastXML.parse('<compile />'), p));
		project.node.appendChild.innerData(exportPaths(p.hiddenPaths, FastXML.parse('<hiddenPaths />'), FastXML.parse('<hidden />'), p));

		tmpXML = FastXML.parse('<preBuildCommand />');
		tmpXML.node.appendChild.innerData(p.prebuildCommands);
		project.node.appendChild.innerData(tmpXML);

		tmpXML = FastXML.parse('<postBuildCommand />');
		tmpXML.node.appendChild.innerData(p.postbuildCommands);
		tmpXML.setAttribute("alwaysRun", SerializeUtil.serializeBoolean(p.postbuildAlways));
		project.node.appendChild.innerData(tmpXML);

		tmpXML = FastXML.parse('<trustSVNCertificate />');
		tmpXML.node.appendChild.innerData((p.isTrustServerCertificateSVN) ? 'True' : 'False');
		project.node.appendChild.innerData(tmpXML);

		var options:FastXML = FastXML.parse('<options />');
		var optionPairs:Dynamic = {
			showHiddenPaths: SerializeUtil.serializeBoolean(p.showHiddenPaths),
			testMovie: SerializeUtil.serializeString(p.testMovie),
			defaultBuildTargets: SerializeUtil.serializeString(p.defaultBuildTargets),
			testMovieCommand: SerializeUtil.serializeString(p.testMovieCommand),
			isPrimeFacesVisualEditor: SerializeUtil.serializeBoolean(p.isPrimeFacesVisualEditorProject),
			isExportedToExistingSource: SerializeUtil.serializeBoolean(p.isExportedToExistingSource),
			visualEditorExportPath: SerializeUtil.serializeString(p.visualEditorExportPath)
		};
		if (p.testMovieCommand && p.testMovieCommand != '') {
			optionPairs.testMovieCommand = p.testMovieCommand;
		}
		options.node.appendChild.innerData(SerializeUtil.serializePairs(optionPairs, FastXML.parse('<option />')));
		project.node.appendChild.innerData(options);

		var projType:Int = !(p.air) ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
		if (p.isMobile) {
			projType = AS3ProjectPlugin.AS3PROJ_AS_ANDROID;
		}

		var platform:Int = !(p.air) ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
		if (p.isMobile) {
			platform = ((p.buildOptions.targetPlatform == 'Android')) ? AS3ProjectPlugin.AS3PROJ_AS_ANDROID : AS3ProjectPlugin.AS3PROJ_AS_IOS;
		}

		options = FastXML.parse('<moonshineRunCustomization />');
		optionPairs = {
					projectType: projType,
					targetPlatform: platform,
					urlToLaunch: (p.htmlPath) ? p.htmlPath.fileBridge.nativePath : '',
					customUrlToLaunch: (p.customHTMLPath) ? p.customHTMLPath : '',
					launchMethod: (p.buildOptions.isMobileRunOnSimulator) ? 'Simulator' : 'Device',
					deviceSimulator: (p.isMobileHasSimulatedDevice) ? p.isMobileHasSimulatedDevice.name : null
				};
		options.node.appendChild.innerData(SerializeUtil.serializePairs(optionPairs, FastXML.parse('<option />')));

		tmpXML = FastXML.parse('<deviceSimulator/>');
		tmpXML.node.appendChild.innerData((p.buildOptions.isMobileHasSimulatedDevice) ? p.buildOptions.isMobileHasSimulatedDevice.name : null);
		options.node.appendChild.innerData(tmpXML);
		tmpXML = FastXML.parse('<certAndroid/>');
		tmpXML.node.appendChild.innerData(p.buildOptions.certAndroid);
		options.node.appendChild.innerData(tmpXML);
		tmpXML = FastXML.parse('<certIos/>');
		tmpXML.node.appendChild.innerData(p.buildOptions.certIos);
		options.node.appendChild.innerData(tmpXML);
		tmpXML = FastXML.parse('<certIosProvisioning/>');
		tmpXML.node.appendChild.innerData(p.buildOptions.certIosProvisioning);
		options.node.appendChild.innerData(tmpXML);
		project.node.appendChild.innerData(options);

		// update obj/*config.xml
		if (p.config.file && p.config.file.fileBridge.exists) {
			p.updateConfig();
		}

		return project;
	}

	private static function exportPaths(v:Array<FileLocation>, container:FastXML, element:FastXML, p:AS3ProjectVO, absolutePath:Bool = false, appendAsValue:Bool = false, nullValue:String = null):FastXML {
		for (f in v) {
			var e:FastXML = element.node.copy.innerData();
			var relative:String = p.folderLocation.fileBridge.getRelativePath(f, true);
			if (absolutePath) {
				relative = null;
			}
			if (appendAsValue) {
				e.node.appendChild.innerData((relative != null) ? relative : f.fileBridge.nativePath);
			} else {
				e.setAttribute("path", (relative != null) ? relative : f.fileBridge.nativePath) = (relative != null) ? relative : f.fileBridge.nativePath;
			}
			container.node.appendChild.innerData(e);
		}

		if (v.length == 0 && nullValue != null) {
			element.node.appendChild.innerData(nullValue);
			container.node.appendChild.innerData(nullValue);
		} else if (v.length == 0) {
			container.node.appendChild.innerData(null);
		}

		return container;
	}

	private static function exportPathString(v:Array<String>, container:FastXML, element:FastXML, p:AS3ProjectVO, absolutePath:Bool = false, appendAsValue:Bool = false, nullValue:String = null):FastXML {
		for (f in v) {
			var e:FastXML = element.node.copy.innerData();
			if (appendAsValue) {
				e.node.appendChild.innerData(f);
			} else {
				e.setAttribute("path", f);
			}
			container.node.appendChild.innerData(e);
		}

		if (v.length == 0 && nullValue != null) {
			element.node.appendChild.innerData(nullValue);
			container.node.appendChild.innerData(nullValue);
		} else if (v.length == 0) {
			var tmpXML:FastXML = FastXML.parse('<!-- <empty/>')-- >
			container.node.appendChild.innerData(tmpXML);
		}

		return container;
	}

	public function new() {}

}