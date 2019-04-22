package org.as3commons.asblocks.impl;

class ASQName {

	//----------------------------------
	//  packageName
	//----------------------------------

	/**
	 * @private
	 */
	private var _packageName:String;

	/**
	 * doc
	 */
	public var packageName(get, set):String;
	private function get_packageName():String {
		return _packageName;
	}

	/**
	 * @private
	 */
	private function set_packageName(value:String):String {
		_packageName = value;
		return value;
	}

	//----------------------------------
	//  localName
	//----------------------------------

	/**
	 * @private
	 */
	private var _localName:String;

	/**
	 * doc
	 */
	public var localName(get, set):String;
	private function get_localName():String {
		return _localName;
	}

	/**
	 * @private
	 */
	private function set_localName(value:String):String {
		_localName = value;
		return value;
	}

	//----------------------------------
	//  qualifiedName
	//----------------------------------

	/**
	 * doc
	 */
	public var qualifiedName(get, never):String;
	private function get_qualifiedName():String {
		if (isQualified) {
			return packageName + '.' + localName;
		}
		return localName;
	}

	//----------------------------------
	//  isQualified
	//----------------------------------

	/**
	 * doc
	 */
	public var isQualified(get, never):Bool;
	private function get_isQualified():Bool {
		return packageName != null;
	}

	public function new(qualifiedName:String = null) {
		if (qualifiedName == null) {
			return;
		}

		var pos:Int = qualifiedName.lastIndexOf('.');
		if (pos != -1) {
			_packageName = qualifiedName.substring(0, pos);
			_localName = qualifiedName.substring(pos + 1);
		} else {
			_localName = qualifiedName;
		}
	}

	//----------------------------------
	//  filePath
	//----------------------------------

	/**
	 * @private
	 */
	private var _filePath:String;

	/**
	 * doc
	 */
	public var filePath(get, set):String;
	private function get_filePath():String {
		return _filePath;
	}

	/**
	 * @private
	 */
	private function set_filePath(value:String):String {
		_filePath = value;
		return value;
	}

	public function define(localName:String, packageName:String):Void {
		_localName = localName;
		_packageName = packageName;
	}

	public function equals(obj:Dynamic):Bool {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		//if (getClass() != obj.getClass())
		//	return false;
		var other:ASQName = ASQName(obj);

		if (localName == null) {
			if (other.localName != null) {
				return false;
			}
		} else if (!localName == other.localName) {
			return false;
		}

		if (packageName == null) {
			if (other.packageName != null) {
				return false;
			}
		} else if (!packageName == other.packageName) {
			return false;
		}

		return true;
	}

	public function toString():String {
		return qualifiedName;
	}

}