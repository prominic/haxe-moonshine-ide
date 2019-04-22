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
package actionScripts.plugin.actionscript.as3project.vo;

import actionScripts.factory.FileLocation;
import actionScripts.utils.SerializeUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.MobileDeviceVO;
import actionScripts.valueObjects.SDKReferenceVO;

class BuildOptions {

	public static var defaultOptions:BuildOptions = new BuildOptions();
	public static inline var TYPE_FB:String = 'TYPE_FB';
	public static inline var TYPE_FD:String = 'TYPE_FD';

	//https://help.adobe.com/en_US/flashbuilder/using/WSe4e4b720da9dedb5-6caff02f136a645e895-7ffe.html
	//standard takes longer to package is suitable for submission to the app store
	public static inline var IOS_PACKAGING_STANDARD:String = 'IOS_PACKAGING_STANDARD';
	//fast bypasses bytecode translation interprets the SWF
	public static inline var IOS_PACKAGING_FAST:String = 'IOS_PACKAGING_FAST';

	public var accessible:Bool = false;
	public var allowSourcePathOverlap:Bool = false;
	public var benchmark:Bool = false;
	public var es:Bool = false;
	public var locale:String;
	public var loadConfig:String;
	public var optimize:Bool = true;
	public var showActionScriptWarnings:Bool = true;
	public var showBindingWarnings:Bool = true;
	public var showDeprecationWarnings:Bool = true;
	public var showUnusedTypeSelectorWarnings:Bool = true;
	public var strict:Bool = true;
	public var useNetwork:Bool = true;
	public var useResourceBundleMetadata:Bool = true;
	public var warnings:Bool = true;
	public var verboseStackTraces:Bool = false;
	public var linkReport:String;
	public var staticLinkRSL:Bool = false;
	public var additional:String;
	public var compilerConstants:String;
	public var customSDKPath:String;
	public var certAndroid:String;
	public var certAndroidPassword:String;
	public var certIos:String;
	public var certIosPassword:String;
	public var certIosProvisioning:String;
	public var iosPackagingMode:String = IOS_PACKAGING_FAST;

	public var antBuildPath:String;

	private var _targetPlatform:String;
	public var oldDefaultSDKPath:String;

	public var targetPlatform(get, set):String;
	private function set_targetPlatform(value:String):String {
		_targetPlatform = value;
		return value;
	}

	private function get_targetPlatform():String {
		return _targetPlatform;
	}

	private var _isMobileRunOnSimulator:Bool = true;

	public var isMobileRunOnSimulator(get, set):Bool;
	private function set_isMobileRunOnSimulator(value:Bool):Bool {
		_isMobileRunOnSimulator = value;
		return value;
	}

	private function get_isMobileRunOnSimulator():Bool {
		return _isMobileRunOnSimulator;
	}

	private var _isMobileHasSimulatedDevice:MobileDeviceVO;

	public var isMobileHasSimulatedDevice(get, set):MobileDeviceVO;
	private function set_isMobileHasSimulatedDevice(value:MobileDeviceVO):MobileDeviceVO {
		_isMobileHasSimulatedDevice = value;
		return value;
	}

	private function get_isMobileHasSimulatedDevice():MobileDeviceVO {
		return _isMobileHasSimulatedDevice;
	}

	public var customSDK(get, never):FileLocation;
	private function get_customSDK():FileLocation {
		if (customSDKPath != null) {
			var sdkReference:SDKReferenceVO = UtilsCore.getUserDefinedSDK(customSDKPath, 'path');
			if (sdkReference != null) {
				var tmpSDK:FileLocation = new FileLocation(sdkReference.path);
				tmpSDK.fileBridge.canonicalize();
				return tmpSDK;
			}
		}
		return null;
	}

	/**
	 * @return mxmlc arguments with defaults removed
	 */
	public function getArguments():String {
		var pairs:Dynamic = getArgumentPairs();
		var dpairs:Dynamic = defaultOptions.getArgumentPairs();
		var args:String = '';
		for (p in Reflect.fields(pairs)) {
			if (isArgumentExistsInAdditionalOptions(p)) {
				continue;
			}

			if (Reflect.field(pairs, p) != Reflect.field(dpairs, p)) {
				args += ' -' + p + '=' + Reflect.field(pairs, p);
			}
		}
		if (additional != null && (StringTools.trim(additional).length > 0)) {
			args += ' ' + StringTools.replace(additional, '\n', ' ');
		}
		if (args.indexOf('-locale ') != -1) {
			var tmpSplit:Array<String> = args.split(' ');
			var localeArray:Array<Dynamic> = [];
			var i:Int = 0;
			while (i < tmpSplit.length) {
				if (tmpSplit[i] == '-locale' || (tmpSplit[i].indexOf('_') != -1)) {
					if (tmpSplit[i] != '-locale') {
						localeArray.push(tmpSplit[i]);
					}
					tmpSplit.splice(i, 1);
					i--;
				}
				i++;
			}

			args = tmpSplit.join(' ') + ' -locale=' + localeArray.join(',');
		}
		return args;
	}

