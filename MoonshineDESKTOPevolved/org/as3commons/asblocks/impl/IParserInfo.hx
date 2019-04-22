package org.as3commons.asblocks.impl;

import flash.events.IEventDispatcher;
import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.parser.api.ISourceCode;

interface IParserInfo extends IEventDispatcher {

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  sourceCode
	//----------------------------------

	/**
	 * The source code.
	 */
	var sourceCode(get, never):ISourceCode;

	//----------------------------------
	//  entry
	//----------------------------------

	/**
	 * The class path entry (base path).
	 */
	var entry(get, never):IClassPathEntry;

	//----------------------------------
	//  unit
	//----------------------------------

	/**
	 * The parsed compilation unit.
	 */
	var unit(get, never):ICompilationUnit;

	/**
	 * @private
	 */
	var error(get, set):ASBlocksSyntaxError;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Parses the sourceCode with the appropriate parser.
	 */
	function parse():ICompilationUnit;

}