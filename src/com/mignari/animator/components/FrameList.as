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

package com.mignari.animator.components
{
    import flash.ui.ContextMenu;

    import com.mignari.animator.events.FrameListEvent;

    import otlib.components.ListBase;
    import otlib.core.otlib_internal;
    import com.mignari.animator.Frame;

    use namespace otlib_internal;

    [Event(name="duplicate", type="com.mignari.animator.events.FrameListEvent")]
    [Event(name="remove", type="com.mignari.animator.events.FrameListEvent")]

    public class FrameList extends ListBase
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get selectedFrames():Vector.<Frame>
        {
            var result:Vector.<Frame> = new Vector.<Frame>();
            if (this.selectedIndices) {
                var length:uint = selectedIndices.length;
                for (var i:uint = 0; i < length; i++) {
                    result[i] = dataProvider.getItemAt(selectedIndices[i]) as Frame;
                }
            }
            return result;
        }

        public function set selectedFrames(value:Vector.<Frame>):void
        {
            if (value) {
                var list:Vector.<int> = new Vector.<int>();
                var length:uint = value.length;
                for (var i:uint = 0; i < length; i++) {
                    var index:int = getIndexOf(value[i]);
                    if (index != -1) {
                        list.push(index);
                    }
                }
                this.selectedIndices = list;
            }
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function FrameList()
        {
            super();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        public function addObject(object:Frame):void
        {
            this.dataProvider.addItem(object);
        }

        //--------------------------------------
        // Internal
        //--------------------------------------

        otlib_internal function onContextMenuSelect(index:int, type:String):void
        {
            if (index != -1 && this.dataProvider)
            {
                var frame:Frame = this.dataProvider.getItemAt(index) as Frame;

                if (frame) {
                    var event:FrameListEvent;

                    switch(type) {
                        case FrameListEvent.DUPLICATE:
                            event = new FrameListEvent(FrameListEvent.DUPLICATE);
                            break;
                        case FrameListEvent.REMOVE:
                            event = new FrameListEvent(FrameListEvent.REMOVE);
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
            if (!this.multipleSelected)
                this.setSelectedIndex(index, true);

            if (hasEventListener(FrameListEvent.DISPLAYING_CONTEXT_MENU)) {
                dispatchEvent(new FrameListEvent(FrameListEvent.DISPLAYING_CONTEXT_MENU));
            }
        }
    }
}
