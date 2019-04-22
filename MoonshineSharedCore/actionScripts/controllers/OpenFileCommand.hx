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
package actionScripts.controllers;

import flash.events.Event;
import mx.controls.Alert;
import mx.events.CloseEvent;
import actionScripts.events.AddTabEvent;
import actionScripts.events.EditorPluginEvent;
import actionScripts.events.FileChangeEvent;
import actionScripts.events.FilePluginEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.editor.text.DebugHighlightManager;
import actionScripts.ui.notifier.ActionNotifier;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.URLDescriptorVO;
import actionScripts.valueObjects.ProjectVO;

class OpenFileCommand implements ICommand {

	private var model:IDEModel;
	private var file:FileLocation;
	private var wrapper:FileWrapper;
	private var atLine:Int = -1;
	private var atChar:Int = -1;
	private var openAsTourDe:Bool = false;
	private var tourDeSWFSource:String;
	private var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var loader:DataAgent;
	private var lastOpenEvent:OpenFileEvent;
	private var binaryFiles:Array<Dynamic>;
	private var countIndex:Int = 0;

	public function execute(event:Event):Void {
		ActionNotifier.getInstance().notify('Open file');
		model = IDEModel.getInstance();

		if (Std.is(event, OpenFileEvent)) {
			binaryFiles = [];
			countIndex = 0;

			var openFileEvent:OpenFileEvent = AS3.as(event, OpenFileEvent);
			lastOpenEvent = openFileEvent;
			openAsTourDe = openFileEvent.openAsTourDe;
			tourDeSWFSource = openFileEvent.tourDeSWFSource;
			if (openFileEvent.atLine > -1) {
				atLine = openFileEvent.atLine;
				if (openFileEvent.atChar > -1) {
					atChar = openFileEvent.atChar;
				}
			}
			if (openFileEvent.wrappers != null && openFileEvent.wrappers.length > 0) {
				wrapper = openFileEvent.wrappers[0];
			}
			prepareBeforeOpen();
		} else if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			model.fileCore.browseForOpen('Open File', openFile, cancelOpenFile, ['*.as;*.mxml;*.css;*.txt;*.js;*.xml']);
		}
	}

	private function prepareBeforeOpen():Void {
		function fileLoadCompletes(event:Event):Void {
			if (event != null) {
				event.target.removeEventListener(Event.COMPLETE, fileLoadCompletes);
				if (UtilsCore.isBinary(Std.string(Std.string(Reflect.field(event.target, 'data'))))) {
					binaryFiles.push(tmpFL);
				} else {
					openFile(tmpFL, lastOpenEvent.type, tmpFW, Std.string(Reflect.field(event.target, 'data')));
				}
			}

			lastOpenEvent.files.shift();
			countIndex++;
			prepareBeforeOpen();
		};
		var tmpFL:FileLocation;
		var tmpFW:FileWrapper; /*
		* @local
		*/
		if (lastOpenEvent.files != null) {
			if (lastOpenEvent.files.length != 0) {
				tmpFL = lastOpenEvent.files[0];
				// in case of awd file proceed to different process
				if (tmpFL.fileBridge.extension == 'awd') {
					GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.OPEN_PROJECT_AWAY3D, tmpFL));
					fileLoadCompletes(null);
				} else {
					tmpFL.fileBridge.getFile.addEventListener(Event.COMPLETE, fileLoadCompletes);
					tmpFL.fileBridge.load();
				}
			} else if (binaryFiles.length > 0) {
				openBinaryFiles(binaryFiles);
			}
		} else {
			openFile(null, lastOpenEvent.type);
		}
	}

	private function cancelOpenFile():Void {
		/*event.target.removeEventListener(Event.SELECT, openFile);
		event.target.removeEventListener(Event.CANCEL, cancelOpenFile);*/
	}

	private function openFile(fileDir:Dynamic = null, openType:String = null, fileWrapper:FileWrapper = null, fileData:String = null):Void {
		if (AS3.as(fileDir, Bool)) {
			if (Std.is(fileDir, FileLocation)) {
				file = AS3.as(fileDir, FileLocation);
			} else {
				file = new FileLocation(AS3.string(Reflect.field(fileDir, 'nativePath')));
			}
		}

		var isFileOpen:Bool = false;

		// If file is open already, just focus that editor.
		for (contentWindow in model.editors) {
			var ed:BasicTextEditor = AS3.as(contentWindow, BasicTextEditor);
			if (ed != null
				&& ed.currentFile != null
				&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath) {
				isFileOpen = true;
				model.activeEditor = ed;
				if (atLine > -1) {
					ed.getEditorComponent().scrollTo(atLine, openType);
					if (openType == null || openType == OpenFileEvent.OPEN_FILE || openType == OpenFileEvent.JUMP_TO_SEARCH_LINE) {
						ed.getEditorComponent().selectLine(atLine);
					} else if (openType == OpenFileEvent.TRACE_LINE) {
						ed.getEditorComponent().selectTraceLine(atLine);
					}

					if (atChar > -1) {
						ed.getEditorComponent().model.caretIndex = atChar;
					}
				}
				return;
			}
		}

		// @note
		// https://github.com/prominic/Moonshine-IDE/issues/31
		// when file is not open and a debug-trace call happens
		// it never goes through the selectTraceLine(..) command for the
		// particular file, because its yet to be open.
		// thus we need some way to determine if a file needs to focus
		// to its breakpoint once it opens.
		if (!isFileOpen && openType == OpenFileEvent.TRACE_LINE) {
			DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH = Std.string(file.fileBridge.nativePath);
			DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE = atLine;
		}

		// Let plugins know that we're opening a file & abort it if they want to render it themselves
		// as this will add a link to RECENT items, add only for non 'Tour de Flex' items
		if (!openAsTourDe) {
			var plugEvent:FilePluginEvent = new FilePluginEvent(FilePluginEvent.EVENT_FILE_OPEN, file);
			ged.dispatchEvent(plugEvent);
			if (plugEvent.isDefaultPrevented()) {
				return;
			}
		}

		// Load and see if it's a binary file
		if (AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			if (openAsTourDe) {
				openTextFile(fileData, true);
			} else {
				openTextFile(fileData);
			}
			GlobalEventDispatcher.getInstance().dispatchEvent(new FileChangeEvent(FileChangeEvent.EVENT_FILECHANGE, Std.string(file.fileBridge.nativePath), 0, 0, 0));
		} else {
			if (wrapper != null) {
				wrapper.isWorking = true;
			}
			file = AS3.as(fileDir, FileLocation);
			loader = new DataAgent(URLDescriptorVO.FILE_OPEN, fileLoadedFromServer, fileFault, {
						'path': Reflect.field(Reflect.field(fileDir, 'fileBridge'), 'nativePath')
					});
		}
	}

	private function fileLoadedFromServer(value:Dynamic, message:String = null):Void {
		if (UtilsCore.isBinary(Std.string(Std.string(value)))) {
			openBinaryFiles(cast [file]);
		} else {
			openTextFile(value);
		}

		fileFault(null);
	}

	private function fileFault(message:String):Void {
		if (wrapper != null) {
			wrapper.isWorking = false;
		}
		loader = null;
		wrapper = null;
		file = null;
	}

	private function openBinaryFiles(files:Array<Dynamic>):Void {
		if ((binaryFiles.length != 0) && (binaryFiles.length > 1)) {
			Alert.buttonWidth = 90;
			Alert.yesLabel = 'Open All';
			Alert.cancelLabel = 'Cancel All';
			Alert.show('Unable to open the selected binary files.\nDo you want to open the files with the default system applications?', 'Confirm!', Alert.YES | Alert.CANCEL, null, function(event:CloseEvent):Void {
						Alert.buttonWidth = 65;
						Alert.yesLabel = 'Yes';
						Alert.cancelLabel = 'Cancel';

						if (event.detail == Alert.YES) {
							for (fl_ in files) {
								var fl:FileLocation = cast fl_;
								Reflect.field(fl, 'fileBridge').openWithDefaultApplication();
							}
						}
					});
		} else if ((binaryFiles.length != 0) && (binaryFiles.length == 1)) {
			Alert.show('Unable to open binary file ' + Reflect.field(files[0], 'name') + '.\nDo you want to open the file with the default system application?', 'Confirm!', Alert.YES | Alert.NO, null, function(event:CloseEvent):Void {
						if (event.detail == Alert.YES) {
							Reflect.field(files[0], 'fileBridge').openWithDefaultApplication();
						}
					});
		}
		// Let WebKit try to display binary files (works for images)
		/*var htmlViewer:BasicHTMLViewer = new BasicHTMLViewer();
		htmlViewer.open(file);

		ged.dispatchEvent(
		new AddTabEvent(htmlViewer)
		);*/
	}

	private function openTextFile(value:Dynamic, asTourDe:Bool = false):Void {
		// Open all text files with basic text editor
		var editor:BasicTextEditor = null;
		if (asTourDe) {
			editor = model.flexCore.getTourDeEditor(tourDeSWFSource);
		} else {
			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(wrapper);
			var extension:String = Std.string(file.fileBridge.extension);

			if (project == null) {
				project = AS3.as(model.activeProject, AS3ProjectVO);
			}

			if (Std.is(project, AS3ProjectVO) &&
				(AS3.as(project, AS3ProjectVO)).isVisualEditorProject &&
				(extension == 'mxml' || extension == 'xhtml') && !lastOpenEvent.independentOpenFile) {
				editor = model.visualEditorCore.getVisualEditor(AS3.as(project, AS3ProjectVO));
			} else if (!lastOpenEvent.independentOpenFile && model.languageServerCore.hasCustomTextEditorForUri(Std.string(file.fileBridge.url), project)) {
				editor = model.languageServerCore.getCustomTextEditorForUri(Std.string(file.fileBridge.url), project);
			} else {
				editor = new BasicTextEditor();
			}

			// requires in case of project deletion and closing all the opened
			// file instances belongs to the project
			if (wrapper != null) {
				editor.projectPath = wrapper.projectReference.path;
			}
		}

		// Let plugins hook in syntax highlighters & other functionality
		var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
		editorEvent.editor = editor.getEditorComponent();
		editorEvent.file = file;
		editorEvent.fileExtension = Std.string(file.fileBridge.extension);
		ged.dispatchEvent(editorEvent);

		editor.lastOpenType = (lastOpenEvent != null) ? lastOpenEvent.type : null;
		if (!AS3.as(ConstantsCoreVO.IS_AIR, Bool)) {
			var rawData:String = Std.string(value);
			var jsonObj:Dynamic = haxe.Json.parse(rawData);
			editor.open(file, Reflect.field(jsonObj, 'text'));
		} else {
			editor.open(file, value);
		}

		if (atLine > -1) {
			editor.scrollTo(atLine, lastOpenEvent.type);
		}

		ged.dispatchEvent(
				new AddTabEvent(editor)
		);
	}

	public function new() {}

}