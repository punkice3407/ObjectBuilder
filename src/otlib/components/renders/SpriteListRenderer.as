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
    import flash.display.NativeMenuItem;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;

    import mx.events.FlexEvent;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.graphics.SolidColor;
    import mx.graphics.SolidColorStroke;

    import spark.components.Label;
    import spark.components.supportClasses.ItemRenderer;
    import spark.primitives.BitmapImage;
    import spark.primitives.Rect;

    import otlib.components.ListBase;
    import otlib.components.SpriteList;
    import otlib.core.otlib_internal;
    import otlib.events.SpriteListEvent;
    import otlib.sprites.SpriteData;

    use namespace otlib_internal;

    [ResourceBundle("strings")]
    public class SpriteListRenderer extends ItemRenderer
    {
        private var _imageDisplay:BitmapImage;
        private var _labelDisplay:Label;
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

        public function SpriteListRenderer()
        {
            super();
            this.height = 41;
            this.setStyle("fontSize", 11);
            this.autoDrawBackground = false;
        }

        override protected function createChildren():void
        {
            super.createChildren();

            // 1. Fill
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
            _border.right = 1; // MXML had right=1
            _border.top = 0;
            _border.bottom = 0;
            _border.stroke = new SolidColorStroke(COLOR_BORDER, 0.1);
            addElement(_border);

            // 3. Image Background
            _imageBackground = new Rect();
            _imageBackground.left = 5;
            _imageBackground.verticalCenter = 0;
            _imageBackground.width = 33;
            _imageBackground.height = 33;
            _imageBackground.fill = new SolidColor(COLOR_IMAGE_BG);
            _imageBackground.stroke = new SolidColorStroke(COLOR_BORDER);
            addElement(_imageBackground);

            // 4. Image
            _imageDisplay = new BitmapImage();
            _imageDisplay.left = 6;
            _imageDisplay.width = 32;
            _imageDisplay.height = 32;
            _imageDisplay.verticalCenter = 0;
            addElement(_imageDisplay);

            // 5. Label
            _labelDisplay = new Label();
            _labelDisplay.left = 42;
            _labelDisplay.right = 5;
            _labelDisplay.verticalCenter = 0;
            _labelDisplay.mouseChildren = false;
            _labelDisplay.mouseEnabled = false;
            addElement(_labelDisplay);

            this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
            this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        }

        protected function creationCompleteHandler(event:FlexEvent):void
        {
            if (owner is ListBase && ListBase(owner).contextMenuEnabled)
            {
                var cm:ContextMenu = createContextMenu();
                cm.addEventListener(Event.SELECT, contextMenuSelectHandler);
                cm.addEventListener(Event.DISPLAYING, contextMenuDisplayingHandler);
                this.contextMenu = cm;
            }
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

            var isDragging:Boolean = (currentState == "dragging");

            // Update Colors
            var color:uint = COLOR_NORMAL;
            if (selected)
                color = COLOR_SELECTED;
            else if (_hovered)
                color = COLOR_HOVERED;

            if (_fill && _fill.fill is SolidColor)
            {
                SolidColor(_fill.fill).color = color;
            }

            // Visibility based on dragging state
            if (isDragging)
            {
                if (_fill)
                    _fill.visible = false;
                if (_border)
                    _border.visible = false;
                // MXML: <s:Label alpha.dragging="0" />
                if (_labelDisplay)
                    _labelDisplay.alpha = 0;
            }
            else
            {
                if (_fill)
                    _fill.visible = true;
                if (_border)
                    _border.visible = true;
                if (_labelDisplay)
                    _labelDisplay.alpha = 1;
            }
        }

        override public function set data(value:Object):void
        {
            super.data = value;

            // Guard against null during drag proxy creation
            if (!_imageDisplay || !_labelDisplay)
                return;

            var sprite:SpriteData = value as SpriteData;
            if (sprite)
            {
                _imageDisplay.source = sprite.getBitmap();
                _labelDisplay.text = sprite.id.toString();
            }
            else
            {
                _imageDisplay.source = null;
                _labelDisplay.text = "";
            }
        }

        // Context Menu

        protected function contextMenuDisplayingHandler(event:Event):void
        {
            if (owner is SpriteList)
            {
                SpriteList(owner).onContextMenuDisplaying(this.itemIndex, ContextMenu(event.target));
            }
        }

        protected function contextMenuSelectHandler(event:Event):void
        {
            if (owner is SpriteList)
            {
                var type:String = NativeMenuItem(event.target).data as String;
                SpriteList(owner).onContextMenuSelect(this.itemIndex, type);
            }
        }

        private static function createContextMenu():ContextMenu
        {
            var resource:IResourceManager = ResourceManager.getInstance();
            var copyMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "copy"));
            copyMenu.data = Event.COPY;
            var pasteMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "paste"));
            pasteMenu.data = Event.PASTE;
            var fillMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "fill"), true);
            fillMenu.data = SpriteListEvent.FILL;
            var replaceMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "replace"), true);
            replaceMenu.data = SpriteListEvent.REPLACE;
            var exportMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "export"));
            exportMenu.data = SpriteListEvent.EXPORT;
            var removeMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "remove"));
            removeMenu.data = SpriteListEvent.REMOVE;
            var menu:ContextMenu = new ContextMenu();
            menu.customItems = [copyMenu, pasteMenu, fillMenu, replaceMenu, exportMenu, removeMenu];
            return menu;
        }
    }
}
