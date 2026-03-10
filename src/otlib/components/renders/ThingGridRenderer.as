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

package otlib.components.renders
{
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.ui.ContextMenu;
    import flash.events.MouseEvent;

    import mx.events.FlexEvent;
    import mx.graphics.SolidColor;
    import mx.graphics.SolidColorStroke;

    import spark.components.Label;
    import spark.components.supportClasses.ItemRenderer;
    import spark.primitives.BitmapImage;
    import spark.primitives.Rect;
    import spark.layouts.HorizontalAlign;

    import nail.logging.Log;
    import nail.utils.isNullOrEmpty;

    import otlib.components.ListBase;
    import otlib.core.otlib_internal;
    import otlib.things.ThingType;
    import otlib.utils.ThingListItem;

    use namespace otlib_internal;

    public class ThingGridRenderer extends ItemRenderer
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        private var _imageDisplay:BitmapImage;
        private var _idLabel:Label;
        private var _hovered:Boolean = false;

        // Background elements
        private var _fill:Rect;
        private var _border:Rect;
        private var _imageBackground:Rect;

        // Colors
        private static const COLOR_NORMAL:uint = 0x535353;
        private static const COLOR_HOVERED:uint = 0x3385B2;
        private static const COLOR_SELECTED:uint = 0x156692;
        private static const COLOR_BORDER:uint = 0x272727;
        private static const COLOR_IMAGE_BG:uint = 0x636363;

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ThingGridRenderer()
        {
            super();
            this.width = 64;
            this.height = 71;
            this.autoDrawBackground = false; // We draw our own background
            this.setStyle("fontSize", 9);
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();

            // 1. Fill (Background)
            _fill = new Rect();
            _fill.left = 1;
            _fill.right = 1;
            _fill.top = 1;
            _fill.bottom = 1;
            _fill.fill = new SolidColor(COLOR_NORMAL);
            addElement(_fill);

            // 2. Border
            _border = new Rect();
            _border.left = 0;
            _border.right = 1;
            _border.top = 0;
            _border.bottom = 0;
            _border.stroke = new SolidColorStroke(COLOR_BORDER, 0.1);
            addElement(_border);

            // 3. Image Background
            _imageBackground = new Rect();
            _imageBackground.horizontalCenter = 0;
            _imageBackground.top = 3;
            _imageBackground.width = 56;
            _imageBackground.height = 56;
            _imageBackground.fill = new SolidColor(COLOR_IMAGE_BG);
            _imageBackground.stroke = new SolidColorStroke(COLOR_BORDER);
            addElement(_imageBackground);

            // 4. Bitmap Image
            _imageDisplay = new BitmapImage();
            _imageDisplay.horizontalCenter = 0;
            _imageDisplay.top = 4;
            _imageDisplay.width = 54;
            _imageDisplay.height = 54;
            _imageDisplay.fillMode = "scale";
            _imageDisplay.scaleMode = "letterbox";
            addElement(_imageDisplay);

            // 5. ID Label
            _idLabel = new Label();
            _idLabel.horizontalCenter = 0;
            _idLabel.bottom = 2;
            _idLabel.setStyle("textAlign", "center");
            _idLabel.mouseChildren = false;
            _idLabel.mouseEnabled = false;
            addElement(_idLabel);

            // Context Menu setup
            this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        }

        protected function creationCompleteHandler(event:FlexEvent):void
        {
            this.removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

            if (owner is ListBase && ListBase(owner).contextMenuEnabled)
            {
                var cm:ContextMenu = ThingRendererBase.createContextMenu();
                cm.addEventListener(Event.SELECT, contextMenuSelectHandler);
                cm.addEventListener(Event.DISPLAYING, contextMenuDisplayingHandler);
                this.contextMenu = cm;
            }
            this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        }

        protected function rollOverHandler(event:MouseEvent):void
        {
            _hovered = true;
            invalidateDisplayList();
        }

        protected function rollOutHandler(event:MouseEvent):void
        {
            _hovered = false;
            invalidateDisplayList();
        }

        override public function set selected(value:Boolean):void
        {
            super.selected = value;
            invalidateDisplayList();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            // Update background color based on state
            var color:uint = COLOR_NORMAL;
            if (selected)
                color = COLOR_SELECTED;
            else if (_hovered)
                color = COLOR_HOVERED;

            if (_fill && _fill.fill is SolidColor)
            {
                SolidColor(_fill.fill).color = color;
            }
        }

        override public function set data(value:Object):void
        {
            super.data = value;

            var item:ThingListItem = value as ThingListItem;
            if (item)
            {
                var thing:ThingType = item.thing;

                // ID text
                _idLabel.text = thing.id.toString();

                // Image
                try
                {
                    _imageDisplay.source = item.getBitmap();
                }
                catch (error:Error)
                {
                    Log.error(error.message, error.getStackTrace(), error.errorID);
                }
            }
            else
            {
                _idLabel.text = "";
                _imageDisplay.source = null;
            }
        }

        // Context Menu Handlers

        protected function contextMenuDisplayingHandler(event:Event):void
        {
            var menu:ContextMenu = ContextMenu(event.target);
            var item:ThingListItem = this.data as ThingListItem;
            ThingRendererBase.handleContextMenuDisplaying(owner, this.itemIndex, menu, item);
        }

        protected function contextMenuSelectHandler(event:Event):void
        {
            ThingRendererBase.handleContextMenuSelect(owner, this.itemIndex, event);
        }
    }
}
