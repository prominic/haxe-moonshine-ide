package actionScripts.utils;

import actionScripts.valueObjects.Range;
class LSPUtil {

	public static function rangesIntersect(r1:Range, r2:Range):Bool {
		var resultStartLine:Int = r1.start.line;
		var resultStartChar:Int = r1.start.character;
		var resultEndLine:Int = r1.end.line;
		var resultEndChar:Int = r1.end.character;
		var otherStartLine:Int = r2.start.line;
		var otherStartChar:Int = r2.start.character;
		var otherEndLine:Int = r2.end.line;
		var otherEndChar:Int = r2.end.character;
		if (resultStartLine < otherStartLine) {
			resultStartLine = otherStartLine;
			resultStartChar = otherStartChar;
		} else if (resultStartLine == otherStartLine && resultStartChar < otherStartChar) {
			resultStartChar = otherStartChar;
		}
		if (resultEndLine > otherEndLine) {
			resultEndLine = otherEndLine;
			resultEndChar = otherEndChar;
		} else if (resultEndLine == otherEndLine && resultEndChar < otherEndChar) {
			resultEndChar = otherEndChar;
		}
		if (resultStartLine > resultEndLine) {
			return false;
		}
		if (resultStartLine == resultEndLine && resultStartChar > resultEndChar) {
			return false;
		}
		return true;
	}

	public function new() {}

}