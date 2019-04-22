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
package actionScripts.factory;

import actionScripts.interfaces.IClipboardBridge;
import actionScripts.interfaces.IVisualEditorBridge;
import flash.system.ApplicationDomain;
import actionScripts.interfaces.IAboutBridge;
import actionScripts.interfaces.IContextMenuBridge;
import actionScripts.interfaces.IFileBridge;
import actionScripts.interfaces.IFlexCoreBridge;
import actionScripts.interfaces.IJavaBridge;
import actionScripts.interfaces.ILanguageServerBridge;

/**
 * BridgeFactory
 *
 *
 * @date 01.17.2013
 * @version 1.0
 */
class BridgeFactory {

	//--------------------------------------------------------------------------
	//
	//  PUBLIC API
	//
	//--------------------------------------------------------------------------

	/**
	 * Returns the bridge instance for
	 * file API implementation
	 */
	public static function getFileInstance():IFileBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IFileBridgeImp');
		var gb:IFileBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getFileInstanceObject():Dynamic {
		return getClassToCreate('actionScripts.impls.IFileBridgeImp');
	}

	public static function getContextMenuInstance():IContextMenuBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IContextMenuBridgeImp');
		var gb:IContextMenuBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getClipboardInstance():IClipboardBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IClipboardBridgeImp');
		var gb:IClipboardBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getNativeMenuItemInstance():Dynamic {
		return getClassToCreate('actionScripts.impls.INativeMenuItemBridgeImp');
	}

	public static function getFlexCoreInstance():IFlexCoreBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IFlexCoreBridgeImp');
		var gb:IFlexCoreBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getVisualEditorInstance():IVisualEditorBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IVisualEditorProjectBridgeImpl');
		var gb:IVisualEditorBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getAboutInstance():IAboutBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IAboutBridgeImp');
		var gb:IAboutBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getJavaInstance():IJavaBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.IJavaBridgeImpl');
		var gb:IJavaBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	public static function getLanguageServerCoreInstance():ILanguageServerBridge {
		var clsToCreate:Dynamic = getClassToCreate('actionScripts.impls.ILanguageServerBridgeImp');
		var gb:ILanguageServerBridge = Type.createInstance(clsToCreate, []);
		return gb;
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE API
	//
	//--------------------------------------------------------------------------

	/**
	 * Retreives the Class definition from
	 * running project
	 *
	 * @required
	 * Class name
	 * @return
	 * Class
	 */
	private static function getClassToCreate(className:String):Dynamic {
		var tmpClass:Dynamic = ApplicationDomain.currentDomain.getDefinition(className);
		return tmpClass;
	}

}