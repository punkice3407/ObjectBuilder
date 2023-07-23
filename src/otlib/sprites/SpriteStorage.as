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

package otlib.sprites
{
    import flash.display.BitmapData;
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;

    import nail.errors.NullArgumentError;
    import nail.logging.Log;
    import nail.utils.FileUtil;

    import ob.commands.ProgressBarID;

    import otlib.assets.Assets;
    import otlib.core.Version;
    import otlib.core.otlib_internal;
    import otlib.events.ProgressEvent;
    import otlib.resources.Resources;
    import otlib.storages.IStorage;
    import otlib.storages.events.StorageEvent;
    import otlib.utils.ChangeResult;
    import otlib.utils.SpriteUtils;
    import otlib.utils.SpriteExtent;

    use namespace otlib_internal;

    [Event(name="progress", type="flash.events.ProgressEvent")]
    [Event(name="load", type="otlib.storages.events.StorageEvent")]
    [Event(name="compile", type="otlib.storages.events.StorageEvent")]
    [Event(name="change", type="otlib.storages.events.StorageEvent")]
    [Event(name="unloading", type="otlib.storages.events.StorageEvent")]
    [Event(name="unload", type="otlib.storages.events.StorageEvent")]
    [Event(name="error", type="flash.events.ErrorEvent")]

    public class SpriteStorage extends EventDispatcher implements IStorage
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        otlib_internal var _sprites:Dictionary;
        otlib_internal var _spritesCount:uint;

        private var _file:File;
        private var _reader:SpriteReader;
        private var _version:Version;
        private var _signature:uint;
        private var _extended:Boolean;
        private var _transparency:Boolean;
        private var _rect:Rectangle;
        private var _point:Point;
        private var _blankSprite:Sprite;
        private var _alertSprite:Sprite;
        private var _headerSize:uint;
        private var _changed:Boolean;
        private var _loaded:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get file():File { return _file; }
        public function get version():Version { return _version; }
        public function get signature():uint { return _signature; }
        public function get spritesCount():uint { return _spritesCount; }
        public function get loaded():Boolean { return _loaded; }
        public function get changed():Boolean { return _changed; }
        public function get isFull():Boolean { return (!_extended && _spritesCount == 0xFFFF); }
        public function get transparency():Boolean { return _transparency; }
        public function get alertSprite():Sprite { return _alertSprite; }
        public function get isTemporary():Boolean { return (_loaded && _file == null); }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteStorage()
        {
            _rect = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
            _point = new Point();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load(file:File, version:Version, extended:Boolean, transparency:Boolean):void
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!version)
                throw new NullArgumentError("version");

            if (loaded)
                return;

            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.SPRITES, 0, 100));
            onLoad(file, version, extended, transparency, false);
        }

        public function createNew(version:Version, extended:Boolean, transparency:Boolean):void
        {
            if (!version)
                throw new NullArgumentError("version");

            if (this.loaded) return;

            _version = version;
            _extended = (extended || version.value >= 960);
            _signature = version.sprSignature;
            _spritesCount = 1;
            _headerSize = _extended ? SpriteFileSize.HEADER_U32 : SpriteFileSize.HEADER_U16;
            _transparency = transparency;
            _blankSprite = new Sprite(0, transparency);
            _alertSprite = createAlertSprite(transparency);
            _sprites = new Dictionary();
            _sprites[0] = _blankSprite;
            _sprites[1] = new Sprite(1, transparency);
            _changed = false;
            _loaded = true;

            dispatchEvent(new StorageEvent(StorageEvent.LOAD));
        }

        public function addSprite(pixels:ByteArray):ChangeResult
        {
            if (!pixels) {
                throw new NullArgumentError("pixels");
            }

            var result:ChangeResult = internalAddSprite(pixels);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function addSprites(sprites:Vector.<ByteArray>):ChangeResult
        {
            if (!sprites) {
                throw new NullArgumentError("sprites");
            }

            var result:ChangeResult = internalAddSprites(sprites);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function replaceSprite(id:uint, pixels:ByteArray):ChangeResult
        {
            if (id == 0 || id > _spritesCount) {
                throw new ArgumentError(Resources.getString("indexOutOfRange"));
            }

            if (!pixels) {
                throw new NullArgumentError("pixels");
            }

            if (pixels.length != SpriteExtent.DEFAULT_DATA_SIZE) {
                throw new ArgumentError("Parameter pixels has an invalid length.");
            }

            var result:ChangeResult = internalReplaceSprite(id, pixels);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function replaceSprites(sprites:Vector.<SpriteData>):ChangeResult
        {
            if (!sprites) {
                throw new NullArgumentError("sprites");
            }

            var result:ChangeResult = internalReplaceSprites(sprites);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function removeSprite(id:uint):ChangeResult
        {
            if (id == 0 || id > _spritesCount) {
                throw new ArgumentError(Resources.getString("indexOutOfRange"));
            }

            var result:ChangeResult = internalRemoveSprite(id);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function removeSprites(sprites:Vector.<uint>):ChangeResult
        {
            if (!sprites) {
                throw new NullArgumentError("sprites");
            }

            var result:ChangeResult = internalRemoveSprites(sprites);
            if (result.done && hasEventListener(StorageEvent.CHANGE)) {
                _changed = true;
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }

            return result;
        }

        public function getSprite(id:uint):Sprite
        {
            if (id == uint.MAX_VALUE) return _alertSprite;

            if (_loaded && id <= _spritesCount) {
                var sprite:Sprite;
                if (_sprites[id] !== undefined)
                    sprite = Sprite(_sprites[id]);
                else
                    sprite = readSprite(id);

                if (!sprite) {
                    sprite = _blankSprite;
                }

                return sprite;
            }
            return null;
        }

        public function getPixels(id:uint):ByteArray
        {
            if (_loaded) {
                var sprite:Sprite = getSprite(id);
                if (sprite) {
                    var pixels:ByteArray;
                    try
                    {
                        pixels =  sprite.getPixels();
                    } catch (error:Error) {
                        Log.error(Resources.getString("failedToGetSprite", id), error.getStackTrace());
                        return _alertSprite.getPixels();
                    }
                    return pixels;
                }
            }
            return null;
        }

        /**
         * Copies the pixels of a sprite to a bitmap.
         *
         * @param id The id of sprite.
         * @param bitmap The destination bitmap.
         * @param x The X destination point that represents the upper-left corner
         * of the SpriteExtent x SpriteExtent area where the new pixels are placed.
         * @param y The Y destination point that represents the upper-left corner of
         * the SpriteExtent x SpriteExtent area where the new pixels are placed.
         */
        public function copyPixels(id:int, bitmap:BitmapData, x:int, y:int):void
        {
            if (!this.loaded || !bitmap) return;

            try
            {
                var sprite:BitmapData = getBitmap(id, true);
                if (!sprite) return;

                _point.x = x;
                _point.y = y;

                bitmap.copyPixels(sprite, _rect, _point, null, null, true);
            }
            catch(error:Error)
            {
                bitmap.copyPixels(SpriteUtils.createAlertBitmap(), _rect, _point, null, null, true);
                Log.error(Resources.getString("failedToGetSprite", id), error.getStackTrace());
            }
        }

        /**
         * @param backgroundColor A 32-bit ARGB color value.
         */
        public function getBitmap(id:uint, transparent:Boolean):BitmapData
        {
            if (!this.loaded || id == 0)
                return null;

            var sprite:Sprite = getSprite(id);
            if (!sprite)
                return null;

            var bitmap:BitmapData = sprite.getBitmap();
            if (!transparent)
                bitmap = SpriteUtils.fillBackground(bitmap);

            return bitmap;
        }

        public function hasSpriteId(id:uint):Boolean
        {
            if (_loaded && id <= _spritesCount)
            {
                return true;
            }
            return false;
        }

        /**
         * Checks if a sprite id and a sprite pixels are equal.
         *
         * @param id The id of the sprite to compare.
         * @param pixels Sprite pixels to compare.
         */
        public function compare(id:uint, pixels:ByteArray):Boolean
        {
            if (!pixels) {
                throw new NullArgumentError("pixels");
            }

            if (pixels.length != SpriteExtent.DEFAULT_DATA_SIZE) {
                throw new ArgumentError("Parameter pixels has an invalid length.");
            }

            if (hasSpriteId(id)) {
                pixels.position = 0;
                var bmp1:BitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, 0xFFFF00FF);
                bmp1.setPixels(bmp1.rect, pixels);
                var otherPixels:ByteArray = this.getPixels(id);
                otherPixels.position = 0;
                var bmp2:BitmapData = new BitmapData(SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE, true, 0xFFFF00FF);
                bmp2.setPixels(bmp2.rect, otherPixels);
                return (bmp1.compare(bmp2) == 0);
            }
            return false;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function readSprite(id:uint):Sprite
        {
            try
            {
                return _reader.readSprite(id);
            }
            catch(error:Error)
            {
                Log.error(Resources.getString("failedToGetSprite", id), error.getStackTrace());
                return _alertSprite;
            }

            return null;
        }

        public function compile(file:File, version:Version, extended:Boolean, transparency:Boolean):Boolean
        {
            if (!file) {
                throw new NullArgumentError("file");
            }

            if (!version) {
                throw new NullArgumentError("version");
            }

            if (!_loaded) return false;

            extended = (extended || version.value >= 960);
            var equal:Boolean = FileUtil.equals(_file, file);
            var stream:FileStream;

            // If is unmodified and the version is equal only save raw bytes.
            if (!this.isTemporary &&
                !this.changed &&
                _version.equals(version) &&
                _extended == extended &&
                _transparency == transparency)
            {
                if (!equal)
                    FileUtil.copyToAsync(_file, file);

                dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.SPRITES, _spritesCount, _spritesCount));
                return true;
            }

            var tmpFile:File = FileUtil.getDirectory(file).resolvePath("tmp_" + file.name);
            var done:Boolean;
            var headSize:uint;
            var count:uint;

            try
            {
                stream = new FileStream();
                stream.open(tmpFile, FileMode.WRITE);
                stream.endian = Endian.LITTLE_ENDIAN;
                stream.writeUnsignedInt(version.sprSignature); // Write spr signature.

                // Write sprites count.
                if (extended || version.value >= 960) {
                    count = _spritesCount;
                    headSize = SpriteFileSize.HEADER_U32;
                    stream.writeUnsignedInt(count);
                } else {
                    count = _spritesCount >= 0xFFFF ? 0xFFFE : _spritesCount;
                    headSize = SpriteFileSize.HEADER_U16;
                    stream.writeShort(count);
                }

                var addressPosition:uint = stream.position;
                var offset:uint = (count * 4) + headSize;
                var dispatchProgess:Boolean = this.hasEventListener(ProgressEvent.PROGRESS);
                var progressEvent:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.SPRITES);
                progressEvent.total = count;

                for (var i:uint = 1; i <= count; i++) {
                    stream.position = addressPosition;

                    var sprite:Sprite = getSprite(i);

                    if(sprite.isEmpty) {
                        stream.writeUnsignedInt(0); // Write address
                    } else {
                        sprite.transparent = transparency;
                        sprite.compressedPixels.position = 0;

                        stream.writeUnsignedInt(offset); // Write address
                        stream.position = offset;
                        stream.writeByte(0xFF);          // Write red
                        stream.writeByte(0x00);          // Write blue
                        stream.writeByte(0xFF);          // Write green
                        stream.writeShort(sprite.length);  // Write sprite data size

                        if (sprite.length > 0) {
                            stream.writeBytes(sprite.compressedPixels, 0, sprite.length);
                        }

                        offset = stream.position;
                    }

                    addressPosition += 4;

                    if (dispatchProgess && (i % 10) == 0) {
                        progressEvent.loaded = i;
                        dispatchEvent(progressEvent);
                    }
                }

                stream.close();
                done = true;
            }
            catch(error:Error)
            {
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.getStackTrace(), error.errorID));
                done = false;
            }

            if (done)
            {
                // Closes the current spr file
                if (equal)
                    _reader.close();

                // Delete old file.
                if (file.exists)
                    file.deleteFile();

                // Rename the temporary file
                _file = FileUtil.rename(tmpFile, FileUtil.getName(file));

                // Reload all if equal.
                if (equal)
                    this.onLoad(file, version, extended, transparency, true);
            }
            else if (tmpFile.exists)
            {
                tmpFile.deleteFile();
            }

            dispatchEvent(new StorageEvent(StorageEvent.COMPILE));
            dispatchEvent(new StorageEvent(StorageEvent.CHANGE));

            return done;
        }

        public function isEmptySprite(id:uint):Boolean
        {
            if (_loaded && id <= _spritesCount) {
                if (_sprites[id] !== undefined)
                    return Sprite(_sprites[id]).isEmpty;
                else
                    return _reader.isEmptySprite(id);
            }
            return true;
        }

        public function unload():void
        {
            var event:StorageEvent = new StorageEvent(StorageEvent.UNLOADING, false, true);
            dispatchEvent(event);

            if (event.isDefaultPrevented())
                return;

            if (_reader) {
                _reader.close();
                _reader = null;
            }

            _file = null;
            _loaded = false;
            _signature = 0;
            _extended = false;
            _transparency = false;
            _version = null;
            _sprites = null;
            _spritesCount = 0;
            _blankSprite = null;
            _alertSprite = null;
            _headerSize = 0;

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
        // Internal
        //--------------------------------------

        otlib_internal function internalAddSprite(pixels:ByteArray, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            if (pixels.length != SpriteExtent.DEFAULT_DATA_SIZE) {
                return result.update(null, false, "Parameter pixels has an invalid length.");
            }

            if (this.isFull) {
                return result.update(null, false, Resources.getString("spritesLimitReached"));
            }

            var id:uint = ++_spritesCount;
            var sprite:Sprite = new Sprite(id, _transparency);
            if (!sprite.setPixels(pixels)) {
                var message:String = Resources.getString(
                    "failedToAdd",
                    Resources.getString("sprite"),
                    id);
                return result.update(null, false, message);
            }

            // Add sprite to list.
            _sprites[id] = sprite;
            _spritesCount = id;

            // Returns the pixels buffer position.
            pixels.position = 0;

            var data:SpriteData = SpriteData.createSpriteData(id, sprite.getPixels());
            return result.update([data], true);
        }

        otlib_internal function internalAddSprites(sprites:Vector.<ByteArray>, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var addedList:Array = [];
            var length:uint = sprites.length;
            for (var i:uint = 0; i < length; i++) {
                var added:ChangeResult = internalAddSprite(sprites[i], CHANGE_RESULT_HELPER);
                if (!added.done) {
                    return result.update(addedList, false, added.message);
                }
                addedList[i] = added.list[0];
            }
            return result.update(addedList, true);
        }

        otlib_internal function internalReplaceSprite(id:uint, pixels:ByteArray, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            if (id == 0)
                return result.update(null, true);

            var sprite:Sprite = new Sprite(id, _transparency);
            if (!sprite.setPixels(pixels)) {
                var message:String = Resources.getString(
                    "failedToReplace",
                    Resources.getString("sprite"),
                    id);
                return result.update(null, false, message);
            }

            // Get the removed sprite.
            var removed:Sprite = getSprite(id);

            // Add sprite to list.
            _sprites[id] = sprite;

            // Return the ByteArray position.
            pixels.position = 0;
            var data:SpriteData = SpriteData.createSpriteData(id, removed.getPixels());
            return result.update([data], true);
        }

        otlib_internal function internalReplaceSprites(sprites:Vector.<SpriteData>, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var replacedList:Array = [];
            var length:uint = sprites.length;

            for (var i:uint = 0; i < length; i++) {
                var id:uint = sprites[i].id;
                var pixels:ByteArray = sprites[i].pixels;
                var replaced:ChangeResult = internalReplaceSprite(id, pixels, CHANGE_RESULT_HELPER);
                if (!replaced.done) {
                    return result.update(replacedList, false, replaced.message);
                }

                if (replaced.list)
                    replacedList[i] = replaced.list[0];
            }
            return result.update(replacedList, true);
        }

        otlib_internal function internalRemoveSprite(id:uint, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            // Get the removed sprite.
            var removed:Sprite = getSprite(id);

            if (id == _spritesCount && id != 1) {
                delete _sprites[id];
                _spritesCount--;
            } else {
                // Add a blank sprite at index.
                _sprites[id] = new Sprite(id, _transparency);
            }

            var data:SpriteData = SpriteData.createSpriteData(id, removed.getPixels());
            return result.update([data], true);
        }

        otlib_internal function internalRemoveSprites(sprites:Vector.<uint>, result:ChangeResult = null):ChangeResult
        {
            result = result ? result : new ChangeResult();

            var removedList:Array = [];
            var length:uint = sprites.length;

            // Removes last sprite first
            sprites.sort(Array.NUMERIC | Array.DESCENDING);

            for (var i:uint = 0; i < length; i++) {
                var id:uint = sprites[i];
                if (id != 0 && hasSpriteId(id)) {
                    var removed:ChangeResult = internalRemoveSprite(id, CHANGE_RESULT_HELPER);
                    if (!removed.done) {
                        return result.update(removedList, false, removed.message);
                    }
                    removedList[removedList.length] = removed.list[0];
                }
            }
            return result.update(removedList, true);
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function onLoad(file:File,
                                version:Version,
                                extended:Boolean,
                                transparency:Boolean,
                                reloading:Boolean):void
        {
            if (!file.exists) {
                Log.error(Resources.getString("fileNotFound", file.nativePath));
                return;
            }

            _file = file;
            _version = version;
            _extended = (extended || version.value >= 960);
            _transparency = transparency;
            _reader = new SpriteReader(_extended, _transparency);
            _reader.open(file, FileMode.READ);
            _signature = _reader.readSignature();
            _spritesCount = _reader.readSpriteCount();
            _headerSize = _extended ? SpriteFileSize.HEADER_U32 : SpriteFileSize.HEADER_U16;
            _blankSprite = new Sprite(0, transparency);
            _alertSprite = createAlertSprite(transparency);
            _sprites = new Dictionary();
            _sprites[0] = _blankSprite;
            _changed = false;
            _loaded = true;

            if (!reloading)
            {
                dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.SPRITES, _spritesCount, _spritesCount));
                dispatchEvent(new StorageEvent(StorageEvent.LOAD));
                dispatchEvent(new StorageEvent(StorageEvent.CHANGE));
            }
        }

        private function createAlertSprite(transparent:Boolean):Sprite
        {
            var bitmap:BitmapData = SpriteUtils.createAlertBitmap();
            var sprite:Sprite = new Sprite(uint.MAX_VALUE, transparent);
            sprite.setPixels( bitmap.getPixels(bitmap.rect) );
            return sprite;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const CHANGE_RESULT_HELPER:ChangeResult = new ChangeResult();
    }
}
