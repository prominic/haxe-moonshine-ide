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
package actionScripts.ui.parser.context;

import flash.events.EventDispatcher;
import actionScripts.ui.parser.ILineParser;

class ContextSwitchParser extends EventDispatcher implements ILineParser {

	private var context:Int = 0;
	public var switchManager:ContextSwitchManager;
	public var parserManager:InlineParserManager;

	private var defaultContext:Int = 0;

	public function new() {
		super();
	}

	public function setContext(newContext:Int):Void {
		context = newContext;
	}

	public function parse(sourceCode:String):Array<Int> {
		var result:Array<Int> = new Array<Int>();
		var tail:String = sourceCode;
		var pos:Int = 0;
		var curContext:Int;
		var curParser:InlineParser;

		if (switchManager != null) {
			while (tail.length != 0) {
				var firstMatch:Dynamic = null;

				// Skip whitespace, no point in coloring it
				var whiteSpace:Dynamic = new as3hx.Compat.Regex('^\\s+', '').exec(tail);
				if (AS3.as(whiteSpace, Bool)) {
					var whiteSpaceLen:Int = AS3.int(Reflect.field(whiteSpace, Std.string(0)).length);

					if (whiteSpaceLen == tail.length) {
						break;
					}

					pos += whiteSpaceLen;
					tail = sourceCode.substr(pos);
				}

				// Get current context, transposing to inline parser mask if available
				curContext = (context != 0 || defaultContext != 0) ? 1 : 0;
				if (parserManager != null) {
					curParser = parserManager.getParser(curContext);
					if (curParser != null) {
						curContext = curParser.contextMask;
					}
				}

				// Get switches for current context
				var curSwitches:Array<ContextSwitch> = cast switchManager.getSwitches(curContext);

				// Search for the first matching switch
				if (curSwitches != null) {
					for (swtch in curSwitches) {
						if (swtch.pattern != null) {
							var match:Dynamic = swtch.pattern.exec(tail);

							if (AS3.as(match, Bool)) {
								if (!AS3.as(firstMatch, Bool) || Reflect.field(match, 'index') < Reflect.field(firstMatch, 'index')) {
									firstMatch = {
												'swtch': swtch,
												'index': Reflect.field(match, 'index'),
												'length': Reflect.field(match, Std.string(0)).length
											};
								}
							}
						} else {
							firstMatch = {
										'swtch': swtch,
										'index': 0,
										'length': 0
									};
						}

						// Break early if matched at 0 (no point to keep processing, this is the earliest possible match)
						if (AS3.as(firstMatch, Bool) && Reflect.field(firstMatch, 'index') == 0) {
							break;
						}
					}
				}

				// Apply the context switch, if one is found
				if (AS3.as(firstMatch, Bool)) {
					var firstSwitch:ContextSwitch = Reflect.field(firstMatch, 'swtch');
					var matchPos:Int = AS3.int(Reflect.field(firstMatch, 'index'));
					var matchLen:Int = AS3.int(firstMatch.length);
					var contextPos:Int = pos + matchPos + ((firstSwitch.post) ? matchLen : 0);

					if (result.length == 0 && contextPos > 0) {
						result.push(0);
						result.push(context || defaultContext);

					}
					context = firstSwitch.to;
					// Avoid redundant context switches
					if (result.length > 0 && result[result.length - 1] != context) {
						if (result[result.length - 2] == contextPos) {
							result[result.length - 1] = context;
						} else {
							result.push(contextPos);
							result.push(context);

						}
					}

					pos += AS3.int(matchPos + matchLen);
					tail = sourceCode.substr(pos);
				} else {
					break;
				}
			}
		}

		if (result.length == 0) {
			result.push(0);
			result.push(context || defaultContext);

		}

		// Process inline contexts through inline parsers
		if (parserManager != null) {
			var i:Int = result.length - 1;while (i > 0) {
				curContext = result[i];
				curParser = parserManager.getParser(curContext);

				if (curParser != null) {
					var inlinePos:Int = result[i - 1];
					var inlineResult:Array<Int>;
					var inlineMask:Int = curParser.contextMask;
					var inlineCutoff:Int = (i < result.length - 1) ? result[i + 1] : -1;

					tail = sourceCode.substring(inlinePos, inlineCutoff) + '\n';

					curParser.parser.setContext(curContext & AS3.int(~inlineMask));
					inlineResult = curParser.parser.parse(tail);

					// Remove old results
					result.splice(i - 1, 2);
					// Inject AS parser results, applying offsets and mask
					var n:Int = 0;

					while (n < inlineResult.length) {
						pos = AS3.int(inlineResult[n] + inlinePos);

						if (inlineCutoff < 0 || pos < inlineCutoff) {
							as3hx.Compat.arraySplice(result, i - 1 + n, 0, [pos, inlineResult[n + 1] | inlineMask]);
						}
						n += 2;
					}

					context = result[result.length - 1];
				}
				i -= 2;
			}
		}

		return result;
	}

}