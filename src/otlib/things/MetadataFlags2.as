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

    /**
     * The ThingTypeFlags2 class defines the valid constant values for the client versions 7.40 - 7.50
     */
    public final class MetadataFlags2
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataFlags2()
        {
            throw new AbstractClassError(MetadataFlags2);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const GROUND:uint = 0x00;
        public static const ON_BOTTOM:uint = 0x01;
        public static const ON_TOP:uint = 0x02;
        public static const CONTAINER:uint = 0x03;
        public static const STACKABLE:uint = 0x04;
        public static const MULTI_USE:uint = 0x05;
        public static const FORCE_USE:uint = 0x06;
        public static const WRITABLE:uint = 0x07;
        public static const WRITABLE_ONCE:uint = 0x08;
        public static const FLUID_CONTAINER:uint = 0x09;
        public static const FLUID:uint = 0x0A;
        public static const UNPASSABLE:uint = 0x0B;
        public static const UNMOVEABLE:uint = 0x0C;
        public static const BLOCK_MISSILE:uint = 0x0D;
        public static const BLOCK_PATHFINDER:uint  = 0x0E;
        public static const PICKUPABLE:uint = 0x0F;
        public static const HAS_LIGHT:uint = 0x10;
        public static const FLOOR_CHANGE:uint = 0x11;
        public static const FULL_GROUND:uint = 0x12;
        public static const HAS_ELEVATION:uint = 0x13;
        public static const HAS_OFFSET:uint = 0x14;
        // Flag 0x15 ????
        public static const MINI_MAP:uint = 0x16;
        public static const ROTATABLE:uint = 0x17;
        public static const LYING_OBJECT:uint = 0x18;
        public static const HANGABLE:uint = 0x19;
        public static const VERTICAL:uint = 0x1A;
        public static const HORIZONTAL:uint = 0x1B;
        public static const ANIMATE_ALWAYS:uint = 0x1C;
        public static const LENS_HELP:uint = 0x1D;
        public static const WRAPPABLE:uint = 0x24;
        public static const UNWRAPPABLE:uint = 0x25;
        public static const TOP_EFFECT:uint = 0x26;
        public static const LAST_FLAG:uint = 0xFF;
    }
}
