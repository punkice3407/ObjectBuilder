package store
{
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    import otlib.assets.Assets;
    import otlib.obd.OBDEncoder;
    import otlib.things.ThingCategory;
    import otlib.things.ThingData;
	import otlib.things.FrameGroupType;
	import otlib.utils.SpriteUtils;
	import ob.settings.ObjectBuilderSettings;
	import ob.core.IObjectBuilder;
	import mx.core.FlexGlobals;

    [Event(name="complete", type="flash.events.Event")]

    public final class StoreAsset extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_data:ThingData;
        private var m_bitmap:BitmapData;
        private var m_error:String;
        private var m_loaded:Boolean;

        public var name:String;
        public var author:String;
        public var url:String;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get data():ThingData { return m_data; }
        public function get bitmap():BitmapData { return m_bitmap; }
        public function get error():String { return m_error; }
        public function get loaded():Boolean { return m_loaded; }
        

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function StoreAsset()
        {
            
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load():void
        {
            if (m_loaded)
                return;

            var request:URLRequest = new URLRequest(url);
            request.followRedirects = true;
            request.useCache = false;

            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            loader.load(request);

            function loadCompleteHandler(event:Event):void
            {
                try
                {
                    var settings:ObjectBuilderSettings = IObjectBuilder(FlexGlobals.topLevelApplication).settings
                    trace("StoreAsset")
                    trace(settings)

                    var bytes:ByteArray = ByteArray(loader.data);
                    var encoder:OBDEncoder = new OBDEncoder(settings);
                    var patternX:uint = 0;

                    m_data = encoder.decode(bytes);
                    if (data.category == ThingCategory.OUTFIT)
                        patternX = 2;
                    m_bitmap = m_data.getBitmap(m_data.getFrameGroup(FrameGroupType.DEFAULT), 0, patternX);
                    m_error = null;
                    m_loaded = true;
                }
                catch(error:Error)
                {
                    m_data = null;
                    m_bitmap = SpriteUtils.createAlertBitmap();
                    m_error = error.message;
                    m_loaded = false;
                }

                dispatchEvent(new Event(Event.COMPLETE));
            }

            function errorHandler(event:IOErrorEvent):void
            {
                m_bitmap = SpriteUtils.createAlertBitmap();
                m_error = event.text;
                m_loaded = false;
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
    }
}
