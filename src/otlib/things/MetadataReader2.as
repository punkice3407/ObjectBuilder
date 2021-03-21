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
    import otlib.animation.FrameDuration;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;

    /**
     * Reader for versions 7.40 - 7.50
     */
    public class MetadataReader2 extends MetadataReader
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataReader2()
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
            while (flag < MetadataFlags2.LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = readUnsignedByte();

                if (flag == MetadataFlags2.LAST_FLAG)
                    return true;

                switch (flag)
                {
                    case MetadataFlags2.GROUND:
                        type.isGround = true;
                        type.groundSpeed = readUnsignedShort();
                        break;

                    case MetadataFlags2.ON_BOTTOM:
                        type.isOnBottom = true;
                        break;

                    case MetadataFlags2.ON_TOP:
                        type.isOnTop = true;
                        break;

                    case MetadataFlags2.CONTAINER:
                        type.isContainer = true;
                        break;

                    case MetadataFlags2.STACKABLE:
                        type.stackable = true;
                        break;

                    case MetadataFlags2.MULTI_USE:
                        type.multiUse = true;
                        break;

                    case MetadataFlags2.FORCE_USE:
                        type.forceUse = true;
                        break;

                    case MetadataFlags2.WRITABLE:
                        type.writable = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags2.WRITABLE_ONCE:
                        type.writableOnce = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags2.FLUID_CONTAINER:
                        type.isFluidContainer = true;
                        break;

                    case MetadataFlags2.FLUID:
                        type.isFluid = true;
                        break;

                    case MetadataFlags2.UNPASSABLE:
                        type.isUnpassable = true;
                        break;

                    case MetadataFlags2.UNMOVEABLE:
                        type.isUnmoveable = true;
                        break;

                    case MetadataFlags2.BLOCK_MISSILE:
                        type.blockMissile = true;
                        break;

                    case MetadataFlags2.BLOCK_PATHFINDER:
                        type.blockPathfind = true;
                        break;

                    case MetadataFlags2.PICKUPABLE:
                        type.pickupable = true;
                        break;

                    case MetadataFlags2.HAS_LIGHT:
                        type.hasLight = true;
                        type.lightLevel = readUnsignedShort();
                        type.lightColor = readUnsignedShort();
                        break;

                    case MetadataFlags2.FLOOR_CHANGE:
                        type.floorChange = true;
                        break;

                    case MetadataFlags2.FULL_GROUND:
                        type.isFullGround = true;
                        break;

                    case MetadataFlags2.HAS_ELEVATION:
                        type.hasElevation = true;
                        type.elevation = readUnsignedShort();
                        break;

                    case MetadataFlags2.HAS_OFFSET:
                        type.hasOffset = true;
                        type.offsetX = 8;
                        type.offsetY = 8;
                        break;

                    case MetadataFlags2.MINI_MAP:
                        type.miniMap = true;
                        type.miniMapColor = readUnsignedShort();
                        break;

                    case MetadataFlags2.ROTATABLE:
                        type.rotatable = true;
                        break;

                    case MetadataFlags2.LYING_OBJECT:
                        type.isLyingObject = true;
                        break;

                    case MetadataFlags2.HANGABLE:
                        type.hangable = true;
                        break;

                    case MetadataFlags2.VERTICAL:
                        type.isVertical = true;
                        break;

                    case MetadataFlags2.HORIZONTAL:
                        type.isHorizontal = true;
                        break;

                    case MetadataFlags2.ANIMATE_ALWAYS:
                        type.animateAlways = true;
                        break;

                    case MetadataFlags2.LENS_HELP:
                        type.isLensHelp = true;
                        type.lensHelp = readUnsignedShort();
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

        public override function readTexturePatterns(type:ThingType, extended:Boolean, frameDurations:Boolean):Boolean
        {
            var i:uint;

            type.width = readUnsignedByte();
            type.height = readUnsignedByte();

            if (type.width > 1 || type.height > 1)
                type.exactSize = readUnsignedByte();
            else
                type.exactSize = Sprite.DEFAULT_SIZE;

            type.layers = readUnsignedByte();
            type.patternX = readUnsignedByte();
            type.patternY = readUnsignedByte();
            type.patternZ = 1;
            type.frames = readUnsignedByte();
            if (type.frames > 1) {
                type.isAnimation = true;
                type.frameDurations = new Vector.<FrameDuration>(type.frames, true);

                if (frameDurations) {
                    type.animationMode = readUnsignedByte();
                    type.loopCount = readInt();
                    type.startFrame = readByte();

                    for (i = 0; i < type.frames; i++)
                    {
                        var minimum:uint = readUnsignedInt();
                        var maximum:uint = readUnsignedInt();
                        type.frameDurations[i] = new FrameDuration(minimum, maximum);
                    }
                } else {

                    var duration:uint = FrameDuration.getDefaultDuration(type.category);
                    for (i = 0; i < type.frames; i++)
                        type.frameDurations[i] = new FrameDuration(duration, duration);
                }
            }

            var totalSprites:uint = type.getTotalSprites();
            if (totalSprites > 4096)
                throw new Error("A thing type has more than 4096 sprites.");

            type.spriteIndex = new Vector.<uint>(totalSprites);
            for (i = 0; i < totalSprites; i++) {
                if (extended)
                    type.spriteIndex[i] = readUnsignedInt();
                else
                    type.spriteIndex[i] = readUnsignedShort();
            }

            return true;
        }
    }
}
