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
package no.doomsday.console.core.bitmap;

import flash.display.BitmapData;
import no.doomsday.console.core.bitmap.BresenhamSharedData;
import flash.geom.Point;

/**
 * ...
 * @author Andreas Rønning
 */
@:final class Bresenham {

	private static var XY(default, never):BresenhamSharedData = new BresenhamSharedData();

	public static function line_pixel(p1:Point, p2:Point, target:BitmapData, color:Int = 0x000000):Void {
		XY.update(p1, p2);
		var y:Int = XY.y0;
		target.lock();
		target.setPixel(AS3.int(p1.x), AS3.int(p1.y), color);
		for (x in XY.x0...XY.x1) {
			if (XY.steep) {
				target.setPixel(y, x, color);
			} else {
				target.setPixel(x, y, color);
			}
			XY.error = AS3.int(XY.error - XY.deltay);
			if (XY.error < 0) {
				y += XY.ystep;
				XY.error += XY.deltax;
			}
		}
		target.setPixel(AS3.int(p2.x), AS3.int(p2.y), color);
		target.unlock();
	}

	public static function line_pixel32(p1:Point, p2:Point, target:BitmapData, color:Int = 0xFF000000):Void {
		XY.update(p1, p2);
		var y:Int = XY.y0;
		target.lock();
		target.setPixel32(AS3.int(p1.x), AS3.int(p1.y), color);
		for (x in XY.x0...XY.x1) {
			if (XY.steep) {
				target.setPixel32(y, x, color);
			} else {
				target.setPixel32(x, y, color);
			}
			XY.error = AS3.int(XY.error - XY.deltay);
			if (XY.error < 0) {
				y += XY.ystep;
				XY.error += XY.deltax;
			}
		}
		target.setPixel32(AS3.int(p2.x), AS3.int(p2.y), color);
		target.unlock();
	}

	public static function line_stamp(p1:Point, p2:Point, target:BitmapData, stampSource:BitmapData, centerStamp:Bool = true):Void {
		if (centerStamp) {
			var offsetX:Int = 0;
			var offsetY:Int = 0;
			offsetX = AS3.int(stampSource.width * .5);
			offsetY = AS3.int(stampSource.height * .5);
			p1.offset(-offsetX, -offsetY);
			p2.offset(-offsetX, -offsetY);
		}
		XY.update(p1, p2);
		var y:Int = XY.y0;
		var targetPoint:Point = new Point();
		var targetPointInv:Point = new Point();
		target.lock();
		target.copyPixels(stampSource, stampSource.rect, p1, null, null, true);
		for (x in XY.x0...XY.x1) {
			targetPoint.x = x;
			targetPoint.y = y;
			targetPointInv.x = y;
			targetPointInv.y = x;
			if (XY.steep) {
				target.copyPixels(stampSource, stampSource.rect, targetPointInv, null, null, true);
			} else {
				target.copyPixels(stampSource, stampSource.rect, targetPoint, null, null, true);
			}
			XY.error = AS3.int(XY.error - XY.deltay);
			if (XY.error < 0) {
				y += XY.ystep;
				XY.error += XY.deltax;
			}
		}
		target.copyPixels(stampSource, stampSource.rect, p2, null, null, true);
		target.unlock();
	}

	public static function circle(p:Point, radius:Int, target:BitmapData, color:Int = 0x000000):Void {
		var f:Int = 1 - radius;
		var ddF_x:Int = 1;
		var ddF_y:Int = -2 * radius;
		var x:Int = 0;
		var y:Int = radius;
		var x0:Int = AS3.int(p.x);
		var y0:Int = AS3.int(p.y);

		target.lock();
		target.setPixel(x0, y0 + radius, color);
		target.setPixel(x0, y0 - radius, color);
		target.setPixel(x0 + radius, y0, color);
		target.setPixel(x0 - radius, y0, color);

		while (x < y) {
			if (f >= 0) {
				y--;
				ddF_y += 2;
				f += ddF_y;
			}
			x++;
			ddF_x += 2;
			f += ddF_x;
			target.setPixel(x0 + x, y0 + y, color);
			target.setPixel(x0 - x, y0 + y, color);
			target.setPixel(x0 + x, y0 - y, color);
			target.setPixel(x0 - x, y0 - y, color);
			target.setPixel(x0 + y, y0 + x, color);
			target.setPixel(x0 - y, y0 + x, color);
			target.setPixel(x0 + y, y0 - x, color);
			target.setPixel(x0 - y, y0 - x, color);
		}
		target.unlock();
	}

	public static function circle32(p:Point, radius:Int, target:BitmapData, color:Int = 0xFF000000):Void {
		var f:Int = 1 - radius;
		var ddF_x:Int = 1;
		var ddF_y:Int = -2 * radius;
		var x:Int = 0;
		var y:Int = radius;
		var x0:Int = AS3.int(p.x);
		var y0:Int = AS3.int(p.y);

		target.lock();
		target.setPixel32(x0, y0 + radius, color);
		target.setPixel32(x0, y0 - radius, color);
		target.setPixel32(x0 + radius, y0, color);
		target.setPixel32(x0 - radius, y0, color);

		while (x < y) {
			if (f >= 0) {
				y--;
				ddF_y += 2;
				f += ddF_y;
			}
			x++;
			ddF_x += 2;
			f += ddF_x;
			target.setPixel32(x0 + x, y0 + y, color);
			target.setPixel32(x0 - x, y0 + y, color);
			target.setPixel32(x0 + x, y0 - y, color);
			target.setPixel32(x0 - x, y0 - y, color);
			target.setPixel32(x0 + y, y0 + x, color);
			target.setPixel32(x0 - y, y0 + x, color);
			target.setPixel32(x0 + y, y0 - x, color);
			target.setPixel32(x0 - y, y0 - x, color);
		}
		target.unlock();
	}

}