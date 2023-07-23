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
    /**
     * Writer for versions 7.55 - 7.72
     */
    public class MetadataWriter3 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter3()
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
                writeByte(MetadataFlags3.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset) {
                writeByte(MetadataFlags3.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.animateAlways)
                writeByte(MetadataFlags3.ANIMATE_ALWAYS);

            writeByte(MetadataFlags3.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags3.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isGroundBorder)
                writeByte(MetadataFlags3.GROUND_BORDER);
            else if (type.isOnBottom)
                writeByte(MetadataFlags3.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags3.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags3.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags3.STACKABLE);

            if (type.multiUse)
                writeByte(MetadataFlags3.MULTI_USE);

            if (type.forceUse)
                writeByte(MetadataFlags3.FORCE_USE);

            if (type.writable) {
                writeByte(MetadataFlags3.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags3.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags3.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags3.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags3.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags3.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags3.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags3.BLOCK_PATHFINDER);

            if (type.pickupable)
                writeByte(MetadataFlags3.PICKUPABLE);

            if (type.hangable)
                writeByte(MetadataFlags3.HANGABLE);

            if (type.isVertical)
                writeByte(MetadataFlags3.VERTICAL);

            if (type.isHorizontal)
                writeByte(MetadataFlags3.HORIZONTAL);

            if (type.rotatable)
                writeByte(MetadataFlags3.ROTATABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags3.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.floorChange)
                writeByte(MetadataFlags3.FLOOR_CHANGE);

            if (type.hasOffset) {
                writeByte(MetadataFlags3.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.hasElevation) {
                writeByte(MetadataFlags3.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.isLyingObject)
                writeByte(MetadataFlags3.LYING_OBJECT);

            if (type.animateAlways)
                writeByte(MetadataFlags3.ANIMATE_ALWAYS);

            if (type.miniMap) {
                writeByte(MetadataFlags3.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.isLensHelp) {
                writeByte(MetadataFlags3.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.isFullGround)
                writeByte(MetadataFlags3.FULL_GROUND);

            writeByte(MetadataFlags3.LAST_FLAG);

            return true;
        }
    }
}
