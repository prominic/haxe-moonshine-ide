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
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

class FlashBuilderExporter {

	private static var sourceFolderPath:String;
	private static inline var SOURCE_NODE:String = 'SOURCE_NODE';
	private static inline var SWC_NODE:String = 'SWC_NODE';
	private static inline var MOONSHINE_RESOURCE_NODE:String = 'MOONSHINE_RESOURCE_NODE';
	private static var isMacOS(default, never):Bool = !AS3.as(NativeApplication.supportsSystemTrayIcon, Bool);

	public static function export(p:AS3ProjectVO, file:File):Void {
		var output:FastXML = toXML(p);

		var fw:FileStream = new FileStream();

		fw.open(file, FileMode.WRITE);
		// Does not prefix with a 16-bit length word like writeUTF() does
		fw.writeUTFBytes('<?xml version="1.0" encoding="utf-8" standalone="no"?>\n' + output.node.toXMLString());
		fw.close();
	}

	/*
		Serialize to FlashDevelop compatible XML project file.
	*/
	private static function toXML(p:AS3ProjectVO):FastXML {
		// custom Flex SDK
		updateAttributes(p.flashBuilderProperties.compiler, 'flexSDK', Std.string(p.buildOptions.customSDKPath));
		updateAttributes(p.flashBuilderProperties.compiler, 'additionalCompilerArguments', (AS3.as(p.air, Bool)) ? Std.string(p.buildOptions.additional.replace('+configname=air', '')) : Std.string(p.buildOptions.additional));
		updateAttributes(p.flashBuilderProperties.compiler, 'warn', Std.string(Std.string(p.buildOptions.warnings)));
		updateAttributes(p.flashBuilderProperties.compiler, 'strict', Std.string(Std.string(p.buildOptions.strict)));

		sourceFolderPath = Std.string(p.flashBuilderProperties.compiler.att.sourceFolderPath);

		// remove any path settings in .actionScriptProperties XML first
		;
		// remove any SWC path
		for (i in as3hx.Compat.each(p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry)) {
			Reflect.getProperty(This is an intentional compilation error. See the README for handling the delete keyword
			delete FastXML.filterNodes(i, function(x:FastXML) {
				if(x.att.kind == '3')
					return true;
				return false;

			}), Std.string(0));
		}
		// remove any resource type of path
		for (m in as3hx.Compat.each(p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.libraryPathEntry)) {
			Reflect.getProperty(This is an intentional compilation error. See the README for handling the delete keyword
			delete FastXML.filterNodes(m, function(x:FastXML) {
				if(x.att.linkType == '10')
					return true;
				return false;

			}), Std.string(0));
		}

		// adds new source paths
		Reflect.setProperty(p.flashBuilderProperties.compiler.child, Std.string(0), exportPaths(p.classpaths, FastXML.parse('<compilerSourcePath/>'), FastXML.parse('<compilerSourcePathEntry/>'), p, SOURCE_NODE));
		//p.flashBuilderProperties.compiler.child[0] = exportPaths(p.resourcePaths, <compilerSourcePath/>, <compilerSourcePathEntry/>, p, MOONSHINE_RESOURCE_NODE);

		// resource items
		var resourceXML:Array<FastXML> = try cast(exportPaths(p.resourcePaths, null, FastXML.parse('<libraryPathEntry/>'), p, MOONSHINE_RESOURCE_NODE), Vector) catch(e:Dynamic) null;
		for (k in resourceXML) {
			Reflect.setProperty(p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.child, Std.string(0), k);
		}

		// adds new SWC paths
		var swcPaths:FastXML = AS3.as(exportPaths(p.libraries, FastXML.parse('<libraryPath/>'), FastXML.parse('<libraryPathEntry/>'), p, SWC_NODE), FastXML);
		for (j in swcPaths.nodes.libraryPathEntry) {
			Reflect.setProperty(p.flashBuilderProperties.compiler.libraryPath.child, Std.string(0), j);
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
			var e:FastXML = element.copy();
			var relative:String = Std.string(p.folderLocation.fileBridge.getRelativePath(f));
			// don't add sourcefolderpath again
			e.setAttribute("path", (relative != null) ? relative : Std.string(f.fileBridge.nativePath));
			if (e.att.path != sourceFolderPath) {
				if (!isMacOS) {
					var ptrn:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('\\\\', 'g'));
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
					container.node.appendChild(e);
				}
			}
		}
		return (container != null) ? container : tmpList;
	}

}