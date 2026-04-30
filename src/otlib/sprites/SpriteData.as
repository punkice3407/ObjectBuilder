/*
*  Copyright (c) 2014-2023 Object Builder <https://github.com/ottools/ObjectBuilder>
*
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:
*
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.
*/

package otlib.sprites
{
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;

    import otlib.components.IListObject;
    import otlib.utils.SpriteUtils;
    import otlib.utils.SpriteExtent;
    import flash.display.Bitmap;

    public class SpriteData implements IListObject
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        private var _id:uint;
        private var _pixels:ByteArray;
        private var _rect:Rectangle;
        private var _bitmapData:BitmapData;

        /** Cached cropped bitmap for grid renderer (cropped to non-transparent bounds) */
        public var croppedBitmap:BitmapData;

        // --------------------------------------
        // Getters / Setters
        // --------------------------------------

        public function get id():uint
        {
            return _id;
        }
        public function set id(value:uint):void
        {
            _id = value;
        }
        public function get pixels():ByteArray
        {
            return _pixels;
        }
        public function set pixels(value:ByteArray):void
        {
            _pixels = value;
            // Pixels mutated — invalidate cached cropped bitmap
            if (croppedBitmap)
            {
                croppedBitmap.dispose();
                croppedBitmap = null;
            }
        }

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function SpriteData()
        {
            _rect = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
            // _bitmapData is now lazy-initialized in ensureBitmapData()
        }

        private function ensureBitmapData():BitmapData
        {
            if (!_bitmapData)
            {
                _bitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, 0xFFFF00FF);
            }
            return _bitmapData;
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        // --------------------------------------
        // Public
        // --------------------------------------

        public function toString():String
        {
            return "[object ThingData id=" + id + "]";
        }

        /**
         * @param backgroundColor A 32-bit ARGB color value.
         */
        public function getBitmap(backgroundColor:uint = 0x00000000):BitmapData
        {
            if (!pixels)
                return null;

            try
            {
                pixels.position = 0;
                // Create result bitmap directly - avoid intermediate buffer when possible
                var bitmap:BitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, backgroundColor);

                if (backgroundColor == 0x00000000)
                {
                    // Transparent background: decode directly to result
                    bitmap.setPixels(_rect, pixels);
                }
                else
                {
                    // Non-transparent background: need intermediate buffer for alpha blending
                    var buffer:BitmapData = ensureBitmapData();
                    buffer.setPixels(_rect, pixels);
                    bitmap.copyPixels(buffer, _rect, POINT, null, null, true);
                }
                return bitmap;
            }
            catch (error:Error)
            {
                return null;
            }
            return null;
        }

        public function isEmpty():Boolean
        {
            if (!pixels)
                return true;

            pixels.position = 0;
            var buffer:BitmapData = ensureBitmapData();
            buffer.setPixels(_rect, pixels);
            return SpriteUtils.isEmpty(buffer);
        }

        public function dispose():void
        {
            if (_pixels)
            {
                _pixels.clear();
                _pixels = null;
            }
            if (_bitmapData)
            {
                _bitmapData.dispose();
                _bitmapData = null;
            }
            if (croppedBitmap)
            {
                croppedBitmap.dispose();
                croppedBitmap = null;
            }
        }

        public function clone():SpriteData
        {
            var pixelsCopy:ByteArray;

            if (_pixels)
            {
                pixelsCopy = new ByteArray();
                _pixels.position = 0;
                _pixels.readBytes(pixelsCopy, 0, _pixels.bytesAvailable);
            }

            var sd:SpriteData = new SpriteData();
            sd.id = _id;
            sd.pixels = pixelsCopy;
            return sd;
        }

        // --------------------------------------------------------------------------
        // STATIC
        // --------------------------------------------------------------------------
        private static const POINT:Point = new Point();
        private static const DEFAULT_RECT:Rectangle = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
        private static var _emptyPixels:ByteArray;
        private static var _sharedBitmapBuffer:BitmapData;

        private static function getEmptyPixels():ByteArray
        {
            if (!_emptyPixels)
            {
                _emptyPixels = new ByteArray();
                _emptyPixels.length = SpriteExtent.DEFAULT_DATA_SIZE;
                // Fill with transparent magenta (0xFFFF00FF in ARGB)
                for (var i:uint = 0; i < SpriteExtent.DEFAULT_DATA_SIZE; i += 4)
                {
                    _emptyPixels[i] = 0xFF; // Alpha
                    _emptyPixels[i + 1] = 0xFF; // Red
                    _emptyPixels[i + 2] = 0x00; // Green
                    _emptyPixels[i + 3] = 0xFF; // Blue
                }
            }
            _emptyPixels.position = 0;
            return _emptyPixels;
        }

        public static function createSpriteData(id:uint = 0, pixels:ByteArray = null):SpriteData
        {
            var data:SpriteData = new SpriteData();
            data.id = id;

            if (pixels)
            {
                data.pixels = pixels;
            }
            else
            {
                // Copy empty pixels instead of creating a new BitmapData
                var empty:ByteArray = getEmptyPixels();
                var copy:ByteArray = new ByteArray();
                copy.writeBytes(empty, 0, empty.length);
                data.pixels = copy;
            }

            return data;
        }
    }
}
