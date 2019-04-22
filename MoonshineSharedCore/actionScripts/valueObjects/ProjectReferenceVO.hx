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
package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;

class ProjectReferenceVO {

	public var name:String;
	public var path:String = '';
	public var startIn:String = '';
	public var status:String = '';
	public var loading:Bool = false;
	public var sdk:String;
	public var isAway3D:Bool = false;
	public var isTemplate:Bool = false;
	public var hiddenPaths:Array<FileLocation> = new Array<FileLocation>();
	public var showHiddenPaths:Bool = false;

	public function new() {}

	//--------------------------------------------------------------------------
	//
	//  PUBLIC STATIC API
	//
	//--------------------------------------------------------------------------

	/**
	 * Static method to translate config
	 * SO data in a loosely-coupled manner
	 */
	public static function getNewRemoteProjectReferenceVO(value:Dynamic):ProjectReferenceVO {
		var tmpVO:ProjectReferenceVO = new ProjectReferenceVO();

		// value submission
		if (Reflect.hasField(value, 'name')) {
			tmpVO.name = AS3.string(Reflect.field(value, 'name'));
		}
		if (Reflect.hasField(value, 'path')) {
			tmpVO.path = AS3.string(Reflect.field(value, 'path'));
		}
		if (Reflect.hasField(value, 'startIn')) {
			tmpVO.startIn = AS3.string(Reflect.field(value, 'startIn'));
		}
		if (Reflect.hasField(value, 'status')) {
			tmpVO.status = AS3.string(Reflect.field(value, 'status'));
		}
		if (Reflect.hasField(value, 'loading')) {
			tmpVO.loading = AS3.as(Reflect.field(value, 'loading'), Bool);
		}
		if (Reflect.hasField(value, 'sdk')) {
			tmpVO.sdk = AS3.string(Reflect.field(value, 'sdk'));
		}
		if (Reflect.hasField(value, 'isAway3D')) {
			tmpVO.isAway3D = AS3.as(Reflect.field(value, 'isAway3D'), Bool);
		}
		if (Reflect.hasField(value, 'isTemplate')) {
			tmpVO.isTemplate = AS3.as(Reflect.field(value, 'isTemplate'), Bool);
		}

		// finally
		return tmpVO;
	}

}