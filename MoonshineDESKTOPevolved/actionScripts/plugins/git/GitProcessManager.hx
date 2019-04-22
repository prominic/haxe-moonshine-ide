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
package actionScripts.plugins.git;

import flash.errors.Error;
import haxe.Constraints.Function;
import com.adobe.utils.StringUtil;
import flash.events.Event;
import flash.filesystem.File;
import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;
import actionScripts.events.GeneralEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.events.StatusBarEvent;
import actionScripts.events.WorkerEvent;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IWorkerSubscriber;
import actionScripts.locator.IDEModel;
import actionScripts.locator.IDEWorker;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
import actionScripts.plugins.git.model.GitProjectVO;
import actionScripts.plugins.git.model.MethodDescriptor;
import actionScripts.plugins.versionControl.VersionControlUtils;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.menu.vo.ProjectMenuTypes;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.GenericSelectableObject;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;
import actionScripts.valueObjects.WorkerNativeProcessResult;
import actionScripts.vo.NativeProcessQueueVO;

class GitProcessManager extends ConsoleOutputter implements IWorkerSubscriber {

	public static inline var GIT_DIFF_CHECKED:String = 'gitDiffProcessCompleted';
	public static inline var GIT_REPOSITORY_TEST:String = 'checkIfGitRepository';
	public static inline var GIT_STATUS_FILE_MODIFIED:String = 'gitStatusFileModified';
	public static inline var GIT_STATUS_FILE_DELETED:String = 'gitStatusFileDeleted';
	public static inline var GIT_STATUS_FILE_NEW:String = 'gitStatusFileNew';
	public static inline var GIT_REMOTE_BRANCH_LIST:String = 'getGitRemoteBranchList';

	private static inline var XCODE_PATH_DECTECTION:String = 'xcodePathDectection';
	private static inline var GIT_AVAIL_DECTECTION:String = 'gitAvailableDectection';
	private static inline var GIT_DIFF_CHECK:String = 'checkGitDiff';
	private static inline var GIT_PUSH:String = 'gitPush';
	private static inline var GIT_REMOTE_ORIGIN_URL:String = 'getGitRemoteURL';
	private static inline var GIT_CURRENT_BRANCH_NAME:String = 'getGitCurrentBranchName';
	private static inline var GIT_COMMIT:String = 'gitCommit';
	private static inline var GIT_QUERY_USER_NAME:String = 'gitQueryUserName';
	private static inline var GIT_QUERY_USER_EMAIL:String = 'gitQueryUserEmail';
	private static inline var GIT_CHECKOUT_BRANCH:String = 'gitCheckoutToBranch';
	private static inline var GIT_CHECKOUT_NEW_BRANCH:String = 'gitCheckoutNewBranch';
	private static inline var GIT_BRANCH_NAME_VALIDATION:String = 'gitValidateProposedBranchName';

	public var gitBinaryPathOSX:String;
	public var setGitAvailable:Function;
	public var plugin:GitHubPlugin;
	public var pendingProcess:Array< of MethodDescriptor > = cast [];

	private var processType:String;

	private var worker:IDEWorker = IDEWorker.getInstance();
	private var queue:Array<Dynamic> = new Array<Dynamic>();
	private var model:IDEModel = IDEModel.getInstance();
	private var onXCodePathDetection:Function;
	private var xCodePathDetectionType:String;
	private var repositoryUnderCursor:RepositoryItemVO;
	private var completionFunctionsDic:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var subscribeIdToWorker:String = Std.string(UIDUtil.createUID());
	private var lastCloneURL:String;
	private var lastCloneTarget:String;
	private var isGitUserName:Bool = false;
	private var isGitUserEmail:Bool = false;

	private var _cloningProjectName:String;

	private var cloningProjectName(get, set):String;
	private function get_cloningProjectName():String {
		return _cloningProjectName;
	}

	private function set_cloningProjectName(value:String):String {
		var quoteIndex:Int = value.indexOf('\'');
		_cloningProjectName = value.substring(++quoteIndex, value.indexOf('\'', quoteIndex));
		return value;
	}

