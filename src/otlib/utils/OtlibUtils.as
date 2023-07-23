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
    import flash.net.FileFilter;

    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    import nail.errors.AbstractClassError;
    import otlib.things.ThingCategory;

    public final class OtlibUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OtlibUtils()
        {
            throw new AbstractClassError(OtlibUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function toLocale(category:String):String
        {
            var result:String = "";

            if (ThingCategory.getCategory(category)) {
                switch(category) {
                    case ThingCategory.ITEM:
                        result = ResourceManager.getInstance().getString("strings", "item");
                        break;
                    case ThingCategory.OUTFIT:
                        result = ResourceManager.getInstance().getString("strings", "outfit");
                        break;
                    case ThingCategory.EFFECT:
                        result = ResourceManager.getInstance().getString("strings", "effect");
                        break;
                    case ThingCategory.MISSILE:
                        result = ResourceManager.getInstance().getString("strings", "missile");
                        break;
                }
            }
            return result;
        }

        public static function hundredFloor(value:uint):uint
        {
            return (Math.floor(value / 100) * 100);
        }

        public static function createImagesFileFilter():Array
        {
            var resources:IResourceManager = ResourceManager.getInstance();
            return  [
                new FileFilter(resources.getString("strings", "allFormats"), "*.png;*.bmp;*.jpg;*.gif;"),
                new FileFilter("PNG (*.PNG)", "*.png"),
                new FileFilter("BMP (*.BMP)", "*.bmp"),
                new FileFilter("JPEG (*.JPG)", "*.jpg"),
                new FileFilter("CompuServe (*.GIF)", "*.gif") ];
        }
    }
}
