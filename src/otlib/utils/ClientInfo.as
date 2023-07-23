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
    public class ClientInfo
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var clientVersion:uint;
        public var clientVersionStr:String;
        public var datSignature:uint;
        public var minItemId:uint;
        public var maxItemId:uint;
        public var minOutfitId:uint;
        public var maxOutfitId:uint;
        public var minEffectId:uint;
        public var maxEffectId:uint;
        public var minMissileId:uint;
        public var maxMissileId:uint;
        public var sprSignature:uint;
        public var minSpriteId:uint;
        public var maxSpriteId:uint;
        public var extended:Boolean;
        public var transparency:Boolean;
        public var improvedAnimations:Boolean;
        public var frameGroups:Boolean;
        public var changed:Boolean;
        public var isTemporary:Boolean;
        public var loaded:Boolean;
        public var spriteSize:uint;
        public var spriteDataSize:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ClientInfo()
        {
        }
    }
}
