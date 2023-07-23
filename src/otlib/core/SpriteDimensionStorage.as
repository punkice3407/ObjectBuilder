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

package otlib.core
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    import nail.errors.FileNotFoundError;
    import nail.errors.NullArgumentError;
    import nail.errors.SingletonClassError;
    import otlib.utils.ClientInfo;


    [Event(name="change", type="flash.events.Event")]

    public class SpriteDimensionStorage extends EventDispatcher implements ISpriteDimensionStorage
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _file:File;
        private var _dimensions:Dictionary;
        private var _changed:Boolean;
        private var _loaded:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get file():File { return _file; }
        public function get changed():Boolean { return _changed; }
        public function get loaded():Boolean { return _loaded; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteDimensionStorage()
        {
            if (_instance)
                throw new SingletonClassError(SpriteDimensionStorage);

            _instance = this;
            _dimensions = new Dictionary();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load(file:File):Boolean
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!file.exists)
                throw new FileNotFoundError(file);

            if (this.loaded)
                unload();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var xml:XML = XML( stream.readUTFBytes(stream.bytesAvailable) );
            stream.close();

            if (xml.localName() != "sprites")
                throw new Error("Invalid versions XML.");

            for each (var spriteXML:XML in xml.sprite) {

                var spriteDimension:SpriteDimension = new SpriteDimension();
                spriteDimension.unserialize(spriteXML);

                _dimensions[spriteDimension.value] = spriteDimension;
            }

            _file = file;
            _changed = false;
            _loaded = true;
            dispatchEvent(new Event(Event.COMPLETE));

            return _loaded;
        }

        public function getList():Array
        {
            var list:Array = [];

            for each (var spriteDimension:SpriteDimension in _dimensions)
            list[list.length] = spriteDimension;

            if (list.length > 1)
                list.sortOn("size", Array.NUMERIC);

            return list;
        }

        public function getBySizes(size:uint, dataSize:uint):SpriteDimension
        {
            for each (var spriteDimension:SpriteDimension in _dimensions) {
                if (spriteDimension.size == size &&
                    spriteDimension.dataSize == dataSize)
                    return spriteDimension;
            }
            return null;
        }

        public function getFromClientInfo(info:ClientInfo):SpriteDimension
        {
            if (info.spriteSize <= 0 || info.spriteDataSize <= 0)
                return null;

            for each (var spriteDimension:SpriteDimension in _dimensions) {
                if (spriteDimension.size == info.spriteSize &&
                    spriteDimension.dataSize == info.spriteDataSize)
                    return spriteDimension;
            }
            return null;
        }

        public function unload():void
        {
            _file = null;
            _dimensions = new Dictionary();
            _changed = false;
            _loaded = false;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static var _instance:ISpriteDimensionStorage;
        public static function getInstance():ISpriteDimensionStorage
        {
            if (!_instance)
                new SpriteDimensionStorage();

            return _instance;
        }
    }
}

