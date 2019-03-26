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

import flash.events.Event;
import flash.filesystem.File;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugins.svn.commands.CheckoutCommand;
import actionScripts.plugins.svn.commands.CommitCommand;
import actionScripts.plugins.svn.commands.UpdateCommand;
import actionScripts.plugins.svn.event.SVNEvent;
class SubversionProvider extends ConsoleOutputter {

	private var status:Dynamic = {};

	public var executable:File;

	public var root:File;

	public var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	override private function get_name():String {
		return 'Subversion plugin';
	}

	private function handleCommit(event:Event):Void {
		commit(cast((event.target.data), FileLocation));
	}

	public function commit(file:FileLocation, message:String = null, user:String = null, password:String = null, commitInfo:Dynamic = null, isTrustServerCertificateSVN:Bool = false):Void {
		var commitCommand:CommitCommand = new CommitCommand(executable, root, status);
		commitCommand.commit(file, message, user, password, commitInfo, isTrustServerCertificateSVN);
	}

	private function handleUpdate(event:Event):Void {
		update(cast((event.target.data), FileLocation));
	}

	public function update(file:FileLocation, user:String = null, password:String = null, isTrustServerCertificateSVN:Bool = false):Void {
		var updateCommand:UpdateCommand = new UpdateCommand(executable, root);
		updateCommand.update(file, user, password, isTrustServerCertificateSVN);
	}

	public function checkout(event:SVNEvent, isTrustServerCertificateSVN:Bool):Void {
		var checkoutCommand:CheckoutCommand = new CheckoutCommand(executable, root);
		checkoutCommand.checkout(event, isTrustServerCertificateSVN);
	}

	public function new() {
		super();
	}

}