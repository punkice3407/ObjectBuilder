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

package otlib.otml
{
    import com.mignari.errors.NullArgumentError;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    public class OTMLDocument extends OTMLNode
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var text:String;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OTMLDocument(text:String = "")
        {
            this.text = text;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toOTMLString():String
        {
            return OTMLEmitter.emitNode(this.getChildAt(0), 0);
        }

        public function load(file:File):Boolean
        {
            if (!file)
            {
                throw new NullArgumentError("file");
            }

            if (!file.exists)
            {
                return false;
            }

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            this.text = stream.readMultiByte(stream.bytesAvailable, "iso-8859-1");
            stream.close();

            this.source = file.nativePath;

            var parser:OTMLParser = new OTMLParser(this);
            parser.parse();
            return true;
        }

        public function save(file:File):Boolean
        {
            if (!file)
            {
                throw new NullArgumentError("file");
            }

            if (file.isDirectory)
            {
                return false;
            }

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes(OTMLEmitter.emitNode(this));
            stream.close();
            return true;
        }

        override public function toString():String
        {
            return "[OTMLDocument tag='"+tag+"', value='"+value+"']";
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        /**
         * Creates a new OTML document for filling it with nodes.
         */
        static public function create():OTMLDocument
        {
            var doc:OTMLDocument = new OTMLDocument();
            doc.tag = "doc";
            return doc;
        }

        /**
         * Parse OTML from a file
         */
        static public function parse(file:File):OTMLDocument
        {
            if (!file || !file.exists)
            {
                return null;
            }

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var text:String = stream.readMultiByte(stream.bytesAvailable, "iso-8859-1");
            stream.close();

            var doc:OTMLDocument = new OTMLDocument(text);
            doc.source = file.nativePath;

            var parser:OTMLParser = new OTMLParser(doc);
            parser.parse();
            return doc;
        }
    }
}
