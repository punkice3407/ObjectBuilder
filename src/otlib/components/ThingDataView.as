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
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;

    import mx.core.UIComponent;

    import otlib.animation.Animator;
    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.geom.Rect;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingCategory;
    import otlib.things.ThingData;
    import otlib.things.ThingType;
    import otlib.utils.OutfitData;
    import otlib.utils.SpriteExtent;

    [Event(name="change", type="flash.events.Event")]
    [Event(name="complete", type="flash.events.Event")]

    public class ThingDataView extends UIComponent
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _thingData:ThingData;
        private var _proposedThingData:ThingData;
        private var _thingDataChanged:Boolean;
        private var _animator:Animator;
        private var _spriteSheet:BitmapData;
        private var _textureIndex:Vector.<Rect>;
        private var _bitmap:BitmapData;
        private var _fillRect:Rectangle;
        private var _point:Point;
        private var _rectangle:Rectangle;
        private var _frame:int;
        private var _maxFrame:int;
        private var _playing:Boolean;
        private var _lastTime:Number;
        private var _time:Number;
        private var _patternX:uint;
        private var _patternY:uint;
        private var _patternZ:uint;
        private var _layer:uint;
        private var _outfitData:OutfitData;
        private var _drawBlendLayer:Boolean;
        private var _backgroundColor:Number;
		private var _frameGroupType:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        [Bindable]
        public function get thingData():ThingData { return _proposedThingData ? _proposedThingData : _thingData; }
        public function set thingData(value:ThingData):void
        {
            if (_thingData != value) {
                _proposedThingData = value;
                _thingDataChanged = true;
                invalidateProperties();
            }
        }

        public function get patternX():uint { return _patternX; }
        public function set patternX(value:uint):void { _patternX = value; }

        public function get patternY():uint { return _patternY; }
        public function set patternY(value:uint):void { _patternY = value; }

        public function get patternZ():uint { return _patternZ; }
        public function set patternZ(value:uint):void { _patternZ = value; }

        public function get frame():int { return _frame; }
        public function set frame(value:int):void
        {
            if (_frame != value) {
                _frame = value % _maxFrame;
                _time = 0;
                draw();

                if (hasEventListener(Event.CHANGE))
                    dispatchEvent(new Event(Event.CHANGE));
            }
        }

        public function get outfitData():OutfitData { return _outfitData; }
        public function set outfitData(value:OutfitData):void { _outfitData = value; }

        public function get drawBlendLayer():Boolean { return _drawBlendLayer; }
        public function set drawBlendLayer(value:Boolean):void { _drawBlendLayer = value; }

        public function get backgroundColor():Number { return _backgroundColor; }
        public function set backgroundColor(value:Number):void
        {
            if (isNaN(_backgroundColor) && isNaN(value))
                return;

            if (_backgroundColor != value) {
                _backgroundColor = value;
                draw();
            }
        }

		public function get frameGroupType():uint { return _frameGroupType; }
		public function set frameGroupType(value:uint):void { _frameGroupType = value; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ThingDataView()
        {
            _point = new Point();
            _rectangle = new Rectangle();
            _frame = -1;
            _lastTime = 0;
            _time = 0;

            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function fistFrame():void
        {
            frame = 0;
        }

        public function prevFrame():void
        {
            frame = Math.max(0, _frame - 1);
        }

        public function nextFrame():void
        {
            frame = _frame + 1;
        }

        public function lastFrame():void
        {
            frame = Math.max(0, _maxFrame - 1);
        }

        public function play():void
        {
			var frameGroup:FrameGroup = thingData.thing.getFrameGroup(frameGroupType);
            if (thingData && frameGroup && frameGroup.isAnimation)
				_playing = true;
        }

        public function pause():void
        {
            _playing = false;
        }

        public function stop():void
        {
            _playing = false;
            frame = 0;
        }

        //--------------------------------------
        // Override Protected
        //--------------------------------------

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_thingDataChanged) {
                setThingData(_proposedThingData);
                _proposedThingData = null;
                _thingDataChanged = false;
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function setThingData(thingData:ThingData):void
        {
            if (thingData) {
                if (thingData.thing.category == ThingCategory.OUTFIT) {
                    if (!_outfitData)
                        _outfitData = new OutfitData();

					thingData = thingData.clone().colorize(_outfitData);
                }

				var frameGroup:FrameGroup = thingData.thing.getFrameGroup(frameGroupType);
                _textureIndex = new Vector.<Rect>();
                _spriteSheet = thingData.getSpriteSheet(frameGroup, _textureIndex, 0);

                _bitmap = new BitmapData(frameGroup.width * SpriteExtent.DEFAULT_SIZE, frameGroup.height * SpriteExtent.DEFAULT_SIZE, true);
                _fillRect = _bitmap.rect;
                _maxFrame = frameGroup.frames;
                _frame = 0;
                _playing = frameGroup.isAnimation ? _playing : false;

                width = _bitmap.width;
                height = _bitmap.height;

				var durations:Vector.<FrameDuration> = frameGroup.frameDurations;
				if(durations && frameGroup.type == FrameGroupType.WALKING && frameGroup.frames > 2)
				{
					var duration:uint = 1000 / frameGroup.frames;
					for (var i:uint = 0; i < frameGroup.frames; i++)
						durations[i] = new FrameDuration(duration, duration);
				}

				if (frameGroup.isAnimation) {
					_animator = new Animator(frameGroup.animationMode, frameGroup.loopCount, frameGroup.startFrame, durations, frameGroup.frames);
					_animator.skipFirstFrame = (thingData.category == ThingCategory.OUTFIT && !thingData.thing.animateAlways && frameGroup.type != FrameGroupType.WALKING);
				}
            } else {
                _textureIndex = null;
                _spriteSheet = null;
                _animator = null;
                _bitmap = null;
                _maxFrame = -1;
                _frame = -1;
                _playing = false;
            }

            _thingData = thingData;

            draw();
        }

        private function draw():void
        {
            graphics.clear();

            if (_spriteSheet)
            {
                if (!isNaN(_backgroundColor)) {
                    graphics.beginFill(_backgroundColor);
                    graphics.drawRect(0, 0, _fillRect.width, _fillRect.height);
                    graphics.endFill();
                }

				var frameGroup:FrameGroup = thingData.thing.getFrameGroup(frameGroupType);
                var layers:uint = _drawBlendLayer ? frameGroup.layers : 1;
                var px:uint = _patternX % frameGroup.patternX;
                var pz:uint = _patternZ % frameGroup.patternZ;

                _bitmap.fillRect(_fillRect, 0);

                for (var l:uint = 0; l < layers; l++)
                {
                    var index:int = frameGroup.getTextureIndex(l, px, 0, pz, _frame);
                    if (index >= _textureIndex.length)
                        index = 0;

                    var rect:Rect = _textureIndex[index];

                    _rectangle.setTo(rect.x, rect.y, rect.width, rect.height);
                    _bitmap.copyPixels(_spriteSheet, _rectangle, _point, null, null, true);
                }

                graphics.beginBitmapFill(_bitmap);
                graphics.drawRect(0, 0, _fillRect.width, _fillRect.height);
            }

            graphics.endFill();
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function addedToStageHandler(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            addEventListener(Event.ENTER_FRAME, enterFramehandler);
        }

        protected function enterFramehandler(event:Event):void
        {
            if (!_playing || !thingData)
            {
                return;
            }

            var elapsed:Number = getTimer();
            if (_animator)
            {
                _animator.update(elapsed);
                if (_animator.isComplete)
                {
                    if (_thingData.thing.animateAlways)
                    {
                        _animator.reset();
                    }
                    else
                    {
                        pause();
                        dispatchEvent(new Event(Event.COMPLETE));
                    }
                }

                frame = _animator.frame;
            }
        }
    }
}
