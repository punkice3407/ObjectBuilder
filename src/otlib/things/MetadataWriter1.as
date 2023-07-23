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
    import otlib.animation.FrameGroup;
    import otlib.things.FrameGroupType;
	import otlib.utils.DictionaryUtil;

    /**
     * Writer for versions 7.10 - 7.30
     */
    public class MetadataWriter1 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter1()
        {

        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public Override
        //--------------------------------------

        public override function writeProperties(type:ThingType):Boolean
        {
            if (type.category == ThingCategory.ITEM)
                return false;

            if (type.hasLight) {
                writeByte(MetadataFlags1.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset)
                writeByte(MetadataFlags1.HAS_OFFSET);

            if (type.animateAlways)
                writeByte(MetadataFlags1.ANIMATE_ALWAYS);

            writeByte(MetadataFlags1.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags1.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isOnBottom)
                writeByte(MetadataFlags1.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags1.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags1.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags1.STACKABLE);

            if (type.multiUse)
                writeByte(MetadataFlags1.MULTI_USE);

            if (type.forceUse)
                writeByte(MetadataFlags1.FORCE_USE);

            if (type.writable) {
                writeByte(MetadataFlags1.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags1.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags1.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags1.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags1.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags1.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags1.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags1.BLOCK_PATHFINDER);

            if (type.pickupable)
                writeByte(MetadataFlags1.PICKUPABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags1.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.floorChange)
                writeByte(MetadataFlags1.FLOOR_CHANGE);

            if (type.isFullGround)
                writeByte(MetadataFlags1.FULL_GROUND);

            if (type.hasElevation) {
                writeByte(MetadataFlags1.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.hasOffset)
                writeByte(MetadataFlags1.HAS_OFFSET);

            if (type.miniMap) {
                writeByte(MetadataFlags1.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.rotatable)
                writeByte(MetadataFlags1.ROTATABLE);

            if (type.isLyingObject)
                writeByte(MetadataFlags1.LYING_OBJECT);

            if (type.animateAlways)
                writeByte(MetadataFlags1.ANIMATE_ALWAYS);

            if (type.topEffect && type.category == ThingCategory.EFFECT)
                writeByte(MetadataFlags1.TOP_EFFECT);

            if (type.isLensHelp) {
                writeByte(MetadataFlags1.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.wrappable)
                writeByte(MetadataFlags1.WRAPPABLE);

            if (type.unwrappable)
                writeByte(MetadataFlags1.UNWRAPPABLE);

            writeByte(MetadataFlags1.LAST_FLAG);

            return true;
        }

        public override function writeTexturePatterns(type:ThingType, extended:Boolean, frameDurations:Boolean, frameGroups:Boolean):Boolean
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

                if (frameGroup.width > 1 || frameGroup.height > 1) {
                    writeByte(frameGroup.exactSize); // Write exact size
                }

                writeByte(frameGroup.layers);   // Write layers
                writeByte(frameGroup.patternX); // Write pattern X
                writeByte(frameGroup.patternY); // Write pattern Y
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
