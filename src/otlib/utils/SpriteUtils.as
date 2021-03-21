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

package otlib.utils
{
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import nail.errors.AbstractClassError;
    import nail.utils.BitmapUtil;

    import otlib.sprites.Sprite;

    public final class SpriteUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteUtils()
        {
            throw new AbstractClassError(SpriteUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const RECTANGLE:Rectangle = new Rectangle(0, 0, Sprite.DEFAULT_SIZE, Sprite.DEFAULT_SIZE);
        private static const POINT:Point = new Point();

        public static function fillBackground(sprite:BitmapData):BitmapData
        {
            var bitmap:BitmapData = new BitmapData(Sprite.DEFAULT_SIZE, Sprite.DEFAULT_SIZE, false, 0xFF00FF);
            bitmap.copyPixels(sprite, RECTANGLE, POINT, null, null, true);
            return bitmap;
        }

        public static function removeMagenta(sprite:BitmapData):BitmapData
        {
            // Transform bitmap 24 to 32 bits
            if (!sprite.transparent) {
                sprite = BitmapUtil.to32bits(sprite);
            }

            // Replace magenta to transparent.
            BitmapUtil.replaceColor(sprite, 0xFFFF00FF, 0x00FF00FF);
            return sprite;
        }

        public static function isEmpty(sprite:BitmapData):Boolean
        {
            var bounds:Rectangle = sprite.getColorBoundsRect(0xFF000000, 0x00000000, false);
            if (bounds.width == 0 && bounds.height == 0) return true;
            return false;
        }
    }
}
