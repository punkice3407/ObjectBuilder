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
    public class OutfitData
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var head:uint;
        public var body:uint;
        public var legs:uint;
        public var feet:uint;
        public var addons:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OutfitData(head:uint = 0, body:uint = 0, legs:uint = 0, feet:uint = 0, addons:uint = 0)
        {
            this.head = head;
            this.body = body;
            this.legs = legs;
            this.feet = feet;
            this.addons = addons;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function setTo(head:uint = 0, body:uint = 0, legs:uint = 0, feet:uint = 0, addons:uint = 0):OutfitData
        {
            this.head = head;
            this.body = body;
            this.legs = legs;
            this.feet = feet;
            this.addons = addons;
            return this;
        }

        public function setFrom(data:OutfitData):OutfitData
        {
            this.head = data.head;
            this.body = data.body;
            this.legs = data.legs;
            this.feet = data.feet;
            this.addons = data.addons;
            return this;
        }

        public function clone():OutfitData
        {
            return new OutfitData(this.head, this.body, this.legs, this.feet, this.addons);
        }
    }
}
