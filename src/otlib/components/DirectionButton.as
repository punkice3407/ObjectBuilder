package otlib.components
{
    import com.mignari.errors.NullArgumentError;
    
    import spark.components.ToggleButton;
    
    import otlib.geom.Direction;

    public class DirectionButton extends ToggleButton
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_direction:Direction;
        private var m_isDiagonal:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get direction():Direction { return m_direction; }
        public function set direction(value:Direction):void
        {
            if (!value)
                throw new NullArgumentError("direction");
            if (value !== m_direction) {
                m_direction = value;
                m_isDiagonal = Direction.isDiagonal(value);
            }
        }

        public function get isDiagonal():Boolean { return m_isDiagonal; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function DirectionButton()
        {
            width = 22;
            height = 22;
            direction = Direction.NORTH;
        }
    }
}
