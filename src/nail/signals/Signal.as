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

package nail.signals
{
    public class Signal
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_callbacks:Vector.<Function>;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Signal()
        {
            m_callbacks = new Vector.<Function>();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function addCallback(callback:Function):Boolean
        {
            if (callback != null && m_callbacks.indexOf(callback) == -1)
            {
                m_callbacks.push(callback);
                return true;
            }

            return false;
        }

        public function hasCallback(callback:Function):Boolean
        {
            if (callback != null)
            {
                var i:int = m_callbacks.indexOf(callback);
                if (i != -1) return true;
            }

            return false;
        }

        public function removeCallback(callback:Function):Boolean
        {
            if (callback != null)
            {
                var i:int = m_callbacks.indexOf(callback);
                if (i > -1)
                {
                    m_callbacks.splice(i, 1);
                    return true;
                }
            }

            return false;
        }

        public function removeAll():Boolean
        {
            m_callbacks.length = 0;
            return true;
        }

        public function dispatch(args:Array):void
        {
            for (var i:uint = 0; i < m_callbacks.length; i++)
                m_callbacks[i].apply(null, args);
        }

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get length():uint
        {
            return m_callbacks.length;
        }
    }
}
