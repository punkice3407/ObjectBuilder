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

    /**
     * Writer for versions 7.80 - 8.54
     */
    public class MetadataWriter4 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter4()
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
                writeByte(MetadataFlags4.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset) {
                writeByte(MetadataFlags4.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.animateAlways)
                writeByte(MetadataFlags4.ANIMATE_ALWAYS);

            writeByte(MetadataFlags4.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags4.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isGroundBorder)
                writeByte(MetadataFlags4.GROUND_BORDER);
            else if (type.isOnBottom)
                writeByte(MetadataFlags4.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags4.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags4.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags4.STACKABLE);

            if (type.forceUse)
                writeByte(MetadataFlags4.FORCE_USE);

            if (type.multiUse)
                writeByte(MetadataFlags4.MULTI_USE);

            if (type.hasCharges)
                writeByte(MetadataFlags4.HAS_CHARGES);

            if (type.writable) {
                writeByte(MetadataFlags4.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags4.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags4.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags4.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags4.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags4.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags4.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags4.BLOCK_PATHFIND);

            if (type.pickupable)
                writeByte(MetadataFlags4.PICKUPABLE);

            if (type.hangable)
                writeByte(MetadataFlags4.HANGABLE);

            if (type.isVertical)
                writeByte(MetadataFlags4.VERTICAL);

            if (type.isHorizontal)
                writeByte(MetadataFlags4.HORIZONTAL);

            if (type.rotatable)
                writeByte(MetadataFlags4.ROTATABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags4.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.dontHide)
                writeByte(MetadataFlags4.DONT_HIDE);

            if (type.floorChange)
                writeByte(MetadataFlags4.FLOOR_CHANGE);

            if (type.hasOffset) {
                writeByte(MetadataFlags4.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.hasElevation) {
                writeByte(MetadataFlags4.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.isLyingObject)
                writeByte(MetadataFlags4.LYING_OBJECT);

            if (type.animateAlways)
                writeByte(MetadataFlags4.ANIMATE_ALWAYS);

            if (type.miniMap) {
                writeByte(MetadataFlags4.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.isLensHelp) {
                writeByte(MetadataFlags4.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.isFullGround)
                writeByte(MetadataFlags4.FULL_GROUND);

            if (type.ignoreLook)
                writeByte(MetadataFlags4.IGNORE_LOOK);

            writeByte(MetadataFlags4.LAST_FLAG);

            return true;
        }
    }
}
