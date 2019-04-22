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
package actionScripts.ui.editor.text.change;

class TextChangeMulti extends TextChangeBase {

	private var _changes:Array<TextChangeBase>;

	public var changes(get, never):Array<TextChangeBase>;
	private function get_changes():Array<TextChangeBase> {
		return cast _changes;
	}

	public function new(changes:Array<Dynamic> = null) {
		super(TextChangeBase.UNBLOCK);

		if (Std.is(changes[0], Array/*Vector.<T> call?*/)) {
			_changes = changes[0];
		} else {
			_changes = changes;
		}
	}

	override public function getReverse():TextChangeBase {
		var revChanges:Array<TextChangeBase> = new Array<TextChangeBase>();

		var i:Int = changes.length;

		while (i-- != 0) {
			revChanges.push(changes[i].getReverse());
		}

		return new TextChangeMulti(revChanges);
	}

}