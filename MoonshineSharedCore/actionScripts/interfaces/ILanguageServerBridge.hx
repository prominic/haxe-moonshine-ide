package actionScripts.interfaces;

import actionScripts.valueObjects.ProjectVO;
import actionScripts.ui.editor.BasicTextEditor;

interface ILanguageServerBridge {

	var connectedProjectCount(get, never):Int;

	function hasLanguageServerForProject(project:ProjectVO):Bool;

	function hasCustomTextEditorForUri(uri:String, project:ProjectVO):Bool;

	function getCustomTextEditorForUri(scheme:String, project:ProjectVO, readOnly:Bool = false):BasicTextEditor;

}