	public function parse(build:FastXMLList, parseType:String = TYPE_FD):Void {
		if (parseType == TYPE_FD) {
			var options:FastXMLList = build.descendants('option');

			accessible = SerializeUtil.deserializeBoolean(options.att.accessible);
			allowSourcePathOverlap = SerializeUtil.deserializeBoolean(options.att.allowSourcePathOverlap);
			benchmark = SerializeUtil.deserializeBoolean(options.att.benchmark);
			es = SerializeUtil.deserializeBoolean(options.att.es);
			optimize = SerializeUtil.deserializeBoolean(options.att.optimize);
			showActionScriptWarnings = SerializeUtil.deserializeBoolean(options.att.showActionScriptWarnings);
			showBindingWarnings = SerializeUtil.deserializeBoolean(options.att.showBindingWarnings);
			showDeprecationWarnings = SerializeUtil.deserializeBoolean(options.att.showDeprecationWarnings);
			showUnusedTypeSelectorWarnings = SerializeUtil.deserializeBoolean(options.att.showUnusedTypeSelectorWarnings);
			strict = SerializeUtil.deserializeBoolean(options.att.strict);
			useNetwork = SerializeUtil.deserializeBoolean(options.att.useNetwork);
			useResourceBundleMetadata = SerializeUtil.deserializeBoolean(options.att.useResourceBundleMetadata);
			warnings = SerializeUtil.deserializeBoolean(options.att.warnings);
			verboseStackTraces = SerializeUtil.deserializeBoolean(options.att.verboseStackTraces);
			staticLinkRSL = SerializeUtil.deserializeBoolean(options.att.staticLinkRSL);

			locale = SerializeUtil.deserializeString(options.att.locale);
			loadConfig = SerializeUtil.deserializeString(options.att.loadConfig);
			linkReport = SerializeUtil.deserializeString(options.att.linkReport);
			additional = SerializeUtil.deserializeString(options.att.additional);
			compilerConstants = SerializeUtil.deserializeString(options.att.compilerConstants);
			customSDKPath = SerializeUtil.deserializeString(options.att.customSDK);
			antBuildPath = SerializeUtil.deserializeString(options.att.antBuildPath);
		} else if (parseType == TYPE_FB) {
			additional = Std.string(StringTools.trim(build.att.additionalCompilerArguments));
			// FB seems to keep it as -switch value, while mxmlc takes -switch=value
			//additional = tmpAdditional.replace(/\s+/g,",").replace(/-([^,]+),([^-]+)/g,"-$1=$2");
			warnings = SerializeUtil.deserializeBoolean(build.att.warn);
			accessible = SerializeUtil.deserializeBoolean(build.att.generateAccessible);
			strict = SerializeUtil.deserializeBoolean(build.att.strict);
			customSDKPath = SerializeUtil.deserializeString(build.att.flexSDK);
		}
	}

	public function toXML():FastXML {
		var build:FastXML = FastXML.parse('<build/>');

		var pairs:Dynamic = {
			'accessible': SerializeUtil.serializeBoolean(accessible),
			'allowSourcePathOverlap': SerializeUtil.serializeBoolean(allowSourcePathOverlap),
			'benchmark': SerializeUtil.serializeBoolean(benchmark),
			'es': SerializeUtil.serializeBoolean(es),
			'optimize': SerializeUtil.serializeBoolean(optimize),
			'showActionScriptWarnings': SerializeUtil.serializeBoolean(showActionScriptWarnings),
			'showBindingWarnings': SerializeUtil.serializeBoolean(showBindingWarnings),
			'showDeprecationWarnings': SerializeUtil.serializeBoolean(showDeprecationWarnings),
			'showUnusedTypeSelectorWarnings': SerializeUtil.serializeBoolean(showUnusedTypeSelectorWarnings),
			'strict': SerializeUtil.serializeBoolean(strict),
			'useNetwork': SerializeUtil.serializeBoolean(useNetwork),
			'useResourceBundleMetadata': SerializeUtil.serializeBoolean(useResourceBundleMetadata),
			'warnings': SerializeUtil.serializeBoolean(warnings),
			'verboseStackTraces': SerializeUtil.serializeBoolean(verboseStackTraces),
			'staticLinkRSL': SerializeUtil.serializeBoolean(staticLinkRSL),
			'locale': SerializeUtil.serializeString(locale),
			'loadConfig': SerializeUtil.serializeString(loadConfig),
			'linkReport': SerializeUtil.serializeString(linkReport),
			'additional': SerializeUtil.serializeString(additional),
			'compilerConstants': SerializeUtil.serializeString(compilerConstants),
			'customSDK': SerializeUtil.serializeString(customSDKPath),
			'antBuildPath': SerializeUtil.serializeString(antBuildPath)
		};

		build.node.appendChild(SerializeUtil.serializePairs(pairs, FastXML.parse('<option/>')));

		return build;
	}

	private function isArgumentExistsInAdditionalOptions(name:String):Bool {
		if (additional == null) {
			return false;
		}

		var trimmedAdditionalOptions:String = Std.string(StringTools.trim(additional));
		if (trimmedAdditionalOptions.length == 0) {
			return false;
		}

		return trimmedAdditionalOptions.indexOf('-' + name) > -1 || trimmedAdditionalOptions.indexOf('+' + name) > -1;
	}

	private function getArgumentPairs():Dynamic {
		return {
			'load-config+': loadConfig,
			'accessible': accessible,
			'allow-source-path-overlap': allowSourcePathOverlap,
			'benchmark': benchmark,
			'es': es,
			'as3': !es,
			'optimize': optimize,
			'show-actionscript-warnings': showActionScriptWarnings,
			'show-binding-warnings': showBindingWarnings,
			'show-deprecation-warnings': showDeprecationWarnings,
			'show-unused-type-selector-warnings': showUnusedTypeSelectorWarnings,
			'strict': strict,
			'use-network': useNetwork,
			'use-resource-bundle-metadata': useResourceBundleMetadata,
			'warnings': warnings,
			'verbose-stacktraces': verboseStackTraces,
			'link-report': linkReport,
			'static-link-runtime-shared-libraries': staticLinkRSL
		};
	}

	public function new() {}

}