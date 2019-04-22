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
		if (runningForFile != null) {
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
		if (event.exitCode == 0) {
			// Refresh succeded
			var str:String = Std.string(customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable));
			var data:FastXML = new FastXML(str);

			parseStatusXML(data);

			// Show changes in project view
			dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);

			dispatchEvent(new Event(Event.COMPLETE));
		} else {
			// Refresh failed
			var err:String = Std.string(customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable));
			error(err);

			dispatchEvent(new Event(Event.CANCEL));
		}

		runningForFile = null;
		customProcess = null;
	}

	private function parseStatusXML(data:FastXML):Void {
		// Remove status for files under given file/directory
		//  in case they are now versioned we don't want to display old data
		var topPath:String = Std.string(runningForFile.nativePath);
		var topPathLength:Int = topPath.length;

		for (p in Reflect.fields(status)) {
			if (p.length > topPathLength && p.substr(0, topPathLength) == topPath) {
				Reflect.deleteField(status, p);
			}
		}

		var path:String;
		var pathParts:Array<Dynamic>;
		var st:SVNStatus;
		var folderPath:String = Std.string(runningForFile.parent.nativePath + File.separator);
		for (entry in data.nodes.target.descendants('entry')) {
			path = Std.string(entry.att.path);
			// Add status for the path
			pathParts = cast path.split(Std.string(File.separator));
			// Loop the path parts, skip the last one since it'll have a proper status
			// SVN only idicates which items that changed,
			// 	 we want to display something for all directories leading up to each item
			var pathTrail:String = '';
			for (i in 0...pathParts.length - 1) {
				pathTrail += Std.string(pathParts[i]);
				st = new SVNStatus();
				st.status = 'childChanged';
				Reflect.setField(status, folderPath + pathTrail, st);
				pathTrail += Std.string(File.separator);
			}

			// Add status for the file
			st = new SVNStatus();
			st.status = Std.string(Std.string(entry.descendants('child')('wc-status').att.item));
			st.revision = as3hx.Compat.parseInt(entry.descendants('child')('wc-status').att.revision);
			st.author = Std.string(entry.descendants('author'));
			st.treeConflict = AS3.as(SerializeUtil.deserializeBoolean(entry.descendants('child')('wc.status').attribute('tree-conflicted')), Bool);
			//st.date = DateUtil.parseBlaDate(entry..date);
			Reflect.setField(status, path, st);
		}
	}

}