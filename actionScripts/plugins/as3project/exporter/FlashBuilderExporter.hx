////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.exporter;

import flash.desktop.NativeApplication;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import mx.collections.XMLListCollection;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
class FlashBuilderExporter {

	private static var sourceFolderPath:String;

	private static inline var SOURCE_NODE:String = 'SOURCE_NODE';

	private static inline var SWC_NODE:String = 'SWC_NODE';

	private static inline var MOONSHINE_RESOURCE_NODE:String = 'MOONSHINE_RESOURCE_NODE';

	private static var isMacOS:Bool = !NativeApplication.supportsSystemTrayIcon;

	public static function export(p:AS3ProjectVO, file:File):Void {
		var output:FastXML = toXML(p);

		var fw:FileStream = new FileStream();

		fw.open(file, FileMode.WRITE);
		// Does not prefix with a 16-bit length word like writeUTF() does
		fw.writeUTFBytes('<?xml version="1.0" encoding="utf-8" standalone="no"?>\n' + output.node.toXMLString.innerData());
		fw.close();
	}

	/*
	Serialize to FlashDevelop compatible XML project file.
	*/
	private static function toXML(p:AS3ProjectVO):FastXML
	// custom Flex SDK
	 {

		updateAttributes(p.flashBuilderProperties.compiler, 'flexSDK', p.buildOptions.customSDKPath);
		updateAttributes(p.flashBuilderProperties.compiler, 'additionalCompilerArguments', (p.air) ? p.buildOptions.additional.replace('+configname=air', '') : p.buildOptions.additional);
		updateAttributes(p.flashBuilderProperties.compiler, 'warn', Std.string(p.buildOptions.warnings));
		updateAttributes(p.flashBuilderProperties.compiler, 'strict', Std.string(p.buildOptions.strict));

		sourceFolderPath = p.flashBuilderProperties.compiler.att.sourceFolderPath;

		// remove any path settings in .actionScriptProperties XML first
		This is an intentional compilation error. See the README for handling the delete keyword
		delete p.flashBuilderProperties.compiler.compilerSourcePath // remove any SWC path;

		for (i /* AS3HX WARNING could not determine type for var: i exp: EField(EField(EField(EField(EIdent(p),flashBuilderProperties),compiler),libraryPath),libraryPathEntry) type: null */ in p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry) {
			This is an intentional compilation error. See the README for handling the delete keyword
			delete FastXML.filterNodes(i, function(x:FastXML) {
				if(x.att.kind == '3')
					return true;				return false;
			})[0];
		}
		// remove any resource type of path
		for (m /* AS3HX WARNING could not determine type for var: m exp: EField(EField(EField(EField(EField(EField(EIdent(p),flashBuilderProperties),compiler),libraryPath),libraryPathEntry),excludedEntries),libraryPathEntry) type: null */ in p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.libraryPathEntry) {
			This is an intentional compilation error. See the README for handling the delete keyword
			delete FastXML.filterNodes(m, function(x:FastXML) {
				if(x.att.linkType == '10')
					return true;				return false;
			})[0];
		}

		// adds new source paths
		p.flashBuilderProperties.compiler.child[0] = exportPaths(p.classpaths, FastXML.parse('<compilerSourcePath/>'), FastXML.parse('<compilerSourcePathEntry/>'), p, SOURCE_NODE);
		//p.flashBuilderProperties.compiler.child[0] = exportPaths(p.resourcePaths, <compilerSourcePath/>, <compilerSourcePathEntry/>, p, MOONSHINE_RESOURCE_NODE);

		// resource items
		var resourceXML:Array<FastXML> = try cast(exportPaths(p.resourcePaths, null, FastXML.parse('<libraryPathEntry/>'), p, MOONSHINE_RESOURCE_NODE), Array/*Vector.<T> call?*/) catch (e:Dynamic) null;
		for (k in resourceXML) {
			p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.child[0] = k;
		}

		// adds new SWC paths
		var swcPaths:FastXML = try cast(exportPaths(p.libraries, FastXML.parse('<libraryPath/>'), FastXML.parse('<libraryPathEntry/>'), p, SWC_NODE), FastXML) catch (e:Dynamic) null;
		for (j in swcPaths.nodes.libraryPathEntry) {
			p.flashBuilderProperties.compiler.libraryPath.child[0] = j;
		}

		return p.flashBuilderProperties;
	}

	private static function updateAttributes(container:FastXMLList, attributeName:String, updateWith:String):Void {
		if (updateWith != null) {
			This is an intentional compilation error. See the README for handling the delete keyword
			delete container.att.attributeName;
			container.setAttribute("attributeName", updateWith);
		}
	}

	private static function exportPaths(v:Array<FileLocation>, container:FastXML, element:FastXML, p:AS3ProjectVO, nodeAs:String = null):Dynamic {
		var tmpList:Array<FastXML> = ((container == null)) ? new Array<FastXML>() : null;
		for (f in v) {
			var e:FastXML = element.node.copy.innerData();
			var relative:String = p.folderLocation.fileBridge.getRelativePath(f);
			// don't add sourcefolderpath again
			e.setAttribute("path", (relative != null) ? relative : f.fileBridge.nativePath) = (relative != null) ? relative : f.fileBridge.nativePath;
			if (e.att.path != sourceFolderPath) {
				if (!isMacOS) {
					var ptrn:as3hx.Compat.Regex = null; //new RegExp(/\\/g);
					e.setAttribute("path", Std.string(e.setAttribute("path", )).replace(ptrn, '/'));
				}
				if (e.att.path.indexOf(p.flashBuilderDOCUMENTSPath) != -1) {
					e.setAttribute("path", Std.string(e.setAttribute("path", )).replace(p.flashBuilderDOCUMENTSPath, '${DOCUMENTS}'));
				}
				if (nodeAs == SOURCE_NODE) {
					e.setAttribute("kind", 1);
					e.setAttribute("linkType", 1);
				} else if (nodeAs == SWC_NODE) {
					e.setAttribute("kind", 3);
					e.setAttribute("linkType", 1);
				} else if (nodeAs == MOONSHINE_RESOURCE_NODE) {
					e.setAttribute("kind", 3);
					e.setAttribute("linkType", 10);
					e.setAttribute("useDefaultLinkType", 'false');
				}

				if (container == null) {
					tmpList.push(e);
				} else {
					container.node.appendChild.innerData(e);
				}
			}
		}
		return (container != null) ? container : tmpList;
	}

	public function new() {}

}