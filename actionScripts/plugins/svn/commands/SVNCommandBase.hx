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
package actionScripts.plugins.svn.commands;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filesystem.File;
import flash.utils.IDataOutput;
import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.core.ExternalCommandBase;
import actionScripts.plugins.svn.view.ServerCertificateDialog;
class SVNCommandBase extends ExternalCommandBase {

	override private function get_name():String {
		return 'Subversion Plugin';
	}

	public function new(executable:File, root:File) {
		super(executable, root);
	}

	// Only allow one operation at a time
	private var runningForFile:File;

	/*
	Handle SVN asking about Server Certificate approval/rejection
	*/
	private function serverCertificatePrompt(data:String):Void
	// Strip stuff we don't want
	 {

		data = StringTools.replace(data, '(R)eject, accept (t)emporarily or accept (p)ermanently?', '');

		var d:ServerCertificateDialog = new ServerCertificateDialog();
		d.prompt = data;
		d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
		d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
		d.addEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);

		PopUpManager.addPopUp(d, try cast(FlexGlobals.topLevelApplication, DisplayObject) catch (e:Dynamic) null);
		PopUpManager.centerPopUp(d);
	}

	// (R)eject, accept (t)emporarily or accept (p)ermanently?
	private function acceptPerm(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('p\n');
		removeCertDialog(event);
	}

	private function acceptTemp(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('t\n');
		removeCertDialog(event);
	}

	private function dontAccept(event:Event):Void {
		var input:IDataOutput = customProcess.standardInput;
		input.writeUTFBytes('r\n');
		removeCertDialog(event);
	}

	private function removeCertDialog(event:Event):Void {
		var d:ServerCertificateDialog = cast((event.target), ServerCertificateDialog);
		PopUpManager.removePopUp(d);

		d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
		d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
		d.removeEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);
	}

}