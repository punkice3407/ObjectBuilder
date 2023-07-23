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

package otlib.storages
{
    import com.mignari.errors.NullArgumentError;

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import otlib.storages.events.StorageEvent;

    [Event(name="complete", type="flash.events.Event")]

    public class StorageQueueLoader extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_storages:Vector.<StorageData>;
        private var m_index:int;
        private var m_running:Boolean;
        private var m_loaded:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get running():Boolean { return m_running; }
        public function get loaded():Boolean { return m_loaded; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function StorageQueueLoader()
        {

        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function add(storage:IStorage, callback:Function, ...args):void
        {
            if (!storage)
            {
                throw new NullArgumentError("storage");
            }

            if (!m_storages)
            {
                m_storages = new Vector.<StorageData>();
            }
            else
            {
                for (var i:int = m_storages.length - 1; i >= 0; i--)
                {
                    if (m_storages[i].callback === callback)
                    {
                        return;
                    }
                }
            }

            addHandlers(storage);
            m_storages[m_storages.length] = new StorageData(storage, callback, args);
        }

        public function start():void
        {
            if (m_running)
            {
                return;
            }

            m_index = -1;
            m_running = true;
            m_loaded = false;

            loadNext();
        }

        //--------------------------------------
        // Protected
        //--------------------------------------

        protected function addHandlers(storage:IStorage):void
        {
            storage.addEventListener(StorageEvent.LOAD, storageHandler);
        }

        protected function removeHandlers(storage:IStorage):void
        {
            storage.removeEventListener(StorageEvent.LOAD, storageHandler);
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function loadNext():void
        {
            m_index++;
            if (m_index >= m_storages.length)
            {
                m_running = false;
                m_loaded = true;
                dispatchEvent(new Event(Event.COMPLETE));
            }
            else
            {
                m_storages[m_index].perform();
            }
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function storageHandler(event:StorageEvent):void
        {
            removeHandlers(IStorage(event.target));
            loadNext();
        }
    }
}
