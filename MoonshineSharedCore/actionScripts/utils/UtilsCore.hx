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
package actionScripts.utils;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.system.Capabilities;
import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.ToolTipEvent;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import mx.utils.UIDUtil;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
import actionScripts.plugin.settings.SettingsView;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.menu.vo.MenuItem;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.DataHTMLType;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.ResourceVO;
import actionScripts.valueObjects.SDKReferenceVO;
import components.popup.ModifiedFileListPopup;
import components.popup.SDKDefinePopup;
import components.popup.SDKSelectorPopup;
import components.renderers.CustomToolTipGBA;
import components.views.splashscreen.SplashScreen;

class UtilsCore {

	public static var wrappersFoundThroughFindingAWrapper:Array<FileWrapper>;

	private static var sdkPopup:SDKSelectorPopup;
	private static var sdkPathPopup:SDKDefinePopup;
	private static var model:IDEModel = IDEModel.getInstance();

	/**
	 * Get data agent error type
	 */
	public static function getDataType(value:String):DataHTMLType {
		var dataType:DataHTMLType = new DataHTMLType();
		var message:String;

		// true if it's a login agent call
		if ((value.indexOf('/Grails4NotesBroker/admin/auth') != -1) || (value.indexOf('Please Login') != -1)) {
			// error is a login error
			var indexToStart:Int = value.indexOf('<div class=\'login_message\'>');
			if (indexToStart > 0) {
				message = value.substring(indexToStart + 27, value.indexOf('</div>', indexToStart));
			} else {
				message = 'Please, check your username or password.';
			}

			dataType.message = message;
			dataType.type = DataHTMLType.LOGIN_ERROR;
			dataType.isError = true;
		} else if ((value.toLowerCase().indexOf('authenticated') != -1) || (value.toLowerCase().indexOf('welcome to grails') != -1)) {
			dataType.isError = false;
			dataType.type = DataHTMLType.LOGIN_SUCCESS;
		} else {
			dataType.message = 'Your session has expired. Please, re-login.';
			dataType.type = DataHTMLType.SESSION_ERROR;
			dataType.isError = true;
		}

		return dataType;
	}

	/**
	 * Checks through opened project list against
	 * a given path value
	 * @return
	 * BOOL
	 */
	public static function checkProjectIfAlreadyOpened(value:String):Bool {
		for (file in model.projects) {
			if (Reflect.field(Reflect.field(Reflect.field(file, 'folderLocation'), 'fileBridge'), 'nativePath') == value) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Creates custom tooltip
	 */
	public static function createCustomToolTip(event:ToolTipEvent):Void {
		var cTT:CustomToolTipGBA = new CustomToolTipGBA();
		event.toolTip = cTT;
	}

	/**
	 * Checks content of files to determine between
	 * binary and text
	 */
	public static function isBinary(fileContent:String):Bool {
		return (AS3.as(new as3hx.Compat.Regex('[\\x00-\\x08\\x0E-\\x1F]', '').test(fileContent), Bool));
	}

	/**
	 * Positions the toolTip
	 */
	public static function positionTip(event:ToolTipEvent):Void {
		var tmpPoint:Point = getContentToGlobalXY(AS3.as(event.currentTarget, UIComponent));
		event.toolTip.y = tmpPoint.y + 20;
		event.toolTip.x = event.toolTip.x - 20;
	}

	/**
	 * Determines if a project is AIR type
	 */
	public static function isAIR(project:AS3ProjectVO):Bool {
		// giving precedence to the as3proj value
		if (project.swfOutput.platform == SWFOutputVO.PLATFORM_AIR || project.swfOutput.platform == SWFOutputVO.PLATFORM_MOBILE) {
			return true;
		}

		if (project.targets.length > 0) {
			// considering that application descriptor file should exists in the same
			// root where application source file is exist
			var appFileName:String = Std.string(Reflect.getProperty(project.targets[0].fileBridge.name.split('.'), Std.string(0)));
			if (AS3.as(project.targets[0].fileBridge.parent.fileBridge.resolvePath('application.xml').fileBridge.exists, Bool)) {
				return true;
			} else if (AS3.as(project.targets[0].fileBridge.parent.fileBridge.resolvePath(appFileName + '-app.xml').fileBridge.exists, Bool)) {
				return true;
			}
		}

		if (project.isLibraryProject && project.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) {
			return true;
		}

		return false;
	}

	/**
	 * Determines if a project is mobile type
	 */
	public static function isMobile(project:AS3ProjectVO):Bool {
		// giving precedence to the as3proj value
		if (project.swfOutput.platform == SWFOutputVO.PLATFORM_MOBILE) {
			return true;
		}

		if (project.isLibraryProject) {
			if (project.buildOptions.additional != null && project.buildOptions.additional.indexOf('airmobile') != -1) {
				return true;
			}
		} else if (project.sourceFolder != null && AS3.as(project.sourceFolder.fileBridge.exists, Bool)) {
			var appFileName:String = Std.string(Reflect.getProperty(project.targets[0].fileBridge.name.split('.'), Std.string(0)));
			var descriptor:FileLocation = project.sourceFolder.fileBridge.resolvePath(appFileName + '-app.xml');
			if (AS3.as(descriptor.fileBridge.exists, Bool)) {
				var descriptorData:FastXML = FastXML.parse(descriptor.fileBridge.read());
				var tmpNameSearchString:String = '';
				for (i in as3hx.Compat.each(descriptorData.nodes.children())) {
					tmpNameSearchString += i.localName() + ' ';
				}

				return (tmpNameSearchString.indexOf('android') != -1) || (tmpNameSearchString.indexOf('iPhone') != -1);
			}
		}

		return false;
	}

	/**
	 * Getting a component co-ordinate
	 * in respect of global stage
	 */
	public static function getContentToGlobalXY(dObject:UIComponent):Point {
		var thisHolderPoint:Point = UIComponent(dObject.owner).contentToGlobal(new Point(dObject.x, dObject.y));
		var newP:Point = FlexGlobals.topLevelApplication.globalToContent(thisHolderPoint);
		return newP;
	}

	public static function fixSlashes(path:String):String {
		if (path == null) {
			return null;
		}

		//path = path.replace(/\//g, IDEModel.getInstance().fileCore.separator);
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			path = new as3hx.Compat.Regex('\\\\', 'g').replace(path, model.fileCore.separator);
		}
		return path;
	}

	public static function convertString(path:String):String {
		if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			path = path.split(' ').join('^ ');
			path = path.split('(').join('^(');
			path = path.split(')').join('^)');
			path = path.split('&').join('^&');
		} else {
			path = path.split(' ').join('\\ ');
			path = path.split('(').join('\\(');
			path = path.split(')').join('\\)');
			path = path.split('&').join('\\&');
		}
		return path;
	}

