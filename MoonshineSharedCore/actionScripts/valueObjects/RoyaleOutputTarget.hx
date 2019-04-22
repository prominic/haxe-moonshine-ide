////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects;

class RoyaleOutputTarget {

	private var _name:String;
	private var _version:String;
	private var _airVersion:String;
	private var _flashVersion:String;

	public function new(name:String, version:String,
			airVersion:String = null, flashVersion:String = null) {
		_name = name;
		_version = version;
		_airVersion = airVersion;
		_flashVersion = flashVersion;
	}

	public var name(get, never):String;
	private function get_name():String {
		return _name;
	}

	public var version(get, never):String;
	private function get_version():String {
		return _version;
	}

	public var airVersion(get, never):String;
	private function get_airVersion():String {
		return _airVersion;
	}

	public var flashVersion(get, never):String;
	private function get_flashVersion():String {
		return _flashVersion;
	}

}