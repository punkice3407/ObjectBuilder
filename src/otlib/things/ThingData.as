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
    import flash.utils.Dictionary;

    import nail.errors.NullArgumentError;
    import nail.errors.NullOrEmptyArgumentError;
    import nail.utils.StringUtil;
    import nail.utils.isNullOrEmpty;

    import otlib.animation.FrameGroup;
    import otlib.geom.Rect;
    import otlib.geom.Size;
    import otlib.obd.OBDEncoder;
    import otlib.obd.OBDVersions;
    import otlib.sprites.SpriteData;
    import otlib.things.FrameGroupType;
    import otlib.utils.ColorUtils;
    import otlib.utils.OTFormat;
    import otlib.utils.OutfitData;
    import otlib.utils.SpriteUtils;
    import otlib.utils.SpriteExtent;
    import ob.settings.ObjectBuilderSettings;

    public class ThingData
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_obdVersion:uint;
        private var m_clientVersion:uint;
        private var m_thing:ThingType;
        private var m_sprites:Dictionary;
        private var _rect:Rectangle;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get id():uint { return m_thing.id; }
        public function get category():String { return m_thing.category; }

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

        public function get sprites():Dictionary { return m_sprites; }
        public function set sprites(value:Dictionary):void
        {
            if (isNullOrEmpty(value))
                throw new NullOrEmptyArgumentError("sprites");

            var empty:Boolean = true;
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var spritesValue:Vector.<SpriteData> = value[groupType];
                if(!spritesValue)
                    continue;

                var length:uint = spritesValue.length;
                for (var i:uint = 0; i < length; i++)
                {
                    if (spritesValue[i] == null)
                        throw new ArgumentError("Invalid sprite list");
                }

                empty = false;
            }

            if(empty)
                throw new ArgumentError("Invalid sprite list");

            m_sprites = value;
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingData()
        {
            m_sprites = new Dictionary();
            _rect = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function getFrameGroup(groupType:uint):FrameGroup
        {
			return m_thing.getFrameGroup(groupType);
        }

        public function getSpriteSheet(frameGroup:FrameGroup, textureIndex:Vector.<Rect> = null, backgroundColor:uint = 0xFFFF00FF):BitmapData
        {
            // Measures and creates bitmap
            var size:uint = SpriteExtent.DEFAULT_SIZE;
            var totalX:int = frameGroup.getTotalX();
            var totalY:int = frameGroup.getTotalY();
            var bitmapWidth:Number = (totalX * frameGroup.width) * size;
            var bitmapHeight:Number = (totalY * frameGroup.height) * size;
            var pixelsWidth:int = frameGroup.width * size;
            var pixelsHeight:int = frameGroup.height * size;
            var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, backgroundColor);

            if (textureIndex)
                textureIndex.length = frameGroup.getTotalTextures();

            for (var f:uint = 0; f < frameGroup.frames; f++)
            {
                for (var z:uint = 0; z < frameGroup.patternZ; z++)
                {
                    for (var y:uint = 0; y < frameGroup.patternY; y++)
                    {
                        for (var x:uint = 0; x < frameGroup.patternX; x++)
                        {
                            for (var l:uint = 0; l < frameGroup.layers; l++)
                            {
                                var index:uint = frameGroup.getTextureIndex(l, x, y, z, f);
                                var fx:int = (index % totalX) * pixelsWidth;
                                var fy:int = Math.floor(index / totalX) * pixelsHeight;

                                if (textureIndex)
                                    textureIndex[index] = new Rect(fx, fy, pixelsWidth, pixelsHeight);

                                for (var w:uint = 0; w < frameGroup.width; w++)
                                {
                                    for (var h:uint = 0; h < frameGroup.height; h++)
                                    {
                                        index = frameGroup.getSpriteIndex(w, h, l, x, y, z, f);
                                        var px:int = ((frameGroup.width - w - 1) * size);
                                        var py:int = ((frameGroup.height - h - 1) * size);
                                        copyPixels(frameGroup.type, index, bitmap, px + fx, py + fy);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return bitmap;
        }

        public function getTotalSpriteSheet(textureIndex:Vector.<Rect> = null, backgroundColor:uint = 0xFFFF00FF):BitmapData
        {
            // Measures and creates bitmap
            var size:uint = SpriteExtent.DEFAULT_SIZE;
            var totalX:int = 0;
            var totalY:int = 0;
            var totalGroupY:Array = [];
            var width:uint = 0;
            var height:uint = 0;
            var _totalX:int;
            var groupType:uint;
            var frameGroup:FrameGroup;

            for (groupType = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                frameGroup = getFrameGroup(groupType);
                if(!frameGroup)
                    continue;

                _totalX = frameGroup.getTotalX();
                if(totalX < _totalX)
                    totalX = _totalX;

                totalGroupY[groupType] = frameGroup.getTotalY();
                totalY += totalGroupY[groupType];

                if(width < frameGroup.width)
                    width = frameGroup.width;

                if(height < frameGroup.height)
                    height = frameGroup.height;
            }

            var bitmapWidth:Number = (totalX * width) * size;
            var bitmapHeight:Number = (totalY * height) * size;
            var pixelsHeight:int = height * size;
            var pixelsWidth:int = width * size;
            var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, backgroundColor);

            var defaultY:uint = 0;
            for (groupType = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                frameGroup = getFrameGroup(groupType);
                if(!frameGroup)
                    continue;

                if (textureIndex)
                    textureIndex.length = frameGroup.getTotalTextures();

                for (var f:uint = 0; f < frameGroup.frames; f++)
                {
                    for (var z:uint = 0; z < frameGroup.patternZ; z++)
                    {
                        for (var y:uint = 0; y < frameGroup.patternY; y++)
                        {
                            for (var x:uint = 0; x < frameGroup.patternX; x++)
                            {
                                for (var l:uint = 0; l < frameGroup.layers; l++)
                                {
                                    var index:uint = frameGroup.getTextureIndex(l, x, y, z, f);
                                    var fx:int = (index % totalX) * pixelsWidth;
                                    var fy:int = Math.floor(index / totalX) * pixelsHeight;

                                    if(frameGroup.type == FrameGroupType.WALKING)
                                        fy += totalGroupY[FrameGroupType.DEFAULT] * pixelsHeight;

                                    if (textureIndex)
                                        textureIndex[index] = new Rect(fx, fy, pixelsWidth, pixelsHeight);

                                    for (var w:uint = 0; w < frameGroup.width; w++)
                                    {
                                        for (var h:uint = 0; h < frameGroup.height; h++)
                                        {
                                            index = frameGroup.getSpriteIndex(w, h, l, x, y, z, f);
                                            var px:int = ((frameGroup.width - w - 1) * size);
                                            var py:int = ((frameGroup.height - h - 1) * size);
                                            copyPixels(frameGroup.type, index, bitmap, px + fx, py + fy);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return bitmap;
        }

        public function getColoredSpriteSheet(frameGroup:FrameGroup, outfitData:OutfitData):BitmapData
        {
            if (!outfitData)
                throw new NullArgumentError("outfitData");

            var textureRectList:Vector.<Rect> = new Vector.<Rect>();
            var spriteSheet:BitmapData = getSpriteSheet(frameGroup, textureRectList, 0x00000000);
            spriteSheet = SpriteUtils.removeMagenta(spriteSheet);

            if (frameGroup.layers < 2)
                return spriteSheet;

            var size:uint = SpriteExtent.DEFAULT_SIZE;
            var totalX:int = frameGroup.getTotalX();
            var totalY:int = frameGroup.height;
            var pixelsWidth:int  = frameGroup.width * size;
            var pixelsHeight:int = frameGroup.height * size;
            var bitmapWidth:uint = frameGroup.patternZ * frameGroup.patternX * pixelsWidth;
            var bitmapHeight:uint = frameGroup.frames * pixelsHeight;
            var grayBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var blendBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var colorBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            var bitmapRect:Rectangle = bitmap.rect;
            var rectList:Vector.<Rect> = new Vector.<Rect>(frameGroup.getTotalTextures(), true);
            var index:uint;
            var f:uint;
            var x:uint;
            var y:uint;
            var z:uint;

            for (f = 0; f < frameGroup.frames; f++)
            {
                for (z = 0; z < frameGroup.patternZ; z++)
                {
                    for (x = 0; x < frameGroup.patternX; x++)
                    {
                        index = (((f % frameGroup.frames * frameGroup.patternZ + z) * frameGroup.patternY + y) * frameGroup.patternX + x) * frameGroup.layers;
                        rectList[index] = new Rect((z * frameGroup.patternX + x) * pixelsWidth, f * pixelsHeight, pixelsWidth, pixelsHeight);
                    }
                }
            }

            for (y = 0; y < frameGroup.patternY; y++) {
                if (y == 0 || (outfitData.addons & 1 << (y - 1)) != 0) {
                    for (f = 0; f < frameGroup.frames; f++) {
                        for (z = 0; z < frameGroup.patternZ; z++) {
                            for (x = 0; x < frameGroup.patternX; x++) {
                                var i:uint = (((f % frameGroup.frames * frameGroup.patternZ + z) * frameGroup.patternY + y) * frameGroup.patternX + x) * frameGroup.layers;
                                var rect:Rect = textureRectList[i];
                                _rect.setTo(rect.x, rect.y, rect.width, rect.height);

                                index = (((f * frameGroup.patternZ + z) * frameGroup.patternY) * frameGroup.patternX + x) * frameGroup.layers;
                                rect = rectList[index];
                                POINT.setTo(rect.x, rect.y);
                                grayBitmap.copyPixels(spriteSheet, _rect, POINT);

                                i++;
                                rect = textureRectList[i];
                                _rect.setTo(rect.x, rect.y, rect.width, rect.height);
                                blendBitmap.copyPixels(spriteSheet, _rect, POINT);
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

        public function setSpriteSheet(frameGroup:FrameGroup, bitmap:BitmapData):void
        {
            if (!bitmap)
                throw new NullArgumentError("bitmap");

            var ss:Size = frameGroup.getSpriteSheetSize();
            if (bitmap.width != ss.width ||
                bitmap.height != ss.height) return;

            bitmap = SpriteUtils.removeMagenta(bitmap);

            var size:uint = SpriteExtent.DEFAULT_SIZE;
            var totalX:int = frameGroup.getTotalX();
            var pixelsWidth:int  = frameGroup.width * size;
            var pixelsHeight:int = frameGroup.height * size;

            POINT.setTo(0, 0);

            for (var f:uint = 0; f < frameGroup.frames; f++)
            {
                for (var z:uint = 0; z < frameGroup.patternZ; z++)
                {
                    for (var y:uint = 0; y < frameGroup.patternY; y++)
                    {
                        for (var x:uint = 0; x < frameGroup.patternX; x++)
                        {
                            for (var l:uint = 0; l < frameGroup.layers; l++)
                            {
                                var index:uint = frameGroup.getTextureIndex(l, x, y, z, f);
                                var fx:int = (index % totalX) * pixelsWidth;
                                var fy:int = Math.floor(index / totalX) * pixelsHeight;

                                for (var w:uint = 0; w < frameGroup.width; w++)
                                {
                                    for (var h:uint = 0; h < frameGroup.height; h++)
                                    {
                                        index = frameGroup.getSpriteIndex(w, h, l, x, y, z, f);
                                        var px:int = ((frameGroup.width - w - 1) * size);
                                        var py:int = ((frameGroup.height - h - 1) * size);

                                        _rect.setTo(px + fx, py + fy, size, size);
                                        var bmp:BitmapData = new BitmapData(size, size, true, 0x00000000);
                                        bmp.copyPixels(bitmap, _rect, POINT);

                                        var sd:SpriteData = new SpriteData();
                                        sd.pixels = bmp.getPixels(bmp.rect);
                                        sd.id = uint.MAX_VALUE;

                                        m_sprites[frameGroup.type][index] = sd;
										frameGroup.spriteIndex[index] = sd.id;
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

			for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
			{
				var frameGroup:FrameGroup = getFrameGroup(groupType);
				if(!frameGroup)
					continue;

				var bitmap:BitmapData = getColoredSpriteSheet(frameGroup, outfitData);
				setSpriteSheet(frameGroup, bitmap);
			}

			return this;
		}

        public function getBitmap(frameGroup:FrameGroup, layer:uint = 0, patternX:uint = 0, patternY:uint = 0, patternZ:uint = 0, frame:uint = 0):BitmapData
        {
            layer %= frameGroup.layers;
            patternX %= frameGroup.patternX;
            patternY %= frameGroup.patternY;
            patternZ %= frameGroup.patternZ;
            frame %= frameGroup.frames;

            var rects:Vector.<Rect> = new Vector.<Rect>();
            var spriteSheet:BitmapData = getSpriteSheet(frameGroup, rects, 0);
            var index:int = frameGroup.getTextureIndex(layer, patternX, patternY, patternZ, frame);
            var bitmap:BitmapData = null;

            if (index < rects.length) {
                var rect:Rect = rects[index];
                bitmap = new BitmapData(rect.width, rect.height, true, 0);
                _rect.setTo(rect.x, rect.y, rect.width, rect.height);
                POINT.setTo(0, 0);
                bitmap.copyPixels(spriteSheet, _rect, POINT);
            }

            spriteSheet.dispose();
            return bitmap;
        }

        public function clone():ThingData
        {
            var td:ThingData = new ThingData();
            td.m_obdVersion = m_obdVersion;
            td.m_clientVersion = m_clientVersion;
            td.m_thing = m_thing.clone();

            td.m_sprites = new Dictionary();
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                if(!m_sprites[groupType])
                    continue;

                var length:uint = m_sprites[groupType].length;
                td.m_sprites[groupType] = new Vector.<SpriteData>(length, true);

                for (var i:uint = 0; i < length; i++)
                    td.m_sprites[groupType][i] = m_sprites[groupType][i].clone();

            }

            return td;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function copyPixels(groupType:uint, index:uint, bitmap:BitmapData, x:uint, y:uint):void
        {
            if(!m_sprites[groupType])
                return;

            if (index < m_sprites[groupType].length)
            {
                var sd:SpriteData = m_sprites[groupType][index];
                if (sd && sd.pixels)
                {
                    var bmp:BitmapData = sd.getBitmap();
                    if (bmp)
                    {
                        sd.pixels.position = 0;
                        _rect.setTo(0, 0, bmp.width, bmp.height);
                        POINT.setTo(x, y);
                        bitmap.copyPixels(bmp, _rect, POINT, null, null, true);
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

        public function addFrameGroupSprites():void
        {
            var spritesGroup:Dictionary = new Dictionary();
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = m_thing.getFrameGroup(groupType);
                if(!frameGroup)
                    continue;

                var _length:uint = frameGroup.spriteIndex.length;
                spritesGroup[groupType] = new Vector.<SpriteData>(_length, true);

                for each (var spriteData:SpriteData in m_sprites[FrameGroupType.DEFAULT])
                {
                    for (var index:uint = 0; index < _length; index++)
                    {
                        var spriteIndex:uint = frameGroup.spriteIndex[index];
                        if(spriteIndex == spriteData.id)
                            spritesGroup[groupType][index] = spriteData.clone();
                    }
                }
            }

            m_sprites = spritesGroup;
        }

        public function removeFrameGroupSprites():void
        {
            var spritesGroup:Dictionary = new Dictionary();
            var frameGroup:FrameGroup = m_thing.getFrameGroup(FrameGroupType.DEFAULT);
            if(!frameGroup)
                return;

            var _length:uint = frameGroup.spriteIndex.length;
            spritesGroup[FrameGroupType.DEFAULT] = new Vector.<SpriteData>(_length, true);

            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                for each (var spriteData:SpriteData in m_sprites[groupType])
                {
                    for (var index:uint = 0; index < _length; index++)
                    {
                        if(frameGroup.spriteIndex[index] == spriteData.id)
                            spritesGroup[FrameGroupType.DEFAULT][index] = spriteData.clone();
                    }
                }
            }

            m_sprites = spritesGroup;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const POINT:Point = new Point();
        private static const COLOR_TRANSFORM:ColorTransform = new ColorTransform();
        private static const MATRIX_FILTER:ColorMatrixFilter = new ColorMatrixFilter([1, -1,    0, 0,
                                                                                      0, -1,    1, 0,
                                                                                      0,  0,    1, 1,
                                                                                      0,  0, -255, 0,
                                                                                      0, -1,    1, 0]);

        public static function create(obdVersion:uint, clientVersion:uint, thing:ThingType, sprites:Dictionary):ThingData
        {
            if (obdVersion < OBDVersions.OBD_VERSION_1)
                throw new ArgumentError(StringUtil.format("Invalid OBD version {0}", obdVersion));

            if (clientVersion < 710)
                throw new ArgumentError(StringUtil.format("Invalid client version {0}", clientVersion));

            if (!thing)
                throw new NullArgumentError("thing");

            if (!sprites)
                throw new NullArgumentError("sprites");

            var spritesLength:uint = 0;
            var spriteIndexLength:uint = 0;
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType)
                if(!frameGroup)
                    continue;

                spriteIndexLength += frameGroup.spriteIndex.length;
                spritesLength += sprites[groupType].length
            }

            if (spriteIndexLength != spritesLength)
                throw new ArgumentError("Invalid sprites length.");

            var thingData:ThingData = new ThingData();
            thingData.obdVersion = obdVersion;
            thingData.clientVersion = clientVersion;
            thingData.thing = thing;
            thingData.sprites = sprites;
            return thingData;
        }

        public static function createFromFile(file:File, settings:ObjectBuilderSettings):ThingData
        {
            if (!file || file.extension != OTFormat.OBD || !file.exists || !settings)
                return null;

            var bytes:ByteArray = new ByteArray();
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            stream.readBytes(bytes, 0, stream.bytesAvailable);
            stream.close();
            return new OBDEncoder(settings).decode(bytes);
        }
    }
}
