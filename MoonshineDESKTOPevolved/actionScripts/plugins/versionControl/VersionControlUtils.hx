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
package actionScripts.plugins.versionControl;

import flash.filesystem.File;
import mx.collections.ArrayCollection;
import actionScripts.utils.FileUtils;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.valueObjects.RepositoryItemVO;
import actionScripts.valueObjects.VersionControlTypes;

class VersionControlUtils {

	private static var _REPOSITORIES:ArrayCollection;

	public static var REPOSITORIES(get, never):ArrayCollection;
	private static function get_REPOSITORIES():ArrayCollection {
		if (_REPOSITORIES == null) {
			_REPOSITORIES = SharedObjectUtil.getRepositoriesFromSO();
		}
		return _REPOSITORIES;
	}

	public static function getRepositoryItemByUdid(value:String):RepositoryItemVO {
		for (item in REPOSITORIES) {
			if (Reflect.field(item, 'udid') == value) {
				return item;
			}
		}

		return null;
	}

	public static function hasAuthenticationFailError(value:String):Bool {
		var match:Array<Dynamic> = as3hx.Compat.match(value.toLowerCase(), new as3hx.Compat.Regex('authentication failed', ''));
		if (match == null) {
			match = as3hx.Compat.match(value.toLowerCase(), new as3hx.Compat.Regex('authorization failed', ''));
		}

		return (match != null);
	}

	public static function parseGitDependencies(ofRepository:RepositoryItemVO, fromPath:File):Bool {
		fromPath = fromPath.resolvePath('dependencies.xml');
		if (AS3.as(fromPath.exists, Bool)) {
			var readObject:Dynamic = FileUtils.readFromFile(fromPath);
			var dependencies:FastXML = new FastXML(readObject);
			var tmpRepo:RepositoryItemVO;
			for (repo in as3hx.Compat.each(dependencies.descendants('dependency'))) {
				// put this inside so we initialize only
				// if the correct xml format found
				if (!AS3.as(ofRepository.children, Bool)) {
					ofRepository.children = [];
				}

				tmpRepo = new RepositoryItemVO();
				tmpRepo.label = Std.string(Reflect.field(repo, 'label'));
				tmpRepo.url = Std.string(Reflect.field(repo, 'url'));
				tmpRepo.notes = Std.string(Reflect.field(repo, 'purpose'));
				tmpRepo.isRequireAuthentication = ofRepository.isRequireAuthentication;
				tmpRepo.isTrustCertificate = ofRepository.isTrustCertificate;
				tmpRepo.udid = ofRepository.udid;
				tmpRepo.type = VersionControlTypes.GIT;
				ofRepository.children.push(tmpRepo);
			}

			SharedObjectUtil.saveRepositoriesToSO(REPOSITORIES);
			return true;
		}

		return false;
	}

}