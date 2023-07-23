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
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;

    import nail.errors.AbstractClassError;

    import otlib.animation.FrameDuration;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;

    public final class ThingSerializer
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingSerializer()
        {
            throw new AbstractClassError(ThingSerializer);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const STRING_CHARSET:String = "iso-8859-1";
        public static const LAST_FLAG:uint = 0xFF;

        /**
         * Read versions 7.10 - 7.30
         */
        public static function readProperties1(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags1.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags1.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags1.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags1.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags1.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags1.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags1.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags1.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags1.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags1.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags1.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags1.BLOCK_PATHFINDER:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags1.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags1.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.FLOOR_CHANGE:
                        thing.floorChange = true;
                        break;
                    case MetadataFlags1.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    case MetadataFlags1.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = 8;
                        thing.offsetY = 8;
                        break;
                    case MetadataFlags1.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags1.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags1.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags1.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags1.WRAPPABLE:
                        thing.wrappable = true;
                        break;
                    case MetadataFlags1.UNWRAPPABLE:
                        thing.unwrappable = true;
                        break;
                    case MetadataFlags1.TOP_EFFECT:
                        thing.topEffect = true;
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Read versions 7.40 - 7.50
         */
        public static function readProperties2(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags2.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags2.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags2.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags2.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags2.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags2.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags2.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags2.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags2.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags2.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags2.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags2.BLOCK_PATHFINDER:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags2.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags2.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.FLOOR_CHANGE:
                        thing.floorChange = true;
                        break;
                    case MetadataFlags2.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    case MetadataFlags2.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = 8;
                        thing.offsetY = 8;
                        break;
                    case MetadataFlags2.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags2.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags2.HANGABLE:
                        thing.hangable = true;
                        break;
                    case MetadataFlags2.VERTICAL:
                        thing.isVertical = true;
                        break;
                    case MetadataFlags2.HORIZONTAL:
                        thing.isHorizontal = true;
                        break;
                    case MetadataFlags2.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags2.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags2.WRAPPABLE:
                        thing.wrappable = true;
                        break;
                    case MetadataFlags2.UNWRAPPABLE:
                        thing.unwrappable = true;
                        break;
                    case MetadataFlags2.TOP_EFFECT:
                        thing.topEffect = true;
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Read versions 7.55 - 7.72
         */
        public static function readProperties3(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags3.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.GROUND_BORDER:
                        thing.isGroundBorder = true;
                        break;
                    case MetadataFlags3.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags3.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags3.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags3.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags3.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags3.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags3.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags3.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags3.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags3.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags3.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags3.BLOCK_PATHFINDER:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags3.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags3.HANGABLE:
                        thing.hangable = true;
                        break;
                    case MetadataFlags3.VERTICAL:
                        thing.isVertical = true;
                        break;
                    case MetadataFlags3.HORIZONTAL:
                        thing.isHorizontal = true;
                        break;
                    case MetadataFlags3.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags3.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.FLOOR_CHANGE:
                        thing.floorChange = true;
                        break;
                    case MetadataFlags3.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = input.readShort();
                        thing.offsetY = input.readShort();
                        break;
                    case MetadataFlags3.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags3.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags3.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags3.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Read versions 7.80 - 8.54
         */
        public static function readProperties4(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags4.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.GROUND_BORDER:
                        thing.isGroundBorder = true;
                        break;
                    case MetadataFlags4.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags4.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags4.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags4.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags4.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags4.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags4.HAS_CHARGES:
                        thing.hasCharges = true;
                        break;
                    case MetadataFlags4.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags4.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags4.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags4.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags4.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags4.BLOCK_PATHFIND:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags4.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags4.HANGABLE:
                        thing.hangable = true;
                        break;
                    case MetadataFlags4.VERTICAL:
                        thing.isVertical = true;
                        break;
                    case MetadataFlags4.HORIZONTAL:
                        thing.isHorizontal = true;
                        break;
                    case MetadataFlags4.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags4.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.DONT_HIDE:
                        thing.dontHide = true;
                        break;
                    case MetadataFlags4.FLOOR_CHANGE:
                        thing.floorChange = true;
                        break;
                    case MetadataFlags4.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = input.readShort();
                        thing.offsetY = input.readShort();
                        break;
                    case MetadataFlags4.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags4.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags4.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags4.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    case MetadataFlags4.IGNORE_LOOK:
                        thing.ignoreLook = true;
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Read versions 8.60 - 9.86
         */
        public static function readProperties5(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags5.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.GROUND_BORDER:
                        thing.isGroundBorder = true;
                        break;
                    case MetadataFlags5.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags5.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags5.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags5.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags5.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags5.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags5.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags5.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags5.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags5.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags5.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags5.BLOCK_PATHFIND:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags5.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags5.HANGABLE:
                        thing.hangable = true;
                        break;
                    case MetadataFlags5.VERTICAL:
                        thing.isVertical = true;
                        break;
                    case MetadataFlags5.HORIZONTAL:
                        thing.isHorizontal = true;
                        break;
                    case MetadataFlags5.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags5.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.DONT_HIDE:
                        thing.dontHide = true;
                        break;
                    case MetadataFlags5.TRANSLUCENT:
                        thing.isTranslucent = true;
                        break;
                    case MetadataFlags5.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = input.readShort();
                        thing.offsetY = input.readShort();
                        break;
                    case MetadataFlags5.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags5.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags5.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    case MetadataFlags5.IGNORE_LOOK:
                        thing.ignoreLook = true;
                        break;
                    case MetadataFlags5.CLOTH:
                        thing.cloth = true;
                        thing.clothSlot = input.readUnsignedShort();
                        break;
                    case MetadataFlags5.MARKET_ITEM:
                        thing.isMarketItem = true;
                        thing.marketCategory = input.readUnsignedShort();
                        thing.marketTradeAs = input.readUnsignedShort();
                        thing.marketShowAs = input.readUnsignedShort();
                        var nameLength:uint = input.readUnsignedShort();
                        thing.marketName = input.readMultiByte(nameLength, STRING_CHARSET);
                        thing.marketRestrictProfession = input.readUnsignedShort();
                        thing.marketRestrictLevel = input.readUnsignedShort();
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Read versions 10.10+
         */
        public static function readProperties6(thing:ThingType, input:IDataInput):Boolean
        {
            var flag:uint = 0;
            while (flag < LAST_FLAG) {

                var previusFlag:uint = flag;
                flag = input.readUnsignedByte();
                if (flag == LAST_FLAG) return true;

                switch (flag)
                {
                    case MetadataFlags6.GROUND:
                        thing.isGround = true;
                        thing.groundSpeed = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.GROUND_BORDER:
                        thing.isGroundBorder = true;
                        break;
                    case MetadataFlags6.ON_BOTTOM:
                        thing.isOnBottom = true;
                        break;
                    case MetadataFlags6.ON_TOP:
                        thing.isOnTop = true;
                        break;
                    case MetadataFlags6.CONTAINER:
                        thing.isContainer = true;
                        break;
                    case MetadataFlags6.STACKABLE:
                        thing.stackable = true;
                        break;
                    case MetadataFlags6.FORCE_USE:
                        thing.forceUse = true;
                        break;
                    case MetadataFlags6.MULTI_USE:
                        thing.multiUse = true;
                        break;
                    case MetadataFlags6.WRITABLE:
                        thing.writable = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.WRITABLE_ONCE:
                        thing.writableOnce = true;
                        thing.maxTextLength = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.FLUID_CONTAINER:
                        thing.isFluidContainer = true;
                        break;
                    case MetadataFlags6.FLUID:
                        thing.isFluid = true;
                        break;
                    case MetadataFlags6.UNPASSABLE:
                        thing.isUnpassable = true;
                        break;
                    case MetadataFlags6.UNMOVEABLE:
                        thing.isUnmoveable = true;
                        break;
                    case MetadataFlags6.BLOCK_MISSILE:
                        thing.blockMissile = true;
                        break;
                    case MetadataFlags6.BLOCK_PATHFIND:
                        thing.blockPathfind = true;
                        break;
                    case MetadataFlags6.NO_MOVE_ANIMATION:
                        thing.noMoveAnimation = true;
                        break;
                    case MetadataFlags6.PICKUPABLE:
                        thing.pickupable = true;
                        break;
                    case MetadataFlags6.HANGABLE:
                        thing.hangable = true;
                        break;
                    case MetadataFlags6.VERTICAL:
                        thing.isVertical = true;
                        break;
                    case MetadataFlags6.HORIZONTAL:
                        thing.isHorizontal = true;
                        break;
                    case MetadataFlags6.ROTATABLE:
                        thing.rotatable = true;
                        break;
                    case MetadataFlags6.HAS_LIGHT:
                        thing.hasLight = true;
                        thing.lightLevel = input.readUnsignedShort();
                        thing.lightColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.DONT_HIDE:
                        thing.dontHide = true;
                        break;
                    case MetadataFlags6.TRANSLUCENT:
                        thing.isTranslucent = true;
                        break;
                    case MetadataFlags6.HAS_OFFSET:
                        thing.hasOffset = true;
                        thing.offsetX = input.readShort();
                        thing.offsetY = input.readShort();
                        break;
                    case MetadataFlags6.HAS_ELEVATION:
                        thing.hasElevation = true;
                        thing.elevation    = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.LYING_OBJECT:
                        thing.isLyingObject = true;
                        break;
                    case MetadataFlags6.ANIMATE_ALWAYS:
                        thing.animateAlways = true;
                        break;
                    case MetadataFlags6.MINI_MAP:
                        thing.miniMap = true;
                        thing.miniMapColor = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.LENS_HELP:
                        thing.isLensHelp = true;
                        thing.lensHelp = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.FULL_GROUND:
                        thing.isFullGround = true;
                        break;
                    case MetadataFlags6.IGNORE_LOOK:
                        thing.ignoreLook = true;
                        break;
                    case MetadataFlags6.CLOTH:
                        thing.cloth = true;
                        thing.clothSlot = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.MARKET_ITEM:
                        thing.isMarketItem = true;
                        thing.marketCategory = input.readUnsignedShort();
                        thing.marketTradeAs = input.readUnsignedShort();
                        thing.marketShowAs = input.readUnsignedShort();
                        var nameLength:uint = input.readUnsignedShort();
                        thing.marketName = input.readMultiByte(nameLength, STRING_CHARSET);
                        thing.marketRestrictProfession = input.readUnsignedShort();
                        thing.marketRestrictLevel = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.DEFAULT_ACTION:
                        thing.hasDefaultAction = true;
                        thing.defaultAction = input.readUnsignedShort();
                        break;
                    case MetadataFlags6.WRAPPABLE:
                        thing.wrappable = true;
                        break;
                    case MetadataFlags6.UNWRAPPABLE:
                        thing.unwrappable = true;
                        break;
                    case MetadataFlags6.TOP_EFFECT:
                        thing.topEffect = true;
                        break;
                    case MetadataFlags6.USABLE:
                        thing.usable = true;
                        break;
                    default:
                        throw new Error(Resources.getString(
                            "readUnknownFlag",
                            flag.toString(16),
                            previusFlag.toString(16),
                            Resources.getString(thing.category),
                            thing.id));
                }
            }
            return true;
        }

        /**
         * Write versions 7.10 - 7.30
         */
        public static function writeProperties1(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags1.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags1.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags1.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags1.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags1.STACKABLE);
            if (thing.multiUse) output.writeByte(MetadataFlags1.MULTI_USE);
            if (thing.forceUse) output.writeByte(MetadataFlags1.FORCE_USE);
            if (thing.writable) {
                output.writeByte(MetadataFlags1.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags1.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags1.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags1.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags1.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags1.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags1.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags1.BLOCK_PATHFINDER);
            if (thing.pickupable) output.writeByte(MetadataFlags1.PICKUPABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags1.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.floorChange) output.writeByte(MetadataFlags1.FLOOR_CHANGE);
            if (thing.isFullGround) output.writeByte(MetadataFlags1.FULL_GROUND);
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags1.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags1.HAS_OFFSET);
            }
            if (thing.miniMap) {
                output.writeByte(MetadataFlags1.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.rotatable) output.writeByte(MetadataFlags1.ROTATABLE);
            if (thing.isLyingObject) output.writeByte(MetadataFlags1.LYING_OBJECT);
            if (thing.animateAlways) output.writeByte(MetadataFlags1.ANIMATE_ALWAYS);
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags1.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.wrappable) output.writeByte(MetadataFlags1.WRAPPABLE);
            if (thing.unwrappable) output.writeByte(MetadataFlags1.UNWRAPPABLE);
            if (thing.topEffect && thing.category == ThingCategory.EFFECT) output.writeByte(MetadataFlags1.TOP_EFFECT);
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }

        /**
         * Write versions 7.40 - 7.50
         */
        public static function writeProperties2(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags2.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags2.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags2.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags2.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags2.STACKABLE);
            if (thing.multiUse) output.writeByte(MetadataFlags2.MULTI_USE);
            if (thing.forceUse) output.writeByte(MetadataFlags2.FORCE_USE);
            if (thing.writable) {
                output.writeByte(MetadataFlags2.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags2.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags2.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags2.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags2.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags2.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags2.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags2.BLOCK_PATHFINDER);
            if (thing.pickupable) output.writeByte(MetadataFlags2.PICKUPABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags2.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.floorChange) output.writeByte(MetadataFlags2.FLOOR_CHANGE);
            if (thing.isFullGround) output.writeByte(MetadataFlags2.FULL_GROUND);
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags2.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags2.HAS_OFFSET);
            }
            if (thing.miniMap) {
                output.writeByte(MetadataFlags2.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.rotatable) output.writeByte(MetadataFlags2.ROTATABLE);
            if (thing.isLyingObject) output.writeByte(MetadataFlags2.LYING_OBJECT);
            if (thing.hangable) output.writeByte(MetadataFlags2.HANGABLE);
            if (thing.isVertical) output.writeByte(MetadataFlags2.VERTICAL);
            if (thing.isHorizontal) output.writeByte(MetadataFlags2.HORIZONTAL);
            if (thing.animateAlways) output.writeByte(MetadataFlags2.ANIMATE_ALWAYS);
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags2.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.wrappable) output.writeByte(MetadataFlags2.WRAPPABLE);
            if (thing.unwrappable) output.writeByte(MetadataFlags2.UNWRAPPABLE);
            if (thing.topEffect && thing.category == ThingCategory.EFFECT) output.writeByte(MetadataFlags2.TOP_EFFECT);
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }

        /**
         * Write versions 7.55 - 7.72
         */
        public static function writeProperties3(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags3.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isGroundBorder) {
                output.writeByte(MetadataFlags3.GROUND_BORDER);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags3.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags3.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags3.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags3.STACKABLE);
            if (thing.multiUse) output.writeByte(MetadataFlags3.MULTI_USE);
            if (thing.forceUse) output.writeByte(MetadataFlags3.FORCE_USE);
            if (thing.writable) {
                output.writeByte(MetadataFlags3.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags3.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags3.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags3.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags3.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags3.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags3.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags3.BLOCK_PATHFINDER);
            if (thing.pickupable) output.writeByte(MetadataFlags3.PICKUPABLE);
            if (thing.hangable) output.writeByte(MetadataFlags3.HANGABLE);
            if (thing.isVertical) output.writeByte(MetadataFlags3.VERTICAL);
            if (thing.isHorizontal) output.writeByte(MetadataFlags3.HORIZONTAL);
            if (thing.rotatable) output.writeByte(MetadataFlags3.ROTATABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags3.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.floorChange) output.writeByte(MetadataFlags3.FLOOR_CHANGE);
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags3.HAS_OFFSET);
                output.writeShort(thing.offsetX);
                output.writeShort(thing.offsetY);
            }
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags3.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.isLyingObject) output.writeByte(MetadataFlags3.LYING_OBJECT);
            if (thing.animateAlways) output.writeByte(MetadataFlags3.ANIMATE_ALWAYS);
            if (thing.miniMap) {
                output.writeByte(MetadataFlags3.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags3.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.isFullGround) output.writeByte(MetadataFlags3.FULL_GROUND);
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }

        /**
         * Write versions 7.80 - 8.54
         */
        public static function writeProperties4(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags4.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isGroundBorder) {
                output.writeByte(MetadataFlags4.GROUND_BORDER);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags4.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags4.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags4.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags4.STACKABLE);
            if (thing.forceUse) output.writeByte(MetadataFlags4.FORCE_USE);
            if (thing.multiUse) output.writeByte(MetadataFlags4.MULTI_USE);
            if (thing.hasCharges) output.writeByte(MetadataFlags4.HAS_CHARGES);
            if (thing.writable) {
                output.writeByte(MetadataFlags4.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags4.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags4.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags4.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags4.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags4.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags4.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags4.BLOCK_PATHFIND);
            if (thing.pickupable) output.writeByte(MetadataFlags4.PICKUPABLE);
            if (thing.hangable) output.writeByte(MetadataFlags4.HANGABLE);
            if (thing.isVertical) output.writeByte(MetadataFlags4.VERTICAL);
            if (thing.isHorizontal) output.writeByte(MetadataFlags4.HORIZONTAL);
            if (thing.rotatable) output.writeByte(MetadataFlags4.ROTATABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags4.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.dontHide) output.writeByte(MetadataFlags4.DONT_HIDE);
            if (thing.floorChange) output.writeByte(MetadataFlags4.FLOOR_CHANGE);
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags4.HAS_OFFSET);
                output.writeShort(thing.offsetX);
                output.writeShort(thing.offsetY);
            }
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags4.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.isLyingObject) output.writeByte(MetadataFlags4.LYING_OBJECT);
            if (thing.animateAlways) output.writeByte(MetadataFlags4.ANIMATE_ALWAYS);
            if (thing.miniMap) {
                output.writeByte(MetadataFlags4.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags4.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.isFullGround) output.writeByte(MetadataFlags4.FULL_GROUND);
            if (thing.ignoreLook) output.writeByte(MetadataFlags4.IGNORE_LOOK);
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }

        /**
         * Write versions 8.60 - 9.86
         */
        public static function writeProperties5(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags5.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isGroundBorder) {
                output.writeByte(MetadataFlags5.GROUND_BORDER);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags5.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags5.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags5.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags5.STACKABLE);
            if (thing.forceUse) output.writeByte(MetadataFlags5.FORCE_USE);
            if (thing.multiUse) output.writeByte(MetadataFlags5.MULTI_USE);
            if (thing.writable) {
                output.writeByte(MetadataFlags5.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags5.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags5.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags5.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags5.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags5.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags5.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags5.BLOCK_PATHFIND);
            if (thing.pickupable) output.writeByte(MetadataFlags5.PICKUPABLE);
            if (thing.hangable) output.writeByte(MetadataFlags5.HANGABLE);
            if (thing.isVertical) output.writeByte(MetadataFlags5.VERTICAL);
            if (thing.isHorizontal) output.writeByte(MetadataFlags5.HORIZONTAL);
            if (thing.rotatable) output.writeByte(MetadataFlags5.ROTATABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags5.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.dontHide) output.writeByte(MetadataFlags5.DONT_HIDE);
            if (thing.isTranslucent) output.writeByte(MetadataFlags5.TRANSLUCENT);
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags5.HAS_OFFSET);
                output.writeShort(thing.offsetX);
                output.writeShort(thing.offsetY);
            }
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags5.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.isLyingObject) output.writeByte(MetadataFlags5.LYING_OBJECT);
            if (thing.animateAlways) output.writeByte(MetadataFlags5.ANIMATE_ALWAYS);
            if (thing.miniMap) {
                output.writeByte(MetadataFlags5.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags5.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.isFullGround) output.writeByte(MetadataFlags5.FULL_GROUND);
            if (thing.ignoreLook) output.writeByte(MetadataFlags5.IGNORE_LOOK);
            if (thing.cloth) {
                output.writeByte(MetadataFlags5.CLOTH);
                output.writeShort(thing.clothSlot);
            }
            if (thing.isMarketItem) {
                output.writeByte(MetadataFlags5.MARKET_ITEM);
                output.writeShort(thing.marketCategory);
                output.writeShort(thing.marketTradeAs);
                output.writeShort(thing.marketShowAs);
                output.writeShort(thing.marketName.length);
                output.writeMultiByte(thing.marketName, STRING_CHARSET);
                output.writeShort(thing.marketRestrictProfession);
                output.writeShort(thing.marketRestrictLevel);
            }
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }

        /**
         * Write versions 10.10+
         */
        public static function writeProperties6(thing:ThingType, output:IDataOutput):Boolean
        {
            if (thing.isGround) {
                output.writeByte(MetadataFlags6.GROUND);
                output.writeShort(thing.groundSpeed);
            } else if (thing.isGroundBorder) {
                output.writeByte(MetadataFlags6.GROUND_BORDER);
            } else if (thing.isOnBottom) {
                output.writeByte(MetadataFlags6.ON_BOTTOM);
            } else if (thing.isOnTop) {
                output.writeByte(MetadataFlags6.ON_TOP);
            }

            if (thing.isContainer) output.writeByte(MetadataFlags6.CONTAINER);
            if (thing.stackable) output.writeByte(MetadataFlags6.STACKABLE);
            if (thing.forceUse) output.writeByte(MetadataFlags6.FORCE_USE);
            if (thing.multiUse) output.writeByte(MetadataFlags6.MULTI_USE);
            if (thing.writable) {
                output.writeByte(MetadataFlags6.WRITABLE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.writableOnce) {
                output.writeByte(MetadataFlags6.WRITABLE_ONCE);
                output.writeShort(thing.maxTextLength);
            }
            if (thing.isFluidContainer) output.writeByte(MetadataFlags6.FLUID_CONTAINER);
            if (thing.isFluid) output.writeByte(MetadataFlags6.FLUID);
            if (thing.isUnpassable) output.writeByte(MetadataFlags6.UNPASSABLE);
            if (thing.isUnmoveable) output.writeByte(MetadataFlags6.UNMOVEABLE);
            if (thing.blockMissile) output.writeByte(MetadataFlags6.BLOCK_MISSILE);
            if (thing.blockPathfind) output.writeByte(MetadataFlags6.BLOCK_PATHFIND);
            if (thing.noMoveAnimation) output.writeByte(MetadataFlags6.NO_MOVE_ANIMATION);
            if (thing.pickupable) output.writeByte(MetadataFlags6.PICKUPABLE);
            if (thing.hangable) output.writeByte(MetadataFlags6.HANGABLE);
            if (thing.isVertical) output.writeByte(MetadataFlags6.VERTICAL);
            if (thing.isHorizontal) output.writeByte(MetadataFlags6.HORIZONTAL);
            if (thing.rotatable) output.writeByte(MetadataFlags6.ROTATABLE);
            if (thing.hasLight) {
                output.writeByte(MetadataFlags6.HAS_LIGHT);
                output.writeShort(thing.lightLevel);
                output.writeShort(thing.lightColor);
            }
            if (thing.dontHide) output.writeByte(MetadataFlags6.DONT_HIDE);
            if (thing.isTranslucent) output.writeByte(MetadataFlags6.TRANSLUCENT);
            if (thing.hasOffset) {
                output.writeByte(MetadataFlags6.HAS_OFFSET);
                output.writeShort(thing.offsetX);
                output.writeShort(thing.offsetY);
            }
            if (thing.hasElevation) {
                output.writeByte(MetadataFlags6.HAS_ELEVATION);
                output.writeShort(thing.elevation);
            }
            if (thing.isLyingObject) output.writeByte(MetadataFlags6.LYING_OBJECT);
            if (thing.animateAlways) output.writeByte(MetadataFlags6.ANIMATE_ALWAYS);
            if (thing.miniMap) {
                output.writeByte(MetadataFlags6.MINI_MAP);
                output.writeShort(thing.miniMapColor);
            }
            if (thing.isLensHelp) {
                output.writeByte(MetadataFlags6.LENS_HELP);
                output.writeShort(thing.lensHelp);
            }
            if (thing.isFullGround) output.writeByte(MetadataFlags6.FULL_GROUND);
            if (thing.ignoreLook) output.writeByte(MetadataFlags6.IGNORE_LOOK);
            if (thing.cloth) {
                output.writeByte(MetadataFlags6.CLOTH);
                output.writeShort(thing.clothSlot);
            }
            if (thing.isMarketItem) {
                output.writeByte(MetadataFlags6.MARKET_ITEM);
                output.writeShort(thing.marketCategory);
                output.writeShort(thing.marketTradeAs);
                output.writeShort(thing.marketShowAs);
                output.writeShort(thing.marketName.length);
                output.writeMultiByte(thing.marketName, STRING_CHARSET);
                output.writeShort(thing.marketRestrictProfession);
                output.writeShort(thing.marketRestrictLevel);
            }
            if (thing.hasDefaultAction) {
                output.writeByte(MetadataFlags6.DEFAULT_ACTION);
                output.writeShort(thing.defaultAction);
            }
            if (thing.wrappable) output.writeByte(MetadataFlags6.WRAPPABLE);
            if (thing.unwrappable) output.writeByte(MetadataFlags6.UNWRAPPABLE);
            if (thing.topEffect && thing.category == ThingCategory.EFFECT) output.writeByte(MetadataFlags6.TOP_EFFECT);
            if (thing.usable) {
                output.writeByte(MetadataFlags6.USABLE);
            }
            output.writeByte(LAST_FLAG); // Close flags
            return true;
        }
    }
}
