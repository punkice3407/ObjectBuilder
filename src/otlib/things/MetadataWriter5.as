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
     * Writer for versions 8.60 - 9.86
     */
    public class MetadataWriter5 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter5()
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
                writeByte(MetadataFlags5.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset) {
                writeByte(MetadataFlags5.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.animateAlways)
                writeByte(MetadataFlags5.ANIMATE_ALWAYS);

            writeByte(MetadataFlags5.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags5.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isGroundBorder)
                writeByte(MetadataFlags5.GROUND_BORDER);
            else if (type.isOnBottom)
                writeByte(MetadataFlags5.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags5.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags5.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags5.STACKABLE);

            if (type.forceUse)
                writeByte(MetadataFlags5.FORCE_USE);

            if (type.multiUse)
                writeByte(MetadataFlags5.MULTI_USE);

            if (type.writable) {
                writeByte(MetadataFlags5.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags5.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags5.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags5.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags5.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags5.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags5.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags5.BLOCK_PATHFIND);

            if (type.pickupable)
                writeByte(MetadataFlags5.PICKUPABLE);

            if (type.hangable)
                writeByte(MetadataFlags5.HANGABLE);

            if (type.isVertical)
                writeByte(MetadataFlags5.VERTICAL);

            if (type.isHorizontal)
                writeByte(MetadataFlags5.HORIZONTAL);

            if (type.rotatable)
                writeByte(MetadataFlags5.ROTATABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags5.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.dontHide)
                writeByte(MetadataFlags5.DONT_HIDE);

            if (type.isTranslucent)
                writeByte(MetadataFlags5.TRANSLUCENT);

            if (type.hasOffset) {
                writeByte(MetadataFlags5.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.hasElevation) {
                writeByte(MetadataFlags5.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.isLyingObject)
                writeByte(MetadataFlags5.LYING_OBJECT);

            if (type.animateAlways)
                writeByte(MetadataFlags5.ANIMATE_ALWAYS);

            if (type.miniMap) {
                writeByte(MetadataFlags5.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.isLensHelp) {
                writeByte(MetadataFlags5.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.isFullGround)
                writeByte(MetadataFlags5.FULL_GROUND);

            if (type.ignoreLook)
                writeByte(MetadataFlags5.IGNORE_LOOK);

            if (type.cloth) {
                writeByte(MetadataFlags5.CLOTH);
                writeShort(type.clothSlot);
            }

            if (type.isMarketItem) {
                writeByte(MetadataFlags5.MARKET_ITEM);
                writeShort(type.marketCategory);
                writeShort(type.marketTradeAs);
                writeShort(type.marketShowAs);
                writeShort(type.marketName.length);
                writeMultiByte(type.marketName, MetadataFlags5.STRING_CHARSET);
                writeShort(type.marketRestrictProfession);
                writeShort(type.marketRestrictLevel);
            }

            writeByte(MetadataFlags5.LAST_FLAG);

            return true;
        }
    }
}
