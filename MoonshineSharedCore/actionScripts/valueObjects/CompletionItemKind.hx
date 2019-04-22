package actionScripts.valueObjects;

/**
 * Implementation of CompletionItemKind enum from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new values to this class that are specific
 * to Moonshine IDE or to a particular language.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
 * @see https://microsoft.github.io/language-server-protocol/specification#completionItem_resolve
 */
class CompletionItemKind {

	public static inline var TEXT:Int = 1;
	public static inline var METHOD:Int = 2;
	public static inline var FUNCTION:Int = 3;
	public static inline var CONSTRUCTOR:Int = 4;
	public static inline var FIELD:Int = 5;
	public static inline var VARIABLE:Int = 6;
	public static inline var CLASS:Int = 7;
	public static inline var INTERFACE:Int = 8;
	public static inline var MODULE:Int = 9;
	public static inline var PROPERTY:Int = 10;
	public static inline var UNIT:Int = 11;
	public static inline var VALUE:Int = 12;
	public static inline var ENUM:Int = 13;
	public static inline var KEYWORD:Int = 14;
	public static inline var SNIPPET:Int = 15;
	public static inline var COLOR:Int = 16;
	public static inline var FILE:Int = 17;
	public static inline var REFERENCE:Int = 18;
	public static inline var FOLDER:Int = 19;
	public static inline var ENUM_MEMBER:Int = 20;
	public static inline var CONSTANT:Int = 21;
	public static inline var STRUCT:Int = 22;
	public static inline var EVENT:Int = 23;
	public static inline var OPERATOR:Int = 24;
	public static inline var TYPE_PARAMETER:Int = 25;

}