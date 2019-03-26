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

import flash.errors.Error;

import actionScripts.utils.SerializeUtil;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
import actionScripts.plugin.core.importer.FlashBuilderImporterBase;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.UtilsCore;
class FlashBuilderImporter extends FlashBuilderImporterBase {

	public static function test(file:File):FileLocation {
		var ret:Bool = true;
		if (file.resolvePath('.actionScriptProperties').exists == false) {
			ret = false;
		}
		if (file.resolvePath('.project').exists == false) {
			ret = false;
		}

		return (((ret)) ? new FileLocation(file.nativePath) : null);
	}

	public static function parse(file:FileLocation):AS3ProjectVO {
		var p:AS3ProjectVO = new AS3ProjectVO(file);

		var libSettings:File = try cast(file.resolvePath('.flexLibProperties').fileBridge.getFile, File) catch (e:Dynamic) null;
		if (libSettings.exists) {
			p.isLibraryProject = true;
		}

		var projectSettings:File = try cast(file.resolvePath('.project').fileBridge.getFile, File) catch (e:Dynamic) null;
		readProjectSettings(projectSettings, p);

		var actionscriptProperties:File = try cast(file.resolvePath('.actionScriptProperties').fileBridge.getFile, File) catch (e:Dynamic) null;
		readActionScriptSettings(actionscriptProperties, p);

		// For AIR projects we need to meddle with the projectname-app.xml file
		if (p.air == true) {
			if (p.targets.length > 0) {
				var targetApp:File = try cast(p.targets[0].fileBridge.getFile, File) catch (e:Dynamic) null;
				var appConfig:File = targetApp.parent.resolvePath(p.projectName + '-app.xml');
				if (appConfig.exists) {
					updateAppConfigXML(appConfig, p);
				}
			}
		}

		UtilsCore.setProjectMenuType(p);

		return p;
	}

	private static function readProjectSettings(file:File, p:AS3ProjectVO):Void {
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var data:FastXML = FastXML.parse(stream.readUTFBytes(file.size));
		stream.close();

		p.projectName = data.node.name.innerData;
	}

