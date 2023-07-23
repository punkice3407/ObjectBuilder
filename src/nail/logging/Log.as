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
    import com.mignari.workers.IWorkerCommunicator;

    import nail.commands.LogCommand;
    import nail.errors.AbstractClassError;

    public final class Log
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Log()
        {
            throw new AbstractClassError(Log);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const ALL:uint = 0;
        public static const DEBUG:uint = 2;
        public static const INFO:uint = 4;
        public static const WARN:uint = 6;
        public static const ERROR:uint = 8;
        public static const FATAL:uint = 1000;

        public static var commnunicator:IWorkerCommunicator;

        public static function debug(message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(Log.DEBUG, message, stack, id));
        }

        public static function info(message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(Log.INFO, message, stack, id));
        }

        public static function warn(message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(Log.WARN, message, stack, id));
        }

        public static function error(message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(Log.ERROR, message, stack, id));
        }

        public static function fatal(message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(Log.FATAL, message, stack, id));
        }

        public static function log(level:uint, message:String, stack:String = null, id:uint = 0):void
        {
            commnunicator.sendCommand(new LogCommand(level, message, stack, id));
        }
    }
}
