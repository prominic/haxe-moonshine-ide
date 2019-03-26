////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.IDataInput;
import mx.controls.Alert;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.PluginBase;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.utils.HtmlFormatter;
import actionScripts.valueObjects.Settings;
class CreateCertificate extends PluginBase {

	public static inline var EVENT_ANTBUILD:String = 'antbuildEvent';

	public static var ASCRIPTLINES:FastXML = FastXML.parse('<root><![CDATA[
							#!/bin/bash
							on run argv
							do shell script "/bin/blah > /dev/null 2>&1 &"
							set userHomePath to POSIX path of (path to home folder)
							do shell script "CreateCertificate.bat"

						end run]]></root>');

	override private function get_name():String {
		return 'Ant Build Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Ant Build Plugin. Esc exits.';
	}

	public var certificateName:String;

	private var cmdFile:File;

	private var cmdLine:CommandLine = new CommandLine();

	private var shellInfo:NativeProcessStartupInfo;

	private var nativeProcess:NativeProcess;

	private var errors:String = '';

	private var exiting:Bool = false;

	private var workingDirectory:File;

	public function new(workingDirectory:File) {
		super();
		this.workingDirectory = workingDirectory;
		if (Settings.os.toLowerCase() == 'win') {
			cmdFile = new File('c:\\Windows\\System32\\cmd.exe');
		} else if (Settings.os.toLowerCase() == 'mac') {
			cmdFile = new File('/bin/bash');
		}
	}

	public function buildCertificate():Void {
		if (nativeProcess == null) {
			if (!IDEModel.getInstance().defaultSDK) {
				Alert.show('No Flex SDK found: Creating self-signed certificate ignored.', 'Note!');
				return;
			}

			var processArgs:Array<String> = new Array<String>();
			shellInfo = new NativeProcessStartupInfo();

			if (Settings.os == 'win') {
				processArgs.push('/c');
			}

			processArgs.push(IDEModel.getInstance().defaultSDK.resolvePath('bin/adt').fileBridge.nativePath);
			processArgs.push('-certificate');
			processArgs.push('-cn');
			processArgs.push(certificateName + 'Certificate');
			processArgs.push('2048-RSA');
			processArgs.push('build' + File.separator + certificateName + 'Certificate.p12');
			processArgs.push(certificateName + 'Certificate');
			shellInfo.arguments = processArgs;
			shellInfo.executable = cmdFile;
			shellInfo.workingDirectory = workingDirectory;
			initShell();
		}
	}

	private function initShell():Void {
		if (nativeProcess != null) {
			nativeProcess.exit();
			exiting = true;
		} else {
			startShell();
		}
	}

	private function startShell():Void {
		nativeProcess = new NativeProcess();
		nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
		nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
		nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		nativeProcess.start(shellInfo);
	}

	private function shellData(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		var match:Array<Dynamic>;

		match = data.match(new as3hx.Compat.Regex('nativeProcess: Target \\d not found', ''));
		if (match != null) {
			error('Target not found. Try again.');
		}

		match = data.match(new as3hx.Compat.Regex('nativeProcess: Assigned (\\d) as the compile target id', ''));
		if (data != null) {
			match = data.match(new as3hx.Compat.Regex('(.*) \\(\\d+? bytes\\)', ''));
			if (match != null)
			// Successful Build
			{

				print('Done');
			}
		}
		if (data == '(nativeProcess) ') {
			if (errors != '') {
				compilerError(errors);
				errors = '';
			}
		}

		if (data.charAt(data.length - 1) == '\n') {
			data = data.substr(0, data.length - 1);
		}
		print('%s', data);
	}

	private function shellError(e:ProgressEvent):Void {
		var output:IDataInput = nativeProcess.standardError;
		var data:String = output.readUTFBytes(output.bytesAvailable);

		var syntaxMatch:Array<Dynamic>;
		var generalMatch:Array<Dynamic>;
		var initMatch:Array<Dynamic>;
		print(data);
		syntaxMatch = data.match(new as3hx.Compat.Regex('(.*?)\\((\\d*)\\): col: (\\d*) Error: (.*).*', ''));
		if (syntaxMatch != null) {
			var pathStr:String = syntaxMatch[1];
			var lineNum:Int = syntaxMatch[2];
			var colNum:Int = syntaxMatch[3];
			var errorStr:String = syntaxMatch[4];
			pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);
			errors += HtmlFormatter.sprintf('%s<weak>:</weak>%s \t %s\n',
					pathStr, lineNum, errorStr
			);
		}

		generalMatch = data.match(new as3hx.Compat.Regex('(.*?): Error: (.*).*', ''));
		if (syntaxMatch == null && generalMatch != null) {
			pathStr = generalMatch[1];
			errorStr = generalMatch[2];
			pathStr = pathStr.substr(pathStr.lastIndexOf('/') + 1);

			errors += HtmlFormatter.sprintf('%s: %s', pathStr, errorStr);
		}

		debug('%s', data);
	}

	private function shellExit(e:NativeProcessExitEvent):Void {
		debug('FSCH exit code: %s', e.exitCode);
		if (exiting) {
			exiting = false;
			startShell();
		}
	}

	private function compilerError(msg:Array<Dynamic> = null):Void {
		var text:String = msg.join(' ');
		var textLines:Array<Dynamic> = text.split('\n');
		var lines:Array<TextLineModel> = [];
		var i:Int = 0;
		while (i < textLines.length) {
			if (textLines[i] == '') {
				{i++;
					continue;
				}
			}
			text = '<error> ⚡  </error>' + textLines[i];
			var lineModel:TextLineModel = new TextLineModel(text);
			lines.push(lineModel);
			i++;
		}
		outputMsg(lines);
	}

}