	private static function readActionScriptSettings(file:File, p:AS3ProjectVO):Void {
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var dataString:String = stream.readUTFBytes(file.size);
		var data:FastXML = FastXML.parse(dataString);
		p.flashBuilderProperties = data;
		stream.close();

		var isDocumentsPathExists:Bool = (dataString.indexOf('${DOCUMENTS}') != -1);
		if (isDocumentsPathExists) {
			var folderToSearch:String = '.metadata';
			for (i in 0...6) {
				var m:File;
				try {
					if (i == 0) {
						m = p.folderLocation.fileBridge.getFile.parent.resolvePath(folderToSearch);
					} else if (i == 1) {
						m = p.folderLocation.fileBridge.getFile.parent.parent.resolvePath(folderToSearch);
					} else if (i == 2) {
						m = p.folderLocation.fileBridge.getFile.parent.parent.parent.resolvePath(folderToSearch);
					} else if (i == 3) {
						m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.resolvePath(folderToSearch);
					} else if (i == 4) {
						m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.resolvePath(folderToSearch);
					} else if (i == 5) {
						m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.parent.resolvePath(folderToSearch);
					}
				} catch (e:Error) {
					break;
				}
				if (m.exists) {
					m = m.resolvePath('.plugins/org.eclipse.core.runtime/.settings/org.eclipse.core.resources.prefs');
					if (m.exists)
					/* AS3HX WARNING namespace modifier CONFIG::OSX */
					{
						{
							if (!checkOSXBookmarked(m.nativePath)) {
								break;
							}
						}

						stream = new FileStream();
						stream.open(m, FileMode.READ);
						dataString = stream.readUTFBytes(m.size);
						stream.close();

						var allLines:Array<Dynamic> = dataString.split(new as3hx.Compat.Regex('\\n', ''));
						for (j in allLines) {
							if (Std.string(j).indexOf('pathvariable.DOCUMENTS') != -1) {
								allLines = Std.string(j).split('=');
								p.flashBuilderDOCUMENTSPath = allLines[1];
								p.flashBuilderDOCUMENTSPath = p.flashBuilderDOCUMENTSPath.replace('\r', '');
								p.flashBuilderDOCUMENTSPath = p.flashBuilderDOCUMENTSPath.replace('\\:', ':'); // for Windows settlement. i.e. C\:/Users/
								break;
							}
						}
					}
					break;
				}
			}
		}

		parsePaths(data.nodes.compiler.node.compilerSourcePath.innerData['compilerSourcePathEntry'], p.classpaths, p, 'path', p.flashBuilderDOCUMENTSPath);
		//parsePaths(data.compiler.moonshineResourcePath["moonshineResourcePathEntry"], p.resourcePaths, p, "path", p.flashBuilderDOCUMENTSPath);
		parsePaths(FastXML.filterNodes(data.nodes.compiler.node.libraryPath.innerData.libraryPathEntry.excludedEntries.libraryPathEntry, function(x:FastXML) {
					if(x.att.linkType == '10')
						return true;					return false;
				}), p.resourcePaths, p, 'path', p.flashBuilderDOCUMENTSPath);
		parsePaths(FastXML.filterNodes(data.nodes.compiler.node.libraryPath.innerData.libraryPathEntry, function(x:FastXML) {
					if(x.att.kind == '3')
						return true;					return false;
				}), p.libraries, p, 'path', p.flashBuilderDOCUMENTSPath);

		p.buildOptions.parse(data.node.compiler.innerData, BuildOptions.TYPE_FB);
		var target:FileLocation = p.folderLocation.resolvePath(data.node.compiler.innerData.att.sourceFolderPath + '/' + data.att.mainApplicationPath);
		p.targets.push(target);

		p.air = SerializeUtil.deserializeBoolean(data.node.compiler.innerData.att.useApolloConfig);
		p.isActionScriptOnly = SerializeUtil.deserializeBoolean(data.node.compiler.innerData.att.useFlashSDK);

		// FB doesn't seem to have a notion of output filename, so we guesstimate it
		p.swfOutput.path = p.folderLocation.resolvePath(data.node.compiler.innerData.att.outputFolderPath + '/' + p.targets[0].fileBridge.name.split('.')[0] + '.swf');
		// lets update SWF version too per current SDK version (if setup a default SDK)
		p.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(p.buildOptions.customSDKPath);

		var classPath:FileLocation = p.folderLocation.resolvePath(data.node.compiler.innerData.att.sourceFolderPath);
		p.classpaths.push(classPath);

		p.isFlashBuilderProject = true;

		p.sourceFolder = p.folderLocation.fileBridge.resolvePath(data.node.compiler.innerData.att.sourceFolderPath);
		p.isMobile = UtilsCore.isMobile(p);

		// add output folder path to flash trust content list
		if (!p.air && !p.isMobile) { //IDEModel.getInstance().flexCore.updateFlashPlayerTrustContent(p.folderLocation.resolvePath("bin-debug"));

		}
	}

	private static function updateAppConfigXML(file:File, p:AS3ProjectVO):Void {
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var data:String = Std.string(stream.readUTFBytes(file.size));
		stream.close();

		var replacement:String = p.projectName + '.swf';
		p.isMobile = UtilsCore.isMobile(p);

		// Try to not mess up the formatting of the XML first
		//  by just string replacing
		if (data.indexOf('<content>') > -1) {
			data = new as3hx.Compat.Regex('<content>.*?<\\/content>', '').replace(data, '<content>' + replacement + '</content>');
		}
		// If that fails we change up the XML
		else {

			{
				FastXML.ignoreComments = false;
				FastXML.ignoreWhitespace = false;

				var dataXML:FastXML = FastXML.parse(data);

				var ns:Namespace = dataXML.nodes.namespaceDeclarations()[0];
				dataXML.node.ns::initialWindow.innerData.node.ns::content.innerData = replacement;

				data = dataXML.node.toXMLString.innerData();

				FastXML.ignoreComments = true;
				FastXML.ignoreWhitespace = true;
			}
		}

		stream.open(file, FileMode.WRITE);
		stream.writeUTFBytes(data);
		stream.close();
	}

	public function new() {
		super();
	}

}