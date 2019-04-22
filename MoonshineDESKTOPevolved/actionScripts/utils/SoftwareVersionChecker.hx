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
import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;
import actionScripts.events.WorkerEvent;
import actionScripts.interfaces.IWorkerSubscriber;
import actionScripts.locator.IDEModel;
import actionScripts.locator.IDEWorker;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.help.HelpPlugin;
import actionScripts.plugins.git.model.MethodDescriptor;
import actionScripts.valueObjects.ComponentTypes;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.WorkerNativeProcessResult;
import actionScripts.vo.NativeProcessQueueVO;

class SoftwareVersionChecker extends ConsoleOutputter implements IWorkerSubscriber {

	private static inline var QUERY_FLEX_AIR_VERSION:String = 'getFlexAIRversion';
	private static inline var QUERY_ROYALE_FJS_VERSION:String = 'getRoyaleFlexJSversion';
	private static inline var QUERY_JDK_VERSION:String = 'getJDKVersion';
	private static inline var QUERY_ANT_VERSION:String = 'getAntVersion';
	private static inline var QUERY_MAVEN_VERSION:String = 'getMavenVersion';
	private static inline var QUERY_SVN_GIT_VERSION:String = 'getSVNGitVersion';

	public var pendingProcess:Array< of MethodDescriptor > = cast [];

	private var processType:String;

	private var worker:IDEWorker = IDEWorker.getInstance();
	private var queue:Array<Dynamic> = new Array<Dynamic>();
	private var model:IDEModel = IDEModel.getInstance();
	private var environmentSetup:EnvironmentSetupUtils = EnvironmentSetupUtils.getInstance();
	private var components:ArrayCollection;
	private var lastOutput:String;
	private var subscribeIdToWorker:String;
	private var itemUnderCursorIndex:Int = 0;

	/**
	 * CONSTRUCTOR
	 */
	public function new() {
		super();
		if (AS3.as(HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER, Bool)) {
			subscribeIdToWorker = Std.string(HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER);
		} else {
			subscribeIdToWorker = Std.string(HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER = UIDUtil.createUID());
		}

		worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
		worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
	}

	/**
	 * Checks some required/optional software installation
	 * and their version if available
	 */
	public function retrieveAboutInformation(items:ArrayCollection):Void {
		components = items;
		startRequestProcess();
	}

	private function startRequestProcess():Void {
		var itemTypeUnderCursor:String;
		if (itemUnderCursorIndex <= (components.length - 1)) {
			var executable:String;
			var itemUnderCursor:ComponentVO = AS3.as(components.getItemAt(itemUnderCursorIndex), ComponentVO);
			var executableFullPath:String;
			if (itemUnderCursor.installToPath != null) {
				var commands:String;
				queue = new Array<Dynamic>();
				switch (itemUnderCursor.type) {
					case ComponentTypes.TYPE_FLEX, ComponentTypes.TYPE_FEATHERS, ComponentTypes.TYPE_FLEXJS:
						executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'mxmlc' : 'mxmlc.bat';
						commands = '"' + itemUnderCursor.installToPath + '/bin/' + executable + '" --version' + ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? ';' : '&& ');
						executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'adt' : 'adt.bat';
						commands += '"' + itemUnderCursor.installToPath + '/bin/' + executable + '" -version';
						itemTypeUnderCursor = QUERY_FLEX_AIR_VERSION;
					case ComponentTypes.TYPE_ROYALE:
						executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'mxmlc' : 'mxmlc.bat';
						commands = '"' + itemUnderCursor.installToPath + '/js/bin/' + executable + '" --version';
						itemTypeUnderCursor = QUERY_ROYALE_FJS_VERSION;
					case ComponentTypes.TYPE_OPENJAVA:
						commands = '"' + itemUnderCursor.installToPath + '/bin/java" -version';
						itemTypeUnderCursor = QUERY_JDK_VERSION;
					case ComponentTypes.TYPE_ANT:
						executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'ant' : 'ant.bat';
						commands = '"' + itemUnderCursor.installToPath + '/bin/' + executable + '" -version';
						itemTypeUnderCursor = QUERY_ANT_VERSION;
					case ComponentTypes.TYPE_MAVEN:
						executable = (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 'mvn' : 'mvn.cmd';
						executableFullPath = itemUnderCursor.installToPath + '/bin/' + executable;
						if (!AS3.as(FileUtils.isPathExists(executableFullPath), Bool)) {
							executableFullPath = itemUnderCursor.installToPath + '/' + executable;
						}
						commands = '"' + executableFullPath + '" -version';
						itemTypeUnderCursor = QUERY_MAVEN_VERSION;
					case ComponentTypes.TYPE_SVN, ComponentTypes.TYPE_GIT:
						commands = '"' + itemUnderCursor.installToPath + '" --version';
						itemTypeUnderCursor = QUERY_SVN_GIT_VERSION;
				}

				environmentSetup.initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, null, cast [commands]);
			} else {
				itemUnderCursorIndex++;
				startRequestProcess();
			}
		} else {
			dispatchEvent(new Event(Event.COMPLETE));
		}

