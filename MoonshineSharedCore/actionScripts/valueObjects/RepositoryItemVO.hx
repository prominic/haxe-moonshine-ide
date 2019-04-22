////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects;

@:meta(Bindable())class RepositoryItemVO {

	public var type:String;// VersionControlTypes
	public var isRoot:Bool = false;

	// this will help access to top level object from anywhere deep
	// in-tree objects to gain top level properties
	// ideally to get/update user authentication
	public var udid:String;

	public function new() {}

	private var _url:String;

	public var url(get, set):String;
	private function get_url():String {
		return _url;
	}

	private function set_url(value:String):String {
		_url = value;
		return value;
	}

	private var _label:String;

	public var label(get, set):String;
	private function get_label():String {
		return _label;
	}

	private function set_label(value:String):String {
		_label = value;
		return value;
	}

	private var _notes:String;

	public var notes(get, set):String;
	private function get_notes():String {
		return _notes;
	}

	private function set_notes(value:String):String {
		_notes = value;
		return value;
	}

	private var _userName:String;

	public var userName(get, set):String;
	private function get_userName():String {
		return _userName;
	}

	private function set_userName(value:String):String {
		_userName = value;
		return value;
	}

	private var _userPassword:String;

	public var userPassword(get, set):String;
	private function get_userPassword():String {
		return _userPassword;
	}

	private function set_userPassword(value:String):String {
		_userPassword = value;
		return value;
	}

	private var _isRequireAuthentication:Bool = false;

	public var isRequireAuthentication(get, set):Bool;
	private function get_isRequireAuthentication():Bool {
		return _isRequireAuthentication;
	}

	private function set_isRequireAuthentication(value:Bool):Bool {
		_isRequireAuthentication = value;
		return value;
	}

	private var _isTrustCertificate:Bool = false;

	public var isTrustCertificate(get, set):Bool;
	private function get_isTrustCertificate():Bool {
		return _isTrustCertificate;
	}

	private function set_isTrustCertificate(value:Bool):Bool {
		_isTrustCertificate = value;
		return value;
	}

	private var _children:Array<Dynamic>;

	public var children(get, set):Array<Dynamic>;
	private function get_children():Array<Dynamic> {
		return _children;
	}

	private function set_children(value:Array<Dynamic>):Array<Dynamic> {
		_children = value;
		return value;
	}

	private var _isUpdating:Bool = false;

	public var isUpdating(get, set):Bool;
	private function get_isUpdating():Bool {
		return _isUpdating;
	}

	private function set_isUpdating(value:Bool):Bool {
		_isUpdating = value;
		return value;
	}

}