////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;

import actionScripts.utils.UtilsCore;

@:meta(Bindable())class SDKReferenceVO {

	private static inline var JS_SDK_COMPILER_NEW:String = 'js/bin/mxmlc';
	private static inline var JS_SDK_COMPILER_OLD:String = 'bin/mxmlc';
	private static inline var FLEX_SDK_COMPILER:String = 'bin/fcsh';

	//--------------------------------------------------------------------------
	//
	//  PUBLIC VARIABLES
	//
	//--------------------------------------------------------------------------

	public var version:String;
	public var build:String;
	public var status:String;

	private var _path:String;

	public var path(get, set):String;
	private function set_path(value:String):String {
		_path = value;
		return value;
	}

	private function get_path():String {
		return _path;
	}

	private var _outputTargets:Array<Dynamic>;

	public var outputTargets(get, set):Array<Dynamic>;
	private function get_outputTargets():Array<Dynamic> {
		return _outputTargets;
	}

	private function set_outputTargets(value:Array<Dynamic>):Array<Dynamic> {
		_outputTargets = value;
		return value;
	}

	private var _name:String;

	public var name(get, set):String;
	private function get_name():String {
		return _name;
	}

	private function set_name(value:String):String {
		if (value != _name) {
			_name = getNameOfSdk(value);
		}
		return value;
	}

	public var isJSOnlySdk(get, never):Bool;
	private function get_isJSOnlySdk():Bool {
		if (outputTargets != null && outputTargets.length == 1) {
			return Reflect.field(outputTargets[0], 'name') == 'js';
		}

		return false;
	}

	private var _fileLocation:FileLocation;

	public var fileLocation(get, never):FileLocation;
	private function get_fileLocation():FileLocation {
		if (_fileLocation == null) {
			_fileLocation = new FileLocation(path);
		}

		return _fileLocation;
	}

	private var _type:String;

	public var type(get, never):String;
	private function get_type():String {
		if (_type == null) {
			_type = getType();
		}
		return _type;
	}

	public var hasPlayerglobal(get, never):Bool;
	private function get_hasPlayerglobal():Bool {
		if (type == SDKTypes.ROYALE && !isJSOnlySdk) {
			var separator:String = Std.string(fileLocation.fileBridge.separator);
			var playerGlobalVersion:String = getPlayerGlobalVersion();
			var playerGlobalLocation:FileLocation = new FileLocation(Std.string(fileLocation.fileBridge.nativePath.concat(separator,
							'frameworks', separator, 'libs', separator, 'player',
							separator, playerGlobalVersion, separator, 'playerglobal.swc'
				)));

			return AS3.as(playerGlobalLocation.fileBridge.exists, Bool);
		}

		return type == SDKTypes.FLEX || type == SDKTypes.FEATHERS;
	}

	public static function getNewReference(value:Dynamic):SDKReferenceVO {
		var tmpRef:SDKReferenceVO = new SDKReferenceVO();
		if (Reflect.hasField(value, 'build')) {
			tmpRef.build = AS3.string(Reflect.field(value, 'build'));
		}
		if (Reflect.hasField(value, 'name')) {
			tmpRef.name = AS3.string(Reflect.field(value, 'name'));
		}
		if (Reflect.hasField(value, 'path')) {
			tmpRef.path = AS3.string(Reflect.field(value, 'path'));
		}
		if (Reflect.hasField(value, 'status')) {
			tmpRef.status = AS3.string(Reflect.field(value, 'status'));
		}
		if (Reflect.hasField(value, 'version')) {
			tmpRef.version = AS3.string(Reflect.field(value, 'version'));
		}

		return tmpRef;
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE API
	//
	//--------------------------------------------------------------------------

	private function getNameOfSdk(providedName:String):String {
		var suffixName:String = '(';
		var suffixSwf:String = '';

		if (outputTargets != null) {
			var outputTargesCount:Int = outputTargets.length;
			for (i in 0...outputTargesCount) {
				var outputTarget:RoyaleOutputTarget = outputTargets[i];
				if (outputTarget.flashVersion != null || outputTarget.airVersion != null) {
					suffixSwf = 'FP' + outputTarget.flashVersion + ' AIR' + outputTarget.airVersion + ' ';
				}

				if (outputTargesCount > 1 && outputTargesCount - 1 <= i) {
					suffixName += ', ' + outputTarget.name.toUpperCase();
				} else {
					suffixName += outputTarget.name.toUpperCase();
				}
			}
		}

		if (suffixName.length > 1) {
			return providedName + ' ' + suffixSwf + suffixName + ')';
		}

		return providedName;
	}

	private function getType():String {
		// flex
		var compilerExtension:String = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '' : '.bat';
		var compilerFile:FileLocation = fileLocation.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
		if (AS3.as(compilerFile.fileBridge.exists, Bool)) {
			if (AS3.as(fileLocation.resolvePath('frameworks/libs/spark.swc').fileBridge.exists, Bool) ||
				AS3.as(fileLocation.resolvePath('frameworks/libs/flex.swc').fileBridge.exists, Bool)) {
				return SDKTypes.FLEX;
			}
		}

		// royale
		compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
		if (AS3.as(compilerFile.fileBridge.exists, Bool)) {
			if (AS3.as(fileLocation.resolvePath('frameworks/royale-config.xml').fileBridge.exists, Bool)) {
				return SDKTypes.ROYALE;
			}
		}

		// feathers
		compilerFile = fileLocation.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
		if (AS3.as(compilerFile.fileBridge.exists, Bool)) {
			if (AS3.as(fileLocation.resolvePath('frameworks/libs/feathers.swc').fileBridge.exists, Bool)) {
				return SDKTypes.FEATHERS;
			}
		}

		// flexjs
		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = UtilsCore.isNewerVersionSDKThan(7, this.path);

		compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
		if (isFlexJSAfter7 && AS3.as(compilerFile.fileBridge.exists, Bool)) {
			if (name.toLowerCase().indexOf('flexjs') != -1) {
				return SDKTypes.FLEXJS;
			}
		} else if (!isFlexJSAfter7) {
			compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_OLD + compilerExtension);
			if (AS3.as(compilerFile.fileBridge.exists, Bool)) {
				if (name.toLowerCase().indexOf('flexjs') != -1) {
					return SDKTypes.FLEXJS;
				}
			}
		}

		return null;
	}

	public function getPlayerGlobalVersion():String {
		for (target_ in outputTargets) {
			var target:RoyaleOutputTarget = cast target_;
			if (AS3.as(Reflect.field(target, 'flashVersion'), Bool)) {
				return AS3.string(Reflect.field(target, 'flashVersion'));
			}
		}

		return null;
	}

	public function new() {}

}