	public static function getUserDefinedSDK(searchByValue:String, searchByField:String):SDKReferenceVO {
		for (i in model.userSavedSDKs) {
			if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				searchByValue = new as3hx.Compat.Regex('(\\/)', 'g').replace(searchByValue, '\\');
			}
			if (Reflect.field(i, searchByField) == searchByValue) {
				return i;
			}
		}
		// if not found
		return null;
	}

	/**
	 * Returns project based on its path
	 */
	public static function getProjectByPath(value:String):ProjectVO {
		for (project in model.projects) {
			if (Reflect.field(Reflect.field(Reflect.field(project, 'folderLocation'), 'fileBridge'), 'nativePath') == value) {
				return project;
			}
		}

		return null;
	}

	/**
	 * Returns project based on its name
	 */
	public static function getProjectByName(projectName:String):ProjectVO {
		for (project in model.projects) {
			if (Reflect.field(project, 'projectName') == projectName) {
				return project;
			}
		}

		return null;
	}

	/**
	 * Returns projectVO against fileWrapper
	 */
	public static function getProjectFromProjectFolder(projectFolder:FileWrapper):ProjectVO {
		if (projectFolder == null) {
			return null;
		}

		for (p in model.projects) {
			if (Reflect.field(p, 'folderPath') == projectFolder.projectReference.path) {
				return p;
			}
		}

		return null;
	}

	/**
	 * Returns the probable SDK against a project
	 */
	public static function getCurrentSDK(pvo:AS3ProjectVO):FileLocation {
		return (pvo.buildOptions.customSDK != null) ? pvo.buildOptions.customSDK : model.defaultSDK;
	}

	/**
	 * Returns dotted package references
	 * against a project path
	 */
	public static function getPackageReferenceByProjectPath(classPaths:Array<FileLocation>, filePath:String = null, fileWrapper:FileWrapper = null, fileLocation:FileLocation = null, appendProjectNameAsPrefix:Bool = true):String {
		if (fileWrapper != null) {
			filePath = fileWrapper.nativePath;
		} else if (fileLocation != null) {
			filePath = Std.string(fileLocation.fileBridge.nativePath);
		}

		var separator:String = Std.string(model.fileCore.separator);
		var classPathCount:Int = classPaths.length;
		var projectPathSplit:Array<Dynamic> = null;
		for (i in 0...classPathCount) {
			var location:FileLocation = classPaths[i];
			if (filePath.indexOf(Std.string(location.fileBridge.nativePath)) > -1) {
				projectPathSplit = location.fileBridge.nativePath.split(separator);
				filePath = StringTools.replace(filePath, Std.string(location.fileBridge.nativePath), '');
				break;
			}
		}
		//var projectPathSplit:Array = projectPath.split(separator);
		//filePath = filePath.replace(projectPath, "");
		if (appendProjectNameAsPrefix && projectPathSplit != null) {
			return projectPathSplit[projectPathSplit.length - 1] + filePath.split(separator).join('.');
		}
		return filePath.split(separator).join('.');
	}

	/**
	 * Fine a fileWrapper object
	 * by a fileLocation object
	 */
	public static function findFileWrapperAgainstFileLocation(current:FileWrapper, target:FileLocation):FileWrapper {
		// Recurse-find filewrapper child
		for (child_ in current.children) {
			var child:FileWrapper = cast child_;
			if (target.fileBridge.nativePath == Reflect.field(child, 'nativePath') || target.fileBridge.nativePath.indexOf(Reflect.field(child, 'nativePath') + target.fileBridge.separator) == 0) {
				if (wrappersFoundThroughFindingAWrapper != null) {
					wrappersFoundThroughFindingAWrapper.push(child);
				}
				if (target.fileBridge.nativePath == Reflect.field(child, 'nativePath')) {
					return child;
				}
				if (AS3.as(Reflect.field(child, 'children'), Bool) && Reflect.field(child, 'children').length > 0) {
					return findFileWrapperAgainstFileLocation(child, target);
				}
			}
		}
		return current;
	}

	/**
	 * Find a fileWrapper object
	 * against a project object
	 */
	public static function findFileWrapperAgainstProject(current:FileWrapper, project:ProjectVO, orInFileWrapper:FileWrapper = null):FileWrapper {
		var projectChildren:FileWrapper = (project != null) ? project.projectFolder : orInFileWrapper;

		// Probable termination
		if (projectChildren == null) {
			return current;
		}

		// Recurse-find filewrapper child
		wrappersFoundThroughFindingAWrapper = cast new Array<FileWrapper>();
		for (ownerWrapper_ in projectChildren.children) {
			var ownerWrapper:FileWrapper = cast ownerWrapper_;
			if (current.file.fileBridge.nativePath == Reflect.field(ownerWrapper, 'nativePath') || current.file.fileBridge.nativePath.indexOf(Reflect.field(ownerWrapper, 'nativePath') + current.file.fileBridge.separator) == 0) {
				wrappersFoundThroughFindingAWrapper.push(ownerWrapper);
				if (current.file.fileBridge.nativePath == Reflect.field(ownerWrapper, 'nativePath')) {
					return ownerWrapper;
				}
				if (AS3.as(Reflect.field(ownerWrapper, 'children'), Bool) && Reflect.field(ownerWrapper, 'children').length > 0) {
					var tmpMultiReturn:FileWrapper = findFileWrapperAgainstFileLocation(ownerWrapper, current.file);
					if (tmpMultiReturn != ownerWrapper) {
						return tmpMultiReturn;
					}
				}
			}
		}
		return current;
	}

	/**
	 * Another way of finding fileWrapper
	 * inside the project hierarchy
	 */
	public static function findFileWrapperInDepth(wrapper:FileWrapper, searchPath:String, project:ProjectVO = null):FileWrapper {
		var projectChildren:FileWrapper = (project != null) ? project.projectFolder : wrapper;
		for (child_ in projectChildren.children) {
			var child:FileWrapper = cast child_;
			if (searchPath == AS3.string(Reflect.field(child, 'nativePath')) || searchPath.indexOf(Std.string(Reflect.field(child, 'nativePath') + Reflect.field(Reflect.field(Reflect.field(child, 'file'), 'fileBridge'), 'separator'))) == 0) {
				wrappersFoundThroughFindingAWrapper.push(child);
				if (searchPath == AS3.string(Reflect.field(child, 'nativePath'))) {
					return child;
				}
				if (AS3.as(Reflect.field(child, 'children'), Bool) && Reflect.field(child, 'children').length > 0) {
					return findFileWrapperInDepth(child, searchPath);
				}
			}
		}

		return wrapper;
	}

	/**
	 * Finding fileWrapper by its UDID
	 */
	public static function findFileWrapperIndexByID(wrapperToSearch:FileWrapper, searchIn:ICollectionView):Int {
		var uidToSearch:String = Std.string(UIDUtil.getUID(wrapperToSearch));
		for (i in Reflect.fields(searchIn)) {
			if (UIDUtil.getUID(Reflect.getProperty(searchIn, i)) == uidToSearch) {
				return AS3.int(i);
			}
		}

		return -1;
	}

	/**
	 * Validate a given path compared with a project's
	 * default source path
	 */
	public static function validatePathAgainstSourceFolder(project:ProjectVO, wrapperToCompare:FileWrapper = null, locationToCompare:FileLocation = null, pathToCompare:String = null):Bool {
		if (wrapperToCompare != null) {
			pathToCompare = wrapperToCompare.nativePath + project.folderLocation.fileBridge.separator;
		} else if (locationToCompare != null) {
			pathToCompare = Std.string(locationToCompare.fileBridge.nativePath + project.folderLocation.fileBridge.separator);
		}

		// if no sourceFolder exists at all let add file anywhere
		if (Reflect.getProperty(project, 'sourceFolder') == null) {
			return true;
		}

		if (pathToCompare.indexOf(Std.string(Reflect.getProperty(project, 'sourceFolder').fileBridge.nativePath + project.folderLocation.fileBridge.separator)) == -1) {
			return false;
		}

		return true;
	}

	public static function sdkSelection():Void {
		if (sdkPathPopup == null) {
			if (sdkPopup == null) {
				sdkPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SDKSelectorPopup, false), SDKSelectorPopup);
				sdkPopup.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
				sdkPopup.addEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
				PopUpManager.centerPopUp(sdkPopup);
			} else {
				PopUpManager.bringToFront(sdkPopup);
			}
		} else {
			PopUpManager.bringToFront(sdkPathPopup);
		}

		var onFlexSDKUpdated:ProjectEvent->Void = function(event:ProjectEvent):Void {
			onSDKPopupClosed(null);
		}
		var onSDKPopupClosed:CloseEvent->Void = function(event:CloseEvent):Void {
			sdkPopup.removeEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
			sdkPopup.removeEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
			sdkPopup = null;
		}
	}

	/**
	 * Checks if code-completion requisite FlexJS
	 * available or not and returns
	 */
	public static function checkCodeCompletionFlexJSSDK():String {
		var hasFlex:Bool = false;
		var FLEXJS_NAME_PREFIX:String = 'Apache Flex (FlexJS) ';

		var path:String;
		var bestVersionValue:Int = 0;
		for (i in model.userSavedSDKs) {
			var sdkName:String = AS3.string(Reflect.field(i, 'name'));
			if (sdkName.indexOf(FLEXJS_NAME_PREFIX) != -1) {
				var sdkVersion:String = sdkName.substr(FLEXJS_NAME_PREFIX.length, sdkName.indexOf(' ', FLEXJS_NAME_PREFIX.length) - FLEXJS_NAME_PREFIX.length);
				var versionParts:Array<String> = sdkVersion.split('-')[0].split('.');
				var major:Int = 0;
				var minor:Int = 0;
				var revision:Int = 0;
				if (versionParts.length >= 3) {
					major = as3hx.Compat.parseInt(versionParts[0], 10);
					minor = as3hx.Compat.parseInt(versionParts[1], 10);
					revision = as3hx.Compat.parseInt(versionParts[2], 10);
				}
				//FlexJS 0.7.0 is the minimum version supported by the
				//language server. this may change in the future.
				if (major > 0 || minor >= 7) {
					//convert the three parts of the version number
					//into a single value to compare to other versions.
					var currentValue:Int = AS3.int(major * 1e6 + minor * 1000 + revision);
					if (bestVersionValue < currentValue) {
						//pick the newest available version of FlexJS
						//to power the language server.
						hasFlex = true;
						path = AS3.string(Reflect.field(i, 'path'));
						bestVersionValue = currentValue;
						model.isCodeCompletionJavaPresent = true;
					}
				}
			}
		}

		return path;
	}

	/**
	 * Returns BOOL if version is newer than
	 * given version
	 *
	 * Basically requires for FlexJS version check where
	 * 0.8.0 added new compiler argument which do not works
	 * in older versions
	 */
	public static function isNewerVersionSDKThan(olderVersion:Int, sdkPath:String):Bool {
		if (sdkPath == null) {
			return false;
		}

		// we need some extra work to determine if FlexJS version is lower than 0.8.0
		// to ensure addition of new compiler argument '-compiler.targets'
		// which do not works with SDK < 0.8.0
		var sdkFullName:String;
		for (project in model.userSavedSDKs) {
			if (sdkPath == AS3.string(Reflect.field(project, 'path'))) {
				sdkFullName = AS3.string(Reflect.field(project, 'name'));
				break;
			}
		}

		if (sdkFullName == null) {
			return false;
		}

		var flexJSPrefixName:String = 'Apache Flex (FlexJS) ';
		var royalePrefixName:String = 'Apache Royale ';

		var isValidSdk:Bool = false;
		if (sdkFullName.indexOf(flexJSPrefixName) > -1) {
			isValidSdk = true;
		} else if (sdkFullName.indexOf(royalePrefixName) > -1) {
			return true;
		}

		if (isValidSdk) {
			var sdkNamePrefixLength:Int = flexJSPrefixName.length;

			var sdkVersion:String = sdkFullName.substr(sdkNamePrefixLength,
					sdkFullName.indexOf(' ', sdkNamePrefixLength) - sdkNamePrefixLength
			);
			var versionParts:Array<String> = sdkVersion.split('-')[0].split('.');
			var major:Int = 0;
			var minor:Int = 0;

			if (versionParts.length >= 3) {
				major = as3hx.Compat.parseInt(versionParts[0], 10);
				minor = as3hx.Compat.parseInt(versionParts[1], 10);
			}

			if (major > 0 || minor > olderVersion) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Sets requisite flags based on application file's tag
	 * Required - AS3ProjectVO
	 */
	public static function checkIfRoyaleApplication(project:AS3ProjectVO):Void {
		if (project.isRoyale) {
			return;
		}

		// probable termination
		if (project.targets.length == 0 || !AS3.as(project.targets[0].fileBridge.exists, Bool)) {
			return;
		}

		var mainAppContent:String = Std.string(project.targets[0].fileBridge.read());
		var isBasicApp:Bool = mainAppContent.indexOf('js:Application') > -1;
		var isMdlApp:Bool = mainAppContent.indexOf('mdl:Application') > -1;
		var isJewelApp:Bool = mainAppContent.indexOf('j:Application') > -1;
		var isMXApp:Bool = mainAppContent.indexOf('mx:Application') > -1;
		var hasExpressNamespace:Bool = mainAppContent.indexOf('library://ns.apache.org/royale/express') > -1;
		var hasRoyaleNamespace:Bool = mainAppContent.indexOf('library://ns.apache.org/royale/basic') > -1 || hasExpressNamespace;
		var hasFlexJSNamespace:Bool = mainAppContent.indexOf('library://ns.apache.org/flexjs/basic') > -1;
		var hasJewelNamespace:Bool = mainAppContent.indexOf('library://ns.apache.org/royale/jewel') > -1;
		var hasMXNamespace:Bool = mainAppContent.indexOf('library://ns.apache.org/royale/mx') > -1;
		var isRoyaleModule:Bool = mainAppContent.indexOf('s:Module') > -1 || mainAppContent.indexOf('mx:Module') != 0 || mainAppContent.indexOf('js:UIModule') != 0;

		var isRoyaleNamespace:Bool = hasRoyaleNamespace || hasJewelNamespace || hasMXNamespace || hasExpressNamespace;

		if ((isBasicApp || isMdlApp || isJewelApp || isMXApp || isRoyaleModule) &&
			(hasFlexJSNamespace || isRoyaleNamespace)) {
			// FlexJS Application
			project.isFlexJS = true;
			project.isRoyale = isRoyaleNamespace;

			// FlexJS MDL applicaiton
			project.isMDLFlexJS = isMdlApp;
		} else {
			project.isFlexJS = project.isMDLFlexJS = project.isRoyale = false;
		}
	}

	/**
	 * Returns possible Java exeuctable in system
	 */
	public static function getExecutableJavaLocation():FileLocation {
		var executableFile:FileLocation;
		var separator:String = Std.string(model.fileCore.separator);

		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			if (model.javaPathForTypeAhead != null && AS3.as(model.javaPathForTypeAhead.fileBridge.exists, Bool)) {
				executableFile = new FileLocation(Std.string(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, 'bin', separator, 'java')));
			} else {
				executableFile = new FileLocation(Std.string(separator.concat('usr', separator, 'bin', separator, 'java')));
			}
		} else if (model.javaPathForTypeAhead != null && AS3.as(model.javaPathForTypeAhead.fileBridge.exists, Bool)) {
			executableFile = new FileLocation(Std.string(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, 'bin', separator, 'javaw.exe')));
			if (!AS3.as(executableFile.fileBridge.exists, Bool)) {
				executableFile = new FileLocation(Std.string(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, 'javaw.exe')));
			}// in case of user setup by 'javaPath/bin'
		} else {
			var javaFolder:String = (Capabilities.supports64BitProcesses) ? 'Program Files (x86)' : 'Program Files';
			var tmpJavaLocation:FileLocation = new FileLocation(Std.string('C:'.concat(separator, javaFolder, separator, 'Java')));
			if (AS3.as(tmpJavaLocation.fileBridge.exists, Bool)) {
				var javaFiles:Array<Dynamic> = tmpJavaLocation.fileBridge.getDirectoryListing();
				for (j in javaFiles) {
					if (Reflect.field(j, 'nativePath').indexOf('jre') != -1) {
						executableFile = new FileLocation(Reflect.field(j, 'nativePath') + separator + 'bin' + separator + 'javaw.exe');
						break;
					}
				}
			}
		}

		// finally
		return executableFile;
	}

	/**
	 * Closes all the opened editors relative to a certain project path
	 */
	public static function closeAllRelativeEditors(projectOrWrapper:Dynamic, isSkipSaveConfirmation:Bool = false,
			completionHandler:Function = null, isCloseWhenDone:Bool = true):Void {
		function onModListClosed(event:CloseEvent):Void {
			if (event != null) {
				event.target.removeEventListener(CloseEvent.CLOSE, onModListClosed);
			}

			// in case we just want save process to the unsaved editors
			// but not to close the editors when done
			// default - true
			if (isCloseWhenDone) {
				// close all the tabs without waiting for anything further
				for (j_ in editorsToClose) {
					var j:IContentWindow = cast j_;
					GlobalEventDispatcher.getInstance().dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, AS3.as(j, DisplayObject), true)
				);
				}
			}

			// notify the caller
			if (completionHandler != null) {
				completionHandler();
			}
		};
		var projectReferencePath:String;
		var editorsCount:Int = AS3.int(model.editors.length);
		var hasChangesEditors:ArrayCollection = new ArrayCollection();
		var editorsToClose:Array<Dynamic> = [];

		// closes all opened file editor instances belongs to the deleted project
		// closing is IMPORTANT
		// if projectOrWrapper==null, it'll close all opened editors irrespective of
		// any particular project (example usage in 'Close All' option in File menu)
		if (AS3.as(projectOrWrapper, Bool)) {
			if (Std.is(projectOrWrapper, ProjectVO)) {
				projectReferencePath = Std.string((AS3.as(projectOrWrapper, ProjectVO)).folderLocation.fileBridge.nativePath);
			} else if (Std.is(projectOrWrapper, FileWrapper) && (AS3.as(projectOrWrapper, FileWrapper)).projectReference != null) {
				projectReferencePath = (AS3.as(projectOrWrapper, FileWrapper)).projectReference.path;
			}
		}

		for (i in 0...editorsCount) {
			if ((Std.is(Reflect.getProperty(model.editors, Std.string(i)), BasicTextEditor)) && AS3.as(Reflect.getProperty(model.editors, Std.string(i)).currentFile, Bool) &&
				(projectReferencePath == null || Reflect.getProperty(model.editors, Std.string(i)).projectPath == projectReferencePath)) {
				var editor:BasicTextEditor = Reflect.getProperty(model.editors, Std.string(i));
				if (editor != null) {
					editorsToClose.push(editor);
					if (!isSkipSaveConfirmation && editor.isChanged()) {
						hasChangesEditors.addItem({
									'file': editor,
									'isSelected': true
								});
					}
				}
			} else if (Std.is(Reflect.getProperty(model.editors, Std.string(i)), SettingsView) && AS3.as(Reflect.getProperty(model.editors, Std.string(i)).associatedData, Bool) &&
				(projectReferencePath == null || ProjectVO(Reflect.getProperty(model.editors, Std.string(i)).associatedData).folderLocation.fileBridge.nativePath == projectReferencePath)) {
				editorsToClose.push(Reflect.getProperty(model.editors, Std.string(i)));
				if (!isSkipSaveConfirmation && AS3.as(Reflect.getProperty(model.editors, Std.string(i)).isChanged(), Bool)) {
					hasChangesEditors.addItem({
								'file': Reflect.getProperty(model.editors, Std.string(i)),
								'isSelected': true
							});
				}
			} else if (AS3.as(AS3.hasOwnProperty(Reflect.getProperty(model.editors, Std.string(i)), 'label'), Bool) && ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(Reflect.getProperty(model.editors, Std.string(i)).label) == -1) {
				if (!isSkipSaveConfirmation && AS3.as(Reflect.getProperty(model.editors, Std.string(i)).isChanged(), Bool)) {
					hasChangesEditors.addItem({
								'file': Reflect.getProperty(model.editors, Std.string(i)),
								'isSelected': true
							});
				} else if (projectOrWrapper == null && Reflect.compareMethods(completionHandler, null) && Reflect.getProperty(model.editors, Std.string(i)) != SplashScreen) {
					editorsToClose.push(Reflect.getProperty(model.editors, Std.string(i)));
				}
			}
		} /*
		 * @local
		 */

		// check if the editors has any changes
		if (!isSkipSaveConfirmation && hasChangesEditors.length > 0) {
			var modListPopup:ModifiedFileListPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), ModifiedFileListPopup, true), ModifiedFileListPopup);
			modListPopup.collection = hasChangesEditors;
			modListPopup.addEventListener(CloseEvent.CLOSE, onModListClosed);
			PopUpManager.centerPopUp(modListPopup);
		} else {
			onModListClosed(null);
		}
	}

	/**
	 * Parse all acceptable files in a given project
	 */
	public static function parseFilesList(collection:IList, project:ProjectVO = null, readableExtensions:Array<Dynamic> = null, isSourceFolderOnly:Bool = false):Void {
		if (project != null) {
			if (isSourceFolderOnly && (AS3.as(project, AS3ProjectVO)).sourceFolder != null) {
				// lets search for the probable existing fileWrapper object
				// instead of creating a new one - that could be expensive
				var sourceWrapper:FileWrapper = findFileWrapperAgainstFileLocation(project.projectFolder, (AS3.as(project, AS3ProjectVO)).sourceFolder);
				if (sourceWrapper != null) {
					parseChildrens(sourceWrapper, collection, readableExtensions);
					return;
				}
			}

			parseChildrens(project.projectFolder, collection, readableExtensions);
		} else {
			for (i in model.projects) {
				parseChildrens(Reflect.field(i, 'projectFolder'), collection, readableExtensions);
			}
		}
	}

	/**
	 * Returns menu options on current
	 * recent opened projects
	 */
	public static function getRecentProjectsMenu():MenuItem {
		var openRecentLabel:String = Std.string(ResourceManager.getInstance().getString('resources', 'OPEN_RECENT_PROJECTS'));
		var openProjectMenu:MenuItem = new MenuItem(openRecentLabel);
		openProjectMenu.parents = cast ['File', openRecentLabel];
		openProjectMenu.items = cast new Array<MenuItem>();

		for (i in model.recentlyOpenedProjects) {
			if (AS3.as(Reflect.field(i, 'name'), Bool)) {
				var menuItem:MenuItem = new MenuItem(AS3.string(Reflect.field(i, 'name')), null, null, 'eventOpenRecentProject');
				menuItem.data = i;
				openProjectMenu.items.push(menuItem);
			}
		}

		return openProjectMenu;
	}

	/**
	 * Returns menu options on current
	 * recent opened projects
	 */
	public static function getRecentFilesMenu():MenuItem {
		var openRecentLabel:String = Std.string(ResourceManager.getInstance().getString('resources', 'OPEN_RECENT_FILES'));
		var openFileMenu:MenuItem = new MenuItem(openRecentLabel);
		openFileMenu.parents = cast ['File', openRecentLabel];
		openFileMenu.items = cast new Array<MenuItem>();

		for (i in model.recentlyOpenedFiles) {
			if (AS3.as(Reflect.field(i, 'name'), Bool)) {
				var menuItem:MenuItem = new MenuItem(AS3.string(Reflect.field(i, 'name')), null, null, 'eventOpenRecentFile');
				menuItem.data = i;
				openFileMenu.items.push(menuItem);
			}
		}

		return openFileMenu;
	}

	/**
	 * Set project menu type based on possible field
	 */
	public static function setProjectMenuType(value:AS3ProjectVO):Void {
		var currentMenuType:String;

		if (value.isFlexJS || value.isRoyale || value.isMDLFlexJS) {
			currentMenuType = ProjectMenuTypes.JS_ROYALE;
		} else if (value.isLibraryProject) {
			currentMenuType = ProjectMenuTypes.LIBRARY_FLEX_AS;
		} else if (value.isPrimeFacesVisualEditorProject) {
			currentMenuType = ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES;
		} else if (value.isVisualEditorProject) {
			currentMenuType = ProjectMenuTypes.VISUAL_EDITOR_FLEX;
		} else if (value.isActionScriptOnly) {
			currentMenuType = ProjectMenuTypes.PURE_AS;
		} else {
			currentMenuType = ProjectMenuTypes.FLEX_AS;
		}

		if (value.menuType.indexOf(currentMenuType) == -1) {
			value.menuType += ',' + currentMenuType;
		}

		// version-control check
		if (value.hasVersionControlType == null) {
			// git check
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.CHECK_GIT_PROJECT, value));
			// svn check
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.CHECK_SVN_PROJECT, value));
		}
	}

	/**
	 * Returns encoded string to run on Windows' shell
	 */
	public static function getEncodedForShell(value:String, forceOSXEncode:Bool = false, forceWindowsEncode:Bool = false):String {
		var tmpValue:String = '';
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool) || forceOSXEncode) {
			// @note
			// in case of /bash one should send the value surrounded by $''
			// i.e. $' +encodedValue+ '
			tmpValue = new as3hx.Compat.Regex('(\\\\)', 'g').replace(value, '\\\\"');
			tmpValue = new as3hx.Compat.Regex('(")', 'g').replace(value, '\\"');
			tmpValue = new as3hx.Compat.Regex('(\')', 'g').replace(value, '\\\'');
		} else if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool) || forceWindowsEncode) {
			for (i in ...value.length) {
				tmpValue += '^' + value.charAt(i);
			}
		}

		return tmpValue;
	}

	public static function getConsolePath():String {
		var separator:String = Std.string(model.fileCore.separator);
		if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			// in windows
			return Std.string('c:'.concat(separator, 'Windows', separator, 'System32', separator, 'cmd.exe'));
		}// in mac
		else {
			// in mac
			return Std.string(separator.concat('bin', separator, 'bash'));
		}
	}

	public static function isMavenAvailable():Bool {
		if (model.mavenPath == null || model.mavenPath == '') {
			return false;
		}

		var mavenLocation:FileLocation = new FileLocation(model.mavenPath);
		return AS3.as(mavenLocation.resolvePath('bin/' + ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'mvn' : 'mvn.cmd')).fileBridge.exists, Bool);
	}

	public static function getMavenBinPath():String {
		if (model.mavenPath == null || model.mavenPath == '') {
			return null;
		}

		var separator:String = Std.string(model.fileCore.separator);
		var mavenLocation:FileLocation = new FileLocation(model.mavenPath);
		var mavenBin:String = 'bin' + separator;
		if (mavenLocation.fileBridge.nativePath.lastIndexOf('bin') > -1) {
			mavenBin = '';
		}

		if (!AS3.as(mavenLocation.fileBridge.exists, Bool)) {
			return null;
		} else if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			return Std.string(mavenLocation.resolvePath(mavenBin + 'mvn.cmd').fileBridge.nativePath);
		} else {
			return UtilsCore.convertString(Std.string(mavenLocation.resolvePath(mavenBin + 'mvn').fileBridge.nativePath));
		}

		return null;
	}

	public static function isDefaultSDKAvailable():Bool {
		if (model.defaultSDK == null || !AS3.as(model.defaultSDK.fileBridge.exists, Bool)) {
			return false;
		}

		return true;
	}

	public static function isJavaForTypeaheadAvailable():Bool {
		var isJavaPathExists:Bool = model.javaPathForTypeAhead != null && AS3.as(model.javaPathForTypeAhead.fileBridge.exists, Bool);
		if (model.javaPathForTypeAhead == null || !isJavaPathExists) {
			return false;
		}

		return true;
	}

	public static function isAntAvailable():Bool {
		if (model.antHomePath == null || !AS3.as(model.antHomePath.fileBridge.exists, Bool)) {
			return false;
		}

		return true;
	}

	public static function isSVNPresent():Bool {
		if (model.svnPath != null) {
			return (AS3.as(new FileLocation(model.svnPath).fileBridge.exists, Bool));
		}

		return false;
	}

	public static function isGitPresent():Bool {
		if (model.gitPath != null) {
			return (AS3.as(new FileLocation(model.gitPath).fileBridge.exists, Bool));
		}

		return false;
	}

	public static function getLineBreakEncoding():String {
		return ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '\n' : '\r\n');
	}

	private static function parseChildrens(value:FileWrapper, collection:IList, readableExtensions:Array<Dynamic> = null):Void {
		if (value == null) {
			return;
		}

		var extension:String = Std.string(value.file.fileBridge.extension);
		if (!AS3.as(value.file.fileBridge.isDirectory, Bool) && (extension != null) && isAcceptableResource(extension)) {
			collection.addItem(new ResourceVO(Std.string(value.file.fileBridge.name), value));
			return;
		}

		if ((Std.is(value.children, Array)) && (AS3.asArray(value.children)).length > 0) {
			for (c_ in value.children) {
				var c:FileWrapper = cast c_;
				extension = AS3.string(Reflect.field(Reflect.field(Reflect.field(c, 'file'), 'fileBridge'), 'extension'));
				if (!AS3.as(Reflect.field(Reflect.field(Reflect.field(c, 'file'), 'fileBridge'), 'isDirectory'), Bool) && (extension != null) && isAcceptableResource(extension, readableExtensions)) {
					collection.addItem(new ResourceVO(AS3.string(Reflect.field(Reflect.field(Reflect.field(c, 'file'), 'fileBridge'), 'name')), c));
				} else if (AS3.as(Reflect.field(Reflect.field(Reflect.field(c, 'file'), 'fileBridge'), 'isDirectory'), Bool)) {
					parseChildrens(c, collection, readableExtensions);
				}
			}
		}
	}

	private static function isAcceptableResource(extension:String, readableExtensions:Array<Dynamic> = null):Bool {
		function isValidExtension(item:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return item == extension;
		};
		readableExtensions = (readableExtensions != null) ? readableExtensions : ConstantsCoreVO.READABLE_FILES;
		return AS3.as(readableExtensions.some(), Bool);
	}

}