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

package otlib.utils
{
    import flash.events.EventDispatcher;

    [Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]

    public class BindableLookType extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        [Bindable]
        public var outfit:uint;

        [Bindable]
        public var item:uint;

        [Bindable]
        public var head:uint;

        [Bindable]
        public var body:uint;

        [Bindable]
        public var legs:uint;

        [Bindable]
        public var feet:uint;

        [Bindable]
        public var addons:uint;

        [Bindable]
        public var mount:uint;

        [Bindable]
        public var corpse:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function BindableLookType()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function serialize():XML
        {
            var xml:XML = <look/>;
            if (this.outfit != 0)
                xml.@type = this.outfit;
            else if (this.item != 0)
                xml.@typeex = this.item;
            else
                return null;

            if (this.head != 0) xml.@head = this.head;
            if (this.body != 0) xml.@body = this.body;
            if (this.legs != 0) xml.@legs = this.legs;
            if (this.feet != 0) xml.@feet = this.feet;
            if (this.mount != 0) xml.@mount = this.mount;
            if (this.addons != 0) xml.@addons = this.addons;
            if (this.corpse != 0) xml.@corpse = this.corpse;
            return xml;
        }

        public function unserialize(xml:XML):void
        {
            if (xml.localName() != "look") {
                throw new Error("Invalid look XML. Missing look tag.");
            }

            this.clear();

            if (xml.hasOwnProperty("@type"))
                this.outfit = uint(xml.@type);
            else if (xml.hasOwnProperty("@typeex"))
                this.item = uint(xml.@typeex);
            else
                throw new Error("Invalid look XML. Missing look type/typeex.");

            if (xml.hasOwnProperty("@head")) this.head = uint(xml.@head);
            if (xml.hasOwnProperty("@body")) this.body = uint(xml.@body);
            if (xml.hasOwnProperty("@legs")) this.legs = uint(xml.@legs);
            if (xml.hasOwnProperty("@feet")) this.feet = uint(xml.@feet);
            if (xml.hasOwnProperty("@addons")) this.addons = uint(xml.@addons);
            if (xml.hasOwnProperty("@mount")) this.mount = uint(xml.@mount);
            if (xml.hasOwnProperty("@corpse")) this.corpse = uint(xml.@corpse);
        }

        public function clear():void
        {
            this.outfit = 0;
            this.item = 0;
            this.head = 0;
            this.body = 0;
            this.legs = 0;
            this.feet = 0;
            this.addons = 0;
            this.mount = 0;
            this.corpse = 0;
        }
    }
}
