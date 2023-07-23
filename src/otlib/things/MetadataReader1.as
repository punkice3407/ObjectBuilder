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
    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.resources.Resources;
    import com.mignari.utils.StringUtil;
    import otlib.utils.SpriteExtent;

    /**
     * Reader for versions 7.10 - 7.30
     */
    public class MetadataReader1 extends MetadataReader
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataReader1()
        {

        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public Override
        //--------------------------------------

        public override function readProperties(type:ThingType):Boolean
        {
            var flag:uint = 0;
            while (flag < MetadataFlags1.LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = readUnsignedByte();

                if (flag == MetadataFlags1.LAST_FLAG)
                    return true;

                switch (flag)
                {
                    case MetadataFlags1.GROUND:
                        type.isGround = true;
                        type.groundSpeed = readUnsignedShort();
                        break;

                    case MetadataFlags1.ON_BOTTOM:
                        type.isOnBottom = true;
                        break;

                    case MetadataFlags1.ON_TOP:
                        type.isOnTop = true;
                        break;

                    case MetadataFlags1.CONTAINER:
                        type.isContainer = true;
                        break;

                    case MetadataFlags1.STACKABLE:
                        type.stackable = true;
                        break;

                    case MetadataFlags1.MULTI_USE:
                        type.multiUse = true;
                        break;

                    case MetadataFlags1.FORCE_USE:
                        type.forceUse = true;
                        break;

                    case MetadataFlags1.WRITABLE:
                        type.writable = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags1.WRITABLE_ONCE:
                        type.writableOnce = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags1.FLUID_CONTAINER:
                        type.isFluidContainer = true;
                        break;

                    case MetadataFlags1.FLUID:
                        type.isFluid = true;
                        break;

                    case MetadataFlags1.UNPASSABLE:
                        type.isUnpassable = true;
                        break;

                    case MetadataFlags1.UNMOVEABLE:
                        type.isUnmoveable = true;
                        break;

                    case MetadataFlags1.BLOCK_MISSILE:
                        type.blockMissile = true;
                        break;

                    case MetadataFlags1.BLOCK_PATHFINDER:
                        type.blockPathfind = true;
                        break;

                    case MetadataFlags1.PICKUPABLE:
                        type.pickupable = true;
                        break;

                    case MetadataFlags1.HAS_LIGHT:
                        type.hasLight = true;
                        type.lightLevel = readUnsignedShort();
                        type.lightColor = readUnsignedShort();
                        break;

                    case MetadataFlags1.FLOOR_CHANGE:
                        type.floorChange = true;
                        break;

                    case MetadataFlags1.FULL_GROUND:
                        type.isFullGround = true;
                        break;

                    case MetadataFlags1.HAS_ELEVATION:
                        type.hasElevation = true;
                        type.elevation = readUnsignedShort();
                        break;

                    case MetadataFlags1.HAS_OFFSET:
                        type.hasOffset = true;
                        type.offsetX = 8;
                        type.offsetY = 8;
                        break;

                    case MetadataFlags1.MINI_MAP:
                        type.miniMap = true;
                        type.miniMapColor = readUnsignedShort();
                        break;

                    case MetadataFlags1.ROTATABLE:
                        type.rotatable = true;
                        break;

                    case MetadataFlags1.LYING_OBJECT:
                        type.isLyingObject = true;
                        break;

                    case MetadataFlags1.ANIMATE_ALWAYS:
                        type.animateAlways = true;
                        break;

                    case MetadataFlags1.LENS_HELP:
                        type.isLensHelp = true;
                        type.lensHelp = readUnsignedShort();
                        break;

                    case MetadataFlags1.WRAPPABLE:
                        type.wrappable = true;
                        break;

                    case MetadataFlags1.UNWRAPPABLE:
                        type.unwrappable = true;
                        break;

                    case MetadataFlags1.TOP_EFFECT:
                        type.topEffect = true;
                        break;

                    default:
                        throw new Error(Resources.getString("readUnknownFlag",
                                                            flag.toString(16),
                                                            previusFlag.toString(16),
                                                            Resources.getString(type.category),
                                                            type.id));
                }
            }

            return true;
        }

        public override function readTexturePatterns(type:ThingType, extended:Boolean, frameDurations:Boolean, frameGroups:Boolean):Boolean
        {
            var groupCount:uint = 1;
			if(frameGroups && type.category == ThingCategory.OUTFIT) {
				groupCount = readUnsignedByte();
			}

            var i:uint;
            var groupType:uint;
			var frameGroup:FrameGroup;
            for(groupType = 0; groupType < groupCount; groupType++)
            {
			    if(frameGroups && type.category == ThingCategory.OUTFIT)
					readUnsignedByte();

				frameGroup = new FrameGroup();
                frameGroup.width = readUnsignedByte();
                frameGroup.height = readUnsignedByte();

                if (frameGroup.width > 1 || frameGroup.height > 1)
                    frameGroup.exactSize = readUnsignedByte();
                else
                    frameGroup.exactSize = SpriteExtent.DEFAULT_SIZE;

                frameGroup.layers = readUnsignedByte();
                frameGroup.patternX = readUnsignedByte();
                frameGroup.patternY = readUnsignedByte();
                frameGroup.patternZ = 1;
                frameGroup.frames = readUnsignedByte();
                if (frameGroup.frames > 1) {
                    frameGroup.isAnimation = true;
                    frameGroup.frameDurations = new Vector.<FrameDuration>(frameGroup.frames, true);

                    if (frameDurations) {
                        frameGroup.animationMode = readUnsignedByte();
                        frameGroup.loopCount = readInt();
                        frameGroup.startFrame = readByte();

                        for (i = 0; i < frameGroup.frames; i++)
                        {
                            var minimum:uint = readUnsignedInt();
                            var maximum:uint = readUnsignedInt();
                            frameGroup.frameDurations[i] = new FrameDuration(minimum, maximum);
                        }
                    } else {
                        var duration:uint = settings.getDefaultDuration(type.category);
                        for (i = 0; i < frameGroup.frames; i++)
                            frameGroup.frameDurations[i] = new FrameDuration(duration, duration);
                    }
                }

                var totalSprites:uint = frameGroup.getTotalSprites();
                if (totalSprites > SpriteExtent.DEFAULT_DATA_SIZE)
                    throw new Error(StringUtil.format("A thing type has more than {0} sprites.", SpriteExtent.DEFAULT_DATA_SIZE));

                frameGroup.spriteIndex = new Vector.<uint>(totalSprites);
                for (i = 0; i < totalSprites; i++) {
                    if (extended)
                        frameGroup.spriteIndex[i] = readUnsignedInt();
                    else
                        frameGroup.spriteIndex[i] = readUnsignedShort();
                }

                type.setFrameGroup(groupType, frameGroup);
            }

            return true;
        }
    }
}
