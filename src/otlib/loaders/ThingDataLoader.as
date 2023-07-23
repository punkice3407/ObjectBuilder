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
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    import nail.errors.NullArgumentError;

    import ob.commands.ProgressBarID;

    import otlib.events.ProgressEvent;
    import otlib.obd.OBDEncoder;
    import otlib.things.ThingData;
    import otlib.utils.OTFormat;
    import ob.settings.ObjectBuilderSettings;

    [Event(name="progress", type="otlib.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]
    [Event(name="error", type="flash.events.ErrorEvent")]

    public class ThingDataLoader extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _encoder:OBDEncoder;
        private var _thingDataList:Vector.<ThingData>;
        private var _files:Vector.<PathHelper>;
        private var _index:int;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get thingDataList():Vector.<ThingData> { return _thingDataList; }
        public function get length():uint { return _files ? _files.length : 0; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingDataLoader(settings:ObjectBuilderSettings)
        {
            _encoder = new OBDEncoder(settings);
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
            _thingDataList = new Vector.<ThingData>();
            _index = -1;
            loadNext();
        }

        private function loadNext():void
        {
            _index++;

            if (hasEventListener(ProgressEvent.PROGRESS)) {
                dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, ProgressBarID.DEFAULT, _index, _files.length));
            }

            if (_index >= _files.length) {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }

            var file:File = new File(_files[_index].nativePath);
            if (file.extension == OTFormat.OBD)
                loadOBD(file, _files[_index].id);
            else
                loadNext();
        }

        private function loadOBD(file:File, id:uint):void
        {
            var request:URLRequest = new URLRequest(file.url);
            var loader:URLLoader  = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.load(request);

            function completeHandler(event:Event):void
            {
                try
                {
                    var thingData:ThingData = _encoder.decode(ByteArray(loader.data));
                    thingData.thing.id = id;
                    _thingDataList.push(thingData);
                } catch(error:Error) {
                    _thingDataList = null;
                    dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message, error.errorID));
                    return;
                }
                loadNext();
            }
        }
    }
}
