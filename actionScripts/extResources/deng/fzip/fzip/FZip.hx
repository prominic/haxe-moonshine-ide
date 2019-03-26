/*
 * Copyright (C) 2006 Claus Wahlers and Max Herkender
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package actionScripts.extResources.deng.fzip.fzip;

import flash.errors.Error;import haxe.Constraints.Function;

import flash.events.*;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.*;

/**
 * Dispatched when a file contained in a ZIP archive has
 * loaded successfully.
 *
 * @eventType deng.fzip.FZipEvent.FILE_LOADED
 */
@:meta(Event(name = 'fileLoaded', type = 'deng.fzip.FZipEvent'))

/**
 * Dispatched when an error is encountered while parsing a
 * ZIP Archive.
 *
 * @eventType deng.fzip.FZipErrorEvent.PARSE_ERROR
 */
@:meta(Event(name = 'parseError', type = 'deng.fzip.FZipErrorEvent'))

/**
 * Dispatched when data has loaded successfully.
 *
 * @eventType flash.events.Event.COMPLETE
 */
@:meta(Event(name = 'complete', type = 'flash.events.Event'))

/**
 * Dispatched if a call to FZip.load() attempts to access data
 * over HTTP, and the current Flash Player is able to detect
 * and return the status code for the request. (Some browser
 * environments may not be able to provide this information.)
 * Note that the httpStatus (if any) will be sent before (and
 * in addition to) any complete or error event
 *
 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
 */
@:meta(Event(name = 'httpStatus', type = 'flash.events.HTTPStatusEvent'))

/**
 * Dispatched when an input/output error occurs that causes a
 * load operation to fail.
 *
 * @eventType flash.events.IOErrorEvent.IO_ERROR
 */
@:meta(Event(name = 'ioError', type = 'flash.events.IOErrorEvent'))

/**
 * Dispatched when a load operation starts.
 *
 * @eventType flash.events.Event.OPEN
 */
@:meta(Event(name = 'open', type = 'flash.events.Event'))

/**
 * Dispatched when data is received as the download operation
 * progresses.
 *
 * @eventType flash.events.ProgressEvent.PROGRESS
 */
@:meta(Event(name = 'progress', type = 'flash.events.ProgressEvent'))

/**
 * Dispatched if a call to FZip.load() attempts to load data
 * from a server outside the security sandbox.
 *
 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
 */
@:meta(Event(name = 'securityError', type = 'flash.events.SecurityErrorEvent'))

/**
 * Loads and parses ZIP archives.
 *
 * <p>FZip is able to process, create and modify standard ZIP archives as described in the
 * <a href="http://www.pkware.com/business_and_developers/developer/popups/appnote.txt">PKZIP file format documentation</a>.</p>
 *
 * <p>Limitations:</p>
 * <ul>
 * <li>ZIP feature versions &gt; 2.0 are not supported</li>
 * <li>ZIP archives containing data descriptor records are not supported.</li>
 * <li>If running in the Flash Player browser plugin, FZip requires ZIPs to be
 * patched (Adler32 checksums need to be added). This is not required if
 * FZip runs in the Adobe AIR runtime or if files contained in the ZIP
 * are not compressed.</li>
 * </ul>
 */
class FZip extends EventDispatcher {

	public var active(get, never):Bool;

	private var filesList:Array<Dynamic>;

	private var filesDict:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	private var urlStream:URLStream;

	private var charEncoding:String;

	private var parseFunc:Function;

	private var currentFile:FZipFile;

	private var ddBuffer:ByteArray;

	private var ddSignature:Int;

	private var ddCompressedSize:Int;