		var onEnvironmentPrepared:String->Void = function(value:String):Void {
			addToQueue(new NativeProcessQueueVO(value, false, itemTypeUnderCursor, itemUnderCursorIndex));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {
						'queue': queue,
						'workingDirectory': null
					}, subscribeIdToWorker);
			itemUnderCursorIndex++;
		}
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
				// starts checking pending process here
				if (pendingProcess.length > 0) {
					var process:MethodDescriptor = pendingProcess.shift();
					process.callMethod();
				}
			case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
				//debug("%s", event.value.value);
				break;
		}
	}

	private function addToQueue(value:Dynamic):Void {
		queue.push(value);
	}

	private function listOfProcessEnded():Void {
		switch (processType) {
			case QUERY_FLEX_AIR_VERSION:
				//success("...Flex Process completed");
				break;
		}

		startRequestProcess();
	}

	private function shellError(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		error(Reflect.field(value, 'output'));
	}

	private function shellExit(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		var tmpQueue:Dynamic = Reflect.field(value, 'queue'); /** type of NativeProcessQueueVO **/
		if (AS3.as(Reflect.field(tmpQueue, 'extraArguments'), Bool) && Reflect.field(tmpQueue, 'extraArguments').length != 0 && lastOutput != null) {
			var tmpIndex:Int = AS3.int(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)));
			switch (Reflect.field(tmpQueue, 'processType')) {
				case QUERY_FLEX_AIR_VERSION:
					Reflect.getProperty(components, Std.string(tmpIndex)).version = lastOutput;
				case QUERY_MAVEN_VERSION:
					Reflect.getProperty(components, Std.string(tmpIndex)).version = getVersionNumberedTypeLine(lastOutput);
			}
		}

		lastOutput = null;
	}

	private function shellTick(value:Dynamic /** type of NativeProcessQueueVO **/ ):Void {
		/*var tmpIndex:int = int(value.extraArguments[0]);
		switch (value.processType)
		{
		case QUERY_FLEX_AIR_VERSION:
		if (!components[tmpIndex].version) components[tmpIndex].version = lastOutput;
		else components[tmpIndex].version += ", "+ lastOutput;
		break;
		}*/
	}

	private function shellData(value:Dynamic /** type of WorkerNativeProcessResult **/ ):Void {
		var match:Array<Dynamic>;
		var tmpQueue:Dynamic = Reflect.field(value, 'queue'); /** type of NativeProcessQueueVO **/
		var isFatal:Bool;
		var tmpProject:ProjectVO;
		var versionNumberString:String;

		match = Reflect.field(value, 'output').match(new as3hx.Compat.Regex('fatal: .*', ''));
		if (match != null) {
			isFatal = true;
		}

		match = Reflect.field(value, 'output').match(new as3hx.Compat.Regex('is not recognized as an internal or external command', ''));
		if (match == null) {
			switch (Reflect.field(tmpQueue, 'processType')) {
				case QUERY_FLEX_AIR_VERSION:
					versionNumberString = getVersionNumberedTypeLine(AS3.string(Reflect.field(value, 'output')));
					if (lastOutput == null && versionNumberString != null) {
						lastOutput = versionNumberString;
					} else if (versionNumberString != null) {
						lastOutput += ', ' + versionNumberString;
					}
				case QUERY_ROYALE_FJS_VERSION:
					match = Reflect.field(value, 'output').match(new as3hx.Compat.Regex('Version ', ''));
					if (match != null) {
						Reflect.getProperty(components, Std.string(AS3.int(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)))), getVersionNumberedTypeLine(AS3.string(Reflect.field(value, 'output')))).version;
					}
				case QUERY_JDK_VERSION, QUERY_ANT_VERSION, QUERY_SVN_GIT_VERSION:
					if (!AS3.as(Reflect.getProperty(components, Std.string(AS3.int(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0))))).version, Bool)) {
						versionNumberString = getVersionNumberedTypeLine(AS3.string(Reflect.field(value, 'output')));
						if (versionNumberString != null) {
							Reflect.getProperty(components, Std.string(AS3.int(Reflect.field(Reflect.field(tmpQueue, 'extraArguments'), Std.string(0)))), versionNumberString).version;
						}
					}
				case QUERY_MAVEN_VERSION:
					// in case of 'mvn -version' on OSX the process
					// returns the full information in many shell-data
					// so we need to prepare the full output first
					// (unlike others) and extract the first line
					// from it
					if (lastOutput == null) {
						lastOutput = AS3.string(Reflect.field(value, 'output'));
					} else {
						lastOutput += AS3.string(Reflect.field(value, 'output'));
					}
			}
		}

		if (isFatal) {
			shellError(value);
			return;
		} else {
			//notice(value.output);
		}
	}

	private function getVersionNumberedTypeLine(value:String):String {
		var lines:Array<String> = value.split(Std.string(UtilsCore.getLineBreakEncoding()));
		for (line in lines) {
			if (AS3.as(as3hx.Compat.match(line, new as3hx.Compat.Regex('\\d+.\\d+.\\d+', '')), Bool)) {
				return line;
			}
		}

		return null;
	}

}