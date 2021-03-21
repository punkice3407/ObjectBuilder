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
    import nail.errors.AbstractClassError;

    import otlib.things.ThingCategory;
    import otlib.things.ThingType;

    public final class ThingUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingUtils()
        {
            throw new AbstractClassError(ThingUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function createAlertThing(category:String):ThingType
        {
            var thing:ThingType = ThingType.create(0, category);
            if (thing) {
                var spriteIndex:Vector.<uint> = thing.spriteIndex;
                var length:uint = spriteIndex.length;
                for (var i:uint = 0; i < length; i++) {
                    spriteIndex[i] = 0xFFFFFFFF;
                }
            }
            return thing;
        }

        public static function isValid(thing:ThingType):Boolean
        {
            return thing && thing.width != 0 && thing.height != 0;
        }

        public static function isEmpty(type:ThingType):Boolean
        {
            var length:uint = type.spriteIndex ? type.spriteIndex.length : 0;
            if (length == 0)
                return true;

            if (length == 1 && type.spriteIndex[0] == 0)
                return true;

            if ((length == 12 && type.category == ThingCategory.OUTFIT) ||
                (length == 9 && type.category == ThingCategory.MISSILE)) {
                for (var i:int = length - 1; i >= 0; i--) {
                    if (type.spriteIndex[i] != 0)
                        return false;
                }
                return true;
            }

            // TODO check all properties.

            return false;
        }
    }
}
