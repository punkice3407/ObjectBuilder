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

package otlib.geom
{
    public class Position
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var x:int;
        public var y:int;
        public var z:int;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Position(x:int = 0, y:int = 0, z:int = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return "(x:" + this.x + ", y:" + this.y + ", z:" + this.z + ")";
        }

        public function equals(position:Position):Boolean
        {
            return (position != null && position.x == this.x && position.y == this.y && position.z == this.z);
        }

        public function isZero():Boolean
        {
            return (this.x == 0 && this.y == 0 && this.z == 0);
        }

        public function setTo(x:int, y:int, z:int):Position
        {
            this.x = x;
            this.y = y;
            this.z = z;
            return this;
        }

        public function setEmpty():Position
        {
            this.x = 0;
            this.y = 0;
            this.z = 0;
            return this;
        }

        public function setFrom(position:Position):Position
        {
            this.x = position.x;
            this.y = position.y;
            this.z = position.z;
            return this;
        }

        public function clone():Position
        {
            return new Position(this.x, this.y, this.z);
        }
    }
}
