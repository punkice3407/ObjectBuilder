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

package com.mignari.animator
{
    import flash.display.BitmapData;

    import otlib.components.IListObject;
    import otlib.animation.FrameDuration;

    public class Frame implements IListObject
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var opacity:Number;
        public var bitmap:BitmapData;
        public var duration:FrameDuration;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get id():uint { return uint.MAX_VALUE; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Frame(bitmap:BitmapData = null, duration:FrameDuration = null)
        {
            this.opacity = 1.0;
            this.bitmap = bitmap;
            this.duration = duration;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function getBitmap(backgroundColor:uint = 0):BitmapData
        {
            return bitmap;
        }

        public function clone():Frame
        {
            var clone:Frame = new Frame();
            clone.opacity = this.opacity;
            clone.bitmap = this.bitmap ? this.bitmap.clone() : null;
            clone.duration = this.duration ? this.duration.clone() : null;
            return clone;
        }
    }
}