	// PKZIP record signatures
	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_CENTRAL_FILE_HEADER:Int = 0x02014b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_SPANNING_MARKER:Int = 0x30304b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_LOCAL_FILE_HEADER:Int = 0x04034b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_DIGITAL_SIGNATURE:Int = 0x05054b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_END_OF_CENTRAL_DIRECTORY:Int = 0x06054b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_ZIP64_END_OF_CENTRAL_DIRECTORY:Int = 0x06064b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR:Int = 0x07064b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_DATA_DESCRIPTOR:Int = 0x08074b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_ARCHIVE_EXTRA_DATA:Int = 0x08064b50;

	@:allow(actionScripts.extResources.deng.fzip.fzip)
	private static inline var SIG_SPANNING:Int = 0x08074b50;

	/**
	 * Constructor
	 *
	 * @param filenameEncoding The character encoding used for filenames
	 * contained in the zip. If unspecified, unicode ("utf-8") is used.
	 * Older zips commonly use encoding "IBM437" (aka "cp437"),
	 * while other European countries use "ibm850".
	 * @see http://livedocs.adobe.com/labs/as3preview/langref/charset-codes.html
	 */
	public function new(filenameEncoding:String = 'utf-8') {
		super();
		charEncoding = filenameEncoding;
		parseFunc = parseIdle;
	}

	/**
	 * Indicates whether a file is currently being processed or not.
	 */
	private function get_active():Bool {
		return (parseFunc != parseIdle);
	}

	/**
	 * Begins downloading the ZIP archive specified by the request
	 * parameter.
	 *
	 * @param request A URLRequest object specifying the URL of a ZIP archive
	 * to download.
	 * If the value of this parameter or the URLRequest.url property
	 * of the URLRequest object passed are null, Flash Player throws
	 * a null pointer error.
	 */
	public function load(request:URLRequest):Void {
		if (urlStream == null && parseFunc == parseIdle) {
			urlStream = new URLStream();
			urlStream.endian = Endian.LITTLE_ENDIAN;
			addEventHandlers();
			filesList = [];
			filesDict = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
			parseFunc = parseSignature;
			urlStream.load(request);
		}
	}

