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
    import otlib.resources.Resources;

    /**
     * Reader for versions 7.80 - 8.54
     */
    public class MetadataReader4 extends MetadataReader
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataReader4()
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
            while (flag < MetadataFlags4.LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = readUnsignedByte();

                if (flag == MetadataFlags4.LAST_FLAG)
                    return true;

                switch (flag)
                {
                    case MetadataFlags4.GROUND:
                        type.isGround = true;
                        type.groundSpeed = readUnsignedShort();
                        break;

                    case MetadataFlags4.GROUND_BORDER:
                        type.isGroundBorder = true;
                        break;

                    case MetadataFlags4.ON_BOTTOM:
                        type.isOnBottom = true;
                        break;

                    case MetadataFlags4.ON_TOP:
                        type.isOnTop = true;
                        break;

                    case MetadataFlags4.CONTAINER:
                        type.isContainer = true;
                        break;

                    case MetadataFlags4.STACKABLE:
                        type.stackable = true;
                        break;

                    case MetadataFlags4.FORCE_USE:
                        type.forceUse = true;
                        break;

                    case MetadataFlags4.MULTI_USE:
                        type.multiUse = true;
                        break;

                    case MetadataFlags4.HAS_CHARGES:
                        type.hasCharges = true;
                        break;

                    case MetadataFlags4.WRITABLE:
                        type.writable = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags4.WRITABLE_ONCE:
                        type.writableOnce = true;
                        type.maxTextLength = readUnsignedShort();
                        break;

                    case MetadataFlags4.FLUID_CONTAINER:
                        type.isFluidContainer = true;
                        break;

                    case MetadataFlags4.FLUID:
                        type.isFluid = true;
                        break;

                    case MetadataFlags4.UNPASSABLE:
                        type.isUnpassable = true;
                        break;

                    case MetadataFlags4.UNMOVEABLE:
                        type.isUnmoveable = true;
                        break;

                    case MetadataFlags4.BLOCK_MISSILE:
                        type.blockMissile = true;
                        break;

                    case MetadataFlags4.BLOCK_PATHFIND:
                        type.blockPathfind = true;
                        break;

                    case MetadataFlags4.PICKUPABLE:
                        type.pickupable = true;
                        break;

                    case MetadataFlags4.HANGABLE:
                        type.hangable = true;
                        break;

                    case MetadataFlags4.VERTICAL:
                        type.isVertical = true;
                        break;

                    case MetadataFlags4.HORIZONTAL:
                        type.isHorizontal = true;
                        break;

                    case MetadataFlags4.ROTATABLE:
                        type.rotatable = true;
                        break;

                    case MetadataFlags4.HAS_LIGHT:
                        type.hasLight = true;
                        type.lightLevel = readUnsignedShort();
                        type.lightColor = readUnsignedShort();
                        break;

                    case MetadataFlags4.DONT_HIDE:
                        type.dontHide = true;
                        break;

                    case MetadataFlags4.FLOOR_CHANGE:
                        type.floorChange = true;
                        break;

                    case MetadataFlags4.HAS_OFFSET:
                        type.hasOffset = true;
                        type.offsetX = readShort();
                        type.offsetY = readShort();
                        break;

                    case MetadataFlags4.HAS_ELEVATION:
                        type.hasElevation = true;
                        type.elevation = readUnsignedShort();
                        break;

                    case MetadataFlags4.LYING_OBJECT:
                        type.isLyingObject = true;
                        break;

                    case MetadataFlags4.ANIMATE_ALWAYS:
                        type.animateAlways = true;
                        break;

                    case MetadataFlags4.MINI_MAP:
                        type.miniMap = true;
                        type.miniMapColor = readUnsignedShort();
                        break;

                    case MetadataFlags4.LENS_HELP:
                        type.isLensHelp = true;
                        type.lensHelp = readUnsignedShort();
                        break;

                    case MetadataFlags4.FULL_GROUND:
                        type.isFullGround = true;
                        break;

                    case MetadataFlags4.IGNORE_LOOK:
                        type.ignoreLook = true;
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
    }
}
