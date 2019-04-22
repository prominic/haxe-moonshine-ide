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
package actionScripts.interfaces;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import mx.core.IFlexDisplayObject;
import actionScripts.events.NewProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.ui.IPanelWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.valueObjects.FileWrapper;

/**
 * IFlexCoreBridge
 *
 *
 * @date 10.28.2015
 * @version 1.0
 *
 * All methods those particularly useful
 * in multiple projects (AIR or Web)
 */
interface IFlexCoreBridge {

	//--------------------------------------------------------------------------
	//
	//  PUBLIC METHODS
	//
	//--------------------------------------------------------------------------

	function parseFlashDevelop(project:AS3ProjectVO = null, file:FileLocation = null, projectName:String = null):AS3ProjectVO;

	function parseFlashBuilder(file:FileLocation):AS3ProjectVO;

	function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):Void;

	function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):Void;

	function testFlashDevelop(file:Dynamic):FileLocation;

	function testFlashBuilder(file:Dynamic):FileLocation;

	function getQuitMenuItem():MenuItem;

	function getSettingsMenuItem():MenuItem;

	function getAboutMenuItem():MenuItem;

	function getWindowsMenu():Array<MenuItem>;

	function getHTMLView(url:String):DisplayObject;

	function getAccessManagerPopup():IFlexDisplayObject;

	function getSDKInstallerView():IFlexDisplayObject;

	function getTourDeView():IPanelWindow;

	function getTourDeEditor(swfSource:String):BasicTextEditor;

	function getNewAntBuild():IFlexDisplayObject;

	function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):Void;

	function removeExAttributesTo(path:String):Void;

	function getJavaPath(completionHandler:Function):Void;

	function reAdjustApplicationSize(width:Float, height:Float):Void;

	function createProject(event:NewProjectEvent):Void;

	function importArchiveProject():Void;

	function updateToCurrentEnvironmentVariable():Void;

	/**
	 *
	 * @param projectWrapper
	 * @param finishHandler - handler must return FileWrapper object
	 */
	function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Bool = false):Void;

	function getCorePlugins():Array<Dynamic>;

	function getDefaultPlugins():Array<Dynamic>;

	function getPluginsNotToShowInSettings():Array<Dynamic>;

	var runtimeVersion(get, never):String;
	var version(get, never):String;

}