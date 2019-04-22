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
package actionScripts.locator;

import mx.collections.ArrayCollection;
import mx.core.IFlexDisplayObject;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IAboutBridge;
import actionScripts.interfaces.IClipboardBridge;
import actionScripts.interfaces.IContextMenuBridge;
import actionScripts.interfaces.IFileBridge;
import actionScripts.interfaces.IFlexCoreBridge;
import actionScripts.interfaces.IJavaBridge;
import actionScripts.interfaces.ILanguageServerBridge;
import actionScripts.interfaces.IVisualEditorBridge;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.MainView;
import actionScripts.utils.NoSDKNotifier;
import actionScripts.valueObjects.ProjectVO;

@:meta(Bindable())class IDEModel {

	private static var instance:IDEModel;

	public static function getInstance():IDEModel {
		if (instance == null) {
			instance = new IDEModel();
		}
		return instance;
	}

	public var fileCore:IFileBridge;
	public var contextMenuCore:IContextMenuBridge;
	public var flexCore:IFlexCoreBridge;
	public var aboutCore:IAboutBridge;
	public var clipboardCore:IClipboardBridge;
	public var visualEditorCore:IVisualEditorBridge;
	public var javaCore:IJavaBridge;
	public var languageServerCore:ILanguageServerBridge;

	// Currently active editor
	public var activeEditor:IContentWindow;

	// Array of current editors
	public var editors:ArrayCollection = new ArrayCollection();
	public var projects:ArrayCollection = new ArrayCollection();
	public var selectedprojectFolders:ArrayCollection = new ArrayCollection();
	public var mainView:MainView;

	public var activeProject:ProjectVO;
	public var defaultSDK:FileLocation;
	public var noSDKNotifier:NoSDKNotifier = NoSDKNotifier.getInstance();
	public var sdkInstallerView:IFlexDisplayObject;
	public var antHomePath:FileLocation;
	public var antScriptFile:FileLocation;
	public var mavenPath:String;
	public var javaPathForTypeAhead:FileLocation;
	public var svnPath:String;
	public var gitPath:String;
	public var isCodeCompletionJavaPresent:Bool = false;
	public var payaraServerLocation:FileLocation;

	public var recentlyOpenedFiles:ArrayCollection = new ArrayCollection();
	public var recentlyOpenedProjects:ArrayCollection = new ArrayCollection();
	public var recentlyOpenedProjectOpenedOption:ArrayCollection = new ArrayCollection();
	public var recentSaveProjectPath:ArrayCollection = new ArrayCollection();
	public var userSavedSDKs:ArrayCollection = new ArrayCollection();
	public var userSavedTempSDKPath:String;
	public var isIndividualCloseTabAlertShowing:Bool = false;
	public var saveFilesBeforeBuild:Bool = false;

	public var openPreviouslyOpenedProjects:Bool = false;
	public var openPreviouslyOpenedProjectBranches:Bool = false;
	public var openPreviouslyOpenedFiles:Bool = false;
	public var confirmApplicationExit:Bool = false;
	public var showHiddenPaths:Bool = false;

	public var version:String = '1.0.0';
	public var build:String = '';

	public function removeEditor(editor:Dynamic):Bool {
		var index:Int = AS3.int(editors.getItemIndex(editor));
		if (index > -1) {
			editors.removeItemAt(index);
			return true;
		}

		return false;
	}

	public function refreshIdeBuildVersion():Void {
		build = '';

		var revisionInfoFile:FileLocation = fileCore.resolveApplicationDirectoryPath('elements/appProperties.txt');
		if (AS3.as(revisionInfoFile.fileBridge.exists, Bool)) {
			var buildNumber:String = Std.string(revisionInfoFile.fileBridge.read()).split('\n')[0];
			if (buildNumber != null && buildNumber.indexOf('bamboo') == -1) {
				build = buildNumber;
			}
		}
	}

	public function getVersionWithBuildNumber():String {
		if (build != null) {
			return 'Version ' + version + ', Build ' + build;
		}

		return 'Version ' + version;
	}

	public function new() {}

}