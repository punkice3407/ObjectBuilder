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
    import nail.errors.AbstractClassError;

    public final class ColorUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ColorUtils()
        {
            throw new AbstractClassError(ColorUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function toARGB(color:uint, alpha:uint = 0xFF):uint
        {
            const R:uint = color >> 16 & 0xFF;
            const G:uint = color >> 8 & 0xFF;
            const B:uint = color & 0xFF;
            alpha = alpha > 0xFF ? 0xFF : alpha;
            return (alpha << 24 | R << 16 | G << 8 | B);
        }

        public static function HSItoRGB(color:uint):uint
        {
            var values:uint = 7;
            var steps:uint = 19;
            var H:Number = 0;
            var S:Number = 0;
            var I:Number = 0;
            var R:Number = 0;
            var G:Number = 0;
            var B:Number = 0;

            if (color >= steps * values) {
                color = 0;
            }

            if (color % steps == 0) {
                H = 0;
                S = 0;
                I = 1 - color / steps / values;
            } else {
                H = color % steps * (1 / 18);
                S = 1;
                I = 1;

                switch (int(color / steps)) {
                    case 0:
                        S = 0.25;
                        I = 1;
                        break;
                    case 1:
                        S = 0.25;
                        I = 0.75;
                        break;
                    case 2:
                        S = 0.5;
                        I = 0.75;
                        break;
                    case 3:
                        S = 0.667;
                        I = 0.75;
                        break;
                    case 4:
                        S = 1;
                        I = 1;
                        break;
                    case 5:
                        S = 1;
                        I = 0.75;
                        break;
                    case 6:
                        S = 1;
                        I = 0.5;
                        break;
                }
            }

            if (I == 0) {
                return 0x000000;
            }

            if (S == 0) {
                return (int(I * 0xFF) << 16 | int(I * 0xFF) << 8 | int(I * 0xFF));
            }

            if (H < 1 / 6) {
                R = I;
                B = I * (1 - S);
                G = B + (I - B) * 6 * H;
            } else if (H < 2 / 6) {
                G = I;
                B = I * (1 - S);
                R = G - (I - B) * (6 * H - 1);
            } else if (H < 3 / 6) {
                G = I;
                R = I * (1 - S);
                B = R + (I - R) * (6 * H - 2);

            } else if (H < 4 / 6) {
                B = I;
                R = I * (1 - S);
                G = B - (I - R) * (6 * H - 3);
            } else if (H < 5 / 6) {
                B = I;
                G = I * (1 - S);
                R = G + (I - G) * (6 * H - 4);
            } else {
                R = I;
                G = I * (1 - S);
                B = R - (I - G) * (6 * H - 5);
            }
            return (R * 0xFF << 16 | G * 0xFF << 8 | B * 0xFF);
        }

        public static function HSItoARGB(color:uint):uint
        {
            const rgb:uint = HSItoRGB(color);
            return toARGB(rgb);
        }

        public static function from8Bit(color:uint):uint
        {
            if (color >= 216) return 0;
            const R:Number = int(color / 36) % 6 * 51;
            const G:Number = int(color / 6) % 6 * 51;
            const B:Number = color % 6 * 51;
            return (R << 16 | G << 8 | B);
        }
    }
}
