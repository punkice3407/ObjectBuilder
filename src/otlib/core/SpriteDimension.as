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

package otlib.core
{
    import nail.errors.NullArgumentError;

    public final class SpriteDimension
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var value:String;
        public var size:uint;
        public var dataSize:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteDimension()
        {
        }

        //----------------------------------------------------
        // METHODS
        //----------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return value;
        }

        public function serialize():XML
        {
            var xml:XML = <sprite/>;
            xml.@value = this.value;
            xml.@size = this.size;
            xml.@dataSize = this.dataSize;
            return xml;
        }

        public function unserialize(xml:XML):void
        {
            if (!xml)
                throw new NullArgumentError("xml");

            if (!xml.hasOwnProperty("@value"))
                throw new Error("Version.unserialize: Missing 'value' attribute.");

            if (!xml.hasOwnProperty("@size"))
                throw new Error("Version.unserialize: Missing 'size' attribute.");

            if (!xml.hasOwnProperty("@dataSize"))
                throw new Error("Version.unserialize: Missing 'dataSize' attribute.");

            this.value = String(xml.@value);
            this.size = uint(xml.@size);
            this.dataSize = uint(xml.@dataSize);
        }
    }
}
