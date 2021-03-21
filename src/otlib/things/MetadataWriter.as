/*
*  Copyright (c) 2014-2019 Object Builder <https://github.com/ottools/ObjectBuilder>
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
    import com.mignari.errors.NotImplementedMethodError;

    import flash.filesystem.FileStream;
    import flash.utils.Endian;

    public class MetadataWriter extends FileStream implements IMetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter()
        {
            endian = Endian.LITTLE_ENDIAN;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public Override
        //--------------------------------------

        public function writeProperties(type:ThingType):Boolean
        {
            throw new NotImplementedMethodError();
        }

        public function writeItemProperties(type:ThingType):Boolean
        {
            throw new NotImplementedMethodError();
        }

        public function writeTexturePatterns(type:ThingType, extended:Boolean, frameDurations:Boolean):Boolean
        {
            var i:uint;

            writeByte(type.width);  // Write width
            writeByte(type.height); // Write height

            if (type.width > 1 || type.height > 1) {
                writeByte(type.exactSize); // Write exact size
            }

            writeByte(type.layers);   // Write layers
            writeByte(type.patternX); // Write pattern X
            writeByte(type.patternY); // Write pattern Y
            writeByte(type.patternZ); // Write pattern Z
            writeByte(type.frames);   // Write frames

            if (frameDurations && type.isAnimation) {
                writeByte(type.animationMode);   // Write animation type
                writeInt(type.loopCount);        // Write loop count
                writeByte(type.startFrame);      // Write start frame

                for (i = 0; i < type.frames; i++) {
                    writeUnsignedInt(type.frameDurations[i].minimum); // Write minimum duration
                    writeUnsignedInt(type.frameDurations[i].maximum); // Write maximum duration
                }
            }

            var spriteIndex:Vector.<uint> = type.spriteIndex;
            var length:uint = spriteIndex.length;
            for (i = 0; i < length; i++) {
                // Write sprite index
                if (extended)
                    writeUnsignedInt(spriteIndex[i]);
                else
                    writeShort(spriteIndex[i]);
            }

            return true;
        }
    }
}
