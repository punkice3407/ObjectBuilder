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

    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.resources.Resources;
    import otlib.sprites.Sprite;
    import otlib.sprites.SpriteStorage;
    import otlib.things.ThingType;
    import otlib.things.ThingTypeStorage;

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class SpritesOptimizer extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_dat:ThingTypeStorage;
        private var m_spr:SpriteStorage;
        private var m_finished:Boolean;
        private var m_oldIDs:Vector.<Sprite>;
        private var m_newIDs:Dictionary;
        private var m_removedCount:uint;
        private var m_oldCount:uint;
        private var m_newCount:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get removedCount():uint { return m_removedCount; }
        public function get oldCount():uint { return m_oldCount; }
        public function get newCount():uint { return m_newCount; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpritesOptimizer(dat:ThingTypeStorage, spr:SpriteStorage)
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
                dispatchProgress(0, 5, Resources.getString("startingTheOptimization"));

                var length:uint = m_spr.spritesCount + 1;
                var i:int = 0;
                var freeIDs:Vector.<Boolean> = new Vector.<Boolean>(length, true);
                var usedList:Vector.<Boolean> = new Vector.<Boolean>(length, true);

                m_oldIDs = new Vector.<Sprite>(length, true);

                if (unusedSprites)
                {
                    dispatchProgress(1, 5, Resources.getString("searchingForUnusedSprites"));

                    // scan items
                    scanList(m_dat.items, usedList);

                    // scan outfits
                    scanList(m_dat.outfits, usedList);

                    // scan effects
                    scanList(m_dat.effects, usedList);

                    // scan missiles
                    scanList(m_dat.missiles, usedList);

                    // =====================================================================
                    // gets all unused/empty ids.

                    dispatchProgress(2, 5, Resources.getString("gettingFreeIds"));

                    for (i = 1; i < length; i++)
                    {
                        m_oldIDs[i] = m_spr.getSprite(i);

                        if (!usedList[i] && (!m_oldIDs[i].isEmpty || emptySprites))
                            freeIDs[i] = true;
                    }
                }
                else
                {
                    // =====================================================================
                    // gets all empty ids.

                    dispatchProgress(2, 5, Resources.getString("gettingFreeIds"));

                    for (i = 1; i < length; i++)
                    {
                        m_oldIDs[i] = m_spr.getSprite(i);

                        if (m_spr.isEmptySprite(i))
                            freeIDs[i] = true;
                    }
                }

                // =====================================================================
                // replaces all free ids and organizes indices.

                m_newIDs = new Dictionary();
                dispatchProgress(3, 5, Resources.getString("organizingSprites"));

                var index:int = 1;
                var count:uint = 0;

                for (i = 1; i < length; i++, index++)
                {
                    while (index < length && freeIDs[index])
                    {
                        index++;
                        count++;
                    }

                    if (index > m_spr.spritesCount) break;

                    var sprite:Sprite = m_oldIDs[index];
                    sprite.id = i;
                    m_newIDs[i] = sprite;
                }

                // =====================================================================
                // updates the ids of all lists.

                dispatchProgress(4, 5, Resources.getString("updatingObjects"));

                if (count > 0)
                {
                    // set items
                    setNewIDs(m_dat.items);

                    // set outfits
                    setNewIDs(m_dat.outfits);

                    // set effects
                    setNewIDs(m_dat.effects);

                    // set missiles
                    setNewIDs(m_dat.missiles);

                    // =====================================================================
                    // sets new values to the sprite storage.

                    dispatchProgress(5, 5, Resources.getString("finalizingTheOptimization"));

                    m_newIDs[0] = m_spr._sprites[0];

                    m_dat._changed = true;
                    m_spr._sprites = m_newIDs;
                    m_spr._spritesCount = m_spr._spritesCount - count;
                    m_spr._changed = true;
                }

                m_removedCount = count;
                m_oldCount = length - 1;
                m_newCount = m_spr._spritesCount;
            }

            m_finished = true;

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function scanList(list:Dictionary, usedList:Vector.<Boolean>):void
        {
            for each (var thing:ThingType in list)
            {
                var spriteIDs:Vector.<uint> = thing.spriteIndex;
                for (var i:int = spriteIDs.length - 1; i >= 0; i--)
                    usedList[ spriteIDs[i] ] = true;
            }
        }

        private function setNewIDs(list:Dictionary):void
        {
            for each (var thing:ThingType in list)
            {
                var spriteIDs:Vector.<uint> = thing.spriteIndex;
                for (var i:int = spriteIDs.length - 1; i >= 0; i--)
                {
                    if (spriteIDs[i] != 0)
                        spriteIDs[i] = m_oldIDs[ spriteIDs[i] ].id;
                }
            }
        }

        private function dispatchProgress(current:uint, target:uint, label:String):void
        {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,
                                            ProgressBarID.FIND,
                                            current,
                                            target,
                                            label));
        }
    }
}
