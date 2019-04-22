/*
	See COPYRIGHT.txt in this directory for full copyright text.

	Pretty resumable parser
	Inspired by Google Code Prettify
	Which was ported by Anirudh Sasikumar to AS3

   	Modified and simplified to be able to handle on-the-fly changes,
	by parsing one line at a time, which can be spread out over multiple frames
	as to emulate threading in a Flash runtime.

	You need to populate wordBoundaries, patterns, endPatterns & keywords.
	See AS3LineParser for an example
*/

package actionScripts.ui.parser;

import flash.events.EventDispatcher;

class LineParser extends EventDispatcher implements ILineParser {

	private var wordBoundaries:as3hx.Compat.Regex;

	private var patterns:Array<Dynamic>;
	private var endPatterns:Array<Dynamic>;
	private var keywords:Array<Dynamic>;

	// Generated based on keywords array
	private var keywordSet:Dynamic = {};

	// Will start assuming this context
	private var context:Int = 0x1;
	// If nothing is found this context is set
	private var defaultContext:Int = 0x1;
	private var result:Array<Int>;

	public function new() {
		super();
		var keywordsCount:Int = keywords.length;
		for (i in 0...keywordsCount) {
			var keyword:Array<Dynamic> = keywords[i];
			var keywordOneCount:Int = AS3.int(keyword[1].length);
			for (j in 0...keywordOneCount) {
				Reflect.setField(keywordSet, Std.string(Reflect.field(keyword[1], Std.string(j))), keyword[0]);
			}
		}
	}

	public function setContext(newContext:Int):Void {
		context = newContext;
	}

	public function parse(sourceCode:String):Array<Int> {
		result = new Array<Int>();

		for (i in 0...endPatterns.length) {
			if (Reflect.field(endPatterns[i], Std.string(0)) == context) {
				result.push(0);
				result.push(context);

				findContextEnd(sourceCode, Reflect.field(endPatterns[i], Std.string(1)));

				break;
			}
		}

		if (result.length == 0) {
			splitOnContext(Std.string(sourceCode));
		}

		context = result[result.length - 1];

		return result;
	}

	private function findContextEnd(source:String, endPattern:as3hx.Compat.Regex):Void {
		var endMatch:Dynamic = endPattern.exec(source);

		if (AS3.as(endMatch, Bool)) {
			var matchLen:Int = AS3.int(Reflect.field(endMatch, Std.string(0)).length);

			splitOnContext(source.substring(AS3.int(Reflect.field(endMatch, 'index') + matchLen)), AS3.int(Reflect.field(endMatch, 'index') + matchLen));
		}
	}

	/*
		Takes string of source code, assigns styles to this.result.
		Dives instantly when pattern is found, unlike Prettify,
		which nests decoration/result array & then runs over it again.
	*/
	private function splitOnContext(tail:String, pos:Int = 0):Void {
		var style:Int = 0;

		var lastStyle:Int = 0;
		var head:String = '';

		// NOTE: for longer strings this could be a for loop & could break & be returned to,
		// as to make the parsing fully psuedo-threaded.
		while (tail.length != 0) {
			var match:Array<Dynamic>;
			var token:Int = 0;

			for (i in 0...patterns.length) {
				match = as3hx.Compat.match(tail, Reflect.field(patterns[i], Std.string(1)));
				if (match != null) {
					token = AS3.int(match[0].length);
					lastStyle = style;
					style = AS3.int(Reflect.field(patterns[i], Std.string(0)));
					break;
				}
			}
			if (token == 0) {
				token = 1;
				head += Std.string(tail.charAt(0));
				lastStyle = style;
				style = defaultContext;
			} else if (style != lastStyle && lastStyle == defaultContext) {
				// Decorations are set to this.result instantly by this function
				splitOnKeywords(head, pos - head.length);
				head = '';
			}

			if (style != lastStyle && head.length == 0) {
				result.push(pos);
				result.push(style);

			}

			pos += token;
			tail = tail.substring(token);
		}

		// If head exists it means last matched token was unknown (defaultContext),
		// so we see if it contains keywords.
		if (head.length != 0) {
			splitOnKeywords(head, pos - head.length);
		}
	}

	private function splitOnKeywords(source:String, pos:Int):Void {
		var keywordsBoundary:Array<String> = source.split(Std.string(wordBoundaries));
		var keywordsBoundaryCount:Int = keywordsBoundary.length;
		var currentKeyword:String;
		var style:Int;
		var lastStyle:Int;
		for (i in 0...keywordsBoundaryCount) {
			currentKeyword = keywordsBoundary[i];
			lastStyle = style;
			if (Reflect.hasField(keywordSet, currentKeyword)) {
				style = AS3.int(Reflect.field(keywordSet, currentKeyword));
			} else if (!AS3.as(new as3hx.Compat.Regex('^\\s+$', '').test(currentKeyword), Bool)) {
				// Avoid switching styles for whitespace
				style = defaultContext;
			}

			if (style != lastStyle) {
				result.push(pos);
				result.push(style);

			}
			pos += currentKeyword.length;
		}
	}

}