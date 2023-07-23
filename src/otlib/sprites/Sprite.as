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
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import by.blooddy.crypto.MD5;

    import nail.errors.NullArgumentError;
    import otlib.utils.SpriteExtent;

    /**
     * The Sprite class represents an image with SpriteExtent x SpriteExtent pixels.
     */
    public class Sprite
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _id:uint;
        private var _transparent:Boolean;
        private var _compressedPixels:ByteArray;
        private var _bitmap:BitmapData;
        private var _hash:String;
        private var _rect:Rectangle;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        /** The id of the sprite. This value specifies the index in the spr file. **/
        public function get id():uint { return _id; }
        public function set id(value:uint):void { _id = value; }

        /** Specifies whether the sprite supports per-pixel transparency. **/
        public function get transparent():Boolean { return _transparent; }
        public function set transparent(value:Boolean):void {
            if (_transparent != value) {

                var pixels:ByteArray = getPixels();
                _transparent = value;
                setPixels( pixels );
            }
        }

        /** Indicates if the sprite does not have colored pixels. **/
        public function get isEmpty():Boolean { return (_compressedPixels.length == 0); }

        internal function get length():uint { return _compressedPixels.length;}
        internal function get compressedPixels():ByteArray { return _compressedPixels; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Sprite(id:uint, transparent:Boolean)
        {
            _id = id;
            _transparent = transparent;
            _compressedPixels = new ByteArray();
            _compressedPixels.endian = Endian.LITTLE_ENDIAN;

            _rect = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        /**
         * Returns the <code>id</code> string representation of the <code>Sprite</code>.
         */
        public function toString():String
        {
            return _id.toString();
        }

        public function getPixels():ByteArray
        {
            return uncompressPixels();
        }

        public function setPixels(pixels:ByteArray):Boolean
        {
            if (!pixels)
                throw new NullArgumentError("pixels");

            if (pixels.length != SpriteExtent.DEFAULT_DATA_SIZE)
                throw new Error("Invalid sprite pixels length");

            _hash = null;
            return compressPixels(pixels);
        }

        public function getBitmap():BitmapData
        {
            if (_bitmap)
                return _bitmap;

            var pixels:ByteArray = getPixels();
            if (!pixels)
                return null;

            _bitmap = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true);
            _bitmap.setPixels(_rect, pixels);

            return _bitmap;
        }

        public function setBitmap(bitmap:BitmapData):Boolean
        {
            if (!bitmap)
                throw new NullArgumentError("bitmap");

            if (bitmap.width != SpriteExtent.DEFAULT_SIZE || bitmap.height != SpriteExtent.DEFAULT_SIZE)
                throw new Error("Invalid sprite bitmap size");

            if (!compressPixels( bitmap.getPixels(_rect) ))
                return false;

            _hash = null;
            _bitmap = bitmap.clone();
            return true;
        }

        public function getHash():String
        {
            if (_hash != null)
                return _hash;

            if (_compressedPixels.length != 0)
                _hash = MD5.hashBytes(_compressedPixels);

            return _hash;
        }

        public function clone():Sprite
        {
            var sprite:Sprite = new Sprite(_id, _transparent);

            _compressedPixels.position = 0;
            _compressedPixels.readBytes(sprite._compressedPixels);

            sprite._bitmap = _bitmap;
            return sprite;
        }

        public function clear():void
        {
            if (_compressedPixels)
                _compressedPixels.clear();

            if (_bitmap)
                _bitmap.fillRect(_rect, 0x00FF00FF);
        }

        public function dispose():void
        {
            if (_compressedPixels)
                _compressedPixels.clear();

            if (_bitmap) {
                _bitmap.dispose();
                _bitmap = null;
            }

            _id = 0;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function compressPixels(pixels:ByteArray):Boolean
        {
            _compressedPixels.clear();
            pixels.position = 0;

            var index:uint;
            var color:uint;
            var transparentPixel:Boolean = true;
            var alphaCount:uint;
            var chunkSize:uint;
            var coloredPos:uint;
            var finishOffset:uint;
            var length:uint = pixels.length / 4;

            while (index < length) {

                chunkSize = 0;
                while (index < length) {
                    pixels.position = index * 4;
                    color = pixels.readUnsignedInt();
                    transparentPixel = (color == 0);
                    if (!transparentPixel) break;
                    alphaCount++;
                    chunkSize++;
                    index++;
                }

                // Entire image is transparent
                if (alphaCount < length) {
                    // Already at the end
                    if(index < length) {
                        _compressedPixels.writeShort(chunkSize); // Write transparent pixels
                        coloredPos = _compressedPixels.position; // Save colored position
                        _compressedPixels.position += 2; // Skip colored short
                        chunkSize = 0;

                        while(index < length) {
                            pixels.position = index * 4;
                            color = pixels.readUnsignedInt();
                            transparentPixel = (color == 0);
                            if (transparentPixel) break;

                            _compressedPixels.writeByte(color >> 16 & 0xFF); // Write red
                            _compressedPixels.writeByte(color >> 8 & 0xFF); // Write green
                            _compressedPixels.writeByte(color & 0xFF); // Write blue
                            if (_transparent) _compressedPixels.writeByte(color >> 24 & 0xFF); // Write Alpha

                            chunkSize++;
                            index++;
                        }

                        finishOffset = _compressedPixels.position;
                        _compressedPixels.position = coloredPos; // Go back to chunksize indicator
                        _compressedPixels.writeShort(chunkSize); // Write colored pixels
                        _compressedPixels.position = finishOffset;
                    }
                }
            }

            return true;
        }

        private function uncompressPixels():ByteArray
        {
            var read:uint;
            var write:uint;
            var transparentPixels:uint;
            var coloredPixels:uint;
            var alpha:uint;
            var red:uint;
            var green:uint;
            var blue:uint;
            var channels:uint = _transparent ? 4 : 3;
            var length:uint = _compressedPixels.length;
            var i:int;

            _compressedPixels.position = 0;
            var pixels:ByteArray = new ByteArray();

            for (read = 0; read < length; read += 4 + (channels * coloredPixels)) {

                transparentPixels = _compressedPixels.readUnsignedShort();
                coloredPixels = _compressedPixels.readUnsignedShort();

                for (i = 0; i < transparentPixels; i++) {
                    pixels[write++] = 0x00; // Alpha
                    pixels[write++] = 0x00; // Red
                    pixels[write++] = 0x00; // Green
                    pixels[write++] = 0x00; // Blue
                }

                for (i = 0; i < coloredPixels; i++) {
                    red = _compressedPixels.readUnsignedByte(); // Red
                    green = _compressedPixels.readUnsignedByte(); // Green
                    blue = _compressedPixels.readUnsignedByte(); // Blue
                    alpha = _transparent ? _compressedPixels.readUnsignedByte() : 0xFF; // Alpha

                    pixels[write++] = alpha; // Alpha
                    pixels[write++] = red; // Red
                    pixels[write++] = green; // Green
                    pixels[write++] = blue; // Blue
                }
            }

            while(write < SpriteExtent.DEFAULT_DATA_SIZE) {
                pixels[write++] = 0x00; // Alpha
                pixels[write++] = 0x00; // Red
                pixels[write++] = 0x00; // Green
                pixels[write++] = 0x00; // Blue
            }

            return pixels;
        }
    }
}
