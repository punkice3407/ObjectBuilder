package gamelib.client
{
    import com.mignari.errors.AbstractClassError;

    public final class MetadataFormat
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MetadataFormat()
        {
            throw new AbstractClassError(MetadataFormat);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const INVALID_FORMAT:uint = 0;
        public static const FORMAT_710:uint = 710;
        public static const FORMAT_740:uint = 740;
        public static const FORMAT_755:uint = 755;
        public static const FORMAT_780:uint = 780;
        public static const FORMAT_860:uint = 860;
        public static const FORMAT_900:uint = 900;
        public static const FORMAT_940:uint = 940;
        public static const FORMAT_960:uint = 960;
        public static const FORMAT_1010:uint = 1010;
        public static const FORMAT_1021:uint = 1021;
        public static const FORMAT_1050:uint = 1050;
        public static const FORMAT_1057:uint = 1057;
        public static const FORMAT_1092:uint = 1092;
        public static const FORMAT_1098:uint = 1098;

        [Inline]
        public static function isValid(value:uint):Boolean
        {
            return (value == FORMAT_710 ||
                    value == FORMAT_740 ||
                    value == FORMAT_755 ||
                    value == FORMAT_780 ||
                    value == FORMAT_860 ||
                    value == FORMAT_900 ||
                    value == FORMAT_960 ||
                    value == FORMAT_940 ||
                    value == FORMAT_1010 ||
                    value == FORMAT_1021 ||
                    value == FORMAT_1050 ||
                    value == FORMAT_1057 ||
                    value == FORMAT_1092 ||
                    value == FORMAT_1098);
        }

        /**
         * Converte o valor de uma versão em um formato do dat.
         */
        public static function convert(value:uint):uint
        {
            if (value == 0)
            {
                return MetadataFormat.INVALID_FORMAT;
            }

            if (value < 740)
            {
                return MetadataFormat.FORMAT_710;
            }
            else if (value < 755)
            {
                return MetadataFormat.FORMAT_740;
            }
            else if (value < 780)
            {
                return MetadataFormat.FORMAT_755;
            }
            else if (value < 860)
            {
                return MetadataFormat.FORMAT_780;
            }
            else if (value < 900)
            {
                return MetadataFormat.FORMAT_860;
            }
            else if (value < 940)
            {
                return MetadataFormat.FORMAT_900;
            }
            else if (value < 960)
            {
                return MetadataFormat.FORMAT_940;
            }
            else if (value < 1010)
            {
                return MetadataFormat.FORMAT_960;
            }
            else if (value < 1021)
            {
                return MetadataFormat.FORMAT_1010;
            }
            else if (value < 1050)
            {
                return MetadataFormat.FORMAT_1021;
            }
            else if (value < 1057)
            {
                return MetadataFormat.FORMAT_1050;
            }
            else if (value < 1092)
            {
                return MetadataFormat.FORMAT_1057;
            }
            else if (value < 1098)
            {
                return MetadataFormat.FORMAT_1092;
            }
            else if (value >= 1098)
            {
                return MetadataFormat.FORMAT_1098;
            }

            return MetadataFormat.INVALID_FORMAT;
        }
    }
}
