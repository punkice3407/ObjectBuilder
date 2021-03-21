package store
{
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    
    import spark.components.List;
    
    import store.events.AssetStoreEvent;

    [Event(name="importAsset", type="store.events.AssetStoreEvent")]

    public final class StoreList extends List
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_collection:ArrayCollection;
        private var m_currentIndex:int;
        private var m_loaded:Boolean;
        private var m_canceled:Boolean

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function StoreList()
        {
            m_collection = new ArrayCollection();
            dataProvider = m_collection;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function addAsset(asset:StoreAsset):void
        {
            m_collection.addItem(asset);
        }

        public function getAsset(index:int):StoreAsset
        {
            if (index < 0 || index >= m_collection.length)
                return null;

            return m_collection.getItemAt(index) as StoreAsset;
        }

        public function load():void
        {
            if (m_loaded)
                return;

            m_currentIndex = -1;
            m_canceled = false;
            loadNext();
        }

        public function clear():void
        {
            m_collection.removeAll();
            m_canceled = true;
            m_loaded = false;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function loadNext():void
        {
            if (m_canceled)
                return;

            m_currentIndex++;
            if (m_currentIndex >= m_collection.length) {
                m_loaded = true;
                return;
            }

            var asset:StoreAsset = getAsset(m_currentIndex);
            asset.addEventListener(Event.COMPLETE, completeHandler);
            asset.load();

            function completeHandler(event:Event):void
            {
                asset.removeEventListener(Event.COMPLETE, completeHandler);
                m_collection.refresh();
                loadNext();
            }
        }
    }
}
