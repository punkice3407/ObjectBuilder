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
     * Writer for versions 7.40 - 7.50
     */
    public class MetadataWriter2 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter2()
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
                writeByte(MetadataFlags2.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset)
                writeByte(MetadataFlags2.HAS_OFFSET);

            if (type.animateAlways)
                writeByte(MetadataFlags2.ANIMATE_ALWAYS);

            writeByte(MetadataFlags2.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags2.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isOnBottom)
                writeByte(MetadataFlags2.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags2.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags2.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags2.STACKABLE);

            if (type.multiUse)
                writeByte(MetadataFlags2.MULTI_USE);

            if (type.forceUse)
                writeByte(MetadataFlags2.FORCE_USE);

            if (type.writable) {
                writeByte(MetadataFlags2.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags2.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags2.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags2.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags2.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags2.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags2.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags2.BLOCK_PATHFINDER);

            if (type.pickupable)
                writeByte(MetadataFlags2.PICKUPABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags2.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.floorChange)
                writeByte(MetadataFlags2.FLOOR_CHANGE);

            if (type.isFullGround)
                writeByte(MetadataFlags2.FULL_GROUND);

            if (type.hasElevation) {
                writeByte(MetadataFlags2.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.hasOffset)
                writeByte(MetadataFlags2.HAS_OFFSET);

            if (type.miniMap) {
                writeByte(MetadataFlags2.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.rotatable)
                writeByte(MetadataFlags2.ROTATABLE);

            if (type.isLyingObject)
                writeByte(MetadataFlags2.LYING_OBJECT);

            if (type.hangable)
                writeByte(MetadataFlags2.HANGABLE);

            if (type.isVertical)
                writeByte(MetadataFlags2.VERTICAL);

            if (type.isHorizontal)
                writeByte(MetadataFlags2.HORIZONTAL);

            if (type.animateAlways)
                writeByte(MetadataFlags2.ANIMATE_ALWAYS);

            if (type.topEffect && type.category == ThingCategory.EFFECT)
                writeByte(MetadataFlags2.TOP_EFFECT);

            if (type.isLensHelp) {
                writeByte(MetadataFlags2.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.wrappable)
                writeByte(MetadataFlags2.WRAPPABLE);

            if (type.unwrappable)
                writeByte(MetadataFlags2.UNWRAPPABLE);

            writeByte(MetadataFlags2.LAST_FLAG);

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
