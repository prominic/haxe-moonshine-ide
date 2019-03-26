package actionScripts.languageServer;

import actionScripts.valueObjects.ProjectVO;
import flash.events.IEventDispatcher;
import actionScripts.ui.editor.BasicTextEditor;

/**
 * Dispatched when the language server is active.
 *
 * @see #active
 */
@:meta(Event(name = 'init', type = 'flash.events.Event'))

/**
 * Dispatched when the language server is no longer active.
 *
 * @see #active
 */
@:meta(Event(name = 'close', type = 'flash.events.Event'))
interface ILanguageServerManager extends IEventDispatcher {

	/**
	 * Indicates if the language server is active. If active, it will need
	 * to be closed before Moonshine can exit.
	 *
	 * @see #event:init
	 * @see #event:close
	 */
	var active(get, never):Bool;

	/**
	 * The project associated with this language server.
	 */
	var project(get, never):ProjectVO;

	/**
	 * The URI schemes associated with this language server.
	 */
	var uriSchemes(get, never):Array<String>;

	/**
	 * The file extensions associated with this language server.
	 */
	var fileExtensions(get, never):Array<String>;

	/**
	 * Creates a text editor for the specified URI.
	 */
	function createTextEditorForUri(uri:String, readOnly:Bool = false):BasicTextEditor;

}