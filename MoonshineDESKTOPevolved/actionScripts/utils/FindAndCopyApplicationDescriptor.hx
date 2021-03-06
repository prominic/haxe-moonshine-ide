////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Prominic.NET, Inc.
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
package actionScripts.utils;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

/**
 * Class for findAndCopyApplicationDescriptor
 */
@:final class FindAndCopyApplicationDescriptor {

	public static function findAndCopyApplicationDescriptor(file:File, project:AS3ProjectVO, destDir:File):String {
		// Guesstimate app-xml name
		var rootPath:String = Std.string(File(project.folderLocation.fileBridge.getFile).getRelativePath(file.parent));
		var descriptorName:String = Reflect.getProperty(project.swfOutput.path.fileBridge.name.split('.'), Std.string(0)) + '-app.xml';
		var appXML:String = Reflect.getProperty(project.targets, Std.string(0)).fileBridge.parent.fileBridge.nativePath + File.separator + descriptorName;
		var descriptorFile:File = new File(appXML);

		// in case /src/app-xml present update to bin-debug folder
		if (AS3.as(descriptorFile.exists, Bool)) {
			appXML = rootPath + File.separator + descriptorName;
			descriptorFile.copyTo(AS3.as(project.folderLocation.resolvePath(appXML).fileBridge.getFile, File), true);
			descriptorFile = AS3.as(project.folderLocation.resolvePath(appXML).fileBridge.getFile, File);
			var stream:FileStream = new FileStream();
			stream.open(descriptorFile, FileMode.READ);
			var data:String = Std.string(Std.string(stream.readUTFBytes(descriptorFile.size)));
			stream.close();

			// store namespace version for later probable use
			var firstNamespaceQuote:Int = data.indexOf('"', data.indexOf('<application xmlns=')) + 1;
			var lastNamespaceQuote:Int = data.indexOf('"', firstNamespaceQuote);
			var currentAIRNamespaceVersion:String = data.substring(firstNamespaceQuote, lastNamespaceQuote);

			// replace if appropriate
			data = new as3hx.Compat.Regex('<content>.*?<\\/content>', '').replace(data, '<content>' + project.swfOutput.path.fileBridge.name + '</content>');
			data = StringTools.replace(data, currentAIRNamespaceVersion, 'http://ns.adobe.com/air/application/' + project.swfOutput.swfVersion + '.0');
			if (data.indexOf('_') != -1) {
				// MOON-108
				// Since underscore char is not allowed in <id> we'll need to replace it
				var idFirstIndex:Int = data.indexOf('<id>');
				var idLastIndex:Int = data.indexOf('</id>');
				var dataIdValue:String = data.substring(idFirstIndex, idLastIndex + 5);

				var pattern:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('(_)', 'g'));
				var newID:String = pattern.replace(dataIdValue, '');
				data = StringTools.replace(data, dataIdValue, newID);
			}

			stream = new FileStream();
			stream.open(descriptorFile, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();
		}

		if (!AS3.as(descriptorFile.exists, Bool)) {
			descriptorFile = AS3.as(project.folderLocation.resolvePath('application.xml').fileBridge.getFile, File);
			if (AS3.as(descriptorFile.exists, Bool)) {
				appXML = 'application.xml';
			}
		}
		return appXML;
	}

}