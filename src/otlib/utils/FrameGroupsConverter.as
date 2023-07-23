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
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    import nail.errors.NullArgumentError;

    import ob.commands.ProgressBarID;

    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;
    import otlib.sprites.SpriteStorage;
    import otlib.things.ThingType;
    import otlib.things.ThingTypeStorage;
	import otlib.animation.FrameGroup;
	import otlib.things.FrameGroupType;
	import otlib.animation.FrameDuration;
	import otlib.things.ThingData;
	import otlib.things.ThingCategory;
	import otlib.sprites.SpriteData;
	import flash.utils.ByteArray;
	import mx.logging.Log;
	import otlib.obd.OBDVersions;

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class FrameGroupsConverter extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_objects:ThingTypeStorage;
        private var m_sprites:SpriteStorage;
        private var m_finished:Boolean;
        private var m_frameGroups:Boolean;
        private var m_removeMounts:Boolean;
        private var m_clientVersion:uint;
        private var m_improvedAnimations:Boolean;
        private var m_defaultDuration:uint;


        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function FrameGroupsConverter(objects:ThingTypeStorage, sprites:SpriteStorage, frameGroups:Boolean, removeMounts:Boolean, clientVersion:uint, improvedAnimations:Boolean, duration:uint)
        {
            if (!objects)
                throw new NullArgumentError("objects");

            m_objects = objects;
            m_sprites = sprites;
            m_frameGroups = frameGroups;
            m_removeMounts = removeMounts;
            m_clientVersion = clientVersion;
            m_improvedAnimations = improvedAnimations;
            m_defaultDuration = duration
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function start():void
        {
            if (m_finished) return;

            var step:uint = 0;
            var steps:uint;
            for each (var thing:ThingType in m_objects.outfits)
                steps++;

            for each (thing in m_objects.outfits)
            {
                var thingData:ThingData = getOutfitData(thing.id);
                if(thingData)
                {
                    dispatchProgress(step++, steps, Resources.getString("convertOutfits"));
                    var frameGroups:uint = ThingUtils.REMOVE_FRAME_GROUPS;
                    if (m_frameGroups)
                        frameGroups = ThingUtils.ADD_FRAME_GROUPS;

                    ThingUtils.convertFrameGroups(thingData, frameGroups, m_improvedAnimations, m_defaultDuration, m_removeMounts);
                }
            }

            m_finished = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function getOutfitData(id:uint):ThingData
        {
            if (!ThingCategory.getCategory(ThingCategory.OUTFIT)) {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var thing:ThingType = m_objects.getThingType(id, ThingCategory.OUTFIT);
            if (!thing) {
                throw new Error(Resources.getString(
                    "thingNotFound",
                    Resources.getString(ThingCategory.OUTFIT),
                    id));
            }

			var sprites:Dictionary = new Dictionary();
			for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
			{
				var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
				if(!frameGroup)
					continue;

				sprites[groupType] = new Vector.<SpriteData>();

				var spriteIndex:Vector.<uint> = frameGroup.spriteIndex;
				var length:uint = spriteIndex.length;

				for (var i:uint = 0; i < length; i++) {
					var spriteId:uint = spriteIndex[i];
					var pixels:ByteArray = m_sprites.getPixels(spriteId);
					if (!pixels)
						pixels = m_sprites.alertSprite.getPixels();

					var spriteData:SpriteData = new SpriteData();
					spriteData.id = spriteId;
					spriteData.pixels = pixels;
					sprites[groupType][i] = spriteData;
				}
			}

            return ThingData.create(OBDVersions.OBD_VERSION_2, m_clientVersion, thing, sprites);
        }

        private function dispatchProgress(current:uint, target:uint, label:String):void
        {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.FIND, current, target, label));
        }
    }
}
