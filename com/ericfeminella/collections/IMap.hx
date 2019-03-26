/*
Copyright (c) 2006 - 2008  Eric J. Feminella  <eric@ericfeminella.com>
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

@internal
*/

package com.ericfeminella.collections;

import mx.collections.IList;

/**
 *
 * Defines the contract for lightweight HashMap implementations
 * which are to expose an API into a managed collection of key
 * value pairs
 *
 */
interface IMap {

	/**
	 *
	 * Adds a key / value pair to the current Map
	 *
	 * @param the key to add to the map
	 * @param the value of the specified key
	 *
	 */
	function put(key:Dynamic, value:Dynamic):Void;

	/**
	 *
	 * Places all name / value pairs into the current
	 * <code>IMap</code> instance.
	 *
	 * @param an <code>Object</code> of name / value pairs
	 *
	 */
	function putAll(table:haxe.ds.ObjectMap<Dynamic, Dynamic>):Void;

	/**
	 *
	 * <code>putEntry</code> is intended as a pseudo-overloaded
	 * <code>put</code> implementation whereby clients may call
	 * <code>putEntry</code> to pass an <code>IHashMapEntry</code>
	 * implementation.
	 *
	 * @param concrete <code>IHashMapEntry</code> implementation
	 *
	 */
	function putEntry(entry:IHashMapEntry):Void;

	/**
	 *
	 * Removes a key / value from the HashMap instance
	 *
	 * @param  key to remove from the map
	 *
	 */
	function remove(key:Dynamic):Void;

	/**
	 *
	 * Determines if a key exists in the HashMap instance
	 *
	 * @param  the key in which to determine existance in the map
	 * @return true if the key exisits, false if not
	 *
	 */
	function containsKey(key:Dynamic):Bool;

	/**
	 *
	 * Determines if a value exists in the HashMap instance
	 *
	 * @param  the value in which to determine existance in the map
	 * @return true if the value exisits, false if not
	 *
	 */
	function containsValue(value:Dynamic):Bool;

	/**
	 *
	 * Returns a key value from the HashMap instance
	 *
	 * @param  the key in which to retrieve the value of
	 * @return the value of the specified key
	 *
	 */
	function getKey(value:Dynamic):Dynamic;

	/**
	 *
	 * Returns a key value from the HashMap instance
	 *
	 * @param  the key in which to retrieve the value of
	 * @return the value of the specified key
	 *
	 */
	function getValue(key:Dynamic):Dynamic;

	/**
	 *
	 * Returns each key added to the HashMap instance
	 *
	 * @return String Array of key identifiers
	 *
	 */
	function getKeys():Array<Dynamic>;

	/**
	 *
	 * Returns each value assigned to each key in the HashMap instance
	 *
	 * @return Array of values assigned for all keys in the map
	 *
	 */
	function getValues():Array<Dynamic>;

	/**
	 *
	 * Retrieves the size of the HashMap instance
	 *
	 * @return the current size of the map instance
	 *
	 */
	function size():Int;

	/**
	 *
	 * Determines if the HashMap instance is empty
	 *
	 * @return true if the current map is empty, false if not
	 *
	 */
	function isEmpty():Bool;

	/**
	 *
	 * Resets all key value assignments in the HashMap instance to null
	 *
	 */
	function reset():Void;

	/**
	 *
	 * Resets all key / values defined in the HashMap instance to null
	 *
	 */
	function resetAllExcept(key:Dynamic):Void;

	/**
	 *
	 * Clears all key / values defined in the HashMap instance
	 *
	 */
	function clear():Void;

	/**
	 *
	 * Clears all key / values defined in the HashMap instance
	 * with the exception of the specified key
	 *
	 */
	function clearAllExcept(key:Dynamic):Void;

	/**
	 *
	 * Returns an <code>Array</code> of <code>IHashMapEntry</code>
	 * objects based on the underlying internal map.
	 *
	 * @param <code>Array</code> of <code>IHashMapEntry</code> objects
	 *
	 */
	function getEntries():Array<Dynamic>;

}