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
package actionScripts.ui.menu.vo;

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

class ProjectMenuTypes {

	public static inline var FLEX_AS:String = 'flexASproject';
	public static inline var PURE_AS:String = 'pureASProject';
	public static inline var JS_ROYALE:String = 'flexJSroyale';
	public static inline var VISUAL_EDITOR_FLEX:String = 'visualEditorFlex';
	public static inline var VISUAL_EDITOR_PRIMEFACES:String = 'visualEditorPrimefaces';
	public static inline var LIBRARY_FLEX_AS:String = 'libraryFlexAS';
	public static inline var GIT_PROJECT:String = 'gitProject';
	public static inline var SVN_PROJECT:String = 'svnProject';
	public static inline var JAVA:String = 'java';

	public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS:Array<Dynamic>;
	public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE:Array<Dynamic>;

	private static var resourceManager:IResourceManager = ResourceManager.getInstance();
	private static var ProjectMenuTypes_static_initializer = {
		{
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS = [resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE'), resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE')];
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE = cast [VISUAL_EDITOR_FLEX, VISUAL_EDITOR_PRIMEFACES];
		};
		true;
	}

}