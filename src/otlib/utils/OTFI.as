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
    import flash.filesystem.File;

    import nail.errors.NullArgumentError;

    import otlib.otml.OTMLDocument;
    import otlib.otml.OTMLNode;

    public class OTFI
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var extended:Boolean;
        public var transparency:Boolean;
        public var improvedAnimations:Boolean;
        public var frameGroups:Boolean;
        public var metadataFile:String;
        public var spritesFile:String;
        public var spriteSize:uint;
        public var spriteDataSize:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OTFI(extended:Boolean = false,
                             transparency:Boolean = false,
                             improvedAnimations:Boolean = false,
                             frameGroups:Boolean = false,
                             metadataFile:String = null,
                             spritesFile:String = null,
                             spriteSize:uint = 0,
                             spriteDataSize:uint = 0)
        {
            this.extended = extended;
            this.transparency = transparency;
            this.improvedAnimations = improvedAnimations;
            this.frameGroups = frameGroups;
            this.metadataFile = metadataFile;
            this.spritesFile = spritesFile;
            this.spriteSize = spriteSize;
            this.spriteDataSize = spriteDataSize;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return "[OTFI extended=" + extended +
                   ", transparency=" + transparency +
                   ", improvedAnimations=" + improvedAnimations +
                   ", frameGroups=" + frameGroups + "]" +
                   ", spriteSize=" + spriteSize + "]" +
                   ", spriteDataSize=" + spriteDataSize + "]";
        }

        public function load(file:File):Boolean
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!file.exists || file.extension != "otfi") return false;

            var doc:OTMLDocument = new OTMLDocument();
            if (!doc.load(file) || doc.length == 0 || !doc.hasChild("DatSpr")) return false;

            var node:OTMLNode = doc.getChild("DatSpr");
            extended = node.booleanAt("extended");
            transparency = node.booleanAt("transparency");
            improvedAnimations = node.booleanAt("frame-durations");
            frameGroups = node.booleanAt("frame-groups");
            metadataFile = node.valueAt("metadata-file");
            spritesFile = node.valueAt("sprites-file");

            if (node.getChild("sprite-size"))
                spriteSize = node.readAt("sprite-size", uint);

            if (node.getChild("sprite-data-size"))
                spriteDataSize = node.readAt("sprite-data-size", uint);

            return true;
        }

        public function save(file:File):Boolean
        {
            if (!file)
                throw new NullArgumentError("file");

            if (file.isDirectory) return false;

            var node:OTMLNode = new OTMLNode();
            node.tag = "DatSpr";
            node.writeAt("extended", extended);
            node.writeAt("transparency", transparency);
            node.writeAt("frame-durations", improvedAnimations);
            node.writeAt("frame-groups", frameGroups);

            if (metadataFile)
                node.writeAt("metadata-file", metadataFile);

            if (spritesFile)
                node.writeAt("sprites-file", spritesFile);

            if (spriteSize)
                node.writeAt("sprite-size", spriteSize);

            if (spriteDataSize)
                node.writeAt("sprite-data-size", spriteDataSize);

            var doc:OTMLDocument = OTMLDocument.create();
            doc.addChild(node);
            return doc.save(file);
        }
    }
}
