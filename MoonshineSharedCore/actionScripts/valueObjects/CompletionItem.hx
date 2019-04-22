package actionScripts.valueObjects;

import flash.events.EventDispatcher;

/**
 * Implementation of CompletionItem interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
 */
class CompletionItem extends EventDispatcher {

	private static inline var FIELD_COMMAND:String = 'command';
	private static inline var FIELD_IS_INCOMPLETE:String = 'isIncomplete';
	private static inline var FIELD_ADDITIONAL_TEXT_EDITS:String = 'additionalTextEdits';
	private static inline var FIELD_LABEL:String = 'label';
	private static inline var FIELD_INSERT_TEXT:String = 'insertText';
	private static inline var FIELD_DOCUMENTATION:String = 'documentation';
	private static inline var FIELD_DETAIL:String = 'detail';
	private static inline var FIELD_DEPRECATED:String = 'deprecated';
	private static inline var FIELD_DATA:String = 'data';
	private static inline var FIELD_KIND:String = 'kind';

	private var _label:String;

	@:meta(Bindable(name = 'labelChange'))
	public var label(get, never):String;
	private function get_label():String {
		return this._label;
	}

	private var _sortLabel:String;

	//TODO: remove sortLabel because it does not exist in language server protocol
	public var sortLabel(get, never):String;
	private function get_sortLabel():String {
		return this._sortLabel;
	}

	private var _kind:Int = 0;

	@:meta(Bindable(name = 'kindChange'))
	public var kind(get, never):Int;
	private function get_kind():Int {
		return this._kind;
	}

	private var _detail:String;

	@:meta(Bindable(name = 'detailChange'))
	public var detail(get, never):String;
	private function get_detail():String {
		return this._detail;
	}

	private var _documentation:String;

	@:meta(Bindable(name = 'documentationChange'))
	public var documentation(get, never):String;
	private function get_documentation():String {
		return this._documentation;
	}

	private var _insertText:String = null;

	@:meta(Bindable(name = 'insertTextChange'))
	public var insertText(get, never):String;
	private function get_insertText():String {
		return this._insertText;
	}

	private var _command:Command;

	/**
	 * An optional command that is executed *after* inserting this completion. *Note* that
	 * additional modifications to the current document should be described with the
	 * additionalTextEdits-property.
	 */
	@:meta(Bindable(name = 'commandChange'))
	public var command(get, never):Command;
	private function get_command():Command {
		return this._command;
	}

	private var _data:Dynamic;

	private var _deprecated:Bool = false;

	@:meta(Bindable(name = 'deprecatedChange'))
	public var deprecated(get, never):Bool;
	private function get_deprecated():Bool {
		return this._deprecated;
	}

	private var _additionalTextEdits:Array<TextEdit>;

	public var additionalTextEdits(get, never):Array<TextEdit>;
	private function get_additionalTextEdits():Array<TextEdit> {
		return cast this._additionalTextEdits;
	}

	/**
	 * An data entry field that is preserved on a completion item between
	 * a completion and a completion resolve request.
	 */
	@:meta(Bindable(name = 'dataChange'))
	public var data(get, never):Dynamic;
	private function get_data():Dynamic {
		return this._data;
	}

	public function new(label:String = '', insertText:String = '',
			kind:Int = -1, detail:String = '',
			documentation:String = '', command:Command = null, data:Dynamic = null,
			deprecated:Bool = false, additionalTextEdits:Array<TextEdit> = null) {
		super();
		this._label = label;
		this._sortLabel = label.toLowerCase();
		this._insertText = insertText;
		this._kind = kind;
		this._detail = detail;
		this._documentation = documentation;
		this._command = command;
		this._data = data;
		this._deprecated = deprecated;
		this._additionalTextEdits = cast additionalTextEdits;
	}

	public static function resolve(item:CompletionItem, resolvedFields:Dynamic):CompletionItem {
		if (Reflect.hasField(resolvedFields, FIELD_LABEL)) {
			item._label = AS3.string(Reflect.field(resolvedFields, FIELD_LABEL));
			item._sortLabel = item.label.toLowerCase();
		}
		if (Reflect.hasField(resolvedFields, FIELD_INSERT_TEXT)) {
			item._insertText = AS3.string(Reflect.field(resolvedFields, FIELD_INSERT_TEXT));
		}
		if (Reflect.hasField(resolvedFields, FIELD_KIND)) {
			item._kind = AS3.int(Reflect.field(resolvedFields, FIELD_KIND));
		}
		if (Reflect.hasField(resolvedFields, FIELD_DETAIL)) {
			item._detail = AS3.string(Reflect.field(resolvedFields, FIELD_DETAIL));
		}
		if (Reflect.hasField(resolvedFields, FIELD_DOCUMENTATION)) {
			item._documentation = AS3.string(Reflect.field(resolvedFields, FIELD_DOCUMENTATION));
		}
		if (Reflect.hasField(resolvedFields, FIELD_DEPRECATED)) {
			item._deprecated = Reflect.field(resolvedFields, FIELD_DEPRECATED) != null;
		}
		if (Reflect.hasField(resolvedFields, FIELD_COMMAND)) {
			item._command = Command.parse(Reflect.field(resolvedFields, FIELD_COMMAND));
		}
		if (Reflect.hasField(resolvedFields, FIELD_IS_INCOMPLETE) && Reflect.field(resolvedFields, FIELD_IS_INCOMPLETE) != null) {
			trace('WARNING: Completion item is incomplete. Resolving a completion item is not supported yet. Item: ' + item.label);
		}
		if (Reflect.hasField(resolvedFields, FIELD_ADDITIONAL_TEXT_EDITS)) {
			var additionalTextEdits:Array<TextEdit> = [];
			var jsonTextEdits:Array<Dynamic> = cast AS3.asArray(Reflect.field(resolvedFields, FIELD_ADDITIONAL_TEXT_EDITS));
			var textEditCount:Int = jsonTextEdits.length;
			for (i in 0...textEditCount) {
				var jsonTextEdit:Dynamic = jsonTextEdits[i];
				additionalTextEdits[i] = TextEdit.parse(jsonTextEdit);
			}
			item._additionalTextEdits = cast additionalTextEdits;
		}

		if (Reflect.hasField(resolvedFields, FIELD_DATA)) {
			item._data = Reflect.field(resolvedFields, FIELD_DATA);
		}
		return item;
	}

	public static function parse(original:Dynamic):CompletionItem {
		var item:CompletionItem = new CompletionItem();
		return resolve(item, original);
	}

	public function toJSON(key:String):Dynamic {
		var result:Dynamic = {};
		Reflect.setField(result, 'label', this._label);
		Reflect.setField(result, 'kind', this._kind);
		Reflect.setField(result, 'deprecated', this._deprecated);
		if (this._detail != null) {
			Reflect.setField(result, 'detail', this._detail);
		}
		if (this._documentation != null) {
			Reflect.setField(result, 'documentation', this._documentation);
		}
		if (this._command != null) {
			Reflect.setField(result, 'command', this._command);
		}
		if (AS3.as(this._data, Bool)) {
			Reflect.setField(result, 'data', this._data);
		}
		if (this._additionalTextEdits != null) {
			var additionalTextEdits:Array<Dynamic> = [];
			var length:Int = this._additionalTextEdits.length;
			for (i in 0...length) {
				var textEdit:TextEdit = this._additionalTextEdits[i];
				additionalTextEdits[i] = textEdit;
			}
			Reflect.setField(result, 'additionalTextEdits', additionalTextEdits);
		}
		return result;
	}

}