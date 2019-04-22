package actionScripts.utils;

class SerializeUtil {

	/**
	 * Serializes a Boolean value into True or False strings.
	 */
	public static function serializeBoolean(b:Bool):String {
		return (b) ? 'True' : 'False';
	}

	/**
	 * Serialize a String value so it's empty when null
	 */
	public static function serializeString(str:String):String {
		return (str != null) ? str : '';
	}

	/**
	 * Serialize key-value pairs to FD-like XML elements using a template element
	 *  Example:
	 *		<option accessible="True" />
	 *		<option allowSourcePathOverlap="True" />
	 *		<option benchmark="True" />
	 *		<option es="True" />
	 *		<option locale="" />
	 */
	public static function serializePairs(pairs:Dynamic, template:FastXML):FastXMLList {
		var list:FastXML = FastXML.parse('<xml/>');
		for (key in Reflect.fields(pairs)) {
			var node:FastXML = template.copy();
			node.setAttribute("key", Reflect.setField(pairs, key, ));
			list.node.appendChild(node);
		}
		return list.node.children();
	}

	public static function serializeObjectPairs(pairs:Dynamic, template:FastXML):FastXMLList {
		var list:FastXML = FastXML.parse('<xml/>');

		var node:FastXML = template.copy();
		var hasProperties:Bool = false;

		for (key in Reflect.fields(pairs)) {
			node.setAttribute("key", Reflect.setField(pairs, key, ));
			hasProperties = true;
		}

		if (hasProperties) {
			list.node.appendChild(node);
		}

		return list.node.children();
	}

	/**
	 * Deserializes True and False strings to true and false Boolean values.
	 */
	public static function deserializeBoolean(o:Dynamic):Bool {
		var str:String = Std.string(Std.string(o));
		return str.toLowerCase() == 'true';
	}

	/**
	 * Deserialize a String value so it's null when empty
	 */
	public static function deserializeString(o:Dynamic):String {
		var str:String = Std.string(Std.string(o));
		if (str.length == 0) {
			return null;
		}
		if (str == 'null') {
			return null;
		}
		return str;
	}

}