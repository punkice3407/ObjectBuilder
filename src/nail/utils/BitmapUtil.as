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

package nail.utils
{
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import nail.errors.AbstractClassError;

    public final class BitmapUtil
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function BitmapUtil()
        {
            throw new AbstractClassError(BitmapUtil);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function to32bits(bitmap:BitmapData):BitmapData
        {
            if (!bitmap)
                return null;

            if (bitmap.transparent)
                return bitmap;

            var bmp:BitmapData = new BitmapData(bitmap.width, bitmap.height, true, 0);
            bmp.copyPixels(bitmap, bitmap.rect, new Point());
            return bmp;
        }

        public static function to24bits(bitmap:BitmapData, backgroundColor:uint):BitmapData
        {
            if (!bitmap)
                return null;

            if (!bitmap.transparent)
                return bitmap;

            var bmp:BitmapData = new BitmapData(bitmap.width, bitmap.height, false, backgroundColor);
            bmp.copyPixels(bitmap, bitmap.rect, new Point());
            return bmp;
        }

        public static function hasColor(bitmap:BitmapData, color:uint):Boolean
        {
            var rect:Rectangle = bitmap.getColorBoundsRect(color, color, true);
            if (rect.width > 0 && rect.height > 0)
                return true;

            return false;
        }

        public static function replaceColor(bitmap:BitmapData, oldColor:uint, newColor:uint):void
        {
            if (hasColor(bitmap, oldColor))
                bitmap.threshold(bitmap, bitmap.rect, new Point(), "==", oldColor, newColor, 0xFFFFFFFF, true);
        }

        public static function rotate(bitmap:BitmapData, degree:int = 0):BitmapData
        {
            if (!bitmap)
                return null;

            var newBitmap:BitmapData;
            var matrix:Matrix = new Matrix();
            matrix.rotate(deg2rad( degree ));

            if (degree == 90)
            {
                newBitmap = new BitmapData(bitmap.height, bitmap.width, bitmap.transparent, 0);
                matrix.translate(bitmap.height, 0);
            }
            else if (degree == -90 || degree == 270)
            {
                newBitmap = new BitmapData(bitmap.height, bitmap.width, bitmap.transparent, 0);
                matrix.translate(0, bitmap.width);
            }
            else if (degree == 180)
            {
                newBitmap = new BitmapData(bitmap.width, bitmap.height, bitmap.transparent, 0);
                matrix.translate(bitmap.width, bitmap.height);
            }

            newBitmap.draw(bitmap, matrix);

            return newBitmap;
        }

        public static function flip(bitmap:BitmapData, horizontal:Boolean, vertical:Boolean):BitmapData
        {
            if (!bitmap)
                return null;

            if (horizontal || vertical)
            {
                var bmp:BitmapData;

                if (horizontal)
                {
                    var flipHorizontalMatrix:Matrix = new Matrix();
                    flipHorizontalMatrix.scale(-1, 1);
                    flipHorizontalMatrix.translate(bitmap.width, 0);

                    bmp = new BitmapData(bitmap.width, bitmap.height, bitmap.transparent, 0);
                    bmp.draw(bitmap, flipHorizontalMatrix);
                    bitmap = bmp;
                }

                if (vertical)
                {
                    var flipVerticalMatrix:Matrix = new Matrix();
                    flipVerticalMatrix.scale(1, -1);
                    flipVerticalMatrix.translate(0, bitmap.height);

                    bmp = new BitmapData(bitmap.width, bitmap.height, bitmap.transparent, 0);
                    bmp.draw(bitmap, flipVerticalMatrix);
                    bitmap = bmp;
                }
            }

            return bitmap;
        }
    }
}
