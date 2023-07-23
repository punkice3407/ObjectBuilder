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
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.ContextMenu;
    import flash.ui.Keyboard;

    import mx.core.ClassFactory;

    import otlib.components.renders.SpriteListRenderer;
    import otlib.core.otlib_internal;
    import otlib.events.SpriteListEvent;
    import otlib.sprites.SpriteData;

    [Event(name="copy", type="flash.events.Event")]
    [Event(name="paste", type="flash.events.Event")]
    [Event(name="fill", type="otlib.events.SpriteListEvent")]
    [Event(name="replace", type="otlib.events.SpriteListEvent")]
    [Event(name="export", type="otlib.events.SpriteListEvent")]
    [Event(name="remove", type="otlib.events.SpriteListEvent")]

    public class SpriteList extends ListBase
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get selectedSprite():SpriteData
        {
            if (selectedItem)
                return selectedItem as SpriteData;
            return null;
        }

        public function set selectedSprite(value:SpriteData):void
        {
            selectedIndex = getIndexOf(value);
        }

        public function get selectedSprites():Vector.<SpriteData>
        {
            var result:Vector.<SpriteData> = new Vector.<SpriteData>();

            if (selectedIndices) {
                var length:uint = selectedIndices.length;
                for (var i:uint = 0; i < length; i++) {
                    result[i] = dataProvider.getItemAt(selectedIndices[i]) as SpriteData;
                }
            }
            return result;
        }

        public function set selectedSprites(value:Vector.<SpriteData>):void
        {
            if (value) {
                var list:Vector.<Object> = new Vector.<Object>();
                var length:uint = value.length;
                for (var i:uint = 0; i < length; i++) {
                    list[i] = value[i];
                }
                selectedItems = list;
            }
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteList()
        {
            itemRenderer = new ClassFactory(SpriteListRenderer);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Internal
        //--------------------------------------

        otlib_internal function onContextMenuSelect(index:int, type:String):void
        {
            if (index != -1 && dataProvider) {
                var spriteData:SpriteData = dataProvider.getItemAt(index) as SpriteData;
                var event:Event;
                if (spriteData) {
                    switch(type) {
                        case Event.COPY:
                            event = new Event(Event.COPY);
                            break;
                        case Event.PASTE:
                            event = new Event(Event.PASTE);
                            break;
                        case SpriteListEvent.FILL:
                            event = new SpriteListEvent(SpriteListEvent.FILL);
                            break;
                        case SpriteListEvent.REPLACE:
                            event = new SpriteListEvent(SpriteListEvent.REPLACE);
                            break;
                        case SpriteListEvent.EXPORT:
                            event = new SpriteListEvent(SpriteListEvent.EXPORT);
                            break;
                        case SpriteListEvent.REMOVE:
                            event = new SpriteListEvent(SpriteListEvent.REMOVE);
                            break;
                    }

                    if (event)
                        dispatchEvent(event);
                }
            }
        }

        otlib_internal function onContextMenuDisplaying(index:int, menu:ContextMenu):void
        {
            if (multipleSelected) {
                menu.items[0].enabled = false; // Copy
                menu.items[1].enabled = false; // Paste
            } else {
                setSelectedIndex(index, true);
            }

            if (hasEventListener(SpriteListEvent.DISPLAYING_CONTEXT_MENU)) {
                dispatchEvent(new SpriteListEvent(SpriteListEvent.DISPLAYING_CONTEXT_MENU));
            }
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            super.keyDownHandler(event);

            switch(event.keyCode) {
                case Keyboard.INSERT:
                    dispatchEvent(new SpriteListEvent(SpriteListEvent.FILL));
                    break;
                case Keyboard.C:
                    if (event.ctrlKey) dispatchEvent(new Event(Event.COPY));
                    break;
                case Keyboard.V:
                    if (event.ctrlKey) dispatchEvent(new Event(Event.PASTE));
                    break;
                case Keyboard.DELETE:
                    dispatchEvent(new SpriteListEvent(SpriteListEvent.REMOVE));
                    break;
            }
        }
    }
}
