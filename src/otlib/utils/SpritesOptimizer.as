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

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class SpritesOptimizer extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_objects:ThingTypeStorage;
        private var m_sprites:SpriteStorage;
        private var m_finished:Boolean;
        private var m_oldIDs:Vector.<Sprite>;
        private var m_hashes:Dictionary;
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

        public function SpritesOptimizer(objects:ThingTypeStorage, sprites:SpriteStorage)
        {
            if (!objects)
                throw new NullArgumentError("objects");

            if (!sprites)
                throw new NullArgumentError("sprites");

            m_objects = objects;
            m_sprites = sprites;
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

            var length:uint = m_sprites.spritesCount + 1;
            var steps:uint = 9;
            var step:uint = 0;

            dispatchProgress(step++, steps, Resources.getString("startingTheOptimization"));

            m_oldIDs = new Vector.<Sprite>(length, true);
            m_hashes = new Dictionary();
            m_newIDs = new Dictionary();

            // =====================================================================
            // hashes all sprites.

            dispatchProgress(step++, steps, Resources.getString("hasingSprites"));
            for (var id:uint = 1; id < length; id++)
            {
                m_oldIDs[id] = m_sprites.getSprite(id);
                m_newIDs[id] = id;

                var hash:String = m_oldIDs[id].getHash();
                if (hash == null)
                {
                    m_newIDs[id] = id;
                }
                else if (m_hashes[hash] === undefined)
                {
                    m_newIDs[id] = id;
                    m_hashes[hash] = id;
                }
                else
                {
                    m_newIDs[id] = m_hashes[hash];
                }
            }

            // =====================================================================
            // replaces duplicated sprites found on hashing.

            dispatchProgress(step++, steps, Resources.getString("resettingDuplicateSprites"));

            // set items
            setNewIDsAfterHashing(m_objects.items);

            // set outfits
            setNewIDsAfterHashing(m_objects.outfits);

            // set effects
            setNewIDsAfterHashing(m_objects.effects);

            // set missiles
            setNewIDsAfterHashing(m_objects.missiles);

            // =====================================================================
            // scan lists finding unused ids.

            dispatchProgress(step++, steps, Resources.getString("searchingForUnusedSprites"));

            var i:int = 0;
            var freeIDs:Vector.<Boolean> = new Vector.<Boolean>(length, true);
            var usedList:Vector.<Boolean> = new Vector.<Boolean>(length, true);

            // scan items
            scanList(m_objects.items, usedList);

            // scan outfits
            scanList(m_objects.outfits, usedList);

            // scan effects
            scanList(m_objects.effects, usedList);

            // scan missiles
            scanList(m_objects.missiles, usedList);

            // =====================================================================
            // gets all unused/empty ids.

            dispatchProgress(step++, steps, Resources.getString("gettingFreeIds"));

            for (i = 1; i < length; i++)
            {
                if (!usedList[i] || m_oldIDs[i].isEmpty)
                    freeIDs[i] = true;
            }

            // =====================================================================
            // replaces all free ids and organizes indices.

            m_newIDs = new Dictionary();
            dispatchProgress(step++, steps, Resources.getString("organizingSprites"));

            var index:int = 1;
            var count:uint = 0;

            for (i = 1; i < length; i++, index++)
            {
                while (index < length && freeIDs[index])
                {
                    index++;
                    count++;
                }

                if (index > m_sprites.spritesCount) break;

                var sprite:Sprite = m_oldIDs[index];
                sprite.id = i;
                m_newIDs[i] = sprite;
            }

            // =====================================================================
            // updates the ids of all lists.

            dispatchProgress(step++, steps, Resources.getString("updatingObjects"));

            if (count > 0)
            {
                // set items
                setNewIDs(m_objects.items);

                // set outfits
                setNewIDs(m_objects.outfits);

                // set effects
                setNewIDs(m_objects.effects);

                // set missiles
                setNewIDs(m_objects.missiles);

                // =====================================================================
                // sets new values to the sprite storage.

                dispatchProgress(step++, steps, Resources.getString("finalizingTheOptimization"));

                m_newIDs[0] = m_sprites._sprites[0];

                m_objects.invalidate();
                m_sprites._sprites = m_newIDs;
                m_sprites._spritesCount = m_sprites._spritesCount - count;
                m_sprites.invalidate();
            }

            m_removedCount = count;
            m_oldCount = length - 1;
            m_newCount = m_sprites._spritesCount;
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
					for (var i:int = spriteIDs.length - 1; i >= 0; i--)
						usedList[ spriteIDs[i] ] = true;
				}
            }
        }

        private function setNewIDsAfterHashing(list:Dictionary):void
        {
            for each (var thing:ThingType in list)
            {
				for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
				{
					var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
					if(!frameGroup)
						continue;

					var spriteIDs:Vector.<uint> = frameGroup.spriteIndex;
					for (var i:int = spriteIDs.length - 1; i >= 0; i--)
					{
						if (spriteIDs[i] != 0)
							spriteIDs[i] = m_newIDs[ spriteIDs[i] ];
					}
				}
            }
        }

        private function setNewIDs(list:Dictionary):void
        {
            for each (var thing:ThingType in list)
            {
				for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
				{
					var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
					if(!frameGroup)
						continue;

					var spriteIDs:Vector.<uint> = frameGroup.spriteIndex;
					for (var i:int = spriteIDs.length - 1; i >= 0; i--)
					{
						if (spriteIDs[i] != 0)
							spriteIDs[i] = m_oldIDs[ spriteIDs[i] ].id;
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
