package store.events
{
    import flash.events.Event;

    import otlib.things.ThingData;

    public final class AssetStoreEvent extends Event
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var data:ThingData;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function AssetStoreEvent(type:String, data:ThingData)
        {
            super(type);

            this.data = data;
        }

        
        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Override Public
        //--------------------------------------

        override public function clone():Event
        {
            return new AssetStoreEvent(type, data);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const IMPORT_ASSET:String = "importAsset";
    }
}
