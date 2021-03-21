/*
*  Copyright (c) 2014-2019 Object Builder <https://github.com/ottools/ObjectBuilder>
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

package otlib.things
{
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;

    import nail.errors.NullArgumentError;
    import nail.errors.NullOrEmptyArgumentError;
    import nail.utils.StringUtil;
    import nail.utils.isNullOrEmpty;

    import otlib.geom.Rect;
    import otlib.geom.Size;
    import otlib.obd.OBDEncoder;
    import otlib.obd.OBDVersions;
    import otlib.sprites.Sprite;
    import otlib.sprites.SpriteData;
    import otlib.utils.ColorUtils;
    import otlib.utils.OTFormat;
    import otlib.utils.OutfitData;
    import otlib.utils.SpriteUtils;

    public class ThingData
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_obdVersion:uint;
        private var m_clientVersion:uint;
        private var m_thing:ThingType;
        private var m_sprites:Vector.<SpriteData>;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get id():uint { return m_thing.id; }
        public function get category():String { return m_thing.category; }
        public function get length():uint { return m_sprites.length; }

        public function get obdVersion():uint { return m_obdVersion; }
        public function set obdVersion(value:uint):void
        {
            if (value < OBDVersions.OBD_VERSION_1)
                throw new ArgumentError(StringUtil.format("Invalid obd version {0}.", value));

            m_obdVersion = value;
        }

        public function get clientVersion():uint { return m_clientVersion; }
        public function set clientVersion(value:uint):void
        {
            if (value < 710)
                throw new ArgumentError(StringUtil.format("Invalid client version {0}.", value));

            m_clientVersion = value;
        }

        public function get thing():ThingType { return m_thing; }
        public function set thing(value:ThingType):void
        {
            if (!value)
                throw new NullArgumentError("thing");

            m_thing = value;
        }

        public function get sprites():Vector.<SpriteData> { return m_sprites; }
        public function set sprites(value:Vector.<SpriteData>):void
        {
            if (isNullOrEmpty(value))
                throw new NullOrEmptyArgumentError("sprites");

            var length:uint = value.length;
            for (var i:uint = 0; i < length; i++)
            {
                if (value[i] == null)
                    throw new ArgumentError("Invalid sprite list");
            }

            m_sprites = value;
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingData()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function getSpriteSheet(textureIndex:Vector.<Rect> = null,
                                       backgroundColor:uint = 0xFFFF00FF):BitmapData
        {
            // Measures and creates bitmap
            var size:uint = Sprite.DEFAULT_SIZE;
            var totalX:int = m_thing.patternZ * m_thing.patternX * m_thing.layers;
            var totalY:int = m_thing.frames * m_thing.patternY;
            var bitmapWidth:Number = (totalX * m_thing.width) * size;
            var bitmapHeight:Number = (totalY * m_thing.height) * size;
            var pixelsWidth:int = m_thing.width * size;
            var pixelsHeight:int = m_thing.height * size;
            var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, backgroundColor);

            if (textureIndex)
                textureIndex.length = m_thing.getTotalTextures();

            for (var f:uint = 0; f < m_thing.frames; f++)
            {
                for (var z:uint = 0; z < m_thing.patternZ; z++)
                {
                    for (var y:uint = 0; y < m_thing.patternY; y++)
                    {
                        for (var x:uint = 0; x < m_thing.patternX; x++)
                        {
                            for (var l:uint = 0; l < m_thing.layers; l++)
                            {
                                var index:uint = thing.getTextureIndex(l, x, y, z, f);
                                var fx:int = (index % totalX) * pixelsWidth;
                                var fy:int = Math.floor(index / totalX) * pixelsHeight;

                                if (textureIndex)
                                    textureIndex[index] = new Rect(fx, fy, pixelsWidth, pixelsHeight);

                                for (var w:uint = 0; w < m_thing.width; w++)
                                {
                                    for (var h:uint = 0; h < m_thing.height; h++)
                                    {
                                        index = thing.getSpriteIndex(w, h, l, x, y, z, f);
                                        var px:int = ((m_thing.width - w - 1) * size);
                                        var py:int = ((m_thing.height - h - 1) * size);
                                        copyPixels(index, bitmap, px + fx, py + fy);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return bitmap;
        }

        public function getColoredSpriteSheet(outfitData:OutfitData):BitmapData
        {
            if (!outfitData)
                throw new NullArgumentError("outfitData");

            var textureRectList:Vector.<Rect> = new Vector.<Rect>();
            var spriteSheet:BitmapData = getSpriteSheet(textureRectList, 0x00000000);
            spriteSheet = SpriteUtils.removeMagenta(spriteSheet);

            if (m_thing.layers != 2)
                return spriteSheet;

            var size:uint = Sprite.DEFAULT_SIZE;
            var totalX:int = m_thing.patternZ * m_thing.patternX * m_thing.layers;
            var totalY:int = m_thing.height;
            var pixelsWidth:int  = m_thing.width * size;
            var pixelsHeight:int = m_thing.height * size;
            var bitmapWidth:uint = m_thing.patternZ * m_thing.patternX * pixelsWidth;
            var bitmapHeight:uint = m_thing.frames * pixelsHeight;
            var grayBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var blendBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var colorBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var bitmapRect:Rectangle = bitmap.rect;
            var rectList:Vector.<Rect> = new Vector.<Rect>(m_thing.getTotalTextures(), true);
            var index:uint;
            var f:uint;
            var x:uint;
            var y:uint;
            var z:uint;

            for (f = 0; f < m_thing.frames; f++)
            {
                for (z = 0; z < m_thing.patternZ; z++)
                {
                    for (x = 0; x < m_thing.patternX; x++)
                    {
                        index = (((f % m_thing.frames * m_thing.patternZ + z) * m_thing.patternY + y) * m_thing.patternX + x) * m_thing.layers;
                        rectList[index] = new Rect((z * m_thing.patternX + x) * pixelsWidth, f * pixelsHeight, pixelsWidth, pixelsHeight);
                    }
                }
            }

            for (y = 0; y < m_thing.patternY; y++) {
                if (y == 0 || (outfitData.addons & 1 << (y - 1)) != 0) {
                    for (f = 0; f < m_thing.frames; f++) {
                        for (z = 0; z < m_thing.patternZ; z++) {
                            for (x = 0; x < m_thing.patternX; x++) {
                                var i:uint = (((f % m_thing.frames * m_thing.patternZ + z) * m_thing.patternY + y) * m_thing.patternX + x) * m_thing.layers;
                                var rect:Rect = textureRectList[i];
                                RECTANGLE.setTo(rect.x, rect.y, rect.width, rect.height);

                                index = (((f * m_thing.patternZ + z) * m_thing.patternY) * m_thing.patternX + x) * m_thing.layers;
                                rect = rectList[index];
                                POINT.setTo(rect.x, rect.y);
                                grayBitmap.copyPixels(spriteSheet, RECTANGLE, POINT);

                                i++;
                                rect = textureRectList[i];
                                RECTANGLE.setTo(rect.x, rect.y, rect.width, rect.height);
                                blendBitmap.copyPixels(spriteSheet, RECTANGLE, POINT);
                            }
                        }
                    }

                    POINT.setTo(0, 0);
                    setColor(colorBitmap, grayBitmap, blendBitmap, bitmapRect, BitmapDataChannel.BLUE, ColorUtils.HSItoARGB(outfitData.feet));
                    blendBitmap.applyFilter(blendBitmap, bitmapRect, POINT, MATRIX_FILTER);
                    setColor(colorBitmap, grayBitmap, blendBitmap, bitmapRect, BitmapDataChannel.BLUE, ColorUtils.HSItoARGB(outfitData.head));
                    setColor(colorBitmap, grayBitmap, blendBitmap, bitmapRect, BitmapDataChannel.RED, ColorUtils.HSItoARGB(outfitData.body));
                    setColor(colorBitmap, grayBitmap, blendBitmap, bitmapRect, BitmapDataChannel.GREEN, ColorUtils.HSItoARGB(outfitData.legs));
                    bitmap.copyPixels(grayBitmap, bitmapRect, POINT, null, null, true);
                }
            }

            grayBitmap.dispose();
            blendBitmap.dispose();
            colorBitmap.dispose();
            return bitmap;
        }

        public function setSpriteSheet(bitmap:BitmapData):void
        {
            if (!bitmap)
                throw new NullArgumentError("bitmap");

            var ss:Size = m_thing.getSpriteSheetSize();
            if (bitmap.width != ss.width ||
                bitmap.height != ss.height) return;

            bitmap = SpriteUtils.removeMagenta(bitmap);

            var size:uint = Sprite.DEFAULT_SIZE;
            var totalX:int = m_thing.patternZ * m_thing.patternX * m_thing.layers;
            var pixelsWidth:int  = m_thing.width * size;
            var pixelsHeight:int = m_thing.height * size;

            POINT.setTo(0, 0);

            for (var f:uint = 0; f < m_thing.frames; f++)
            {
                for (var z:uint = 0; z < m_thing.patternZ; z++)
                {
                    for (var y:uint = 0; y < m_thing.patternY; y++)
                    {
                        for (var x:uint = 0; x < m_thing.patternX; x++)
                        {
                            for (var l:uint = 0; l < m_thing.layers; l++)
                            {
                                var index:uint = m_thing.getTextureIndex(l, x, y, z, f);
                                var fx:int = (index % totalX) * pixelsWidth;
                                var fy:int = Math.floor(index / totalX) * pixelsHeight;

                                for (var w:uint = 0; w < m_thing.width; w++)
                                {
                                    for (var h:uint = 0; h < m_thing.height; h++)
                                    {
                                        index = m_thing.getSpriteIndex(w, h, l, x, y, z, f);
                                        var px:int = ((m_thing.width - w - 1) * size);
                                        var py:int = ((m_thing.height - h - 1) * size);

                                        RECTANGLE.setTo(px + fx, py + fy, size, size);
                                        var bmp:BitmapData = new BitmapData(size, size, true, 0x00000000);
                                        bmp.copyPixels(bitmap, RECTANGLE, POINT);

                                        var sd:SpriteData = new SpriteData();
                                        sd.pixels = bmp.getPixels(bmp.rect);
                                        sd.id = uint.MAX_VALUE;

                                        m_sprites[index] = sd;
                                        m_thing.spriteIndex[index] = sd.id;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        public function colorize(outfitData:OutfitData):ThingData
        {
            if (!outfitData)
                throw new NullArgumentError("outfitData");

            if (m_thing.category != ThingCategory.OUTFIT)
                return this;

            var bitmap:BitmapData = getColoredSpriteSheet(outfitData);

            m_thing.patternY = 1; // Decrease addons
            m_thing.layers = 1; // Decrease layers
            m_thing.spriteIndex = new Vector.<uint>(m_thing.getTotalSprites(), true);
            m_sprites = new Vector.<SpriteData>(m_thing.getTotalSprites(), true);
            setSpriteSheet(bitmap);
            return this;
        }

        public function getBitmap(layer:uint = 0, patternX:uint = 0, patternY:uint = 0, patternZ:uint = 0, frame:uint = 0):BitmapData
        {
            layer %= m_thing.layers;
            patternX %= m_thing.patternX;
            patternY %= m_thing.patternY;
            patternZ %= m_thing.patternZ;
            frame %= m_thing.frames;

            var rects:Vector.<Rect> = new Vector.<Rect>();
            var spriteSheet:BitmapData = getSpriteSheet(rects, 0);
            var index:int = m_thing.getTextureIndex(layer, patternX, patternY, patternZ, frame);
            var bitmap:BitmapData = null;

            if (index < rects.length) {
                var rect:Rect = rects[index];
                bitmap = new BitmapData(rect.width, rect.height, true, 0);
                RECTANGLE.setTo(rect.x, rect.y, rect.width, rect.height);
                POINT.setTo(0, 0);
                bitmap.copyPixels(spriteSheet, RECTANGLE, POINT);
            }

            spriteSheet.dispose();
            return bitmap;
        }

        public function clone():ThingData
        {
            var length:uint = m_sprites.length;

            var td:ThingData = new ThingData();
            td.m_obdVersion = m_obdVersion;
            td.m_clientVersion = m_clientVersion;
            td.m_thing = m_thing.clone();
            td.m_sprites = new Vector.<SpriteData>(length, true);

            for (var i:uint = 0; i < length; i++)
                td.m_sprites[i] = m_sprites[i].clone();

            return td;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function copyPixels(index:uint, bitmap:BitmapData, x:uint, y:uint):void
        {
            if (index < m_sprites.length)
            {
                var sd:SpriteData = m_sprites[index];
                if (sd && sd.pixels)
                {
                    var bmp:BitmapData = sd.getBitmap();
                    if (bmp)
                    {
                        sd.pixels.position = 0;
                        RECTANGLE.setTo(0, 0, bmp.width, bmp.height);
                        POINT.setTo(x, y);
                        bitmap.copyPixels(bmp, RECTANGLE, POINT, null, null, true);
                    }
                }
            }
        }

        private function setColor(canvas:BitmapData,
                                  grey:BitmapData,
                                  blend:BitmapData,
                                  rect:Rectangle,
                                  channel:uint,
                                  color:uint):void
        {
            POINT.setTo(0, 0);
            COLOR_TRANSFORM.redMultiplier = (color >> 16 & 0xFF) / 0xFF;
            COLOR_TRANSFORM.greenMultiplier = (color >> 8 & 0xFF) / 0xFF;
            COLOR_TRANSFORM.blueMultiplier = (color & 0xFF) / 0xFF;

            canvas.copyPixels(grey, rect, POINT);
            canvas.copyChannel(blend, rect, POINT, channel, BitmapDataChannel.ALPHA);
            canvas.colorTransform(rect, COLOR_TRANSFORM);
            grey.copyPixels(canvas, rect, POINT, null, null, true);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const RECTANGLE:Rectangle = new Rectangle(0, 0, 32, 32);
        private static const POINT:Point = new Point();
        private static const COLOR_TRANSFORM:ColorTransform = new ColorTransform();
        private static const MATRIX_FILTER:ColorMatrixFilter = new ColorMatrixFilter([1, -1,    0, 0,
                                                                                      0, -1,    1, 0,
                                                                                      0,  0,    1, 1,
                                                                                      0,  0, -255, 0,
                                                                                      0, -1,    1, 0]);

        public static function create(obdVersion:uint, clientVersion:uint, thing:ThingType, sprites:Vector.<SpriteData>):ThingData
        {
            if (obdVersion < OBDVersions.OBD_VERSION_1)
                throw new ArgumentError(StringUtil.format("Invalid OBD version {0}", obdVersion));

            if (clientVersion < 710)
                throw new ArgumentError(StringUtil.format("Invalid client version {0}", clientVersion));

            if (!thing)
                throw new NullArgumentError("thing");

            if (!sprites)
                throw new NullArgumentError("sprites");

            if (thing.spriteIndex.length != sprites.length)
                throw new ArgumentError("Invalid sprites length.");

            var thingData:ThingData = new ThingData();
            thingData.obdVersion = obdVersion;
            thingData.clientVersion = clientVersion;
            thingData.thing = thing;
            thingData.sprites = sprites;
            return thingData;
        }

        public static function createFromFile(file:File):ThingData
        {
            if (!file || file.extension != OTFormat.OBD || !file.exists)
                return null;

            var bytes:ByteArray = new ByteArray();
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            stream.readBytes(bytes, 0, stream.bytesAvailable);
            stream.close();
            return new OBDEncoder().decode(bytes);
        }
    }
}
