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

    public final class MarketCategory
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MarketCategory()
        {
            throw new AbstractClassError(MarketCategory);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const ARMORS:uint = 1;
        public static const AMULETS:uint = 2;
        public static const BOOTS:uint = 3;
        public static const CONTAINERS:uint = 4;
        public static const DECORATION:uint = 5;
        public static const FOOD:uint = 6;
        public static const HELMETS_HATS:uint = 7;
        public static const LEGS:uint = 8;
        public static const OTHERS:uint = 9;
        public static const POTIONS:uint = 10;
        public static const RINGS:uint = 11;
        public static const RUNES:uint = 12;
        public static const SHIELDS:uint = 13;
        public static const TOOLS:uint = 14;
        public static const VALUABLES:uint = 15;
        public static const AMMUNITION:uint = 16;
        public static const AXES:uint = 17;
        public static const CLUBS:uint = 18;
        public static const DISTANCE_WEAPONS:uint = 19;
        public static const SWORDS:uint = 20;
        public static const WANDS_RODS:uint = 21;
        public static const PREMIUM_SCROLLS:uint = 22;
        public static const CATEGORY_META_WEAPONS:uint = 255;
    }
}
