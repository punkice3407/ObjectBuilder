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

package otlib.utils
{
    import flash.display.BitmapData;
    import flash.utils.ByteArray;

    import otlib.animation.FrameGroup;
    import otlib.components.IListObject;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingType;

    public class ThingListItem implements IListObject
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var thing:ThingType;
        public var frameGroup:FrameGroup;
        public var pixels:ByteArray;

        private var _bitmap:BitmapData;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get id():uint { return thing ? thing.id : 0; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingListItem()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function getBitmap(backgroundColor:uint = 0x00000000):BitmapData
        {
            if (pixels && thing && frameGroup && !_bitmap) {
                pixels.position = 0;
                _bitmap = new BitmapData(Math.max(SpriteExtent.DEFAULT_SIZE, frameGroup.width * SpriteExtent.DEFAULT_SIZE), Math.max(SpriteExtent.DEFAULT_SIZE, frameGroup.height * SpriteExtent.DEFAULT_SIZE), true, backgroundColor);
                if (frameGroup.width != 0 &&
                    frameGroup.height != 0 &&
                    pixels.length == (_bitmap.width * _bitmap.height * 4)) {
                    _bitmap.setPixels(_bitmap.rect, pixels);
                }
            }
            return _bitmap;
        }
    }
}
