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
