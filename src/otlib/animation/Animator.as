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

package otlib.animation
{
    import flash.utils.getTimer;

    public class Animator
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var mode:uint;
        public var loopCount:int;
        public var startFrame:int;
        public var durations:Vector.<FrameDuration>;
        public var frames:uint;
        public var skipFirstFrame:Boolean;

        private var m_lastTime:Number = 0;
        private var m_currentFrameDuration:uint;
        private var m_currentFrame:uint;
        private var m_currentLoop:uint;
        private var m_currentDirection:uint;
        private var m_isComplete:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get frame():int { return m_currentFrame; }
        public function set frame(value:int):void
        {
            if (m_currentFrame == value)
            {
                return;
            }

            if (this.mode == AnimationMode.ASYNCHRONOUS)
            {
                if (value == FRAME_ASYNCHRONOUS)
                {
                    m_currentFrame = 0;
                }
                else if (value == FRAME_RANDOM)
                {
                    m_currentFrame = Math.floor(Math.random() * this.frames);
                }
                else if (value >= 0 && value < this.frames)
                {
                    m_currentFrame = value;
                }
                else
                {
                    m_currentFrame = this.getStartFrame();
                }

                m_isComplete = false;
                m_lastTime = getTimer();
                m_currentFrameDuration = this.durations[m_currentFrame].duration;
            }
            else
            {
                this.calculateSynchronous();
            }
        }

        public function get isComplete():Boolean { return m_isComplete; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Animator(mode:uint, loopCount:int, startFrame:int, durations:Vector.<FrameDuration>, frames:uint)
        {
            if (mode != AnimationMode.ASYNCHRONOUS && mode != AnimationMode.SYNCHRONOUS)
            {
                throw new ArgumentError("Unexpected animation mode " + mode);
            }

            if (startFrame < -1 || startFrame >= frames)
            {
                throw new ArgumentError("Invalid start frame " + startFrame);
            }

            if (durations.length != frames)
            {
                throw new ArgumentError("Frame duration differs from frame count");
            }

            this.mode = mode;
            this.loopCount = loopCount;
            this.startFrame = startFrame;
            this.durations = durations;
            this.frames = frames;
            this.frame = FRAME_AUTOMATIC;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function update(time:Number):void
        {
            if (time != m_lastTime && !m_isComplete)
            {
                var elapsed:Number = time - m_lastTime;
                if (elapsed >= m_currentFrameDuration)
                {
                    var frame:uint = loopCount < 0 ? getPingPongFrame() : getLoopFrame();
                    if (m_currentFrame != frame)
                    {
                        var duration:int = this.durations[frame].duration - (elapsed - m_currentFrameDuration);
                        if (duration < 0 && this.mode == AnimationMode.SYNCHRONOUS)
                        {
                            this.calculateSynchronous();
                        }
                        else
                        {
                            m_currentFrame = skipFirstFrame && frame == 0 ? 1 % frames : frame;
                            m_currentFrameDuration = duration < 0 ? 0 : duration;
                        }
                    }
                    else
                    {
                        m_isComplete = true;
                    }
                }
                else
                {
                    m_currentFrameDuration = m_currentFrameDuration - elapsed;
                }

                m_lastTime = time;
            }
        }

        public function getStartFrame():uint
        {
            if (this.startFrame > -1)
            {
                return this.startFrame;
            }

            return Math.floor(Math.random() * this.frames);
        }

        public function clone():Animator
        {
            var durationsCopy:Vector.<FrameDuration> = new Vector.<FrameDuration>(this.frames, true);
            for (var i:uint = 0; i < this.frames; i++)
            {
                durationsCopy[i] = this.durations[i].clone();
            }

            return new Animator(this.mode, this.loopCount, this.startFrame, durationsCopy, this.frames);
        }

        public function reset():void
        {
            frame = FRAME_AUTOMATIC;
            m_currentLoop = 0;
            m_currentDirection = FORWARD;
            m_isComplete = false;
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function calculateSynchronous():void
        {
            var totalDuration:Number = 0;
            for (var i:uint = 0; i < frames; i++)
            {
                totalDuration += durations[i].duration;
            }

            var time:Number = getTimer();
            var elapsed:Number = time % totalDuration;
            var totalTime:Number = 0;

            for (i = 0; i < frames; i++)
            {
                var duration:Number = this.durations[i].duration;
                if (elapsed >= totalTime && elapsed < totalTime + duration)
                {
                    m_currentFrame = i;
                    m_currentFrameDuration = duration - (elapsed - totalTime);
                    break;
                }

                totalTime += duration;
            }

            m_lastTime = time;
        }

        private function getLoopFrame():uint
        {
            var nextFrame:uint = (m_currentFrame + 1);
            if (nextFrame < frames)
            {
                return nextFrame;
            }

            if (loopCount == 0)
            {
                return 0;
            }

            if (m_currentLoop < (loopCount - 1))
            {
                m_currentLoop++;
                return 0;
            }

            return m_currentFrame;
        }

        private function getPingPongFrame():uint
        {
            var count:int = m_currentDirection == FORWARD ? 1 : -1;
            var nextFrame:int = m_currentFrame + count;
            if (m_currentFrame + count < 0 || nextFrame >= frames)
            {
                m_currentDirection = m_currentDirection == FORWARD ? BACKWARD : FORWARD;
                count *= -1;
            }

            return m_currentFrame + count;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        static public const FRAME_AUTOMATIC:int = -1;
        static public const FRAME_RANDOM:int = 0xFE;
        static public const FRAME_ASYNCHRONOUS:int = 0xFF;
        static public const FORWARD:uint = 0;
        static public const BACKWARD:uint = 1;
    }
}
