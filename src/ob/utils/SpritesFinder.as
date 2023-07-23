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

package ob.utils
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    import nail.errors.NullArgumentError;

    import ob.commands.ProgressBarID;

    import otlib.animation.FrameGroup;
    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.sprites.SpriteData;
    import otlib.sprites.SpriteStorage;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingType;
    import otlib.things.ThingTypeStorage;
	import otlib.animation.FrameGroup;
	import otlib.things.FrameGroupType;

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class SpritesFinder extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_dat:ThingTypeStorage;
        private var m_spr:SpriteStorage;
        private var m_foundList:Array;
        private var m_finished:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get foundList():Array { return m_foundList; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpritesFinder(dat:ThingTypeStorage, spr:SpriteStorage)
        {
            if (!dat)
                throw new NullArgumentError("dat");

            if (!spr)
                throw new NullArgumentError("spr");

            m_dat = dat;
            m_spr = spr;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function start(unusedSprites:Boolean, emptySprites:Boolean):void
        {
            if (m_finished) return;

            if (unusedSprites || emptySprites)
            {
                var length:uint = m_spr.spritesCount + 1;
                var i:int = 0;
                var spriteFoundList:Array = [];
                var usedList:Vector.<Boolean> = new Vector.<Boolean>(length, true);
                var spriteData:SpriteData;

                if (unusedSprites)
                {
                    // scan items
                    scanList(m_dat.items, usedList);

                    // scan outfits
                    scanList(m_dat.outfits, usedList);

                    // scan effects
                    scanList(m_dat.effects, usedList);

                    // scan missiles
                    scanList(m_dat.missiles, usedList);

                    // =====================================================================
                    // gets all unused/empty sprites.

                    for (i = 1; i < length; i++)
                    {
                        if (!usedList[i] && (!m_spr.isEmptySprite(i) || emptySprites))
                        {
                            spriteData = new SpriteData();
                            spriteData.id = i;
                            spriteData.pixels = m_spr.getPixels(i);
                            spriteFoundList[spriteFoundList.length] = spriteData;

                            if (i % 10 == 0)
                                dispatchProgress(i, length);
                        }
                    }
                }
                else
                {
                    // =====================================================================
                    // gets all empty sprites.

                    for (i = 1; i < length; i++)
                    {
                        if (m_spr.isEmptySprite(i))
                        {
                            spriteData = new SpriteData();
                            spriteData.id = i;
                            spriteData.pixels = m_spr.getPixels(i);
                            spriteFoundList[spriteFoundList.length] = spriteData;

                            if (i % 10 == 0)
                                dispatchProgress(i, length);
                        }
                    }
                }

                m_foundList = spriteFoundList;
            }

            m_finished = true;

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function scanList(list:Dictionary, usedList:Vector.<Boolean>):void
        {
            for each (var thing:ThingType in list)
            {
				for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
				{
					var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
					if(!frameGroup)
						continue;

					var spriteIDs:Vector.<uint> = frameGroup.spriteIndex;
					var length:uint = spriteIDs.length;

					for (var i:int = 0; i < length; i++)
						usedList[ spriteIDs[i] ] = true;
				}
            }
        }

        private function dispatchProgress(current:uint, target:uint):void
        {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,
                                            ProgressBarID.FIND,
                                            current,
                                            target));
        }
    }
}
