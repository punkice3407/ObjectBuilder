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

package otlib.components
{
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.utils.Timer;

    import spark.components.TextInput;
    import spark.events.TextOperationEvent;

    import otlib.events.FileTextInputEvent;

    [Event(name="fileChange", type="otlib.events.FileTextInputEvent")]

    public class FileTextInput extends TextInput
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _file:File;
        private var _fileChanged:Boolean;
        private var _timer:Timer;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        [Bindable("fileChange")]
        public function get file():File { return _file; }
        public function set file(value:File):void
        {
            _file = value;
            _fileChanged = true;
            invalidateProperties();
            dispatchEvent(new FileTextInputEvent(FileTextInputEvent.FILE_CHANGE, _file));
        }

        public function exists():Boolean { return (_file && _file.exists); }
        public function isDirectory():Boolean { return (_file && _file.isDirectory); }
        public function nativePath():String { return _file ? _file.nativePath : null; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //
        //--------------------------------------------------------------------------

        public function FileTextInput()
        {
            super();

            _timer = new Timer(1000, 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
            this.addEventListener(TextOperationEvent.CHANGING, textChangingHandler);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_fileChanged) {
                setFile(_file);
                _fileChanged = false;
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function setFile(file:File):void
        {
            var path:String = file ? file.nativePath : null;
            this.text = path;
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function textChangingHandler(event:TextOperationEvent):void
        {
            _timer.reset();
            _timer.start();
        }

        protected function timerCompleteHandler(event:TimerEvent):void
        {
            var file:File;

            try
            {
                file = new File(this.text);
            } catch(error:Error) {
                file = null;
            }

            this.file = file;
        }
    }
}
