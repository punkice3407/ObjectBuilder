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

package otlib.events
{
    import flash.events.Event;

    public class ThingListEvent extends Event
    {
        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ThingListEvent(type:String)
        {
            super(type);
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        // --------------------------------------
        // Override Public
        // --------------------------------------

        override public function clone():Event
        {
            return new ThingListEvent(this.type);
        }

        // --------------------------------------------------------------------------
        // STATIC
        // --------------------------------------------------------------------------

        public static const REPLACE:String = "replace";
        public static const EXPORT:String = "export";
        public static const EDIT:String = "edit";
        public static const DUPLICATE:String = "duplicate";
        public static const BULK_EDIT:String = "bulkEdit";
        public static const REMOVE:String = "remove";
        public static const COPY_OBJECT:String = "copyObject";
        public static const PASTE_OBJECT:String = "pasteObject";
        public static const COPY_PATTERNS:String = "copyPatterns";
        public static const PASTE_PATTERNS:String = "pastePatterns";
        public static const COPY_PROPERTIES:String = "copyProperties";
        public static const PASTE_PROPERTIES:String = "pasteProperties";
        public static const COPY_ATTRIBUTES:String = "copyAttributes";
        public static const PASTE_ATTRIBUTES:String = "pasteAttributes";
        public static const COPY_CLIENT_ID:String = "copyClientId";
        public static const COPY_SERVER_ID:String = "copyServerId";
        public static const COMPARE:String = "compare";
        public static const DISPLAYING_CONTEXT_MENU:String = "displayingContextMenu";
    }
}
