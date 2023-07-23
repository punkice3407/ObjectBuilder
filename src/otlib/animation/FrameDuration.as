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

package otlib.animation
{
    import otlib.things.ThingCategory;
    import ob.core.IObjectBuilder;
    import mx.core.FlexGlobals;

    public class FrameDuration
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var minimum:uint;
        public var maximum:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get duration():uint
        {
            if (minimum == maximum)
            {
                return minimum;
            }

            return minimum + Math.round(Math.random() * (maximum - minimum));
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function FrameDuration(minimum:uint = 0, maximum:uint = 0)
        {
            if (minimum > maximum)
            {
                throw new ArgumentError("The minimum value may not be greater than the maximum value.");
            }

            this.minimum = minimum;
            this.maximum = maximum;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return "[FrameDuration minimum=" + minimum + ", maximum=" + maximum + "]";
        }

        public function equals(frameDuration:FrameDuration):Boolean
        {
            return (this.minimum == frameDuration.minimum && this.maximum == frameDuration.maximum);
        }

        public function clone():FrameDuration
        {
            return new FrameDuration(this.minimum, this.maximum);
        }
    }
}
