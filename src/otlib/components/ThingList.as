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

    import otlib.components.renders.ThingListRenderer;
    import otlib.core.otlib_internal;
    import otlib.events.ThingListEvent;
    import otlib.things.ThingType;
    import otlib.utils.ThingListItem;

    [Event(name="replace", type="otlib.events.ThingListEvent")]
    [Event(name="export", type="otlib.events.ThingListEvent")]
    [Event(name="edit", type="otlib.events.ThingListEvent")]
    [Event(name="duplicate", type="otlib.events.ThingListEvent")]
    [Event(name="remove", type="otlib.events.ThingListEvent")]
    [Event(name="displayingContextMenu", type="otlib.events.ThingListEvent")]

    public class ThingList extends ListBase
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingList()
        {
            this.itemRenderer = new ClassFactory(ThingListRenderer);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Internal
        //--------------------------------------

        otlib_internal function onContextMenuSelect(index:int, type:String):void
        {
            if (index != -1 && this.dataProvider)
            {
                var listItem:ThingListItem = this.dataProvider.getItemAt(index) as ThingListItem;

                if (listItem && listItem.thing) {
                    var event:ThingListEvent;

                    switch(type) {
                        case ThingListEvent.REPLACE:
                            event = new ThingListEvent(ThingListEvent.REPLACE);
                            break;
                        case ThingListEvent.EXPORT:
                            event = new ThingListEvent(ThingListEvent.EXPORT);
                            break;
                        case ThingListEvent.EDIT:
                            event = new ThingListEvent(ThingListEvent.EDIT);
                            break;
                        case ThingListEvent.DUPLICATE:
                            event = new ThingListEvent(ThingListEvent.DUPLICATE);
                            break;
                        case ThingListEvent.REMOVE:
                            event = new ThingListEvent(ThingListEvent.REMOVE);
                            break;
                    }

                    if (event) {
                        dispatchEvent(event);
                    }
                }
            }
        }

        otlib_internal function onContextMenuDisplaying(index:int, menu:ContextMenu):void
        {
            if (this.multipleSelected)
                menu.items[2].enabled = false; // Edit
            else
                this.setSelectedIndex(index, true);

            if (hasEventListener(ThingListEvent.DISPLAYING_CONTEXT_MENU)) {
                dispatchEvent(new ThingListEvent(ThingListEvent.DISPLAYING_CONTEXT_MENU));
            }
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            super.keyDownHandler(event);

            switch(event.keyCode) {
                case Keyboard.C:
                    if (event.ctrlKey) dispatchEvent(new Event(Event.COPY));
                    break;
                case Keyboard.V:
                    if (event.ctrlKey) dispatchEvent(new Event(Event.PASTE));
                    break;
                case Keyboard.DELETE:
                    dispatchEvent(new ThingListEvent(ThingListEvent.REMOVE));
                    break;
            }
        }

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get selectedThing():ThingType
        {
            if (this.selectedItem) {
                return this.selectedItem.thing;
            }
            return null;
        }

        public function get selectedThings():Vector.<ThingType>
        {
            var result:Vector.<ThingType> = new Vector.<ThingType>();
            if (this.selectedIndices) {
                var length:uint = selectedIndices.length;
                for (var i:uint = 0; i < length; i++) {
                    result[i] = dataProvider.getItemAt(selectedIndices[i]).thing;
                }
            }
            return result;
        }

        public function set selectedThings(value:Vector.<ThingType>):void
        {
            if (value) {
                var list:Vector.<int> = new Vector.<int>();
                var length:uint = value.length;
                for (var i:uint = 0; i < length; i++) {
                    var index:int = getIndexById(value[i].id);
                    if (index != -1)
                    {
                        list.push(index);
                    }
                }
                this.selectedIndices = list;
            }
        }
    }
}
