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
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.system.MessageChannel;
import flash.system.Worker;
import actionScripts.events.WorkerEvent;
import actionScripts.utils.WorkerListOfNativeProcess;
import actionScripts.valueObjects.WorkerFileWrapper;

class MoonshineWorker extends Sprite {

	public static var READABLE_FILES_PATTERNS(default, never):Array<Dynamic> = cast ['as', 'mxml', 'css', 'xml', 'bat', 'txt', 'as3proj', 'actionScriptProperties', 'html', 'js', 'veditorproj'];

	public static var FILES_COUNT:Int = 0;
	public static var FILE_PROCESSED_COUNT:Int = 0;
	public static var FILES_FOUND_IN_COUNT:Int = 0;
	public static var IS_MACOS:Bool = false;

	public var mainToWorker:MessageChannel;
	public var workerToMain:MessageChannel;

	private var projectSearchObject:Dynamic;
	private var projects:Array<Dynamic>;
	private var totalFoundCount:Int = 0;
	private var customFilePatterns:Array<Dynamic> = [];
	private var isCustomFilePatterns:Bool = false;
	private var isStorePathsForProbableReplace:Bool = false;
	private var storedPathsForProbableReplace:Array<Dynamic>;
	private var gitListProcessClasses:haxe.ds.ObjectMap<Dynamic, Dynamic> = new haxe.ds.ObjectMap<Dynamic, Dynamic>();

	private var customProcess:NativeProcess;
	private var customInfo:NativeProcessStartupInfo;

	public function new() {
		super();
		// receive from main
		mainToWorker = Worker.current.getSharedProperty('mainToWorker');
		// Send to main
		workerToMain = Worker.current.getSharedProperty('workerToMain');

		if (mainToWorker != null) {
			mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
		}
	}

