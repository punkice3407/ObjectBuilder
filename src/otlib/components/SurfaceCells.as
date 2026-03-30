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
    import mx.core.UIComponent;

    [ExcludeClass]
    public class SurfaceCells extends UIComponent
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        private var _columns:uint;
        private var _rows:uint;
        private var _cellWidth:uint;
        private var _cellHeight:uint;
        private var _subdivisions:Boolean;
        private var _lineColor:uint = 0;
        private var _lineAlpha:Number = 1.0;

        // --------------------------------------
        // Getters / Setters
        // --------------------------------------

        public function get cellWidth():uint
        {
            return _cellWidth;
        }
        public function set cellWidth(value:uint):void
        {
            if (_cellWidth != value)
            {
                _cellWidth = value;
                invalidateDisplayList();
                invalidateSize();
            }
        }

        public function get cellHeight():uint
        {
            return _cellHeight;
        }
        public function set cellHeight(value:uint):void
        {
            if (_cellHeight != value)
            {
                _cellHeight = value;
                invalidateDisplayList();
                invalidateSize();
            }
        }

        public function get columns():uint
        {
            return _columns;
        }
        public function set columns(value:uint):void
        {
            if (_columns != value)
            {
                _columns = value;
                invalidateDisplayList();
                invalidateSize();
            }
        }

        public function get rows():uint
        {
            return _rows;
        }
        public function set rows(value:uint):void
        {
            if (_rows != value)
            {
                _rows = value;
                invalidateDisplayList();
                invalidateSize();
            }
        }

        public function get subdivisions():Boolean
        {
            return _subdivisions;
        }
        public function set subdivisions(value:Boolean):void
        {
            if (_subdivisions != value)
            {
                _subdivisions = value;
                invalidateDisplayList();
            }
        }

        public function get lineColor():uint
        {
            return _lineColor;
        }
        public function set lineColor(value:uint):void
        {
            if (_lineColor != value)
            {
                _lineColor = value;
                invalidateDisplayList();
            }
        }

        public function get lineAlpha():Number
        {
            return _lineAlpha;
        }
        public function set lineAlpha(value:Number):void
        {
            if (_lineAlpha != value)
            {
                _lineAlpha = value;
                invalidateDisplayList();
            }
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        public function SurfaceCells()
        {
        }

        /**
         * Set columns and rows in a single call to avoid double invalidation.
         */
        public function setGridSize(cols:uint, rows:uint):void
        {
            if (_columns != cols || _rows != rows)
            {
                _columns = cols;
                _rows = rows;
                invalidateDisplayList();
                invalidateSize();
            }
        }

        // --------------------------------------
        // Override Protected
        // --------------------------------------

        override protected function measure():void
        {
            super.measure();
            measuredWidth = _cellWidth * _columns;
            measuredHeight = _cellHeight * _rows;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            var halfWidth:Number = _cellWidth / 2;
            var halfHeight:Number = _cellHeight / 2;
            var x:Number;
            var y:Number;

            graphics.clear();
            for (var c:uint = 0; c < _columns; c++)
            {
                for (var r:uint = 0; r < _rows; r++)
                {
                    x = c * _cellWidth;
                    y = r * _cellHeight;

                    graphics.lineStyle(0.5, _lineColor, _lineAlpha);
                    graphics.beginFill(0, 0);
                    graphics.drawRect(x, y, _cellWidth, _cellHeight);
                    graphics.endFill();

                    if (_subdivisions)
                    {
                        graphics.lineStyle(0.5, _lineColor, _lineAlpha * 0.3);
                        graphics.moveTo(x + halfWidth, y);
                        graphics.lineTo(x + halfWidth, y + _cellHeight);
                        graphics.moveTo(x, y + halfHeight);
                        graphics.lineTo(x + _cellWidth, y + halfHeight);
                    }
                }
            }
        }
    }
}
