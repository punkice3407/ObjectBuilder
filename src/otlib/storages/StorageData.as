package otlib.storages
{
    internal class StorageData
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var storage:IStorage;
        public var callback:Function;
        public var parameters:Array;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function StorageData(storage:IStorage, callback:Function, parameters:Array)
        {
            this.storage = storage;
            this.callback = callback;
            this.parameters = parameters;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function perform():void
        {
            callback.apply(null, parameters);
        }
    }
}
