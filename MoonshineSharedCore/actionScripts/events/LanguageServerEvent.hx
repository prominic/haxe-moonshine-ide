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
package actionScripts.events;

import flash.events.Event;

class LanguageServerEvent extends Event {

	public static inline var EVENT_DIDOPEN:String = 'newDidOpenEvent';
	public static inline var EVENT_DIDCLOSE:String = 'newDidCloseEvent';
	public static inline var EVENT_DIDCHANGE:String = 'newDidChangeEvent';
	public static inline var EVENT_WILLSAVE:String = 'newWillSaveEvent';
	public static inline var EVENT_DIDSAVE:String = 'newDidSaveEvent';
	public static inline var EVENT_COMPLETION:String = 'newCompletionEvent';
	public static inline var EVENT_SIGNATURE_HELP:String = 'newSignatureHelpEvent';
	public static inline var EVENT_HOVER:String = 'newHover';
	public static inline var EVENT_DEFINITION_LINK:String = 'newDefinitionLink';
	public static inline var EVENT_DOCUMENT_SYMBOLS:String = 'newDocumentSymbols';
	public static inline var EVENT_WORKSPACE_SYMBOLS:String = 'newWorkspaceSymbols';
	public static inline var EVENT_FIND_REFERENCES:String = 'newFindReferences';
	public static inline var EVENT_RENAME:String = 'newRename';
	public static inline var EVENT_CODE_ACTION:String = 'newCodeAction';

	public var startLinePos:Float;
	public var endLinePos:Float;
	public var startLineNumber:Float;
	public var endLineNumber:Float;
	public var newText:String;
	public var textlen:Float;
	public var version:Float;
	public var uri:String;

	public function new(type:String, startLinePos:Float = 0, startLineNumber:Float = 0,
			endLinePos:Float = 0, endLineNumber:Float = 0,
			newText:String = null, textlen:Float = 0, version:Float = 0,
			uri:String = null) {
		this.startLinePos = startLinePos;
		this.endLinePos = endLinePos;
		this.startLineNumber = startLineNumber;
		this.endLineNumber = endLineNumber;
		this.newText = newText;
		this.textlen = textlen;
		this.version = version;
		this.uri = uri;
		super(type, false, true);
	}

}