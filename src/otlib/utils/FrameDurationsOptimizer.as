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

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class FrameDurationsOptimizer extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_objects:ThingTypeStorage;
        private var m_finished:Boolean;
        private var m_itemsEnabled:Boolean;
        private var m_itemsMinimumDuration:uint;
        private var m_itemsMaximumDuration:uint;
        private var m_outfitsEnabled:Boolean;
        private var m_outfitsMinimumDuration:uint;
        private var m_outfitsMaximumDuration:uint;
        private var m_effectsEnabled:Boolean;
        private var m_effectsMinimumDuration:uint;
        private var m_effectsMaximumDuration:uint;


        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function FrameDurationsOptimizer(objects:ThingTypeStorage, items:Boolean, itemsMinimumDuration:uint, itemsMaximumDuration:uint,
                                                                        outfits:Boolean, outfitsMinimumDuration:uint, outfitsMaximumDuration:uint,
                                                                        effects:Boolean, effectsMinimumDuration:uint, effectsMaximumDuration:uint)
        {
            if (!objects)
                throw new NullArgumentError("objects");

            m_objects = objects;
            m_itemsEnabled = items;
            m_itemsMinimumDuration = itemsMinimumDuration;
            m_itemsMaximumDuration = itemsMaximumDuration;

            m_outfitsEnabled = outfits;
            m_outfitsMinimumDuration = outfitsMinimumDuration;
            m_outfitsMaximumDuration = outfitsMaximumDuration;

            m_effectsEnabled = effects;
            m_effectsMinimumDuration = effectsMinimumDuration;
            m_effectsMaximumDuration = effectsMaximumDuration;
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

            var steps:uint = 5;
            var step:uint = 0;

            dispatchProgress(step++, steps, Resources.getString("startingTheOptimization"));
            dispatchProgress(step++, steps, Resources.getString("changingDurationsInItems"));
            if (m_itemsEnabled)
                changeFrameDurations(m_objects.items, m_itemsMinimumDuration, m_itemsMaximumDuration)

            dispatchProgress(step++, steps, Resources.getString("changingDurationsInOutfits"));
            if (m_outfitsEnabled)
                changeFrameDurations(m_objects.outfits, m_outfitsMinimumDuration, m_outfitsMaximumDuration)

            dispatchProgress(step++, steps, Resources.getString("changingDurationsInEffects"));
            if (m_effectsEnabled)
                changeFrameDurations(m_objects.effects, m_effectsMinimumDuration, m_effectsMaximumDuration)

            m_finished = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function changeFrameDurations(list:Dictionary, minimum:uint, maximum:uint):void
        {
            for each (var thing:ThingType in list)
            {
				for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
				{
					var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
					if(!frameGroup || !frameGroup.frameDurations)
						continue;

                    for (var frame:uint = 0; frame < frameGroup.frames; frame++) {
                        var duration:FrameDuration = frameGroup.getFrameDuration(frame);
                        if (duration)
                        {
                            duration.minimum = minimum;
                            duration.maximum = maximum;

                            frameGroup.frameDurations[frame] = duration.clone();
                        }
                    }
				}
            }
        }

        private function dispatchProgress(current:uint, target:uint, label:String):void
        {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.FIND, current, target, label));
        }
    }
}
