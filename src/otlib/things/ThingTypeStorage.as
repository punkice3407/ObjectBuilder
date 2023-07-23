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
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.utils.Dictionary;

    import nail.errors.NullArgumentError;
    import nail.logging.Log;
    import nail.utils.FileUtil;
    import nail.utils.StringUtil;

    import ob.commands.ProgressBarID;

    import otlib.core.Version;
    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.resources.Resources;
    import otlib.storages.IStorage;
    import otlib.storages.events.StorageEvent;
    import otlib.utils.ChangeResult;
    import otlib.utils.ThingUtils;
	import otlib.animation.FrameGroup;
	import ob.settings.ObjectBuilderSettings;

    use namespace otlib_internal;

    [Event(name="progress", type="flash.events.ProgressEvent")]
    [Event(name="load", type="otlib.storages.events.StorageEvent")]
    [Event(name="compile", type="otlib.storages.events.StorageEvent")]
    [Event(name="change", type="otlib.storages.events.StorageEvent")]
    [Event(name="convert", type="flash.events.ProgressEvent")]
    [Event(name="unloading", type="otlib.storages.events.StorageEvent")]
    [Event(name="unload", type="otlib.storages.events.StorageEvent")]
    [Event(name="error", type="flash.events.ErrorEvent")]

    public class ThingTypeStorage extends EventDispatcher implements IStorage
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _file:File;
        private var _version:Version;
        private var _signature:uint;
        private var _items:Dictionary;
        private var _itemsCount:uint;
        private var _outfits:Dictionary;
        private var _outfitsCount:uint;
        private var _effects:Dictionary;
        private var _effectsCount:uint;
        private var _missiles:Dictionary;
        private var _missilesCount:uint;
        private var _thingsCount:uint;
        private var _extended:Boolean;
        private var _improvedAnimations:Boolean;
        private var _frameGroups:Boolean;
        private var _progressCount:uint;
        private var _changed:Boolean;
        private var _loaded:Boolean;
        private var _settings:ObjectBuilderSettings;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get file():File { return _file; }
        public function get version():Version { return _version; }
        public function get signature():uint { return _signature; }
        public function get items():Dictionary { return _items; }
        public function get outfits():Dictionary { return _outfits; }
        public function get effects():Dictionary { return _effects; }
        public function get missiles():Dictionary { return _missiles; }
        public function get itemsCount():uint { return _itemsCount; }
        public function get outfitsCount():uint { return _outfitsCount; }
        public function get effectsCount():uint { return _effectsCount; }
        public function get missilesCount():uint { return _missilesCount; }
        public function get changed():Boolean { return _changed; }
        public function get isTemporary():Boolean { return (_loaded && _file == null); }
        public function get loaded():Boolean { return _loaded; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingTypeStorage(settings:ObjectBuilderSettings)
        {
            _settings = settings;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //----------------------------------
        //  Public
        //----------------------------------

        public function load(file:File,
                             version:Version,
                             extended:Boolean = false,
                             improvedAnimations:Boolean = false,
                             frameGroups:Boolean = false):void
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!version)
                throw new NullArgumentError("version");

            if (this.loaded) return;

            _version = version;
            _extended = (extended || _version.value >= 960);
            _improvedAnimations = (improvedAnimations || _version.value >= 1050);
            _frameGroups = (frameGroups || _version.value >= 1057);

            try
            {
                var reader:MetadataReader;
                if (version.value <= 730)
                    reader = new MetadataReader1();
                else if (version.value <= 750)
                    reader = new MetadataReader2();
                else if (version.value <= 772)
                    reader = new MetadataReader3();
                else if (version.value <= 854)
                    reader = new MetadataReader4();
                else if (version.value <= 986)
                    reader = new MetadataReader5();
                else
                    reader = new MetadataReader6();

                reader.settings = _settings;
                reader.open(file, FileMode.READ);
                readBytes(reader);
                reader.close();
            }
            catch(error:Error)
            {
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.getStackTrace(), error.errorID));
                return;
            }

            _file = file;
            _changed = false;
            _loaded = true;

            dispatchEvent(new StorageEvent(StorageEvent.LOAD));
            dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
        }

        public function createNew(version:Version,
                                  extended:Boolean,
                                  improvedAnimations:Boolean,
                                  frameGroups:Boolean):void
        {
            if (!version)
                throw new NullArgumentError("version");

            if (this.loaded) return;

            _version = version;
            _extended = (extended || _version.value >= 960);
            _improvedAnimations = (improvedAnimations || _version.value >= 1050);
            _frameGroups = (frameGroups || _version.value >= 1057);
            _items = new Dictionary();
            _outfits = new Dictionary();
            _effects = new Dictionary();
            _missiles = new Dictionary();
            _signature = version.datSignature;
            _itemsCount = MIN_ITEM_ID;
            _outfitsCount = MIN_OUTFIT_ID;
            _effectsCount = MIN_EFFECT_ID;
            _missilesCount = MIN_MISSILE_ID;

            _items[_itemsCount] = ThingType.create(_itemsCount, ThingCategory.ITEM, _frameGroups, _settings.getDefaultDuration(ThingCategory.ITEM));
            _outfits[_outfitsCount] = ThingType.create(_outfitsCount, ThingCategory.OUTFIT, _frameGroups, _settings.getDefaultDuration(ThingCategory.OUTFIT));
            _effects[_effectsCount] = ThingType.create(_effectsCount, ThingCategory.EFFECT, _frameGroups, _settings.getDefaultDuration(ThingCategory.EFFECT));
            _missiles[_missilesCount] = ThingType.create(_missilesCount, ThingCategory.MISSILE, _frameGroups, _settings.getDefaultDuration(ThingCategory.MISSILE));
            _changed = false;
            _loaded = true;

            dispatchEvent(new StorageEvent(StorageEvent.LOAD));
        }

        public function addThing(thing:ThingType, category:String):ChangeResult
        {
            if (!thing) {
                throw new NullArgumentError("thing");
            }

            if (!ThingCategory.getCategory(category)) {
                throw new ArgumentError(Resources.getString("invalidCategory"));
            }

            var result:ChangeResult = internalAddThing(thing, category);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        public function addThings(things:Vector.<ThingType>):ChangeResult
        {
            if (!things) {
                throw new NullArgumentError("things");
            }

            var result:ChangeResult = internalAddThings(things);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        public function replaceThing(thing:ThingType, category:String, replaceId:uint):ChangeResult
        {
            if (!thing) {
                throw new NullArgumentError("thing");
            }

            if (!ThingCategory.getCategory(category)) {
                throw new ArgumentError(Resources.getString("invalidCategory"));
            }

            if (!hasThingType(category, replaceId)) {
                throw new Error(Resources.getString(
                    "thingNotFound",
                    Resources.getString(category),
                    replaceId));
            }

            var result:ChangeResult = internalReplaceThing(thing, category, replaceId);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        /**
        * @return The replaced things.
        */
        public function replaceThings(things:Vector.<ThingType>):ChangeResult
        {
            if (!things) {
                throw new NullArgumentError("things");
            }

            var result:ChangeResult = internalReplaceThings(things);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        public function removeThing(id:uint, category:String):ChangeResult
        {
            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            if (!hasThingType(category, id)) {
                throw new Error(Resources.getString(
                    "thingNotFound",
                    Resources.getString(category),
                    id));
            }

            var result:ChangeResult = internalRemoveThing(id, category);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        /**
         * @return The property <code>list</code> of ChangeResult is an Array of ThingType.
         */
        public function removeThings(things:Vector.<uint>, category:String):ChangeResult
        {
            if (!things) {
                throw new NullArgumentError("things");
            }

            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var result:ChangeResult = internalRemoveThings(things, category);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
            return result;
        }

        public function compile(file:File, version:Version, extended:Boolean, frameDurations:Boolean, frameGroups:Boolean):Boolean
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!version)
                throw new NullArgumentError("version");

            if (!_loaded)
                return false;

            extended = (extended || version.value >= 960);
            frameDurations = (frameDurations || version.value >= 1050);
			frameGroups = (frameGroups || version.value >= 1057);

            var tmpFile:File = FileUtil.getDirectory(file).resolvePath("tmp_" + file.name);
            var done:Boolean = true;

            try
            {
                _thingsCount = _itemsCount + _outfitsCount + _effectsCount + _missilesCount;
                _progressCount = 0;

                var writer:MetadataWriter;
                if (version.value <= 730)
                    writer = new MetadataWriter1();
                else if (version.value <= 750)
                    writer = new MetadataWriter2();
                else if (version.value <= 772)
                    writer = new MetadataWriter3();
                else if (version.value <= 854)
                    writer = new MetadataWriter4();
                else if (version.value <= 986)
                    writer = new MetadataWriter5();
                else
                    writer = new MetadataWriter6();

                writer.open(tmpFile, FileMode.WRITE);
                writer.writeUnsignedInt(version.datSignature); // Write sprite signature
                writer.writeShort(_itemsCount); // Write items count
                writer.writeShort(_outfitsCount); // Write outfits count
                writer.writeShort(_effectsCount); // Write effects count
                writer.writeShort(_missilesCount); // Write missiles count

                if (!writeItemList(writer, _items, MIN_ITEM_ID, _itemsCount, version, extended, frameDurations)) {
                    done = false;
                }

                if (done && !writeThingList(writer, _outfits, MIN_OUTFIT_ID, _outfitsCount, version, extended, frameDurations, frameGroups)) {
                    done = false;
                }

                if (done && !writeThingList(writer, _effects, MIN_EFFECT_ID, _effectsCount, version, extended, frameDurations, false)) {
                    done = false;
                }

                if (done && !writeThingList(writer, _missiles, MIN_MISSILE_ID, _missilesCount, version, extended, frameDurations, false)) {
                    done = false;
                }

                writer.close();
            } catch(error:Error) {
                if (error.errorID == 3001)
                    Log.error(Resources.getString("accessDenied"));
                else
                    dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.getStackTrace(), error.errorID));

                done = false;
            }

            if (done)
            {
                var fileName:String = FileUtil.getName(file);

                // Delete old file.
                if (file.exists)
                    file.deleteFile();

                // Rename temporary file
                _file = FileUtil.rename(tmpFile, fileName);
                _changed = false;
            }
            else if (tmpFile.exists)
            {
                tmpFile.deleteFile();
            }

            dispatchEvent(new StorageEvent(StorageEvent.COMPILE));
            dispatchEvent(new StorageEvent(StorageEvent.CHANGE));

            return done;
        }

        public function hasThingType(category:String, id:uint):Boolean
        {
            if (_loaded && category) {
                switch(category) {
                    case ThingCategory.ITEM:
                        return (_items[id] !== undefined);

                    case ThingCategory.OUTFIT:
                        return (_outfits[id] !== undefined);

                    case ThingCategory.EFFECT:
                        return (_effects[id] !== undefined);

                    case ThingCategory.MISSILE:
                        return (_missiles[id] !== undefined);
                }
            }

            return false;
        }

        public function getThingType(id:uint, category:String):ThingType
        {
            if (_loaded && category) {
                switch(category) {
                    case ThingCategory.ITEM:
                        return getItemType(id);

                    case ThingCategory.OUTFIT:
                        return getOutfitType(id);

                    case ThingCategory.EFFECT:
                        return getEffectType(id);

                    case ThingCategory.MISSILE:
                        return getMissileType(id);
                }
            }

            return null;
        }

        public function getItemType(id:uint):ThingType
        {
            if (_loaded && id >= MIN_ITEM_ID && id <= _itemsCount && _items[id] !== undefined) {
                var thing:ThingType = ThingType(_items[id]);
                if (!ThingUtils.isValid(thing)) {
                    Log.error(Resources.getString("failedToGetThing", ThingCategory.ITEM, id));
                    thing = ThingUtils.createAlertThing(ThingCategory.ITEM, _settings.getDefaultDuration(ThingCategory.ITEM));
                    thing.id = id;
                }
                return thing;
            }
            return null;
        }

        public function getOutfitType(id:uint):ThingType
        {
            if (_loaded && id >= MIN_OUTFIT_ID && id <= _outfitsCount && _outfits[id] !== undefined) {
                var thing:ThingType = ThingType(_outfits[id]);
                if (!ThingUtils.isValid(thing)) {
                    Log.error(Resources.getString("failedToGetThing", ThingCategory.OUTFIT, id));
                    thing = ThingUtils.createAlertThing(ThingCategory.ITEM, _settings.getDefaultDuration(ThingCategory.ITEM));
                    thing.category = ThingCategory.OUTFIT;
                    thing.id = id;
                }
                return thing;
            }
            return null;
        }

        public function getEffectType(id:uint):ThingType
        {
            if (_loaded && id >= MIN_EFFECT_ID && id <= _effectsCount && _effects[id] !== undefined) {
                var thing:ThingType = ThingType(_effects[id]);
                if (!ThingUtils.isValid(thing)) {
                    Log.error(Resources.getString("failedToGetThing", ThingCategory.EFFECT, id));
                    thing = ThingUtils.createAlertThing(ThingCategory.ITEM, _settings.getDefaultDuration(ThingCategory.ITEM));
                    thing.category = ThingCategory.EFFECT;
                    thing.id = id;
                }
                return thing;
            }
            return null;
        }

        public function getMissileType(id:uint):ThingType
        {
            if (_loaded && id >= MIN_MISSILE_ID && id <= _missilesCount && _missiles[id] !== undefined) {
                var thing:ThingType = ThingType(_missiles[id]);
                if (!ThingUtils.isValid(thing)) {
                    Log.error(Resources.getString("failedToGetThing", ThingCategory.MISSILE, id));
                    thing = ThingUtils.createAlertThing(ThingCategory.ITEM, _settings.getDefaultDuration(ThingCategory.ITEM));
                    thing.category = ThingCategory.MISSILE;
                    thing.id = id;
                }
                return thing;
            }
            return null;
        }

        public function getMinId(category:String):uint
        {
            if (_loaded && ThingCategory.getCategory(category)) {
                switch(category) {
                    case ThingCategory.ITEM:
                        return MIN_ITEM_ID;

                    case ThingCategory.OUTFIT:
                        return MIN_OUTFIT_ID;

                    case ThingCategory.EFFECT:
                        return MIN_EFFECT_ID;

                    case ThingCategory.MISSILE:
                        return MIN_MISSILE_ID;
                }
            }

            return 0;
        }

        public function getMaxId(category:String):uint
        {
            if (_loaded && ThingCategory.getCategory(category)) {
                switch(category) {
                    case ThingCategory.ITEM:
                        return _itemsCount;

                    case ThingCategory.OUTFIT:
                        return _outfitsCount;

                    case ThingCategory.EFFECT:
                        return _effectsCount;

                    case ThingCategory.MISSILE:
                        return _missilesCount;
                }
            }

            return 0;
        }

        public function findThingTypeByProperties(category:String, properties:Vector.<ThingProperty>):Array
        {
            if (!ThingCategory.getCategory(category)) {
                throw new ArgumentError(Resources.getString("invalidCategory"));
            }

            if (!properties) {
                throw new NullArgumentError("properties");
            }

            var result:Array = [];
            if (!_loaded || properties.length == 0) return result;

            var list:Dictionary;
            var total:uint;
            var current:uint;

            switch(category) {
                case ThingCategory.ITEM:
                    list = _items;
                    total = _itemsCount;
                    current = MIN_ITEM_ID;
                    break;

                case ThingCategory.OUTFIT:
                    list = _outfits;
                    total = _outfitsCount;
                    current = MIN_OUTFIT_ID;
                    break;

                case ThingCategory.EFFECT:
                    list = _effects;
                    total = _effectsCount;
                    current = MIN_EFFECT_ID;
                    break;

                case ThingCategory.MISSILE:
                    list = _missiles;
                    total = _missilesCount;
                    current = MIN_MISSILE_ID;
                    break;
            }

            var length:uint = properties.length;

            for each (var thing:ThingType in list) {
                var equals:Boolean = true;

                for (var i:uint = 0; i < length; i++) {

                    var thingProperty:ThingProperty = properties[i];
                    var property:String = thingProperty.property;
                    if (property != null && thing.hasOwnProperty(property)) {

                        if (property == "marketName" && thing[property] != null && thingProperty.value != null)
                        {
                            var name1:String = StringUtil.toKeyString( String(thingProperty.value) );
                            var name2:String = StringUtil.toKeyString(thing[property]);
                            if (name2.indexOf(name1) == -1) {
                                equals = false;
                                break;
                            }

                        } else if (thingProperty.value != thing[property]) {
                            equals = false;
                            break;
                        }
                    }
                }

                if (equals) {
                    if (!ThingUtils.isValid(thing)) {
                        var id:uint = thing.id;
                        thing = ThingUtils.createAlertThing(ThingCategory.EFFECT, _settings.getDefaultDuration(ThingCategory.EFFECT));
                        thing.id = id;
                    }
                    result.push(thing);
                }

                if (this.hasEventListener(ProgressEvent.PROGRESS)) {
                    dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.FIND, current, total));
                }
                current++;
            }
            return result;
        }

        public function unload():void
        {
            var event:StorageEvent = new StorageEvent(StorageEvent.UNLOADING, false, true);
            dispatchEvent(event);

            if (event.isDefaultPrevented())
                return;

            _file = null;
            _items = null;
            _itemsCount = 0;
            _outfits = null;
            _outfitsCount = 0;
            _effects = null;
            _effectsCount = 0;
            _missiles = null;
            _missilesCount = 0;
            _signature = 0;
            _progressCount = 0;
            _thingsCount = 0;
            _changed = false;
            _loaded = false;

            dispatchEvent(new StorageEvent(StorageEvent.UNLOAD));
            dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
        }

        public function invalidate():void
        {
            if (!_changed) {
                _changed = true;

                if (hasEventListener(StorageEvent.CHANGE))
                    dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
        }

        //--------------------------------------
        // Intenal
        //--------------------------------------

        /**
        * @return The ChangeResult returns the thing added.
        */
        otlib_internal function internalAddThing(thing:ThingType, category:String, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var id:int;
            switch(category) {
                case ThingCategory.ITEM:
                    id = ++_itemsCount;
                    _items[id] = thing;
                    break;

                case ThingCategory.OUTFIT:
                    id = ++_outfitsCount;
                    _outfits[id] = thing;
                    break;

                case ThingCategory.EFFECT:
                    id = ++_effectsCount;
                    _effects[id] = thing;
                    break;

                case ThingCategory.MISSILE:
                    id = ++_missilesCount;
                    _missiles[id] = thing;
                    break;

                default:
                    return result.update(null, false, Resources.getString("invalidCategory"));
            }

            thing.category = category;
            thing.id = id;
            return result.update([thing], true);
        }

        /**
         * @return The property <code>list</code> of ChangeResult is an Array of ThingType.
         */
        otlib_internal function internalAddThings(things:Vector.<ThingType>, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var addedList:Array = [];
            var length:uint = things.length;

            for (var i:uint = 0; i < length; i++) {
                var thing:ThingType = things[i];
                if(!thing)
                    continue;

                var added:ChangeResult = internalAddThing(thing, thing.category, CHANGE_RESULT_HELPER);
                if (!added.done) {
                    var message:String = Resources.getString(
                        "failedToAdd",
                        Resources.getString(thing.category),
                        getMaxId(thing.category) + 1);
                    return result.update(addedList, false, message + File.lineEnding + result.message);
                }
                addedList[i] = thing;
            }
            return result.update(addedList, true);
        }

        /**
         * @return The property <code>list</code> of ChangeResult is an Array of ThingType.
         */
        otlib_internal function internalReplaceThing(thing:ThingType, category:String, replaceId:uint, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var thingReplaced:ThingType;
            switch(category)
            {
                case ThingCategory.ITEM:
                    thingReplaced = _items[replaceId];
                    _items[replaceId] = thing;
                    break;

                case ThingCategory.OUTFIT:
                    thingReplaced = _outfits[replaceId];
                    _outfits[replaceId] = thing;
                    break;

                case ThingCategory.EFFECT:
                    thingReplaced = _effects[replaceId];
                    _effects[replaceId] = thing;
                    break;

                case ThingCategory.MISSILE:
                    thingReplaced = _missiles[replaceId];
                    _missiles[replaceId] = thing;
                    break;

                default:
                    return result.update(null, false, Resources.getString("invalidCategory"));
            }

            thing.category = category;
            thing.id = replaceId;
            return result.update([thingReplaced], true);
        }

        /**
         * @return The ChangeResult returns a vector with the replaced ThingType.
         */
        otlib_internal function internalReplaceThings(things:Vector.<ThingType>, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var replacedList:Array = [];
            var length:uint = things.length;

            for (var i:uint = 0; i < length; i++) {
                var thing:ThingType = things[i];
                if(!thing)
                    continue;

                var replaced:ChangeResult = internalReplaceThing(thing,
                    thing.category,
                    thing.id,
                    CHANGE_RESULT_HELPER);
                if (!replaced.done) {
                    var message:String = Resources.getString(
                        "failedToReplace",
                        Resources.getString(thing.category),
                        thing.id);
                    return result.update(replacedList, false, message + File.lineEnding + result.message);
                }
                replacedList[i] = replaced.list[0];
            }
            return result.update(replacedList, true);
        }

        /**
         * @return The ChangeResult returns the thing removed.
         */
        otlib_internal function internalRemoveThing(id:uint, category:String, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var removedThing:ThingType;

            var duration:uint = _settings.getDefaultDuration(category);
            if (category == ThingCategory.ITEM)
            {
                removedThing = _items[id];

                if (id == _itemsCount && id != MIN_ITEM_ID)
                {
                    delete _items[id];
                    _itemsCount = Math.max(0, _itemsCount - 1);
                }
                else
                {
                    _items[id] = ThingType.create(id, category, _frameGroups, duration);
                }
            }
            else if (category == ThingCategory.OUTFIT)
            {
                removedThing = _outfits[id];

                if (id == _outfitsCount && id != MIN_OUTFIT_ID)
                {
                    delete _outfits[id];
                    _outfitsCount = Math.max(0, _outfitsCount - 1);
                }
                else
                {
                    _outfits[id] = ThingType.create(id, category, _frameGroups, duration);
                }
            }
            else if (category == ThingCategory.EFFECT)
            {
                removedThing = _effects[id];

                if (id == _effectsCount && id != MIN_EFFECT_ID)
                {
                    delete _effects[id];
                    _effectsCount = Math.max(0, _effectsCount - 1);
                }
                else
                {
                    _effects[id] = ThingType.create(id, category, _frameGroups, duration);
                }
            }
            else if (category == ThingCategory.MISSILE)
            {
                removedThing = _missiles[id];

                if (id == _missilesCount && id != MIN_MISSILE_ID)
                {
                    delete _missiles[id];
                    _missilesCount = Math.max(0, _missilesCount - 1);
                }
                else
                {
                    _missiles[id] = ThingType.create(id, category, _frameGroups, duration);
                }
            }

            return result.update([removedThing], true);
        }

        /**
         * @return The ChangeResult returns a vector with the removed ThingType.
         */
        otlib_internal function internalRemoveThings(things:Vector.<uint>, category:String, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var removedList:Array = [];
            var length:uint = things.length;

            // Removes last thing first
            things.sort(Array.NUMERIC | Array.DESCENDING);

            for (var i:uint = 0; i < length; i++) {
                var removed:ChangeResult = internalRemoveThing(things[i], category, CHANGE_RESULT_HELPER);
                if (!removed.done) {
                    var message:String = Resources.getString(
                        "failedToRemove",
                        Resources.getString(category),
                        things[i]);
                    return result.update(removedList, false, message + File.lineEnding + removed.message);
                }
                removedList[i] = removed.list[0];
            }
            return result.update(removedList, true);
        }

        //--------------------------------------
        // Protected
        //--------------------------------------

        protected function readBytes(reader:MetadataReader):void
        {
            if (reader.bytesAvailable < 12)
                throw new ArgumentError("Not enough data.");

            _items = new Dictionary();
            _outfits = new Dictionary();
            _effects = new Dictionary();
            _missiles = new Dictionary();
            _signature = reader.readSignature();
            _itemsCount = reader.readItemsCount();
            _outfitsCount = reader.readOutfitsCount();
            _effectsCount = reader.readEffectsCount();
            _missilesCount = reader.readMissilesCount();
            _thingsCount = _itemsCount + _outfitsCount + _effectsCount + _missilesCount;
            _progressCount = 0;

            // Load item list.
            if (!loadThingTypeList(reader, _items, MIN_ITEM_ID, _itemsCount, ThingCategory.ITEM))
                throw new Error("Items list cannot be created.");

            // Load outfit list.
            if (!loadThingTypeList(reader, _outfits, MIN_OUTFIT_ID, _outfitsCount, ThingCategory.OUTFIT))
                throw new Error("Outfits list cannot be created.");

            // Load effect list.
            if (!loadThingTypeList(reader, _effects, MIN_EFFECT_ID, _effectsCount, ThingCategory.EFFECT))
                throw new Error("Effects list cannot be created.");

            // Load missile list.
            if (!loadThingTypeList(reader, _missiles, MIN_MISSILE_ID, _missilesCount, ThingCategory.MISSILE))
                throw new Error("Missiles list cannot be created.");

            if (reader.bytesAvailable != 0)
                throw new Error("An unknown error occurred while reading the file '*.dat'");
        }

        protected function loadThingTypeList(reader:MetadataReader,
                                             list:Dictionary,
                                             minID:uint,
                                             maxID:uint,
                                             category:String):Boolean
        {
            var dispatchProgress:Boolean = this.hasEventListener(ProgressEvent.PROGRESS);

            for (var id:uint = minID; id <= maxID; id++) {
                var thing:ThingType = new ThingType();
                thing.id = id;
                thing.category = category;

                if (!reader.readProperties(thing))
                    return false;

                if (!reader.readTexturePatterns(thing, _extended, _improvedAnimations, _frameGroups))
                    return false;

                list[id] = thing;

                if (dispatchProgress) {
                    dispatchEvent(new ProgressEvent(
                        ProgressEvent.PROGRESS,
                        ProgressBarID.METADATA,
                        _progressCount,
                        _thingsCount));
                    _progressCount++;
                }
            }
            return true;
        }

        protected function writeThingList(writer:MetadataWriter,
                                          list:Dictionary,
                                          minId:uint,
                                          maxId:uint,
                                          version:Version,
                                          extended:Boolean,
                                          frameDurations:Boolean,
										  frameGroups:Boolean):Boolean
        {
            var dispatchProgress:Boolean = hasEventListener(ProgressEvent.PROGRESS);

            for (var id:uint = minId; id <= maxId; id++) {
                var thing:ThingType = list[id];
                if (thing) {

                    if (!writer.writeProperties(thing))
                        return false;

                    if (!writer.writeTexturePatterns(thing, extended, frameDurations, frameGroups))
                        return false;

                } else {
                    writer.writeByte(ThingSerializer.LAST_FLAG); // Close flags
                }

                if (dispatchProgress) {
                    dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.METADATA, _progressCount, _thingsCount));
                    _progressCount++;
                }
            }

            return true;
        }

        protected function writeItemList(writer:MetadataWriter,
                                         list:Dictionary,
                                         minId:uint,
                                         maxId:uint,
                                         version:Version,
                                         extended:Boolean,
                                         frameDurations:Boolean):Boolean
        {
            var dispatchProgress:Boolean = hasEventListener(ProgressEvent.PROGRESS);

            for (var id:uint = minId; id <= maxId; id++) {
                var item:ThingType = list[id];
                if (item) {

                    if (!writer.writeItemProperties(item))
                        return false;

                    if (!writer.writeTexturePatterns(item, extended, frameDurations, false))
                        return false;

                } else {
                    writer.writeByte(ThingSerializer.LAST_FLAG); // Close flags
                }

                if (dispatchProgress) {
                    dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.METADATA, _progressCount, _thingsCount));
                    _progressCount++;
                }
            }

            return true;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const MIN_ITEM_ID:uint = 100;
        public static const MIN_OUTFIT_ID:uint = 1;
        public static const MIN_EFFECT_ID:uint = 1;
        public static const MIN_MISSILE_ID:uint = 1;
        private static const CHANGE_RESULT_HELPER:ChangeResult = new ChangeResult();
    }
}
