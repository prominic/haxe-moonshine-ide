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

import mx.collections.ArrayCollection;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.LanguageServerEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.LanguageServerTextEditor;
import actionScripts.utils.ApplyTextEditsToFile;
import actionScripts.valueObjects.CreateFile;
import actionScripts.valueObjects.DeleteFile;
import actionScripts.valueObjects.RenameFile;
import actionScripts.valueObjects.TextEdit;

import actionScripts.valueObjects.TextDocumentEdit;

import actionScripts.valueObjects.WorkspaceEdit;

/**
 * Class for applyWorkspaceEdit
 */
@:final class ApplyWorkspaceEdit {

	public static function applyWorkspaceEdit(edit:WorkspaceEdit):Void {
		var changes:Dynamic = edit.changes;
		if (AS3.as(changes, Bool)) {
			for (uri in Reflect.fields(changes)) {
				var textEdits:Array<TextEdit> = try cast(Reflect.field(changes, uri), Vector) catch(e:Dynamic) null;
				ApplyTextEditsToURI.applyTextEditsToURI(uri, textEdits);
			}
		}
		var documentChanges:Array<Dynamic> = edit.documentChanges;
		if (documentChanges != null) {
			var documentChangesCount:Int = documentChanges.length;
			for (i in 0...documentChangesCount) {
				var documentChange:Dynamic = documentChanges[i];
				if (Std.is(documentChange, TextDocumentEdit)) {
					var textDocumentEdit:TextDocumentEdit = TextDocumentEdit(documentChange);
					ApplyTextEditsToURI.applyTextEditsToURI(
							textDocumentEdit.textDocument.uri,
							textDocumentEdit.edits
				);
				} else if (Reflect.hasField(documentChange, 'kind')) {
					switch (Reflect.field(documentChange, 'kind')) {
						case RenameFile.KIND:
							var renameFile:RenameFile = RenameFile(documentChange);
							HandleRenameFile.handleRenameFile(renameFile);
						case CreateFile.KIND:
							var createFile:CreateFile = CreateFile(documentChange);
							HandleCreateFile.handleCreateFile(createFile);
						case DeleteFile.KIND:
							var deleteFile:DeleteFile = DeleteFile(documentChange);
							HandleDeleteFile.handleDeleteFile(deleteFile);
						case _:
							{
								trace('applyWorkspaceEdit: Unknown document change kind ' + Reflect.field(documentChange, 'kind'));
							}
					}
				} else {
					trace('applyWorkspaceEdit: Unknown document change ' + documentChange);
				}
			}
		}
	}

}

/**
 * Class for applyTextEditsToURI
 */
@:final class ApplyTextEditsToURI {

	private static function applyTextEditsToURI(uri:String, textEdits:Array<TextEdit>):Void {
		var file:FileLocation = new FileLocation(uri, true);
		ApplyTextEditsToFile.applyTextEditsToFile(file, textEdits);
	}

}

/**
 * Class for handleRenameFile
 */
@:final class HandleRenameFile {

	private static function handleRenameFile(renameFile:RenameFile):Void {
		var renameOldLocation:FileLocation = new FileLocation(renameFile.oldUri, true);
		var renameNewLocation:FileLocation = new FileLocation(renameFile.newUri, true);
		renameOldLocation.fileBridge.moveTo(renameNewLocation, true);

		var editors:ArrayCollection = IDEModel.getInstance().editors;
		var editorCount:Int = AS3.int(editors.length);
		for (i in 0...editorCount) {
			var editor:LanguageServerTextEditor = AS3.as(editors.getItemAt(i), LanguageServerTextEditor);
			if (editor == null) {
				continue;
			}
			var editorFile:FileLocation = editor.currentFile;
			if (editorFile == null || editorFile.fileBridge.nativePath != renameOldLocation.fileBridge.nativePath) {
				continue;
			}
			editor.currentFile = renameNewLocation;
			GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDCLOSE,
					0, 0, 0, 0, null, 0, 0, Std.string(renameOldLocation.fileBridge.url)));
			GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
					0, 0, 0, 0, editor.getEditorComponent().dataProvider, 0, 0, Std.string(renameNewLocation.fileBridge.url)));
		}
	}

}

/**
 * Class for handleCreateFile
 */
@:final class HandleCreateFile {

	private static function handleCreateFile(createFile:CreateFile):Void {
		var createLocation:FileLocation = new FileLocation(createFile.uri, true);
		createLocation.fileBridge.createFile();
	}

}

/**
 * Class for handleDeleteFile
 */
@:final class HandleDeleteFile {

	private static function handleDeleteFile(deleteFile:DeleteFile):Void {
		var deleteLocation:FileLocation = new FileLocation(deleteFile.uri, true);
		if (AS3.as(deleteLocation.fileBridge.exists, Bool)) {
			if (AS3.as(deleteLocation.fileBridge.isDirectory, Bool)) {
				deleteLocation.fileBridge.deleteDirectory(true);
			} else {
				deleteLocation.fileBridge.deleteFile();
			}
		}
	}

}