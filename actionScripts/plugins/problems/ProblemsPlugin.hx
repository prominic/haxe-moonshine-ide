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
package actionScripts.plugins.problems;

import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.controls.AdvancedDataGrid;
import mx.events.ListEvent;
import actionScripts.events.DiagnosticsEvent;
import actionScripts.events.GeneralEvent;
import actionScripts.events.OpenFileEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.PluginBase;
import actionScripts.plugins.problems.view.ProblemsView;
import actionScripts.ui.IPanelWindow;
import actionScripts.ui.LayoutModifier;
import actionScripts.valueObjects.Diagnostic;
class ProblemsPlugin extends PluginBase {

	public static inline var EVENT_PROBLEMS:String = 'EVENT_PROBLEMS';

	public function new() {
		super();
	}

	override private function get_name():String {
		return 'Problems Plugin';
	}

	override private function get_author():String {
		return 'Moonshine Project Team';
	}

	override private function get_description():String {
		return 'Displays problems in source files.';
	}

	private var problemsPanel:ProblemsView = new ProblemsView();

	private var isStartupCall:Bool = true;

	override public function activate():Void {
		super.activate();
		dispatcher.addEventListener(EVENT_PROBLEMS, handleProblemsShow);
		dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
	}

	override public function deactivate():Void {
		super.deactivate();
		dispatcher.removeEventListener(EVENT_PROBLEMS, handleProblemsShow);
		dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
	}

	private function handleProblemsShow(event:Event):Void {
		LayoutModifier.addToSidebar(problemsPanel, event);

		problemsPanel.validateNow();
		problemsPanel.problemsTree.addEventListener(ListEvent.ITEM_CLICK, handleProblemClick);
		isStartupCall = false;
	}

	private function handleShowDiagnostics(event:DiagnosticsEvent):Void {
		var path:String = event.path;
		var objectTree:ArrayCollection = problemsPanel.objectTree;
		var itemCount:Int = objectTree.length;
		var i:Int = as3hx.Compat.parseInt(itemCount - 1);
		while (i >= 0) {
			var item:Diagnostic = cast((objectTree.getItemAt(i)), Diagnostic);
			if (item.path == path) {
				objectTree.removeItemAt(i);
			}
			i--;
		}
		var diagnostics:Array<Diagnostic> = event.diagnostics;
		itemCount = diagnostics.length;
		for (i in 0...itemCount) {
			item = diagnostics[i];
			objectTree.addItem(item);
		}
	}

	private function handleProblemClick(event:ListEvent):Void {
		var diagnostic:Diagnostic = cast((event.itemRenderer.data), Diagnostic);
		var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
		[new FileLocation(diagnostic.path)], diagnostic.range.start.line);
		openEvent.atChar = diagnostic.range.start.character;
		dispatcher.dispatchEvent(openEvent);
	}

}