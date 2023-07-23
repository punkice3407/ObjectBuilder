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

package otlib.components
{
    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    import mx.core.UIComponent;

    [Style(name="cellColors", type="Array", arrayType="uint", format="Color", inherit="no", theme="spark")]

    public class CheckerBoard extends UIComponent
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _cellSize:uint;
        private var _cellSizeChanged:Boolean;
        private var _rect:Rectangle;
        private var _bitmap:BitmapData;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get cellSize():uint { return _cellSize; }
        public function set cellSize(value:uint):void {
            if (_cellSize != value) {
                _cellSize = value;
                _cellSizeChanged = true;
                invalidateProperties();
                invalidateDisplayList();
            }
        }

        public function get bitmap():BitmapData { return _bitmap; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function CheckerBoard()
        {
            this.cellSize = 4;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_cellSizeChanged) {
                var double:uint = _cellSize * 2;
                var colors:Array = getStyle("cellColors");

                if (!colors || colors.length < 2) {
                    colors = [0xFFFFFF, 0xCCCCCC];
                }

                _bitmap = new BitmapData(double, double, false, uint(colors[1]));
                _rect = new Rectangle(0, _cellSize, _cellSize, double);
                _bitmap.fillRect(_rect, colors[0]);
                _rect.setTo(_cellSize, 0, double, _cellSize);
                _bitmap.fillRect(_rect, colors[0]);
                _cellSizeChanged = false;
            }
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            graphics.clear();
            if (unscaledWidth > 0 && unscaledHeight > 0) {
                graphics.beginBitmapFill(_bitmap, null, true);
                graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
                graphics.endFill();
            }
        }
    }
}
