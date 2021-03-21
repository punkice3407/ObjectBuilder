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
    import flash.utils.describeType;

    import otlib.animation.FrameDuration;
    import otlib.geom.Size;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;

    public class ThingType
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var id:uint;
        public var category:String;
        public var width:uint;
        public var height:uint;
        public var exactSize:uint;
        public var layers:uint;
        public var patternX:uint;
        public var patternY:uint;
        public var patternZ:uint;
        public var frames:uint;
        public var spriteIndex:Vector.<uint>;
        public var isGround:Boolean;
        public var groundSpeed:uint;
        public var isGroundBorder:Boolean;
        public var isOnBottom:Boolean;
        public var isOnTop:Boolean;
        public var isContainer:Boolean;
        public var stackable:Boolean;
        public var forceUse:Boolean;
        public var multiUse:Boolean;
        public var hasCharges:Boolean;
        public var writable:Boolean;
        public var writableOnce:Boolean;
        public var maxTextLength:uint;
        public var isFluidContainer:Boolean;
        public var isFluid:Boolean;
        public var isUnpassable:Boolean;
        public var isUnmoveable:Boolean;
        public var blockMissile:Boolean;
        public var blockPathfind:Boolean;
        public var noMoveAnimation:Boolean;
        public var pickupable:Boolean;
        public var hangable:Boolean;
        public var isVertical:Boolean;
        public var isHorizontal:Boolean;
        public var rotatable:Boolean;
        public var hasLight:Boolean;
        public var lightLevel:uint;
        public var lightColor:uint;
        public var dontHide:Boolean;
        public var isTranslucent:Boolean;
        public var floorChange:Boolean;
        public var hasOffset:Boolean;
        public var offsetX:uint;
        public var offsetY:uint;
        public var hasElevation:Boolean;
        public var elevation:uint;
        public var isLyingObject:Boolean;
        public var animateAlways:Boolean;
        public var miniMap:Boolean;
        public var miniMapColor:uint;
        public var isLensHelp:Boolean;
        public var lensHelp:uint;
        public var isFullGround:Boolean;
        public var ignoreLook:Boolean;
        public var cloth:Boolean;
        public var clothSlot:uint;
        public var isMarketItem:Boolean;
        public var marketName:String;
        public var marketCategory:uint;
        public var marketTradeAs:uint;
        public var marketShowAs:uint;
        public var marketRestrictProfession:uint;
        public var marketRestrictLevel:uint;
        public var hasDefaultAction:Boolean;
        public var defaultAction:uint;
        public var wrappable:Boolean;
        public var unwrappable:Boolean;
        public var topEffect:Boolean;
        public var usable:Boolean;

        public var isAnimation:Boolean;
        public var animationMode:uint;
        public var loopCount:int;
        public var startFrame:int;
        public var frameDurations:Vector.<FrameDuration>;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingType()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function toString():String
        {
            return "[ThingType category=" + this.category + ", id=" + this.id + "]";
        }

        public function getTotalSprites():uint
        {
            return this.width *
                   this.height *
                   this.patternX *
                   this.patternY *
                   this.patternZ *
                   this.frames *
                   this.layers;
        }

        public function getTotalTextures():uint
        {
            return this.patternX *
                   this.patternY *
                   this.patternZ *
                   this.frames *
                   this.layers;
        }

        public function getSpriteIndex(width:uint,
                                       height:uint,
                                       layer:uint,
                                       patternX:uint,
                                       patternY:uint,
                                       patternZ:uint,
                                       frame:uint):uint
        {
            return ((((((frame % this.frames) *
                    this.patternZ + patternZ) *
                    this.patternY + patternY) *
                    this.patternX + patternX) *
                    this.layers + layer) *
                    this.height + height) *
                    this.width + width;
        }

        public function getTextureIndex(layer:uint,
                                        patternX:uint,
                                        patternY:uint,
                                        patternZ:uint,
                                        frame:uint):int
        {
            return (((frame % this.frames *
                    this.patternZ + patternZ) *
                    this.patternY + patternY) *
                    this.patternX + patternX) *
                    this.layers + layer;
        }

        public function getSpriteSheetSize():Size
        {
            var size:Size = new Size();
            size.width = this.patternZ * this.patternX * this.layers * this.width * Sprite.DEFAULT_SIZE;
            size.height = this.frames * this.patternY * this.height * Sprite.DEFAULT_SIZE;
            return size;
        }

        public function clone():ThingType
        {
            var newThing:ThingType = new ThingType();
            var description:XMLList = describeType(this)..variable;
            for each (var property:XML in description) {
                var name:String = property.@name;
                newThing[name] = this[name];
            }

            if (this.spriteIndex)
                newThing.spriteIndex = this.spriteIndex.concat();

            if (this.isAnimation) {

                var durations:Vector.<FrameDuration> = new Vector.<FrameDuration>(this.frames, true);
                for (var i:uint = 0; i < this.frames; i++)
                {
                    durations[i] = this.frameDurations[i].clone();
                }

                newThing.animationMode = this.animationMode;
                newThing.loopCount = this.loopCount;
                newThing.startFrame = this.startFrame;
                newThing.frameDurations = durations;
            }

            return newThing;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function create(id:uint, category:String):ThingType
        {
            if (!ThingCategory.getCategory(category))
                throw new Error(Resources.getString("invalidCategory"));

            var thing:ThingType = new ThingType();
            thing.category = category;
            thing.id = id;
            thing.width = 1;
            thing.height = 1;
            thing.layers = 1;
            thing.frames = 1;
            thing.patternX = 1;
            thing.patternY = 1;
            thing.patternZ = 1;
            thing.exactSize = 32;

            if (category == ThingCategory.OUTFIT)
            {
                thing.patternX = 4; // Directions
                thing.frames = 3;   // Animations
                thing.isAnimation = true;
                thing.frameDurations = new Vector.<FrameDuration>(thing.frames, true);

                var duration:uint = FrameDuration.getDefaultDuration(category);
                for (var i:uint = 0; i < thing.frames; i++)
                    thing.frameDurations[i] = new FrameDuration(duration, duration);
            }
            else if (category == ThingCategory.MISSILE)
            {
                thing.patternX = 3;
                thing.patternY = 3;
            }

            thing.spriteIndex = new Vector.<uint>(thing.getTotalSprites(), true);
            return thing;
        }
    }
}
