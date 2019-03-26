////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.mxmlblocks.impl;

import flash.events.ErrorEvent;
import flash.events.Event;
import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.impl.ParserInfo;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.mxmlblocks.IMXMLParser;

/**
 * Implementation of the <code>IParserInfo</code> for .mxml files.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class MXMLParserInfo extends ParserInfo {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function new(parser:Dynamic,
			sourceCode:ISourceCode,
			entry:IClassPathEntry) {
		super(parser, sourceCode, entry, false);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override public function parse():Void {
		var mxmlparser:IMXMLParser = cast((parser), IMXMLParser);

		try {
			_unit = mxmlparser.parse(sourceCode, entry);
		} catch (e:ASBlocksSyntaxError) {
			error = e;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			return;
		}

		dispatchEvent(new Event(Event.COMPLETE));
	}

}