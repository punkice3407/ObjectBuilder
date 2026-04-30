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
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class BitmapUtils
    {
        /**
         * Crops a bitmap to the bounding box of its non-transparent pixels (alpha != 0).
         * Returns the input bitmap unchanged when it is already tight, fully transparent,
         * or fully opaque (e.g. fresh sprite encoded as solid magenta — alpha-based crop is a no-op).
         */
        public static function cropToTransparency(bmp:BitmapData):BitmapData
        {
            if (!bmp) return null;
            var bounds:Rectangle = bmp.getColorBoundsRect(0xFF000000, 0x00000000, false);
            if (bounds.width <= 0 || bounds.height <= 0)
                return bmp;
            if (bounds.width == bmp.width && bounds.height == bmp.height)
                return bmp;
            var cropped:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
            cropped.copyPixels(bmp, bounds, new Point(0, 0));
            return cropped;
        }
    }
}
