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
    import com.mignari.errors.NotImplementedMethodError;

    import otlib.animation.FrameGroup;
    import otlib.things.FrameGroupType;

    import flash.filesystem.FileStream;
    import flash.utils.Endian;
    import otlib.utils.DictionaryUtil;

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

        public function writeTexturePatterns(type:ThingType, extended:Boolean, frameDurations:Boolean, frameGroups:Boolean):Boolean
        {
            var groupCount:uint = 1;
			if(frameGroups && type.category == ThingCategory.OUTFIT) {
                groupCount = type.frameGroups.length;
				writeByte(groupCount);
			}

            var i:uint;
            var groupType:uint;
			var frameGroup:FrameGroup;
            for(groupType = 0; groupType < groupCount; groupType++)
            {
                if(frameGroups && type.category == ThingCategory.OUTFIT)
                {
                    var group:uint = groupType;
                    if(groupCount < 2)
                        group = 1;

                    writeByte(group);
                }

                frameGroup = type.getFrameGroup(groupType);
                writeByte(frameGroup.width);  // Write width
                writeByte(frameGroup.height); // Write height

                if (frameGroup.width > 1 || frameGroup.height > 1)
                    writeByte(frameGroup.exactSize); // Write exact size

                writeByte(frameGroup.layers);   // Write layers
                writeByte(frameGroup.patternX); // Write pattern X
                writeByte(frameGroup.patternY); // Write pattern Y
                writeByte(frameGroup.patternZ); // Write pattern Z
                writeByte(frameGroup.frames);   // Write frames

                if (frameDurations && frameGroup.isAnimation) {
                    writeByte(frameGroup.animationMode);   // Write animation type
                    writeInt(frameGroup.loopCount);        // Write loop count
                    writeByte(frameGroup.startFrame);      // Write start frame

                    for (i = 0; i < frameGroup.frames; i++) {
                        writeUnsignedInt(frameGroup.frameDurations[i].minimum); // Write minimum duration
                        writeUnsignedInt(frameGroup.frameDurations[i].maximum); // Write maximum duration
                    }
                }

                var spriteIndex:Vector.<uint> = frameGroup.spriteIndex;
                var length:uint = spriteIndex.length;
                for (i = 0; i < length; i++) {
                    // Write sprite index
                    if (extended)
                        writeUnsignedInt(spriteIndex[i]);
                    else
                        writeShort(spriteIndex[i]);
                }
            }

            return true;
        }
    }
}
