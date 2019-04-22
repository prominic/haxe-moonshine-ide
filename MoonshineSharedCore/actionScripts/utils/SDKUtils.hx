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
package actionScripts.utils;

import flash.events.Event;
import flash.events.EventDispatcher;
import mx.collections.ArrayCollection;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.NewFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.RoyaleOutputTarget;
import actionScripts.valueObjects.SDKReferenceVO;

class SDKUtils extends EventDispatcher {

	public static inline var BUNDLED:String = 'Bundled';
	public static inline var EVENT_SDK_EXTRACTED:String = 'EVENT_SDK_EXTRACTED';
	public static inline var EVENT_SDK_EXTRACTION_FAILED:String = 'EVENT_SDK_EXTRACTION_FAILED';
	public static inline var EVENT_SDK_PROMPT_DNS:String = 'EVENT_SDK_PROMPT_DNS';
	public static inline var EXTRACTED_FOLDER_NAME:String = 'MoonshineSDKs';

	private static var SDKS(default, never):Array<Dynamic> = cast ['FlexJS_SDK', 'Flex_SDK', 'Royale_SDK'];

	private static var currentSDKIndex:Int = 0;
	private static var isSDKExtractionFailed:Bool = false;

	public static function checkBundledSDKPresence():Void {
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			var tmpLocation:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath('defaultSDKs/flexSDK.tar.gz');
			if (AS3.as(tmpLocation.fileBridge.exists, Bool)) {
				ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT = true;
			}
		}
	}

	public static function checkHelperDownloadedSDKPresence():Void {
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
			if (!AS3.as(downloadsFolder.fileBridge.exists, Bool)) {
				return;
			}

			var tmpDirListing:Array<Dynamic>;
			var tmpFolder:FileLocation;
			var j:Dynamic;

			// finding probable Flex/JS SDKs
			for (i in 0...SDKS.length) {
				tmpFolder = downloadsFolder.resolvePath(Std.string(SDKS[i]));
				if (AS3.as(tmpFolder.fileBridge.exists, Bool)) {
					tmpDirListing = tmpFolder.fileBridge.getDirectoryListing();
					for (j in tmpDirListing) {
						if (AS3.as(Reflect.field(j, 'isDirectory'), Bool) && ((Reflect.field(j, 'name').toLowerCase().indexOf('flex') != -1) || (Reflect.field(j, 'name').toLowerCase().indexOf('royale') != -1))) {
							ConstantsCoreVO.IS_HELPER_DOWNLOADED_SDK_PRESENT = true;
							break;
						}
					}
				}
			}

			// finding probable Ant SDK
			tmpFolder = downloadsFolder.resolvePath('Ant');
			if (AS3.as(tmpFolder.fileBridge.exists, Bool)) {
				tmpDirListing = tmpFolder.fileBridge.getDirectoryListing();
				for (j in tmpDirListing) {
					if (AS3.as(Reflect.field(j, 'isDirectory'), Bool) && AS3.as(j.resolvePath('bin/ant').exists, Bool)) {
						ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT = j;
						if (IDEModel.getInstance().antHomePath == null) {
							GlobalEventDispatcher.getInstance().dispatchEvent(new NewFileEvent(NewFileEvent.EVENT_ANT_BIN_URL_SET, AS3.string(Reflect.field(j, 'nativePath'))));
						}
						break;
					}
				}
			}
		}
	}

	public static function extractBundledSDKs(event:Event):Void {
		if (isSDKExtractionFailed) {
			isSDKExtractionFailed = false;
			currentSDKIndex = 0;
			return;
		}

		var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
		if (!AS3.as(downloadsFolder.fileBridge.exists, Bool)) {
			downloadsFolder.fileBridge.createDirectory();
		}

		if (currentSDKIndex < SDKS.length) {
			var model:IDEModel = IDEModel.getInstance();
			var tmpLocation:FileLocation = model.fileCore.resolveApplicationDirectoryPath('defaultSDKs/' + SDKS[currentSDKIndex] + '.tar.gz');
			if (AS3.as(tmpLocation.fileBridge.exists, Bool)) {
				currentSDKIndex++;
				model.flexCore.untar(tmpLocation, downloadsFolder, extractBundledSDKs, onExtractionFailed);
			}
		} else {
			currentSDKIndex = 0;
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(EVENT_SDK_EXTRACTED));

			// remove com.apple.quarantine from extracted folders
			for (i in 0...SDKS.length) {
				IDEModel.getInstance().flexCore.removeExAttributesTo(downloadsFolder.fileBridge.nativePath + '/' + SDKS[i]);
			}
		}
	}

	public static function initBundledSDKs():Array<Dynamic> {
		function addSDKDirectory(value:SDKReferenceVO):Void {
			var tmpPR:SDKReferenceVO = new SDKReferenceVO();
			tmpPR.name = value.name;
			tmpPR.path = value.path;
			tmpPR.status = BUNDLED;
			model.userSavedSDKs.addItemAt(tmpPR, 0);
			isFound = true;
		};
		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			// this method should run once on application startup
			var isFound:Bool;
			var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
			if (!AS3.as(downloadsFolder.fileBridge.exists, Bool)) {
				return [];
			}

			var totalBundledSDKs:Array<Dynamic> = [];
			var model:IDEModel = IDEModel.getInstance();
			if (model.userSavedSDKs == null) {
				model.userSavedSDKs = new ArrayCollection();
			}
			for (i in 0...SDKS.length) {
				var targetDir:FileLocation = new FileLocation(downloadsFolder.fileBridge.nativePath + '/' + SDKS[i]);
				var bundledFlexSDK:SDKReferenceVO = getSDKReference(targetDir);
				if (bundledFlexSDK != null) {
					addSDKDirectory(bundledFlexSDK);
				} else if (AS3.as(targetDir.fileBridge.exists, Bool)) {
					// parse through if sdk folders present
					var tmpDirListing:Array<Dynamic> = targetDir.fileBridge.getDirectoryListing();
					for (j in tmpDirListing) {
						if (AS3.as(Reflect.field(j, 'isDirectory'), Bool) && ((Reflect.field(j, 'name').toLowerCase().indexOf('flex') != -1) || (Reflect.field(j, 'name').toLowerCase().indexOf('royale') != -1))) {
							bundledFlexSDK = getSDKReference(new FileLocation(AS3.string(Reflect.field(j, 'nativePath'))));
							if (bundledFlexSDK != null) {
								addSDKDirectory(bundledFlexSDK);
								totalBundledSDKs.push(bundledFlexSDK);
							}
						}
					}
				}
			}

			// set one as default sdk if requires
			var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
						if (isFound && model.defaultSDK == null) {
							setDefaultSDKByBundledSDK();
							GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, Reflect.getProperty(model.userSavedSDKs, Std.string(0))));
						}

						as3hx.Compat.clearTimeout(timeoutValue);
					}, 500); /**
			 * @local
			 */

			// send to owner
			return totalBundledSDKs;
		}

		// for non-OSX
		return [];
	}

	public static function setDefaultSDKByBundledSDK():Void {
		var model:IDEModel = IDEModel.getInstance();
		model.defaultSDK = new FileLocation(Std.string(Reflect.getProperty(model.userSavedSDKs, Std.string(0)).path));
	}

	public static function getSDKReference(location:FileLocation):SDKReferenceVO {
		if (location == null) {
			return null;
		}

		// lets load flex-sdk-description.xml to get it's label
		var description:FileLocation = location.fileBridge.resolvePath('royale-sdk-description.xml');
		if (!AS3.as(description.fileBridge.exists, Bool)) {
			description = location.fileBridge.resolvePath('royale-asjs/royale-sdk-description.xml');
		}
		if (!AS3.as(description.fileBridge.exists, Bool)) {
			description = location.fileBridge.resolvePath('flex-sdk-description.xml');
		}

		if (AS3.as(description.fileBridge.exists, Bool)) {
			// read the xml value to get SDK name
			var tmpXML:FastXML = FastXML.parse(description.fileBridge.read());
			var outputTargetsXml:FastXMLList = tmpXML.get('output-targets').get('output-target');
			var outputTargets:Array<Dynamic> = [];

			for (item in outputTargetsXml) {
				outputTargets.push(new RoyaleOutputTarget(Std.string(item.att.name), Std.string(item.att.version), Std.string(item.att.AIR), Std.string(item.att.Flash)));
			}

			var displayName:String = Std.string(tmpXML.get('name'));
			if (description.fileBridge.name.indexOf('royale') > -1) {
				if (outputTargets.length == 1) {
					displayName = Std.string(displayName.concat(' ', tmpXML.node.version, ' (', Reflect.field(outputTargets[0], 'name'), ' only)'));
				} else {
					displayName += ' ' + tmpXML.node.version;
				}
			}

			var tmpSDK:SDKReferenceVO = new SDKReferenceVO();
			tmpSDK.path = Std.string(description.fileBridge.parent.fileBridge.nativePath);
			tmpSDK.name = displayName;
			tmpSDK.version = Std.string(tmpXML.node.version);
			tmpSDK.build = Std.string(tmpXML.node.build);
			tmpSDK.outputTargets = outputTargets;

			return tmpSDK;
		}

		// non-sdk case
		return null;
	}

	public static function isSDKAlreadySaved(sdkObject:Dynamic):SDKReferenceVO {
		// add sdk
		// don't add if said sdk already added
		var isAlreadyAdded:Bool;
		var model:IDEModel = IDEModel.getInstance();
		for (i in model.userSavedSDKs) {
			if (Reflect.field(i, 'path') == Reflect.field(sdkObject, 'path')) {
				return i;
			}
		}

		if (!(Std.is(sdkObject, SDKReferenceVO)) && !isAlreadyAdded) {
			var tmp:SDKReferenceVO = new SDKReferenceVO();
			tmp.name = AS3.string(Reflect.field(sdkObject, 'label'));
			tmp.path = AS3.string(Reflect.field(sdkObject, 'path'));
			model.userSavedSDKs.addItem(tmp);
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, tmp));
			return tmp;
		} else if (!isAlreadyAdded) {
			model.userSavedSDKs.addItem(sdkObject);
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, sdkObject));
			return (AS3.as(sdkObject, SDKReferenceVO));
		}

		return null;
	}

	public static function getSDKFromSavedList(byPath:String):SDKReferenceVO {
		var model:IDEModel = IDEModel.getInstance();
		for (i in model.userSavedSDKs) {
			if (Reflect.field(i, 'path') == byPath) {
				return i;
			}
		}

		return null;
	}

	private static function getUserDownloadsSDKFolder(onlyDownloadsFolder:Bool = false):FileLocation {
		var tmpUserFolderSplit:Array<Dynamic> = IDEModel.getInstance().fileCore.resolveUserDirectoryPath().fileBridge.nativePath.split(IDEModel.getInstance().fileCore.separator);
		if (tmpUserFolderSplit[1] == 'Users') {
			tmpUserFolderSplit = tmpUserFolderSplit.slice(1, 3);
		}

		var extractionDir:FileLocation = ((!onlyDownloadsFolder)) ? new FileLocation('/' + tmpUserFolderSplit.join('/') + '/Downloads/' + EXTRACTED_FOLDER_NAME) : new FileLocation('/' + tmpUserFolderSplit.join('/') + '/Downloads');
		//if (!extractionDir.fileBridge.exists) extractionDir.fileBridge.createDirectory();

		return extractionDir;
	}

	public static function getSdkSwfMajorVersion(sdkPath:String = null, providerToUpdateAsync:Dynamic = null, fieldToUpdateAsync:String = null):Int {
		var currentSDKVersion:Int = 10;
		var sdk:FileLocation;
		if (sdkPath != null) {
			var isFound:SDKReferenceVO = UtilsCore.getUserDefinedSDK(sdkPath, 'path');
			if (isFound != null) {
				sdk = new FileLocation(isFound.path);
			}
		} else {
			sdk = IDEModel.getInstance().defaultSDK;
		}

		if (sdk != null && AS3.as(sdk.fileBridge.exists, Bool)) {
			var configFile:FileLocation = getSDKConfig(sdk);
			if (AS3.as(configFile.fileBridge.exists, Bool)) {
				// for async type of read and update to specific object's field
				if (AS3.as(providerToUpdateAsync, Bool)) {
					Reflect.setField(providerToUpdateAsync, fieldToUpdateAsync, currentSDKVersion);
					configFile.fileBridge.readAsync(providerToUpdateAsync, FastXML, Int, fieldToUpdateAsync, 'target-player');
				}// non-async direct return only
				else {
					var tmpConfigXML:FastXML = FastXML.parse(configFile.fileBridge.read());
					currentSDKVersion = AS3.int(tmpConfigXML.get('target-player'));
				}
			}
		}

		return currentSDKVersion;
	}

	public static function getSdkSwfMinorVersion(sdkPath:String = null):Int {
		var currentSdkMinorVersion:Int = 0;
		var sdk:FileLocation;
		if (sdkPath != null) {
			var isFound:SDKReferenceVO = UtilsCore.getUserDefinedSDK(sdkPath, 'path');
			if (isFound != null) {
				sdk = new FileLocation(isFound.path);
			}
		} else {
			sdk = IDEModel.getInstance().defaultSDK;
		}

		if (sdk != null && AS3.as(sdk.fileBridge.exists, Bool)) {
			var configFile:FileLocation = getSDKConfig(sdk);
			if (AS3.as(configFile.fileBridge.exists, Bool)) {
				var tmpConfigXML:FastXML = FastXML.parse(configFile.fileBridge.read());
				var targetPlayerVersion:String = Std.string(Std.string(tmpConfigXML.get('target-player')));
				var versionParts:Array<String> = targetPlayerVersion.split('.');
				if (versionParts.length > 1) {
					currentSdkMinorVersion = AS3.int(versionParts[1]);
				}
			}
		}

		return currentSdkMinorVersion;
	}

	public static function checkSDKTypeInSDKList(type:String):SDKReferenceVO {
		var model:IDEModel = IDEModel.getInstance();
		for (sdk in model.userSavedSDKs) {
			if (Reflect.field(sdk, 'type') == type) {
				return sdk;
			}
		}

		return null;
	}

	private static function onExtractionFailed(event:Event):Void {
		isSDKExtractionFailed = true;
		GlobalEventDispatcher.getInstance().dispatchEvent(new Event(EVENT_SDK_EXTRACTION_FAILED));
	}

	private static function getSDKConfig(sdkLocation:FileLocation):FileLocation {
		var configFile:FileLocation = sdkLocation.resolvePath('frameworks/royale-config.xml');
		if (!AS3.as(configFile.fileBridge.exists, Bool)) {
			configFile = sdkLocation.resolvePath('frameworks/flex-config.xml');
		}

		return configFile;
	}

}