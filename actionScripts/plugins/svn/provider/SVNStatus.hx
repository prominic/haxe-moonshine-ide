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
package actionScripts.plugins.svn.provider;

class SVNStatus {

	public var status(get, set):String;
	public var canBeCommited(get, never):Bool;

	public var shortStatus:String;

	private var _status:String;

	private function get_status():String {
		return _status;
	}

	private function set_status(v:String):String {
		_status = v;
		shortStatus =
				((v == 'modified')) ? 'm' :
				((v == 'unversioned')) ? '?' :
				((v == 'obstructed')) ? '!' :
				((v == 'added')) ? '+' :
				((v == 'deleted')) ? 'd' :
				((v == 'childChanged')) ? '*' :  // Non-SVN entry, used to indicate that an item further down is changed
				'ERR';
		return v;
	}

	private function get_canBeCommited():Bool {
		if (Lambda.indexOf(['modified', 'added', 'unversioned', 'deleted'], status) > -1) {
			return true;
		} else {
			return false;
		}
	}

	public var revision:Int;

	public var author:String;

	public var date:Date;

	public var treeConflict:Bool;

	public function new() {}

}