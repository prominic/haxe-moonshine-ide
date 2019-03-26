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

import actionScripts.utils.SerializeUtil;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import actionScripts.events.RefreshTreeEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.svn.provider.SVNStatus;
class UpdateStatusCommand extends SVNCommandBase {

	public var status:Dynamic;

	public function new(executable:File, root:File, status:Dynamic) {
		this.status = status;
		super(executable, root);
	}

	// Modifies status object. obj[nativePath] = SVNStatus
	public function update(file:File, isTrustServerCertificateSVN:Bool):Void {
		if (runningForFile) {
			error('Currently running, try again later.');
			return;
		}

		runningForFile = file;

		customInfo = new NativeProcessStartupInfo();
		customInfo.executable = executable;

		var args:Array<String> = new Array<String>();

		/*var target:String = file.getRelativePath(root, false);
		// If we're refreshing the root we give roots name
		if (!target) target = file.name; */
		args.push('status');
		/*args.push(file.name);*/
		args.push('--xml');
		args.push('--non-interactive');
		if (isTrustServerCertificateSVN) {
			args.push('--trust-server-cert');
		}

		customInfo.arguments = args;
		// We give the file as target, so go one directory up
		customInfo.workingDirectory = file;

		customProcess = new NativeProcess();
		customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
		customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
		customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
		customProcess.start(customInfo);
	}

	private function svnError(event:ProgressEvent):Void {}

	private function svnOutput(event:ProgressEvent):Void {}

	private function svnExit(event:NativeProcessExitEvent):Void {
		if (event.exitCode == 0)
		// Refresh succeded
		{

			var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);
			var data:FastXML = new FastXML(str);

			parseStatusXML(data);

			// Show changes in project view
			dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		// Refresh failed
		else {

			var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
			error(err);

			dispatchEvent(new Event(Event.CANCEL));
		}

		runningForFile = null;
		customProcess = null;
	}

	private function parseStatusXML(data:FastXML):Void
	// Remove status for files under given file/directory
	 {

		//  in case they are now versioned we don't want to display old data
		var topPath:String = runningForFile.nativePath;
		var topPathLength:Int = topPath.length;

		for (p in Reflect.fields(status)) {
			if (p.length > topPathLength && p.substr(0, topPathLength) == topPath) {
				Reflect.deleteField(status, p);
			}
		}

		var path:String;
		var pathParts:Array<Dynamic>;
		var st:SVNStatus;
		var folderPath:String = runningForFile.parent.nativePath + File.separator;
		for (entry /* AS3HX WARNING could not determine type for var: entry exp: EField(EField(EIdent(data),target),entry) type: null */ in data.nodes.target.node.entry.innerData) {
			path = entry.att.path;
			// Add status for the path
			pathParts = path.split(File.separator);
			// Loop the path parts, skip the last one since it'll have a proper status
			// SVN only idicates which items that changed,
			// 	 we want to display something for all directories leading up to each item
			var pathTrail:String = '';
			var i:Int = 0;
			while (i < pathParts.length - 1) {
				pathTrail += pathParts[i];
				st = new SVNStatus();
				st.status = 'childChanged';
				Reflect.setField(status, Std.string(folderPath + pathTrail), st);
				pathTrail += File.separator;
				i++;
			}

			// Add status for the file
			st = new SVNStatus();
			st.status = Std.string(entry.child('wc-status').att.item);
			st.revision = as3hx.Compat.parseInt(entry.child('wc-status').att.revision);
			st.author = entry.descendants('author');
			st.treeConflict = SerializeUtil.deserializeBoolean(entry.child('wc.status').attribute('tree-conflicted'));
			//st.date = DateUtil.parseBlaDate(entry..date);
			Reflect.setField(status, path, st);
		}
	}

}