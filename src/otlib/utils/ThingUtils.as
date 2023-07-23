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

package otlib.utils
{
    import nail.errors.AbstractClassError;

    import otlib.things.ThingCategory;
    import otlib.things.ThingType;
    import otlib.animation.FrameGroup;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingData;

    public final class ThingUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingUtils()
        {
            throw new AbstractClassError(ThingUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function createAlertThing(category:String, duration:uint):ThingType
        {
            var thing:ThingType = ThingType.create(0, category, false, duration);
            if (thing) {
                var frameGroup:FrameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);
                var spriteIndex:Vector.<uint> = frameGroup.spriteIndex;
                var length:uint = spriteIndex.length;
                for (var i:uint = 0; i < length; i++) {
                    spriteIndex[i] = 0xFFFFFFFF;
                }
            }
            return thing;
        }

        public static function isValid(thing:ThingType):Boolean
        {
            if(!thing)
                return false;

            var frameGroup:FrameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);
            if(!frameGroup)
                return false;

            return frameGroup.width != 0 && frameGroup.height != 0;
        }

        public static function isEmpty(thing:ThingType):Boolean
        {
            var frameGroup:FrameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);
            if(!frameGroup)
                return true;

            var length:uint = frameGroup.spriteIndex ? frameGroup.spriteIndex.length : 0;
            if (length == 0)
                return true;

            if (length == 1 && frameGroup.spriteIndex[0] == 0)
                return true;

            if ((length == 12 && thing.category == ThingCategory.OUTFIT) ||
                (length == 9 && thing.category == ThingCategory.MISSILE)) {
                for (var i:int = length - 1; i >= 0; i--) {
                    if (frameGroup.spriteIndex[i] != 0)
                        return false;
                }
                return true;
            }

            // TODO check all properties.

            return false;
        }

        public static function convertFrameGroups(thingData:ThingData, frameGroups:uint, improvedAnimations:Boolean, duration:uint, removeMounts:Boolean):void
        {
            if(thingData.thing.animateAlways || thingData.category != ThingCategory.OUTFIT)
                return;

            if (frameGroups == REMOVE_FRAME_GROUPS)
            {
                if(thingData.thing.frameGroups.length <= 1)
                    return;

                thingData.thing.removeFrameGroupState(improvedAnimations, duration, removeMounts);
                thingData.removeFrameGroupSprites();
            }
            else if (frameGroups == ADD_FRAME_GROUPS)
            {
                if(thingData.thing.frameGroups.length > 1)
                    return;

                thingData.thing.addFrameGroupState(improvedAnimations, duration);
                thingData.addFrameGroupSprites();
            }

            return;
        }

        public static var REMOVE_FRAME_GROUPS:uint = 0;
        public static var ADD_FRAME_GROUPS:uint = 1;
    }
}
