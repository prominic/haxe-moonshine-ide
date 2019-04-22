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

import flash.errors.Error;
import flash.events.Event;
import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;

class OpenFileEvent extends Event {

	public static inline var OPEN_FILE:String = 'openFileEvent';
	public static inline var TRACE_LINE:String = 'traceLineEvent';
	public static inline var JUMP_TO_SEARCH_LINE:String = 'jumpToLineEvent';

	public var files:Array<FileLocation>;
	public var atLine:Int = 0;
	public var atChar:Int = -1;
	public var wrappers:Array<FileWrapper>;
	public var openAsTourDe:Bool = false;
	public var tourDeSWFSource:String;

	public var independentOpenFile:Bool = false;
// when arbitrary file opened off-Moonshine, or drag into off-Moonshine

	public function new(type:String, files:Array<Dynamic> = null, atLine:Int = -1, wrappers:Array<Dynamic> = null, param:Array<Dynamic> = null) {
		try {
			if (files != null) {
				this.files = AS3.asArray(files);
			}
			if (wrappers != null) {
				this.wrappers = AS3.asArray(wrappers);
			}
		} catch (e:Error) {
			trace('Error:: Unrecognized \'Open\' object type.');
		}

		this.atLine = atLine;
		if (param != null && param.length > 0) {
			this.openAsTourDe = param[0] != null;
			if (this.openAsTourDe) {
				this.tourDeSWFSource = Std.string(param[1]);
			}
		}

		super(type, false, true);
	}

}