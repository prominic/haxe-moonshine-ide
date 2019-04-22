package org.as3commons.asblocks.impl;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.IASParser;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IParserInfo;
import org.as3commons.asblocks.parser.api.ISourceCode;

@:meta(Event(name = 'complete', type = 'flash.events.Event'))
@:meta(Event(name = 'error', type = 'flash.events.Event'))
/**
 * Implementation of the <code>IParserInfo</code> for .as files.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ParserInfo extends EventDispatcher implements IParserInfo {

	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var parser:Dynamic;

	//--------------------------------------------------------------------------
	//
	//  IParserInfo API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  sourceCode
	//----------------------------------

	/**
	 * @private
	 */
	private var _sourceCode:ISourceCode;

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#sourceCode
	 */
	public var sourceCode(get, never):ISourceCode;
	private function get_sourceCode():ISourceCode {
		return _sourceCode;
	}

	//----------------------------------
	//  entry
	//----------------------------------

	/**
	 * @private
	 */
	private var _entry:IClassPathEntry;

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#entry
	 */
	public var entry(get, never):IClassPathEntry;
	private function get_entry():IClassPathEntry {
		return _entry;
	}

	//----------------------------------
	//  unit
	//----------------------------------

	/**
	 * @private
	 */
	private var _unit:ICompilationUnit;

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#unit
	 */
	public var unit(get, never):ICompilationUnit;
	private function get_unit():ICompilationUnit {
		return _unit;
	}

	//----------------------------------
	//  error
	//----------------------------------

	/**
	 * @private
	 */
	private var _error:ASBlocksSyntaxError;

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#error
	 */
	public var error(get, set):ASBlocksSyntaxError;
	private function get_error():ASBlocksSyntaxError {
		return _error;
	}

	/**
	 * @private
	 */
	private function set_error(value:ASBlocksSyntaxError):ASBlocksSyntaxError {
		_error = value;
		return value;
	}

	//----------------------------------
	//  parseBlocks
	//----------------------------------

	/**
	 * @private
	 */
	private var _parseBlocks:Bool = false;

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#parseBlocks
	 */
	public var parseBlocks(get, set):Bool;
	private function get_parseBlocks():Bool {
		return _parseBlocks;
	}

	/**
	 * @private
	 */
	private function set_parseBlocks(value:Bool):Bool {
		_parseBlocks = value;
		return value;
	}

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
			entry:IClassPathEntry,
			parseBlocks:Bool) {
		super();

		this.parser = parser;
		_sourceCode = sourceCode;
		_entry = entry;
		this.parseBlocks = parseBlocks;
	}

	//--------------------------------------------------------------------------
	//
	//  IParserInfo API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.api.IParserInfo#parse()
	 */
	public function parse():Void {
		var asparser:IASParser = IASParser(parser);

		try {
			_unit = asparser.parse(sourceCode, parseBlocks);
		} catch (e:ASBlocksSyntaxError) {
			error = e;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			return;
		}

		dispatchEvent(new Event(Event.COMPLETE));
	}

}