	private function onMainToWorker(event:Event):Void {
		var incomingObject:Dynamic = mainToWorker.receive();
		switch (Reflect.field(incomingObject, 'event')) {
			case WorkerEvent.SET_IS_MACOS:
				IS_MACOS = AS3.as(Reflect.field(incomingObject, 'value'), Bool);
			case WorkerEvent.SEARCH_IN_PROJECTS:
				projectSearchObject = incomingObject;
				projects = Reflect.field(Reflect.field(projectSearchObject, 'value'), 'projects');
				isStorePathsForProbableReplace = AS3.as(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'isShowReplaceWhenDone'), Bool);
				FILES_FOUND_IN_COUNT = 0;
				storedPathsForProbableReplace = null;
				storedPathsForProbableReplace = [];
				parseProjectsTree();
			case WorkerEvent.REPLACE_FILE_WITH_VALUE:
				projectSearchObject = incomingObject;
				startReplacing();
			case WorkerEvent.GET_FILE_LIST:
				workerToMain.send({
							'event': WorkerEvent.GET_FILE_LIST,
							'value': storedPathsForProbableReplace
						});
			case WorkerEvent.SET_FILE_LIST:
				storedPathsForProbableReplace = cast AS3.asArray(Reflect.field(incomingObject, 'value'));
			case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS:
				// the list of np must have a non-null sub-id
				if (AS3.as(Reflect.field(incomingObject, 'subscriberUdid'), Bool)) {
					getListProcessClass(AS3.string(Reflect.field(incomingObject, 'subscriberUdid'))).runProcesses(Reflect.field(incomingObject, 'value'));
				}
		}
	}

	private function getListProcessClass(udid:String):WorkerListOfNativeProcess {
		if (gitListProcessClasses.get(udid) != null) {
			return gitListProcessClasses.get(udid);
		}

		// in case of non-existence
		var gitProcess:WorkerListOfNativeProcess = new WorkerListOfNativeProcess();
		gitProcess.worker = this;
		gitProcess.subscriberUdid = udid;
		gitListProcessClasses.set(udid, gitProcess);
		return gitProcess;
	}

	private function parseProjectsTree():Void {
		function isValidExtension(item:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return item == '*';
		};
		// probable termination
		if (projects.length == 0) {
			workerToMain.send({
						'event': WorkerEvent.PROCESS_ENDS,
						'value': FILES_FOUND_IN_COUNT
					});
			return;
		}

		FILES_COUNT = FILE_PROCESSED_COUNT = 0;
		totalFoundCount = 0;
		isCustomFilePatterns = false;

		var tmpWrapper:WorkerFileWrapper = new WorkerFileWrapper(new File(projects[0]), true);

		// in case a given path is not valid, do not parse anything
		if (!AS3.as(tmpWrapper.file.exists, Bool)) {
			// restart with available next project (if any)
			projects.shift();
			var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
						as3hx.Compat.clearTimeout(timeoutValue);
						parseProjectsTree();
					}, 400);
			return;
		}

		workerToMain.send({
					'event': WorkerEvent.TOTAL_FILE_COUNT,
					'value': FILES_COUNT
				});

		if (Reflect.field(Reflect.field(projectSearchObject, 'value'), 'patterns') != '*') {
			var filtered:String = Std.string(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'patterns').replace(new as3hx.Compat.Regex('( )', 'g'), ''));
			customFilePatterns = cast filtered.split(',');

			var hasGloablSearchSign:Bool = AS3.as(customFilePatterns.some(), Bool);

			isCustomFilePatterns = !hasGloablSearchSign;
		}

		parseChildrens(tmpWrapper);
	}

	private function parseChildrens(value:Dynamic):Void {
		function notifyFileCountCompletionToMain():Void {
			tmpLineObject = null;
			workerToMain.send({
						'event': WorkerEvent.FILE_PROCESSED_COUNT,
						'value': ++FILE_PROCESSED_COUNT
					});
		};
		if (!AS3.as(value, Bool)) {
			return;
		}

		var extension:String = AS3.string(Reflect.field(Reflect.field(value, 'file'), 'extension'));
		var tmpReturnCount:Int;
		var tmpLineObject:Dynamic; /*
		 * @local
		 */

		if ((Std.is(Reflect.field(value, 'children'), Array)) && (AS3.asArray(Reflect.field(value, 'children'))).length > 0) {
			var tmpTotalChildrenCount:Int = AS3.int(Reflect.field(value, 'children').length);
			var c:Int = 0;
			while (c < Reflect.field(value, 'children').length) {
				extension = AS3.string(Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'extension'));
				var isAcceptable:Bool = ((extension != null)) ? isAcceptableResource(extension) : false;
				if (!AS3.as(Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'isDirectory'), Bool) && isAcceptable) {
					tmpLineObject = testFilesForValueExist(AS3.string(Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'nativePath')));
					tmpReturnCount = (AS3.as(tmpLineObject, Bool)) ? AS3.int(Reflect.field(tmpLineObject, 'foundCountInFile')) : -1;
					if (tmpReturnCount == -1) {
						Reflect.field(value, 'children').splice(c, 1);
						tmpTotalChildrenCount--;
						c--;
					} else {
						Reflect.setField(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'searchCount', tmpReturnCount);
						Reflect.setField(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'children', Reflect.field(tmpLineObject, 'foundMatches'));
						totalFoundCount += tmpReturnCount;
						FILES_FOUND_IN_COUNT++;
						if (isStorePathsForProbableReplace) {
							storedPathsForProbableReplace.push({
										'label': Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'nativePath'),
										'isSelected': true
									});
						}
					}
				} else if (!AS3.as(Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'isDirectory'), Bool) && !isAcceptable) {
					Reflect.field(value, 'children').splice(c, 1);
					tmpTotalChildrenCount--;
					c--;
				} else if (AS3.as(Reflect.field(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'file'), 'isDirectory'), Bool)) {
					//lastChildren = value.children;
					parseChildrens(Reflect.field(Reflect.field(value, 'children'), Std.string(c)));
					if (!AS3.as(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'children'), Bool) || (AS3.as(Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'children'), Bool) && Reflect.field(Reflect.field(Reflect.field(value, 'children'), Std.string(c)), 'children').length == 0)) {
						Reflect.field(value, 'children').splice(c, 1);
						c--;
					}
				}

				notifyFileCountCompletionToMain();
				c++;
			}

			// when recursive listing done
			if (AS3.as(Reflect.field(value, 'isRoot'), Bool)) {
				notifyFileCountCompletionToMain();
				workerToMain.send({
							'event': WorkerEvent.TOTAL_FOUND_COUNT,
							'value': Reflect.field(Reflect.field(value, 'file'), 'nativePath') + '::' + totalFoundCount
						});
				workerToMain.send({
							'event': WorkerEvent.FILTERED_FILE_COLLECTION,
							'value': value
						});

				// restart with available next project (if any)
				projects.shift();
				var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
							as3hx.Compat.clearTimeout(timeoutValue);
							parseProjectsTree();
						}, 400);
			}
		} else {
			notifyFileCountCompletionToMain();
		}
	}

	private function isAcceptableResource(extension:String):Bool {
		function isValidExtension(item:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return item == extension;
		};
		function isValidExtension(item:Dynamic, index:Int, arr:Array<Dynamic>):Bool {
			return item == extension;
		};
		if (isCustomFilePatterns) {
			return AS3.as(customFilePatterns.some(), Bool);
		}

		return AS3.as(READABLE_FILES_PATTERNS.some(), Bool);
	}

	private function startReplacing():Void {
		for (i in storedPathsForProbableReplace) {
			if (AS3.as(Reflect.field(i, 'isSelected'), Bool)) {
				testFilesForValueExist(AS3.string(Reflect.field(i, 'label')), AS3.string(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'valueToReplace')));
				workerToMain.send({
							'event': WorkerEvent.FILE_PROCESSED_COUNT,
							'value': Reflect.field(i, 'label')
						});// sending path value instead of completion count in case of replace
			}
		}

		// once done
		workerToMain.send({
					'event': WorkerEvent.PROCESS_ENDS,
					'value': null
				});
	}

	private function testFilesForValueExist(value:String, replace:String = null):Dynamic {
		function replaceAndSaveFile():Void {
			content = searchRegExp.replace(content, replace);

			r = new FileStream();
			r.open(f, FileMode.WRITE);
			r.writeUTFBytes(content);
			r.close();
		};
		var r:FileStream = new FileStream();
		var f:File = new File(value);
		r.open(f, FileMode.READ);
		var content:String = Std.string(r.readUTFBytes(f.size));
		r.close();

		// remove all the leading space/tabs in a line
		// so we can show the lines without having space/tabs in search results
		content = new as3hx.Compat.Regex('^[ \\t]+(?=\\S)', 'gm').replace(content, '');
		content = Std.string(StringTools.trim(content));

		var searchString:String = (AS3.as(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'isEscapeChars'), Bool)) ? escapeRegex(AS3.string(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'valueToSearch'))) : AS3.string(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'valueToSearch'));
		var flags:String = 'g';
		if (!AS3.as(Reflect.field(Reflect.field(projectSearchObject, 'value'), 'isMatchCase'), Bool)) {
			flags += 'i';
		}
		var searchRegExp:as3hx.Compat.Regex = new as3hx.Compat.Regex(searchString, flags);

		//var foundMatches:Array = content.match(searchRegExp);

		var foundMatches:Array<Dynamic> = [];
		var results:Array<Dynamic> = searchRegExp.exec(content);
		var tmpFW:WorkerFileWrapper;
		var res:SearchResult;
		var lastLineIndex:Int = -1;
		var foundCountInFile:Int;
		var lines:Array<Dynamic>;
		while (results != null) {
			var lc:Point = charIdx2LineCharIdx(content, AS3.int(results.index), '\n');

			res = new SearchResult();
			res.startLineIndex = AS3.int(lc.x);
			res.endLineIndex = AS3.int(lc.x);
			res.startCharIndex = AS3.int(lc.y);
			res.endCharIndex = AS3.int(lc.y + results[0].length);

			if (res.startLineIndex != lastLineIndex) {
				lines = cast content.split(Std.string(new as3hx.Compat.Regex('\\r?\\n|\\r', '')));
				tmpFW = new WorkerFileWrapper(null);
				tmpFW.isShowAsLineNumber = true;
				tmpFW.lineNumbersWithRange = [];
				tmpFW.fileReference = value;
				foundMatches.push(tmpFW);
				lastLineIndex = res.startLineIndex;
			}

			//tmpFW.lineText = StringUtil.trim(lines[res.startLineIndex]);
			tmpFW.lineText = Std.string(lines[res.startLineIndex]);
			tmpFW.lineNumbersWithRange.push(res);
			results = searchRegExp.exec(content);

			// since a line could have multiple searched instance
			// we need to count do/while separately other than
			// counting total lines (foundMatches)
			foundCountInFile++;
		}

		if (foundMatches.length > 0 && replace != null) {
			replaceAndSaveFile();
		}

		lines = null;
		content = null; /*
		 * @local
		 */
		return (((foundMatches.length > 0)) ? {
			'foundMatches': foundMatches,
			'foundCountInFile': foundCountInFile
		} : null);
	}

	private function escapeRegex(str:String):String {
		return new as3hx.Compat.Regex('[\\$\\(\\)\\*\\+\\.\\[\\]\\?\\\\\\^\\{\\}\\|]', 'g').replace(str, '\\$&');
	}

	private function charIdx2LineCharIdx(str:String, charIdx:Int, lineDelim:String):Point {
		var line:Int = str.substr(0, charIdx).split(lineDelim).length - 1;
		var chr:Int = (line > 0) ? charIdx - str.lastIndexOf(lineDelim, charIdx - 1) - lineDelim.length : charIdx;
		return new Point(line, chr);
	}

}

class SearchResult {

	public var startLineIndex:Int = -1;
	public var startCharIndex:Int = -1;
	public var endLineIndex:Int = -1;
	public var endCharIndex:Int = -1;
	public var totalMatches:Int = 0;
	public var totalReplaces:Int = 0;
	public var selectedIndex:Int = 0;
	public var didWrap:Bool = false;

	public function new() {}

}