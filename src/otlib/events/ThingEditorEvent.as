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

    import otlib.things.ThingData;

    public class ThingEditorEvent extends Event
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var data:ThingData;
        public var sprite:uint;
        public var property:Object;
        public var oldValue:Object;
        public var newValue:Object;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingEditorEvent(type:String,
                                         data:ThingData,
                                         sprite:uint = 0,
                                         property:Object = null,
                                         oldValue:Object = null,
                                         newValue:Object = null)
        {
            super(type);

            this.data = data;
            this.sprite = sprite;
            this.property = property;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Override Public
        //--------------------------------------

        override public function clone():Event
        {
            return new ThingEditorEvent(this.type,
                this.data,
                this.sprite,
                this.property,
                this.oldValue,
                this.newValue);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const THING_CHANGE:String = "thingChange";
        public static const THING_PROPERTY_CHANGE:String = "thingPropertyChange";
        public static const SPRITE_DOUBLE_CLICK:String = "spriteDoubleClick";
    }
}
