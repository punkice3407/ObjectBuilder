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
    import flash.ui.Keyboard;

    import mx.events.FlexEvent;

    import spark.components.Button;
    import spark.components.NumericStepper;
    import spark.formatters.NumberFormatter;

    import otlib.utils.OtlibUtils;

    public class AmountNumericStepper extends NumericStepper
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        [SkinPart(required="true", type="spark.components.Button")]
        public var firstButton:Button;

        [SkinPart(required="true", type="spark.components.Button")]
        public var previousAmountButton:Button;

        [SkinPart(required="true", type="spark.components.Button")]
        public var nextAmountButton:Button;

        [SkinPart(required="true", type="spark.components.Button")]
        public var lastButton:Button;

        private var _dataFormatter:NumberFormatter;
        private var _amount:uint;
        private var _amountChanged:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get amount():uint { return _amount; }
        public function set amount(value:uint):void
        {
            if (_amount != value) {
                _amount = value;
                _amountChanged = true;
                invalidateProperties();
            }
        }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function AmountNumericStepper()
        {
            _amount = 100;
            _dataFormatter = new NumberFormatter();
            this.valueParseFunction = this.parseFunction;
            this.focusEnabled = false;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        /**
         *  @private
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

            if (instance == firstButton) {
                firstButton.focusEnabled = false;
                firstButton.addEventListener(FlexEvent.BUTTON_DOWN, fistButtonDownHandler);
                firstButton.autoRepeat = false;
            } else if (instance == previousAmountButton) {
                previousAmountButton.focusEnabled = false;
                previousAmountButton.addEventListener(FlexEvent.BUTTON_DOWN, previousAmountButtonDownHandler);
                previousAmountButton.autoRepeat = false;
            } else if (instance == nextAmountButton) {
                nextAmountButton.focusEnabled = false;
                nextAmountButton.addEventListener(FlexEvent.BUTTON_DOWN, nextAmountButtonButtonDownHandler);
                nextAmountButton.autoRepeat = false;
            } else if (instance == lastButton) {
                lastButton.focusEnabled = false;
                lastButton.addEventListener(FlexEvent.BUTTON_DOWN, lastButtonDownHandler);
                lastButton.autoRepeat = false;
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_amountChanged) {
                this.value = Math.max(minimum, OtlibUtils.hundredFloor(value) - _amount);
                _amountChanged = false;
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function parseFunction(text:String):Number
        {
            return _dataFormatter.parseNumber(text);
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function fistButtonDownHandler(event:FlexEvent):void
        {
            var current:Number = this.value;
            this.value = minimum;

            if (current != this.value)
                dispatchEvent(new Event(Event.CHANGE));
        }

        protected function previousAmountButtonDownHandler(event:FlexEvent):void
        {
            var current:Number = this.value;
            this.value = Math.max(minimum, OtlibUtils.hundredFloor(value) - _amount);

            if (current != this.value)
                dispatchEvent(new Event(Event.CHANGE));
        }

        protected function nextAmountButtonButtonDownHandler(event:FlexEvent):void
        {
            var current:Number = this.value;
            this.value = Math.min(maximum, OtlibUtils.hundredFloor(value) + _amount);

            if (current != this.value)
                dispatchEvent(new Event(Event.CHANGE));
        }

        protected function lastButtonDownHandler(event:FlexEvent):void
        {
            var current:Number = this.value;
            this.value = maximum;

            if (current != this.value)
                dispatchEvent(new Event(Event.CHANGE));
        }

        /**
         *  @private
         *  Handles keyboard input. Up arrow increments. Down arrow
         *  decrements. Home and End keys set the value to maximum
         *  and minimum respectively.
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            if (event.isDefaultPrevented())
                return;

            var current:Number = this.value;

            switch (event.keyCode) {
                case Keyboard.DOWN:
                case Keyboard.LEFT:
                    changeValueByStep(false);
                    event.preventDefault();
                    break;
                case Keyboard.UP:
                case Keyboard.RIGHT:
                    changeValueByStep(true);
                    event.preventDefault();
                    break;
                case Keyboard.HOME:
                    this.value = minimum;
                    event.preventDefault();
                    break;
                case Keyboard.END:
                    this.value = maximum;
                    event.preventDefault();
                    break;
            }

            if (this.value != current)
                dispatchEvent(new Event(Event.CHANGE));
        }
    }
}
