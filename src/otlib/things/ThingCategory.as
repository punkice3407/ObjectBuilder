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
    import nail.errors.AbstractClassError;
    import nail.utils.StringUtil;
    import nail.utils.isNullOrEmpty;

    public final class ThingCategory
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingCategory(value:String)
        {
            throw new AbstractClassError(ThingCategory);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const ITEM:String = "item";
        public static const OUTFIT:String = "outfit";
        public static const EFFECT:String = "effect";
        public static const MISSILE:String = "missile";

        public static function isValid(category:String):Boolean
        {
            return (category == ITEM || category == OUTFIT || category == EFFECT || category == MISSILE);
        }

        public static function getCategory(value:String):String
        {
            if (!isNullOrEmpty(value)) {
                value = StringUtil.toKeyString(value);
                switch (value) {
                    case "item":
                        return ITEM;
                    case "outfit":
                        return OUTFIT;
                    case "effect":
                        return EFFECT;
                    case "missile":
                        return MISSILE;
                }
            }
            return null;
        }

        public static function getCategoryByValue(value:uint):String
        {
            switch (value) {
                case 1:
                    return ITEM;
                case 2:
                    return OUTFIT;
                case 3:
                    return EFFECT;
                case 4:
                    return MISSILE;
            }
            return null;
        }

        public static function getValue(category:String):uint
        {
            if (!isNullOrEmpty(category)) {
                switch (category) {
                    case "item":
                        return 1;
                    case "outfit":
                        return 2;
                    case "effect":
                        return 3;
                    case "missile":
                        return 4;
                }
            }
            return 0;
        }
    }
}
