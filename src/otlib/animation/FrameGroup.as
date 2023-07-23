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
    import flash.utils.describeType;

    import otlib.geom.Size;
    import otlib.utils.SpriteExtent;

	[Bindable]
    public class FrameGroup
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

		public var type:uint;
        public var width:uint;
        public var height:uint;
        public var exactSize:uint;
        public var layers:uint;
        public var patternX:uint;
        public var patternY:uint;
        public var patternZ:uint;
        public var frames:uint;
		public var spriteIndex:Vector.<uint>;
        public var isAnimation:Boolean;
        public var animationMode:uint;
        public var loopCount:int;
        public var startFrame:int;
        public var frameDurations:Vector.<FrameDuration>;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function FrameGroup()
        {
			this.type = 0;
            this.width = 1;
            this.height = 1;
            this.layers = 1;
            this.frames = 1;
            this.patternX = 1;
            this.patternY = 1;
            this.patternZ = 1;
            this.exactSize = SpriteExtent.DEFAULT_SIZE;
            this.isAnimation = false;
            this.animationMode = AnimationMode.ASYNCHRONOUS;
            this.loopCount = 0;
            this.startFrame = 0;
            this.frameDurations = null;
        }

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function getFrameDuration(index:int):FrameDuration
        {
			if(this.frameDurations)
            	return this.frameDurations[index];

			return null;
        }

        public function getTotalX():uint
        {

            return this.patternZ * this.patternX * this.layers;
        }

        public function getTotalY():uint
        {

            return this.frames * this.patternY;
        }

        public function getTotalSprites():uint
        {
            return this.width *
                   this.height *
                   this.patternX *
                   this.patternY *
                   this.patternZ *
                   this.frames *
                   this.layers;
        }

        public function getTotalTextures():uint
        {
            return this.patternX *
                    this.patternY *
                    this.patternZ *
                    this.frames *
                    this.layers;
        }

        public function getSpriteIndex(width:uint,
                                       height:uint,
                                       layer:uint,
                                       patternX:uint,
                                       patternY:uint,
                                       patternZ:uint,
                                       frame:uint):uint
        {
            return ((((((frame % this.frames) *
                    this.patternZ + patternZ) *
                    this.patternY + patternY) *
                    this.patternX + patternX) *
                    this.layers + layer) *
                    this.height + height) *
                    this.width + width;
        }

        public function getTextureIndex(layer:uint,
                                        patternX:uint,
                                        patternY:uint,
                                        patternZ:uint,
                                        frame:uint):int
        {
            return (((frame % this.frames *
                    this.patternZ + patternZ) *
                    this.patternY + patternY) *
                    this.patternX + patternX) *
                    this.layers + layer;
        }

        public function getSpriteSheetSize():Size
        {
            var size:Size = new Size();
            size.width = this.patternZ * this.patternX * this.layers * this.width * SpriteExtent.DEFAULT_SIZE;
            size.height = this.frames * this.patternY * this.height * SpriteExtent.DEFAULT_SIZE;
            return size;
        }

        public function makeOutfitGroup(duration:uint):void
        {
            this.patternX = 4; // Directions
            this.frames = 1;   // Animations
            this.isAnimation = false;
            this.frameDurations = new Vector.<FrameDuration>(this.frames, true);

            for (var i:uint = 0; i < this.frames; i++)
                this.frameDurations[i] = new FrameDuration(duration, duration);

            this.spriteIndex = new Vector.<uint>(this.getTotalSprites(), true);
        }

        public function clone():FrameGroup
        {
			var group:FrameGroup = new FrameGroup();
			group.type = this.type;
			group.width = this.width;
			group.height = this.height;
			group.layers = this.layers;
			group.frames = this.frames;
			group.patternX = this.patternX;
			group.patternY = this.patternY;
			group.patternZ = this.patternZ;
			group.exactSize = this.exactSize;

			if(this.spriteIndex)
            	group.spriteIndex = this.spriteIndex.concat();

			group.animationMode = this.animationMode;
			group.loopCount = this.loopCount;
			group.startFrame = this.startFrame;

            if(this.frames > 1)
            {
                group.isAnimation = true;

                group.frameDurations = new Vector.<FrameDuration>(this.frames, true);
                for (var i:uint = 0; i < this.frames; i++)
                    group.frameDurations[i] = this.frameDurations[i].clone();
            }

            return group
        }
    }
}
