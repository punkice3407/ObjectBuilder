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

package nail.menu
{
    import nail.errors.NullArgumentError;
    import nail.utils.CapabilitiesUtil;
    import nail.utils.isNullOrEmpty;

    public class MenuItem
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var label:String;
        public var data:String;
        public var keyEquivalent:String;
        public var altKey:Boolean;
        public var controlKey:Boolean;
        public var shiftKey:Boolean;
        public var isSeparator:Boolean;
        public var isCheck:Boolean;
        public var toggled:Boolean;
        public var enabled:Boolean;
        public var items:Array;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function MenuItem(label:String = null)
        {
            this.label = label;
            this.enabled = true;
            this.items = [];
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function serialize():XML
        {
            var xml:XML = <menuitem/>;

            if (!isNullOrEmpty(label))
                xml.@label = label;
            else
                isSeparator = true;

            if (!isNullOrEmpty(data))
                xml.@data = data;

            if (!isNullOrEmpty(keyEquivalent))
            {
                var key:String = keyEquivalent.toLowerCase();
                if (key.length > 1 && key.charAt(0) == "f")
                    key = key.toUpperCase();

                xml.@keyEquivalent = key;
            }

            if (altKey)
                xml.@altKey = altKey;

            if (controlKey)
            {
                if (CapabilitiesUtil.isMac)
                    xml.@commandKey = controlKey;
                else
                    xml.@controlKey = controlKey;
            }

            if (shiftKey)
                xml.@shiftKey = shiftKey;

            if (isSeparator)
            {
                xml.@type = "separator";
            }
            else if (isCheck)
            {
                xml.@type = "check";
                xml.@toggled = toggled;
            }

            if (!enabled)
                xml.@enabled = enabled;

            if (items)
            {
                var length:uint = items.length;
                for (var i:uint = 0; i < length; i++)
                    xml.appendChild( items[i].serialize() );
            }

            return xml;
        }

        public function addMenuItem(item:MenuItem):void
        {
            if (!item)
                throw new NullArgumentError("item");

            if (!items)
                items = [];

            items[items.length] = item;
        }
    }
}
