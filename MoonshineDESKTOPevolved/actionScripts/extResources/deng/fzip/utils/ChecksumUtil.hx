package actionScripts.extResources.deng.fzip.utils;

import flash.utils.ByteArray;

class ChecksumUtil {

	/**
	 * @private
	 */
	private static var crcTable:Array<Dynamic> = makeCRCTable();

	/**
	 * @private
	 */
	private static function makeCRCTable():Array<Dynamic> {
		var table:Array<Dynamic> = [];
		var i:Int;
		var j:Int;
		var c:Int;
		for (i in 0...256) {
			c = i;
			for (j in 0...8) {
				if ((c & 1) != 0) {
					c = 0xEDB88320 ^ AS3.int(c >>> 1);
				} else {
					c >>>= 1;
				}
			}
			table.push(c);
		}
		return table;
	}

	/**
	 * Calculates a CRC-32 checksum over a ByteArray
	 *
	 * @see http://www.w3.org/TR/PNG/#D-CRCAppendix
	 *
	 * @param data
	 * @param len
	 * @param start
	 * @return CRC-32 checksum
	 */
	public static function CRC32(data:ByteArray, start:Int = 0, len:Int = 0):Int {
		if (start >= data.length) {
			start = data.length;
		}
		if (len == 0) {
			len = AS3.int(data.length - start);
		}
		if (len + start > data.length) {
			len = AS3.int(data.length - start);
		}
		var i:Int;
		var c:Int = 0xffffffff;
		for (i in start...len) {
			c = AS3.int(crcTable[AS3.int(c ^ Reflect.getProperty(data, Std.string(i))) & 0xff]) ^ AS3.int(c >>> 8);
		}
		return AS3.int(c ^ 0xffffffff);
	}

	/**
	 * Calculates an Adler-32 checksum over a ByteArray
	 *
	 * @see http://en.wikipedia.org/wiki/Adler-32#Example_implementation
	 *
	 * @param data
	 * @param len
	 * @param start
	 * @return Adler-32 checksum
	 */
	public static function Adler32(data:ByteArray, start:Int = 0, len:Int = 0):Int {
		if (start >= data.length) {
			start = data.length;
		}
		if (len == 0) {
			len = AS3.int(data.length - start);
		}
		if (len + start > data.length) {
			len = AS3.int(data.length - start);
		}
		var i:Int = start;
		var a:Int = 1;
		var b:Int = 0;
		while (i < (start + len)) {
			a = AS3.int((a + Reflect.getProperty(data, Std.string(i))) % 65521);
			b = AS3.int((a + b) % 65521);
			i++;
		}
		return AS3.int((b << 16) | a);
	}

}