	public function new() {
		super();
		worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
		worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
	}

	public function getOSXCodePath(completion:Function, against:String):Void {
		queue = new Array<Dynamic>();
		onXCodePathDetection = cast completion;
		xCodePathDetectionType = against;

		addToQueue(new NativeProcessQueueVO('xcode-select -p', false, XCODE_PATH_DECTECTION));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': null
				}, subscribeIdToWorker);
	}

	public function checkGitAvailability():Void {
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' --version'), false, GIT_AVAIL_DECTECTION));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': null
				}, subscribeIdToWorker);
	}

	public function checkIfGitRepository(project:AS3ProjectVO):Void {
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' rev-parse --git-dir'), false, GIT_REPOSITORY_TEST, project.folderLocation.fileBridge.nativePath));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': project.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function getGitRemoteURL(project:ProjectVO):Void {
		if (project == null && !AS3.as(model.activeProject, Bool)) {
			return;
		}

		queue = new Array<Dynamic>();
		project != model.activeProject;

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config --get remote.origin.url'), false, GIT_REMOTE_ORIGIN_URL, project.folderLocation.fileBridge.nativePath));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': project.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function getCurrentBranch(project:ProjectVO = null):Void {
		if (project == null && !AS3.as(model.activeProject, Bool)) {
			return;
		}

		project = (project != null) ? project : model.activeProject;
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch'), false, GIT_CURRENT_BRANCH_NAME, project.folderLocation.fileBridge.nativePath));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': project.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function clone(url:String, target:String, targetFolder:String, repository:RepositoryItemVO):Void {
		queue = new Array<Dynamic>();

		repositoryUnderCursor = repository;
		lastCloneURL = url;
		lastCloneTarget = target;
		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' clone --progress -v ' + url + ' ' + targetFolder), false, GitHubPlugin.CLONE_REQUEST));

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'Clone ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': target
				}, subscribeIdToWorker);
	}

	public function checkDiff():Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' status --porcelain > ') +
				((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? '$\'' + File.applicationStorageDirectory.resolvePath('commitDiff.txt').nativePath + '\'' : Std.string(
						File.applicationStorageDirectory.resolvePath('commitDiff.txt').nativePath
			)),
				false,
				GIT_DIFF_CHECK));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function getGitAuthor(completion:Function):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		completionFunctionsDic.set('getGitAuthor', completion);
		isGitUserEmail = isGitUserName = false;
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config user.name'), false, GIT_QUERY_USER_NAME, model.activeProject.folderLocation.fileBridge.nativePath));
		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config user.email'), false, GIT_QUERY_USER_EMAIL, model.activeProject.folderLocation.fileBridge.nativePath));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function setGitAuthor(userObject:Dynamic):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		isGitUserEmail = isGitUserName = false;
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(
				(AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' config user.name $\'' + Reflect.field(userObject, 'userName') + '\'' :
				gitBinaryPathOSX + '&&config&&user.name&&' + Reflect.field(userObject, 'userName'),
				false, GIT_QUERY_USER_NAME, model.activeProject.folderLocation.fileBridge.nativePath));
		addToQueue(new NativeProcessQueueVO(
				(AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' config user.email $\'' + Reflect.field(userObject, 'email') + '\'' :
				gitBinaryPathOSX + '&&config&&user.email&&' + Reflect.field(userObject, 'email'),
				false, GIT_QUERY_USER_EMAIL, model.activeProject.folderLocation.fileBridge.nativePath));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function commit(files:ArrayCollection, withMessage:String):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		queue = new Array<Dynamic>();

		for (i in files) {
			if (AS3.as(Reflect.field(i, 'isSelected'), Bool)) {
				addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' add $\'' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')) + '\'' : gitBinaryPathOSX + '&&add&&' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')), false, GIT_COMMIT));
			}
		}

		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' commit -m $\'' + UtilsCore.getEncodedForShell(withMessage) + '\'' : gitBinaryPathOSX + '&&commit&&-m&&"' + UtilsCore.getEncodedForShell(withMessage, true) + '"', false, GIT_COMMIT));

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'Commit ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function revert(files:ArrayCollection):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}
		queue = new Array<Dynamic>();

		for (i in files) {
			if (AS3.as(Reflect.field(i, 'isSelected'), Bool)) {
				switch (Reflect.field(Reflect.field(i, 'data'), 'status')) {
					case GitProcessManager.GIT_STATUS_FILE_DELETED, GitProcessManager.GIT_STATUS_FILE_MODIFIED:
						addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' checkout $\'' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')) + '\'' : gitBinaryPathOSX + '&&checkout&&' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')), false, GIT_CHECKOUT_BRANCH, Reflect.field(Reflect.field(i, 'data'), 'path')));

					case GitProcessManager.GIT_STATUS_FILE_NEW:
						addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' reset $\'' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')) + '\'' : gitBinaryPathOSX + '&&reset&&' + UtilsCore.getEncodedForShell(Reflect.field(Reflect.field(i, 'data'), 'path')), false, GIT_CHECKOUT_BRANCH, Reflect.field(Reflect.field(i, 'data'), 'path')));
				}
			}
		}

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'File Revert ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': plugin.modelAgainstProject.get(model.activeProject).rootLocal.nativePath
				}, subscribeIdToWorker);
	}

	public function push(userObject:Dynamic = null):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(model.activeProject);
		var userName:String;
		var password:String;

		userName = (tmpModel.sessionUser != null) ? tmpModel.sessionUser : Std.string((AS3.as(userObject, Bool)) ? Reflect.field(userObject, 'userName') : null);
		password = (tmpModel.sessionPassword != null) ? tmpModel.sessionPassword : Std.string((AS3.as(userObject, Bool)) ? Reflect.field(userObject, 'password') : null);

		queue = new Array<Dynamic>();

		// we'll not hold from executing push command if we do not have
		// any immediate credential available but will execute with
		// following options -
		// 1. credential could be saved to the user's system (i.e. keychain) so we might not need to inject that separately
		// 2. executing the command may ask for credential - we shall detect and ask user to enter the same

		if (userName == null && password == null) {
			addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' push -v origin $\'' + UtilsCore.getEncodedForShell(tmpModel.currentBranch) + '\'' : gitBinaryPathOSX + '&&push&&-v&&origin&&' + UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
		}//git push https://user:pass@github.com/user/project.git
		else {
			//git push https://user:pass@github.com/user/project.git
			addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' push https://' + userName + ':' + password + '@' + tmpModel.remoteURL + '.git $\'' + UtilsCore.getEncodedForShell(tmpModel.currentBranch) + '\'' : gitBinaryPathOSX + '&&push&&https://' + userName + ':' + password + '@' + tmpModel.remoteURL + '.git&&' + UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
		}

		warning('Git push requested...');
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'Push ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function pull():Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(model.activeProject);
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' pull --progress -v --no-rebase origin $\'' + UtilsCore.getEncodedForShell(tmpModel.currentBranch) + '\'' : gitBinaryPathOSX + '&&pull&&--progress&&-v&&--no-rebase&&origin&&' + UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GitHubPlugin.PULL_REQUEST));

		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'Pull ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function switchBranch():Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' fetch'), false, null));
		addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch -r'), false, GIT_REMOTE_BRANCH_LIST));
		pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch'));// next method we need to fire when above done

		warning('Fetching branch details...');
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, 'Requested', 'Branch Details ', false));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function changeBranchTo(value:GenericSelectableObject):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' checkout $\'' + UtilsCore.getEncodedForShell(Std.string(value.data)) + '\'' : gitBinaryPathOSX + '&&checkout&&' + UtilsCore.getEncodedForShell(Std.string(value.data)), false, GIT_CHECKOUT_BRANCH));
		pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch'));

		notice('Trying to switch branch...');
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function createAndCheckoutNewBranch(name:String, pushToOrigin:Bool):Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(model.activeProject);
		queue = new Array<Dynamic>();

		// https://stackoverflow.com/questions/1519006/how-do-you-create-a-remote-git-branch
		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' checkout -b $\'' + UtilsCore.getEncodedForShell(name) + '\'' : gitBinaryPathOSX + '&&checkout&&-b&&' + UtilsCore.getEncodedForShell(name), false, GIT_CHECKOUT_NEW_BRANCH));
		pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch'));
		if (pushToOrigin) {
			pendingProcess.push(new MethodDescriptor(this, 'push'));// next method we need to fire when above done
		}

		notice('Trying to switch branch...');
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function checkout():Void {
		if (!AS3.as(model.activeProject, Bool)) {
			return;
		}

		var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(model.activeProject);

		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' checkout $\'' + UtilsCore.getEncodedForShell(tmpModel.currentBranch) + '\' --' : gitBinaryPathOSX + '&&checkout&&' + UtilsCore.getEncodedForShell(tmpModel.currentBranch) + '&&--', false, GIT_CHECKOUT_BRANCH));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	public function checkBranchNameValidity(name:String, completion:Function):Void {
		completionFunctionsDic.set('checkBranchNameValidity', completion);
		queue = new Array<Dynamic>();

		addToQueue(new NativeProcessQueueVO((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? gitBinaryPathOSX + ' check-ref-format --branch $\'' + UtilsCore.getEncodedForShell(name) + '\'' : gitBinaryPathOSX + '&&check-ref-format&&--branch&&' + UtilsCore.getEncodedForShell(name), false, GIT_BRANCH_NAME_VALIDATION));
		worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
					'queue': queue,
					'workingDirectory': model.activeProject.folderLocation.fileBridge.nativePath
				}, subscribeIdToWorker);
	}

	private function getPlatformMessage(value:String):String {
		if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			return gitBinaryPathOSX + value;
		}

		value = new as3hx.Compat.Regex('( )', 'g').replace(value, '&&');
		return gitBinaryPathOSX + value;
	}

	public function onWorkerValueIncoming(value:Dynamic):Void {
		var tmpValue:Dynamic = Reflect.field(value, 'value');
		switch (Reflect.field(value, 'event')) {
			case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
				if (Reflect.field(tmpValue, 'type') == WorkerNativeProcessResult.OUTPUT_TYPE_DATA) {
					shellData(tmpValue);
				} else if (Reflect.field(tmpValue, 'type') == WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE) {
					shellExit(tmpValue);
				} else {
					shellError(tmpValue);
				}
			case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
				if (queue.length != 0) {
					queue.shift();
				}
				processType = AS3.string(Reflect.field(tmpValue, 'processType'));
				shellTick(tmpValue);
			case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
				listOfProcessEnded();
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
				// starts checking pending process here
				if (pendingProcess.length > 0) {
					var process:MethodDescriptor = pendingProcess.shift();
					process.callMethod();
				}
			case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
				debug('%s', Reflect.field(value, 'value'));
		}
	}

	private function addToQueue(value:Dynamic):Void {
		queue.push(value);
	}

	private function listOfProcessEnded():Void {
		switch (processType) {
			case GIT_CHECKOUT_BRANCH, GIT_CHECKOUT_NEW_BRANCH, GitHubPlugin.PULL_REQUEST:
				refreshProjectTree();
				// important
				success('...process completed');
			case GIT_QUERY_USER_EMAIL:
				var tmpVO:GitProjectVO = (AS3.as(model.activeProject, Bool)) ? plugin.modelAgainstProject.get(model.activeProject) : null;
				if (tmpVO != null && !isGitUserEmail) {
					tmpVO.sessionUserEmail = null;
				}
				if (tmpVO != null && !isGitUserName) {
					tmpVO.sessionUserName = null;
				}
				completionFunctionsDic.get('getGitAuthor')(tmpVO);
				completionFunctionsDic.remove('getGitAuthor');
			case GIT_DIFF_CHECK:
				checkDiffFileExistence();
		}
	}

	private function shellError(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		var match:Array<Dynamic> = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('\'git\' is not recognized as an internal or external command', ''));
		if (match != null) {
			setGitAvailable(false);
		}

		switch (Reflect.field(Reflect.field(value, 'queue'), 'processType')) {
			case XCODE_PATH_DECTECTION:
				if (onXCodePathDetection != null) {
					onXCodePathDetection(null, true, null);
				}
		}

		if (match == null) {
			error(Reflect.field(value, 'output'));
		}
		dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
	}

	private function shellExit(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		var tmpQueue:Dynamic = Reflect.field(value, 'queue'); /** type of NativeProcessQueueVO **/
		switch (Reflect.field(tmpQueue, 'processType')) {
			case GitHubPlugin.CLONE_REQUEST:
				success('\'' + cloningProjectName + '\'...downloaded successfully (' + lastCloneURL + File.separator + cloningProjectName + ')');
				doPostCloneProcess(new File(lastCloneTarget).resolvePath(cloningProjectName));
			case GIT_PUSH:
				success('...process completed');
		}
	}

	private function shellTick(value:Dynamic /** type of NativeProcessQueueVO **/ ):Void {
		switch (Reflect.field(value, 'processType')) {
			case GIT_CHECKOUT_BRANCH:
				if (AS3.as(Reflect.field(value, 'extraArguments'), Bool) && Reflect.field(value, 'extraArguments').length != 0) {
					notice(Reflect.field(Reflect.field(value, 'extraArguments'), Std.string(0)) + ' :Finished');
				}
		}
	}

	private function shellData(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		var match:Array<Dynamic>;
		var tmpQueue:Dynamic = Reflect.field(value, 'queue'); /** type of NativeProcessQueueVO **/
		var isFatal:Bool;
		var tmpProject:ProjectVO;

		match = Reflect.field(value, 'output').match(new as3hx.Compat.Regex('fatal: .*', ''));
		if (match != null) {
			isFatal = true;
		}

		switch (Reflect.field(tmpQueue, 'processType')) {
			case XCODE_PATH_DECTECTION:
				Reflect.setField(value, 'output', Reflect.field(value, 'output').replace('\n', ''));
				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('xcode.app\\/contents\\/developer', ''));
				if (match != null && (onXCodePathDetection != null)) {
					onXCodePathDetection(Reflect.field(value, 'output'), true, xCodePathDetectionType);
					onXCodePathDetection = null;
					return;
				}

				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('commandlinetools', ''));
				if (match != null && (onXCodePathDetection != null)) {
					onXCodePathDetection(Reflect.field(value, 'output'), false, xCodePathDetectionType);
					onXCodePathDetection = null;
					return;
				}

				onXCodePathDetection = null;
			case GIT_AVAIL_DECTECTION:
				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('git version', ''));
				if (match != null) {
					setGitAvailable(true);
					return;
				}

				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('\'git\' is not recognized as an internal or external command', ''));
				if (match != null) {
					setGitAvailable(false);
					return;
				}
			case GIT_REPOSITORY_TEST:
				tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
				if (!isFatal) {
					if (tmpProject != null) {
						tmpProject.menuType += ',' + ProjectMenuTypes.GIT_PROJECT;
						(AS3.as(tmpProject, AS3ProjectVO)).hasVersionControlType = VersionControlTypes.GIT;
						if (plugin.modelAgainstProject.get(tmpProject) == null) {
							Reflect.setField(value, 'output', Reflect.field(value, 'output').replace('\n', ''));

							plugin.modelAgainstProject.set(tmpProject, new GitProjectVO());
							plugin.modelAgainstProject.set(tmpProject, ((Reflect.field(value, 'output') == '.git')) ? AS3.as(tmpProject.folderLocation.fileBridge.getFile, File) : (new File(Reflect.field(value, 'output'))).parent).rootLocal;
						}

						// continuing fetch
						pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch', tmpProject));// store the current branch
						pendingProcess.push(new MethodDescriptor(this, 'getGitRemoteURL', tmpProject));// store the remote URL

						// following will enable/disable Moonshine top menus based on project
						dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
					}

					dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST));
				} else if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool) && tmpProject != null &&
					(plugin.projectsNotAcceptedByUserToPermitAsGitOnMacOS.get(tmpProject.folderLocation.fileBridge.nativePath) == null)) {
					// in case of OSX sandbox if the project's parent folder
					// consists of '.git' and do not have bookmark access
					// the running command is tend to be fail, in that case
					// a brute check
					initiateSandboxGitRepositoryCheckBrute(AS3.as(tmpProject, AS3ProjectVO));
				} else {
					dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST));
				}

				// following will enable/disable Moonshine top menus based on project
				if (tmpProject != null) {
					dispatcher.dispatchEvent(new Event(Std.string(MenuPlugin.REFRESH_MENU_STATE)));
				}
				return;
			case GIT_REMOTE_ORIGIN_URL:
				match = Reflect.field(value, 'output').match(new as3hx.Compat.Regex('.*.$', ''));
				if (match != null) {
					tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
					var tmpResult:Array<Dynamic> = new as3hx.Compat.Regex('http.*\://', 'i').exec(Reflect.field(value, 'output'));
					if (tmpResult != null && tmpProject != null) {
						// extracting remote origin URL as 'github/[author]/[project]
						if (plugin.modelAgainstProject.get(tmpProject) != null) {
							plugin.modelAgainstProject.set(tmpProject, Reflect.field(value, 'output').substr(tmpResult[0].length, Reflect.field(value, 'output').length).replace('\n', '')).remoteURL;
						}
					}
					return;
				}
			case GIT_CURRENT_BRANCH_NAME:
				tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
				if (tmpProject != null) {
					parseCurrentBranch(AS3.string(Reflect.field(value, 'output')), tmpProject);
				}
				return;
			case GitHubPlugin.CLONE_REQUEST:
				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('cloning into', ''));
				if (match != null) {
					// for some weird reason git clone always
					// turns to errordata first
					cloningProjectName = AS3.string(Reflect.field(value, 'output'));
					warning(Reflect.field(value, 'output'));
					return;
				}
			case GIT_REMOTE_BRANCH_LIST:
				if (!isFatal) {
					parseRemoteBranchList(AS3.string(Reflect.field(value, 'output')));
				}
				return;
			case GIT_PUSH:
				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('fatal.*username', ''));
				if (match != null) {
					// we'll need user to authenticate
					plugin.requestToAuthenticate();
					return;
				}

				match = Reflect.field(value, 'output').toLowerCase().match(new as3hx.Compat.Regex('invalid username', ''));
				if (match != null) {
					// reset model information if saved by the user
					tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
					plugin.modelAgainstProject.set(tmpProject, null).sessionUser;
					plugin.modelAgainstProject.set(tmpProject, null).sessionPassword;
				}
			case GIT_BRANCH_NAME_VALIDATION:
				if (completionFunctionsDic.get('checkBranchNameValidity') != null) {
					completionFunctionsDic.get('checkBranchNameValidity')(Reflect.field(value, 'output'));
					completionFunctionsDic.remove('checkBranchNameValidity');
					return;
				}
			case GIT_QUERY_USER_NAME:
				tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
				plugin.modelAgainstProject.set(tmpProject, Reflect.field(value, 'output').replace('\n', '')).sessionUserName;
				isGitUserName = true;
				return;
			case GIT_QUERY_USER_EMAIL:
				tmpProject = UtilsCore.getProjectByPath(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
				plugin.modelAgainstProject.set(tmpProject, Reflect.field(value, 'output').replace('\n', '')).sessionUserEmail;
				isGitUserEmail = true;
				return;
		}

		if (isFatal) {
			shellError(value);
			return;
		} else {
			notice(Reflect.field(value, 'output'));
		}
	}

	private function initiateSandboxGitRepositoryCheckBrute(value:AS3ProjectVO):Void {
		var tmpFile:File = AS3.as(value.folderLocation.fileBridge.getFile, File);
		do {
			tmpFile = tmpFile.parent;
			if (tmpFile != null && AS3.as(tmpFile.resolvePath('.git').exists, Bool) && AS3.as(tmpFile.resolvePath('.git/index').exists, Bool)) {
				dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST, {
							'project': value,
							'gitRootLocation': tmpFile
						}));
				break;
			}

		} while ((tmpFile != null));
	}

	private function checkDiffFileExistence():Void {
		function getFileStatus(value:String):String {
			if (value == 'D') {
				return GIT_STATUS_FILE_DELETED;
			} else if (value == '??' || value == 'A') {
				return GIT_STATUS_FILE_NEW;
			}
			return GIT_STATUS_FILE_MODIFIED;
		};
		var tmpFile:File = File.applicationStorageDirectory.resolvePath('commitDiff.txt'); /*
		* @local
		*/
		if (AS3.as(tmpFile.exists, Bool)) {
			var value:String = Std.string(new FileLocation(tmpFile.nativePath).fileBridge.read());

			// @note
			// for some unknown reason, searchRegExp.exec(tmpString) always
			// failed after 4 records; initial investigation didn't shown
			// any possible reason of breaking; Thus forEach treatment for now
			// (but I don't like this)
			var tmpPositions:ArrayCollection = new ArrayCollection();
			var contentInLineBreaks:Array<String> = value.split('\n');
			var firstPart:String;
			var secondPart:String;
			contentInLineBreaks.forEach(function(element:String, index:Int, arr:Array<Dynamic>):Void {
						if (element != '') {
							element = Std.string(StringTools.trim(element));
							firstPart = element.substring(0, element.indexOf(' '));
							secondPart = element.substr(element.indexOf(' ') + 1, element.length);

							// in some cases the output comes surrounding with double-quote
							// we need to remove them before a commit
							secondPart = new as3hx.Compat.Regex('\\"', 'g').replace(secondPart, '');
							secondPart = Std.string(StringTools.trim(secondPart));

							tmpPositions.addItem(new GenericSelectableObject(false, {
										'path': secondPart,
										'status': getFileStatus(firstPart)
									}));
						}
					});

			dispatchEvent(new GeneralEvent(GIT_DIFF_CHECKED, tmpPositions));
			try {
				tmpFile.deleteFile();
			} catch (e:Error) {
				tmpFile.deleteFileAsync();
			}
		}
	}

	private function parseRemoteBranchList(value:String):Void {
		if (AS3.as(model.activeProject, Bool) && plugin.modelAgainstProject.get(model.activeProject) != null) {
			var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(model.activeProject);

			tmpModel.branchList = new ArrayCollection();
			var contentInLineBreaks:Array<String> = value.split('\n');
			contentInLineBreaks.forEach(function(element:String, index:Int, arr:Array<Dynamic>):Void {
						if (element != '' && element.indexOf('origin/') != -1 && element.indexOf('->') == -1) {
							tmpModel.branchList.addItem(new GenericSelectableObject(false, element.substr(element.indexOf('origin/') + 7, element.length)));
						}
					});
		}
	}

	private function parseCurrentBranch(value:String, project:ProjectVO):Void {
		var starredIndex:Int = value.indexOf('* ') + 2;
		var selectedBranchName:String = value.substring(starredIndex, value.indexOf('\n', starredIndex));

		// store the project's selected branch to its model
		if (plugin.modelAgainstProject.get(project) != null) {
			var tmpModel:GitProjectVO = plugin.modelAgainstProject.get(project);
			tmpModel.currentBranch = selectedBranchName;

			for (i in tmpModel.branchList) {
				if (Reflect.field(i, 'data') == selectedBranchName) {
					Reflect.setField(i, 'isSelected', true);
					break;
				}
			}

			// let open the selection popup
			dispatchEvent(new GeneralEvent(GIT_REMOTE_BRANCH_LIST, tmpModel.branchList));
		}
	}

	private function refreshProjectTree():Void {
		// refreshing project tree
		GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, model.activeProject.projectFolder));
	}

	private function doPostCloneProcess(path:File):Void {
		// validate first if root is a know project
		var hasProject:FileLocation = FlashDevelopImporter.test(path);
		if (hasProject == null) {
			hasProject = FlashBuilderImporter.test(path);
		}

		if (hasProject != null) {
			print('Opening project from:' + path.nativePath);
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, path));
		} else if (repositoryUnderCursor != null) {
			VersionControlUtils.parseGitDependencies(repositoryUnderCursor, path);
		}
	}

}