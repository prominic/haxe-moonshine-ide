package actionScripts.impls;

import flash.errors.URIError;

import actionScripts.interfaces.ILanguageServerBridge;
import flash.errors.IllegalOperationError;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.languageServer.ILanguageServerManager;
import actionScripts.events.ProjectEvent;
import flash.events.Event;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.languageServer.ActionScriptLanguageServerManager;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.languageServer.JavaLanguageServerManager;
import actionScripts.ui.editor.BasicTextEditor;
class ILanguageServerBridgeImp implements ILanguageServerBridge {

	public var connectedProjectCount(get, never):Int;

	private static inline var URI_SCHEME_FILE:String = 'file';

	public function new() {
		dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
		dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
	}

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var managers:Array<ILanguageServerManager> = [];

	private var connectedManagers:Array<ILanguageServerManager> = [];

	private function get_connectedProjectCount():Int {
		return connectedManagers.length;
	}

	public function hasLanguageServerForProject(project:ProjectVO):Bool {
		var serverCount:Int = managers.length;
		for (i in 0...serverCount) {
			var manager:ILanguageServerManager = managers[i];
			if (manager.project == project) {
				return true;
			}
		}
		return false;
	}

	public function hasCustomTextEditorForUri(uri:String, project:ProjectVO):Bool {
		var colonIndex:Int = uri.indexOf(':');
		if (colonIndex == -1) {
			throw new URIError('Invalid URI: ' + uri);
		}
		var scheme:String = uri.substr(0, colonIndex);
		var uriWithoutParams:String = uri;
		var paramsIndex:Int = uriWithoutParams.lastIndexOf('?');
		if (paramsIndex != -1) {
			uriWithoutParams = uri.substr(0, paramsIndex);
		}
		var extension:String = '';
		var dotIndex:Int = uriWithoutParams.lastIndexOf('.');
		if (dotIndex != -1) {
			extension = uriWithoutParams.substr(dotIndex + 1);
		}

		var managerCount:Int = managers.length;
		for (i in 0...managerCount) {
			var manager:ILanguageServerManager = managers[i];
			if (manager.project != project) {
				continue;
			}
			if (scheme == URI_SCHEME_FILE) {
				var extensionIndex:Int = manager.fileExtensions.indexOf(extension);
				if (extensionIndex != -1) {
					return true;
				}
			} else {
				var schemeIndex:Int = manager.uriSchemes.indexOf(scheme);
				if (schemeIndex != -1) {
					return true;
				}
			}
		}
		return false;
	}

	public function getCustomTextEditorForUri(uri:String, project:ProjectVO, readOnly:Bool = false):BasicTextEditor {
		var colonIndex:Int = uri.indexOf(':');
		if (colonIndex == -1) {
			throw new URIError('Invalid URI: ' + uri);
		}
		var scheme:String = uri.substr(0, colonIndex);
		var uriWithoutParams:String = uri;
		var paramsIndex:Int = uriWithoutParams.lastIndexOf('?');
		if (paramsIndex != -1) {
			uriWithoutParams = uri.substr(0, paramsIndex);
		}
		var extension:String = '';
		var dotIndex:Int = uriWithoutParams.lastIndexOf('.');
		if (dotIndex != -1) {
			extension = uriWithoutParams.substr(dotIndex + 1);
		}

		var managerCount:Int = managers.length;
		for (i in 0...managerCount) {
			var manager:ILanguageServerManager = managers[i];
			if (manager.project != project) {
				continue;
			}
			if (scheme == URI_SCHEME_FILE) {
				var extensionIndex:Int = manager.fileExtensions.indexOf(extension);
				if (extensionIndex != -1) {
					return manager.createTextEditorForUri(uri, readOnly);
				}
			} else {
				var schemeIndex:Int = manager.uriSchemes.indexOf(scheme);
				if (schemeIndex != -1) {
					return manager.createTextEditorForUri(uri, readOnly);
				}
			}
		}
		return null;
	}

	private function removeProjectHandler(event:ProjectEvent):Void {
		var project:ProjectVO = try cast(event.project, ProjectVO) catch (e:Dynamic) null;
		var managerCount:Int = managers.length;
		for (i in 0...managerCount) {
			var manager:ILanguageServerManager = managers[i];
			if (manager.project == project)
			//don't remove from connectedManagers until
			{

				managers.splice(i, 1);
				cleanupManager(manager);
				break;
			}
		}
	}

	private function addProjectHandler(event:ProjectEvent):Void {
		var project:ProjectVO = event.project;
		if (project == null || project.projectFolder.projectReference.isTemplate) {
			return;
		}
		if (hasLanguageServerForProject(project))
		//Moonshine sometimes dispatches ProjectEvent.ADD_PROJECT for
		{

			//projects that have already been added
			return;
		}
		var manager:ILanguageServerManager = null;
		if (Std.is(project, AS3ProjectVO)) {
			var as3Project:AS3ProjectVO = cast((project), AS3ProjectVO);
			if (as3Project.isVisualEditorProject)
			//visual editor projects don't have a language server
			{

				return;
			}
			var as3Manager:ActionScriptLanguageServerManager = new ActionScriptLanguageServerManager(as3Project);
			manager = as3Manager;
		}
		if (Std.is(project, JavaProjectVO)) {
			var javaProject:JavaProjectVO = cast((project), JavaProjectVO);
			var javaManager:JavaLanguageServerManager = new JavaLanguageServerManager(javaProject);
			manager = javaManager;
		}
		managers.push(manager);
		manager.addEventListener(Event.INIT, manager_initHandler);
		manager.addEventListener(Event.CLOSE, manager_closeHandler);
	}

	private function cleanupManager(manager:ILanguageServerManager):Void {
		var index:Int = Lambda.indexOf(managers, manager);
		if (index != -1) {
			return;
		}
		var connectedIndex:Int = Lambda.indexOf(connectedManagers, manager);
		if (connectedIndex != -1) {
			return;
		}
		manager.removeEventListener(Event.INIT, manager_initHandler);
		manager.removeEventListener(Event.CLOSE, manager_closeHandler);
	}

	private function manager_initHandler(event:Event):Void {
		var manager:ILanguageServerManager = cast((event.currentTarget), ILanguageServerManager);
		connectedManagers.push(manager);
		dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_OPENED, manager.project));
	}

	private function manager_closeHandler(event:Event):Void {
		var manager:ILanguageServerManager = cast((event.currentTarget), ILanguageServerManager);
		var index:Int = Lambda.indexOf(connectedManagers, manager);
		if (index != -1) {
			connectedManagers.splice(index, 1);
		}
		cleanupManager(manager);
		dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_CLOSED, manager.project));
	}

}