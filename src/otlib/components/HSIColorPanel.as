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
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import mx.core.UIComponent;

    import otlib.utils.ColorUtils;

    [Event(name="change", type="flash.events.Event")]

    public class HSIColorPanel extends UIComponent
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _columns:uint;
        private var _rows:uint;
        private var _length:uint;
        private var _lengthChanged:Boolean;
        private var _bounds:Rectangle;
        private var _highlight:UIComponent;
        private var _selection:UIComponent;
        private var _swatchWidth:Number;
        private var _swatchHeight:Number;
        private var _swatchGap:Number;
        private var _overIndex:int;
        private var _selectedIndex:int;
        private var _proposedSelectedIndex:int;
        private var _selectedIndexFlag:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get selectedIndex():int { return _proposedSelectedIndex == -1 ? _selectedIndex : _proposedSelectedIndex; }
        public function set selectedIndex(value:int):void
        {
            if (_selectedIndex != value) {
                _proposedSelectedIndex = value;
                _selectedIndexFlag = true;
                invalidateProperties();
                dispatchEvent(new Event(Event.CHANGE));
            }
        }

        public function get columns():uint { return _columns; }
        public function set columns(value:uint):void
        {
            if (_columns != value) {
                _columns = value;
                _lengthChanged = true;
                invalidateProperties();
                invalidateDisplayList();
            }
        }

        public function get rows():uint { return _rows; }
        public function set rows(value:uint):void
        {
            if (_rows != value) {
                _rows = value;
                _lengthChanged = true;
                invalidateProperties();
                invalidateDisplayList();
            }
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function HSIColorPanel()
        {
            super();

            _bounds = new Rectangle();
            _swatchWidth = 15;
            _swatchHeight = 15;
            _swatchGap = 1;
            _selectedIndex = 0;
            _proposedSelectedIndex = -1;

            this.columns = 19;
            this.rows = 7;

            addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
            addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            addEventListener(MouseEvent.CLICK, mouseClickHandler);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Protected
        //--------------------------------------

        protected function getColor(color:uint):uint
        {
            return ColorUtils.HSItoRGB(color);
        }

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        override protected function createChildren():void
        {
            _highlight = new UIComponent();
            _highlight.visible = false;
            addChild(_highlight);

            _selection = new UIComponent();
            addChild(_selection);
        }

        override protected function measure():void
        {
            super.measure();
            measuredWidth= _bounds.width;
            measuredHeight = _bounds.height;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            _bounds.setTo(0, 0, _columns * (_swatchWidth + _swatchGap), _rows * (_swatchHeight + _swatchGap));

            var w:Number = (_swatchWidth + _swatchGap);
            var h:Number = (_swatchHeight + _swatchGap);

            var g:Graphics = graphics;
            g.beginFill(0x000000);
            g.drawRect(-1, -1, _bounds.width + 1, _bounds.height + 1);
            g.endFill();

            g = _highlight.graphics;
            g.clear();
            g.lineStyle(1, 0x000000, 0.7);
            g.drawRect(1, 1, w - 4, h - 4);
            g.endFill();
            g.lineStyle(1, 0xFFFFFF, 0.7);
            g.drawRect(2, 2, w - 6, h - 6);
            g.endFill();

            g = _selection.graphics;
            g.clear();
            g.lineStyle(1, 0x000000);
            g.drawRect(1, 1, w - 4, h - 4);
            g.endFill();
            g.lineStyle(1, 0xFFFFFF);
            g.drawRect(2, 2, w - 6, h - 6);
            g.endFill();

            var column:uint = 0;
            var row:uint = 0;
            for (var i:uint = 0; i < _length; i++) {
                var px:Number = column * w;
                var py:Number = row * h;
                var color:uint = getColor(i);

                drawCell(px, py, _swatchWidth, _swatchHeight, color);

                if (column < _columns - 1) {
                    column++;
                } else {
                    column = 0;
                    row++;
                }
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_lengthChanged) {
                _lengthChanged = false;
                _bounds.setTo(0, 0, _columns * (_swatchWidth + _swatchGap), _rows * (_swatchHeight + _swatchGap));
                _length = _columns * _rows;
            }

            if (_selectedIndexFlag) {
                _selectedIndexFlag = false;
                setFocusOnSwatch(_proposedSelectedIndex);
                _proposedSelectedIndex = -1;
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function drawCell(x:Number, y:Number, width:Number, height:Number, color:uint):void
        {
            graphics.moveTo(x, y);
            graphics.beginFill(color);
            graphics.lineTo(x + width, y);
            graphics.lineTo(x + width, height + y);
            graphics.lineTo(x, height + y);
            graphics.lineTo(x, y);
            graphics.endFill();
        }

        /**
         *  @private
         */
        private function setFocusOnSwatch(index:int):void
        {
            if (index < 0 || index >= _length) {
                _selection.visible = false;
                return;
            }

            var row:uint = Math.floor(index / _columns);
            var column:uint = index - (row * _columns);
            var px:Number = column * (_swatchWidth + _swatchGap);
            var py:Number = row * (_swatchHeight + _swatchGap);

            _selection.move(px, py);
            _selection.visible = true;
            _selectedIndex = index;
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function mouseClickHandler(event:MouseEvent):void
        {
            if (_overIndex != -1) {
                this.selectedIndex = _overIndex;
            }
        }

        protected function mouseOutHandler(event:MouseEvent):void
        {
            _highlight.visible = false;
        }

        protected function mouseOverHandler(event:MouseEvent):void
        {
            _highlight.visible = true;
        }

        protected function mouseMoveHandler(event:MouseEvent):void
        {
            if (mouseX > _bounds.left && mouseX < _bounds.right && mouseY > _bounds.top && mouseY < _bounds.bottom) {
                var w:Number = (_swatchWidth + _swatchGap);
                var h:Number = (_swatchHeight + _swatchGap);
                var column:uint = Math.floor(Math.floor(mouseX) / w);
                var row:uint = Math.floor(Math.floor(mouseY) / h);
                var px:Number = column * w;
                var py:Number = row * h;
                _overIndex = row * _columns + column;
                _highlight.move(px, py);
            } else {
                _overIndex = -1;
            }
        }
    }
}
