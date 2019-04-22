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
package no.doomsday.console.core.introspection;

import flash.errors.Error;
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * Parse the ProductInfo tag from the root object's SWF.
 *
 * c.f. http://wahlers.com.br/claus/blog/undocumented-swf-tags-written-by-mxmlc/
 *
 */
class ProductInfo {

	private var _root:DisplayObject;
	private var _isParsed:Bool = false;
	private var _tagData:ByteArray;

	public var root(get, set):DisplayObject;
	private function set_root(value:DisplayObject):DisplayObject {
		if (_root != null) {
			_isParsed = false;
			_tagData = null;
		}
		_root = value;
		parseBytes();
		return value;
	}

	private function get_root():DisplayObject {
		return _root;
	}

	public var available(get, never):Bool;
	private function get_available():Bool {
		return _isParsed && _tagData != null;
	}

	public var productID(get, never):Int;
	private function get_productID():Int {
		if (!available) {
			return AS3.int(Math.NaN);
		}
		_tagData.position = 0;
		return _tagData.readUnsignedInt();
	}

	public var edition(get, never):Int;
	private function get_edition():Int {
		if (!available) {
			return AS3.int(Math.NaN);
		}
		_tagData.position = 4;
		return _tagData.readUnsignedInt();
	}

	public var sdkVersion(get, never):String;
	private function get_sdkVersion():String {
		if (!available) {
			return '';
		}
		_tagData.position = 8;
		var major:Int;
		var minor:Int;
		var build:Float;
		major = _tagData.readUnsignedByte();
		minor = _tagData.readUnsignedByte();
		build = _tagData.readUnsignedInt() +
						_tagData.readUnsignedInt() * (as3hx.Compat.INT_MAX + 1);
		return major + '.' + minor + '.0.' + build;
	}

	public var compilationDate(get, never):Date;
	private function get_compilationDate():Date {
		if (!available) {
			return null;
		}
		var date:Date = Date.now();
		_tagData.position = 18;
		date.getTime() = _tagData.readUnsignedInt() +
						_tagData.readUnsignedInt() * (as3hx.Compat.INT_MAX + 1);
		return date;
	}

	public function new(root:DisplayObject) {
		_root = root;
		parseBytes();
	}

	private function parseBytes():Void {
		var loaderInfo:LoaderInfo;
		var bytes:ByteArray;
		var ub:Int = 5;
		var sb:Int;
		var frameRectSize:Int;
		var packedTag:Int;
		var code:Int;
		var len:Int;

		_isParsed = true;

		try {
			loaderInfo = _root.loaderInfo;
			bytes = loaderInfo.bytes;
		} catch (e:Error) {
			return;
		}

		bytes.endian = Endian.LITTLE_ENDIAN;

		// Skip the header
		bytes.position = 8;

		// Read the size of and skip the frame rectangle
		sb = bytes.readUnsignedByte() >> AS3.int(8 - ub);
		frameRectSize = Math.ceil((ub + (sb * 4)) / 8);
		bytes.position += AS3.int(frameRectSize - 1);

		// Skip the frame rate and frame count
		bytes.position += 4;

		// Search for the productInfo tag
		while (bytes.bytesAvailable != 0) {
			packedTag = bytes.readUnsignedShort();
			code = packedTag >> 6;
			len = packedTag & 0x3f;
			if (len == 0x3f) {
				len = bytes.readInt();
			}
			if (code == 0x29) {
				// ProductInfo tag
				_tagData = as3hx.Compat.newByteArray();
				_tagData.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(_tagData, 0, len);
				_isParsed = true;
				return;
			}
			bytes.position += len;
		}

		// SWFs without productInfo tags will reach here without
		// having set the _tagData property.  This is okay.
	}

}