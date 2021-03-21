package gamelib.client
{
    import com.mignari.errors.SingletonClassError;
    
    import otlib.core.Version;

    public final class ClientFeatures
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ClientFeatures()
        {
            throw new SingletonClassError(ClientFeatures);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const NONE:uint            = 0;
        public static const PATTERNS_Z:uint      = 1 << 0;
        public static const EXTENDED:uint        = 1 << 1;
        public static const FRAME_DURATIONS:uint = 1 << 2;
        public static const FRAME_GROUPS:uint    = 1 << 3;
        public static const TRANSPARENCY:uint    = 1 << 4;

        [Inline]
        public static function isEnabled(features:uint, feature:uint):Boolean
        {
            return (features & feature) == feature;
        }

        public static function getFeatures(version:Version, transparency:Boolean):uint
        {
            var features:uint = NONE;
            features |= version.value >= MetadataFormat.FORMAT_740 ? ClientFeatures.PATTERNS_Z : features;
            features |= version.value >= MetadataFormat.FORMAT_960 ? ClientFeatures.EXTENDED : features;
            features |= version.value >= MetadataFormat.FORMAT_1050 ? ClientFeatures.FRAME_DURATIONS : features;
            features |= version.value >= MetadataFormat.FORMAT_1057 ? ClientFeatures.FRAME_GROUPS : features;
            features |= transparency ? ClientFeatures.TRANSPARENCY : features;
            return features;
        }

        public static function setFeatures(patternsZ:Boolean, extended:Boolean, frameDurations:Boolean, frameGroups:Boolean, transparency:Boolean):uint
        {
            var features:uint = NONE;
            features |= patternsZ ? ClientFeatures.PATTERNS_Z : features;
            features |= extended ? ClientFeatures.EXTENDED : features;
            features |= frameDurations ? ClientFeatures.FRAME_DURATIONS : features;
            features |= frameGroups ? ClientFeatures.FRAME_GROUPS : features;
            features |= transparency ? ClientFeatures.TRANSPARENCY : features;
            return features;
        }

        public static function toString(features:uint):String
        {
            var text:String = '';
            if ((features & PATTERNS_Z) == PATTERNS_Z) text += "PATTERNS_Z;"
            if ((features & EXTENDED) == EXTENDED) text += "EXTENDED;"
            if ((features & FRAME_DURATIONS) == FRAME_DURATIONS) text += "FRAME_DURATIONS;"
            if ((features & FRAME_GROUPS) == FRAME_GROUPS) text += "FRAME_GROUPS;"
            if ((features & TRANSPARENCY) == TRANSPARENCY) text += "TRANSPARENCY;"
            if (text.length == 0) text = "NONE;";
            return text;
        }
    }
}
