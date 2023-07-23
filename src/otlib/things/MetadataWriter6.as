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
     * Writer for versions 10.10 - 10.56
     */
    public class MetadataWriter6 extends MetadataWriter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataWriter6()
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
                writeByte(MetadataFlags6.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.hasOffset) {
                writeByte(MetadataFlags6.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.animateAlways)
                writeByte(MetadataFlags6.ANIMATE_ALWAYS);

            if (type.topEffect && type.category == ThingCategory.EFFECT)
                writeByte(MetadataFlags6.TOP_EFFECT);

            writeByte(MetadataFlags6.LAST_FLAG);
            return true;
        }

        public override function writeItemProperties(type:ThingType):Boolean
        {
            if (type.category != ThingCategory.ITEM)
                return false;

            if (type.isGround) {
                writeByte(MetadataFlags6.GROUND);
                writeShort(type.groundSpeed);
            } else if (type.isGroundBorder)
                writeByte(MetadataFlags6.GROUND_BORDER);
            else if (type.isOnBottom)
                writeByte(MetadataFlags6.ON_BOTTOM);
            else if (type.isOnTop)
                writeByte(MetadataFlags6.ON_TOP);

            if (type.isContainer)
                writeByte(MetadataFlags6.CONTAINER);

            if (type.stackable)
                writeByte(MetadataFlags6.STACKABLE);

            if (type.forceUse)
                writeByte(MetadataFlags6.FORCE_USE);

            if (type.multiUse)
                writeByte(MetadataFlags6.MULTI_USE);

            if (type.writable) {
                writeByte(MetadataFlags6.WRITABLE);
                writeShort(type.maxTextLength);
            }

            if (type.writableOnce) {
                writeByte(MetadataFlags6.WRITABLE_ONCE);
                writeShort(type.maxTextLength);
            }

            if (type.isFluidContainer)
                writeByte(MetadataFlags6.FLUID_CONTAINER);

            if (type.isFluid)
                writeByte(MetadataFlags6.FLUID);

            if (type.isUnpassable)
                writeByte(MetadataFlags6.UNPASSABLE);

            if (type.isUnmoveable)
                writeByte(MetadataFlags6.UNMOVEABLE);

            if (type.blockMissile)
                writeByte(MetadataFlags6.BLOCK_MISSILE);

            if (type.blockPathfind)
                writeByte(MetadataFlags6.BLOCK_PATHFIND);

            if (type.noMoveAnimation)
                writeByte(MetadataFlags6.NO_MOVE_ANIMATION);

            if (type.pickupable)
                writeByte(MetadataFlags6.PICKUPABLE);

            if (type.hangable)
                writeByte(MetadataFlags6.HANGABLE);

            if (type.isVertical)
                writeByte(MetadataFlags6.VERTICAL);

            if (type.isHorizontal)
                writeByte(MetadataFlags6.HORIZONTAL);

            if (type.rotatable)
                writeByte(MetadataFlags6.ROTATABLE);

            if (type.hasLight) {
                writeByte(MetadataFlags6.HAS_LIGHT);
                writeShort(type.lightLevel);
                writeShort(type.lightColor);
            }

            if (type.dontHide)
                writeByte(MetadataFlags6.DONT_HIDE);

            if (type.isTranslucent)
                writeByte(MetadataFlags6.TRANSLUCENT);

            if (type.hasOffset) {
                writeByte(MetadataFlags6.HAS_OFFSET);
                writeShort(type.offsetX);
                writeShort(type.offsetY);
            }

            if (type.hasElevation) {
                writeByte(MetadataFlags6.HAS_ELEVATION);
                writeShort(type.elevation);
            }

            if (type.isLyingObject)
                writeByte(MetadataFlags6.LYING_OBJECT);

            if (type.animateAlways)
                writeByte(MetadataFlags6.ANIMATE_ALWAYS);

            if (type.miniMap) {
                writeByte(MetadataFlags6.MINI_MAP);
                writeShort(type.miniMapColor);
            }

            if (type.isLensHelp) {
                writeByte(MetadataFlags6.LENS_HELP);
                writeShort(type.lensHelp);
            }

            if (type.isFullGround)
                writeByte(MetadataFlags6.FULL_GROUND);

            if (type.ignoreLook)
                writeByte(MetadataFlags6.IGNORE_LOOK);

            if (type.cloth) {
                writeByte(MetadataFlags6.CLOTH);
                writeShort(type.clothSlot);
            }

            if (type.isMarketItem) {
                writeByte(MetadataFlags6.MARKET_ITEM);
                writeShort(type.marketCategory);
                writeShort(type.marketTradeAs);
                writeShort(type.marketShowAs);
                writeShort(type.marketName.length);
                writeMultiByte(type.marketName, MetadataFlags6.STRING_CHARSET);
                writeShort(type.marketRestrictProfession);
                writeShort(type.marketRestrictLevel);
            }

            if (type.hasDefaultAction) {
                writeByte(MetadataFlags6.DEFAULT_ACTION);
                writeShort(type.defaultAction);
            }

            if (type.wrappable)
                writeByte(MetadataFlags6.WRAPPABLE);

            if (type.unwrappable)
                writeByte(MetadataFlags6.UNWRAPPABLE);

            if (type.usable)
                writeByte(MetadataFlags6.USABLE);

            writeByte(MetadataFlags6.LAST_FLAG);

            return true;
        }
    }
}