	/**
	 * Loads a ZIP archive from a ByteArray.
	 *
	 * @param bytes The ByteArray containing the ZIP archive
	 */
	public function loadBytes(bytes:ByteArray):Void {
		if (urlStream == null && parseFunc == parseIdle) {
			filesList = [];
			filesDict = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			parseFunc = parseSignature;
			if (parse(bytes)) {
				parseFunc = parseIdle;
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new FZipErrorEvent(FZipErrorEvent.PARSE_ERROR, 'EOF'));
			}
		}
	}

	/**
	 * Immediately closes the stream and cancels the download operation.
	 * Files contained in the ZIP archive being loaded stay accessible
	 * through the getFileAt() and getFileByName() methods.
	 */
	public function close():Void {
		if (urlStream != null) {
			parseFunc = parseIdle;
			removeEventHandlers();
			urlStream.close();
			urlStream = null;
		}
	}

	/**
	 * Serializes this zip archive into an IDataOutput stream (such as
	 * ByteArray or FileStream) according to PKZIP APPNOTE.TXT
	 *
	 * @param stream The stream to serialize the zip file into.
	 * @param includeAdler32 To decompress compressed files, FZip needs Adler32
	 * 		checksums to be injected into the zipped files. FZip will do that
	 * 		automatically if includeAdler32 is set to true. Note that if the
	 * 		ZIP contains a lot of files, or big files, the calculation of the
	 * 		checksums may take a while.
	 */
	public function serialize(stream:IDataOutput, includeAdler32:Bool = false):Void {
		if (stream != null && filesList.length > 0) {
			var endian:String = stream.endian;
			var ba:ByteArray = new ByteArray();
			stream.endian = ba.endian = Endian.LITTLE_ENDIAN;
			var offset:Int = 0;
			var files:Int = 0;
			var i:Int = 0;
			while (i < filesList.length) {
				var file:FZipFile = try cast(filesList[i], FZipFile) catch (e:Dynamic) null;
				if (file != null)
				// first serialize the central directory item
				{

					// into our temporary ByteArray
					file.serialize(ba, includeAdler32, true, offset);
					// then serialize the file itself into the stream
					// and update the offset
					offset += file.serialize(stream, includeAdler32);
					// keep track of how many files we have written
					files++;
				}
				i++;
			}
			if (ba.length > 0)
			// Write the central directory items
			{

				stream.writeBytes(ba);
			}
			// Write end of central directory:
			// Write signature
			stream.writeUnsignedInt(SIG_END_OF_CENTRAL_DIRECTORY);
			// Write number of this disk (always 0)
			stream.writeShort(0);
			// Write number of this disk with the start of the central directory (always 0)
			stream.writeShort(0);
			// Write total number of entries on this disk
			stream.writeShort(files);
			// Write total number of entries
			stream.writeShort(files);
			// Write size
			stream.writeUnsignedInt(ba.length);
			// Write offset of start of central directory with respect to the starting disk number
			stream.writeUnsignedInt(offset);
			// Write zip file comment length (always 0)
			stream.writeShort(0);
			// Reset endian of stream
			stream.endian = endian;
		}
	}

	/**
	 * Gets the number of accessible files in the ZIP archive.
	 *
	 * @return The number of files
	 */
	public function getFileCount():Int {
		return (filesList != null) ? filesList.length : 0;
	}

	/**
	 * Retrieves a file contained in the ZIP archive, by index.
	 *
	 * @param index The index of the file to retrieve
	 * @return A reference to a FZipFile object
	 */
	public function getFileAt(index:Int):FZipFile {
		return (filesList != null) ? try cast(filesList[index], FZipFile) catch (e:Dynamic) null : null;
	}

	/**
	 * Retrieves a file contained in the ZIP archive, by filename.
	 *
	 * @param name The filename of the file to retrieve
	 * @return A reference to a FZipFile object
	 */
	public function getFileByName(name:String):FZipFile {
		return (filesDict.get(name) != null) ? try cast(filesDict.get(name), FZipFile) catch (e:Dynamic) null : null;
	}

	/**
	 * Adds a file to the ZIP archive.
	 *
	 * @param name The filename
	 * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder)
	 * @param doCompress Compress the data after adding.
	 *
	 * @return A reference to the newly created FZipFile object
	 */
	public function addFile(name:String, content:ByteArray = null, doCompress:Bool = true):FZipFile {
		return addFileAt((filesList != null) ? filesList.length : 0, name, content, doCompress);
	}

	/**
	 * Adds a file from a String to the ZIP archive.
	 *
	 * @param name The filename
	 * @param content The String
	 * @param charset The character set
	 * @param doCompress Compress the string after adding.
	 *
	 * @return A reference to the newly created FZipFile object
	 */
	public function addFileFromString(name:String, content:String, charset:String = 'utf-8', doCompress:Bool = true):FZipFile {
		return addFileFromStringAt((filesList != null) ? filesList.length : 0, name, content, charset, doCompress);
	}

	/**
	 * Adds a file to the ZIP archive, at a specified index.
	 *
	 * @param index The index
	 * @param name The filename
	 * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder)
	 * @param doCompress Compress the data after adding.
	 *
	 * @return A reference to the newly created FZipFile object
	 */
	public function addFileAt(index:Int, name:String, content:ByteArray = null, doCompress:Bool = true):FZipFile {
		if (filesList == null) {
			filesList = [];
		}
		if (filesDict == null) {
			filesDict = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
		} else if (filesDict.get(name) != null) {
			throw (new Error('File already exists: ' + name + '. Please remove first.'));
		}
		var file:FZipFile = new FZipFile();
		file.filename = name;
		file.setContent(content, doCompress);
		if (index >= filesList.length) {
			filesList.push(file);
		} else {
			as3hx.Compat.arraySplice(filesList, index, 0, [file]);
		}
		filesDict.set(name, file);
		return file;
	}

	/**
	 * Adds a file from a String to the ZIP archive, at a specified index.
	 *
	 * @param index The index
	 * @param name The filename
	 * @param content The String
	 * @param charset The character set
	 * @param doCompress Compress the string after adding.
	 *
	 * @return A reference to the newly created FZipFile object
	 */
	public function addFileFromStringAt(index:Int, name:String, content:String, charset:String = 'utf-8', doCompress:Bool = true):FZipFile {
		if (filesList == null) {
			filesList = [];
		}
		if (filesDict == null) {
			filesDict = new haxe.ds.ObjectMap<Dynamic, Dynamic>();
		} else if (filesDict.get(name) != null) {
			throw (new Error('File already exists: ' + name + '. Please remove first.'));
		}
		var file:FZipFile = new FZipFile();
		file.filename = name;
		file.setContentAsString(content, charset, doCompress);
		if (index >= filesList.length) {
			filesList.push(file);
		} else {
			as3hx.Compat.arraySplice(filesList, index, 0, [file]);
		}
		filesDict.set(name, file);
		return file;
	}

	/**
	 * Removes a file at a specified index from the ZIP archive.
	 *
	 * @param index The index
	 * @return A reference to the removed FZipFile object
	 */
	public function removeFileAt(index:Int):FZipFile {
		if (filesList != null && filesDict != null && index < filesList.length) {
			var file:FZipFile = try cast(filesList[index], FZipFile) catch (e:Dynamic) null;
			if (file != null) {
				filesList.splice(index, 1);
				filesDict.remove(file.filename);
				return file;
			}
		}
		return null;
	}

	/**
	 * @private
	 */
	private function parse(stream:IDataInput):Bool {
		while (parseFunc(stream)) {}
		return (parseFunc == parseIdle);
	}

	/**
	 * @private
	 */
	private function parseIdle(stream:IDataInput):Bool {
		return false;
	}

	/**
	 * @private
	 */
	private function parseSignature(stream:IDataInput):Bool {
		if (stream.bytesAvailable >= 4) {
			var sig:Int = stream.readUnsignedInt();
			switch (sig) {
				case SIG_LOCAL_FILE_HEADER:
					parseFunc = parseLocalfile;
					currentFile = new FZipFile(charEncoding);
				case SIG_CENTRAL_FILE_HEADER, SIG_END_OF_CENTRAL_DIRECTORY, SIG_SPANNING_MARKER, SIG_DIGITAL_SIGNATURE, SIG_ZIP64_END_OF_CENTRAL_DIRECTORY, SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR, SIG_DATA_DESCRIPTOR, SIG_ARCHIVE_EXTRA_DATA, SIG_SPANNING:
					parseFunc = parseIdle;
				case _:
					throw (new Error('Unknown record signature: 0x' + Std.string(sig)));
			}
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function parseLocalfile(stream:IDataInput):Bool {
		if (currentFile.parse(stream)) {
			if (currentFile.hasDataDescriptor)
			// This file uses a data descriptor:
			{

				// "[A data] descriptor exists only if bit 3 of the
				// general purpose bit flag is set.  It is byte aligned
				// and immediately follows the last byte of compressed data.
				// This descriptor is used only when it was not possible to
				// seek in the output .ZIP file, e.g., when the output .ZIP file
				// was standard output or a non-seekable device" (APPNOTE.TXT).

				// The file parser stops parsing after the file header.
				// We need to figure out the compressed size of the file's
				// payload (by searching ahead for the data descriptor
				// signature). See findDataDescriptor() below.

				parseFunc = findDataDescriptor;
				ddBuffer = new ByteArray();
				ddSignature = 0;
				ddCompressedSize = 0;
				return true;
			}
			// No data descriptor: We're done.
			else {

				// Register file and dispatch FILE_LOADED event
				onFileLoaded();
				// TODO [CW] why do we check for parseIdle here?
				if (parseFunc != parseIdle) {
					parseFunc = parseSignature;
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * @private
	 */
	private function findDataDescriptor(stream:IDataInput):Bool {
		while (stream.bytesAvailable > 0) {
			var c:Int = stream.readUnsignedByte();
			ddSignature = as3hx.Compat.parseInt(ddSignature >>> 8) | as3hx.Compat.parseInt(c << 24);
			if (ddSignature == SIG_DATA_DESCRIPTOR)
			// Data descriptor signature found
			{

				// Remove last three (signature-) bytes from buffer
				ddBuffer.length -= 3;
				parseFunc = validateDataDescriptor;
				return true;
			}
			ddBuffer.writeByte(c);
		}
		return false;
	}

	/**
	 * @private
	 */
	private function validateDataDescriptor(stream:IDataInput):Bool
	// TODO [CW]
	 {

		// In case validation fails, we should reexamine the
		// alleged sig/crc32/size bytes (minus the first byte)
		if (stream.bytesAvailable >= 12)
		// Get data from descriptor
		{

			var ddCRC32:Int = stream.readUnsignedInt();
			var ddSizeCompressed:Int = stream.readUnsignedInt();
			var ddSizeUncompressed:Int = stream.readUnsignedInt();
			// If the compressed size from the descriptor matches the buffer length,
			// we can be reasonably sure that this really is the descriptor.
			if (ddBuffer.length == ddSizeCompressed) {
				ddBuffer.position = 0;
				// Inject the descriptor data into current file
				currentFile._crc32 = ddCRC32;
				currentFile._sizeCompressed = ddSizeCompressed;
				currentFile._sizeUncompressed = ddSizeUncompressed;
				// Copy buffer into current file
				currentFile.parseContent(ddBuffer);
				// Register file and dispatch FILE_LOADED event
				onFileLoaded();
				// Continue with next file
				parseFunc = parseSignature;
			}
			// TODO [CW] check endianness (i think it's big endian, gotta set that on buffer)
			else {

				ddBuffer.writeUnsignedInt(ddCRC32);
				ddBuffer.writeUnsignedInt(ddSizeCompressed);
				ddBuffer.writeUnsignedInt(ddSizeUncompressed);
				parseFunc = findDataDescriptor;
			}
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function onFileLoaded():Void {
		filesList.push(currentFile);
		if (currentFile.filename) {
			filesDict.set(currentFile.filename, currentFile);
		}
		dispatchEvent(new FZipEvent(FZipEvent.FILE_LOADED, currentFile));
		currentFile = null;
	}

	/**
	 * @private
	 */
	private function progressHandler(evt:Event):Void {
		dispatchEvent(evt.clone());
		try {
			if (parse(urlStream)) {
				close();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		} catch (e:Error) {
			close();
			if (hasEventListener(FZipErrorEvent.PARSE_ERROR)) {
				dispatchEvent(new FZipErrorEvent(FZipErrorEvent.PARSE_ERROR, e.message));
			} else {
				throw (e);
			}
		}
	}

	/**
	 * @private
	 */
	private function defaultHandler(evt:Event):Void {
		dispatchEvent(evt.clone());
	}

	/**
	 * @private
	 */
	private function defaultErrorHandler(evt:Event):Void {
		close();
		dispatchEvent(evt.clone());
	}

	/**
	 * @private
	 */
	private function addEventHandlers():Void {
		urlStream.addEventListener(Event.COMPLETE, defaultHandler);
		urlStream.addEventListener(Event.OPEN, defaultHandler);
		urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
		urlStream.addEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
		urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	}

	/**
	 * @private
	 */
	private function removeEventHandlers():Void {
		urlStream.removeEventListener(Event.COMPLETE, defaultHandler);
		urlStream.removeEventListener(Event.OPEN, defaultHandler);
		urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
		urlStream.removeEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
		urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		urlStream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
	}

}