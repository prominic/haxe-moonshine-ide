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

package org.as3commons.asblocks.impl;

import flash.events.EventDispatcher;
import org.as3commons.asblocks.ASFactory;
import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.utils.FileUtil;

/**
 * The default implementation of the <code>IASProject</code> API.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
class ASProject extends EventDispatcher implements IASProject {

	public var factory(get, never):ASFactory;
	public var compilationUnits(get, never):Array<ICompilationUnit>;
	public var classPathEntries(get, never):Array<IClassPathEntry>;
	public var resourceRoots(get, never):Array<IResourceRoot>;
	public var outputLocation(get, set):String;
	public var sourceCodeList(get, never):Array<Dynamic>;

	//--------------------------------------------------------------------------
	//
	//  IASProject API :: Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  factory
	//----------------------------------

	/**
	 * @private
	 */
	private var _factory:ASFactory;

	/**
	 * @copy org.as3commons.asblocks.IASProject#factory
	 */
	private function get_factory():ASFactory {
		return _factory;
	}

	//----------------------------------
	//  compilationUnits
	//----------------------------------

	/**
	 * @private
	 */
	private var _compilationUnits:Array<ICompilationUnit> = new Array<ICompilationUnit>();

	/**
	 * @copy org.as3commons.asblocks.IASProject#compilationUnits
	 */
	private function get_compilationUnits():Array<ICompilationUnit> {
		var result:Array<ICompilationUnit> = new Array<ICompilationUnit>();
		var len:Int = _compilationUnits.length;
		for (i in 0...len) {
			result.push(_compilationUnits[i]);
		}
		return result;
	}

	//----------------------------------
	//  classPathEntries
	//----------------------------------

	/**
	 * @private
	 */
	private var _classPathEntries:Array<IClassPathEntry> = new Array<IClassPathEntry>();

	/**
	 * @copy org.as3commons.asblocks.IASProject#classPathEntries
	 */
	private function get_classPathEntries():Array<IClassPathEntry> {
		var result:Array<IClassPathEntry> = new Array<IClassPathEntry>();
		var len:Int = _classPathEntries.length;
		for (i in 0...len) {
			result.push(_classPathEntries[i]);
		}
		return result;
	}

	//----------------------------------
	//  resourceRoots
	//----------------------------------

	/**
	 * @private
	 */
	private var _resourceRoots:Array<IResourceRoot> = new Array<IResourceRoot>();

	/**
	 * @copy org.as3commons.asblocks.IASProject#resourceRoots
	 */
	private function get_resourceRoots():Array<IResourceRoot> {
		var result:Array<IResourceRoot> = new Array<IResourceRoot>();
		var len:Int = _resourceRoots.length;
		for (i in 0...len) {
			result.push(_resourceRoots[i]);
		}
		return result;
	}

	//----------------------------------
	//  outputLocation
	//----------------------------------

	/**
	 * @private
	 */
	private var _outputLocation:String;

	/**
	 * @copy org.as3commons.asblocks.IASProject#outputLocation
	 */
	private function get_outputLocation():String {
		return _outputLocation;
	}

	/**
	 * @private
	 */
	private function set_outputLocation(value:String):String {
		_outputLocation = value;
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor, creates a new project with the associated factory.
	 *
	 * @param factory The <code>ASFactory</code> implementation used with the
	 * project. This instance will be used when creating types.
	 */
	public function new(factory:ASFactory) {
		super();
		_factory = factory;
	}

	//--------------------------------------------------------------------------
	//
	//  IASProject API :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @copy org.as3commons.asblocks.IASProject#addCompilationUnit()
	 *
	 * @see #compilationUnitAdded()
	 */
	public function addCompilationUnit(unit:ICompilationUnit):Bool {
		if (Lambda.indexOf(_compilationUnits, unit) != -1) {
			return false;
		}

		_compilationUnits.push(unit);
		compilationUnitAdded(unit);
		return true;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#removeCompilationUnit()
	 *
	 * @see #compilationUnitRemoved()
	 */
	public function removeCompilationUnit(unit:ICompilationUnit):Bool {
		var len:Int = _compilationUnits.length;
		for (i in 0...len) {
			var element:ICompilationUnit = try cast(_compilationUnits[i], ICompilationUnit) catch (e:Dynamic) null;
			if (element == unit) {
				_compilationUnits.splice(i, 1);
				compilationUnitRemoved(unit);
				return true;
			}
		}
		return false;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#addClassPath()
	 */
	public function addClassPath(classPath:String):IClassPathEntry {
		var entry:IClassPathEntry;

		for (entry in _classPathEntries) {
			if (entry.filePath == classPath) {
				return null;
			}
		}

		entry = new ClassPathEntry(classPath);
		_classPathEntries.push(entry);
		return entry;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#removeClassPath()
	 */
	public function removeClassPath(classPath:String):Bool {
		var len:Int = _classPathEntries.length;
		for (i in 0...len) {
			var element:IClassPathEntry = try cast(_classPathEntries[i], IClassPathEntry) catch (e:Dynamic) null;
			if (element.filePath == classPath) {
				_classPathEntries.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#addResourceRoot()
	 */
	public function addResourceRoot(resource:IResourceRoot):Bool {
		if (Lambda.indexOf(_resourceRoots, resource) != -1) {
			return false;
		}

		_resourceRoots.push(resource);
		return true;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#removeResourceRoot()
	 */
	public function removeResourceRoot(resource:IResourceRoot):Bool {
		var len:Int = _resourceRoots.length;
		for (i in 0...len) {
			var element:IResourceRoot = try cast(_resourceRoots[i], IResourceRoot) catch (e:Dynamic) null;
			if (element == resource) {
				_resourceRoots.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#newClass()
	 */
	public function newClass(qualifiedName:String):ICompilationUnit {
		var cu:ICompilationUnit = factory.newClass(qualifiedName);
		addCompilationUnit(cu);
		return cu;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#newInterface()
	 */
	public function newInterface(qualifiedName:String):ICompilationUnit {
		var cu:ICompilationUnit = factory.newInterface(qualifiedName);
		addCompilationUnit(cu);
		return cu;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#newApplication()
	 */
	public function newApplication(qualifiedName:String,
			superQualifiedName:String):ICompilationUnit {
		var cu:ICompilationUnit = factory.newApplication(qualifiedName, superQualifiedName);
		addCompilationUnit(cu);
		return cu;
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#readAllAsync()
	 */
	public function readAllAsync():Void {}

	/**
	 * @copy org.as3commons.asblocks.IASProject#readAll()
	 */
	public function readAll():Void {}

	/**
	 * @copy org.as3commons.asblocks.IASProject#writeAll()
	 *
	 * @see #write()
	 */
	public function writeAll():Void {
		clearBuffer();

		var len:Int = compilationUnits.length;
		for (i in 0...len) {
			var element:ICompilationUnit = try cast(compilationUnits[i], ICompilationUnit) catch (e:Dynamic) null;
			write(outputLocation, element);
		}
	}

	/**
	 * @copy org.as3commons.asblocks.IASProject#writeAll()
	 */
	public function writeAllAsync():Void {}

	//--------------------------------------------------------------------------
	//
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Addition hook.
	 *
	 * @param unit A successfully added compilation unit.
	 * @see #addCompilationUnit()
	 */
	private function compilationUnitAdded(unit:ICompilationUnit):Void
	// TODO (mschmalle) remove this concrete CompilationUnitNode ref
	 {

		if (Std.is(unit, CompilationUnitNode)) {
			cast((unit), CompilationUnitNode)._project = this;
		}
	}

	/**
	 * Removal hook.
	 *
	 * @param unit A successfully removed compilation unit.
	 * @see #removeCompilationUnit()
	 */
	private function compilationUnitRemoved(unit:ICompilationUnit):Void
	// TODO (mschmalle) remove this concrete CompilationUnitNode ref
	 {

		if (Std.is(unit, CompilationUnitNode)) {
			cast((unit), CompilationUnitNode)._project = null;
		}
	}

	/**
	 * @private
	 */
	private function clearBuffer():Void {
		_sourceCodeList = [];
	}

	/**
	 * @private
	 */
	private function write(location:String, unit:ICompilationUnit):Void {
		var fileName:String = FileUtil.fileNameFor(unit);

		// subclass for new implementation
		var code:SourceCode = new SourceCode(null, fileName);
		factory.newWriter().write(code, unit);

		_sourceCodeList.push(code);
	}

	//--------------------------------------------------------------------------
	//
	//  TODO
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _sourceCodeList:Array<Dynamic> = [];

	/**
	 * @private
	 */
	private function get_sourceCodeList():Array<Dynamic> {
		return _sourceCodeList;
	}

}