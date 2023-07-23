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
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _id:uint;
        private var _pixels:ByteArray;
        private var _rect:Rectangle;
        private var _bitmapData:BitmapData;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get id():uint { return _id; }
        public function set id(value:uint):void { _id = value; }
        public function get pixels():ByteArray { return _pixels; }
        public function set pixels(value:ByteArray):void { _pixels = value; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteData()
        {
            _rect = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE)
            _bitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, 0xFFFF00FF);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return "[object ThingData id="+id+"]";
        }

        /**
         * @param backgroundColor A 32-bit ARGB color value.
         */
        public function getBitmap(backgroundColor:uint = 0x00000000):BitmapData
        {
            if (pixels) {
                var bitmap:BitmapData;

                try
                {
                    pixels.position = 0;
                    _bitmapData.setPixels(_rect, pixels);
                    bitmap = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, backgroundColor);
                    bitmap.copyPixels(_bitmapData, _rect, POINT, null, null, true);
                } catch(error:Error) {
                    return null;
                }
                return bitmap;
            }
            return null;
        }

        public function isEmpty():Boolean
        {
            if (pixels) {
                _bitmapData.setPixels(_rect, pixels);
                return SpriteUtils.isEmpty(_bitmapData);
            }
            return true;
        }

        public function clone():SpriteData
        {
            var pixelsCopy:ByteArray;

            if (_pixels) {
                pixelsCopy = new ByteArray();
                _pixels.position = 0;
                _pixels.readBytes(pixelsCopy, 0, _pixels.bytesAvailable);
            }

            var sd:SpriteData = new SpriteData();
            sd.id = _id;
            sd.pixels = pixelsCopy;
            return sd;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------
        private static const POINT:Point = new Point();

        public static function createSpriteData(id:uint = 0, pixels:ByteArray = null):SpriteData
        {
            var data:SpriteData = new SpriteData();
            data.id = id;

            var bitmapData:BitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, 0xFFFF00FF);
            data.pixels = pixels ? pixels : bitmapData.getPixels(new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE));

            return data;
        }
    }
}
