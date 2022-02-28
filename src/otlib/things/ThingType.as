/*
*  Copyright (c) 2014-2022 Object Builder <https://github.com/ottools/ObjectBuilder>
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

    import otlib.animation.AnimationMode;
    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.geom.Size;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;
    import otlib.things.FrameGroupType;
    import ob.core.IObjectBuilder;
    import mx.core.FlexGlobals;

    public class ThingType
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var id:uint;
        public var category:String;
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

        public var frameGroups:Array;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingType()
        {
            frameGroups = [];
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

        public function getFrameGroup(groupType:uint):FrameGroup
        {
			return frameGroups[groupType] as FrameGroup;
        }

		public function setFrameGroup(groupType:uint, frameGroup:FrameGroup):void
		{
			frameGroup.type = groupType
			frameGroups[groupType] = frameGroup
		}

        public function clone():ThingType
        {
            var newThing:ThingType = new ThingType();
            var description:XMLList = describeType(this)..variable;
            for each (var property:XML in description) {
                var name:String = property.@name;
                newThing[name] = this[name];
            }

			newThing.frameGroups = [];
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var group:FrameGroup = this.getFrameGroup(groupType);
                if(group)
                   newThing.setFrameGroup(groupType, group.clone());
            }

            return newThing;
        }

        private function getFrameIndexes(frameGroup:FrameGroup, spriteLength:uint, firstIndex:uint = 0):Vector.<uint>
        {
            var spriteIndex:Vector.<uint> = new Vector.<uint>();
            if(!frameGroup)
                return spriteIndex;

            for (var index:uint = firstIndex; index < spriteLength; index++)
                spriteIndex[spriteIndex.length] = frameGroup.spriteIndex[index];

            return spriteIndex;
        }

        public function addFrameGroupState(improvedAnimations:Boolean, duration:uint):void
        {
            var normal:FrameGroup = this.getFrameGroup(FrameGroupType.DEFAULT);
            if(!normal || normal.frames < 3)
                return;

            var frameId:uint;

            var idle:FrameGroup = normal.clone();
            idle.frames = 1;

            var idleSprites:uint = idle.getTotalSprites();
            idle.spriteIndex = getFrameIndexes(normal, idleSprites);
            idle.isAnimation = false;
            idle.frameDurations = null;
            idle.animationMode = AnimationMode.ASYNCHRONOUS;
            idle.loopCount = 0;
            idle.startFrame = 0;

            var walking:FrameGroup = normal.clone();
            walking.frames = normal.frames - 1;
            walking.spriteIndex = getFrameIndexes(normal, normal.getTotalSprites(), idleSprites);
            walking.isAnimation = false;

            if(walking.frames > 1)
                walking.isAnimation = true;

            walking.frameDurations = new Vector.<FrameDuration>(walking.frames, true);
            walking.animationMode = AnimationMode.ASYNCHRONOUS;
            walking.loopCount = 0;
            walking.startFrame = 0;

            for (frameId = 0; frameId < walking.frames; frameId++) {
                if (improvedAnimations && normal.frameDurations[frameId])
                    walking.frameDurations[frameId] = normal.frameDurations[frameId].clone();
                else
                    walking.frameDurations[frameId] = new FrameDuration(duration, duration);
            }

            this.setFrameGroup(FrameGroupType.DEFAULT, idle);
            this.setFrameGroup(FrameGroupType.WALKING, walking);
        }

        public function removeFrameGroupState(improvedAnimations:Boolean, duration:uint):void
        {
            var idle:FrameGroup = this.getFrameGroup(FrameGroupType.DEFAULT);
            var walking:FrameGroup = this.getFrameGroup(FrameGroupType.WALKING);
            if(!idle || !walking)
                return;

            //TODO
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function create(id:uint, category:String, frameGroups:Boolean, duration:uint):ThingType
        {
            if (!ThingCategory.getCategory(category))
                throw new Error(Resources.getString("invalidCategory"));

            var thing:ThingType = new ThingType();
            thing.category = category;
            thing.id = id;

			var group:FrameGroup;
            if (category == ThingCategory.OUTFIT)
            {
                var groups:uint = FrameGroupType.DEFAULT;
                if(frameGroups)
                    groups = FrameGroupType.WALKING;

                for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= groups; groupType++)
                {
					group = new FrameGroup();
                    group.type = groupType;
                    group.makeOutfitGroup(duration);

                    thing.setFrameGroup(groupType, group);
                }
            }
            else
            {
				group = new FrameGroup();
                if (category == ThingCategory.MISSILE)
                {
                    group.patternX = 3;
                    group.patternY = 3;
                }

                group.spriteIndex = new Vector.<uint>(group.getTotalSprites(), true);
				thing.setFrameGroup(FrameGroupType.DEFAULT, group);
            }

            return thing;
        }
    }
}
