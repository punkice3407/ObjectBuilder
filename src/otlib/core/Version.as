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
    import nail.utils.StringUtil;

    public final class Version
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var value:uint;
        public var valueStr:String;
        public var datSignature:uint;
        public var sprSignature:uint;
        public var otbVersion:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Version()
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
            return valueStr;
        }

        public function equals(version:Version):Boolean
        {
            if (version &&
                version.value == this.value &&
                version.valueStr == this.valueStr &&
                version.datSignature == this.datSignature &&
                version.sprSignature == this.sprSignature &&
                version.otbVersion == this.otbVersion) {
                return true;
            }
            return false;
        }

        public function clone():Version
        {
            var version:Version = new Version();
            version.value = this.value;
            version.valueStr = this.valueStr;
            version.datSignature = this.datSignature;
            version.sprSignature = this.sprSignature;
            version.otbVersion = this.otbVersion;
            return version;
        }

        public function serialize():XML
        {
            var xml:XML = <version/>;
            xml.@value = this.value;
            xml.@string = this.valueStr;
            xml.@dat = this.datSignature.toString(16).toUpperCase();
            xml.@spr = sprSignature.toString(16).toUpperCase();
            xml.@otb = this.otbVersion;
            return xml;
        }

        public function unserialize(xml:XML):void
        {
            if (!xml)
                throw new NullArgumentError("xml");

            if (!xml.hasOwnProperty("@value"))
                throw new Error("Version.unserialize: Missing 'value' attribute.");

            if (!xml.hasOwnProperty("@string"))
                throw new Error("Version.unserialize: Missing 'string' attribute.");

            if (!xml.hasOwnProperty("@dat"))
                throw new Error("Version.unserialize: Missing 'dat' attribute.");

            if (!xml.hasOwnProperty("@spr"))
                throw new Error("Version.unserialize: Missing 'spr' attribute.");

            if (!xml.hasOwnProperty("@otb"))
                throw new Error("Version.unserialize: Missing 'otb' attribute.");

            this.value = uint(xml.@value);
            this.valueStr = String(xml.@string);
            this.datSignature = uint(StringUtil.format("0x{0}", xml.@dat));
            this.sprSignature = uint(StringUtil.format("0x{0}", xml.@spr));
            this.otbVersion = uint(xml.@otb);
        }
    }
}
