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
    import com.mignari.errors.FileNotFoundError;
    import com.mignari.errors.NullArgumentError;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import ob.commands.ProgressBarID;

    import otlib.core.Version;
    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.sprites.SpriteStorage;
    import otlib.storages.StorageQueueLoader;
    import otlib.things.ThingType;
    import otlib.things.ThingTypeStorage;
	import otlib.animation.FrameGroup;
	import otlib.things.FrameGroupType;
	import ob.settings.ObjectBuilderSettings;

    use namespace otlib_internal;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]

    public class ClientMerger extends EventDispatcher
    {
        private var m_objects:ThingTypeStorage;
        private var m_sprites:SpriteStorage;
        private var m_spriteIds:Dictionary;
        private var m_itemsCount:uint;
        private var m_outfitsCount:uint;
        private var m_effectsCount:uint;
        private var m_missilesCount:uint;
        private var m_spritesCount:uint;

        private var m_currentObjects:ThingTypeStorage;
        private var m_currentSprites:SpriteStorage;

        private var m_settings:ObjectBuilderSettings;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get itemsCount():uint { return m_itemsCount; }
        public function get outfitsCount():uint { return m_outfitsCount; }
        public function get effectsCount():uint { return m_effectsCount; }
        public function get missilesCount():uint { return m_missilesCount; }
        public function get spritesCount():uint { return m_spritesCount; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ClientMerger(objects:ThingTypeStorage, sprites:SpriteStorage, settings:ObjectBuilderSettings)
        {
            if (!objects)
                throw new NullArgumentError("objects");

            if (!sprites)
                throw new NullArgumentError("sprites");

            if (!settings)
                throw new NullArgumentError("settings");

            m_currentObjects = objects;
            m_currentSprites = sprites;
            m_settings = settings;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function start(datFile:File,
                              sprFile:File,
                              version:Version,
                              extended:Boolean,
                              improvedAnimations:Boolean,
                              frameGroups:Boolean,
                              transparency:Boolean,
                              optimizeSprites:Boolean = true):void
        {
            if (!datFile)
                throw new NullArgumentError("datFile");

            if (!datFile.exists)
                throw new FileNotFoundError(datFile);

            if (!sprFile)
                throw new NullArgumentError("sprFile");

            if (!sprFile.exists)
                throw new FileNotFoundError(sprFile);

            if (!version)
                throw new NullArgumentError("version");

            m_objects = new ThingTypeStorage(m_settings);
            m_objects.addEventListener(ErrorEvent.ERROR, errorHandler);

            m_sprites = new SpriteStorage();
            m_sprites.addEventListener(ErrorEvent.ERROR, errorHandler);

            var loader:StorageQueueLoader = new StorageQueueLoader();
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.add(m_objects, m_objects.load, datFile, version, extended, improvedAnimations, frameGroups);
            loader.add(m_sprites, m_sprites.load, sprFile, version, extended, transparency);
            loader.start();

            function completeHandler(event:Event):void
            {
                loader.removeEventListener(Event.COMPLETE, completeHandler);

                if (optimizeSprites)
                    startOptimizeSprites();
                else
                    startMerge();
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function startOptimizeSprites():void
        {
            var optimizer:SpritesOptimizer = new SpritesOptimizer(m_objects, m_sprites);
            optimizer.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            optimizer.addEventListener(Event.COMPLETE, completeHandler);
            optimizer.start();

            function progressHandler(event:ProgressEvent):void
            {
                dispatchEvent(event);
            }

            function completeHandler(event:Event):void
            {
                startMerge();
            }
        }

        private function startMerge():void
        {
            var oldItemsCount:uint = m_currentObjects.itemsCount;
            var oldOutfitsCount:uint = m_currentObjects.outfitsCount;
            var oldEffectsCount:uint = m_currentObjects.effectsCount;
            var oldMissilesCount:uint = m_currentObjects.missilesCount;
            var oldSpritesCount:uint = m_currentSprites.spritesCount;

            mergeSpriteList(1, m_sprites.spritesCount);
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, 1, 5));

            mergeObjectList(m_objects.items, 100, m_objects.itemsCount);
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, 2, 5));

            mergeObjectList(m_objects.outfits, 1, m_objects.outfitsCount);
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, 3, 5));

            mergeObjectList(m_objects.effects, 1, m_objects.effectsCount);
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, 4, 5));

            mergeObjectList(m_objects.missiles, 1, m_objects.missilesCount);
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, 5, 5));

            m_currentObjects.invalidate();
            m_currentSprites.invalidate();
            m_itemsCount = m_currentObjects.itemsCount - oldItemsCount;
            m_outfitsCount = m_currentObjects.outfitsCount - oldOutfitsCount;
            m_effectsCount = m_currentObjects.effectsCount - oldEffectsCount;
            m_missilesCount = m_currentObjects.missilesCount - oldMissilesCount;
            m_spritesCount = m_currentSprites.spritesCount - oldSpritesCount;

            if (hasEventListener(Event.COMPLETE))
                dispatchEvent(new Event(Event.COMPLETE));
        }

        private function mergeSpriteList(min:int, max:uint):void
        {
            m_spriteIds = new Dictionary();

            var result:ChangeResult = new ChangeResult();

            for (var id:int = min; id <= max; id++) {
                if (m_sprites.isEmptySprite(id)) {
                    m_spriteIds[id] = 0;
                } else {
                    var pixels:ByteArray = m_sprites.getPixels(id);
                    m_currentSprites.internalAddSprite(pixels, result);
                    m_spriteIds[id] = m_currentSprites.spritesCount;
                }
            }
        }

        private function mergeObjectList(list:Dictionary, min:uint, max:uint):void
        {
            var objects:Vector.<ThingType> = new Vector.<ThingType>();

            for (var id:int = min; id <= max; id++) {
                var type:ThingType = list[id];

                if (ThingUtils.isEmpty(type))
                    continue;

                for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
                {
                    var frameGroup:FrameGroup = type.getFrameGroup(groupType);
                    if(!frameGroup)
                        continue;

                    var spriteIds:Vector.<uint> = frameGroup.spriteIndex;

                    for (var k:int = spriteIds.length - 1; k >= 0; k--) {
                        var sid:uint = spriteIds[k];
                        if (sid != 0) {
                            if (m_spriteIds[sid] !== undefined)
                                spriteIds[k] = m_spriteIds[sid];
                            else
                                spriteIds[k] = 0;
                        }
                    }
                }

                objects[objects.length] = type;
            }

            if (objects.length != 0)
                m_currentObjects.addThings(objects);
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        private function errorHandler(event:ErrorEvent):void
        {
            trace(event.text);
        }
    }
}
