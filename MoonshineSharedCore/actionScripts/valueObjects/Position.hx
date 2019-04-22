package actionScripts.valueObjects;

/**
 * Implementation of Position interface from Language Server Protocol
 *
 * <p><strong>DO NOT</strong> add new properties or methods to this class
 * that are specific to Moonshine IDE or to a particular language. Create a
 * subclass for new properties or create a utility function for methods.</p>
 *
 * @see https://microsoft.github.io/language-server-protocol/specification#position
 */
class Position {

	public var line:Int = 0;

	/**
	 * Character offset on a line in a document (zero-based).
	 */
	public var character:Int = 0;

	public function new(line:Int = 0, character:Int = 0) {
		this.line = line;
		this.character = character;
	}

	public static function parse(original:Dynamic):Position {
		var vo:Position = new Position();
		vo.line = AS3.int(Reflect.field(original, 'line'));
		vo.character = AS3.int(Reflect.field(original, 'character'));
		return vo;
	}

}