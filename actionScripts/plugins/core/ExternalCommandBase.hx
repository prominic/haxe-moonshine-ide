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
package actionScripts.plugins.core;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.filesystem.File;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleOutputter;
class ExternalCommandBase extends ConsoleOutputter {

	private var executable:File;

	private var root:File;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var customProcess:NativeProcess;

	private var customInfo:NativeProcessStartupInfo;

	public function new(executable:File, root:File) {
		super();
		this.executable = executable;
		this.root = root;
	}

}