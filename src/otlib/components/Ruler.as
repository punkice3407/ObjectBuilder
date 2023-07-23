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
    import flash.geom.Point;

    import mx.core.FlexShape;
    import mx.core.UIComponent;
    import otlib.utils.SpriteExtent;
    import otlib.core.SpriteDimension;

    [Style(name="lineColor", inherit="no", type="uint", format="Color")]

    public class Ruler extends UIComponent
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_mouseLine:FlexShape;
        private var m_zoom:Number = 1.0;
        private var m_point:Point;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get zoom():Number { return m_zoom; }
        public function set zoom(value:Number):void
        {
            if (m_zoom != value)
            {
                m_zoom = value;
                invalidateDisplayList();
            }
        }

        public function set spriteDimension(value:SpriteDimension):void
        {
            SpriteExtent.DEFAULT_VALUE = value.toString();
            SpriteExtent.DEFAULT_SIZE = value.size;
            SpriteExtent.DEFAULT_DATA_SIZE = value.dataSize;
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Ruler()
        {
            m_point = new Point();

            super();

            this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();

            m_mouseLine = new FlexShape();
            addChild(m_mouseLine);
        }

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            graphics.clear();
            graphics.lineStyle(1, 0x272727);
            graphics.beginFill(0x353535);
            graphics.drawRect(0, 0, unscaledWidth, 15);
            graphics.endFill();

            graphics.beginFill(0x353535);
            graphics.drawRect(0, 0, 15, unscaledHeight);
            graphics.endFill();

            var lineColor:Number = getStyle("lineColor");
            if (isNaN(lineColor))
                lineColor = 0x000000;

            graphics.lineStyle(1, lineColor);

            var size:Number = (SpriteExtent.DEFAULT_SIZE * m_zoom);

            var w:int = int(width / size) + 1;
            var h:int = int(height / size) + 1;
            var v:Number = NaN;

            for (var i:int = 0; i < w; i++)
            {
                var pos:int = (i * size) + 15;

                // horizontal lines

                graphics.moveTo(pos, 0);
                graphics.lineTo(pos, 15);

                v = pos + (8 * m_zoom);
                graphics.moveTo(v, 10);
                graphics.lineTo(v, 15);

                v = pos + (16 * m_zoom);
                graphics.moveTo(v, 8);
                graphics.lineTo(v, 15);

                v = pos + (24 * m_zoom);
                graphics.moveTo(v, 10);
                graphics.lineTo(v, 15);

                // vertical lines

                graphics.moveTo(0, pos);
                graphics.lineTo(15, pos);

                v = pos + (8 * m_zoom);
                graphics.moveTo(10, v);
                graphics.lineTo(15, v);

                v = pos + (16 * m_zoom);
                graphics.moveTo(8, v);
                graphics.lineTo(15, v);

                v = pos + (24 * m_zoom);
                graphics.moveTo(10, v);
                graphics.lineTo(15, v);

                if (m_zoom >= 2)
                {
                    // horizontal lines

                    v = pos + (4 * m_zoom);
                    graphics.moveTo(v, 10);
                    graphics.lineTo(v, 15);

                    v = pos + (12 * m_zoom);
                    graphics.moveTo(v, 10);
                    graphics.lineTo(v, 15);

                    v = pos + (20 * m_zoom);
                    graphics.moveTo(v, 10);
                    graphics.lineTo(v, 15);

                    v = pos + (28 * m_zoom);
                    graphics.moveTo(v, 10);
                    graphics.lineTo(v, 15);

                    // vertical lines

                    v = pos + (4 * m_zoom);
                    graphics.moveTo(10, v);
                    graphics.lineTo(15, v);

                    v = pos + (12 * m_zoom);
                    graphics.moveTo(10, v);
                    graphics.lineTo(15, v);

                    v = pos + (20 * m_zoom);
                    graphics.moveTo(8, v);
                    graphics.lineTo(15, v);

                    v = pos + (28 * m_zoom);
                    graphics.moveTo(10, v);
                    graphics.lineTo(15, v);
                }
            }

            graphics.endFill();
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function addedToStageHandler(event:Event):void
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
            this.systemManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        protected function removedFromStageHandler(event:Event):void
        {
            this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
            this.systemManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        protected function mouseMoveHandler(event:MouseEvent):void
        {
            if (!m_mouseLine) return;

            m_point.setTo(event.stageX, event.stageY);
            var point:Point = globalToLocal(m_point);
            var x:Number = point.x;
            var y:Number = point.y;
            var g:Graphics = m_mouseLine.graphics;

            g.clear();
            g.lineStyle(1, 0xAAAAAA);

            if (x > 15 && x < width)
            {
                g.moveTo(x, 0);
                g.lineTo(x, 15);
            }

            if (y > 15 && y < height)
            {
                g.moveTo(0, y);
                g.lineTo(15, y);
            }

            g.endFill();
        }
    }
}
