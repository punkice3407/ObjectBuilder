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

package otlib.utils
{
    public class Color
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_alpha:uint;
        private var m_red:uint;
        private var m_green:uint;
        private var m_blue:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get alpha():uint { return m_alpha; }
        public function get red():uint { return m_red; }
        public function get green():uint { return m_green; }
        public function get blue():uint { return m_blue; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Color(value:uint = 0x00000000)
        {
            setColor(value);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function setColor(value:uint):Color
        {
            m_alpha = value >> 24 & 0xFF;
            m_red = value >> 16 & 0xFF;
            m_green = value >> 8 & 0xFF;
            m_blue = value & 0xFF;
            return this;
        }

        public function setFrom(color:Color):Color
        {
            m_alpha = color.m_alpha;
            m_red = color.m_red;
            m_green = color.m_green;
            m_blue = color.m_blue;
            return this;
        }

        public function setTo(color:Color):Color
        {
            color.m_alpha = m_alpha;
            color.m_red = m_red;
            color.m_green = m_green;
            color.m_blue = m_blue;
            return color;
        }

        public function getRGB():uint
        {
            return (m_red << 16 | m_green << 8 | m_blue);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const ALPHA:uint = 0x00000000;
        public static const WHITE:uint = 0xFFFFFFFF;
        public static const BLACK:uint = 0xFF000000;
        public static const RED:uint = 0xFF0000FF;
        public static const DARK_RED:uint = 0xFF000080;
        public static const GREEN:uint = 0xFF00FF00;
        public static const DARK_GREEN:uint = 0xFF008000;
        public static const BLUE:uint = 0xFFFF0000;
        public static const DARK_BLUE:uint = 0xFF800000;
        public static const PINK:uint = 0xFFFF00FF;
        public static const DARK_PINK:uint = 0xFF800080;
        public static const YELLOW:uint = 0xFF00FFFF;
        public static const DARK_YELLOW:uint = 0xFF008080;
        public static const TEAL:uint = 0xFFFFFF00;
        public static const DARK_TEAL:uint = 0xFF808000;
        public static const GRAY:uint = 0xFFA0A0A0;
        public static const DARK_GRAY:uint = 0xFF808080;
        public static const LIGHT_GRAY:uint = 0xFFC0C0C0;
        public static const ORANGE:uint = 0xFF008CFF;

        public static function toColor(value:String):Color
        {
            var color:Color = new Color();

            if (value.indexOf("#") == 0)
            {
                if (value.length == 7 || value.length == 9)
                {
                    color.m_red = uint(value.substr(1, 2));
                    color.m_green = uint(value.substr(3, 2));
                    color.m_blue = uint(value.substr(5, 2));

                    if (value.length == 9)
                        color.m_alpha = uint(value.substr(7, 2));
                }
            }
            else
            {
                value = value.toLowerCase();
                if(value == "alpha")
                    color = new Color(ALPHA);
                else if(value == "black")
                    color = new Color(BLACK);
                else if(value == "white")
                    color = new Color(WHITE);
                else if(value == "red")
                    color = new Color(RED);
                else if(value == "darkred")
                    color = new Color(DARK_RED);
                else if(value == "green")
                    color = new Color(GREEN);
                else if(value == "darkgreen")
                    color = new Color(DARK_GREEN);
                else if(value == "blue")
                    color = new Color(BLUE);
                else if(value == "darkblue")
                    color = new Color(DARK_BLUE);
                else if(value == "pink")
                    color = new Color(PINK);
                else if(value == "darkpink")
                    color = new Color(DARK_PINK);
                else if(value == "yellow")
                    color = new Color(YELLOW);
                else if(value == "darkyellow")
                    color = new Color(DARK_YELLOW);
                else if(value == "teal")
                    color = new Color(TEAL);
                else if(value == "darkteal")
                    color = new Color(DARK_TEAL);
                else if(value == "gray")
                    color = new Color(GRAY);
                else if(value == "darkgray")
                    color = new Color(DARK_GRAY);
                else if(value == "lightgray")
                    color = new Color(LIGHT_GRAY);
                else if(value == "orange")
                    color = new Color(ORANGE);
            }

            return color;
        }
    }
}
