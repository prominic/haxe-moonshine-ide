package actionScripts.utils;

import actionScripts.factory.FileLocation;

class GradleBuildUtil {

	public static function getProjectSourceDirectory(pomLocation:FileLocation):String {
		var fileContent:Dynamic = pomLocation.fileBridge.read();
		if (AS3.as(fileContent, Bool)) {
			var content:String = new as3hx.Compat.Regex('(\\r\\n)+|\\r+|\\n+|\\t+', 'g').replace(Std.string(fileContent), '');

			var taskRegExp:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('\\bsourceSets\\b', ''));
			var taskIndex:Int = AS3.int(as3hx.Compat.search(content, taskRegExp));
			content = content.substr(taskIndex, content.length);

			taskRegExp = new as3hx.Compat.Regex(new as3hx.Compat.Regex('\\bsrcDirs\\b', ''));
			taskIndex = AS3.int(as3hx.Compat.search(content, taskRegExp));
			content = content.substr(taskIndex, content.length);

			var firstIndex:Int = content.indexOf('[');
			var lastIndex:Int = content.lastIndexOf(']');
			content = content.substring(firstIndex + 1, lastIndex);

			firstIndex = content.indexOf('\'');
			lastIndex = content.lastIndexOf('\'');
			content = content.substring(firstIndex + 1, lastIndex);

			return content;
		}

		return '';
	}

}