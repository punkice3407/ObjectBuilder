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

package nail.logging
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import mx.core.mx_internal;
    import mx.logging.targets.LineFormattedTarget;

    import nail.utils.Descriptor;
    import nail.utils.StringUtil;
    import nail.utils.isNullOrEmpty;

    use namespace mx_internal;

    public class LogFileTarget extends LineFormattedTarget
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_file:File;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get logURI():String { return m_file.url; }
        public function get logFile():File { return m_file; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function LogFileTarget(file:File = null)
        {
            if (!file)
                file = createLogFile();

            m_file = file;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function writeStart():void
        {
            var text:String = StringUtil.format("\n=== {0} {1} started at " + (new Date()).toString() + " ===\n", Descriptor.getName(), Descriptor.getVersionNumber());
            write(text);
        }

        public function write(message:String):void
        {
            if (!isNullOrEmpty(message))
            {
                var stream:FileStream = new FileStream();
                stream.open(m_file, FileMode.APPEND);
                stream.writeUTFBytes(message + File.lineEnding);
                stream.close();
            }
        }

        public function writeEnd():void
        {
            var text:String = "=== Aplication closed at " + (new Date()).toString() + " ===";
            write(text);
        }

        public function clear():void
        {
            if (m_file.exists)
            {
                var stream:FileStream = new FileStream();
                stream.open(m_file, FileMode.WRITE);
                stream.writeUTFBytes("");
                stream.close();
            }
        }

        //--------------------------------------
        // Internal
        //--------------------------------------

        mx_internal override function internalLog(message:String):void
        {
            write(message);
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function createLogFile():File
        {
            var name:String = StringUtil.toKeyString(Descriptor.getName());
            return File.applicationStorageDirectory.resolvePath(name + ".log");
        }
    }
}
