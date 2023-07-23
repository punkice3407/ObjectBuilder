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

package otlib.loaders
{
    import com.voidelement.images.BMPDecoder;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    import nail.errors.NullArgumentError;
    import nail.image.ImageFormat;
    import ob.commands.ProgressBarID;

    import otlib.events.ProgressEvent;
    import otlib.resources.Resources;
    import otlib.sprites.SpriteData;
    import otlib.utils.SpriteUtils;
    import otlib.utils.SpriteExtent;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]
    [Event(name="error", type="flash.events.ErrorEvent")]

    public class SpriteDataLoader extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _spriteDataList:Vector.<SpriteData>;
        private var _files:Vector.<PathHelper>;
        private var _index:int;
        private var _cancel:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get spriteDataList():Vector.<SpriteData> { return _spriteDataList; }
        public function get length():uint { return _files ? _files.length : 0; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteDataLoader()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load(file:PathHelper):void
        {
            if (!file) {
                throw new NullArgumentError("file");
            }

            this.onLoad(Vector.<PathHelper>([file]));
        }

        public function loadFiles(files:Vector.<PathHelper>):void
        {
            if (!files) {
                throw new NullArgumentError("files");
            }

            if (files.length > 0) {
                this.onLoad(files);
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function onLoad(files:Vector.<PathHelper>):void
        {
            _files = files;
            _spriteDataList = new Vector.<SpriteData>();
            _index = -1;
            loadNext();
        }

        private function loadNext():void
        {
            if (_cancel) {
                _spriteDataList = null;
                _files = null;
                _index = -1;
                return;
            }

            _index++;

            if (hasEventListener(ProgressEvent.PROGRESS)) {
                dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, _index, _files.length));
            }

            if (_index >= _files.length) {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }

            var file:File = new File(_files[_index].nativePath);
            if (ImageFormat.hasImageFormat(file.extension)) {
                if (file.extension == ImageFormat.BMP)
                    loadImageFormat1(file, _files[_index].id);
                else
                    loadImageFormat2(file, _files[_index].id);
            } else {
                loadNext();
            }
        }

        private function loadImageFormat1(file:File, id:uint):void
        {
            var request:URLRequest = new URLRequest(file.url);
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.load(request);

            function completeHandler(event:Event):void
            {
                var bitmap:BitmapData;
                try
                {
                    if (file.extension == ImageFormat.BMP) {
                        bitmap = new BMPDecoder().decode(loader.data as ByteArray);
                    }
                } catch(error:Error) {

                    _cancel = true;
                    dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.getStackTrace()));
                    return;
                }

                create(id, bitmap);
                loadNext();
            }
        }

        private function loadImageFormat2(file:File, id:uint):void
        {
            var request:URLRequest = new URLRequest(file.url);
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            loader.load(request);

            function completeHandler(event:Event):void
            {
                create(id, Bitmap(loader.content).bitmapData);
                loadNext();
            }

            function errorHandler(event:IOErrorEvent):void
            {
                _spriteDataList = null;
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, event.text, event.errorID));
            }
        }

        private function create(id:uint, bitmap:BitmapData):void
        {
            if (bitmap.width != SpriteExtent.DEFAULT_SIZE || bitmap.height != SpriteExtent.DEFAULT_SIZE) {
                _cancel = true;
                dispatchEvent(new ErrorEvent(
                    ErrorEvent.ERROR,
                    false,
                    false,
                    Resources.getString("invalidSpriteSize", SpriteExtent.DEFAULT_VALUE)));
                return;
            }

            bitmap = SpriteUtils.removeMagenta(bitmap);
            var spriteData:SpriteData = new SpriteData();
            spriteData.id = id;
            spriteData.pixels = bitmap.getPixels(bitmap.rect);
            _spriteDataList.push(spriteData);
        }
    }
}
